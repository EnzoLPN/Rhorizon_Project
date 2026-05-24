# Guide de Développement Sécurisé (ASD)

Ce document régit les règles et standards de développement sécurisé à respecter par l'ensemble des contributeurs du projet **ASD**, conformément aux exigences de la recommandation **R7 de l'ANSSI**.

---

## 🛡️ 1. Prévention des Injections SQL

L'une des vulnérabilités les plus critiques est l'injection SQL. 
* **Règle absolue** : **Ne jamais concaténer** de variables ou de chaînes de caractères pour construire des requêtes SQL.
* **Bonne Pratique** : Utiliser systématiquement les requêtes paramétrées fournies par le driver de base de données (`psycopg2`). Les valeurs utilisateur doivent être passées en tant que tuple de paramètres distinct.

### ❌ Mauvaise Pratique (Vulnérable) :
```python
# VULNÉRABLE - N'utilisez jamais cette syntaxe !
cur.execute("SELECT * FROM employees WHERE name = '" + data['name'] + "';")
```

###  Bonne Pratique (Sécurisée) :
```python
# SÉCURISÉ - Paramétrage natif
cur.execute("SELECT * FROM employees WHERE name = %s;", (data['name'],))
```

---

## 🌐 2. Sécurisation des Politiques CORS (Cross-Origin Resource Sharing)

Pour empêcher des sites malveillants d'appeler notre API depuis le navigateur d'un utilisateur légitime :
* **Développement** : L'origine wildcard (`*`) est autorisée par défaut dans l'environnement local.
* **Production** : La politique CORS doit être restreinte aux domaines officiels du projet. Elle est configurée via la variable d'environnement `ALLOWED_CORS_ORIGINS`.

### Exemple de configuration :
```python
# Chargement des origines autorisées depuis l'environnement
allowed_origins = os.environ.get("ALLOWED_CORS_ORIGINS", "https://votre-domaine.xyz").split(",")
CORS(app, resources={r"/api/*": {"origins": allowed_origins}})
```

---

## 🚨 3. Gestion des Erreurs et Fuites d'Informations

L'affichage de traces d'appels (stack traces) ou de messages d'erreurs internes détaillés (détails de connexion DB, structure des tables) fournit des indices précieux aux attaquants.
* **Règle** : Les erreurs système internes doivent être journalisées avec un niveau `ERROR` côté serveur, mais renvoyer un message d'erreur générique et sécurisé à l'utilisateur.

### ❌ Mauvaise Pratique :
```python
except Exception as e:
    # Renvoyer l'erreur brute peut divulguer le mot de passe ou la structure SQL
    return jsonify({"error": str(e)}), 500
```

###  Bonne Pratique :
```python
except Exception as e:
    logger.error(f"Error updating employee: {e}") # Log complet interne
    return jsonify({"error": "Failed to update employee"}), 500 # Message générique externe
```

---

## 🐳 4. Durcissement des Images Docker & Privilèges

* **Images Minimales** : Toujours privilégier des images de base allégées (ex: `-slim`, `-alpine` ou `distroless`) afin de réduire la surface d'attaque et le nombre de packages vulnérables pré-installés.
* **Utilisateur Non-Root** : Ne jamais exécuter un conteneur en tant que `root`. Un utilisateur non-privilégié doit être explicitement créé et déclaré dans le Dockerfile :
  ```dockerfile
  RUN useradd -u 10001 appuser && chown -R appuser:appuser /app
  USER appuser
  ```

---

## 🔍 5. Outils d'Analyse Statique (SAST) Locaux

Avant de pousser vos modifications sur Git, il est recommandé de lancer les analyseurs de sécurité en local :
1. **Sécurité Python (Bandit)** :
   ```bash
   pip install bandit
   bandit -r app/backend/ -ll
   ```
2. **Scan de Fichiers & Secrets (Trivy)** :
   ```bash
   trivy fs app/frontend/
   ```
