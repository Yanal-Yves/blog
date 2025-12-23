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

Pour rédiger des articles et visualiser le rendu sur votre machine avant de publier :

### 1. Prérequis
* [Git](https://git-scm.com/)
* [Hugo](https://gohugo.io/installation/)

### 2. Cloner le dépôt
```bash
git clone [https://github.com/Yanal-Yves/blog.git](https://github.com/Yanal-Yves/blog.git)
cd blog
```

### 3. Initialiser le thème (Submodule)
Si le dossier `themes` est vide, lancez :
```bash
git submodule update --init --recursive
```

### 4. Lancer le serveur de développement
```bash
hugo server
```
Le site sera accessible à l'adresse : `http://localhost:1313/`

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
Dans un souci de transparence, les articles de ce blog peuvent être assistés par l'IA (Google Gemini) pour la structuration et la synthèse technique. Chaque contenu est systématiquement vérifié, corrigé et validé par l'auteur.

Une mention automatique est ajoutée au bas de chaque page via le fichier `layouts/partials/docs/inject/content-after.html`.

### Licence
Le contenu de ce site est mis à disposition selon les termes de la **Licence Creative Commons Attribution - Partage dans les Mêmes Conditions 4.0 International (CC BY-SA 4.0)**.

---
**Auteur :** Yanal-Yves FARGIALLA