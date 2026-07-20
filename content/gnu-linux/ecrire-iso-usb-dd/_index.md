---
title: "Identifier sa clé USB et y écrire une ISO sous Linux"
description: "Guide pratique pour identifier sans risque le périphérique d'une clé USB sous Linux (lsblk, journalctl) et y écrire une ISO d'installation avec dd."
draft: false
---

{{< toc >}}

Guide pour Linux (testé sur TuxedoOS, valable sur toute distribution récente). La procédure fonctionne pour n'importe quelle ISO d'installation : Debian, Ubuntu, Fedora, Proxmox VE, Arch, etc.

> ⚠️ **Avertissement** : `dd` écrit sans demander confirmation et détruit tout le contenu du périphérique cible. Une erreur de nom (`sda` au lieu de `sdb`) peut écraser un disque système. Vérifiez **deux fois** avant de lancer.

---

## 1. Identifier le périphérique de la clé USB

### Méthode principale : `lsblk`

Branchez la clé, puis lancez :

```bash
lsblk -o NAME,SIZE,TYPE,TRAN,MODEL,MOUNTPOINTS
```

Repérez la ligne correspondant à votre clé grâce à trois indices :

- **`TRAN`** affiche `usb` → c'est un périphérique USB (le disque interne affiche `nvme` ou `sata`).
- **`SIZE`** correspond à la capacité annoncée de la clé (une clé de 64 Go apparaît vers 57–58 Go).
- **`MODEL`** affiche souvent le nom du fabricant (ex. `USB DISK 3.0`).

Exemple de sortie :

```
NAME          SIZE TYPE TRAN   MODEL                   MOUNTPOINTS
sda          57,8G disk usb    USB DISK 3.0
└─sda1       57,8G part                                /media/user/DATA
nvme0n1     953,9G disk nvme   SKHynix_HFS001TEM9X169N
├─nvme0n1p1   200M part nvme                           /boot/efi
└─nvme0n1p5 476,8G part nvme                           /
```

Ici la clé est **`/dev/sda`** (57,8 Go, `usb`, `USB DISK 3.0`). Le disque système `nvme0n1` est à ne surtout pas toucher.

> **Note** : les lecteurs multi-cartes intégrés affichent parfois plusieurs périphériques à `0B` (`sdb`, `sdc`…). Ce sont des slots vides, à ignorer.

### Méthode infaillible : voir le nom apparaître en direct

Si un doute subsiste, laissez le noyau vous dire quel nom il attribue au moment exact du branchement.

Clé **débranchée**, lancez :

```bash
journalctl -kf
```

Puis **branchez** la clé. Les lignes défilent en direct et vous verrez apparaître le périphérique attribué, par exemple :

```
juil. 20 04:57:43 tuxedo-os kernel: sd 1:0:0:0: [sda] Attached SCSI removable disk
```

Le nom entre crochets (`[sda]`) est celui à utiliser. `Ctrl+C` pour quitter.

**Que fait `journalctl -kf` ?** `journalctl` lit le **journal de systemd**, le système centralisé de logs des distributions modernes (dont TuxedoOS et Fedora). Là où on avait historiquement des fichiers texte épars dans `/var/log/`, systemd collecte tout dans un journal binaire indexé qu'on interroge avec cette commande. Les deux paramètres :

- **`-k`** (`--dmesg`) filtre pour ne montrer que les messages du **noyau** (kernel), comme la commande `dmesg`. C'est le noyau qui détecte le matériel USB et attribue le nom de périphérique (`sda`, `sdb`…), donc c'est exactement ce qu'on veut observer.
- **`-f`** (`--follow`) passe en mode **suivi temps réel** : la commande reste ouverte et affiche chaque nouvelle ligne au fur et à mesure, comme un `tail -f`. C'est ce qui permet de voir la ligne apparaître à l'instant précis du branchement.

> Selon la configuration, lire le journal noyau peut demander les droits. Si la sortie est vide ou tronquée, préfixez par `sudo` : `sudo journalctl -kf`.

Variante équivalente juste après le branchement :

```bash
sudo dmesg | tail -20
```

---

## 2. Démonter la clé (sans la débrancher)

Si une partition de la clé est montée (colonne `MOUNTPOINTS` non vide), démontez-la. On démonte la **partition** (`sda1`), pas le disque entier :

```bash
sudo umount /dev/sda1
```

Répétez pour chaque partition montée (`sda2`, etc.) le cas échéant.

---

## 3. Vérifier le chemin de l'ISO

Confirmez que le fichier existe avant de lancer l'écriture :

```bash
ls -lh ~/Downloads/mon-image.iso
```

Adaptez le chemin et le nom à votre fichier.

---

## 4. Écrire l'ISO avec `dd`

Remplacez `sda` par le nom réel de **votre** clé (identifié à l'étape 1) et le nom du fichier par votre ISO :

```bash
sudo dd if=~/Downloads/mon-image.iso of=/dev/sda bs=4M status=progress oflag=direct conv=fsync
```

### Signification des options

| Option | Rôle |
|--------|------|
| `if=` | *input file* — l'ISO source. |
| `of=/dev/sda` | *output file* — le **disque entier**, pas une partition (`sda`, pas `sda1`). La plupart des ISO d'installation modernes sont des images hybrides (« isohybrid ») qui contiennent leur propre table de partitions : elles s'écrivent donc sur le disque entier. |
| `bs=4M` | Taille de bloc de 4 Mo. Sans ça, `dd` copie par blocs de 512 octets — plus lent. |
| `status=progress` | Affiche une barre de progression et le débit. |
| `oflag=direct` | Écrit directement sur la clé en contournant le cache du noyau (page cache). La barre de progression reflète alors l'écriture réelle sur le périphérique, pas le simple remplissage de la RAM — évite de croire l'écriture terminée alors que le noyau écrit encore. |
| `conv=fsync` | Force l'écriture réelle sur la clé avant de rendre la main. C'est le vrai garde-fou contre un débranchement prématuré. |

> Si `dd` renvoie une erreur `Invalid argument` (rare, sur certaines clés ou contrôleurs USB qui supportent mal l'I/O direct), retirez `oflag=direct` : `conv=fsync` + le `sync` final (étape 5) suffisent alors.

> La barre de progression peut filer vite puis marquer une **pause à la fin** : c'est `conv=fsync` qui vide le cache vers la clé. C'est normal, patientez.

> **Écrire sur `sdX` ou sur `sdX1` ?** Par défaut, on écrit sur le **disque entier** (`sdX`), ce qui convient à toutes les images hybrides — c'est le cas de la quasi-totalité des ISO d'installation actuelles (Debian, Ubuntu, Fedora, Proxmox VE, Arch…). Les rares images non hybrides sont l'exception ; en cas de doute, `sdX` reste le bon réflexe.

---

## 5. Synchroniser avant de débrancher

Par sécurité, forcez un dernier vidage des caches avant de retirer la clé :

```bash
sync
```

Une fois `sync` terminé, vous pouvez débrancher la clé en toute sécurité. Elle est prête à booter.

---

## Aide-mémoire (résumé)

```bash
# 1. Identifier
lsblk -o NAME,SIZE,TYPE,TRAN,MODEL,MOUNTPOINTS

# 2. Démonter la partition montée
sudo umount /dev/sdX1

# 3. Vérifier l'ISO
ls -lh ~/Downloads/mon-image.iso

# 4. Écrire (remplacer sdX par le bon périphérique !)
sudo dd if=~/Downloads/mon-image.iso of=/dev/sdX bs=4M status=progress oflag=direct conv=fsync

# 5. Synchroniser
sync
```
