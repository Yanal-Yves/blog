---
title: "Quiz : Polymorphisme"
description: "Quiz interactif sur le polymorphisme en C# : testez votre compréhension des Vtables, de la liaison statique/dynamique et des mots-clés virtual, override et new."
draft: false
---

## 📝 Testez vos connaissances

Avez-vous bien saisi la mécanique interne du polymorphisme et des Vtables ? C'est le moment de vérifier si vous maîtrisez la différence entre liaison statique et dynamique. Cliquez sur "Voir la réponse" pour valider.

### Question 1
**Dans le code `Animal a = new Chien();`, si l'on appelle `a.DitBonjour()` (méthode non virtuelle), quelle version de la méthode est exécutée ?**

* A) Celle de la classe `Chien` car l'objet est un Chien.
* B) Celle de la classe `Animal` car la variable est de type Animal.
* C) Aucune, cela provoque une erreur de compilation.
* D) Celle du `Chien` uniquement si elle utilise le mot clé `override`.

<details>
<summary>🔻 Voir la réponse</summary>
<blockquote>
<strong>Réponse B : Celle de la classe `Animal`.</strong><br>
La méthode n'étant pas virtuelle, le compilateur utilise la liaison statique. Il se base uniquement sur le type de la <strong>variable</strong> (`Animal`) et grave dans le marbre l'appel à `Animal.DitBonjour` dès la compilation.
</blockquote>
</details>

---

### Question 2
**Quel mot-clé C# permet d'activer la liaison dynamique (appel via Vtable) dans la classe de base ?**

* A) `static`
* B) `override`
* C) `virtual`
* D) `new`

<details>
<summary>🔻 Voir la réponse</summary>
<blockquote>
<strong>Réponse C : `virtual`.</strong><br>
C'est ce mot-clé qui signale au compilateur qu'il ne doit pas figer l'adresse de la méthode, mais mettre en place un mécanisme de résolution dynamique (lookup) pour l'exécution.
</blockquote>
</details>

---

### Question 3
**Qu'est-ce qu'une Vtable (Virtual Method Table) concrètement ?**

* A) Une base de données SQL stockant les objets.
* B) Un tableau de pointeurs vers les adresses mémoire des méthodes.
* C) Une liste des variables locales de la méthode.
* D) Un espace mémoire réservé sur la Pile (Stack).

<details>
<summary>🔻 Voir la réponse</summary>
<blockquote>
<strong>Réponse B : Un tableau de pointeurs.</strong><br>
C'est une structure dans les métadonnées de la classe (MethodTable) qui associe chaque méthode virtuelle à l'adresse mémoire réelle du code à exécuter.
</blockquote>
</details>

---

### Question 4
**Quand l'adresse de destination d'un appel de méthode "statique" (non virtuelle) est-elle déterminée ?**

* A) Au moment de l'instanciation de l'objet (`new`).
* B) À l'exécution (Runtime), juste avant l'appel.
* C) À la compilation.
* D) Lors du passage du Garbage Collector.

<details>
<summary>🔻 Voir la réponse</summary>
<blockquote>
<strong>Réponse C : À la compilation.</strong><br>
Le compilateur connaît le type de la variable. Il génère donc une instruction de saut direct vers l'adresse de la méthode correspondante, sans avoir besoin de vérifier ce qui se passe en mémoire.
</blockquote>
</details>

---

### Question 5
**Comment le Runtime trouve-t-il la Vtable correspondant à un objet lors de l'exécution ?**

* A) Il cherche le nom de la classe dans un fichier XML.
* B) Il analyse le code source original.
* C) Il consulte le TypeHandle situé dans l'en-tête (Header) de l'objet dans le Tas.
* D) Il demande au compilateur via une exception.

<details>
<summary>🔻 Voir la réponse</summary>
<blockquote>
<strong>Réponse C : Via l'en-tête de l'objet (TypeHandle).</strong><br>
Chaque objet dans le Tas possède un en-tête invisible qui pointe vers sa "carte d'identité" (MethodTable), laquelle contient la Vtable. C'est ainsi que le Runtime sait qu'il a affaire à un `Chien` et non un `Animal`.
</blockquote>
</details>

---

### Question 6
**Si la classe `Chat` définit `public new void DitBonjour()`, que se passe-t-il au niveau de la Vtable héritée de `Animal` ?**

* A) L'adresse de `Animal.DitBonjour` est remplacée par celle de `Chat.DitBonjour`.
* B) Une erreur critique se produit.
* C) Rien, la méthode `Chat.DitBonjour` est ignorée dans le slot de `Animal`.
* D) La Vtable est supprimée pour optimiser la mémoire.

<details>
<summary>🔻 Voir la réponse</summary>
<blockquote>
<strong>Réponse C : Rien, la méthode est ignorée dans le slot parent.</strong><br>
Le mot-clé `new` (masquage) n'utilise pas le mécanisme de la Vtable pour surcharger le parent. L'adresse dans le slot de la Vtable reste celle de `Animal`. La méthode `Chat.DitBonjour` existe "à côté" mais n'est pas accessible via une référence `Animal`.
</blockquote>
</details>

---

### Question 7
**Que signifie le terme "Indirection" dans le contexte d'un appel virtuel ?**

* A) Que le code est mal écrit.
* B) Que le processeur doit faire un détour par la Vtable pour trouver l'adresse du code.
* C) Que la méthode est appelée récursivement.
* D) Que l'objet est stocké sur le disque dur.

<details>
<summary>🔻 Voir la réponse</summary>
<blockquote>
<strong>Réponse B : Le détour par la Vtable.</strong><br>
Au lieu de sauter directement au code (appel direct), le processeur doit d'abord lire une adresse mémoire dans un tableau (la Vtable), puis sauter à cette adresse. Cette étape supplémentaire est l'indirection.
</blockquote>
</details>

---

### Question 8
**Dans le schéma fourni, pourquoi la flèche rouge (appel statique) contourne-t-elle la Vtable ?**

* A) Parce que c'est un bug du schéma.
* B) Parce que l'appel statique est plus lent.
* C) Parce que le compilateur a déjà câblé l'adresse `@Addr_A` (Animal) en dur.
* D) Parce que la méthode `DitBonjour` n'existe pas chez le Chien.

<details>
<summary>🔻 Voir la réponse</summary>
<blockquote>
<strong>Réponse C : L'adresse est câblée en dur.</strong><br>
L'appel statique ignore totalement l'instance réelle et sa Vtable. Il va tout droit vers le code défini par le type de la variable.
</blockquote>
</details>

---

### Question 9
**Quelle est la condition pour que le slot d'une méthode dans la Vtable soit mis à jour avec l'adresse de la méthode de l'enfant ?**

* A) L'enfant doit utiliser le mot-clé `override`.
* B) L'enfant doit utiliser le mot-clé `new`.
* C) La méthode doit être `private`.
* D) L'enfant ne doit pas avoir de constructeur.

<details>
<summary>🔻 Voir la réponse</summary>
<blockquote>
<strong>Réponse A : Utiliser `override`.</strong><br>
C'est l'`override` qui instruit le système de remplacer l'adresse de la méthode parente par celle de l'enfant à l'intérieur du slot correspondant dans la Vtable.
</blockquote>
</details>

---

### Question 10
**Pourquoi dit-on que l'appel virtuel (polymorphique) est plus "flexible" ?**

* A) Parce qu'il permet de changer le code source sans recompiler.
* B) Parce qu'il s'adapte au type réel de l'objet à l'exécution, quel qu'il soit.
* C) Parce qu'il utilise moins de mémoire.
* D) Parce qu'il permet d'éviter l'utilisation de classes.

<details>
<summary>🔻 Voir la réponse</summary>
<blockquote>
<strong>Réponse B : Il s'adapte au type réel de l'objet.</strong><br>
Peu importe que la variable soit de type `Animal`, si l'objet est un `Chat`, c'est le comportement du `Chat` qui sera déclenché grâce à la résolution dynamique.
</blockquote>
</details>
