---
title: "Les normes Wi-Fi : de 802.11 à Wi-Fi 8"
description: "Tableau des normes Wi-Fi IEEE 802.11 (b, a, g, n, ac, ax, be, bn), de leurs noms commerciaux Wi-Fi 4 à Wi-Fi 8, de leurs dates, bandes de fréquences et débits théoriques."
---

{{< toc >}}

Le Wi-Fi repose sur la famille de normes **IEEE 802.11**, publiée par l'IEEE depuis 1997. Chaque évolution ajoute des lettres au nom : 802.11b, g, n, ac, ax, be… Ces noms étant peu parlants, la **Wi-Fi Alliance**, l'organisme qui certifie les produits, a introduit le 3 octobre 2018 des noms commerciaux numérotés : Wi-Fi 4, Wi-Fi 5, Wi-Fi 6 ([communiqué de la Wi-Fi Alliance](https://www.wi-fi.org/news-events/newsroom/wi-fi-alliance-introduces-wi-fi-6)).

## Tableau des normes

| Norme IEEE | Nom commercial | Publication de la norme | Bandes | Débit théorique max | Nouveauté principale |
|---|---|---|---|---|---|
| 802.11 | — | Juin 1997 | 2,4 GHz | 2 Mbit/s | Le premier Wi-Fi |
| 802.11b | (Wi-Fi 1, non officiel) | Septembre 1999 | 2,4 GHz | 11 Mbit/s | Le premier Wi-Fi grand public |
| 802.11a | (Wi-Fi 2, non officiel) | Septembre 1999 | 5 GHz | 54 Mbit/s | Arrivée du 5 GHz |
| 802.11g | (Wi-Fi 3, non officiel) | Juin 2003 | 2,4 GHz | 54 Mbit/s | Le 54 Mbit/s en 2,4 GHz |
| 802.11n | **Wi-Fi 4** | Octobre 2009 | 2,4 et 5 GHz | 600 Mbit/s | Plusieurs antennes (MIMO), canaux de 40 MHz |
| 802.11ac | **Wi-Fi 5** | Décembre 2013 | 5 GHz | 6,9 Gbit/s | Canaux de 80 et 160 MHz, jusqu'à 8 flux, plusieurs appareils servis à la fois (MU-MIMO descendant) |
| 802.11ax | **Wi-Fi 6** | 2021 (certification Wi-Fi 6 dès septembre 2019) | 2,4 et 5 GHz | 9,6 Gbit/s | OFDMA : partage efficace du canal entre de nombreux appareils |
| 802.11ax | **Wi-Fi 6E** | Certification en janvier 2021 | + 6 GHz | 9,6 Gbit/s | Ouverture de la bande des 6 GHz, peu encombrée |
| 802.11be | **Wi-Fi 7** | Septembre 2024 (certification Wi-Fi 7 en janvier 2024) | 2,4, 5 et 6 GHz | 23 Gbit/s | Canaux de 320 MHz, MLO (plusieurs bandes utilisées en même temps), 4096-QAM |
| 802.11bn | Wi-Fi 8 | Prévue vers 2028 | 2,4, 5 et 6 GHz | — | Priorité à la fiabilité (*Ultra High Reliability*) plutôt qu'au débit |

Sources : tableaux des normes 802.11 et des générations Wi-Fi de Wikipédia ([IEEE 802.11](https://en.wikipedia.org/wiki/IEEE_802.11), [Wi-Fi](https://en.wikipedia.org/wiki/Wi-Fi)) et communiqués de la Wi-Fi Alliance pour les certifications [Wi-Fi 6](https://www.wi-fi.org/news-events/newsroom/wi-fi-certified-6-delivers-new-wi-fi-era), [Wi-Fi 6E](https://www.wi-fi.org/news-events/newsroom/wi-fi-alliance-delivers-wi-fi-6e-certification-program) et [Wi-Fi 7](https://www.wi-fi.org/news-events/newsroom/wi-fi-alliance-introduces-wi-fi-certified-7).

## Comment lire ce tableau

### Norme IEEE et nom commercial

Deux organismes interviennent :

- l'**IEEE** rédige les normes techniques (802.11n, 802.11ac…) ;
- la **Wi-Fi Alliance** certifie que les produits fonctionnent ensemble et leur donne un nom commercial.

Les deux calendriers ne coïncident pas toujours. La certification Wi-Fi 6 a commencé en septembre 2019, avant la publication finale de la norme 802.11ax en 2021 ; la certification Wi-Fi 7 a commencé en janvier 2024, avant la publication de 802.11be en septembre 2024.

Seuls les noms à partir de Wi-Fi 4 sont officiels. Les appellations Wi-Fi 1, 2 et 3 pour 802.11b, a et g sont parfois utilisées après coup, mais la Wi-Fi Alliance ne les a pas adoptées.

Le Wi-Fi 6E n'est pas une nouvelle norme : c'est le Wi-Fi 6 (802.11ax) étendu à la bande des 6 GHz.

### Le débit théorique n'est jamais atteint

Le débit théorique maximal suppose les conditions les plus favorables prévues par la norme : le nombre maximal de flux (donc d'antennes de chaque côté), la largeur de canal maximale et un signal parfait. Il correspond en outre au total du point d'accès, **partagé entre tous les appareils** connectés.

En pratique :

- un téléphone ou un ordinateur portable n'a qu'une partie des antennes (et donc des flux) prévues au maximum par la norme ;
- le Wi-Fi est *half-duplex* : sur un canal, un seul appareil émet à la fois, et les échanges comportent des attentes, des accusés de réception et des renvois ;
- le signal diminue avec la distance et les obstacles (murs, planchers), et la vitesse diminue avec lui.

Le débit réellement mesuré, par exemple avec un test en ligne, est donc nettement inférieur au débit du lien radio affiché par l'appareil, lui-même bien inférieur au maximum théorique de la norme.

### Rétrocompatibilité

Chaque génération reste compatible avec les précédentes : un appareil Wi-Fi 6 se connecte à un point d'accès Wi-Fi 4, simplement à la vitesse du Wi-Fi 4. Une connexion fonctionne toujours au niveau de l'équipement le plus ancien des deux.
