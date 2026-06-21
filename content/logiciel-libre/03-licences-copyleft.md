---
title: "Les licences copyleft : la liberté qu'on ne peut pas reprendre"
description: "Les licences copyleft (GPL, LGPL, AGPL) en regard des permissives : comment le copyleft cherche à rendre la liberté de l'utilisateur inaliénable, ce qu'est la tivoïsation, et pourquoi elle a fait naître la GPLv3."
weight: 3
---

{{< toc >}}

Le [premier volet de cette série](../02-licences-permissives-freebsd/) explorait les licences **permissives** (BSD, MIT, Apache) à travers FreeBSD : elles laissent chacun libre de faire ce qu'il veut du code, **y compris le refermer**. Voici leur pendant : les licences **copyleft**.

La différence tient en une idée. Là où le permissif autorise à refermer, le **copyleft impose que toute version redistribuée reste libre**, code source compris. La plus connue est la [GPL](https://www.gnu.org/licenses/gpl-3.0.html), avec ses variantes [LGPL](https://www.gnu.org/licenses/lgpl-3.0.html) et [AGPL](https://www.gnu.org/licenses/agpl-3.0.html). Son but n'est pas seulement de partager du code : c'est de faire en sorte que la liberté **ne puisse pas être reprise** à l'utilisateur en aval.

Cet article reste une **pièce en cours** (la série s'écrit au fil de l'eau). Il **définit** d'abord le copyleft et son origine, retrace la **naissance de la GPL** — la première licence copyleft *généraliste* —, puis distingue la **famille** des licences GNU (GPL, LGPL, AGPL) et l'**évolution** qui a mené à la GPLv3, dont le cas le plus emblématique : la **tivoïsation**. Une conclusion commune aux deux volets referme l'ensemble.

## Qu'est-ce que le copyleft ?

Le copyleft est un **retournement du droit d'auteur**. Plutôt que de renoncer à ses droits (comme un versement au domaine public) ou de s'en servir pour interdire (comme le privateur), l'auteur les utilise pour **garantir** une chose : toute version redistribuée — y compris modifiée — doit rester sous les **mêmes conditions libres**, code source compris. La liberté devient ainsi **transitive**, obligée de « ruisseler » jusqu'au dernier maillon ; personne ne peut la refermer en aval. C'est l'exact contraire des licences permissives, qui autorisent justement à refermer.

Le **mot** lui-même est un jeu de mots, plus ancien que la GPL : on le trouve dès **1976** dans la notice de distribution du *Palo Alto Tiny BASIC* de Li-Chen Wang — « **@COPYLEFT — ALL WRONGS RESERVED** », clin d'œil au « *All rights reserved* » du copyright. Mais ce n'était alors qu'une boutade, sans mécanisme juridique. C'est **Richard Stallman** qui en a fait une véritable stratégie de licence — il raconte avoir adopté le terme après avoir reçu une enveloppe portant la mention « *Copyleft — all rights reversed* ».

> Sources : [« Qu'est-ce que le copyleft ? » (GNU)](https://www.gnu.org/licenses/copyleft.fr.html) · [« All rights reversed » et origine du terme (Wikipédia)](https://en.wikipedia.org/wiki/All_rights_reversed).

## Comment est née la GPL

Le mécanisme copyleft n'est pas apparu d'un bloc. Sa première incarnation est la **GNU Emacs General Public License**, vers **1985** — née en partie d'une mésaventure : du code que Stallman avait utilisé (l'éditeur Gosling Emacs) fut racheté puis refermé par un éditeur tiers, et il voulait empêcher que cela se reproduise. Suivent des licences analogues pour le compilateur **GCC** et le débogueur **GDB**. Problème : chacune était **propre à son programme** (il fallait recopier le texte et y citer le logiciel concerné), si bien qu'elles étaient mutuellement **incompatibles**.

D'où l'étape décisive : en **1989** (le nom « GNU General Public License » apparaît dès **juin 1988**), la **GPL version 1** **généralise** ce texte. C'est tout le sens de **« généraliste »** ici : **un seul texte de licence, indépendant de tout programme, applicable tel quel à n'importe quel logiciel** — au lieu d'une licence à recopier et adapter pour chaque projet. La GPL n'a donc pas *inventé* le copyleft (le terme comme le mécanisme lui préexistaient), mais elle en a été la **première licence réutilisable** — et c'est ce qui a fait son adoption massive.

La suite tient en deux dates. La **GPLv2 (1991)** ajoute la clause dite « Liberty or Death » (en somme : si une contrainte externe — un brevet, par exemple — vous empêche de distribuer en respectant les libertés, vous ne pouvez pas distribuer du tout) ; c'est elle qui est devenue la licence de référence — **le noyau Linux est en GPLv2**. La **GPLv3 (2007)** modernise enfin le texte face à des menaces plus récentes (brevets, tivoïsation), détaillées plus bas.

> Sources : [Histoire de la GNU GPL (free-soft.org)](https://www.free-soft.org/gpl_history/) · [GNU General Public License (Wikipédia)](https://en.wikipedia.org/wiki/GNU_GPL) · [Sam Williams, *Free as in Freedom*, ch. 9 (O'Reilly)](https://www.oreilly.com/openbook/freedom/ch09.html).

## Deux axes pour ne pas s'y perdre

Les noms — GPL, LGPL, AGPL, et leurs « v2 »/« v3 » — mélangent **deux dimensions indépendantes**. Les garder distinctes évite bien des confusions :

- **La *force* du copyleft** — jusqu'où s'étend l'obligation de rester libre : **LGPL** (faible) → **GPL** (standard) → **AGPL** (réseau, la plus étendue).
- **La *version* dans le temps** — **v1 (1989)** → **v2 (1991)** → **v3 (2007)** : avant tout une modernisation juridique.

Un nom comme « AGPLv3 » n'est donc qu'un point sur chacun de ces deux axes. Les deux sections suivantes les prennent l'un après l'autre.

## La famille GPL : LGPL, GPL, AGPL (l'axe de la « force »)

- **GPL** — le copyleft **standard**. Si vous distribuez un programme qui inclut du code GPL, **l'ensemble** doit être publié sous GPL, sources comprises.
- **LGPL** — un copyleft **faible**, pensé pour les **bibliothèques**. Un logiciel privateur peut **se lier** à une bibliothèque LGPL sans devoir lui-même devenir libre ; seules les modifications **de la bibliothèque** restent copyleft. Née en 1991 sous le nom *Library* GPL, elle a été **renommée *Lesser* GPL (v2.1) en 1999** — un changement de nom qui traduit l'intention de la FSF : ne pas en faire le choix par défaut.
- **AGPL** — un copyleft **« réseau »**, le plus étendu. Il ferme le « trou du SaaS » : avec la GPL, faire tourner un logiciel modifié comme **service en ligne** (sans en distribuer le binaire) **ne déclenche pas** l'obligation de partager les sources. L'AGPL l'étend aux utilisateurs qui interagissent avec le programme **à travers un réseau** (sa clause « Remote Network Interaction »). Elle descend de l'**Affero GPL** (2002) ; la **GNU AGPLv3** date de **novembre 2007**.

> Sources : [GNU LGPL (gnu.org)](https://www.gnu.org/licenses/lgpl-3.0.html) · [Historique de la LGPL (FOSSA)](https://fossa.com/blog/open-source-software-licenses-101-lgpl-license/) · [GNU Affero GPL (Wikipédia)](https://en.wikipedia.org/wiki/GNU_Affero_General_Public_License).

Reste l'autre axe : l'**évolution des versions**. C'est là qu'intervient la GPLv3, dont le cas le plus emblématique — celui par lequel le sujet est le plus souvent (mal) compris — est la tivoïsation.

## Tivoïsation et asymétrie de pouvoir

Arrêtons-nous sur un concept clé, car il est souvent mal expliqué : la **tivoïsation**.

Le terme vient de la box **TiVo**, un enregistreur vidéo qui utilisait… **Linux**, sous licence GPLv2. Conformément à la GPL, TiVo publiait bien le code source. Mais l'appareil était conçu pour **n'exécuter que des binaires signés** par le fabricant : l'utilisateur pouvait lire le code, le modifier, le recompiler… **sans jamais pouvoir faire tourner sa version modifiée sur sa propre box**. La liberté sur le papier, le verrou dans le matériel. Richard Stallman a forgé le mot pour désigner ce contournement, et la **FSF l'a explicitement interdit dans la GPLv3** (2007) via une clause dite « anti-tivoïsation ».

Une précision s'impose ici, car le raccourci est tentant : **on pourrait croire que la tivoïsation relève des licences permissives — c'est l'inverse.** **La tivoïsation est un problème de copyleft.** Si TiVo a dû ruser avec le matériel, c'est précisément parce que la GPLv2 l'**obligeait à livrer le code source** : ne pouvant pas cacher les sources, il a verrouillé le matériel pour empêcher quand même les modifications. **Avec une licence permissive, ce détour n'a aucun intérêt** : le fabricant n'a pas besoin de verrouiller quoi que ce soit, puisqu'il peut tout simplement **ne jamais publier le code**. Le permissif est même plus radical — il rend le verrou *juridiquement gratuit* — mais cela n'a rien à voir avec la tivoïsation.

Détail révélateur : le **noyau Linux est resté en GPLv2** et n'est jamais passé à la GPLv3. Linus Torvalds a explicitement rejeté la clause anti-tivoïsation, qu'il juge hors du périmètre d'une licence logicielle. Le sujet divise donc jusqu'au cœur du monde libre.

Reste l'essentiel : l'**asymétrie de pouvoir**. Que ce soit par tivoïsation (copyleft verrouillé) ou par fermeture pure (permissif), le résultat pour l'utilisateur est le même. Le modèle profite massivement aux **méga-corporations** — liberté totale d'innover sur une base libre, **coûts de R&D massivement réduits** (des décennies de développement d'un OS dont on hérite sans avoir à le bâtir), secrets industriels parfaitement protégés. Mais côté **utilisateurs, PME et particuliers**, c'est tout l'inverse : impossibilité de réparer, obsolescence programmée par une simple mise à jour logicielle, dépendance totale au constructeur. La console que vous avez payée, vous ne la **contrôlez** pas.

> Sources : [Tivoization (Wikipédia)](https://en.wikipedia.org/wiki/Tivoization) · [Richard Stallman, « Why Upgrade to GPLv3 » (GNU)](https://www.gnu.org/licenses/rms-why-gplv3.html) · [« Tivoization & Your Right to Install » (Software Freedom Conservancy)](https://sfconservancy.org/blog/2021/jul/23/tivoization-and-the-gpl-right-to-install/)

## Au-delà de la tivoïsation : les autres apports de la GPLv3

La tivoïsation est l'ajout le plus connu de la v3, mais pas le seul. Les autres visent surtout à **boucher des failles juridiques** apparues depuis 1991 :

- **Brevets** — la v3 inclut une **concession de brevets explicite** : qui distribue du code GPLv3 accorde aux destinataires une licence sur ses propres brevets couvrant ce code, ce qui les protège d'une attaque ultérieure.
- **Compatibilité avec Apache 2.0** — conséquence directe : la clause de brevets d'Apache 2.0 était une « restriction supplémentaire » **incompatible avec la GPLv2** ; la **GPLv3 la rend compatible**, ce qui permet enfin de combiner les deux bases de code.
- **Anti-DRM** — la v3 précise qu'un logiciel GPL ne peut pas servir de verrou « anti-contournement » opposable à l'utilisateur.
- **Formulation internationalisée** — un vocabulaire juridique moins centré sur le droit américain, pour mieux tenir hors des États-Unis.

> Sources : [« A Quick Guide to GPLv3 » (GNU)](https://www.gnu.org/licenses/quick-guide-gplv3.en.html) · [Stallman, « Why Upgrade to GPLv3 » (GNU)](https://www.gnu.org/licenses/rms-why-gplv3.html) · [Apache Software Foundation, « Apache License v2.0 and GPL Compatibility »](https://www.apache.org/licenses/GPL-compatibility.html).

## Deux philosophies, un souhait

Au fond, permissif et copyleft ne s'opposent pas sur la technique : ils portent **deux philosophies**. Les licences **permissives** sont dans l'esprit de l'**open source** — faire le meilleur logiciel possible, le plus largement réutilisé, en laissant chacun libre d'en faire ce qu'il veut, **y compris le refermer**. Le **copyleft** est dans l'esprit du **logiciel libre** au sens de la FSF — faire en sorte que la liberté de l'utilisateur ne puisse pas lui être reprise en chemin : elle y est **transitive**, obligée de « ruisseler » jusqu'au dernier maillon. La première démarche est d'abord **pragmatique** ; la seconde, d'abord **éthique**.

> Source : Richard Stallman, [« Pourquoi l'open source passe à côté du problème que soulève le logiciel libre »](https://www.gnu.org/philosophy/open-source-misses-the-point.fr.html).

Je n'en tire pas une leçon à donner. Comme je le raconte dans l'[article fondateur](../01-quand-le-logiciel-privateur-nous-abandonne/), je gagne moi-même ma vie sur du logiciel privateur — autant dire que je serais mal placé pour expliquer aux autres ce qu'ils doivent faire. Ma préférence va à la philosophie qui place la liberté de l'utilisateur au centre ; mais c'est une **préférence**, pas un verdict.

Alors je ne terminerai pas par un jugement, mais par un **souhait** : celui d'un monde informatique plus **libre**, où chacun puisse comprendre, réparer et prolonger les outils dont sa vie dépend. Permissif et copyleft y contribuent, chacun à sa manière — et FreeBSD, dont le code fait tourner une part de l'infrastructure mondiale, en fait pleinement partie.

## Sources et références

- Copyleft et logiciel libre — [Définition du logiciel libre (GNU)](https://www.gnu.org/philosophy/free-sw.fr.html) · [« Qu'est-ce que le copyleft ? » (GNU)](https://www.gnu.org/licenses/copyleft.fr.html) · [GNU GPL FAQ](https://www.gnu.org/licenses/gpl-faq.html) · textes : [GPLv3](https://www.gnu.org/licenses/gpl-3.0.html), [LGPL](https://www.gnu.org/licenses/lgpl-3.0.html), [AGPL](https://www.gnu.org/licenses/agpl-3.0.html)
- Origine du terme « copyleft » — [« All rights reversed » (Wikipédia)](https://en.wikipedia.org/wiki/All_rights_reversed) · [Li-Chen Wang (Wikipédia)](https://en.wikipedia.org/wiki/Li-Chen_Wang)
- Naissance et versions de la GPL — [Histoire de la GNU GPL (free-soft.org)](https://www.free-soft.org/gpl_history/) · [GNU GPL (Wikipédia)](https://en.wikipedia.org/wiki/GNU_GPL) · [Sam Williams, *Free as in Freedom*, ch. 9 (O'Reilly)](https://www.oreilly.com/openbook/freedom/ch09.html)
- Famille LGPL / GPL / AGPL — [GNU LGPL](https://www.gnu.org/licenses/lgpl-3.0.html) · [Historique de la LGPL (FOSSA)](https://fossa.com/blog/open-source-software-licenses-101-lgpl-license/) · [GNU Affero GPL (Wikipédia)](https://en.wikipedia.org/wiki/GNU_Affero_General_Public_License)
- Apports de la GPLv3 — [« A Quick Guide to GPLv3 » (GNU)](https://www.gnu.org/licenses/quick-guide-gplv3.en.html) · [Apache, « Apache License v2.0 and GPL Compatibility »](https://www.apache.org/licenses/GPL-compatibility.html)
- Tivoïsation et GPLv3 — [Tivoization (Wikipédia)](https://en.wikipedia.org/wiki/Tivoization) · [« Why Upgrade to GPLv3 » (Stallman, GNU)](https://www.gnu.org/licenses/rms-why-gplv3.html) · [« Tivoization & Your Right to Install » (Software Freedom Conservancy)](https://sfconservancy.org/blog/2021/jul/23/tivoization-and-the-gpl-right-to-install/)
- Open source vs logiciel libre — [Stallman, « Pourquoi l'open source passe à côté du problème »](https://www.gnu.org/philosophy/open-source-misses-the-point.fr.html)
