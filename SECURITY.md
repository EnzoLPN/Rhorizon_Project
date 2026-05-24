# Politique de Sécurité et Posture DevSecOps (ASD)

Ce document décrit la posture de sécurité du projet **ASD** et adresse spécifiquement les exigences de confidentialité, de souveraineté et de conformité réglementaire (notamment vis-à-vis des règles de l'**ANSSI**).

---

## 🔒 1. Politique de Confidentialité & Souveraineté de la CI/CD (R6)

La recommandation **R6 de l'ANSSI** exige d'être vigilant sur les besoins en confidentialité vis-à-vis de l'infrastructure de CI/CD (localisation physique du code source, exécution des tests dans des environnements tiers SaaS publics).

### Posture Actuelle :
* **Hébergement du Code & Métadonnées** : Le code source est stocké sur la plateforme SaaS publique **GitHub**. Les builds et les tests automatisés sont exécutés sur des runners managés publics (Ubuntu) situés dans les datacenters de GitHub (principalement aux États-Unis ou en Europe).
* **Atténuation des risques** : 
  * Aucun secret persistant ou clé d'API statique n'est stocké dans GitHub. L'accès aux ressources AWS se fait via des jetons temporaires générés par **OIDC AWS** à chaque exécution.
  * Les secrets applicatifs (mots de passe de base de données, clés d'API tierces) sont stockés dans **AWS Secrets Manager** et injectés à la volée dans les pods Kubernetes (via Secrets Store CSI Driver). Ils ne sont jamais imprimés dans les journaux d'exécution de la CI/CD.

### Option de Souveraineté (Migration vers des Runners Auto-Hébergés) :
Si le niveau de sensibilité du projet exige une souveraineté totale des flux et du code :
1. **Migration des Runners** : Configurer des runners auto-hébergés (**Self-hosted runners**) déployés au sein d'instances EC2 sécurisées dans le VPC privé d'AWS, ou sur une infrastructure souveraine européenne (ex: OVHcloud, Scaleway, Outscale).
2. **Couplage Réseau** : Ces runners communiqueront uniquement par requêtes sortantes vers GitHub et n'exposeront aucun port sur Internet.
3. **Localisation des Tests** : L'analyse statique du code, la compilation et le packaging des conteneurs s'exécuteront entièrement au sein de la frontière réseau souveraine contrôlée par l'organisation.

---

## 🔑 2. Gestion des Identités & Moindre Privilège (R4 & R11)

L'accès administrateur à l'infrastructure de production via la CI/CD est traité comme une action d'administration critique :
* **Isolation des Rôles** : Nous avons configuré deux rôles OIDC séparés. Le rôle de Non-Prod est incapable d'accéder ou de modifier les ressources de Production.
* **Restriction par Branche** : Le rôle de production (`shared-github-actions-prod-role`) ne peut être endossé **que** par du code poussé sur la branche `main` après validation manuelle. Les branches de développement et les pull requests ne peuvent en aucun cas y accéder.
* **Traçabilité** : Toutes les demandes de rôles OIDC et les actions associées au niveau des API AWS sont journalisées en continu dans **AWS CloudTrail** et exportées vers notre S3 centralisé d'audit.

---

## 📦 3. Sécurité des Images & des Conteneurs (R2 & R8)

L'intégrité de la chaîne de distribution logicielle est assurée par :
* **Signature Cryptographique** : Chaque image Docker poussée vers ECR est signée via **Cosign** à l'aide d'une clé privée.
* **Vérification active (Admission Control)** : Le cluster EKS exécute le contrôleur d'admission **Kyverno** qui rejette automatiquement toute image provenant de notre registre `rhzorion/*` s'il lui manque une signature valide.
* **Exécution sans privilège** : Tous nos conteneurs applicatifs s'exécutent avec des profils d'utilisateurs non-root (UID `10001` pour le backend, `nginx-unprivileged` sur Alpine pour le frontend) et la directive EKS `runAsNonRoot: true`.

---

## 🚨 4. Signalement de Vulnérabilités

Si vous découvrez une vulnérabilité de sécurité dans ce projet, merci de ne pas ouvrir de ticket public. Veuillez contacter l'équipe de sécurité à l'adresse suivante : `security-team@votre-domaine.xyz`.
