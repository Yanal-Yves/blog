---
title: "AWS KMS : types de clés"
description: "Comprendre AWS KMS (Key Management Service) : AWS owned key, AWS managed key et customer managed key (CMK), origine du matériel cryptographique."
weight: 1
---

{{< toc >}}

KMS, Key Management Service, est le service de gestion de clés cryptographiques d'AWS. Une clé KMS peut être de trois types :
- `AWS owned key`
- `AWS managed key`
- `Customer Managed Key (CMK)`

Un HSM (Hardware Security Module) est un équipement matériel dédié et protégé physiquement contre les intrusions, qui génère, stocke et utilise des clés cryptographiques sans jamais les exposer en clair à l’extérieur. Ceux de KMS sont certifiés FIPS 140-3 niveau 3.

## AWS owned key

Une `AWS owned key` ne sort jamais de KMS. Elle est stockée dans les HSM de KMS.
Elle sert à chiffrer les données de certains services (ex: DynamoDB qui est chiffré au repos par défaut avec une `AWS owned key`).
Elle n'est pas dans le compte AWS du client : il ne peut ni la voir, ni consulter sa politique de clé (le document qui définit qui a le droit d'utiliser la clé), ni la gérer. Sa rotation est assurée par AWS, à un rythme qui varie selon les services.
Les usages de la clé sont non auditables.
La clé est donc utilisée par AWS et la même clé peut être utilisée pour chiffrer les données de plusieurs comptes clients.

## AWS managed key

Une `AWS managed key` ne sort jamais de KMS. Elle est stockée dans les HSM de KMS.
Elle sert à chiffrer par défaut les données de certains services, sans rien avoir à spécifier. Chaque service a la sienne, identifiée par un alias de la forme `aws/<service>` (ex: `aws/ebs` pour EBS, `aws/rds` pour RDS).
Sa politique de clé est consultable mais non modifiable. La clé ne peut pas être supprimée, et sa rotation est automatique : tous les ans, sans possibilité de changer ce rythme.
Les usages de la clé sont auditables.
Elle est propre au compte AWS.
Depuis 2021, AWS ne crée plus d'`AWS managed key` pour les nouveaux services, qui utilisent à la place une `AWS owned key` par défaut. On les rencontre donc surtout avec des services plus anciens, comme EBS ou RDS.

## Customer Managed Key (CMK)

Une CMK est une clé que le client crée lui-même dans son compte AWS. Il en contrôle la politique de clé et peut programmer sa suppression, avec un délai d'attente de 7 à 30 jours (la suppression est irréversible : les données chiffrées avec la clé deviennent indéchiffrables). Il peut aussi activer ou désactiver sa rotation automatique et en choisir la période (365 jours par défaut), mais seulement pour les clés symétriques dont le matériel est généré par KMS (origine `AWS_KMS`, voir ci-dessous).

Dans le cas d'une CMK, il y a plusieurs options pour l'origine du matériel cryptographique :
| Origine | Où est généré le matériel | Sort-il de KMS ? |
| ------- | ------- | ------- |
| AWS_KMS (par défaut) | Dans les HSM de KMS | Jamais |
| EXTERNAL (import, BYOK) | Chez vous, puis importé dans KMS | Vous en gardez une copie hors AWS |
| AWS_CLOUDHSM (custom key store) | Dans votre cluster CloudHSM | Il reste dans votre CloudHSM |
| EXTERNAL_KEY_STORE (XKS) | Dans votre gestionnaire de clés externe, hors d'AWS (matériel ou logiciel) | Il n’entre jamais dans KMS |

## Exemple : chiffrement d'un volume EBS

Les autres services AWS utilisés dans cet exemple :
- **EC2** (Elastic Compute Cloud) : les machines virtuelles d'AWS, appelées « instances ».
- **EBS** (Elastic Block Store) : les volumes de stockage en mode bloc qu'on attache aux instances EC2, c'est-à-dire leurs disques durs virtuels.
- **RDS** (Relational Database Service) : le service de bases de données relationnelles gérées par AWS (MySQL, PostgreSQL...). Pour la plupart des moteurs, les données et les journaux d'une instance RDS sont stockés sur des volumes EBS.

Les cartes Nitro sont des cartes électroniques conçues par AWS (via Annapurna Labs, une société qu'Amazon a rachetée en 2015). Elles équipent les instances EC2 de nouvelle génération, à partir des instances C5 lancées en 2017. Elles ont plusieurs rôles et dans notre exemple elles présentent les volumes EBS à la VM (l'instance RDS ou EC2) comme des disques NVMe locaux, alors qu'ils sont en réalité sur le réseau.

Dans cet exemple, je ne traite pas du cas des anciennes familles d'instances basées sur l'hyperviseur Xen (antérieures aux C5 de 2017).

Pour qu'un EBS d'une EC2 ou d'une RDS soit chiffré, le service demande à KMS de produire une data key. Une data key est une clé aléatoire qui est chiffrée grâce à la clé KMS choisie (`AWS managed key` ou CMK).
Cette data key chiffrée est stockée dans les métadonnées de l'EBS ou de la RDS : si elle est volée, elle est inutilisable sans le droit d'utiliser la clé KMS qui l'a chiffrée.
Le service (EC2 ou RDS) fait un appel KMS pour déchiffrer la data key et la stocke en clair uniquement dans la mémoire de la carte Nitro, tant que le volume est attaché à l'instance. La carte Nitro chiffre et déchiffre les blocs à la volée.

Ce mécanisme s'appelle le chiffrement d'enveloppe (*envelope encryption*) : les données sont chiffrées avec une data key, et cette data key est elle-même chiffrée avec une autre clé, ici la clé KMS. La data key chiffrée peut ainsi être stockée sans risque à côté des données qu'elle protège, et KMS n'est sollicité que pour déchiffrer la data key, pas pour chaque bloc du volume.

## Sources et références

- Types de clés KMS (AWS owned, AWS managed, customer managed), politique de clé, rotation, AWS managed keys plus créées pour les nouveaux services depuis 2021 : [AWS KMS concepts](https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html)
- HSM de KMS validés FIPS 140-3 niveau 3 : [AWS KMS overview](https://docs.aws.amazon.com/kms/latest/developerguide/overview.html)
- DynamoDB chiffré par défaut avec une AWS owned key : [DynamoDB encryption at rest](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/EncryptionAtRest.html)
- Suppression des clés KMS (CMK uniquement, délai de 7 à 30 jours) : [Delete an AWS KMS key](https://docs.aws.amazon.com/kms/latest/developerguide/deleting-keys.html)
- Rotation des clés KMS : [Rotate AWS KMS keys](https://docs.aws.amazon.com/kms/latest/developerguide/rotate-keys.html)
- Origine du matériel de clé (`AWS_KMS`, `EXTERNAL`, `AWS_CLOUDHSM`, `EXTERNAL_KEY_STORE`) : [Create keys](https://docs.aws.amazon.com/kms/latest/developerguide/create-keys.html) · [KeyMetadata (API KMS)](https://docs.aws.amazon.com/kms/latest/APIReference/API_KeyMetadata.html) · origine `AWS_KMS` par défaut : [CreateKey (API KMS)](https://docs.aws.amazon.com/kms/latest/APIReference/API_CreateKey.html) · [External key stores](https://docs.aws.amazon.com/kms/latest/developerguide/keystore-external.html)
- Définition d'EBS : [What is Amazon EBS?](https://docs.aws.amazon.com/ebs/latest/userguide/what-is-ebs.html) · stockage RDS sur des volumes EBS : [Amazon RDS DB instance storage](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html)
- Cartes Nitro, Annapurna Labs (rachat en 2015) : [The Security Design of the AWS Nitro System : the components of the Nitro System](https://docs.aws.amazon.com/whitepapers/latest/security-design-of-aws-nitro-system/the-components-of-the-nitro-system.html)
- Nitro à partir des instances C5 (2017) : [The Nitro System journey](https://docs.aws.amazon.com/whitepapers/latest/security-design-of-aws-nitro-system/the-nitro-system-journey.html) · [Annonce des instances C5, 6 novembre 2017](https://aws.amazon.com/about-aws/whats-new/2017/11/introducing-amazon-ec2-c5-instances-the-next-generation-of-compute-optimized-instances/)
- Volumes EBS présentés comme des disques NVMe : [Instances built on the Nitro System](https://docs.aws.amazon.com/ec2/latest/instancetypes/ec2-nitro-instances.html)
- Clé utilisée par défaut pour EBS : [EBS encryption examples](https://docs.aws.amazon.com/ebs/latest/userguide/encryption-examples.html) · pour RDS : [RDS encryption keys](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.Encryption.Keys.html)
- Data key, stockage avec le volume et clé en clair dans le matériel Nitro : [How EBS encryption works](https://docs.aws.amazon.com/ebs/latest/userguide/how-ebs-encryption-works.html)
- Chiffrement d'enveloppe : [AWS KMS cryptography essentials : envelope encryption](https://docs.aws.amazon.com/kms/latest/developerguide/kms-cryptography.html)
