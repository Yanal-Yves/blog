---
title: "BIMI et analyse des limites - 7/9"
weight: 7
---

Dans l'écosystème de la sécurité des e-mails, **BIMI (Brand Indicators for Message Identification)** est souvent présenté comme la prochaine étape logique après la mise en conformité DMARC. L'objectif est de permettre l'affichage d'un logo certifié dans les clients de messagerie pour renforcer la confiance visuelle.

Cependant, une analyse technique approfondie révèle que ce protocole est plus complexe qu'il n'y paraît. Contrairement à SPF ou DKIM qui sont purement déclaratifs, BIMI s'appuie généralement sur un tiers de confiance via un certificat numérique appelé VMC (Verified Mark Certificate). Si ce mécanisme fonctionne dans des environnements intégrés (comme les webmails de Google ou Yahoo), il se heurte à des obstacles structurels majeurs dès qu'il est confronté à l'architecture ouverte et standardisée de l'e-mail.

Voici une analyse des trois freins principaux qui rendent l'adoption de BIMI complexe, voire risquée, pour l'Internet ouvert.

# Le risque de sécurité : La vulnérabilité de l'architecture découplée
Le principal obstacle technique à une implémentation généralisée de BIMI réside dans la séparation des rôles entre le serveur et le client.

Dans la spécification BIMI, la charge de la vérification incombe au MTA (Mail Transfer Agent - le serveur de réception). C'est lui qui doit valider le certificat VMC, vérifier l'alignement DMARC et, en cas de succès, ajouter ou régénérer des en-têtes spécifiques (ex: `BIMI-Location` ou `Authentication-Results`) pour indiquer au client que le logo peut être affiché.

**Le problème de la transmission de confiance via IMAP :** Cette architecture suppose une chaîne de confiance ininterrompue. Or, pour les clients de messagerie universels (MUA) comme **Thunderbird** ou **Outlook** (en mode IMAP), cette chaîne est brisée. Le protocole IMAP, dans sa standardisation actuelle, ne permet pas au client de savoir avec certitude qui a écrit l'en-tête BIMI :
1. Est-ce le serveur (MTA) qui a légitimement validé le message et inséré l'en-tête ?
2. Ou est-ce l'expéditeur malveillant qui a injecté un faux en-tête BIMI-Location avant l'envoi ?

Sans une extension stricte du protocole IMAP permettant au serveur de signer ses résultats d'authentification ou de garantir au client qu'il a "nettoyé" les en-têtes entrants, le client mail se trouve dans l'incapacité de distinguer un vrai logo d'une tentative de phishing sophistiquée.

C'est cette raison technique précise qui pousse les développeurs de **Mozilla Thunderbird** à refuser l'implémentation de BIMI en l'état, la jugeant non sécurisée pour une architecture ouverte. De son côté, **Microsoft** a contourné le problème pour Outlook en ignorant BIMI au profit d'une solution propriétaire centralisée, ne faisant pas confiance aux en-têtes transitant par le mail.

Pour que cela soit sécurisé, la spécification exige que le MTA **nettoie (strip)** tous les en-têtes BIMI entrants avant de faire ses propres vérifications et d'ajouter son propre en-tête.

## Scénario détaillée
1. **Le rôle du serveur (MTA) dans la spécification BIMI :** Dans la spécification BIMI, c'est le serveur de réception qui fait le gros du travail. Il doit :
1.1 Vérifier DMARC.
1.2 Récupérer le certificat VMC (Verified Mark Certificate).
1.3 Valider la chaîne de certification du logo.
1.4 Une fois tout cela validé, il ajoute un en-tête spécifique au courriel (ex: `Authentication-Results` ou `BIMI-Location`) pour dire au client : "C'est bon, j'ai vérifié, tu peux afficher ce logo".
2. **Le scénario d'attaque :** Imaginez qu'un attaquant vous envoie un e-mail de phishing prétendant venir de votre banque.
  2.1 **L'attaque :** L'attaquant injecte manuellement l'en-tête suivant dans son e-mail frauduleux avant de l'envoyer : `Authentication-Results: bimi=pass; header.d=mabanque.com;`
  2.2 **Le serveur intermédiaire (Non-BIMI)** : Votre e-mail arrive sur un serveur mail classique (ex: un vieux serveur Postfix d'entreprise, ou un FAI qui n'a pas encore implémenté BIMI).
    - Ce serveur ne connaît pas BIMI.
	- Il vérifie peut-être SPF/DKIM, mais il **ignore** l'en-tête BIMI falsifié.
	- Surtout, **il ne le supprime pas**, car il ne sait pas que cet en-tête est sensible. Il transmet le mail tel quel à Thunderbird.
  2.3 **La réception sur Thunderbird** : Thunderbird relève le courrier via IMAP. Il voit l'en-tête `Authentication-Results: bimi=pass`.
3. **Le dilemme de Thunderbird (et de tous les MUA universels)**
Thunderbird se connecte à n'importe quel serveur IMAP du monde. Lorsqu'il voit cet en-tête "bimi=pass", il a deux possibilités :
  3.1 **Possibilité A :** Le serveur est compatible BIMI. Il a reçu le mail, a supprimé les faux en-têtes, a fait la vérification, et a apposé ce sceau de confiance. **(Légitime)**
  3.2 **Possibilité B :** Le serveur est "bête" (non-BIMI). Il a juste laissé passer l'en-tête falsifié par l'attaquant. **(Phishing)**
   **Thunderbird n'a aucun moyen technique de savoir s'il est dans la situation A ou B.**
   Il n'existe pas (actuellement) de commande IMAP standardisée (ex: `CAPABILITY BIMI`) qui permettrait au serveur de dire à Thunderbird : "Hey, je gère le BIMI, tu peux faire confiance à mes en-têtes, j'ai nettoyé les faux".
4. **Pourquoi Gmail ou Yahoo n'ont pas ce problème ?** L'application Gmail sur Android ou l'interface web de Yahoo Mail savent pertinemment qu'elles parlent aux serveurs de Google ou Yahoo. Le code de l'interface Gmail "sait" que le serveur Gmail nettoie les en-têtes. La confiance est implicite car le client et le serveur appartiennent à la même entité. Thunderbird, en tant que client universel, ne peut pas accorder cette confiance aveugle à tous les serveurs IMAP de la planète.

Si Thunderbird implémentait BIMI aujourd'hui en se basant simplement sur la présence des en-têtes, un attaquant pourrait afficher le logo officiel de "PayPal" ou "Crédit Agricole" sur un mail de phishing simplement en ajoutant une ligne de texte dans l'en-tête de son mail, pour peu que votre serveur de mail ne filtre pas activement ces balises.

Pour que Thunderbird puisse l'implémenter de façon sûre, il faudrait soit :
1. Que Thunderbird fasse lui-même toute la validation BIMI (ce qui est lourd : récupération des certificats VMC, validation crypto, etc., côté client).
2. Qu'une extension du protocole IMAP soit créée pour certifier que le serveur en amont est "BIMI-Aware".

## Une barrière économique à l'entrée (VMC)
Contrairement aux protocoles fondamentaux de l'e-mail (SMTP, SPF, DKIM, DMARC) qui sont basés sur la compétence technique et accessibles gratuitement à quiconque possède un nom de domaine, BIMI introduit une barrière financière via le **VMC (Verified Mark Certificate)**.

Pour être conforme à la spécification (telle qu'exigée par Google ou Apple), le domaine doit acquérir un certificat auprès d'une autorité de certification tierce. Ce coût, avoisinant les **1 200 € à 1 500 € par an**, est certes abordable pour une PME, une ETI ou une grande entreprise considérant cela comme une dépense marketing.

Cependant, ce modèle économique exclut de facto une part importante des acteurs de l'Internet :
- Les **TPE et micro-entreprises** pour qui ce coût est prohibitif.
- Le secteur **associatif et non-lucratif** (hors grandes ONG).
- Les **particuliers**, les développeurs indépendants et les communautés du logiciel libre.

En liant la sécurité visuelle à la capacité de paiement et à la possession d'une marque déposée, BIMI s'éloigne de la philosophie de neutralité du net où la légitimité technique d'un expéditeur (prouvée par DMARC) devrait suffire, indépendamment de sa puissance financière.

# Conclusion
BIMI soulève une question intéressante sur l'évolution des standards Internet. Si l'intention de fournir une validation visuelle est louable, son implémentation actuelle pose un problème de sécurité pour les clients mails universels et introduit une discrimination économique.

Pour l'heure, la recommandation technique la plus robuste reste l'application stricte des standards ouverts : **SPF, DKIM et DMARC (`p=reject` ou `p=quarantine` sur 100% des mails)**. Ces protocoles garantissent la sécurité et la délivrabilité du message pour tous, sans dépendre d'une chaîne de certification payante ni d'une architecture client-serveur propriétaire.
