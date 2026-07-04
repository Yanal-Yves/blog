# Image de build reproductible pour le blog "Notes Techniques".
#
# Deux étages :
#   - build : minimal, ne contient QUE Hugo (+ git pour enableGitInfo). Utilisé par la CI.
#   - dev   : ajoute Node, Claude Code, gh, Neovim, ssh, Python. Travail local.
#
# La CI n'a besoin que de Hugo : on lui sert l'étage "build", léger.
# Le dev veut ses outils : on lui sert l'étage "dev".
#
# Cible : linux/amd64.
ARG HUGO_VERSION=0.159.0
ARG NVIM_VERSION=0.10.2
ARG CLAUDE_CODE_VERSION=2.1.201

# --------------------------------------------------------------------------
# Étage build — image CI minimale (Hugo seul)
# --------------------------------------------------------------------------
FROM debian:bookworm-slim AS build
ARG HUGO_VERSION

# git est nécessaire à Hugo pour enableGitInfo (date de dernière màj).
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git \
    && curl -fsSL "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb" \
        -o /tmp/hugo.deb \
    && apt-get install -y --no-install-recommends /tmp/hugo.deb \
    && rm -rf /var/lib/apt/lists/* /tmp/hugo.deb

# Hugo (enableGitInfo) lit l'historique git pour la date de dernière màj. En CI,
# le dépôt monté n'appartient pas à l'utilisateur du conteneur → git refuse
# ("dubious ownership") et le build échoue. On déclare tout dépôt monté comme
# sûr (conteneur éphémère, sans risque).
RUN git config --system --add safe.directory '*'

# Pas de WORKDIR figé : la CI fixe elle-même le répertoire de travail via
# `-w "$HOME/_gh/Yanal-Yves/blog"` (cf. deploy.yml), suivant la même convention
# que l'hôte et le conteneur dev. La CI lance `hugo --minify`.

# --------------------------------------------------------------------------
# Étage dev — image locale complète (Hugo + Node + Claude + gh + Neovim)
# --------------------------------------------------------------------------
FROM node:22-bookworm-slim AS dev
ARG NVIM_VERSION
ARG CLAUDE_CODE_VERSION
# uid/gid de l'utilisateur du conteneur. Par défaut 1000 (= 1er utilisateur Linux
# courant, et géré par Docker Desktop sur macOS/Windows). Sur un hôte Linux dont
# l'uid ≠ 1000, construire avec `--build-arg UID=$(id -u) --build-arg GID=$(id -g)`
# (compose le fait via les variables UID/GID) pour que les fichiers du projet
# monté soient accessibles en écriture.
ARG UID=1000
ARG GID=1000

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        less \
        gnupg \
        openssh-client \
        python3 \
        python3-venv \
        pipx \
    && rm -rf /var/lib/apt/lists/*

# Même garde que l'étage build : le serveur Hugo (enableGitInfo) et les commandes
# git tournent ici en `node`. Sur un hôte Linux dont l'uid ≠ 1000, le dépôt monté
# n'appartient pas à `node` → git refuse ("dubious ownership"). On déclare le
# dépôt monté comme sûr pour préserver la portabilité multi-machines.
RUN git config --system --add safe.directory '*'

# Hugo : on réutilise le binaire exact de l'étage build (même version, garanti aligné).
COPY --from=build /usr/local/bin/hugo /usr/local/bin/hugo

# GitHub CLI (gh) depuis le dépôt officiel.
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

# Neovim, version épinglée (l'apt de bookworm est trop ancien pour apprendre).
RUN curl -fsSL "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux64.tar.gz" \
        -o /tmp/nvim.tar.gz \
    && tar -C /opt -xzf /tmp/nvim.tar.gz \
    && ln -s /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim \
    && rm /tmp/nvim.tar.gz

# Claude Code, version épinglée (comme Hugo et Neovim) : l'image est reproductible
# et on met à jour en la reconstruisant (bumper CLAUDE_CODE_VERSION), pas via
# l'auto-updater. Ce dernier est d'ailleurs coupé (DISABLE_AUTOUPDATER, cf.
# compose.yaml) : il échouerait de toute façon (paquet installé en root sous
# /usr/local, conteneur lancé en `node`) et toute màj runtime serait perdue à la
# recréation du conteneur.
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

# Aligne l'utilisateur `node` (uid/gid 1000 par défaut dans l'image node) sur
# l'uid/gid de l'hôte. On pré-crée ~/.claude pour que le volume nommé qui s'y
# monte hérite du bon propriétaire à sa création. On pré-crée aussi ~/.ssh (700)
# pour que ssh y écrive son known_hosts (transport git en SSH, optionnel — voir
# CONTAINER.md). La clé privée, elle, n'est jamais dans l'image : elle est
# montée en lecture seule au runtime via compose (deploy key dédiée).
# Robustesse : si le gid existe déjà dans l'image (ex. 100 'users'), on réutilise
# ce groupe au lieu de le recréer ; `-o` autorise un uid déjà pris (collision
# avec un utilisateur système). Sans ça, le build casserait pour ces hôtes.
RUN mkdir -p /home/node/.claude /home/node/.ssh \
    && chmod 700 /home/node/.ssh \
    && if ! getent group "$GID" >/dev/null; then groupmod -g "$GID" node; fi \
    && usermod -o -u "$UID" -g "$GID" node \
    && chown -R "$UID:$GID" /home/node

# Outils installés par l'utilisateur (pipx pose ses exécutables ici) accessibles
# sans `pipx ensurepath`.
ENV PATH=/home/node/.local/bin:$PATH

# On tourne en utilisateur non-root (aligné sur l'hôte via UID/GID ci-dessus).
USER node
# Convention de chemin : projet sous le home du conteneur (`node`), suffixé par
# `_gh/<org>/<repo>`. `node` est un user de conteneur générique → aucun chemin
# perso de l'hôte ici. compose.yaml impose le même `working_dir` ; ce WORKDIR ne
# sert que de repli si l'image est lancée sans compose (alors sans montage).
WORKDIR /home/node/_gh/Yanal-Yves/blog

EXPOSE 1313

# Par défaut : serveur de dev Hugo accessible depuis l'hôte.
# Pour un shell (claude, neovim, gh) : `docker compose exec dev bash`.
CMD ["hugo", "server", "--bind", "0.0.0.0", "--baseURL", "http://localhost:1313/"]
