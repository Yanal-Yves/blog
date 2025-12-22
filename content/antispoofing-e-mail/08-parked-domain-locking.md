---
title: "De SMTP à DMARC (8/9) : Parked Domain Locking"
weight: 8
---

Un domaine qui n'envoie aucun e-mail doit également configurer SPF, DKIM et DMARC afin de déclarer : "Ce domaine n'envoie jamais d'e-mail. Si vous en recevez un, jetez-le immédiatement.". C'est indispensable pour protéger contre l'usurpation : les pirates pourraient utiliser des domaines "dormants" ou des variations de votre domaine (typosquatting) pour envoyer du phishing, car personne ne les surveille.

Voici la configuration DNS qu'il faut appliquer :

| Type | Hôte / Nom | Valeur | Rôle |
| --- | --- | --- | --- |
| TXT | @   | v=spf1 -all | SPF  <br>(Déclare que personne n'est autorisé à envoyer des e-mails au nom du domaine) |
| TXT | \_dmarc | v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s; | DMARC (Demande au destinataire de rejeter tout e-mail qui déclarerait provenir du domaine) |
| TXT | \*.\_domainkey | v=DKIM1; p= | DKIM (Invalide toutes les clés) |
| MX  | @   | . (Priorité 0) | MX (ce domaine ne reçoit pas d'e-mail [RFC 7505](https://www.rfc-editor.org/rfc/rfc7505) (Null MX)) |
