---
title: "Les licences copyleft : la liberté qu'on ne peut pas reprendre"
description: "Les licences copyleft (GPL, LGPL, AGPL) en regard des permissives : comment le copyleft cherche à rendre la liberté de l'utilisateur inaliénable, ce qu'est la tivoïsation, et pourquoi elle a fait naître la GPLv3."
weight: 3
---

{{< toc >}}

Le [premier volet de cette série](../02-licences-permissives-freebsd/) explorait les licences **permissives** (BSD, MIT, Apache) à travers FreeBSD : elles laissent chacun libre de faire ce qu'il veut du code, **y compris le refermer**. Voici leur pendant : les licences **copyleft**.

La différence tient en une idée. Là où le permissif autorise à refermer, le **copyleft impose que toute version redistribuée reste libre**, code source compris. La plus connue est la [GPL](https://www.gnu.org/licenses/gpl-3.0.html), avec ses variantes [LGPL](https://www.gnu.org/licenses/lgpl-3.0.html) et [AGPL](https://www.gnu.org/licenses/agpl-3.0.html). Son but n'est pas seulement de partager du code : c'est de faire en sorte que la liberté **ne puisse pas être reprise** à l'utilisateur en aval.

Cet article est une **première pièce** (la série est en cours d'écriture) : il part du cas le plus emblématique — la **tivoïsation**, ce bras de fer qui a donné naissance à la GPLv3 — avant une conclusion commune aux deux volets.

## Tivoïsation et asymétrie de pouvoir

Arrêtons-nous sur un concept clé, car il est souvent mal expliqué : la **tivoïsation**.

Le terme vient de la box **TiVo**, un enregistreur vidéo qui utilisait… **Linux**, sous licence GPLv2. Conformément à la GPL, TiVo publiait bien le code source. Mais l'appareil était conçu pour **n'exécuter que des binaires signés** par le fabricant : l'utilisateur pouvait lire le code, le modifier, le recompiler… **sans jamais pouvoir faire tourner sa version modifiée sur sa propre box**. La liberté sur le papier, le verrou dans le matériel. Richard Stallman a forgé le mot pour désigner ce contournement, et la **FSF l'a explicitement interdit dans la GPLv3** (2007) via une clause dite « anti-tivoïsation ».

Une précision s'impose ici, car le raccourci est tentant : **on pourrait croire que la tivoïsation relève des licences permissives — c'est l'inverse.** **La tivoïsation est un problème de copyleft.** Si TiVo a dû ruser avec le matériel, c'est précisément parce que la GPLv2 l'**obligeait à livrer le code source** : ne pouvant pas cacher les sources, il a verrouillé le matériel pour empêcher quand même les modifications. **Avec une licence permissive, ce détour n'a aucun intérêt** : le fabricant n'a pas besoin de verrouiller quoi que ce soit, puisqu'il peut tout simplement **ne jamais publier le code**. Le permissif est même plus radical — il rend le verrou *juridiquement gratuit* — mais cela n'a rien à voir avec la tivoïsation.

Détail révélateur : le **noyau Linux est resté en GPLv2** et n'est jamais passé à la GPLv3. Linus Torvalds a explicitement rejeté la clause anti-tivoïsation, qu'il juge hors du périmètre d'une licence logicielle. Le sujet divise donc jusqu'au cœur du monde libre.

Reste l'essentiel : l'**asymétrie de pouvoir**. Que ce soit par tivoïsation (copyleft verrouillé) ou par fermeture pure (permissif), le résultat pour l'utilisateur est le même. Le modèle profite massivement aux **méga-corporations** — liberté totale d'innover sur une base libre, **coûts de R&D massivement réduits** (des décennies de développement d'un OS dont on hérite sans avoir à le bâtir), secrets industriels parfaitement protégés. Mais côté **utilisateurs, PME et particuliers**, c'est tout l'inverse : impossibilité de réparer, obsolescence programmée par une simple mise à jour logicielle, dépendance totale au constructeur. La console que vous avez payée, vous ne la **contrôlez** pas.

> Sources : [Tivoization (Wikipédia)](https://en.wikipedia.org/wiki/Tivoization) · [Richard Stallman, « Why Upgrade to GPLv3 » (GNU)](https://www.gnu.org/licenses/rms-why-gplv3.html) · [« Tivoization & Your Right to Install » (Software Freedom Conservancy)](https://sfconservancy.org/blog/2021/jul/23/tivoization-and-the-gpl-right-to-install/)

## Deux philosophies, un souhait

Au fond, permissif et copyleft ne s'opposent pas sur la technique : ils portent **deux philosophies**. Les licences **permissives** sont dans l'esprit de l'**open source** — faire le meilleur logiciel possible, le plus largement réutilisé, en laissant chacun libre d'en faire ce qu'il veut, **y compris le refermer**. Le **copyleft** est dans l'esprit du **logiciel libre** au sens de la FSF — faire en sorte que la liberté de l'utilisateur ne puisse pas lui être reprise en chemin : elle y est **transitive**, obligée de « ruisseler » jusqu'au dernier maillon. La première démarche est d'abord **pragmatique** ; la seconde, d'abord **éthique**.

> Source : Richard Stallman, [« Pourquoi l'open source passe à côté du problème que soulève le logiciel libre »](https://www.gnu.org/philosophy/open-source-misses-the-point.fr.html).

Je n'en tire pas une leçon à donner. Comme je le raconte dans l'[article fondateur](../01-quand-le-logiciel-privateur-nous-abandonne/), je gagne moi-même ma vie sur du logiciel privateur — autant dire que je serais mal placé pour expliquer aux autres ce qu'ils doivent faire. Ma préférence va à la philosophie qui place la liberté de l'utilisateur au centre ; mais c'est une **préférence**, pas un verdict.

Alors je ne terminerai pas par un jugement, mais par un **souhait** : celui d'un monde informatique plus **libre**, où chacun puisse comprendre, réparer et prolonger les outils dont sa vie dépend. Permissif et copyleft y contribuent, chacun à sa manière — et FreeBSD, dont le code fait tourner une part de l'infrastructure mondiale, en fait pleinement partie.

## Sources et références

- Copyleft et logiciel libre — [Définition du logiciel libre (GNU)](https://www.gnu.org/philosophy/free-sw.fr.html) · [GNU GPL FAQ](https://www.gnu.org/licenses/gpl-faq.html) · textes : [GPLv3](https://www.gnu.org/licenses/gpl-3.0.html), [LGPL](https://www.gnu.org/licenses/lgpl-3.0.html), [AGPL](https://www.gnu.org/licenses/agpl-3.0.html)
- Tivoïsation et GPLv3 — [Tivoization (Wikipédia)](https://en.wikipedia.org/wiki/Tivoization) · [« Why Upgrade to GPLv3 » (Stallman, GNU)](https://www.gnu.org/licenses/rms-why-gplv3.html) · [« Tivoization & Your Right to Install » (Software Freedom Conservancy)](https://sfconservancy.org/blog/2021/jul/23/tivoization-and-the-gpl-right-to-install/)
- Open source vs logiciel libre — [Stallman, « Pourquoi l'open source passe à côté du problème »](https://www.gnu.org/philosophy/open-source-misses-the-point.fr.html)
