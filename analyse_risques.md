# Analyse de Risques Globale & Modélisation des Menaces (Conformité ANSSI R10)

Ce document présente l'analyse de risques et la modélisation des chemins de compromission du projet **ASD**, conformément aux exigences de la recommandation **R10 de l'ANSSI**.

---

## 🗺️ 1. Chemins de Compromission & Vecteurs d'Attaque

L'analyse de risque identifie quatre grands vecteurs d'attaque sur notre architecture cloud et logicielle :

```
[Attaquant]
     │
     ├──► [Poste Développeur] ──────► Vol de jetons, Commits malveillants
     ├──► [Dépendances / Tierce] ───► Empoisonnement de packages (Supply Chain)
     ├──► [Chaîne CI/CD (GitHub)] ──► Compromission de runner, élévation AWS
     └──► [Infrastructure AWS] ────► Exploits réseau, accès API EKS, fuite BDD
```

---

## 🛡️ 2. Analyse Détaillée des Risques et Contre-Mesures

### Vecteur A : Compromission du Poste Développeur (Workstation Compromise)
* **Description** : Un attaquant compromet la machine d'un développeur (via phishing, malware) pour récupérer ses accès AWS/Git ou injecter du code malveillant directement dans le dépôt.
* **Gravité Potentielle** : Critique (accès direct au code source).

| Scénarios de Risque | Contre-Mesures Implémentées dans le Projet | Statut |
| :--- | :--- | :---: |
| **Fuite de clés d'accès AWS statiques** | **Zéro clé AWS statique** : Les développeurs utilisent l'authentification SSO via AWS IAM Identity Center. La CI/CD utilise des rôles OIDC temporaires sans secrets stockés. | **SÉCURISÉ** |
| **Commit de code malveillant usurpant l'identité** | **Signature des Commits obligatoire (R3)** : Intégration du workflow `check-signed-commits.yml` qui rejette toute PR contenant des commits non signés cryptographiquement par la clé privée du développeur. | **SÉCURISÉ** |
| **Poussée accidentelle de secrets (mots de passe, tokens)** | **Scan de Secrets pré-build (R1)** : Trivy FS analyse le dépôt local et la CI/CD à la recherche de secrets en clair avant chaque build. | **SÉCURISÉ** |

---

### Vecteur B : Risque de la Chaîne d'Approvisionnement (Supply Chain / Tierce partie)
* **Description** : Compromission de librairies externes (via empoisonnement de package pip) ou de l'image de base Nginx/Python.
* **Gravité Potentielle** : Élevée (exécution de code arbitraire dans les conteneurs).

| Scénarios de Risque | Contre-Mesures Implémentées dans le Projet | Statut |
| :--- | :--- | :---: |
| **Introduction de dépendances vulnérables** | **Scan de vulnérabilités applicatives (SCA) (R1)** : `pip-audit` analyse systématiquement le fichier `requirements.txt` du backend dans la CI/CD pour bloquer les packages vulnérables. | **SÉCURISÉ** |
| **Image de base Docker vulnérable** | **Hardening & Scan Trivy (R8)** : Utilisation d'images minimales (`python-slim`, `nginx-unprivileged:alpine`) et scan Trivy régulier des images construites avant déploiement. | **SÉCURISÉ** |
| **Substitution d'image Docker dans le registre (ECR)** | **Signature et Admission Control (R2)** : Les images ECR de production sont signées via Cosign, et le contrôleur d'admission Kyverno sur EKS bloque le démarrage de tout conteneur non signé. | **SÉCURISÉ** |

---

### Vecteur C : Compromission de la Chaîne CI/CD (GitHub Actions)
* **Description** : Un attaquant exploite un runner ou une vulnérabilité de workflow pour exécuter des scripts malveillants et tenter de s'emparer des droits d'administration AWS de la CI/CD.
* **Gravité Potentielle** : Critique (compromission de la Landing Zone).

| Scénarios de Risque | Contre-Mesures Implémentées dans le Projet | Statut |
| :--- | :--- | :---: |
| **Élévation de privilèges vers la Production depuis une branche de Dev** | **Ségrégation stricte des rôles OIDC (R4)** : Le rôle OIDC de Non-Prod n'a aucun droit sur le compte `prod`. Le rôle OIDC de Prod ne peut être endossé que depuis la branche `main` protégée. | **SÉCURISÉ** |
| **Persistance latérale sur les serveurs de build** | **Environnements éphémères (R5)** : Utilisation exclusive de runners virtuels vierges détruits immédiatement après usage. | **SÉCURISÉ** |

---

### Vecteur D : Compromission de l'Infrastructure Cloud (AWS / EKS / RDS)
* **Description** : Attaque réseau directe sur la base de données RDS, l'API EKS, ou rebond latéral depuis un pod compromis.
* **Gravité Potentielle** : Critique (fuite de données).

| Scénarios de Risque | Contre-Mesures Implémentées dans le Projet | Statut |
| :--- | :--- | :---: |
| **Accès direct et non authentifié à la base de données RDS** | **Réseau isolé & Moindre Privilège** : RDS est dans des subnets Data sans route internet. Le Security Group RDS n'autorise que les flux venant du SG d'EKS. Pas de SSH public (Bastion SSM privé uniquement). | **SÉCURISÉ** |
| **Rebond depuis un conteneur web compromis** | **Lecture seule et Network Policies (R8 & R9)** : Les pods tournent en lecture seule (`readOnlyRootFilesystem: true`), sans capacités Linux (`drop: [ALL]`). Les NetworkPolicies Kubernetes bloquent le trafic latéral. | **SÉCURISÉ** |
| **Prise de contrôle de l'API Server EKS** : | **EKS Access Entries & OIDC (R12)** : Remplacement de l'ancienne ConfigMap vulnérable `aws-auth` par les Access Entries natives gérées par AWS IAM. | **SÉCURISÉ** |
