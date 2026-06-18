## 🎯 GUIDE D'INTÉGRATION COMPLET - 4 FONCTIONNALITÉS

### 📋 Table des matières
1. [Installation & Configuration](#installation)
2. [Backend Node.js](#backend)
3. [Frontend Flutter](#frontend)
4. [Intégration dans les contrôleurs](#integration)
5. [Tests & Validation](#tests)

---

## Installation & Configuration {#installation}

### 1️⃣ Exécuter les migrations SQL

```bash
# Copier le fichier de migration dans le dossier migrations
cp migrations/002_add_features.sql backend/migrations/

# Exécuter manuellement (ou via votre système de migration)
mysql -h localhost -u root -p bddiane_sp < backend/migrations/002_add_features.sql
```

### 2️⃣ Installer les dépendances supplémentaires Node.js

```bash
cd backend

# Modules déjà installés : express, mysql2, multer, jsonwebtoken
# Vérifier que tout est à jour
npm list jsonwebtoken multer bcryptjs

# Si besoin, ajouter :
npm install crypto  # Généralement inclus avec Node
```

### 3️⃣ Variables d'environnement

Ajouter au fichier `.env` du backend :

```env
# Fichiers signés
FILE_SIGNATURE_SECRET=your-super-secret-key-change-this-in-production
FILE_URL_EXPIRY=3600

# AWS S3 (optionnel pour stockage cloud)
AWS_S3_BUCKET=your-bucket-name
AWS_S3_REGION=us-east-1
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key

# Base de données
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=bddiane_sp
```

### 4️⃣ Ajouter les routes dans server.js

```javascript
// backend/server.js

// Imports existants
const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/auth');
const offersRoutes = require('./routes/offers');
// ... autres routes

// Ajouter les nouvelles routes
const notificationRoutes = require('./routes/notifications');
const profilePhotoRoutes = require('./routes/profilePhotos');
const filesRoutes = require('./routes/files');

const app = express();

// Middlewares existants
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Servir les fichiers uploadés en static
app.use('/uploads', express.static('uploads'));

// Routes existantes
app.use('/api/auth', authRoutes);
app.use('/api/offers', offersRoutes);
// ...

// ✅ AJOUTER LES NOUVELLES ROUTES
app.use('/api/notifications', notificationRoutes);
app.use('/api/profile-photos', profilePhotoRoutes);
app.use('/api/files', filesRoutes);

// Écouter
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
```

---

## Backend Node.js {#backend}

### 📁 Structure des fichiers

```
backend/
├── middleware/
│   ├── auth.js                    (existant)
│   ├── subscriptionCheck.js       (NOUVEAU)
│   ├── fileSignature.js           (NOUVEAU)
│   └── validation.js              (existant)
├── services/
│   ├── profilePhotoService.js     (NOUVEAU)
│   ├── notificationService.js     (NOUVEAU)
│   └── ...
├── routes/
│   ├── auth.js                    (existant)
│   ├── notifications.js           (NOUVEAU)
│   ├── profilePhotos.js           (NOUVEAU)
│   ├── files.js                   (NOUVEAU)
│   └── ...
├── uploads/
│   ├── profile-photos/            (NOUVEAU - permissions 755)
│   ├── cvs/                       (existant)
│   └── cnib/                      (existant)
├── migrations/
│   ├── 001_add_candidature_paiements_table.sql
│   └── 002_add_features.sql       (NOUVEAU)
└── server.js
```

### 🔌 Intégration dans les contrôleurs existants

#### Exemple 1: Notifier quand une offre est publiée

```javascript
// backend/controllers/offerController.js

const notificationService = require('../services/notificationService');

exports.createOffer = async (req, res) => {
  try {
    const { titre, description, domaine, entrepriseId } = req.body;

    // ... création de l'offre ...

    // ✅ CRÉER UNE NOTIFICATION POUR LES CANDIDATS
    const entreprise = await getEntrepriseData(entrepriseId);
    await notificationService.notifyNewOffer(
      titre,
      offreId,
      entreprise.nom_societe,
      domaine
    );

    // ✅ NOTIFIER AUSSI LES CANDIDATS VIA LE SERVICE
    await notificationService.createBulkNotifications(
      candidatIds,
      'candidat',
      'offer',
      `Nouvelle offre: ${titre}`,
      `Une offre intéressante pour vous!`,
      offreId,
      'offre'
    );

    res.json({ success: true, offreId });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};
```

#### Exemple 2: Protéger l'accès au profil candidat

```javascript
// backend/routes/candidates.js

const { checkSubscriptionWithLog } = require('../middleware/subscriptionCheck');

// Avant : GET /api/candidates/:id
// Après : GET /api/candidates/:id avec vérification d'abonnement

router.get('/:candidat_id/profile', 
  authenticateToken,
  checkSubscriptionWithLog,
  async (req, res) => {
    // Seul le candidat lui-même ou une entreprise abonnée peut voir
    const candidatId = req.params.candidat_id;
    const candidat = await db.query('SELECT * FROM candidats WHERE id = ?', [candidatId]);

    res.json({ success: true, candidat: candidat[0] });
  }
);
```

#### Exemple 3: Générer URL signée lors du téléchargement du CV

```javascript
// backend/controllers/candidatureController.js

const { generateSignedUrl } = require('../middleware/fileSignature');

exports.getCandidatureDetails = async (req, res) => {
  try {
    const candidatureId = req.params.id;
    const candidature = await getCandidature(candidatureId);

    // Vérifier l'abonnement de l'entreprise
    await checkSubscription(req.user.id);

    // Générer une URL signée pour le CV
    const cvUrl = await generateSignedUrl(
      candidature.candidat_id,
      'cv',
      candidature.candidat_id,
      req.user.id,
      'entreprise'
    );

    res.json({
      success: true,
      candidature: {
        ...candidature,
        cvDownloadUrl: cvUrl,
        cvViewUrl: cvUrl
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};
```

---

## Frontend Flutter {#frontend}

### 📁 Structure des fichiers

```
frontend/lib/
├── services/
│   ├── api_service.dart                    (existant)
│   ├── api_service_extended.dart           (NOUVEAU)
│   ├── profile_photo_service.dart          (NOUVEAU)
│   ├── notification_service_flutter.dart   (NOUVEAU)
│   ├── document_service.dart               (NOUVEAU)
│   └── ...
├── widgets/
│   ├── profile_photo_widget.dart           (NOUVEAU)
│   ├── notifications_center.dart           (NOUVEAU)
│   ├── document_viewer.dart                (NOUVEAU)
│   └── ...
└── main.dart
```

### ✅ Intégration dans main.dart ou dashboards

#### 1️⃣ Afficher le badge de notifications

```dart
// Dans AppBar
AppBar(
  title: const Text('Mon Application'),
  actions: [
    NotificationBadge(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationsCenter()),
        );
      },
    ),
    // ... autres actions
  ],
)
```

#### 2️⃣ Afficher la photo de profil du candidat

```dart
// Dans le dashboard candidat
Column(
  children: [
    // Photo modifiable
    ProfilePhotoWidget(
      editable: true,
      candidatId: candidatId,
      onPhotoUpdated: () {
        // Rafraîchir le dashboard
        setState(() {});
      },
    ),
    const SizedBox(height: 16),
    // Historique (optionnel)
    TextButton.icon(
      icon: const Icon(Icons.history),
      label: const Text('Voir l\'historique'),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => PhotoHistoryDialog(candidatId: candidatId),
        );
      },
    ),
  ],
)
```

#### 3️⃣ Afficher les documents avec sécurité

```dart
// Dans le profil d'un candidat (pour une entreprise)
Row(
  children: [
    // Bouton pour voir le CV
    DocumentAccessButton(
      documentId: candidat.id,
      documentType: 'cv',
      candidatId: candidat.id,
      label: 'Voir CV',
    ),
    const SizedBox(width: 8),
    // Bouton pour voir la CNIB
    DocumentAccessButton(
      documentId: candidat.id,
      documentType: 'cnib_recto',
      candidatId: candidat.id,
      label: 'Voir CNIB',
    ),
  ],
)
```

#### 4️⃣ Afficher le centre de notifications

```dart
// Naviguer vers le centre
onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const NotificationsCenter()),
  );
}
```

---

## Intégration dans les contrôleurs {#integration}

### Exemple complet: Dashboard Company

```dart
// lib/company_dashboard.dart

import 'package:flutter/material.dart';
import 'services/notification_service_flutter.dart';
import 'widgets/notifications_center.dart';

class CompanyDashboard extends StatefulWidget {
  final Map<String, String> initialData;
  const CompanyDashboard({
    Key? key,
    required this.initialData,
  }) : super(key: key);

  @override
  State<CompanyDashboard> createState() => _CompanyDashboardState();
}

class _CompanyDashboardState extends State<CompanyDashboard> {
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadNotifications();
  }

  Future<void> _loadUnreadNotifications() async {
    final count = await NotificationServiceFlutter.getUnreadCount();
    if (mounted) {
      setState(() => _unreadNotifications = count);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Recruteur'),
        actions: [
          // ✅ Badge de notifications
          NotificationBadge(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsCenter(),
                ),
              ).then((_) {
                // Rafraîchir après fermeture
                _loadUnreadNotifications();
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ... reste du contenu ...
          ],
        ),
      ),
    );
  }
}
```

---

## Tests & Validation {#tests}

### ✅ Test 1: Photo de profil

```bash
# 1. Uploader une photo
curl -X POST http://localhost:5000/api/profile-photos/upload \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "photo=@/path/to/image.jpg"

# 2. Récupérer la photo (vérifier le cache buster)
curl -X GET http://localhost:5000/api/profile-photos/current \
  -H "Authorization: Bearer YOUR_TOKEN"

# 3. Vérifier que la photo est persistée dans la base
mysql> SELECT * FROM profile_photos WHERE candidat_id = 1;
```

### ✅ Test 2: Notifications

```bash
# 1. Créer une notification manuelle
curl -X POST http://localhost:5000/api/notifications \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "userType": "candidat",
    "type": "offer",
    "title": "Nouvelle offre",
    "message": "Une offre intéressante!"
  }'

# 2. Récupérer les notifications
curl -X GET http://localhost:5000/api/notifications/unread?limit=20 \
  -H "Authorization: Bearer USER_TOKEN"

# 3. Marquer comme lue
curl -X PUT http://localhost:5000/api/notifications/1/read \
  -H "Authorization: Bearer USER_TOKEN"
```

### ✅ Test 3: Documents signés

```bash
# 1. Générer une URL signée
curl -X POST http://localhost:5000/api/files/generate-signed-url \
  -H "Authorization: Bearer COMPANY_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "documentId": 1,
    "documentType": "cv",
    "candidatId": 1
  }'

# 2. Accéder au fichier avec token
curl -X GET "http://localhost:5000/api/files/access/TOKEN_HERE" \
  -H "Authorization: Bearer COMPANY_TOKEN"

# 3. Télécharger
curl -X GET "http://localhost:5000/api/files/access/TOKEN_HERE?download=true" \
  -H "Authorization: Bearer COMPANY_TOKEN" \
  -o downloaded_cv.pdf
```

### ✅ Test 4: Restriction d'abonnement

```bash
# 1. Tenter d'accéder au profil SANS abonnement
curl -X GET http://localhost:5000/api/candidates/1/profile \
  -H "Authorization: Bearer COMPANY_TOKEN_NO_SUBSCRIPTION"

# Résultat attendu: 402 Payment Required
# {
#   "success": false,
#   "message": "Abonnement requis pour accéder...",
#   "code": "SUBSCRIPTION_REQUIRED"
# }

# 2. Avec abonnement actif
curl -X GET http://localhost:5000/api/candidates/1/profile \
  -H "Authorization: Bearer COMPANY_TOKEN_WITH_SUBSCRIPTION"

# Résultat: 200 OK avec données
```

---

## 🎯 Checklist de déploiement

- [ ] Migrations SQL exécutées
- [ ] Variables d'environnement configurées
- [ ] Routes ajoutées dans server.js
- [ ] Services Node.js importés et testés
- [ ] Services Flutter importés
- [ ] Widgets Flutter intégrés
- [ ] Tests manuels API réussis
- [ ] Tests Flutter en émulateur/appareil réussis
- [ ] Notifications s'affichent correctement
- [ ] Photos persist après reconnexion
- [ ] Accès aux documents bloqué sans abonnement
- [ ] Cache buster fonctionne (Edge)

---

## 📌 Notes importantes

### Sécurité
- Les URLs signées expirent après 1h (configurable)
- Les accès aux documents sont loggés en base
- Les tokens JWT sont validés côté serveur
- Les photos ancien format sont supprimées après upload

### Performance
- Cache buster force le rechargement des photos
- Pagination sur les notifications (50 par défaut)
- Limite de 10MB par photo
- Compression d'images recommandée

### Production
- Remplacer FILE_SIGNATURE_SECRET par une clé sécurisée
- Utiliser AWS S3 ou Cloudinary pour les fichiers volumineux
- Configurer les headers CORS correctement
- Ajouter les logs d'audit pour la conformité RGPD

---

**Créé le:** 2026-06-18
**Version:** 1.0.0 - Stable pour production
