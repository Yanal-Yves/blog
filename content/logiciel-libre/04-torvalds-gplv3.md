---
title: "Pourquoi le noyau Linux est resté en GPLv2 : Torvalds face à la GPLv3"
description: "La position de Linus Torvalds sur la GPLv3 et la clause anti-tivoïsation : pourquoi le noyau Linux est resté en GPLv2, ce qu'il a réellement refusé, et le clivage de fond entre l'éthique de la FSF et le pragmatisme de l'open source."
weight: 4
---

{{< toc >}}

Dans l'[article précédent sur les licences copyleft](../03-licences-copyleft/), un détail méritait qu'on s'y arrête vraiment : la **GPLv3** (2007) a ajouté une clause **anti-tivoïsation**, et le **noyau Linux**, lui, n'est jamais passé à la GPLv3. L'opposant le plus visible à cette version : **Linus Torvalds**, le créateur de Linux.

On pourrait croire qu'il est favorable au DRM, ou qu'il néglige la liberté de l'utilisateur. Ni l'un ni l'autre : sa position est **cohérente** et repose sur une idée précise — *une licence logicielle doit régir le logiciel, pas le matériel*. La décortiquer est utile, car elle révèle une **ligne de fracture réelle** à l'intérieur même du monde du libre.

## Un préalable : « GPLv2 only », pas « v2 or later »

Beaucoup de projets se publient sous « **GPLv2 or later** » (« v2 ou toute version ultérieure ») : une telle formulation autorise quiconque à basculer le code vers une version plus récente de la licence. Le noyau Linux, lui, est sous **GPLv2 *seulement*** — son fichier `COPYING` précise qu'il est régi « *under the terms of the GNU General Public License version 2 only* », sans l'option « or later ».

Conséquence pratique : même si tout le monde le voulait, **passer le noyau en GPLv3 exigerait l'accord de tous les détenteurs de droits** — des milliers de contributeurs accumulés sur des décennies. C'est, dans les faits, **impossible**. Le « v2 only » est donc à la fois un **verrou pratique** et un **choix délibéré** : avant même tout débat d'opinion, la bascule était hors de portée.

> Sources : [Linux kernel, fichier `COPYING`](https://github.com/torvalds/linux/blob/master/COPYING) · [Documentation noyau, « License rules »](https://www.kernel.org/doc/html/latest/process/license-rules.html).

## L'objection de fond : la licence couvre le logiciel, pas le matériel

Le cœur du désaccord porte sur la clause **anti-tivoïsation**. Le principe que défend Torvalds, dans ses propres mots (janvier 2006) :

> « I believe that a software license should cover the software it licenses. »
> *(« Je crois qu'une licence logicielle devrait couvrir le logiciel qu'elle licencie. »)*

Pour lui, qu'un appareil n'accepte que des micrologiciels signés relève du **design matériel** — une décision de fabricant, pas l'affaire de la licence du logiciel. Il le dit sans détour (février 2006) :

> « I literally feel that we do not — as software developers — have the moral right to enforce our rules on hardware manufacturers. […] I do software, and I license software. »
> *(« Je crois sincèrement que nous n'avons pas, en tant que développeurs de logiciels, le droit moral d'imposer nos règles aux fabricants de matériel. […] Je fais du logiciel, et je licencie du logiciel. »)*

Or la GPLv3 exige, pour ce genre d'appareils, que le fabricant fournisse de quoi installer et exécuter une version modifiée (les « *installation information* », c'est-à-dire en pratique les clés de signature). C'est précisément ce point que Torvalds rejette :

> « I think it's insane to require people to make their private signing keys available, for example. I wouldn't do it. »
> *(« Je trouve insensé d'exiger des gens qu'ils rendent disponibles leurs clés de signature privées, par exemple. Je ne le ferais pas. »)*

Il est même allé jusqu'à juger le **terme « tivoïsation » lui-même** déplacé, faisant valoir que TiVo **respectait la GPLv2** (l'entreprise publiait bien le code source) et n'avait donc, de son point de vue, rien fait d'illégitime.

> Sources : messages de Linus Torvalds (janvier-février 2006) — [archive thématique « GPL » sur yarchive.net](https://yarchive.net/comp/linux/gpl.html) (copies verbatim avec dates et Message-ID) · [Computerworld, « Torvalds says no to GPLv3 »](https://www.computerworld.com/article/1577303/torvalds-says-no-to-gplv3.html) · fil LKML [« GPL V3 and Linux »](https://lkml.iu.edu/hypermail/linux/kernel/0601.3/1495.html).

## « Favorable au DRM » : ce qu'il a vraiment dit

L'étiquette n'est pas inventée : Torvalds a écrit noir sur blanc, en avril 2003, « *I want to make it clear that DRM is perfectly ok with Linux!* », et il s'est opposé à ce qu'on se serve de la GPL pour **interdire** le DRM. Mais « le DRM est permis » ne veut pas dire « le DRM, c'est bien » : c'est exactement la même règle que pour le matériel — une licence dit ce qu'on doit **partager** (le code source), pas ce qu'on a le droit de **faire** avec le logiciel. Refuser qu'elle bannisse un usage n'est pas en faire l'éloge.

Ce qu'il a refusé dans la GPLv3 n'est donc pas « moins de DRM », mais l'**obligation liée au matériel** (livrer les clés de signature). Et face aux verrous, son pari n'est pas la coercition par la licence mais la **concurrence** : il estimait qu'un matériel qui bride ses utilisateurs finirait par perdre **de lui-même**, l'hostilité à l'utilisateur n'étant pas un bon modèle économique.

Autrement dit, là où la FSF veut **interdire** le verrou par la licence, Torvalds préfère **laisser le marché** le sanctionner. On peut trouver ce pari naïf ou réaliste — c'est un autre débat — mais permettre le DRM (refuser de l'interdire par la licence) n'est pas le promouvoir.

> Sources : [LWN.net, « Linus on digital rights management » (avril 2003 — « DRM is perfectly ok with Linux! »)](https://lwn.net/Articles/30048/) · [Linux.com, « Stallman, Torvalds, Moglen share views on DRM and GPLv3 »](https://www.linux.com/news/stallman-torvalds-moglen-share-views-drm-and-gplv3/).

## Le vrai clivage : éthique de la FSF contre pragmatisme de l'open source

Au fond, ce n'est pas une querelle technique mais un désaccord de **valeurs**, le même qui sépare « logiciel libre » et « open source » :

- Pour **Richard Stallman et la FSF**, la liberté de l'utilisateur doit être protégée **jusque sur sa machine** : si vous pouvez lire et modifier le code mais pas exécuter votre version modifiée sur votre propre appareil, la liberté n'est qu'apparente. La clause anti-tivoïsation **comble** ce vide.
- Pour **Torvalds**, la GPLv2 est un échange équilibré — *« tu reçois le code, tu rends tes modifications du code »* — et la licence n'a pas à s'étendre **au-delà du code** lui-même.

Deux systèmes de valeurs **cohérents**, pas un camp qui aurait raison contre l'autre. Le résultat, lui, est concret : le projet GPL le plus important au monde — **le noyau Linux** — est resté en GPLv2, et une large part de l'écosystème l'a suivi. Le débat n'a jamais été tranché ; il dit surtout que le « libre » n'est **pas monolithique**.

## En somme

Le refus de la GPLv3 par Torvalds n'est ni un caprice ni une trahison de la liberté : c'est une **conception différente du périmètre d'une licence**. Stallman veut que la licence protège l'utilisateur jusque dans le matériel ; Torvalds veut qu'elle s'arrête au logiciel. Comprendre ce point, c'est comprendre pourquoi deux personnes également attachées au libre ont pu, en toute bonne foi, choisir des camps opposés — et pourquoi votre téléphone ou votre console, eux, restent souvent verrouillés quoi qu'il arrive.

## Sources et références

- Licence du noyau Linux (GPLv2 *only*) — [fichier `COPYING`](https://github.com/torvalds/linux/blob/master/COPYING) · [Documentation, « License rules »](https://www.kernel.org/doc/html/latest/process/license-rules.html)
- Déclarations de Torvalds (janvier-février 2006) — [archive thématique « GPL » sur yarchive.net](https://yarchive.net/comp/linux/gpl.html) (copies verbatim, datées, avec Message-ID traçables) · [Computerworld, « Torvalds says no to GPLv3 »](https://www.computerworld.com/article/1577303/torvalds-says-no-to-gplv3.html) · fil LKML [« GPL V3 and Linux »](https://lkml.iu.edu/hypermail/linux/kernel/0601.3/1495.html)
- DRM, position de Torvalds — [LWN.net, « Linus on digital rights management » (avril 2003)](https://lwn.net/Articles/30048/) · [Linux.com, « Stallman, Torvalds, Moglen share views on DRM and GPLv3 »](https://www.linux.com/news/stallman-torvalds-moglen-share-views-drm-and-gplv3/)
- Tivoïsation et GPLv3 — [Tivoization (Wikipédia)](https://en.wikipedia.org/wiki/Tivoization) · [Stallman, « Why Upgrade to GPLv3 » (GNU)](https://www.gnu.org/licenses/rms-why-gplv3.html)
