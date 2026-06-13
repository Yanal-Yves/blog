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

Le conteneur isole le **disque** (seul le projet est monté, jamais `$HOME`,
`~/.ssh`, etc.). Mais l'isolation GitHub vient du **token**, pas du conteneur :

1. **Token fine-grained limité au seul repo `Yanal-Yves/blog`** — voir `.env.example`.
   Sans ça, un token large laisserait Claude atteindre *tous* tes repos.
2. On ne monte que le projet (voir `compose.yaml`).
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
identique au tien.

> **Premier setup** : lance une fois le workflow *Build & push images*
> manuellement (onglet Actions → *Run workflow*) pour publier les images avant le
> premier déploiement.

## Bumper Hugo (ou Neovim)

Modifie `ARG HUGO_VERSION` dans le `Dockerfile`, commit : l'image se reconstruit
et la CI suit automatiquement. Local et CI restent alignés.
