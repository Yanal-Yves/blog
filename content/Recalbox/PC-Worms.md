# Extraire le CD vers un fichier. 
Le CD contient plusieurs piste. La piste 1 contient les fichiers, tandis que les autres pistes contienent les fichiers audio. Il faut donc générer un fichier `.toc` qui contient la définition des pistes audios.

```bash
cdrdao read-cd --read-raw --datafile Worms.bin --device /dev/sr0 --driver generic-mmc-raw:0x20000 Worms.toc

toc2cue Worms.toc Worms.cue
```

- `0x20000` indique à `cdrdao` d'inverser les bits audio pendant qu'il les lit. Cela permet de corriger un problème de "Byte order" qui évite que les données audio soient lues "à l'envers" par Linux (Little Endian au lieu de Big Endian), ce qui transforme la musique en bruit blanc ("PSCCHHHH").

Nom du dossier : `worms.pc`

`dosbox.bat`
```bat
@echo off
imgmount D "Worms.cue" -t iso
C:
cd WORMS
WORMS.EXE
```