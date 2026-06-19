# Environnement conteneurisé

Environnement de dev reproductible et isolé pour ce blog. Même version de Hugo
sur n'importe quelle machine (Linux, macOS, Windows) et en CI, et **Claude tourne
dans le conteneur** : on peut lui donner de larges droits, les dégâts restent
bornés à ce projet et à ce repo.

## Deux images (Dockerfile multi-stage)

Le `Dockerfile` a deux étages, pour séparer ce dont la CI a besoin de ce dont le
dev a besoin :

| Image | Étage | Contenu | Usage |
|-------|-------|---------|-------|
| `blog-ci`  | `build` | Hugo extended seul (+ git) | déploiement / CI — léger |
| `blog-dev` | `dev`   | Hugo + Node + **Claude Code** + `git`/`gh` + **neovim** | travail local |

Les deux tournent en utilisateur non-root (`node` pour l'étage dev). Hugo est figé
à la même version dans les deux (le binaire de `blog-dev` est copié depuis `blog-ci`).

## Modèle de sécurité

Le conteneur isole le **disque** (on ne monte que le projet — en lecture/écriture
— et le dossier des captures d'écran — en **lecture seule** ; jamais `$HOME`,
`~/.ssh`, etc.). Mais l'isolation GitHub vient du **token**, pas du conteneur :

1. **Token fine-grained limité au seul repo `Yanal-Yves/blog`** — voir `.env.example`.
   Sans ça, un token large laisserait Claude atteindre *tous* tes repos.
2. On ne monte que le projet et les captures d'écran (voir `compose.yaml`).
3. On ne monte **jamais** le socket Docker (= évasion triviale).
4. Config Claude isolée dans un volume dédié, séparée de ton `~/.claude` de l'hôte.

> Le réseau reste ouvert (Claude peut accéder à Internet). Pour un blog c'est
> acceptable ; un verrouillage d'egress serait possible mais hors périmètre ici.

## Mise en route

Prérequis : **Docker** (avec `docker compose`) — Linux, macOS ou Windows.

```bash
# 1. Token GitHub scopé
cp .env.example .env        # puis colle ton token fine-grained dans .env

# 2. Thème (sous-module) si themes/ est vide
git submodule update --init --recursive

# 3. Construire l'image
docker compose build
```

> **Hôte Linux dont l'uid ≠ 1000** (vérifie avec `id -u`) : aligne l'utilisateur
> du conteneur sur le tien pour pouvoir écrire dans le projet monté, et **construis**
> l'image au lieu de la tirer (l'image publiée est en uid 1000) :
> ```bash
> printf 'UID=%s\nGID=%s\n' "$(id -u)" "$(id -g)" >> .env   # compose lit .env
> docker compose build                                       # ne fais PAS `docker compose pull`
> ```
> Sur uid 1000, macOS et Windows : rien à faire, les valeurs par défaut conviennent.
>
> Si tu **changes l'uid après avoir déjà lancé le conteneur**, le volume Claude
> garde son ancien propriétaire (Docker ne le réinitialise pas) → Claude ne peut
> plus y écrire. Recrée-le : `docker volume rm blog_claude-config`.

## Chemins de montage : projet et captures d'écran

### Projet : convention `<home>/_gh/<org>/<repo>`

Le projet vit sous le **home de chaque environnement**, suffixé par
`_gh/<github-org>/<repo>`. Cette convention scale à plusieurs dépôts sans
collision (contrairement à un `/workspace` unique) et calque l'organisation de
GitHub :

| Environnement | Chemin du projet |
|---|---|
| Hôte | `~/_gh/Yanal-Yves/blog` (= `/home/<toi>/_gh/Yanal-Yves/blog`) |
| Conteneur **dev** | `/home/node/_gh/Yanal-Yves/blog` (`node` = user du conteneur) |
| **CI** (runner) | `$HOME/_gh/Yanal-Yves/blog` (= `/home/runner/_gh/Yanal-Yves/blog`) |

Rien à configurer : `compose.yaml` fixe la cible du montage à
`/home/node/_gh/Yanal-Yves/blog` (et VSCode Dev Containers ouvre ce même chemin).
`node` est un utilisateur de conteneur **générique** : aucun chemin personnel de
l'hôte n'est inscrit dans les fichiers versionnés. Lance simplement
`docker compose up dev` depuis la racine du dépôt.

### Captures d'écran visibles par Claude (`SCREENSHOTS_DIR`)

Le dossier des captures de l'hôte est monté **en lecture seule** (`:ro`) au même
chemin que sur l'hôte → Claude peut *voir* tes captures, jamais les modifier.
(C'est le seul montage qui suit encore le modèle « même chemin dedans/dehors » :
tu colles à Claude des chemins absolus de captures, ils doivent donc exister à
l'identique dans le conteneur.) Ce montage se règle dans `.env` ; **Compose
n'expanse pas `$HOME`/`$PWD` dans `.env`** (valeurs littérales) : laisse
`SCREENSHOTS_DIR` vide pour le défaut calculé dans `compose.yaml`, ou mets un
chemin **absolu** complet.

Par défaut compose prend `~/Pictures/Screenshots` (emplacement KDE/Spectacle en
**anglais**). En **français** c'est `~/Images/Copies d'écran` : il faut alors
renseigner `SCREENSHOTS_DIR`. Le plus robuste — **indépendant de la locale** —
combine le dossier Images localisé (`xdg-user-dir PICTURES`) et le nom de
sous-dossier que Spectacle a lui-même localisé (clé `[ImageSave]
translatedScreenshotsFolder`, p. ex. `Copies d'écran`), avec repli `Screenshots` :

```bash
PICT="$(xdg-user-dir PICTURES)"
SUB="$(kreadconfig6 --file spectaclerc --group ImageSave --key translatedScreenshotsFolder 2>/dev/null \
     || kreadconfig5 --file spectaclerc --group ImageSave --key translatedScreenshotsFolder 2>/dev/null)"
echo "SCREENSHOTS_DIR=$PICT/${SUB:-Screenshots}" >> .env
```

> Le montage source = cible : si le dossier n'existe pas encore côté hôte, Docker
> le crée (vide, possédé par root). Vérifie donc que `SCREENSHOTS_DIR` pointe bien
> sur ton dossier réel. Après modif de `.env`, relance `docker compose up dev`.

## Au quotidien

```bash
# Serveur Hugo live-reload → http://localhost:1313
docker compose up dev

# Dans un autre terminal : shell DANS le conteneur (claude, nvim, gh, git)
docker compose exec dev bash
```

Dans le shell du conteneur :

```bash
gh auth setup-git     # une fois : git utilise le token pour push
claude                 # tu te connectes ici ; donne-lui les droits que tu veux
nvim .
```

## Éditeurs graphiques (PHPStorm, Rider, VSCode)

Ils restent **sur l'hôte** et se connectent *dans* le conteneur :

- **VSCode** : extension *Dev Containers* → « Reopen in Container » (utilise
  `.devcontainer/devcontainer.json`).
- **JetBrains** : Gateway / remote dev sur le conteneur.

Inutile d'installer une GUI dans le conteneur. neovim, lui, vit dans le
conteneur (terminal) — pratique pour t'y mettre progressivement.

## Images partagées (ghcr.io) & CI

Le workflow `.github/workflows/image.yml` publie les **deux** images
(`ghcr.io/yanal-yves/blog-ci` et `ghcr.io/yanal-yves/blog-dev`) au changement du
`Dockerfile`, ou manuellement via *Run workflow*. Récupérer l'image de dev
ailleurs sans reconstruire :

```bash
docker compose pull
```

Le déploiement (`.github/workflows/deploy.yml`) construit le site **dans l'image
`blog-ci`** (légère, Hugo seul) → le `hugo --minify` de la CI est strictement
identique au tien. Il se déclenche sur les push de contenu, et **après**
`image.yml` lorsque le `Dockerfile` change (`workflow_run`), pour toujours bâtir
avec l'image fraîchement publiée.

> **Au premier merge** : `image.yml` se déclenche tout seul (le `Dockerfile` est
> ajouté) et publie les images. En parallèle, ce tout premier déploiement
> **échoue** — c'est attendu : l'image `blog-ci` n'est pas encore sur ghcr. Il se
> relance et réussit automatiquement via `workflow_run` dès qu'`image.yml` a fini
> (ou relance-le à la main). Le bouton *Run workflow* n'apparaît qu'une fois le
> workflow présent sur `main`, donc on ne peut pas l'amorcer avant le merge.

## Bumper Hugo (ou Neovim)

Modifie `ARG HUGO_VERSION` dans le `Dockerfile`, commit : l'image se reconstruit
et la CI suit automatiquement. Local et CI restent alignés.

> Conseil : commit un bump de `Dockerfile` **seul** (sans changement de contenu).
> Un commit mixte (contenu + Dockerfile) déclenche un déploiement immédiat qui
> tire l'ancienne image avant qu'`image.yml` ait publié la nouvelle ; le
> déploiement suivant (via `workflow_run`) corrige, mais évite-toi ce transitoire.
