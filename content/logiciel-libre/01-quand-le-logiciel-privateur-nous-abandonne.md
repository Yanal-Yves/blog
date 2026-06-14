---
title: "Quand le logiciel privateur nous abandonne"
description: "Article fondateur : vingt-cinq ans d'expériences vécues avec le logiciel propriétaire (Access, Classic ASP, Visual Studio, Windows, OneDrive, Balsamiq, PC Soft) qui mènent à une conviction — se tourner vers le logiciel libre et des modèles économiques respectueux des utilisateurs."
weight: 1
---

{{< toc >}}

## Pourquoi cet article

J'ai passé plus de vingt ans à développer et à architecturer des logiciels. Pendant ces années, j'ai vu se répéter le même scénario : une entreprise technologique décide, **seule et unilatéralement**, d'abandonner une technologie, de casser une compatibilité, de changer un prix ou une licence — et des utilisateurs, des indépendants, des associations, des entreprises entières se retrouvent « le bec dans l'eau ». Pas par accident, mais parce que le modèle même du **logiciel privateur** le permet.

Le mot « privateur » n'est pas une coquetterie. C'est le terme défendu par Richard Stallman et la communauté du logiciel libre francophone pour traduire l'anglais *proprietary*, parce qu'il dit ce qu'il se passe vraiment : ce type de logiciel **prive l'utilisateur de ses libertés** — celle d'étudier le programme, de le modifier, de le corriger, de le faire vivre quand son éditeur a décidé de le laisser mourir. Avec un logiciel privateur, comme l'explique Stallman, **ce n'est pas l'utilisateur qui contrôle le programme : c'est le programme qui contrôle l'utilisateur**, et c'est l'éditeur qui contrôle le programme. (Voir la [définition du logiciel libre](https://www.gnu.org/philosophy/free-sw.fr.html) et [« Le logiciel libre est encore plus essentiel maintenant »](https://www.gnu.org/philosophy/free-software-even-more-important.fr.html).)

Cet article repose sur des **situations que j'ai réellement vécues**, puis montre ce que le logiciel libre aurait changé. Il ouvre une série, en cours d'écriture, sur le logiciel libre et les licences. Je ne raconte pas une théorie : je raconte des murs sur lesquels je me suis cogné. J'ai vérifié les faits et les dates auprès de sources publiques, listées en fin d'article ; quand un souvenir n'a pas pu être confirmé précisément, je le signale.

## Expérience 1 — L'école de musique et Microsoft Access

À la fin des années 1990, le directeur d'une école de musique développe lui-même, sur son temps libre, un logiciel de gestion de son établissement. Il s'appuie sur **Microsoft Access 2.0** (avril 1994), un outil pensé pour des non-développeurs : des gens qui n'ont pas de culture du génie logiciel — ni tests unitaires, ni tests de bout en bout — et pour qui, de toute façon, les frameworks permettant ces pratiques n'existaient pas dans cet environnement à l'époque. Des nuits et des week-ends de travail pour fiabiliser et simplifier l'administration de l'école, et faire gagner du temps à tout le monde.

Puis arrive la version suivante, **Access 95** (août 1995). Et là, c'est la rupture. Entre Access 2.0 et Access 95, **la compatibilité est cassée en profondeur** :

- le langage interne change complètement : Access 2.0 utilisait **Access Basic**, remplacé par **VBA** (Visual Basic for Applications) dès Access 95 ;
- on passe du **16 bits au 32 bits** : tous les appels d'API système doivent être réécrits ;
- de nouvelles **règles de nommage** interdisent ce qui était autorisé avant (un module et une procédure ne peuvent plus porter le même nom) ;
- le moteur de base de données lui-même change (Jet 2.0 → Jet 3.0).

Petite précision par rapport à mon souvenir : je situais la rupture à **Access 97** (janvier 1997), mais c'est en réalité **Access 95**, la version immédiatement postérieure à la 2.0, qui a brisé la compatibilité. Les versions d'après n'ont fait qu'en rajouter une couche : Access 97 introduit par exemple de nouveaux **mots-clés réservés** (`AddressOf`, `Enum`, `Event`, `Implements`…) qui cassent à leur tour le code qui les utilisait comme noms. Le résultat est le même : pour passer de l'application Access 2.0 aux versions modernes, il fallait **convertir le fichier puis réécrire et retester une bonne partie du code**, sans traducteur automatique fiable ni guide de migration digne de ce nom.

Pour moi, Microsoft a tout simplement **abandonné** ces clients-là. Des gens qui avaient acheté Access 2.0 et investi leur temps personnel pour améliorer leur organisation. Et même si le code avait été parfaitement « traduit », il aurait fallu **tout retester** — un coût exorbitant pour une petite structure sans équipe de développement ni filet de sécurité automatisé. Au début des années 2000, j'ai moi-même tenté de récupérer ce code et de le migrer vers une version récente d'Access. Je me suis cogné au même mur.

> Sur les difficultés réelles de conversion depuis Access 2.0, voir la fiche d'Allen Browne, [« Issues in converting from Access 2 »](http://allenbrowne.com/gotcha27.html), et la documentation Microsoft sur [l'import des bases Access 2.0 et 95](https://support.microsoft.com/en-au/office/import-access-2-0-and-access-95-databases-into-current-versions-2e9d8851-101d-4407-a881-65d06bb12aa7).

## Expérience 2 — Homelidays et les millions de lignes de Classic ASP

En 2009, j'entre comme architecte chez Homelidays. Le site repose sur **Classic ASP** : plusieurs **millions de lignes de code**. Or Classic ASP est déjà une technologie de fin de vie : sa dernière version stable date de **2000**, et Microsoft a publié son successeur, **ASP.NET**, en **2002**. Le code continue de s'exécuter, mais la technologie est morte : plus d'évolution, plus d'avenir.

Le problème, c'est qu'avec une telle masse de code, **migrer vers VB.NET ou C# représente un investissement colossal**. Impossible de tout réécrire d'un coup. Avec le directeur technique de l'époque, nous lançons une migration progressive vers **C#** : tout nouveau développement se fait en C#, et le Classic ASP est gelé en maintenance évolutive seulement. Vers 2014 (de mémoire), il restait encore environ **deux millions de lignes** de Classic ASP en production. C'est de cette période qu'est né un composant que j'ai publié en open source — à l'époque sur CodePlex, aujourd'hui sur mon GitHub : le [Homelidays Session Service](https://github.com/Yanal-Yves/homelidays-session-service), pour faire cohabiter les sessions entre l'ancien monde ASP et le nouveau monde .NET.

Et c'est précisément à ce moment-là que Microsoft nous explique que **ASP.NET Web Forms** — la technologie vers laquelle une partie du chemin de migration menait — ne sera plus vraiment développée, au profit d'**ASP.NET MVC** (sorti en 2009). Comme pour Classic ASP : le code tourne encore, mais l'investissement s'arrête. Plus tard, **ASP.NET Core** (2016) abandonnera purement et simplement Web Forms. Encore une fois, une décision unilatérale de l'éditeur qui menaçait de nous laisser le bec dans l'eau.

Cette fois pourtant, nous y avons échappé — mais pas grâce à un choix qui nous appartenait : Homelidays avait été racheté par **HomeAway**, qui a entrepris de migrer le site sur la **stack technologique du groupe**, basée sur **Java**. Autrement dit, c'est une décision d'entreprise — et non la pérennité de la technologie Microsoft — qui nous a sortis de l'impasse. Sans ce rachat et cette migration, nous serions bel et bien restés le bec dans l'eau. Tout le monde n'a pas la chance d'être adossé à un groupe capable de financer une telle bascule.

## Expérience 3 — Visual Studio et les projets d'installation MSI supprimés

Pendant des années, Visual Studio a proposé un type de projet dédié — les *Setup and Deployment Projects* (fichiers `.vdproj`) — qui permettait de générer simplement un **installeur MSI** (Windows Installer) pour ses applications : choix des fichiers à déployer, raccourcis, clés de registre, actions personnalisées… C'était une fonctionnalité **intégrée à Visual Studio**, donc déjà incluse dans la licence que l'on payait (dans mon cas, via l'abonnement **MSDN** de mon employeur), et largement utilisée.

Puis, avec **Visual Studio 2012**, Microsoft a tout simplement **retiré ce type de projet**. Visual Studio 2010 aura été la dernière version à l'inclure nativement. À la place, Microsoft renvoyait vers **InstallShield Limited Edition**, un produit tiers (Flexera) bridé : pas de support x64, pas d'installation de services Windows, pas d'actions personnalisées, pas de support VSTO… et conçu, comme son nom l'indique, pour pousser à l'achat de la version complète. Du jour au lendemain, un projet d'installation qui fonctionnait ne pouvait plus être maintenu dans la nouvelle version de l'outil sans le réécrire avec une solution tierce, payante ou limitée.

La réaction de la communauté a été massive. Sur **UserVoice** — la plateforme où Microsoft recueillait alors les retours sur Visual Studio — la demande de rétablir ce type de projet est devenue la **deuxième suggestion la plus votée** de tout le forum Visual Studio. Et pendant des années, Microsoft n'en a pas tenu compte : VS 2012 puis VS 2013 sont sortis sans support natif.

Honnêteté oblige, l'histoire ne s'arrête pas là : Microsoft a fini par céder. En **avril 2014** (version finale en **juin 2014**), l'éditeur publie une **extension** *Visual Studio Installer Projects* qui réintègre la fonctionnalité, extension qui existe d'ailleurs encore aujourd'hui (jusqu'à Visual Studio 2022). La fonction est donc bien revenue — mais seulement **quatre ans après VS 2010**, un délai pendant lequel tous ceux qui en avaient besoin ont dû bricoler des solutions de contournement.

Je n'ai moi-même appris ce revirement qu'en documentant cet article : à l'époque, je travaillais chez HomeAway et nous migrions vers la stack Java du groupe (voir l'expérience précédente), si bien que j'avais quitté ce monde et que je n'ai jamais su que Microsoft avait fini par rétablir la fonction. Que la demande la mieux classée — la **n°2** — d'une plateforme de feedback officielle mette quatre ans à être (partiellement) entendue en dit long sur le rapport de force : même très nombreux et très visibles, les utilisateurs n'ont aucune prise réelle sur les décisions de l'éditeur.

> Sources : [Visual Studio Blog, « Visual Studio Installer Projects Extension »](https://devblogs.microsoft.com/visualstudio/visual-studio-installer-projects-extension/) · [InfoQ, « Visual Studio 2013 Installer Project »](https://www.infoq.com/news/2014/04/vs2013_installer_project).

## Expérience 4 — Le dépôt-vente et la licence Windows

Il y a quelques années, ma femme monte un dépôt-vente, [La Petite Fouine](http://web.archive.org/web/20180601133011/https://lapetitefouine.com/) (lien vers une capture d'archive de 2018). Je lui développe un logiciel de gestion sous forme d'application web, en **ASP.NET MVC / Entity Framework 6 / .NET Framework 4.6**. Pour l'héberger, je loue chez Dedibox un petit serveur à une dizaine d'euros par mois (de mémoire, 10 à 15 €).

Puis un jour, sans que rien ne change techniquement — **même serveur, même version de Windows** — la facture passe à environ **45 € par mois**. La raison : Microsoft a modifié unilatéralement les conditions de licence de Windows Server, et l'hébergeur, qui répercute le coût de la licence, est contraint de facturer beaucoup plus cher.

Le serveur physique vaut toujours le même prix. C'est **uniquement la licence du système privateur** qui explose. Pour un dépôt-vente qui ne dégage même pas un SMIC, **30 € de plus par mois, ça compte énormément**. Là encore, dépendre d'un logiciel non libre, c'est dépendre du **bon vouloir du fournisseur** — sans aucune prise sur sa décision.

## Expérience 5 — Windows 7 puis Windows 10 : le gâchis imposé

Le 14 janvier 2020, Microsoft met fin au support de **Windows 7**. À ce moment-là, l'OS est encore massivement utilisé : les estimations parlent d'environ **200 millions de PC** qui tournaient encore sous Windows 7 fin 2019 (mon souvenir disait 250 millions ; le chiffre sourcé est plutôt de l'ordre de 200 millions, ce qui reste énorme).

La **Free Software Foundation** lance alors la campagne [« Upcycle Windows 7 »](https://www.fsf.org/windows/upcycle-windows-7) : elle demande à Microsoft de **libérer le code source** de Windows 7 pour qu'une communauté puisse le maintenir, et éviter ainsi de jeter à la poubelle des millions d'ordinateurs encore parfaitement fonctionnels. La pétition, qui visait 7 777 signatures, dépasse largement son objectif (plus de **13 600 signataires** à ce jour). Microsoft n'y donne aucune suite.

L'histoire se répète avec **Windows 10**, dont le support s'arrête le **14 octobre 2025** — alors qu'à cette date, le parc est encore gigantesque. Et cette fois, le problème écologique est pire : on estime à environ **400 millions** le nombre de PC qui **ne peuvent pas migrer vers Windows 11** faute de matériel compatible (l'exigence d'une puce TPM 2.0, notamment). Microsoft propose bien des mises à jour de sécurité étendues (ESU), mais payantes (de l'ordre de 30 $/an pour les particuliers).

Le résultat est double : un **gâchis écologique** considérable (des centaines de millions de machines poussées vers la benne ou vers l'obsolescence forcée) et un **non-respect des utilisateurs**, à qui l'on impose un calendrier qu'ils n'ont pas choisi. Avec un système libre, une communauté aurait pu prolonger la sécurité de ces machines aussi longtemps qu'elle le souhaite. Avec un système privateur, c'est interdit : personne d'autre que l'éditeur n'a le droit de toucher au code.

## Expérience 6 — OneDrive et nos photos de famille

Un soir, en 2024, je jette un œil sur l'ordinateur de ma femme et je vois quelque chose d'inquiétant : **toutes nos photos stockées sur OneDrive sont en train de disparaître localement** de sa machine. **400 Gio de photos de famille** qui s'effacent du disque — pas de OneDrive, juste la copie locale. Une fois l'opération terminée, à la place du dossier de photos, il ne reste qu'un **raccourci `.url`** : quand on clique dessus, ça ouvre un navigateur web. Même chose pour le dossier qui contenait la base **KeePass** que je partage avec ma femme.

Nous avions chacun un abonnement **Microsoft 365 Famille** avec 1 Tio de stockage, et **ni l'un ni l'autre n'avions atteint son quota**. Un dossier que je partageais avec elle, et qui se synchronisait localement **depuis des années**, a cessé du jour au lendemain d'être disponible hors ligne — cassant notre organisation familiale et m'obligeant à chercher une solution de remplacement en urgence (la base de mots de passe partagée n'étant soudain plus accessible localement).

Le phénomène a été largement documenté à partir de **juin 2024** : des dossiers partagés synchronisés localement se transformaient en **raccourcis internet**, renvoyant vers l'interface web au lieu d'ouvrir le contenu en local. Microsoft a fini par **reconnaître le problème** — mais en le qualifiant de **bug** (« OneDrive engineering is working on this issue »), pas de choix délibéré ; le problème a tout de même persisté de longs mois.

Et c'est précisément là que tout se joue. Que ce soit un bug ou une décision **ne change rien pour l'utilisateur** : avec un service privateur et fermé, **on ne peut ni corriger soi-même, ni confier le correctif à quelqu'un d'autre**. On subit, et on attend le bon vouloir de l'éditeur — pendant des mois, sur ses propres photos de famille et ses propres mots de passe.

> Sources : [Neowin, « Microsoft confirms OneDrive shared folders are indeed turning into internet shortcuts »](https://www.neowin.net/news/microsoft-confirms-onedrive-shared-folders-are-indeed-turning-into-internet-shortcuts/) · [Windows Latest, « Microsoft confirms Windows 11 OneDrive internet shortcut bug »](https://www.windowslatest.com/2024/07/03/microsoft-confirms-windows-11-onedrive-internet-shortcut-bug/).

## Expérience 7 — Balsamiq et le format de fichier prisonnier

Chez Prothesis Dental Solutions, mon équipe — cinq personnes, moi compris — utilisait **Balsamiq pour Google Drive** pour ses maquettes (*mockups*). Notre organisation était simple et efficace : pour chaque projet ou fonctionnalité, un dossier sur Google Drive, et dans ce dossier un fichier de maquette Balsamiq.

Du jour au lendemain — quelques semaines en réalité — **Balsamiq a déprécié sa version pour Google Drive**, nous obligeant à basculer vers sa **version Cloud**, à la **tarification différente**. Notre organisation d'équipe était cassée, et il fallait nous réorganiser à un moment où nous avions par ailleurs beaucoup de sujets urgents à traiter. Pour être juste, Balsamiq a justifié cet arrêt (effectif le **17 décembre 2024**) par des **coûts de maintenance qu'il ne pouvait plus assumer** et par sa volonté de se concentrer sur Balsamiq Cloud — une raison parfaitement légitime de son point de vue. Mais pour nous, l'effet était le même : une échéance subie, imposée de l'extérieur.

Après avoir étudié la nouvelle tarification, testé la version Cloud et découvert au passage un **bug qui rendait l'import de nos fichiers difficile**, nous avons fini par réussir la migration — mais en y perdant un temps et un argent précieux à ce moment-là. Et nous étions pris au piège : forcés de migrer à la date décidée par l'éditeur, **sans pouvoir nous tourner vers un autre outil**, car le format de fichier de Balsamiq n'est ni standard ni ouvert. Le format privateur n'enferme pas seulement le logiciel : il enferme **vos données**.

> Source : [Balsamiq, « Looking back at Balsamiq's 2024 »](https://balsamiq.com/blog/looking-back-2024/) (« We retired Balsamiq Wireframes for Google Drive and began winding down Desktop »). La page d'annonce dédiée (« What happened to Balsamiq for Google Drive? ») n'est aujourd'hui plus en ligne.

## Expérience 8 — PC Soft : changer les règles en cours de partie

Plus récemment, l'éditeur français **PC Soft** (WinDev, WebDev, WinDev Mobile) a été **racheté par le groupe canadien Volaris Group** (printemps 2025). Dans la foulée, le **modèle économique change radicalement**.

Avant : on payait une licence pour les **outils de développement**, et le **runtime était gratuit** — on déployait son application autant qu'on voulait, sur autant de postes ou de serveurs qu'on voulait, sans surcoût. Après le rachat : fin de la licence perpétuelle, passage à un **abonnement (SaaS)**, et surtout **facturation au runtime / à l'usage**.

Pour qui développe avec une petite équipe mais **déploie massivement**, le changement est brutal : une même application qui ne coûtait rien à déployer peut désormais représenter de **quelques milliers à potentiellement plusieurs millions d'euros** selon le volume de déploiement. Des modèles économiques jusque-là **viables deviennent non viables du jour au lendemain** — non pas parce que le logiciel a changé, mais parce que le propriétaire de l'outil a changé les règles en cours de partie. C'est l'illustration parfaite de la dépendance : on ne possède pas vraiment l'outil avec lequel on a construit son entreprise.

> Sur ce changement et la réaction de la communauté, voir l'article de Next, [« Les développeurs WinDev s'alarment d'une possible redevance par installation client »](https://next.ink/241694/les-developpeurs-windev-salarment-dune-possible-redevance-par-installation-client/).

## Le point commun : qui contrôle réellement le logiciel ?

Huit histoires, une même mécanique. À chaque fois, **une décision — ou une défaillance — de l'éditeur** détruit l'investissement de l'utilisateur, sans qu'il ait son mot à dire :

- Access : compatibilité cassée, code à réécrire et à retester intégralement ;
- Classic ASP / Web Forms : technologie abandonnée, sans alternative indolore ;
- Visual Studio : type de projet d'installation supprimé du jour au lendemain, demande #2 sur UserVoice ignorée quatre ans ;
- Windows Server : prix de licence qui explose, à matériel identique ;
- Windows 7 / 10 : fin de support imposée, machines jetées, refus de libérer le code ;
- OneDrive : synchronisation locale rompue, organisation familiale cassée, aucun correctif possible de notre côté ;
- Balsamiq : produit déprécié, migration forcée, données prisonnières d'un format privateur ;
- PC Soft : modèle économique retourné, viabilité détruite.

C'est exactement ce que décrit Richard Stallman : avec le logiciel privateur, **le développeur a un pouvoir sur les utilisateurs** qu'aucune bonne intention ne suffit à rendre acceptable, parce que ce pouvoir est **structurel**. L'utilisateur n'a pas le code. Il ne peut pas le corriger, le prolonger, le confier à quelqu'un d'autre. Il ne peut que subir — ou tout recommencer.

## Le logiciel libre : retrouver une marge de manœuvre

Quand on utilise un projet **libre** (et donc open source), on n'est plus prisonnier. On dispose d'options qui n'existent tout simplement pas avec le privateur :

1. **Maintenir soi-même** le projet, puisqu'on a le code source et le droit de le modifier ;
2. **Fédérer ou rejoindre une communauté** qui le maintient ;
3. **Profiter du travail des autres** : avec un peu de chance, d'autres financent et entretiennent le projet, et il ne reste qu'à contribuer — financièrement, par l'entraide entre utilisateurs, ou par le code.

Quelques illustrations, vérifiées :

- **PHP** plutôt qu'Access ou Classic ASP. Avec le recul, à la fin des années 1990, partir sur PHP aurait été un meilleur pari de pérennité. Je ne prétends pas que les montées de version de PHP aient été indolores — elles ont parfois été douloureuses — mais elles étaient **possibles**, et personne ne pouvait du jour au lendemain vous interdire de continuer.

- **net2ftp**, un client FTP en PHP que j'ai connu au tout début des années 2000. Sa dernière version stable (1.3) date de **juillet 2019**, sans changement de technologie de fond sur toute cette durée. Un outil libre peut traverser deux décennies parce que personne ne décrète sa mort. *(Je n'ai pas pu confirmer publiquement la date exacte de sa toute première version ; je la situe « au début des années 2000 » de mémoire.)*

- **Python 2 → Python 3**, l'exemple le plus parlant. Python 3.0 sort en **décembre 2008**, en cassant volontairement la compatibilité. Mais comme l'écosystème est libre et piloté par la communauté, **Python 2.7 a été maintenu en parallèle jusqu'au 1ᵉʳ janvier 2020** — plus de onze ans. (La date de fin de vie a même été repoussée de 2015 à 2020 pour laisser à tout le monde le temps de migrer.) Personne n'a été mis devant le fait accompli : chacun a pu migrer **à son rythme**. C'est exactement ce qu'aucune des huit histoires précédentes n'a permis.

La différence est là : avec le libre, une rupture reste **gérable**, parce que le pouvoir de décision n'est pas confisqué par un seul acteur.

## Et moi, dans tout ça ? Un chemin, pas une posture

Je ne voudrais pas écrire tout cela depuis un piédestal : je suis le premier pris dans ces contradictions. Ce que je décris est un **chemin**, lent et parfois fragile, pas une vertu déjà acquise.

Ce que j'ai changé, ces dernières années :

- **À titre personnel**, j'ai quitté Windows pour **Fedora Linux**. Une de mes filles est passée à Fedora elle aussi.
- **Professionnellement**, j'ai fait basculer toute mon équipe sur **TuxedoOS** (une distribution GNU/Linux). J'ai aussi tenté de faire adopter des ordinateurs Tuxedo, ce que la direction a refusé. La bascule reste fragile : dans mon groupe d'environ 60 personnes, nous ne sommes que **5 sous GNU/Linux**.
- Je me suis fixé une **règle simple** : chaque euro dépensé en logiciel privateur, je le compense par un euro **donné à un projet libre**. Concrètement, je contribue financièrement et chaque mois à des projets open source — ce qui **double** le prix réel de tout logiciel privateur que j'achète directement (je ne compte pas le logiciel embarqué, comme celui de ma voiture, dont j'ignore le coût).
- Dans mes développements, **je n'utilise plus de logiciel privateur** : Prothesis Cloud repose presque exclusivement sur du logiciel libre et open source.

Et puis il y a la contradiction que je ne veux pas cacher : **je suis salarié d'une entreprise qui développe et opère un SaaS privateur**, Prothesis Cloud. Certains me diront que, si je crois vraiment à ce que j'écris, je devrais démissionner. Au-delà du fait que j'ai besoin de ce travail pour faire vivre ma famille, je crois que c'est aussi utile de **faire bouger les mentalités de l'intérieur**. Avant, personne dans la société ne connaissait les licences libres et leurs spécificités ; on ne développait qu'avec des outils privateurs. Aujourd'hui :

- on **n'apprend plus** les technologies fermées : quand on rencontre un problème, on contribue sur les forums (mon score Stack Overflow est passé de 0 à **1 327** ces dernières années — modeste, mais mieux que zéro) ;
- on a **contribué à des projets** de l'écosystème .NET (par exemple une [amélioration fusionnée dans DocNet](https://github.com/GowenGit/docnet/pull/42)) et publié un embryon de bibliothèque en open source, [SimpleExcelExporter](https://www.nuget.org/packages/SimpleExcelExporter) (sous licence **LGPL-3.0**) ;
- on fait tourner **PostgreSQL** en production : utiliser un projet libre, c'est déjà soutenir sa popularité — et donc, indirectement, l'investissement que des acteurs comme AWS lui consacrent ;
- l'entreprise est devenue **contributrice financière de WeasyPrint**, via le collectif [CourtBouillon sur OpenCollective](https://opencollective.com/courtbouillon) — ce que l'on peut vérifier sur [son profil OpenCollective](https://opencollective.com/prothesis-dental-solutions).

On entend parfois que les entreprises « exploitent » le logiciel libre. Je crois l'inverse : **rien qu'en l'utilisant et en le faisant connaître, on sert la cause** — on élargit sa base d'utilisateurs, on remonte des bugs, on aide d'autres développeurs, on finance les mainteneurs.

Mais si ces huit histoires enseignent une chose, c'est que **migrer vers le libre après coup est lent, fragile et coûteux**. Cinq personnes sur soixante, une direction qui refuse le matériel, des années pour défaire des dépendances accumulées. D'où la vraie leçon, surtout pour celles et ceux qui débutent : **commencez libre dès le départ**. Le logiciel privateur a souvent de bonnes raisons d'attirer — il est parfois plus abouti, mieux intégré ou mieux accompagné, et c'est un choix qui peut être parfaitement rationnel sur le moment. Mais, après toutes ces années, ma conviction est qu'il reste le plus souvent bien plus facile de bâtir sur du logiciel libre dès le premier jour que de s'extraire, des années plus tard, d'un écosystème privateur dans lequel on s'est enfermé sans même s'en rendre compte.

## Conclusion

Le logiciel privateur est, au sens propre, **privateur** : il prive l'utilisateur du contrôle de son propre outil de travail. Ce n'est pas une question de méchanceté des éditeurs ; c'est une question de **structure de pouvoir**. Tant que vous ne possédez ni le code, ni le droit de le modifier et de le redistribuer, c'est l'entreprise technologique qui décide — de la compatibilité, du prix, de la licence, de la date de mort de votre logiciel — et vous n'avez aucun recours.

J'invite donc tout le monde, partout, à **se tourner vers le logiciel libre** chaque fois que c'est possible, et à privilégier des **modèles économiques qui respectent les clients et les utilisateurs** plutôt que de les piéger. Et si vous le pouvez, **commencez libre dès le départ** : s'extraire d'un écosystème privateur des années plus tard coûte bien plus cher que de ne jamais s'y enfermer. Les articles suivants de cette série exploreront concrètement ces alternatives.

## Sources et références

- Richard Stallman & FSF — [Qu'est-ce que le logiciel libre ? (les quatre libertés)](https://www.gnu.org/philosophy/free-sw.fr.html)
- Richard Stallman — [Le logiciel libre est encore plus essentiel maintenant](https://www.gnu.org/philosophy/free-software-even-more-important.fr.html)
- Sur le terme « privateur » — [Logiciel propriétaire, Wikipédia (FR)](https://fr.wikipedia.org/wiki/Logiciel_propri%C3%A9taire)
- Conversion depuis Access 2.0 — [Allen Browne, « Issues in converting from Access 2 »](http://allenbrowne.com/gotcha27.html) · [Microsoft : importer des bases Access 2.0 et 95](https://support.microsoft.com/en-au/office/import-access-2-0-and-access-95-databases-into-current-versions-2e9d8851-101d-4407-a881-65d06bb12aa7)
- Homelidays Session Service — [dépôt GitHub](https://github.com/Yanal-Yves/homelidays-session-service)
- Visual Studio, suppression puis retour des projets d'installation — [Visual Studio Blog, « Visual Studio Installer Projects Extension »](https://devblogs.microsoft.com/visualstudio/visual-studio-installer-projects-extension/) · [InfoQ, « Visual Studio 2013 Installer Project »](https://www.infoq.com/news/2014/04/vs2013_installer_project) · [InstallShield LE et Visual Studio 2012 — support x64](https://gordon.byers.me/misc/installshield-le-visual-studio-2012-x64-support/)
- Fin de support de Windows 7 et parc résiduel — [PC Gamer, « Over 100 million PCs still run Windows 7… »](https://www.pcgamer.com/over-100-million-pcs-still-run-windows-7-a-year-after-microsoft-ended-support/)
- Campagne FSF — [« Upcycle Windows 7 »](https://www.fsf.org/windows/upcycle-windows-7)
- Fin de support de Windows 10 — [Microsoft Support : Windows 10 support has ended on October 14, 2025](https://support.microsoft.com/en-us/windows/windows-10-support-has-ended-on-october-14-2025-2ca8b313-1946-43d3-b55c-2b95b107f281)
- PC Soft / WinDev, rachat et nouveau modèle — [Next, « Les développeurs WinDev s'alarment… »](https://next.ink/241694/les-developpeurs-windev-salarment-dune-possible-redevance-par-installation-client/) · [Programmez, « PC Soft : après le rachat… »](https://www.programmez.com/actualites/pc-soft-apres-le-rachat-une-grogne-des-developpeurs-windev-39590)
- OneDrive, dossiers partagés transformés en raccourcis web — [Neowin, « Microsoft confirms OneDrive shared folders are indeed turning into internet shortcuts »](https://www.neowin.net/news/microsoft-confirms-onedrive-shared-folders-are-indeed-turning-into-internet-shortcuts/) · [Windows Latest, « Microsoft confirms Windows 11 OneDrive internet shortcut bug »](https://www.windowslatest.com/2024/07/03/microsoft-confirms-windows-11-onedrive-internet-shortcut-bug/)
- Balsamiq pour Google Drive, arrêt et migration — [Balsamiq, « Looking back at Balsamiq's 2024 »](https://balsamiq.com/blog/looking-back-2024/) (la page d'annonce dédiée n'est plus en ligne)
- net2ftp — [Wikipédia (EN)](https://en.wikipedia.org/wiki/Net2ftp)
- Fin de vie de Python 2 — [Python.org, « Sunsetting Python 2 »](https://www.python.org/doc/sunset-python-2/) · [PEP 373 — Python 2.7 Release Schedule](https://peps.python.org/pep-0373/)
- Mes contributions citées — [DocNet, PR #42 (fusion de PDF multiples)](https://github.com/GowenGit/docnet/pull/42) · [SimpleExcelExporter (NuGet, LGPL-3.0)](https://www.nuget.org/packages/SimpleExcelExporter) · [WeasyPrint / CourtBouillon sur OpenCollective](https://opencollective.com/courtbouillon) · [profil OpenCollective de Prothesis Dental Solutions](https://opencollective.com/prothesis-dental-solutions)
