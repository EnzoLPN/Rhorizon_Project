# 🎨 Correspondance Draw.io / Principes ANSSI

Ce tableau vous aide à traduire les concepts de sécurité de votre architecture en éléments visuels clairs pour vos schémas Draw.io.

| Composant Architectural | Symbole / Icône AWS (Draw.io) | Principe ANSSI / Concept de Sécurité | Comment le représenter visuellement |
| :--- | :--- | :--- | :--- |
| **Ségrégation des Comptes** | Cadres globaux (AWS Cloud / Account) | **Isolation logique** (Guide DevSecOps) | Un grand rectangle contenant tout un environnement. Le nom du compte en gras (ex: `Compte Shared-Services`). Ne jamais croiser les cadres. |
| **AWS WAFv2** | AWS > Security, Identity > *WAF* | **Filtrage périmétrique** (OWASP, protection frontale) | Une icône WAF placée sur le trait du `VPC`, en amont de l'Application Load Balancer (ALB). |
| **Private Subnets** | Cadre de sous-réseau (Couleur bleu clair) | **Zones de confiance isolées** | Un rectangle encadrant vos nœuds EKS. Ajouter une icône de "Cadenas" (Lock) ou un texte "No Public IP". |
| **Data Subnets (RDS)** | Cadre de sous-réseau (Couleur plus foncée) | **Isolation du back-end de données** | Un rectangle encadrant RDS. Mettre un trait en pointillés entre l'EKS et la RDS pour symboliser que seul ce flux est autorisé. |
| **VPC Endpoints (PrivateLink)** | AWS > Networking > *Endpoint* (Interface) | **Privatisation des flux** (Pas de transit Internet) | Petits cercles `VPC Endpoint` placés dans les `Private Subnets`, avec des flèches allant vers KMS ou ECR. |
| **AWS KMS (Chiffrement)** | AWS > Security, Identity > *Key Management Service* | **Chiffrement au repos** (Principe de moindre privilège) | Icône de clé placée près des buckets S3 et des bases RDS. Ajouter un lien vers le compte `Shared-Services`. |
| **S3 Object Lock** | AWS > Storage > *S3 Bucket* + Icône de Coffre/Cadenas | **Immutabilité des traces (Audit)** | Icône de Bucket S3 avec le texte "Object Lock" ou un petit cadenas dessiné dessus. |
| **GitHub Actions (OIDC)** | Logo GitHub + AWS > Security > *IAM OIDC Provider* | **Suppression des secrets statiques** (Authentification par jeton) | Lier le logo GitHub au fournisseur OIDC avec une flèche nommée "AssumeRoleWithWebIdentity". |
| **Rôles IAM (IRSA)** | AWS > Security, Identity > *IAM Role* | **Moindre privilège applicatif** | Placer un petit personnage ou l'icône de rôle "attaché" directement sur les Pods (ex: Backend Pod). |
| **Bastion SSM** | AWS > Management > *Systems Manager* + EC2 | **Administration sécurisée** (Zero Trust, pas de SSH ouvert) | Placer une icône EC2 dans le sous-réseau privé, reliée à l'icône "Session Manager". |
| **Approbation Manuelle (CI/CD)** | Icône "Validation" ou Cadenas entre deux étapes | **Double regard / Contrôle humain** avant la Prod | Un point d'arrêt rouge ou un cadenas sur la flèche qui relie l'étape de scan (Trivy) au déploiement EKS. |
| **Kyverno (Admission Control)** | Icône Kubernetes (Volant/Police) | **Validation de l'intégrité** de la chaîne logicielle | Une "barrière de péage" ou un checkmark vert à l'entrée du Control Plane EKS (vérification de la signature Cosign). |

---

## 🛠️ Code d'import automatique Draw.io

Vous pouvez copier-coller le code ci-dessous directement dans Draw.io (**Arrange > Insert > Advanced > CSV...**) pour générer automatiquement une grille de cartes techniques colorées par thématique de sécurité.

```text
##
## Import CSV pour le Mapping de Sécurité ANSSI (ASD Project)
##
#
## Style des étiquettes (HTML autorisé)
# label: <div style="font-size:14px;margin-bottom:6px;"><b>%Composant%</b></div><div style="font-size:11px;opacity:0.8;"><i>%Principe_ANSSI%</i></div><hr><div style="font-size:10px;margin-top:6px;">%Description%</div>
#
## Style des nœuds (Utilisation des couleurs par catégorie)
# style: rounded=1;whiteSpace=wrap;html=1;fillColor=%Fill%;strokeColor=#232F3E;fontColor=%FontColor%;arcSize=10;align=left;spacingLeft=10;
#
## Configuration du layout
# layout: grid
# nodespacing: 20
# width: 220
# height: 110
#
## ---- Données CSV ci-dessous ----
Composant,Principe_ANSSI,Description,Fill,FontColor
Ségrégation Comptes,Isolation Logique,Isolation stricte entre Shared/NP/Prod,#232F3E,#ffffff
AWS WAFv2,Filtrage Périmétrique,Protection L7 contre OWASP Top 10,#FF9900,#000000
VPC Endpoints,Privatisation Flux,Pas de transit internet (PrivateLink),#7AA116,#ffffff
S3 Object Lock,Immutabilité Audit,Preuves d'audit non supprimables,#D05C5C,#ffffff
KMS Encryption,Chiffrement Repos,Chiffrement systématique via clés maîtres,#7AA116,#ffffff
GitHub OIDC,Zéro Secret Statique,Authentification par jetons éphémères,#232F3E,#ffffff
EKS IRSA,Moindre Privilège App,Rôles IAM dédiés par Pod Kubernetes,#FF9900,#000000
Bastion SSM,Accès Sécurisé,Administration Zero-Trust sans port SSH,#D05C5C,#ffffff
Kyverno Check,Intégrité Logicielle,Vérification de signature d'image à l'entrée,#7AA116,#ffffff
Délégation DNS,Souveraineté Nommage,Délégation récursive entre zones DNS,#232F3E,#ffffff
```
