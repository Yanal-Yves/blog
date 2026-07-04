---
title: "L'envers des licences permissives — FreeBSD, et la liberté pour qui ?"
description: "Licences permissives (BSD, MIT, Apache) à travers FreeBSD et son usage par Netflix, Sony (PlayStation) et Apple : comment des géants bâtissent du propriétaire sur une base libre, et ce qu'ils rendent (ou non) à la communauté."
weight: 2
---

{{< toc >}}

Dans l'[article fondateur de cette série](../01-quand-le-logiciel-privateur-nous-abandonne/), je racontais comment le logiciel privateur finit par abandonner ses utilisateurs. La réponse que je défends, c'est le logiciel libre. Mais « libre » n'est pas un bloc : il existe deux grandes familles de licences, aux philosophies opposées.

- Les licences **permissives** (BSD, MIT, Apache…) : faire ce que l'on veut du code, y compris le refermer dans un produit propriétaire.
- Les licences **copyleft** : imposer que toute version redistribuée reste libre. La plus connue est la [GPL](https://www.gnu.org/licenses/gpl-3.0.html), mais elle n'est pas la seule : la [LGPL](https://www.gnu.org/licenses/lgpl-3.0.html), l'[AGPL](https://www.gnu.org/licenses/agpl-3.0.html) ou la [MPL](https://www.mozilla.org/en-US/MPL/2.0/) déclinent la même idée à des degrés divers.

Cet article explore la **première** famille — les licences permissives — à travers le cas le plus spectaculaire qui soit : [FreeBSD](https://www.freebsd.org/), ce système d'exploitation que vous utilisez probablement tous les jours sans le savoir. La seconde, le copyleft, fera l'objet d'[un article dédié](../03-licences-copyleft/).

## Qu'est-ce qu'une licence permissive ?

Une licence permissive — les principales sont **BSD** (2 ou 3 clauses), **MIT** et **Apache 2.0** — repose sur une idée simple : donner à celui qui reçoit le code une **liberté quasi totale**. Concrètement, trois droits :

- le droit de **modifier** le code ;
- le droit de le **redistribuer** ;
- le droit de le **fermer** — c'est-à-dire d'en faire un produit propriétaire, une boîte noire, sans publier ses modifications.

En échange, une seule véritable contrainte : **conserver la mention de copyright et de licence d'origine**. C'est tout. (Apache 2.0 ajoute une clause de concession de brevets et un fichier `NOTICE` ; BSD-3 interdit d'utiliser le nom des auteurs pour endosser un produit dérivé — mais l'esprit reste le même.)

C'est là toute la différence avec le **copyleft** (la GPL en est l'exemple le plus connu), que nous verrons en détail dans un prochain article : une licence copyleft impose que toute version redistribuée reste libre, code source inclus. La licence permissive ne l'impose pas. **Elle autorise donc explicitement à reprendre du libre pour en faire du privateur.** Retenez cette phrase : tout l'article en découle.

## FreeBSD, un système d'exploitation complet, libre… et permissif

Pour voir ce que cela donne en pratique, un bon exemple est **FreeBSD**. Et la première chose à comprendre, c'est que **ce n'est pas une « distribution » comme Ubuntu ou Fedora**.

GNU/Linux, c'est un noyau (Linux) assemblé avec une foule de logiciels venus de projets séparés (le userland GNU, etc.), réunis par un distributeur. FreeBSD, à l'inverse, développe le **noyau ET le userland** (les outils de base du système) **ensemble, dans un seul et même arbre de code source**. Le résultat est un système d'exploitation **complet, cohérent et unifié**, pensé d'un bloc.

Cette cohérence lui a valu une réputation d'**extrême stabilité**, en particulier sur deux terrains : une **pile réseau TCP/IP** réputée parmi les meilleures de l'industrie, et l'intégration native du système de fichiers **ZFS**. C'est précisément ce qui en fait un choix de prédilection pour l'**infrastructure** — là où il faut tenir des charges énormes pendant des années sans broncher. Et c'est là que les licences permissives entrent en scène.

## Comment les géants exploitent FreeBSD

### Netflix : l'infrastructure invisible

Quand vous regardez une vidéo Netflix, elle ne vient probablement pas d'un lointain data center, mais d'un boîtier **Open Connect Appliance** (OCA) installé directement chez votre fournisseur d'accès (Free, Orange, etc.). Et ces boîtiers tournent sous **FreeBSD**.

L'échelle est considérable : Netflix a dépensé **plus d'un milliard de dollars** pour développer et déployer **plus de 8 000** de ces appliances, installées par plus de **1 000 fournisseurs d'accès** — ce qui a permis à ces derniers d'**économiser 1,25 milliard de dollars** (à fin 2021), en évitant de faire transiter tout ce trafic vidéo sur leurs liens. Côté performances, des ingénieurs de Netflix ont présenté à l'[EuroBSDCon](https://www.eurobsdcon.org/) 2022 un seul serveur capable de servir **près de 800 Gb/s** de vidéo chiffrée.

Netflix illustre le **modèle permissif en pratique** : bâtir l'un des plus gros services propriétaires du monde sur une base libre, en ne reversant que ce qu'on a intérêt à reverser. Et c'est justement ce que fait Netflix : il **reverse ses modifications** du noyau à FreeBSD, et fait tourner ses serveurs sur **FreeBSD-CURRENT** (la branche de développement) — non par générosité, mais par **intérêt bien compris** : garder un *fork* privé qui diverge de l'amont coûte cher en « dette technique ». Il garde en revanche fermée sa **couche applicative** — le logiciel Open Connect lui-même : serveur de diffusion, algorithmes de cache et de placement de contenu.

Mais soyons honnêtes, car le point est important pour la suite : **une licence copyleft (GPL) n'y changerait presque rien.** D'abord parce que cette couche fermée tourne en **espace utilisateur** : même sur un noyau copyleft comme Linux, une application qui se contente d'appeler le noyau n'est pas une « œuvre dérivée » et peut rester propriétaire (c'est pourquoi tant de logiciels fermés tournent sur Linux). Ensuite parce que le copyleft ne se déclenche qu'à la **distribution** du logiciel : or les boîtiers restent la propriété de Netflix, opérés en interne — et son noyau modifié est de toute façon **déjà public**, par choix. Pour de l'**infrastructure opérée en interne**, le choix de licence pèse donc peu. Là où il devient décisif, c'est quand le logiciel est **livré entre les mains de l'utilisateur final** — exactement ce que montrent les deux cas suivants.

> Sources : [Open Connect (Wikipédia)](https://en.wikipedia.org/wiki/Open_Connect) (système FreeBSD ; plus d'1 Md$ pour 8 000+ OCA ; 1,25 Md$ d'économies pour les FAI à fin 2021) · [Netflix sert près de 800 Gb/s sur FreeBSD (EuroBSDCon 2022)](https://papers.freebsd.org/2022/eurobsdcon/gallatin-the_other_freebsd_optimizations-netflix/) · stratégie d'*upstream* pour réduire la dette technique : [étude de cas Netflix (FreeBSD Foundation)](https://freebsdfoundation.org/netflix-case-study/), [« Netflix and FreeBSD », J. Looney, FOSDEM 2019](https://papers.freebsd.org/2019/fosdem/looney-netflix_and_freebsd/) · sur copyleft, espace utilisateur et distribution : [GNU GPL FAQ](https://www.gnu.org/licenses/gpl-faq.html)

### Sony PlayStation : la forteresse verrouillée

La généalogie des consoles Sony est une histoire de BSD. La **PS3** s'appuyait déjà sur un système interne (CellOS) **forké à la fois de FreeBSD et de NetBSD**. La **PS4** a basculé entièrement sur un système baptisé **Orbis OS**, un *fork* de **FreeBSD 9.0**. La **PS5**, elle, tourne sous un système interne nommé **ProsperoOS**, basé sur **FreeBSD 11**.

Petite précision d'honnêteté, parce qu'elle compte : pour la PS5, **Sony ne communique rien**. Le nom « ProsperoOS » et la version « FreeBSD 11 » sont **déduits par des chercheurs en sécurité** qui réparent et étudient la console (rétro-ingénierie), pas confirmés officiellement. Je le signale d'autant plus volontiers qu'on lit souvent que la PS5 tournerait sous « Orbis OS 2.0 » — c'est une confusion : *Orbis* est le nom de code de la PS4, *Prospero* celui de la PS5.

Pourquoi FreeBSD pour une console ? Pour deux raisons qui vont ensemble : un **OS x86 industriel et robuste**, et une **licence qui autorise à tout verrouiller**. Sony ferme l'essentiel — pilotes graphiques co-développés avec AMD, hyperviseur de sécurité, interface utilisateur — et conçoit la machine pour n'exécuter que du **code signé**, afin de bloquer le piratage. Logiquement, l'entreprise reverse très peu à l'amont : le matériel est trop spécifique, et le secret fait partie de la sécurité.

> Sources — **PS3** : [PlayStation 3 system software (Wikipédia)](https://en.wikipedia.org/wiki/PlayStation_3_system_software) (« a fork of both FreeBSD and NetBSD ») · **PS4** : [PlayStation 4 system software (Wikipédia)](https://en.wikipedia.org/wiki/PlayStation_4_system_software), [« PlayStation 4 runs modified FreeBSD 9.0: Orbis OS » (OSNews)](https://www.osnews.com/story/27145/playstation-4-runs-modified-freebsd-90-orbis-os/) · **PS5** : [PS5 Kernel — FreeBSD 11.0 / `__FreeBSD_version 1100122` (PS5 Developer wiki, rétro-ingénierie)](https://www.psdevwiki.com/ps5/Kernel)

### Apple : le Frankenstein technologique

Le cas le plus profond est celui d'**Apple**, et il remonte loin. En 1985, Steve Jobs quitte Apple et fonde NeXT, dont le système **NeXTSTEP** (1989) marie un noyau **Mach** et un sous-système Unix **4.3BSD**. Quand Apple rachète NeXT en 1996, c'est **NeXTSTEP qui devient le socle** de Mac OS X — et donc, aujourd'hui, de macOS, iOS, watchOS et tvOS.

Au cœur de ces systèmes : le noyau **XNU**, dit « hybride ». Il combine le micro-noyau **Mach**, une **couche BSD** (issue de 4.3BSD, puis enrichie de 4.4BSD et de code **FreeBSD** : réseau, compatibilité POSIX, système de fichiers) et **IOKit** pour les pilotes. Conséquence concrète et amusante : quand vous tapez `ls` ou `cp` dans le Terminal d'un Mac, vous utilisez les versions **BSD** de ces commandes, pas les versions GNU que connaissent les linuxiens.

Mais Apple illustre surtout une autre facette des licences. Attention à ne pas exagérer : Apple a **longtemps embarqué du logiciel sous GPLv2** (le compilateur GCC, le shell bash…). Ce qu'elle refuse **méthodiquement**, c'est la **GPLv3** (publiée en 2007). Trois exemples, tous au moment précis où le logiciel est passé de GPLv2 à GPLv3 :

- **Le compilateur.** Apple a longtemps utilisé **GCC**, puis l'a figé à la version **4.2.1** — la dernière publiée sous GPLv2 — avant de financer et d'adopter **Clang/LLVM**, sous licence permissive. Sur un Mac, taper `gcc` lance en réalité Clang.
- **Le shell.** Apple a de même gardé **bash 3.2** (la dernière version sous GPLv2) pendant des années, refusant les versions suivantes passées en GPLv3, puis a fait de **zsh le shell par défaut** à partir de macOS **Catalina (2019)**.
- **Le partage de fichiers Windows.** Quand le projet **Samba** est passé en GPLv3, Apple l'a tout bonnement **retiré de macOS** (Lion, 2011) pour le remplacer par sa propre implémentation du protocole SMB.

Et pourtant — c'est là que c'est savoureux — quand Apple **publie** son propre code, elle ne choisit pas une licence permissive. Le cœur libre de macOS, **Darwin**, est diffusé sous l'**Apple Public Source License (APSL)** : une licence que la FSF reconnaît comme libre, mais qui est **copyleft** et **incompatible avec la GPL** — la FSF la compare même à l'**AGPL** pour une clause obligeant à publier ses modifications dès qu'on déploie le logiciel à l'extérieur. Autrement dit, Apple **fuit le copyleft pour le code qu'elle consomme**, mais en **attache un à celui qu'elle diffuse**. Preuve, s'il en fallait, que le choix d'une licence n'est pas affaire de principe, mais d'**intérêt** — selon qu'on est celui qui prend ou celui qui donne.

Pourquoi cette constance à éviter la GPLv3 ? Parce qu'elle contient des clauses qu'Apple ne veut pas accepter — en particulier ses obligations sur les brevets et sa clause « anti-tivoïsation », sur laquelle revient [un article dédié de cette série](../04-torvalds-gplv3/).

> Sources : [Apple's Open Source Roots: The BSD Heritage Behind macOS and iOS (FreeBSD Foundation)](https://freebsdfoundation.org/news-and-events/latest-news/apples-open-source-roots-the-bsd-heritage-behind-macos-and-ios/) · [Darwin (operating system) (Wikipédia)](https://en.wikipedia.org/wiki/Darwin_(operating_system)) · bash → zsh et la raison GPLv3 : [« Why does macOS Catalina use Zsh instead of Bash? Licensing » (The Next Web)](https://thenextweb.com/news/why-does-macos-catalina-use-zsh-instead-of-bash-licensing), [zsh, shell par défaut (doc Apple)](https://support.apple.com/en-us/102360) · Samba retiré pour cause de GPLv3 : [OSNews](https://www.osnews.com/story/24572/apple-ditches-samba-in-favour-of-homegrown-replacement/), [Engadget](https://www.engadget.com/2011-03-24-apple-to-drop-samba-networking-tools-from-lion.html) · APSL : [Apple Public Source License (Wikipédia)](https://en.wikipedia.org/wiki/Apple_Public_Source_License), [classification FSF (liste des licences GNU)](https://www.gnu.org/licenses/license-list.html#apsl2)

## La nuance : ce que les géants rendent vraiment

Le tableau serait malhonnête s'il était purement à charge. Même quand l'utilisateur final est verrouillé, **l'écosystème libre tire de réels bénéfices** de la présence de ces géants. Trois faits, vérifiés :

- **Le financement.** Netflix est un **soutien financier régulier de la FreeBSD Foundation** (dons et matériel pour les développeurs). *(En revanche, pour Apple et Sony, je n'ai pas trouvé de financement direct documenté de la FreeBSD Foundation ; leur apport majeur passe ailleurs — voir ci-dessous.)*
- **LLVM/Clang, le contre-don le plus précieux.** En refusant la GPLv3 pour ses outils, Apple a propulsé un compilateur moderne entièrement neuf : **LLVM/Clang**, aujourd'hui sous licence **Apache 2.0 (avec exceptions LLVM)** — à l'origine sous une licence permissive de type BSD (NCSA). Apple a embauché son créateur Chris Lattner dès **2005** ; et **Sony fait partie des contributeurs** de Clang. Or ce compilateur profite désormais à **toute l'industrie**, y compris à Linux et à FreeBSD. Un outil né d'un refus de la GPL est devenu un bien commun.
- **Les briques partagées.** **WebKit**, le moteur de rendu d'Apple, est lui-même un *fork* de **KHTML** (le moteur du projet libre KDE, sous LGPL) — et il a redéfini le web moderne (Chrome lui-même en descend). **Bonjour/mDNSResponder**, la découverte de services réseau d'Apple, a été publié sous **Apache 2.0**.

Autrement dit : les licences permissives créent une circulation, imparfaite mais réelle, entre les géants et les communautés. Ce serait caricatural de n'y voir qu'un pillage.

> Sources : [FreeBSD Foundation — Record Growth and Partner Investments (2024)](https://www.globenewswire.com/news-release/2024/05/28/2889125/0/en/FreeBSD-Foundation-Marks-Record-Growth-and-Partner-Investments.html) · [LLVM (Wikipédia)](https://en.wikipedia.org/wiki/LLVM) · [Clang (Wikipédia)](https://en.wikipedia.org/wiki/Clang) · [WebKit (Wikipédia)](https://en.wikipedia.org/wiki/WebKit) · [Bonjour (Wikipédia)](https://en.wikipedia.org/wiki/Bonjour_(software))

## Et le copyleft ?

Les licences permissives, on l'a vu, laissent les géants bâtir du propriétaire sur une base libre — tout en lui rendant, par intérêt, de précieux contre-dons. C'est cohérent avec la philosophie de l'**open source** : faire le meilleur logiciel possible, le plus largement réutilisé. L'autre grande famille de licences libres — le **copyleft** (GPL, LGPL, AGPL) — poursuit un tout autre but : **empêcher que la liberté soit reprise à l'utilisateur**. Ce sera l'objet d'[un prochain article de cette série](../03-licences-copyleft/), qui partira d'un cas devenu emblématique, la **tivoïsation**, et débouchera sur une conclusion commune à nos deux familles de licences.

## Sources et références

- Licences libres et permissives — [Définition du logiciel libre (GNU)](https://www.gnu.org/philosophy/free-sw.fr.html) · [Comparatif des licences open source (OSI)](https://opensource.org/licenses) · [GNU GPL FAQ — copyleft, espace utilisateur, distribution](https://www.gnu.org/licenses/gpl-faq.html)
- FreeBSD, système complet et ZFS — [Apple's Open Source Roots (FreeBSD Foundation)](https://freebsdfoundation.org/news-and-events/latest-news/apples-open-source-roots-the-bsd-heritage-behind-macos-and-ios/)
- Netflix / Open Connect — [Open Connect (Wikipédia)](https://en.wikipedia.org/wiki/Open_Connect) · [Netflix à ~800 Gb/s sur FreeBSD (EuroBSDCon 2022)](https://papers.freebsd.org/2022/eurobsdcon/gallatin-the_other_freebsd_optimizations-netflix/) · [étude de cas Netflix (FreeBSD Foundation)](https://freebsdfoundation.org/netflix-case-study/) · [« Netflix and FreeBSD » (FOSDEM 2019)](https://papers.freebsd.org/2019/fosdem/looney-netflix_and_freebsd/)
- Sony PlayStation — **PS3** : [PlayStation 3 system software (Wikipédia)](https://en.wikipedia.org/wiki/PlayStation_3_system_software) · **PS4** : [PS4 system software (Wikipédia)](https://en.wikipedia.org/wiki/PlayStation_4_system_software), [Orbis OS / FreeBSD 9 (OSNews)](https://www.osnews.com/story/27145/playstation-4-runs-modified-freebsd-90-orbis-os/) · **PS5** : [PS5 Kernel (PS5 Developer wiki)](https://www.psdevwiki.com/ps5/Kernel)
- Apple, XNU et héritage BSD — [Darwin (Wikipédia)](https://en.wikipedia.org/wiki/Darwin_(operating_system)) · [bash → zsh sous Catalina, la raison GPLv3 (The Next Web)](https://thenextweb.com/news/why-does-macos-catalina-use-zsh-instead-of-bash-licensing) · [zsh, shell par défaut (doc Apple)](https://support.apple.com/en-us/102360)
- Contre-dons (LLVM, WebKit, Bonjour, financement) — [LLVM (Wikipédia)](https://en.wikipedia.org/wiki/LLVM) · [Clang (Wikipédia)](https://en.wikipedia.org/wiki/Clang) · [Chris Lattner (Wikipédia)](https://en.wikipedia.org/wiki/Chris_Lattner) · [WebKit (Wikipédia)](https://en.wikipedia.org/wiki/WebKit) · [Bonjour (Wikipédia)](https://en.wikipedia.org/wiki/Bonjour_(software)) · [FreeBSD Foundation, partenaires 2024](https://www.globenewswire.com/news-release/2024/05/28/2889125/0/en/FreeBSD-Foundation-Marks-Record-Growth-and-Partner-Investments.html)