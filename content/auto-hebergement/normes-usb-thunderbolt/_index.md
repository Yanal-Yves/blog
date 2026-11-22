---
title: "Les normes USB et Thunderbolt : versions, débits et connecteurs"
description: "Tableau des versions USB (1.0 à USB4 Version 2.0), de leurs débits et noms commerciaux (USB 5Gbps à USB 80Gbps), des générations Thunderbolt 1 à 5, des connecteurs (USB-A, USB-B, Mini, Micro, USB-C) et de l'alimentation USB."
draft: false
---

{{< toc >}}

« USB » désigne à la fois des **versions de la norme** (USB 2.0, USB 3.2, USB4…), qui fixent le débit, et des **connecteurs** (USB-A, Micro-USB, USB-C…), qui fixent la forme de la prise. Les deux sont indépendants : un connecteur USB-C peut transporter de l'USB 2.0 à 480 Mbit/s comme de l'USB4 à 80 Gbit/s. **Thunderbolt**, la technologie d'Intel, a fini par se fondre dans l'USB : l'USB4 est construit sur le protocole de Thunderbolt 3.

## Les versions de l'USB

| Version | Publication de la spécification | Débit maximal | Nom d'origine | Nom commercial actuel (USB-IF) | Connecteurs |
|---|---|---|---|---|---|
| USB 1.0 | Janvier 1996 | 1,5 Mbit/s (Low Speed) et 12 Mbit/s (Full Speed) | Low Speed / Full Speed | Basic-Speed USB | Standard-A et B |
| USB 1.1 | 1998 | Idem | Idem | Basic-Speed USB | Standard-A et B |
| USB 2.0 | Avril 2000 | 480 Mbit/s | High Speed | Hi-Speed USB | Standard, Mini, Micro, USB-C |
| USB 3.0, renommé USB 3.1 Gen 1, puis USB 3.2 Gen 1 | Novembre 2008 | 5 Gbit/s | SuperSpeed | **USB 5Gbps** | Standard-A et B (USB 3), Micro-B (USB 3), USB-C |
| USB 3.1 Gen 2, renommé USB 3.2 Gen 2 | Juillet 2013 | 10 Gbit/s | SuperSpeed+ | **USB 10Gbps** | Standard-A et B (USB 3), Micro (USB 3), USB-C |
| USB 3.2 Gen 2x2 | Septembre 2017 | 20 Gbit/s | SuperSpeed USB 20Gbps | **USB 20Gbps** | **USB-C uniquement** |
| USB4 (version 1.0) | Août 2019 | 20 ou 40 Gbit/s | USB4 | **USB 20Gbps** ou **USB 40Gbps** | **USB-C uniquement** |
| USB4 Version 2.0 | Octobre 2022 | 80 Gbit/s dans les deux sens, ou 120 Gbit/s dans un sens et 40 Gbit/s dans l'autre | USB4 Version 2.0 | **USB 80Gbps** | **USB-C uniquement** |

Les débits sont des débits de signalisation, c'est-à-dire des maximums théoriques : le débit réellement obtenu, par exemple lors d'une copie de fichiers, est inférieur.

Sources : tableaux des versions et des modes de transfert de Wikipédia ([USB](https://en.wikipedia.org/wiki/USB), [USB 3.0](https://en.wikipedia.org/wiki/USB_3.0), [USB4](https://en.wikipedia.org/wiki/USB4)), guide de nommage de l'USB-IF ([USB Data Performance Language Usage Guidelines](https://www.usb.org/sites/default/files/usb_data_performance_language_usage_guidelines_jan_2024.pdf), janvier 2024) et [page USB4 de l'USB-IF](https://www.usb.org/usb4).

### Le casse-tête des noms de l'USB 3

L'USB 3.0 à 5 Gbit/s a été renommée **USB 3.1 Gen 1** à la sortie de l'USB 3.1, puis **USB 3.2 Gen 1** (ou Gen 1x1) à la sortie de l'USB 3.2, avant de devenir **USB 5Gbps** dans la communication de l'USB-IF. Certains fabricants en ont profité pour vendre comme « USB 3.1 » des produits à 5 Gbit/s, en omettant la mention « Gen 1 ».

Pour mettre fin à la confusion, l'USB-IF demande désormais d'afficher le débit plutôt que le numéro de version : **USB 5Gbps, 10Gbps, 20Gbps, 40Gbps et 80Gbps**. Son guide précise que les termes « USB4 Version 2.0 », « USB4 Version 1.0 », « USB 3.2 » ou « SuperSpeed Plus » sont définis dans les spécifications, mais ne sont pas destinés aux noms de produits, aux emballages ni à la communication grand public.

Pour s'y retrouver, il suffit donc de chercher le **débit** sur la fiche du produit.

## Les générations Thunderbolt

| Version | Date | Débit | Connecteur | Remarque |
|---|---|---|---|---|
| Thunderbolt 1 | 2011 (premiers produits chez Apple) | 2 canaux de 10 Gbit/s | Mini DisplayPort | Même connecteur que la sortie vidéo Mini DisplayPort |
| Thunderbolt 2 | 2013 | 20 Gbit/s (les deux canaux agrégés) | Mini DisplayPort | |
| Thunderbolt 3 | 2015 (premiers appareils en décembre 2015) | 40 Gbit/s | USB-C | Protocole cédé à l'USB-IF le 4 mars 2019 pour bâtir l'USB4 |
| Thunderbolt 4 | Annoncé en janvier 2020, spécification finale en juillet 2020 | 40 Gbit/s | USB-C | Conformité USB4 obligatoire, avec des exigences minimales plus élevées |
| Thunderbolt 5 | Présenté le 12 septembre 2023, produits à partir de 2024 | 80 Gbit/s dans les deux sens, jusqu'à 120 Gbit/s en émission (*Bandwidth Boost*) | USB-C | Aligné sur l'USB4 Version 2.0 |

Sources : [Wikipédia, Thunderbolt](https://en.wikipedia.org/wiki/Thunderbolt_(interface)), [page USB4 de l'USB-IF](https://www.usb.org/usb4) et guide de communication d'Intel ([Thunderbolt Messaging Guide](https://www.intel.com/content/dam/www/central-libraries/us/en/documents/2023-09/thunderbolt-messaging-guide.pdf), septembre 2023).

### Thunderbolt et USB4 : quelle différence ?

Depuis Thunderbolt 3, tout passe par le même connecteur USB-C. La différence tient aux **exigences minimales** : un port USB4 a droit à beaucoup de souplesse, un port Thunderbolt doit tout offrir. Extrait du tableau comparatif d'Intel, pour les ordinateurs :

| Exigence minimale pour le PC | Thunderbolt 5 | Thunderbolt 4 | USB4 |
|---|---|---|---|
| Débit | 80 et 120 Gbit/s | 40 Gbit/s | 20 Gbit/s |
| Écrans | Deux écrans 6K | Deux écrans 4K | Un écran |
| PCIe (stockage externe rapide) | 64 Gbit/s | 32 Gbit/s | — |
| Puissance fournie par port aux accessoires | 15 W | 15 W | 7,5 W |

Un port USB4 n'est donc obligé de fournir que 20 Gbit/s : seul le logo Thunderbolt (ou la mention « USB 40Gbps ») garantit les 40 Gbit/s. La compatibilité avec Thunderbolt 3 est d'ailleurs optionnelle pour un port USB4.

## Les connecteurs

| Connecteur | Apparition | Réversible | Usage typique |
|---|---|---|---|
| Standard-A (USB-A) | Spécification d'origine (USB 1.0) | Non | Côté ordinateur, chargeur ou hub : la prise rectangulaire classique |
| Standard-B (USB-B) | Spécification d'origine (USB 1.0) | Non | Côté périphérique, par exemple une imprimante |
| Mini-A, Mini-B (Mini-USB) | Avec l'USB 2.0, en avril 2000 | Non | Appareils photo, premiers smartphones et tablettes |
| Micro-A, Micro-B (Micro-USB) | Annoncés en janvier 2007 | Non | Prévus pour remplacer le Mini-USB dans les petits appareils ; très répandus sur les smartphones avant l'USB-C |
| Standard-A et B USB 3, Micro-B USB 3 | Avec l'USB 3.0, en 2008 | Non | Cinq contacts supplémentaires pour le 5 Gbit/s ; Micro-B USB 3 sur les disques durs externes |
| USB-C | Spécification 1.0 publiée le 11 août 2014 | **Oui** | 24 broches, remplace progressivement tous les autres |

Quelques précisions :

- Les connecteurs Standard ont 4 contacts, les Mini et Micro en ont 5.
- La spécification USB 3 **recommande** (sans l'imposer) un isolant **bleu** (Pantone 300 C) à l'intérieur des prises Standard-A compatibles 5 Gbit/s et plus. Le bleu-vert parfois utilisé pour le 10 Gbit/s ne fait pas partie de la norme.
- La lettre « C » de USB-C ne désigne **que la forme du connecteur**. Un appareil équipé d'un port USB-C n'implémente pas forcément un protocole USB particulier, ni l'USB Power Delivery, ni les modes alternatifs (vidéo, Thunderbolt). Un port USB-C peut très bien n'être que de l'USB 2.0 à 480 Mbit/s.

Sources : [Wikipédia, USB hardware](https://en.wikipedia.org/wiki/USB_hardware), [Wikipédia, USB 3.0](https://en.wikipedia.org/wiki/USB_3.0) et [Wikipédia, USB-C](https://en.wikipedia.org/wiki/USB-C).

## L'alimentation

| Cas | Puissance | Spécification |
|---|---|---|
| USB 1.x et 2.0 | 2,5 W (5 V, 500 mA) | USB 1.0 (1996) et 2.0 (2000) |
| USB 3.x | 4,5 W (5 V, 900 mA) | USB 3.0 (novembre 2008) |
| USB-C sans négociation | 7,5 W (5 V, 1,5 A) ou 15 W (5 V, 3 A) | USB Type-C 1.0 (août 2014) |
| USB Power Delivery | Jusqu'à 100 W (20 V, 5 A) | USB PD 1.0 (juillet 2012) |
| USB Power Delivery EPR | Jusqu'à 240 W (48 V, 5 A), avec des paliers à 28, 36 et 48 V pour 140, 180 et 240 W | USB PD 3.1 (mai 2021), câbles définis par USB Type-C 2.1 |

Au-delà de 15 W, le chargeur, le câble et l'appareil doivent **négocier** la puissance avec l'USB Power Delivery. Les 100 W reposent sur des câbles USB-C prévus pour 5 A, et les 240 W sur des câbles répondant aux exigences de l'USB Type-C 2.1.

Sources : tableau de l'historique de l'alimentation de [Wikipédia, USB](https://en.wikipedia.org/wiki/USB), [Wikipédia, USB-C](https://en.wikipedia.org/wiki/USB-C) et [page USB Charger (USB Power Delivery) de l'USB-IF](https://www.usb.org/usb-charger-pd).

## En pratique

- **Pour connaître le débit d'un port ou d'un câble**, se fier au débit affiché (USB 5Gbps, 10Gbps…) ou au logo Thunderbolt, pas à la forme du connecteur ni au numéro de version.
- **Un câble USB-C n'en vaut pas un autre** : certains ne font que de l'USB 2.0 et de la recharge, d'autres transportent 40 ou 80 Gbit/s, d'autres encore sont prévus pour 240 W.
- **La compatibilité est assurée vers le bas** : un appareil USB 2.0 fonctionne sur un port USB 3 ou USB4, à la vitesse de l'USB 2.0.
