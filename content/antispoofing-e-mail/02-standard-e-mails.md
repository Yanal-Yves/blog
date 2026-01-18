---
title: "Les e-mails standards - 2/9"
weight: 2
---

{{< toc >}}

Les protocoles anti usurpation que l'on va voir dans les articles suivants sont les murs de votre forteresse, et les e-mails standards sont les postes de garde. Si vous construisez les murs (SPF/DKIM) mais qu'il n'y a personne dans les postes de garde (postmaster/abuse) pour entendre les alarmes, votre sécurité finira par être contournée ou dégradée sans que vous le sachiez. Commençons par configurer les e-mails standards.

La création de certaines boîtes mail est une obligation technique définie par les standards de l'Internet (**RFC**). Ces adresses, appelées **"Role-Based Email Addresses"**, assurent l'interopérabilité et la sécurité.

## 💡 En bref, pour un domaine classique (e-mail et site web)
Créez les alias suivants (redirigés vers votre adresse d'administration) pour être conforme :
- `abuse@`
- `admin@`
- `administrator@`
- `hostmaster@`
- `postmaster@`
- `root@`
- `security@`
- `webmaster@`

Ces e-mails permettent de mettre en place des boucles de rétroaction (FBL Feed Back Loop).

**⚠️ Point d'attention sur les redirections :**
L'adresse finale de destination doit idéalement être hébergée sur le même domaine. Si vous redirigez ces alias vers une boîte externe (ex: Gmail), le mécanisme **SPF** échouera souvent (car [le SPF ne résiste pas à la redirection](/content/antispoofing-e-mail/03-spf-sender-policy-framework.md#le-spf-ne-résiste-pas-au-forward-de-mail)). Dans ce cas de figure, seul le **DKIM** permettra de prouver l'authenticité de l'e-mail transféré.

## Explication détaillée

### 1. Les Indispensables (Obligation Technique)

Ces adresses sont critiques. Si elles n'existent pas, vous risquez d'être bloqué par d'autres serveurs ou de rater des alertes de sécurité.

#### **`abuse@`**
* **Fonction :** Réception des plaintes (spam, phishing). Utilisée par les FAI et les blacklists pour signaler un problème venant de chez vous.
* **Référence :**
    * **[RFC 2142](https://www.ietf.org/rfc/rfc2142.txt) (Section 4) :** Définit `abuse` comme standard pour les comportements abusifs.

#### **`postmaster@`**
* **Fonction :** Réception des erreurs de livraison et requêtes techniques entre administrateurs.
* **Référence :**
    * **[RFC 5321](https://www.ietf.org/rfc/rfc5321.txt) (Section 4.5.1) :** « Tout système SMTP [...] DOIT supporter la boîte aux lettres réservée "postmaster" ».
    * **[RFC 5321](https://www.ietf.org/rfc/rfc822.txt) :** Standard historique.

---

### 2. Les Standards de Service ([RFC 2142](https://www.ietf.org/rfc/rfc2142.txt))

La **[RFC 2142](https://www.ietf.org/rfc/rfc2142.txt)** uniformise les contacts pour éviter d'avoir à deviner l'adresse du responsable d'un service.

| Adresse | Service | Fonction / Justification ([RFC 2142](https://www.ietf.org/rfc/rfc2142.txt)) |
| :--- | :--- | :--- |
| **`webmaster@`** | HTTP | Pour les problèmes liés au site web (liens brisés, erreurs). |
| **`hostmaster@`** | DNS | Pour les problèmes liés aux zones DNS et au domaine. |
| **`security@`** | Sécurité | Signalement de failles (*Responsible Disclosure*, [RFC 9116](https://www.ietf.org/rfc/rfc9116.txt)). |
| **`noc@`** | Réseau | Infrastructure et connectivité (*Network Operations Center*). Concerne surtout les FAI et opérateurs réseaux. |

---

### 3. Validation SSL/TLS (Certificats)

Les Autorités de Certification (CA) historiques comme *DigiCert*, *Sectigo*, *GlobalSign*, *GeoTrust* ou *ZeroSSL* utilisent ces alias pour la validation par email (appelée "Email-based DCV" - Domain Control Validation) des certificats SSL/TLS. L'autorité de certification envoie un mail contenant un code de validation à l'une des 5 adresses standards ou à l'e-mail indiqué dans le WHOIS (bien que le WHOIS soit souvent masqué par le RGPD aujourd'hui).

* `admin@`
* `administrator@`
* `hostmaster@`
* `postmaster@`
* `webmaster@`

> **Note :** Les autorités de certification modernes (ex: Let's Encrypt) se basent sur le protocole [ACME](https://en.wikipedia.org/wiki/Automatic_Certificate_Management_Environment) (validation par fichier HTTP ou entrée DNS) et n'utilisent donc plus ces boîtes e-mails.

Maintenant que votre domaine dispose des boîtes aux lettres réglementaires pour recevoir les alertes, nous allons vérifier si l'infrastructure technique (votre serveur et son IP) est correctement déclarée. C'est l'étape du FCrDNS.
