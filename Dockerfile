# Image de build reproductible pour le blog "Notes Techniques".
#
# Deux étages :
#   - build : minimal, ne contient QUE Hugo (+ git pour enableGitInfo). Utilisé par la CI.
#   - dev   : ajoute Node, Claude Code, gh, Neovim. Utilisé pour le travail local.
#
# La CI n'a besoin que de Hugo : on lui sert l'étage "build", léger.
# Le dev veut ses outils : on lui sert l'étage "dev".
#
# Cible : linux/amd64.
ARG HUGO_VERSION=0.159.0
ARG NVIM_VERSION=0.10.2

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
# le conteneur tourne en root sur un dépôt possédé par le runner → git refuse
# ("dubious ownership") et le build échoue. On déclare le workspace comme sûr
# pour tout utilisateur (conteneur éphémère, sans risque).
RUN git config --system --add safe.directory '*'

WORKDIR /workspace
# La CI lance `hugo --minify` ; pas de CMD spécifique requis ici.

# --------------------------------------------------------------------------
# Étage dev — image locale complète (Hugo + Node + Claude + gh + Neovim)
# --------------------------------------------------------------------------
FROM node:22-bookworm-slim AS dev
ARG NVIM_VERSION

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        less \
        gnupg \
    && rm -rf /var/lib/apt/lists/*

# Même garde que l'étage build : le serveur Hugo (enableGitInfo) et les commandes
# git tournent ici en `node`. Sur un hôte Linux dont l'uid ≠ 1000, le dépôt monté
# n'appartient pas à `node` → git refuse ("dubious ownership"). On déclare le
# workspace comme sûr pour préserver la portabilité multi-machines.
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

# Claude Code.
RUN npm install -g @anthropic-ai/claude-code

# On tourne en utilisateur non-root (l'image node fournit déjà l'utilisateur "node", uid 1000).
USER node
WORKDIR /workspace

EXPOSE 1313

# Par défaut : serveur de dev Hugo accessible depuis l'hôte.
# Pour un shell (claude, neovim, gh) : `docker compose exec dev bash`.
CMD ["hugo", "server", "--bind", "0.0.0.0", "--baseURL", "http://localhost:1313/"]
