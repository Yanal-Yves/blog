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
  (Node, Claude Code, GitHub CLI `gh`, Neovim, `openssh-client` pour le push git,
  et un langage de script généraliste — Python — bien pratique pour Claude, etc.).
  Côté Python sur base Debian : `python3` + `python3-venv` + `pipx`, et `~/.local/bin`
  dans le `PATH` ; `pip` système est verrouillé (PEP 668) → libs via venv, outils
  CLI via `pipx`.

Le binaire de l'outil de build de l'image dev est COPIÉ depuis l'étage CI
(`COPY --from=build ...`) : impossible que les deux divergent de version.
La version de l'outil est figée via un `ARG ...VERSION=x.y.z` en tête de Dockerfile ;
la bumper = changer cette ligne et commit, la CI suit automatiquement.

## Modèle de sécurité (le point central — Claude tourne DANS le conteneur)

L'idée est de pouvoir donner de larges droits à Claude tout en bornant les dégâts
au seul projet et au seul repo. Plusieurs couches :

1. **Isolation disque par les montages** : on ne monte QUE le projet (lecture/écriture).
   JAMAIS `$HOME`, ni le `~/.ssh` ou la clé SSH PERSONNELLE de l'hôte (elle a accès
   à tout le compte). JAMAIS le socket Docker (= évasion triviale). Tout dossier hôte
   supplémentaire (ex. captures d'écran pour que Claude les voie) est monté en LECTURE
   SEULE (`:ro`). Seule exception SSH tolérée : une *deploy key* DÉDIÉE au repo, montée
   en `:ro` (cf. « Transport git » plus bas) — jamais ta clé perso.
2. **Isolation GitHub par les identifiants, PAS par le conteneur** : le périmètre est
   borné au SEUL repo courant, par l'une ou l'autre voie (ou les deux), fournies via
   `.env` (gitignoré) :
   - un token GitHub *fine-grained* limité au repo (HTTPS) — sert AUSSI à `gh` / l'API
     / la création de PR ;
   - et/ou une *deploy key* dédiée au repo (SSH) — transport git seulement.
   C'est ce périmètre qui borne les dégâts, pas le conteneur.
3. **Config Claude isolée ET persistante** : un **volume nommé** dédié, séparé du
   `~/.claude` de l'hôte. ATTENTION (piège vérifié) : monter le volume sur `~/.claude`
   ne suffit PAS — le fichier d'état `~/.claude.json` (login, onboarding, INDEX des
   conversations) vit à la racine du HOME, HORS du volume, et est perdu à chaque
   recréation. Pose `CLAUDE_CONFIG_DIR=<chemin du volume>` pour que Claude écrive
   TOUT (config, credentials, historique) dans le volume → plus de ré-auth ni
   d'historique perdu. Détaillé dans « Pièges ».
4. Conteneur en utilisateur **non-root**.

Documente clairement que le réseau reste ouvert (egress non verrouillé) si c'est
le cas.

## Transport git : token HTTPS et/ou deploy key SSH

Deux voies, toutes deux bornées au seul repo. Token et deploy key sont
**complémentaires**, pas interchangeables :

- **Token (HTTPS)** : le plus simple, zéro réglage SSH. `git` peut pousser via une URL
  HTTPS + credential helper, et c'est **de toute façon** ce dont `gh` et l'API ont
  besoin pour **créer les PR** — une deploy key ne le permet pas. Donc le token reste
  requis dès qu'on automatise les PR.
- **Deploy key (SSH)** : une paire de clés DÉDIÉE au repo (clé publique enregistrée
  comme *deploy key* avec accès en écriture, clé privée montée `:ro` dans le conteneur).
  Avantage : **agnostique de la plateforme** (GitHub, GitLab, Gitea, serveur maison).
  Le `remote origin` en `git@…` permet alors un `git push`/`pull` direct.

Mise en œuvre côté image/compose :
- étage dev : `openssh-client` ; pré-créer `~/.ssh` (700) pour le `known_hosts`.
- compose : monter la clé privée `:ro` avec un défaut NEUTRE pour ne pas casser
  `up` quand SSH n'est pas configuré — `source: ${DEPLOY_KEY:-/dev/null}` — et poser
  `GIT_SSH_COMMAND` (`-i <clé> -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new
  -o UserKnownHostsFile=<dans le HOME du conteneur>`).
- la clé privée vit côté HÔTE (jamais dans l'image), chemin absolu via `DEPLOY_KEY`
  dans `.env` ; `chmod 600`.

Pièges/limites à signaler :
- **Enregistrer la deploy key est manuel** : un token *fine-grained* sans permission
  `Administration` reçoit un `403` sur l'API des deploy keys → passage par l'interface.
  Cocher « Allow write access ».
- La notion « deploy key par repo » est **côté forge** (GitHub/GitLab/Gitea). Sur un
  serveur Git **nu** (compte `git` + `authorized_keys`), une clé donne accès à TOUS les
  dépôts → pour cloisonner, **gitolite** ou un forge auto-hébergé. Le transport SSH,
  lui, est identique partout (c'est ça qui est portable).
- Permissions : `git` refuse une clé trop ouverte → `chmod 600` ; sur hôte uid ≠ 1000,
  aligner UID/GID (cf. section suivante) pour que la clé montée appartienne au user
  du conteneur.

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
   dossiers `:ro` + clé SSH `:ro`), variables d'env. Sur un montage `:ro` optionnel
   dont la source vient d'une variable avec défaut (ex. `${SCREENSHOTS_DIR:-...}`),
   poser `bind: { create_host_path: false }` : sinon Compose crée en douce une
   source absente (dossier vide possédé par root). Alternative si le montage doit
   être vraiment facultatif : le sortir dans un `compose.override.yaml` opt-in.
   Côté variables d'env : le token, **`CLAUDE_CONFIG_DIR`** pointant sur le volume
   Claude (persistance, cf. § sécurité et pièges), et **`GIT_SSH_COMMAND`** pour la
   deploy key. Pour rendre SSH optionnel sans casser `up`, monter la clé avec un
   défaut neutre `source: ${DEPLOY_KEY:-/dev/null}` plutôt qu'un montage conditionnel.
3. **`.env.example`** : token fine-grained documenté (comment le générer, scope
   repo unique) + `DEPLOY_KEY` (chemin absolu de la clé privée de la deploy key,
   vide par défaut) + variables de chemin optionnelles. Expliquer le partage des
   rôles **token (API/PR/`gh`) vs deploy key (transport git seulement)** pour que le
   lecteur ne croie pas que SSH remplace le token. AVERTIR que Compose n'expanse PAS
   `$HOME`/`$PWD` dans `.env` (valeurs littérales → chemins absolus).
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
   convention de chemins, cas uid ≠ 1000, push/pull (token HTTPS et deploy key SSH,
   avec leur partage de rôles), persistance de l'état Claude (`CLAUDE_CONFIG_DIR` +
   migration unique), note Python/`pipx`, et le piège du « premier déploiement qui
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
- **Persistance Claude incomplète** : le volume sur `~/.claude` garde credentials et
  transcripts, MAIS `~/.claude.json` (login, onboarding, index des conversations) est
  à la racine du HOME, hors volume → ré-auth + historique « disparu » à chaque
  recréation. Corriger avec `CLAUDE_CONFIG_DIR=<chemin du volume>` (vérifié : Claude
  écrit alors `.claude.json` DANS le dossier pointé). En rétro-fit sur un conteneur
  existant, migration unique : `cp ~/.claude.json <volume>/.claude.json` avant la
  première recréation, sinon une dernière perte.
- Push SSH : `Permission denied (publickey)` = clé publique pas (encore) enregistrée
  comme deploy key, ou `DEPLOY_KEY` faux ; `not granted the required permissions` au
  push = « Allow write access » oublié sur la deploy key.
