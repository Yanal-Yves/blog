---
title: "Effacer vraiment une clé USB : pourquoi supprimer et formater ne suffisent pas"
description: "Effacement sécurisé d'une clé USB sous Linux : pourquoi la suppression, le formatage et shred échouent sur de la mémoire flash, comment écraser le périphérique avec dd et vérifier le résultat avec cmp."
draft: false
---

{{< toc >}}

Vous avez copié des fichiers sensibles sur une clé USB, vous les avez supprimés, et vous savez confusément que « supprimer n'efface pas vraiment ». C'est exact — mais la raison réelle est plus intéressante que l'explication habituelle, et la plupart des réflexes hérités du disque dur sont **contre-productifs** sur de la mémoire flash.

Cet article explique ce qui se passe réellement dans une clé USB, pourquoi `shred` sur un fichier ne sert à rien, comment procéder correctement, comment **vérifier** le résultat, et surtout où s'arrête la garantie.

> ⚠️ **Avertissement** : les commandes de cet article détruisent l'intégralité du contenu d'un périphérique, sans confirmation. Une erreur de nom (`sda` au lieu de `sdb`) peut écraser un disque système. Identifiez votre clé avec certitude avant de lancer quoi que ce soit — la méthode est détaillée dans [Identifier sa clé USB et y écrire une ISO sous Linux]({{< relref "/gnu-linux/ecrire-iso-usb-dd" >}}).

---

## 1. Ce que « supprimer » et « formater » font réellement

Supprimer un fichier ne touche pas à son contenu. Le système de fichiers retire l'entrée du répertoire et marque les blocs comme réutilisables ; les octets restent en place jusqu'à ce que quelque chose les réécrive. C'est le mécanisme bien connu, et c'est ce qui permet aux outils de récupération de fonctionner.

Ce qui est moins connu : **formater n'efface rien non plus.** Si vous avez répondu à un incident en refaisant la table de partition et le système de fichiers, par exemple :

```bash
sudo sgdisk --zap-all /dev/sdX
sudo parted -s /dev/sdX mklabel msdos mkpart primary 1MiB 100%
sudo mkfs.exfat -n MACLE /dev/sdX1
```

… vous n'avez écrit que quelques mégaoctets de métadonnées au début du périphérique. Les dizaines de gigaoctets de contenu précédent sont intacts. Un outil de *file carving* comme PhotoRec, `foremost` ou `scalpel` ignore complètement le système de fichiers : il balaie le périphérique brut à la recherche de signatures de début de fichier (JPEG, PDF, ZIP…) et reconstruit ce qu'il trouve. Un formatage rapide ne le gêne pas du tout.

Autrement dit : après un formatage, vos données sensibles sont toujours là, et récupérables avec un logiciel gratuit.

---

## 2. Pourquoi une clé USB n'est pas un disque dur

Ici commencent les différences qui changent la méthode.

### On ne peut pas réécrire par-dessus

La mémoire NAND a une contrainte physique : une cellule programmée doit être **effacée** avant de pouvoir être réécrite, et l'effacement ne fonctionne qu'à la granularité d'un **bloc** entier — typiquement de 512 Kio à plusieurs mégaoctets. L'écriture, elle, se fait par **page**, de 4 à 16 Kio. Modifier 4 Kio « sur place » exigerait donc d'effacer les quelques mégaoctets qui les entourent.

### La couche de traduction masque tout

Le contrôleur contourne cette contrainte avec la **FTL** (*Flash Translation Layer*), une table de correspondance entre les adresses logiques que voit le système (les LBA) et les pages physiques réelles. Quand vous écrivez sur l'adresse logique X :

1. le contrôleur écrit la nouvelle version dans une page **vierge**, prise dans un réservoir de blocs pré-effacés ;
2. il met à jour sa table pour que X pointe désormais vers cette nouvelle page ;
3. il marque l'ancienne page **« invalide »** — et s'arrête là. **Elle n'est pas effacée.**

Le contenu précédent reste donc physiquement présent dans le silicium, dans une page qui n'est plus référencée par aucune adresse logique. Ces pages invalides ne sont recyclées que plus tard, par le *garbage collector* du contrôleur, quand le réservoir de blocs libres s'épuise.

Deux mécanismes supplémentaires s'ajoutent, et ils comptent pour la suite :

- Le **wear leveling** (répartition d'usure) répartit les écritures pour ne pas user toujours les mêmes cellules. Le contrôleur choisit donc préférentiellement des blocs peu sollicités.
- L'**over-provisioning** : la puce contient plus de NAND que la capacité annoncée. Une clé de 64 Go expose 61 530 439 680 octets, soit 57,3 Gio, alors que la puce brute est très probablement de 64 Gio. Il existe donc environ 10 % de blocs physiques — de l'ordre de 6 Gio — que la FTL ne fait correspondre à **aucune** adresse logique.

Retenez ce dernier point : il existe, dans votre clé, de la mémoire que vous ne pouvez pas adresser.

---

## 3. Pourquoi effacer fichier par fichier ne fonctionne pas

Le réflexe naturel est d'utiliser `shred` sur les fichiers concernés :

```bash
shred -u fichier-sensible.pdf   # inefficace sur de la mémoire flash
```

Sur un disque dur, cela fonctionne : la réécriture se fait au même endroit physique. Sur une clé USB, `shred` écrit sur les mêmes **adresses logiques**, mais le contrôleur redirige chaque écriture vers des pages physiques **différentes**. L'ancienne version du fichier reste intacte dans les pages invalidées. Vous avez consommé des cycles d'écriture sans rien effacer.

Ce n'est pas une supposition théorique. L'étude de référence sur le sujet — [Wei, Grupp, Spada et Swanson, *Reliably Erasing Data From Flash-Based Solid State Drives*, USENIX FAST '11](https://www.usenix.org/conference/fast11/reliably-erasing-data-flash-based-solid-state-drives) (UC San Diego) — a mesuré exactement cela. Les chercheurs ont construit un banc matériel capable de lire le NAND brut **en contournant la FTL**, donc de voir ce qui subsiste réellement dans les puces.

Ils ont testé treize protocoles d'effacement de fichier individuel, dont plusieurs normes gouvernementales. Résultat : **aucun n'a réussi**. Sur les SSD, entre 4 % et 75 % du contenu des fichiers subsistait. Sur les clés USB, entre 0,57 % et 84,9 %. Quelques valeurs pour la seule colonne « clé USB » :

| Méthode appliquée à un fichier | Données subsistantes (clé USB) |
|---|---|
| Suppression par le système de fichiers | 99,4 % |
| Gutmann (35 passes) | 71,7 % |
| Gutmann « Lite » | 84,9 % |
| US Air Force 5020 | 0,0 – 63,5 % |
| British HMG IS5 (Enhanced) | 0,0 – 34,7 % |

Le chiffre le plus parlant est celui de Gutmann : **35 passes de réécriture sur un fichier laissent 71,7 % de son contenu sur la clé.** L'effort est considérable, le résultat quasi nul.

> **Conclusion pratique** : l'effacement sélectif d'un fichier est hors de portée d'un outil logiciel sur de la mémoire flash. La seule approche qui fonctionne est d'écraser le **périphérique entier**.

---

## 4. Ce que votre clé ne sait pas faire

Avant d'écraser, il faut écarter deux raccourcis souvent recommandés. Sur une clé USB, ils sont généralement indisponibles — et il vaut mieux le vérifier que le supposer.

### TRIM / discard

La commande TRIM permet d'indiquer au contrôleur qu'une plage d'adresses n'est plus utilisée, ce qui déclenche l'effacement physique. Vérifiez le support :

```bash
lsblk -D /dev/sdX
```

```
NAME   DISC-ALN DISC-GRAN DISC-MAX DISC-ZERO
sdX           0        0B       0B         0
```

`DISC-GRAN` et `DISC-MAX` à `0B` signifient : **pas de support**. `blkdiscard` et `fstrim` échoueront. C'est le cas normal, car le pont USB Mass Storage ne transmet pas les commandes UNMAP du protocole SCSI. C'était le raccourci le plus propre ; il est écarté.

### Secure erase ATA

`hdparm --security-erase` s'adresse à la couche ATA. Une clé USB native n'en a pas : elle se présente en SCSI par-dessus USB. Il n'y a littéralement rien à qui envoyer la commande. (C'est différent d'un SSD dans un boîtier USB-SATA, où le pont traduit parfois les commandes ATA.)

### Et quand ces commandes existent, elles mentent

C'est le second enseignement marquant de l'étude FAST '11. Sur douze disques collectés, huit annonçaient prendre en charge le jeu de commandes ATA SECURITY. Sur les sept qui étaient vérifiables, **quatre seulement exécutaient `ERASE UNIT` correctement**. Le cas le plus inquiétant, cité par les auteurs :

> *Drive B's behavior is the most disturbing: it reported that sanitization was successful, but all the data remained intact. In fact, the filesystem was still mountable.*

Un disque qui annonce « effacement réussi » alors que le système de fichiers est toujours montable. La leçon générale vaut au-delà du flash : **une commande d'effacement dont on ne vérifie pas le résultat ne vaut rien.**

> **Note sur le démagnétiseur** : sans objet ici. Les auteurs ont soumis des puces flash à un champ tournant de 14 000 gauss plus un champ perpendiculaire alternatif de 8 000 gauss, avec un appareil évalué pour la NSA. Verdict : *« In all cases, the data remained intact. »* Le stockage flash n'est pas magnétique.

---

## 5. Écraser le périphérique entier

C'est la méthode qui fonctionne. Le principe : en écrivant sur **toute** la plage d'adresses, on force le contrôleur à consommer la totalité de son réservoir de blocs libres, ce qui oblige le *garbage collector* à effacer les blocs invalides pour se réapprovisionner.

### Identifier et démonter

Identifiez la clé sans ambiguïté, puis démontez ses partitions — on démonte la **partition**, pas le disque :

```bash
lsblk -o NAME,SIZE,TYPE,TRAN,MODEL,MOUNTPOINTS
sudo umount /dev/sdX1
```

Vérifiez que la colonne `MOUNTPOINTS` est bien vide avant de continuer.

### Les deux passes

Remplacez `sdX` par le nom réel de **votre** clé, et notez qu'on écrit sur le **disque entier** (`sdX`), pas sur une partition (`sdX1`) :

```bash
# Passe 1 — données aléatoires sur toute la capacité
sudo dd if=/dev/urandom of=/dev/sdX bs=4M status=progress conv=fsync

# Passe 2 — zéros sur toute la capacité
sudo dd if=/dev/zero of=/dev/sdX bs=4M status=progress conv=fsync
```

| Option | Rôle |
|--------|------|
| `if=/dev/urandom` | Source de données aléatoires. Voir ci-dessous pourquoi l'aléatoire et pas des zéros. |
| `of=/dev/sdX` | Le **disque entier**. Écrire sur `sdX1` laisserait intacts le secteur de démarrage et tout l'espace hors partition. |
| `bs=4M` | Blocs de 4 Mo. Sans cette option, `dd` travaille par blocs de 512 octets — beaucoup plus lent. 4 Mo tombe aussi dans l'ordre de grandeur du bloc d'effacement NAND, ce qui évite les écritures partielles de bloc. |
| `status=progress` | Affiche la progression et le débit réel. |
| `conv=fsync` | Force l'écriture effective sur la clé avant de rendre la main. Sans cela, `dd` peut se terminer alors que des mégaoctets sont encore dans le cache du noyau. |

Comptez **20 à 30 minutes par passe** pour une clé de 64 Go : ces clés écrivent souvent 30 à 60 Mo/s en soutenu, la mention « USB 3.2 Gen 1 » qualifiant le bus et non le NAND. `status=progress` vous donnera le débit réel au bout de quelques secondes.

### Pourquoi de l'aléatoire à la première passe

Parce que certains contrôleurs compressent ou dédupliquent les données à la volée. Une passe de zéros peut alors être enregistrée comme une simple annotation « cette plage est à zéro » dans les métadonnées, **sans consommer de blocs physiques**. Aucune pression sur le réservoir libre, aucun recyclage déclenché, et vos anciennes données intactes.

Des données aléatoires sont incompressibles : le contrôleur est obligé de faire de vraies écritures. C'est la passe 1 qui produit l'effet utile ; la passe 2 en zéros sert surtout à rendre le résultat **vérifiable**.

### Pourquoi deux passes, et pas trente-cinq

L'argument du multi-passe vient du disque dur : les normes historiques (DoD 5220.22-M, les 35 passes de Gutmann) visaient la **rémanence magnétique**, l'idée qu'une aimantation résiduelle en bord de piste laisserait deviner le bit précédent. Cela n'a jamais été démontré sur les densités modernes, et le NIST 800-88 considère depuis 2006 qu'une passe suffit sur un disque magnétique.

**Sur du NAND, cet argument n'existe même pas** : une cellule est effacée ou programmée, il n'y a pas d'écho analogique du niveau de charge antérieur. Le multi-passe sur flash a une justification entièrement différente — couvrir le **réservoir de blocs physiques**, pas vaincre la physique.

L'intérêt de la seconde passe est donc précis. À la fin de la passe 1, les blocs qui ont échappé au recyclage ont un compteur d'effacements resté bas : si le contrôleur pratique le wear leveling *statique*, ils deviennent les candidats prioritaires de la passe suivante. La passe 2 a donc une bonne chance de les atteindre.

Une bonne chance seulement — la section 8 explique pourquoi il ne faut pas en promettre davantage.

---

## 6. Vérifier l'effacement

Ne vous fiez pas au message final de `dd`. Vérifiez.

L'astuce consiste à comparer la clé à un flux infini de zéros :

```bash
sudo cmp /dev/zero /dev/sdX
```

`cmp` compare deux fichiers **octet par octet** et signale la première différence — contrairement à `diff`, qui raisonne en lignes de texte. `/dev/zero` produit des octets nuls à l'infini ; `/dev/sdX` a une fin. Deux issues sont donc possibles.

**Si tout est à zéro**, `cmp` épuise la clé avant le flux et signale la fin du plus court :

```
cmp: EOF on /dev/sdX after byte 61530439680
```

C'est le résultat attendu, et il vérifie deux choses à la fois : tous les octets étaient nuls, **et** ce nombre correspond exactement à la taille du périphérique — donc `dd` est bien allé jusqu'au dernier secteur.

**S'il subsiste un octet non nul**, `cmp` s'arrête et donne sa position :

```
/dev/zero /dev/sdX differ: byte 500001, line 1
```

### Le piège du code retour

`cmp` renvoie **1 dans les deux cas**. Il ne renvoie 0 que si les fichiers sont identiques *y compris en longueur* — or `/dev/zero` est infini, donc la longueur diffère toujours. Par conséquent :

```bash
sudo cmp /dev/zero /dev/sdX && echo "OK"   # n'affichera JAMAIS "OK"
```

Ne vous fiez qu'au message. Pour un test scriptable :

```bash
sudo cmp /dev/zero /dev/sdX 2>&1 | grep -q 'EOF on /dev/sdX' \
  && echo "EFFACEMENT OK" || echo "RESIDU DETECTE"
```

### Localiser un résidu

L'option `-l` liste **tous** les octets non nuls au lieu du premier seulement :

```bash
sudo cmp -l /dev/zero /dev/sdX | head -20
```

Le format est `position  valeur_octale_fichier1  valeur_octale_fichier2`. Attention, `cmp` compte les octets **à partir de 1**, pas de 0 :

```
offset réel = position_rapportée - 1
secteur     = (position_rapportée - 1) / 512
```

Le diagnostic dépend de l'endroit : une différence tout à la fin suggère une dernière écriture partielle ; une différence en pleine zone utile signifie que `dd` a été interrompu — relancez-le.

Contrôle complémentaire, qui ne remplace pas `cmp` mais attrape d'autres cas :

```bash
sudo strings -n 8 /dev/sdX | head
```

Cette commande ne doit rien renvoyer. Comptez 8 à 15 minutes pour `cmp` : il lit l'intégralité du périphérique, mais la lecture est plus rapide que l'écriture. Ces deux opérations sont strictement en lecture, donc sans risque.

---

## 7. Reconstruire une clé utilisable

Après l'effacement, la clé n'a plus ni table de partition ni système de fichiers. Pour un usage courant, exFAT est le meilleur choix : lisible sous Linux, Windows et macOS, et sans la limite de 4 Go par fichier de FAT32.

```bash
sudo parted -s /dev/sdX mklabel msdos mkpart primary 1MiB 100%
sudo mkfs.exfat -n MACLE /dev/sdX1
```

> **Note** : si votre clé n'exposait qu'une partition de 32 Gio sur une capacité de 64 Go, ce n'était pas un défaut matériel. L'outil de formatage intégré de Windows refuse de créer une partition FAT32 au-delà de 32 Gio ; beaucoup de clés sortent d'usine ainsi. La commande ci-dessus récupère la totalité de l'espace.

---

## 8. Ce que cette méthode ne garantit pas

C'est la section la plus importante, et celle que la plupart des tutoriels omettent.

### Ce qui est acquis

La passe 1 détruit **tout ce qui est atteignable par l'interface normale du périphérique**. C'est une garantie forte, et `cmp` vous la prouve. Aucun logiciel de récupération ne peut lire ce qui subsiste éventuellement, pour une raison structurelle : la FTL ne fait plus correspondre aucune adresse logique à ces blocs. Il n'existe pas d'adresse à demander à la clé pour y accéder. C'est vrai de `dd`, de PhotoRec, de TestDisk et de n'importe quel outil forensique commercial.

Pour la menace réaliste — quelqu'un trouve ou récupère votre clé — le problème est réglé.

### Ce qui ne l'est pas

Les blocs sortis de la circulation restent hors d'atteinte de la réécriture : blocs marqués défectueux par le contrôleur, et zone d'over-provisioning. Ils ne sont lisibles que par *chip-off* — dessoudage des puces et lecture directe du NAND avec un équipement spécialisé.

Et surtout, **il n'existe pas de formule** donnant le résidu après N passes. Je serais tenté d'écrire que si la passe 1 laisse une fraction *f* de blocs non recyclés, la passe 2 ramène le résidu à *f²*. Ce serait faux : ce calcul suppose que le choix des blocs à la passe 2 est indépendant de ceux qui ont survécu à la passe 1. Or il n'est pas indépendant, et dans les deux sens :

- avec du wear leveling **statique**, le contrôleur cible *préférentiellement* les blocs peu usés, donc les survivants : la couverture est **meilleure** que ce calcul ;
- avec du wear leveling seulement **dynamique** — cas fréquent sur les contrôleurs de clés bon marché — les blocs non mappés ne sont **jamais** touchés. Répéter la passe balaie le même ensemble physique, et le résidu reste identique indéfiniment. Le gain est alors **nul**.

Le firmware qui décide est propriétaire, non documenté, et varie d'une révision de production à l'autre pour une même référence commerciale.

### Ce que la mesure montre

La table 2 de l'étude FAST '11 donne le nombre de passes nécessaires pour effacer réellement huit disques non chiffrants :

| Disque | Passes nécessaires |
|---|---|
| B | 1 |
| C, D, F, J, K, L | 2 |
| **A** | **plus de 20** |

Les auteurs précisent :

> *In most cases, overwriting the entire disk twice was sufficient to sanitize the disk, regardless of the previous state of the drive. There were three exceptions: about 1% (1 GB) of the data remained on Drive A after twenty passes.*

**Un gigaoctet encore présent après vingt passes complètes.** La distribution n'est donc pas une décroissance régulière : soit deux passes suffisent, soit le périphérique résiste à vingt. D'où le verdict des auteurs :

> *Overall, the results for overwriting are poor: while overwriting appears to be effective in some cases across a wide range of drives, it is clearly not universally reliable.*

Deux réserves d'honnêteté sur ces chiffres : cette table porte sur des **SSD SATA**, pas sur des clés USB (l'étude ne teste les clés USB que sur l'effacement fichier par fichier), et elle date de **2011**, sur du SLC et du MLC. Transposer à une clé TLC actuelle est une extrapolation raisonnable, pas une déduction.

### Ce qu'il faut en retenir

La deuxième passe est une **bonne pratique empirique**, pas une garantie chiffrable. Elle coûte vingt minutes et une fraction négligeable de la durée de vie de la clé (voir l'annexe), donc faites-la. Mais ne promettez pas de pourcentage, et surtout : elle ne réduit que la surface d'attaque du chip-off, puisque le reste était déjà inatteignable par voie logicielle.

Si votre modèle de menace inclut un laboratoire capable de dessouder les puces, ni la troisième passe ni la trente-cinquième ne changeront le cas du disque A. Les seules réponses sont le chiffrement dès le départ, ou la **destruction physique** des puces — pas seulement du boîtier plastique. Une clé neuve coûte moins cher que le risque.

Enfin, pensez aux copies ailleurs : les fichiers ont transité par votre machine. Vérifiez la corbeille, `~/.local/share/recently-used.xbel`, les miniatures dans `~/.cache/thumbnails/`, et vos sauvegardes.

---

## 9. La vraie solution : chiffrer dès le départ

C'est le correctif structurel, et c'est aussi la recommandation des auteurs de l'étude. Si la clé est chiffrée depuis le premier octet, « effacer » revient à détruire la clé de chiffrement : opération instantanée, sans dépendre du comportement de la FTL, puisque ce qui subsiste dans le NAND est du texte chiffré inexploitable.

**Usage Linux uniquement** — LUKS, avec `cryptsetup` :

```bash
sudo cryptsetup luksFormat /dev/sdX1
sudo cryptsetup open /dev/sdX1 macle
sudo mkfs.exfat -n MACLE /dev/mapper/macle
sudo cryptsetup close macle
```

Les environnements de bureau (GNOME, KDE) demandent ensuite la phrase de passe automatiquement au branchement.

**Usage multi-systèmes** — VeraCrypt, en conteneur de fichiers ou en volume complet, avec le mode *traveler disk* pour l'utiliser sans installation sur la machine hôte.

Dans les deux cas, la règle est la même : chiffrer **avant** d'y mettre quoi que ce soit de sensible. Chiffrer après coup laisse les anciennes données en clair dans les blocs invalidés.

---

## 10. Annexe : mesurer la géométrie physique

Puisque la taille du bloc d'effacement conditionne le comportement du contrôleur, peut-on la connaître ? Depuis l'hôte, **non**. La FTL est précisément là pour masquer la géométrie physique.

```bash
for f in logical_block_size physical_block_size optimal_io_size \
         discard_granularity rotational; do
  printf "%-22s = %s\n" "$f" "$(cat /sys/block/sdX/queue/$f)"
done
```

Sortie typique sur une clé USB :

```
logical_block_size     = 512
physical_block_size    = 512
optimal_io_size        = 0
discard_granularity    = 0
rotational             = 1
```

`physical_block_size = 512` n'a **aucun rapport** avec le bloc d'effacement NAND : c'est la taille de bloc que le pont USB déclare en SCSI, une pure convention. Et `rotational = 1` est révélateur — le noyau croit parler à un disque à plateaux. L'hôte ne sait rien.

Ce qui fonctionne, c'est l'inférence par chronométrage : [flashbench](https://github.com/bradfa/flashbench), écrit par Arnd Bergmann pour l'enquête Linaro sur les mémoires flash. L'outil effectue de courtes lectures de part et d'autre de frontières d'alignement de tailles croissantes et mesure les latences ; un décrochage révèle une frontière de bloc d'effacement. Le contexte est expliqué dans [cet article de LWN](https://lwn.net/Articles/428584/).

```bash
flashbench -a /dev/sdX     # mode -a : lecture seule, sans danger
```

> ⚠️ Le mode `-a` est non destructif, mais d'autres modes de `flashbench` (`--open-au`, notamment) **écrivent** sur le périphérique.

Un dernier piège conceptuel : même en lisant la référence de la puce sur le silicium, la taille de bloc de sa fiche technique n'est pas la granularité d'effacement du *garbage collector*. Les contrôleurs effacent par **superblocs**, en groupant plusieurs blocs répartis sur plusieurs plans et plusieurs puces pour paralléliser. L'unité réelle est un multiple non documenté.

Ordres de grandeur usuels, à prendre comme tels :

| Unité | Valeur typique |
|---|---|
| Page (unité d'écriture) | 4 à 16 Kio |
| Bloc (unité d'effacement) | 512 Kio à 8 Mio |
| Superbloc effectif | souvent 4 à 24 Mio en 3D TLC |

---

## 11. Annexe : combien ça coûte à la clé

On lit souvent qu'il faut limiter les passes pour ne pas user la mémoire. Vérifions.

Les fabricants de clés USB grand public ne publient pas d'endurance en cycles P/E — leurs fiches annoncent une durée de garantie. Il faut donc raisonner par type de cellule, avec des fourchettes issues de la littérature industrielle :

| Type | Bits/cellule | Cycles P/E typiques |
|---|---|---|
| SLC | 1 | 50 000 – 100 000 |
| MLC | 2 | 3 000 – 10 000 |
| **TLC** | **3** | **1 000 – 3 000** |
| QLC | 4 | 100 – 1 000 |

Une clé de 64 Go actuelle est en TLC, souvent avec du NAND de second choix : les puces qui échouent au tri qualité SSD sont réorientées vers les clés et les cartes mémoire. Plusieurs sources situent le flash de ces produits autour de 700 cycles. Retenez un ordre de grandeur de 500 à 1 500 cycles, en gardant en tête que c'est une estimation et non une spécification.

Deux passes complètes consomment environ **2 cycles P/E** : sur une écriture séquentielle intégrale, l'amplification d'écriture est proche de 1, donc sans multiplicateur caché.

| Budget d'endurance | Coût de 2 passes | Coût de 35 passes |
|---|---|---|
| 700 cycles (pessimiste) | 0,29 % | 5,0 % |
| 3 000 cycles (optimiste) | 0,07 % | 1,2 % |

**L'usure n'est donc pas un argument.** Même le protocole Gutmann complet ne consomme que quelques pourcents de la durée de vie. Le vrai argument contre le multi-passe n'est pas qu'il abîme la clé, c'est qu'il **ne fonctionne pas** — le disque A résiste à vingt passes — et qu'il coûte vingt minutes par passe.

---

## Aide-mémoire (résumé)

```bash
# 1. Identifier la clé et vérifier l'absence de TRIM
lsblk -o NAME,SIZE,TYPE,TRAN,MODEL,MOUNTPOINTS
lsblk -D /dev/sdX

# 2. Démonter toutes les partitions
sudo umount /dev/sdX1

# 3. Passe 1 : aléatoire sur le disque entier (~20-30 min)
sudo dd if=/dev/urandom of=/dev/sdX bs=4M status=progress conv=fsync

# 4. Passe 2 : zéros, pour rendre le résultat vérifiable (~20-30 min)
sudo dd if=/dev/zero of=/dev/sdX bs=4M status=progress conv=fsync

# 5. Vérifier — attendu : "EOF on /dev/sdX after byte <taille exacte>"
#    (le code retour vaut 1 même en cas de succès : fiez-vous au message)
sudo cmp /dev/zero /dev/sdX
sudo strings -n 8 /dev/sdX | head     # doit ne rien renvoyer

# 6. Reconstruire une clé utilisable
sudo parted -s /dev/sdX mklabel msdos mkpart primary 1MiB 100%
sudo mkfs.exfat -n MACLE /dev/sdX1
```

Et pour la prochaine clé : chiffrez-la avant d'y copier quoi que ce soit de sensible. C'est la seule méthode dont la garantie ne dépend pas d'un firmware propriétaire.

---

## Sources

- [Michael Wei, Laura M. Grupp, Frederick E. Spada, Steven Swanson, *Reliably Erasing Data From Flash-Based Solid State Drives*, USENIX FAST '11](https://www.usenix.org/conference/fast11/reliably-erasing-data-flash-based-solid-state-drives) — l'étude de référence, avec lecture du NAND brut en contournant la FTL
- [flashbench](https://github.com/bradfa/flashbench) — inférence de la géométrie physique par chronométrage
- [Optimizing Linux with cheap flash drives](https://lwn.net/Articles/428584/) — LWN.net, contexte sur flashbench et la géométrie des mémoires flash
- [Solid state drive (SSD) forensics](https://forensics.wiki/solid_state_drive_(ssd)_forensics/) — forensics.wiki
- [Understanding NAND endurance](https://www.simms.co.uk/tech-talk/understanding-nand-endurance/) — SIMMS
