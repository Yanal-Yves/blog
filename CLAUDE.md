# Instructions pour Claude Code

## Hugo / Mermaid

- **Sauts de ligne dans Mermaid** : Utiliser `<br/>` pour les sauts de ligne dans les diagrammes Mermaid, **jamais** `\n`. Hugo affiche les `\n` littéralement au lieu de les interpréter comme des sauts de ligne.
- **Pas de numéros dans les labels Mermaid** : Éviter les préfixes numérotés comme "1. " dans les labels de nœuds Mermaid. Le parseur Markdown de Mermaid les interprète comme des listes ordonnées (erreur "Unsupported markdown: list").

## Structure du projet

- Générateur de site statique : Hugo
- Thème : hugo-book
- Langue : Français
- Contenu dans `content/` avec frontmatter YAML
- HTML non sécurisé autorisé dans le rendu goldmark (`unsafe = true`)
