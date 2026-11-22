---
title: "Un Raspberry Pi 1 en point d'accès Wi-Fi : retour d'expérience"
description: "Retour d'expérience : transformer un Raspberry Pi 1 Model B (sans Wi-Fi intégré) en point d'accès Wi-Fi en mode pont avec une clé USB RT5370, NetworkManager et une carte SD en lecture seule. Choix de la clé, pièges, mesures de débit et limites."
draft: false
---

{{< toc >}}

Une box Internet installée au sous-sol, une chambre d'enfant à l'étage qui capte mal le Wi-Fi, mais une prise RJ45 murale dans cette chambre, reliée à la box. Et, dans un tiroir, un **Raspberry Pi 1 Model B** (512 Mo de RAM) qui ne servait plus. L'idée : le brancher sur la prise RJ45 de la chambre et lui faire diffuser le réseau de la box en Wi-Fi.

Cet article raconte ce qui a marché, ce qui n'a pas marché, et ce qu'on peut attendre d'une machine de cet âge. Spoiler : ça fonctionne, de façon stable, mais le débit plafonne autour de 8 Mbit/s.

## Le matériel

| Élément | Choix | Remarque |
|---|---|---|
| Carte | Raspberry Pi 1 Model B, 512 Mo | Ethernet 100 Mbit/s, 2 ports USB, **pas de Wi-Fi intégré** |
| Carte SD | 4 Go (de récupération) | Suffisant, à condition de faire le ménage (voir plus bas) |
| Clé Wi-Fi | Clé USB à puce **Ralink RT5370** | Achetée pour l'occasion, une quinzaine d'euros |
| Alimentation | Micro-USB 5 V | Branchée sur une multiprise à interrupteur |
| Système | Raspberry Pi OS Lite 32 bits (Debian 13 « Trixie ») | Sans bureau, administré en SSH |

Aucun Raspberry Pi 1 n'a de Wi-Fi intégré : il faut une clé USB. Le Wi-Fi intégré n'est arrivé qu'avec le Raspberry Pi 3 et le Zero W.

## Choisir la clé Wi-Fi : tout se joue sur la puce

Pour qu'une clé puisse **émettre** un réseau (et pas seulement s'y connecter), il faut que son pilote Linux gère le **mode point d'accès** (*AP*). Ça dépend de la puce, pas de la marque inscrite sur la clé.

On peut le vérifier en une commande, une fois la clé branchée :

```bash
iw list | grep -A 8 "Supported interface modes"
```

Si `AP` n'apparaît pas dans la liste, la clé ne pourra pas servir de point d'accès.

### Essai raté : une clé Realtek RTL8188EUS

J'avais sous la main une petite clé COMFAST, qui avait autrefois servi de point d'accès sur un robot. Avec Raspberry Pi OS, elle est bien reconnue (`lsusb` affiche `0bda:8179 … RTL8188EUS`), son firmware se charge, mais le pilote du noyau (`rtl8xxxu`) ne propose que deux modes :

```
Supported interface modes:
         * managed
         * monitor
```

Pas de mode `AP`. Sur le robot, elle utilisait sans doute un pilote Realtek spécifique, à compiler soi-même. Sur un Pi 1, compiler ce pilote prendrait des heures, occuperait de la place sur une petite carte SD et serait à refaire à chaque mise à jour du noyau : abandonné.

### Clé retenue : Ralink RT5370

Les puces **RT5370** (et RT3070) utilisent le pilote `rt2800usb`, présent dans le noyau depuis longtemps. Résultat avec la clé reçue :

```
Supported interface modes:
         * IBSS
         * managed
         * AP
         * AP/VLAN
         * monitor
         * mesh point
```

Le mode `AP` est là. Attention, les annonces se trompent parfois de puce : à réception, `lsusb` doit afficher `148f:5370` (Ralink). Un identifiant commençant par `0bda:` indique une puce Realtek.

Le firmware de la puce se trouve dans le paquet `firmware-misc-nonfree` (fichier `rt2870.bin`) ; sur mon installation, il fallait l'installer :

```bash
sudo apt install -y firmware-misc-nonfree
```

## Installer le système

### Raspberry Pi Imager sous Fedora

Sous Fedora (session Wayland), le raccourci du menu de Raspberry Pi Imager demande le mot de passe administrateur… puis rien ne s'affiche. Les journaux montrent la cause : relancé en root, le programme ne reçoit pas les informations de la session graphique et plante (`could not connect to display`). Lancé depuis un terminal avec `sudo rpi-imager`, il fonctionne.

Dans les options de personnalisation d'Imager : un nom d'hôte, un utilisateur, le fuseau horaire, **SSH activé**, et le Wi-Fi laissé vide (le Pi n'en a pas encore).

### Un premier démarrage très lent

Le premier démarrage d'un Pi 1 prend plusieurs minutes : les messages `cloud-init` et `First Boot Wizard` défilent lentement, ce n'est pas un blocage. Ensuite, chaque redémarrage prend environ 3 minutes avant que SSH réponde. La première mise à jour complète (`apt full-upgrade`) a pris de l'ordre d'une heure.

### Faire de la place sur une carte de 4 Go

Raspberry Pi OS 32 bits installe un noyau pour **chaque** famille de Raspberry Pi (v6 pour le Pi 1, v7, v8), plus l'ancienne version après une mise à jour du noyau. Sur un Pi 1, seul le noyau v6 en service est utile. Après la première mise à jour, il restait 625 Mo libres ; après avoir retiré les noyaux inutiles et leurs dépendances, **965 Mo**.

Méthode prudente, qui affiche la liste avant de supprimer :

```bash
uname -r                                   # doit finir par -rpi-v6
garder="linux-image-$(uname -r)"
a_retirer=$(dpkg-query -W -f='${db:Status-Abbrev} ${binary:Package}\n' 'linux-image-*' \
  | awk '$1=="ii"{print $2}' \
  | grep -v -e "^${garder}$" -e '^linux-image-rpi-v6$')
echo "$a_retirer"                          # relire avant de continuer
sudo apt purge $a_retirer
sudo apt autoremove
```

On garde le méta-paquet `linux-image-rpi-v6` : les mises à jour suivantes n'installeront plus que le noyau v6. Évidemment, la carte ne démarrera plus sur un Raspberry Pi plus récent.

## La configuration réseau : un pont plutôt que du NAT

Deux façons de faire un point d'accès :

| Mode | Principe | Conséquence |
|---|---|---|
| **NAT** (partage de connexion) | Le Pi crée son propre réseau (par exemple `10.42.0.x`) et le relie à celui de la box | Les appareils ont Internet, mais ne voient pas automatiquement ceux de la box (imprimante, Chromecast, partages) |
| **Pont** (*bridge*) | Le Pi relie Ethernet et Wi-Fi sans rien traduire | Les appareils reçoivent une adresse de la box et sont sur le même réseau que tout le reste |

J'ai choisi le **pont** : les appareils de la chambre font partie du réseau de la maison, comme s'ils captaient directement la box. C'est aussi le mode le plus léger pour le processeur, puisque le Pi n'a ni traduction d'adresses ni serveur DHCP à faire tourner.

Raspberry Pi OS récent utilise **NetworkManager**. Trois profils suffisent :

```bash
MAC=$(cat /sys/class/net/eth0/address)

# 1. Le pont br0, qui porte l'adresse IP du Pi
sudo nmcli connection add type bridge ifname br0 con-name pont \
  bridge.stp no bridge.mac-address "$MAC" \
  ipv4.method auto ipv6.method disabled \
  connection.autoconnect-priority 10

# 2. Le port Ethernet, rattaché au pont
sudo nmcli connection add type ethernet ifname eth0 con-name pont-eth0 \
  connection.master br0 connection.slave-type bridge \
  connection.autoconnect-priority 10

# 3. Le point d'accès Wi-Fi, rattaché au pont
sudo nmcli connection add type wifi ifname wlan0 con-name hotspot \
  autoconnect yes ssid "pi-wifi" \
  802-11-wireless.mode ap 802-11-wireless.band bg \
  802-11-wireless.channel 11 802-11-wireless.powersave 2 \
  wifi-sec.key-mgmt wpa-psk wifi-sec.proto rsn \
  wifi-sec.pairwise ccmp wifi-sec.group ccmp \
  wifi-sec.psk "un-mot-de-passe-long" \
  connection.master br0 connection.slave-type bridge
```

Quelques détails qui comptent :

- **Le profil Wi-Fi peut être créé avant d'avoir la clé** : NetworkManager l'activera dès que `wlan0` apparaîtra. Tout a donc été préparé pendant la livraison.
- `bridge.mac-address` : le pont reprend l'adresse MAC de `eth0`, donc un bail DHCP statique réservé sur la box continue de fonctionner.
- `bridge.stp no` : évite 30 secondes d'attente au démarrage du pont.
- `powersave 2` : désactive l'économie d'énergie de la clé, réputée provoquer des coupures en mode point d'accès.
- `autoconnect-priority 10` : au démarrage, ces profils passent avant le profil Ethernet créé à l'installation, qui reste disponible en secours.
- Mieux vaut avoir un écran et un clavier sous la main : si le pont ne monte pas, le Pi n'est plus joignable par le réseau. Le retour arrière est simple : `sudo nmcli connection delete pont pont-eth0`, puis redémarrer.

### IPv6 : désactivée pour le Pi, pas pour les appareils

Le Pi recevait une adresse IPv6 publique de la box, dont il n'a aucun besoin (SSH et mises à jour passent très bien en IPv4). `ipv6.method disabled` la supprime. Les appareils connectés au Wi-Fi, eux, gardent l'IPv6 : le pont la transmet sans la lire, et c'est la box qui la leur attribue. Vérifié avec [test-ipv6.com](https://test-ipv6.com) depuis un téléphone connecté au point d'accès.

Piège rencontré au passage : avec un VPN WireGuard actif sur le téléphone, ce test affiche « No IPv6 », même sur le Wi-Fi de la box. Il faut couper le VPN pour tester.

### Le piège du Wi-Fi « unavailable »

Clé branchée, profil prêt… et `nmcli device` affiche `wlan0 wifi unavailable`. `rfkill list` montre `Soft blocked: yes`. `sudo rfkill unblock wifi` débloque, mais le blocage revient au redémarrage suivant.

La vraie cause :

```bash
nmcli radio wifi        # → disabled
```

Le Wi-Fi était **désactivé dans NetworkManager**, qui le rebloquait lui-même à chaque démarrage. La solution, conservée ensuite :

```bash
sudo nmcli radio wifi on
```

Quelques secondes plus tard, `wlan0` passe à `connected` sur le profil `hotspot`, et `bridge link` montre `eth0` et `wlan0` dans le pont.

### WPA3 offert en prime

Le profil demande du WPA2 (`wpa-psk`), mais le téléphone affiche le réseau en « WPA3 (SAE Transition Mode) » : NetworkManager a ajouté WPA3 de lui-même, en mode transition. Les appareils récents se connectent en WPA3, les anciens en WPA2, avec le même mot de passe. C'est exactement ce qu'il faut pour une console de jeu de première génération qui ne connaît que WPA2.

## Les performances

### Débit et charge du processeur

Mesures avec fast.com depuis un téléphone connecté au point d'accès, et `top` sur le Pi pendant le test :

| | Au repos | Pendant le test |
|---|---|---|
| Débit | — | **7,3 à 8,2 Mbit/s** (environ 1 Mo/s) |
| Processeur libre (`id`) | 96 % | **0 %** |
| Traitement réseau (`si`, *softirq*) | 0,5 % | 70,7 % |
| Système (`sy`) | 2,4 % | 26,4 % |
| Latence (fast.com) | 7 ms | 76 ms |
| Température (`vcgencmd measure_temp`, sans radiateur) | — | 48 °C au maximum, après trois tests d'affilée |

Le verdict est clair : **c'est le processeur qui limite**. Il passe tout son temps à faire passer les paquets entre la clé USB et l'Ethernet. Sur le Pi 1, l'Ethernet est lui-même relié par USB : chaque paquet traverse deux fois le même bus USB, et un seul cœur à 700 MHz doit tout traiter.

Ce n'est ni le port Ethernet (100 Mbit/s, largement assez), ni la clé Wi-Fi. Le pare-feu n'y est pour rien non plus : le module `br_netfilter` n'est pas chargé (`lsmod | grep br_netfilter` ne renvoie rien), donc les paquets du pont ne passent pas par lui.

Un processeur à 100 % ne perd pas de données : les paquets en trop sont simplement renvoyés par TCP, et le débit s'ajuste. Seule la latence augmente, ici de 7 à 76 ms, ce qui reste confortable pour la vidéo et le jeu en ligne.

### Ce qu'on pourrait gagner

- **Overclocking** (`raspi-config` → *Performance Options* → *Overclock*) : quelques dizaines de pourcents au mieux, avec un risque pour la carte SD aux réglages les plus élevés. Non retenu.
- **Changer de matériel** : un Raspberry Pi 3 ou 4, avec son Wi-Fi intégré, ou un petit point d'accès Wi-Fi du commerce branché sur la même prise RJ45, irait beaucoup plus vite avec la même logique.

Pour une chambre d'enfant (vidéo, jeux en ligne, navigation), environ 8 Mbit/s avec une latence correcte suffisent. Les gros téléchargements, eux, seront lents.

### Cohabiter avec le Wi-Fi de la box

En 2,4 GHz, seuls les canaux 1, 6 et 11 ne se chevauchent pas. Un scan depuis un PC Linux montre qui est où :

```bash
nmcli -f SSID,CHAN,BANDWIDTH,SIGNAL dev wifi list --rescan yes
```

Au départ, la box et le Pi étaient tous les deux sur le canal 6, la box en canaux de 40 MHz, ce qui occupe une bonne partie de la bande. Le point d'accès a été déplacé sur le **canal 11**. NetworkManager ne sait pas choisir seul un canal libre en mesurant l'environnement, comme le fait une box : on le fixe à la main. Si la box est en canal automatique, il faut garder un œil sur le scan : elle pourrait un jour se placer sur le même canal.

## Pouvoir couper le courant : la carte SD en lecture seule

Le Pi est branché sur une multiprise à interrupteur : on l'allume quand on en a besoin, on le coupe la nuit. Couper brutalement le courant d'un Linux qui écrit sur sa carte SD finit par l'abîmer. La parade : rendre la carte **en lecture seule**, avec l'*overlay* de Raspberry Pi OS. Les écritures vont alors en mémoire vive et disparaissent à l'extinction.

```bash
sudo raspi-config nonint do_overlayfs 0   # 0 = activer (convention de raspi-config)
sudo reboot
```

Cette commande active les deux protections : la partition principale en *overlay* et la partition de démarrage `/boot/firmware` en lecture seule. Après redémarrage, `findmnt /` affiche `overlayroot`.

Deux remarques :

- `df -h /` n'indique plus l'espace de la carte, mais celui de la mémoire vive réservée aux écritures temporaires (environ 210 Mo ici). L'espace réel de la carte se lit avec `df -h /media/root-ro`.
- Le test grandeur nature est venu tout seul : quelqu'un a débranché le Pi juste après l'activation. Il est reparti sans problème.

### Un script pour les mises à jour

Avec la protection, plus rien n'est conservé au redémarrage, mises à jour comprises. Pour mettre à jour, il faut désactiver l'overlay, redémarrer, rendre `/boot/firmware` modifiable (`raspi-config` refuse de le faire tant que l'overlay est actif, d'où deux étapes), mettre à jour, puis tout réactiver et redémarrer encore.

Le script [upgrade-pi.sh](/fichiers/raspberry-pi/upgrade-pi.sh) enchaîne tout cela, redémarrages compris. Après chaque redémarrage, un service systemd reprend la suite ; il ne se déclenche que si un petit fichier d'état existe sur `/boot/firmware`, la seule partition qui peut rester modifiable quand l'overlay est actif.

```bash
sudo bash upgrade-pi.sh installer   # une fois, protection désactivée
sudo upgrade-pi                     # mise à jour complète, protection réactivée à la fin
sudo upgrade-pi statut              # état de la protection, du noyau, de l'espace libre
sudo upgrade-pi deproteger          # pour modifier un réglage (canal, mot de passe…)
sudo upgrade-pi proteger            # réactiver la protection
```

En cas d'erreur (réseau, place, paquet), il s'arrête sans redémarrer et laisse la protection désactivée, pour qu'on puisse corriger.

## Bilan

| Ce qui marche bien | Ce qui est limité |
|---|---|
| Signal excellent dans la pièce, réseau de la maison accessible comme si on était à côté de la box | Débit d'environ 8 Mbit/s, plafonné par le processeur du Pi 1 |
| Allumage et extinction par simple interrupteur, sans risque pour la carte SD | Une clé USB à choisir avec soin (mode `AP`) |
| WPA2/WPA3, IPv4 et IPv6 pour les appareils | Canal Wi-Fi à fixer à la main |
| Un vieux Pi 1 réutilisé, une quinzaine d'euros de dépense | Chaque redémarrage prend environ 3 minutes |

Pour l'usage visé, le pari est réussi. Mais si le besoin de débit augmente, la vraie amélioration ne viendra pas des réglages : la même configuration sur un Raspberry Pi plus récent, ou un point d'accès dédié sur la même prise RJ45, fera bien mieux.
