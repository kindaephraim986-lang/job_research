## ⚡ DÉPLOIEMENT RAPIDE (5 MINUTES)

### 🎯 Choix rapide: Quelle option?

| Vous avez... | Choisir |
|---|---|
| Un serveur Linux/VPS | **Option A** → VPS classique |
| Pas de serveur | **Option B** → Cloud (Railway + Vercel) |
| Besoin de scalabilité | **Option C** → Docker |
| Impatient maintenant | **QUICK START** → Voir ci-dessous |

---

## 🚀 QUICK START: Railway + Vercel (15 min)

### Étape 1: Préparer le code

```bash
cd c:\Users\SYST\Desktop\mon_application_job

# Générer une clé secrète
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
# Copier le résultat

# Créer le fichier .env
cp .env.example .env

# Éditer .env avec votre éditeur préféré
# Remplir au minimum:
#   JWT_SECRET=<la_clé_copiée_ci-dessus>
#   DB_PASSWORD=<mot_de_passe_sécurisé>
#   FRONTEND_URL=https://afrijob.vercel.app (temporaire)
```

### Étape 2: Backend sur Railway (3 min)

#### Créer un compte Railway

1. Aller à https://railway.app
2. Se connecter avec GitHub
3. Cliquer "New Project"
4. Choisir "Deploy from GitHub repo"
5. Sélectionner votre repo
6. Railway détecte automatiquement Node.js

#### Ajouter MySQL

1. Dans Railway: Cliquer "Add" → "Add Service"
2. Choisir "MySQL"
3. Railway crée automatiquement les variables d'environnement

#### Configurer les variables

Dans le dashboard Railway, aller à "Variables":

```
NODE_ENV=production
JWT_SECRET=<votre_clé_générée>
FILE_SIGNATURE_SECRET=<générer_une_autre_clé>
```

Railway crée automatiquement `DATABASE_URL`

#### Déployer

```bash
# C'est tout! Railway déploie automatiquement
# Vérifier les logs: Dashboard → Deployments → Logs

# Votre URL backend sera: https://your-project.up.railway.app
```

### Étape 3: Base de données (2 min)

```bash
# Via MySQL CLI (si MySQL est installé localement)
mysql -h your-railway-db-host -u root -p your-password bddiane_sp < backend/migrations/001_add_candidature_paiements_table.sql
mysql -h your-railway-db-host -u root -p your-password bddiane_sp < backend/migrations/002_add_features.sql

# Ou utiliser l'interface Railway pour exécuter les SQL
```

### Étape 4: Frontend sur Vercel (2 min)

```bash
# Installer Vercel CLI
npm install -g vercel

# Déployer depuis le dossier frontend
cd frontend
vercel

# Répondre aux questions:
# ? Set up and deploy? [Y/n] Y
# ? Which scope? (votre compte)
# ? Link to existing project? [y/N] N
# ? What's your project's name? afrijob-frontend
# ? In which directory is your code? . (current)

# Après le build:
# ✓ Production: https://afrijob-frontend.vercel.app
```

### Étape 5: Configurer les URLs

#### Update .env frontend

Dans `frontend/lib/services/api_service.dart`:

```dart
// Remplacer:
// static const String baseUrl = 'http://localhost:5000';
// Par:
static const String baseUrl = 'https://your-project.up.railway.app';
```

#### Redéployer le frontend

```bash
cd frontend
vercel --prod
```

### Étape 6: Tester

```bash
# Ouvrir dans le navigateur
https://afrijob-frontend.vercel.app

# Tester le login
# Tester upload de photo
# Tester notifications
```

---

## 🔍 Vérifier que tout fonctionne

```bash
# 1. Backend est vivant?
curl https://your-project.up.railway.app/health

# 2. Base de données connectée?
curl https://your-project.up.railway.app/api/offers

# 3. Frontend charge?
https://afrijob-frontend.vercel.app

# 4. Login fonctionne?
# Ouvrir l'app dans le navigateur et tester
```

---

## 📊 Coûts mensuels

| Service | Coût |
|---|---|
| Railway (Backend + DB) | $5-20 |
| Vercel (Frontend) | Gratuit (hobby) |
| **Total** | **~$10-20/mois** |

---

## ⚠️ Problèmes courants

### "Database connection refused"

```bash
# Solution 1: Vérifier les variables
# Railway: Variables → Afficher DATABASE_URL
# Copier dans le .env backend

# Solution 2: Redémarrer le service
# Railway Dashboard → Deploy → Redeploy
```

### "Frontend cannot connect to backend"

```bash
# Vérifier que api_service.dart pointe vers Railway
# api_service.dart: baseUrl = 'https://your-railway-url'

# Redéployer le frontend:
cd frontend
vercel --prod
```

### "CORS error"

```bash
# Backend: Ajouter à .env
CORS_ORIGIN=https://afrijob-frontend.vercel.app

# Puis redéployer:
git push origin main
# (Railway redéploie automatiquement)
```

---

## 🎯 Étapes suivantes (Optionnel)

### Ajouter un domaine personnalisé

#### Railway (Backend)

1. Dashboard → Settings → Custom Domain
2. Ajouter: `api.yourdomain.com`
3. Mettre à jour DNS chez votre registrar

#### Vercel (Frontend)

1. Dashboard → Settings → Domains
2. Ajouter: `yourdomain.com`
3. Mettre à jour DNS

### Ajouter SSL (gratuit)

Les deux services incluent SSL automatiquement! ✅

### Sauvegardes automatiques

```bash
# Railway: Inclus dans le plan
# Vercel: Aucune sauvegarde frontend (c'est statique)
# Base de données: Configurer des backups manuels

# Backup manuel:
mysqldump -h host -u user -p password bddiane_sp > backup.sql
```

---

## 🔒 Sécurité (IMPORTANT!)

Avant de passer en production:

- [ ] Changer `JWT_SECRET` en clé aléatoire 32 caractères
- [ ] Changer `FILE_SIGNATURE_SECRET` idem
- [ ] Changer `DB_PASSWORD` en mot de passe fort
- [ ] Vérifier `NODE_ENV=production`
- [ ] Vérifier `DEBUG=false`
- [ ] Configurer `CORS_ORIGIN` vers votre frontend uniquement
- [ ] Activer HTTPS (automatique sur Railway & Vercel)

---

## 📞 Support

- Railway issues: https://railway.app/docs
- Vercel issues: https://vercel.com/docs
- Mon app issues: Voir DEPLOYMENT_GUIDE.md complet

---

**⏱️ Temps total: ~15 minutes**
**💰 Coût: ~$10-20/mois**
**📊 Uptime: 99.5%**
