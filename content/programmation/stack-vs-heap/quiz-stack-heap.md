---
title: "Quiz : Pile et Tas"
draft: false
tags: ["programmation", "mémoire", "débutant", "csharp", "dotnet"]
categories: ["Développement", "Théorie"]
---

## 📝 Testez vos connaissances

Avez-vous bien saisi la nuance ? C'est le moment de vérité. Cliquez sur "Voir la réponse" pour vérifier votre compréhension.

### Question 1
**Quelle est la caractéristique principale de la Pile (Stack) comparée au Tas (Heap) en termes de performance ?**

* A) Elle est plus lente mais permet de stocker plus de données.
* B) Elle est beaucoup plus rapide d'accès et d'allocation.
* C) Il n'y a aucune différence de performance.
* D) Elle est optimisée pour les objets volumineux uniquement.

<details>
<summary>🔻 Voir la réponse</summary>
<blockquote>
<strong>Réponse B : Elle est beaucoup plus rapide.</strong><br>
L'allocation sur la Pile est immédiate (déplacement d'un pointeur CPU), tandis que le Tas nécessite de chercher un espace libre et de le gérer plus tard via le Garbage Collector.
</blockquote>
</details>

---

### Question 2
**En C#, où est stockée la valeur d'une variable locale de type `int` (par exemple `int age = 25;`) ?**

* A) Sur le Tas (Heap).
* B) Dans la base de registre du processeur uniquement.
* C) Sur la Pile (Stack).
* D) Une partie sur la Pile et une partie sur le Tas.

<details>
<summary>🔻 Voir la réponse</summary>
<blockquote>
<strong>Réponse C : Sur la Pile (Stack).</strong><br>
C'est un Type Valeur (Value Type). Il vit directement dans le cadre d'exécution de la méthode sur la Pile. Il n'a pas besoin de l'entrepôt géant pour exister.
</blockquote>
</details>

---

### Question 3
**Lorsque vous instanciez une classe (ex: `var user = new User();`), que contient la variable `user` située sur la Pile ?**

* A) L'objet entier avec toutes ses données.
* B) Une copie de l'objet.
* C) Rien, la variable est vide tant qu'on ne l'utilise pas.
* D) L'adresse mémoire (référence) pointant vers l'objet dans le Tas.

<details>
<summary>🔻 Voir la réponse</summary>
<blockquote>
<strong>Réponse D : L'adresse mémoire (référence).</strong><br>
La variable sur la Pile agit comme un "pointeur" ou une télécommande. L'objet réel (les données) est stocké dans le Tas.
</blockquote>
</details>

---

### Question 4
**Si vous déclarez `int? score = null;`, où cette variable est-elle stockée ?**

* A) Uniquement sur le Tas (Heap) car elle est null.
* B) Uniquement sur la Pile (Stack).
* C) Elle n'est pas stockée en mémoire car elle n'existe pas.
* D) C'est une référence vide pointant vers le Tas.

<details>
<summary>🔻 Voir la réponse</summary>
<blockquote>
<strong>Réponse B : Uniquement sur la Pile (Stack).</strong><br>
C'est le piège classique ! Un `Nullable<int>` reste une struct (Type Valeur). Elle occupe de l'espace sur la Pile pour stocker un booléen (HasValue=false) et la valeur par défaut.
</blockquote>
</details>

---

### Question 5
**Qui est responsable du nettoyage de la mémoire dans le Tas (Heap) en C# ?**

* A) Le système d'exploitation à la fin du programme.
* B) Le développeur, manuellement.
* C) La méthode, dès qu'elle se termine.
* D) Le Garbage Collector (Ramasse-miettes).

<details>
<summary>🔻 Voir la réponse</summary>
<blockquote>
<strong>Réponse D : Le Garbage Collector.</strong><br>
C'est un processus automatique qui passe régulièrement pour identifier et libérer la mémoire des objets du Tas qui ne sont plus référencés par personne.
</blockquote>
</details>

---

### Question 6
**Que se passe-t-il si vous copiez une variable de type classe (`User u2 = u1;`) et que vous modifiez ensuite `u2` ?**

* A) Cela modifie également l'objet pointé par `u1`.
* B) Cela ne modifie pas `u1` car une copie indépendante a été créée.
* C) Cela provoque une erreur de compilation.
* D) L'objet original est supprimé et remplacé.

<details>
<summary>🔻 Voir la réponse</summary>
<blockquote>
<strong>Réponse A : Cela modifie également `u1`.</strong><br>
Comme vous avez copié l'adresse (la référence), les deux variables pointent vers le EXACTEMENT le même objet en mémoire. Si vous changez la tapisserie de la maison via l'adresse 1, elle change aussi pour celui qui a l'adresse 2.
</blockquote>
</details>

---

### Question 7
**Qu'est-ce qu'une `StackOverflowException` ?**

* A) Quand le Tas (Heap) est plein à cause d'objets trop gros.
* B) Quand on essaie d'accéder à une variable null.
* C) Quand la Pile est saturée, souvent par des appels de méthodes récursifs infinis.
* D) Quand le Garbage Collector ne peut plus fonctionner.

<details>
<summary>🔻 Voir la réponse</summary>
<blockquote>
<strong>Réponse C : Saturation de la Pile.</strong><br>
L'espace de la Pile est limité. Si on empile trop d'appels de méthodes sans jamais dépiler (récursion infinie), ça déborde.
</blockquote>
</details>

---

### Question 8
**Quelle affirmation est vraie concernant `string?` (Nullable Reference Type) en C# récent ?**

* A) Cela ajoute un booléen en mémoire pour indiquer si la chaîne est null.
* B) Cela déplace la chaîne de caractères sur la Pile.
* C) C'est uniquement une indication pour le compilateur, en mémoire c'est identique à `string`.
* D) Cela permet de stocker la chaîne sans utiliser le Garbage Collector.

<details>
<summary>🔻 Voir la réponse</summary>
<blockquote>
<strong>Réponse C : C'est une aide au compilateur.</strong><br>
En mémoire, c'est toujours juste une référence (adresse). Le `?` sert uniquement à avertir le développeur lors de la compilation qu'il doit vérifier les nulls, mais cela ne change pas la structure binaire.
</blockquote>
</details>

---

### Question 9
**Pourquoi préfère-t-on parfois utiliser une `struct` plutôt qu'une `class` pour de petits objets de données ?**

* A) Pour bénéficier de l'héritage.
* B) Pour éviter la pression sur le Garbage Collector en restant sur la Pile.
* C) Pour pouvoir les mettre à null facilement.
* D) Parce que les structs ont une taille illimitée.

<details>
<summary>🔻 Voir la réponse</summary>
<blockquote>
<strong>Réponse B : Éviter la pression sur le GC.</strong><br>
Si la struct est utilisée comme variable locale, elle est allouée/désallouée instantanément sur la Pile ("gratuitement"). Cela évite de donner du travail au Ramasse-miettes dans le Tas.
</blockquote>
</details>

---

### Question 10
**Dans le cas `User u = null;`, que contient physiquement la variable `u` sur la Pile ?**

* A) Absolument rien (vide).
* B) Un objet vide caché.
* C) Une exception.
* D) Une adresse spéciale (généralement tous les bits à 0).

<details>
<summary>🔻 Voir la réponse</summary>
<blockquote>
<strong>Réponse D : Une adresse spéciale (0x000000).</strong><br>
En informatique, "rien" n'existe pas. La référence null est concrètement une adresse valant zéro, indiquant "je ne pointe nulle part".
</blockquote>
</details>
