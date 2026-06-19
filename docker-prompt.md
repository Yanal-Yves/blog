# Objectif

Mets en place un environnement Docker reproductible et isolé pour ce projet,
calqué sur une architecture que j'ai déjà utilisée sur un autre dépôt. Je te
décris les principes et les décisions ci-dessous : adapte-les à CE projet (outil
de build, langage, plateforme de déploiement) plutôt que de recopier à
l'identique. Avant de coder, inspecte le dépôt (langage, build, CI existante,
plateforme de déploiement) et propose-moi le plan adapté.

## Principe directeur

UNE source unique de vérité (un `Dockerfile` multi-stage) produit DEUX images
depuis un même fichier, pour que l'environnement de CI et l'environnement de dev
local soient strictement alignés (même version d'outil de build partout) :

- **Image CI** (étage `build`) : minimale, ne contient QUE l'outil de build
  (+ ses dépendances strictes, ex. git). Légère, utilisée par le déploiement.
- **Image dev** (étage `dev`) : tout ce que la CI a + les outils de travail local
  (Node, Claude Code, GitHub CLI `gh`, Neovim, etc.).

Le binaire de l'outil de build de l'image dev est COPIÉ depuis l'étage CI
(`COPY --from=build ...`) : impossible que les deux divergent de version.
La version de l'outil est figée via un `ARG ...VERSION=x.y.z` en tête de Dockerfile ;
la bumper = changer cette ligne et commit, la CI suit automatiquement.

## Modèle de sécurité (le point central — Claude tourne DANS le conteneur)

L'idée est de pouvoir donner de larges droits à Claude tout en bornant les dégâts
au seul projet et au seul repo. Deux couches :

1. **Isolation disque par les montages** : on ne monte QUE le projet (lecture/écriture).
   JAMAIS `$HOME`, `~/.ssh`, etc. JAMAIS le socket Docker (= évasion triviale).
   Tout dossier hôte supplémentaire (ex. captures d'écran pour que Claude les voie)
   est monté en LECTURE SEULE (`:ro`).
2. **Isolation GitHub par le token, PAS par le conteneur** : un token GitHub
   *fine-grained* limité au SEUL repo courant, fourni via `.env` (gitignoré).
   `gh` et git l'utilisent. C'est ce périmètre qui borne les dégâts, pas le conteneur.
3. Config Claude isolée dans un **volume nommé** dédié (login persistant entre runs),
   séparée du `~/.claude` de l'hôte.
4. Conteneur en utilisateur **non-root**.

Documente clairement que le réseau reste ouvert (egress non verrouillé) si c'est
le cas.

## Portabilité utilisateur (Linux uid ≠ 1000)

Le conteneur doit pouvoir écrire dans le projet monté sur n'importe quel hôte.
- L'utilisateur du conteneur est aligné sur l'hôte via des `ARG UID=1000`/`GID=1000`
  passés par compose (`args: UID: ${UID:-1000}` / `GID: ${GID:-1000}`).
- Sur un hôte Linux dont l'uid ≠ 1000, on renseigne UID/GID dans `.env` et on
  CONSTRUIT l'image (pas `pull`, l'image publiée est en uid 1000).
- Robustesse du Dockerfile : si le GID existe déjà dans l'image, réutiliser le
  groupe ; `usermod -o` pour tolérer un uid déjà pris. Pré-créer `~/.claude` et
  le `chown` pour que le volume nommé hérite du bon propriétaire.
- Garde git « dubious ownership » : `git config --system --add safe.directory '*'`
  dans les deux étages (le dépôt monté n'appartient pas au user du conteneur).

## Convention de chemin de montage

Le projet vit sous le home de CHAQUE environnement, suffixé par
`_gh/<org>/<repo>` (calque l'organisation GitHub, scale à plusieurs dépôts sans
collision, contrairement à un `/workspace` unique) :
- Hôte : `~/_gh/<org>/<repo>`
- Conteneur dev : `/home/<user-conteneur>/_gh/<org>/<repo>` (fixé dans compose `working_dir` + montage)
- CI : `$HOME/_gh/<org>/<repo>` (ex. `/home/runner/...`)

L'utilisateur du conteneur est générique (ex. `node`) → AUCUN chemin personnel de
l'hôte n'est inscrit dans les fichiers versionnés.

## Fichiers à produire

1. **`Dockerfile`** multi-stage (`build` puis `dev`), abondamment commenté
   (chaque décision non évidente expliquée : pourquoi git, pourquoi safe.directory,
   pourquoi COPY --from, gestion uid/gid).
2. **`compose.yaml`** : service `dev`, build de l'étage `dev` + `image:` pointant
   sur le registre (permet `pull` au lieu de rebuild), `init: true`, `stdin_open`,
   `tty`, port forwardé, montages (projet RW + volume config Claude + éventuels
   dossiers `:ro`), variables d'env pour le token. Sur un montage `:ro` optionnel
   dont la source vient d'une variable avec défaut (ex. `${SCREENSHOTS_DIR:-...}`),
   poser `bind: { create_host_path: false }` : sinon Compose crée en douce une
   source absente (dossier vide possédé par root). Alternative si le montage doit
   être vraiment facultatif : le sortir dans un `compose.override.yaml` opt-in.
3. **`.env.example`** : token fine-grained documenté (comment le générer, scope
   repo unique) + variables de chemin optionnelles. AVERTIR que Compose n'expanse
   PAS `$HOME`/`$PWD` dans `.env` (valeurs littérales → chemins absolus).
4. **`.devcontainer/devcontainer.json`** : pour VSCode Dev Containers / JetBrains
   Gateway (éditeur graphique sur l'hôte, se connecte dans le conteneur).
   `overrideCommand: true` pour ne PAS lancer le serveur au démarrage du devcontainer.
5. **Workflow CI `image.yml`** : reconstruit et publie les DEUX images sur le
   registre (ghcr.io) quand le Dockerfile change + `workflow_dispatch`. Utiliser
   buildx, cache gha avec un `scope` DISTINCT par image (sinon le 2e build écrase
   le cache du 1er), et un label `org.opencontainers.image.source` pour lier le
   paquet au dépôt (le `GITHUB_TOKEN` du déploiement peut alors le tirer).
   AJOUTER `docker/setup-buildx-action` AVANT les étapes de build : le driver
   `docker` par défaut du runner ne sait pas exporter le cache gha (échec
   « Cache export is not supported for the docker driver »). Épingler toutes les
   actions sur des versions **Node 24** (checkout, build-push, login, setup-buildx,
   gh-pages…) — les anciennes tournent en Node 20, déprécié par GitHub.
6. **Workflow de déploiement `deploy.yml`** : construit le site/artefact DANS
   l'image CI (`docker run --user "$(id -u):$(id -g)" -v "$PWD:..." -w "..."`)
   pour un build identique au local. Déclenchement : push de contenu (en IGNORANT
   les changements de Dockerfile via `paths-ignore`) + `workflow_run` APRÈS
   `image.yml` quand le Dockerfile change (pour bâtir avec l'image fraîchement
   publiée — éviter la course « build avec l'ancienne image »).
7. **`CONTAINER.md`** : documentation de mise en route, modèle de sécurité,
   convention de chemins, cas uid ≠ 1000, et le piège du « premier déploiement qui
   échoue tant que l'image n'est pas publiée ».

## Pièges à documenter explicitement

- Premier merge : `deploy.yml` échoue tant que l'image CI n'est pas sur le
  registre ; il se relance via `workflow_run` quand `image.yml` a fini.
- Commit mixte (contenu + Dockerfile) → déploiement avec l'ancienne image avant
  publication de la nouvelle. Conseiller de committer un bump de Dockerfile SEUL.
- Changer l'uid après un premier run : le volume nommé garde l'ancien propriétaire,
  le recréer (`docker volume rm <projet>_<volume>`).
- `workflow_dispatch` n'est dispo (bouton « Run workflow ») qu'une fois le workflow
  présent sur la branche par défaut → on ne peut PAS amorcer `image.yml` à la main
  avant le tout premier merge. Pour tester `image.yml` sur une branche AVANT merge,
  il faut qu'il existe déjà sur `main`, puis `gh workflow run … --ref <branche>`.
- Montage `:ro` optionnel : un défaut de chemin qui n'existe pas sur l'hôte (autre
  locale, autre OS, dossier jamais créé) fait que Compose crée un dossier vide en
  root. Cf. `create_host_path: false` ci-dessus.
