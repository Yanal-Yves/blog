# 📚 Notes Techniques - Yanal-Yves

Ce dépôt contient le code source et le contenu de mon site personnel de documentation technique. Le site est généré statiquement et hébergé sur GitHub Pages.

🔗 **URL du site :** [https://yanal.fargialla.com](https://yanal.fargialla.com)

## 🛠 Architecture Technique

Ce projet est construit sur la **Jamstack** avec les technologies suivantes :

* **Générateur :** [Hugo](https://gohugo.io/) (Framework statique rapide écrit en Go).
* **Thème :** [Hugo Book](https://github.com/alex-shpak/hugo-book) (Thème orienté documentation).
* **Hébergement :** GitHub Pages.
* **Déploiement (CI/CD) :** GitHub Actions (Compilation et publication automatique).
* **Gestion DNS :** Scaleway.

## 🚀 Installation et Lancement Local

L'environnement de dev tourne dans un **conteneur Docker**, qui fige la même version
de Hugo partout (poste perso, poste de travail, CI) et embarque aussi Claude Code et
Neovim. Plus d'écart de version d'une machine à l'autre.

> 📘 **Détails complets dans [`CONTAINER.md`](./CONTAINER.md)** : modèle de sécurité,
> token GitHub scopé, connexion d'un éditeur (VSCode/JetBrains), publication de
> l'image et CI.

### 1. Prérequis
* [Git](https://git-scm.com/)
* [Docker](https://docs.docker.com/engine/install/) (avec `docker compose`)

### 2. Cloner le dépôt et le thème
```bash
git clone https://github.com/Yanal-Yves/blog.git
cd blog
git submodule update --init --recursive   # récupère le thème (sous-module)
```

### 3. Construire l'image et lancer le serveur
```bash
cp .env.example .env        # y coller un token GitHub fine-grained (facultatif si pas de push)
docker compose build        # construit l'image (1re fois seulement)
docker compose up dev       # serveur Hugo live-reload
```
Le site sera accessible à l'adresse : `http://localhost:1313/`

### 4. Travailler dans le conteneur
```bash
docker compose exec dev bash   # shell avec claude, nvim, gh, git
```

**Ce qu'il faut savoir :**
* L'image (`Dockerfile`) embarque **Hugo extended (version épinglée) + Node + Claude
  Code + `git`/`gh` + Neovim**, en utilisateur non-root. La même image sert en CI.
* **Bac à sable** : seul le projet est monté dans le conteneur (jamais `$HOME`,
  `~/.ssh`…), et le socket Docker n'est **jamais** monté. Les dégâts qu'un agent
  (Claude) peut faire restent bornés à ce projet et à ce dépôt.
* **Périmètre GitHub** : c'est le **token *fine-grained* limité au seul dépôt du blog**
  (`.env`, voir `.env.example`) qui borne les actions GitHub — pas le conteneur.

## 📝 Rédaction de contenu

### Structure des dossiers
Les articles se trouvent dans le dossier `content/`.
* `content/antispoofing-e-mail/` : Série sur les techniques d'anti usurpation d'e-mail.
* `content/recalbox/` : (À venir) Notes sur le retrogaming.

### Créer un nouvel article
Créez un fichier `.md` dans la catégorie souhaitée. Chaque fichier doit commencer par un entête (Front Matter) :

```markdown
---
title: "Titre de l'article"
date: 2025-12-21
weight: 10
---

Votre contenu en Markdown ici...
```
*Note : La date de dernière mise à jour affichée en bas de page est gérée automatiquement via l'historique Git (cf. `enableGitInfo` dans `hugo.toml`).*

## 🤖 Transparence et Licence

### Note sur l'Intelligence Artificielle
Dans un souci de transparence, les articles de ce blog peuvent être assistés par l'IA (Google Gemini, Claude, etc...) pour la structuration et la synthèse technique. Chaque contenu est systématiquement vérifié, corrigé et validé par l'auteur.

Une mention automatique est ajoutée au bas de chaque page via le fichier `layouts/partials/docs/inject/content-after.html`.

### Licence
Le contenu de ce site est mis à disposition selon les termes de la **Licence Creative Commons Attribution - Partage dans les Mêmes Conditions 4.0 International (CC BY-SA 4.0)**.

---
**Auteur :** Yanal-Yves FARGIALLA