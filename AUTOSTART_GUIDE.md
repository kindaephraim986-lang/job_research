# 📱 Guide de Démarrage Automatique - AfriJob

## 🚀 Démarrage Rapide

Vous avez maintenant **3 façons** de lancer l'application :

### **Option 1: Double-clic (Recommandé pour les utilisateurs non-techniques)**
1. Naviguez jusqu'à: `c:\Users\SYST\Desktop\mon_application_job\`
2. **Double-cliquez** sur `START_APP.bat`
3. L'application démarre automatiquement ✨

> **Note:** Un ou plusieurs terminaux PowerShell/CMD s'ouvriront. Ne les fermez pas pendant l'utilisation de l'application.

---

### **Option 2: PowerShell (Pour les utilisateurs avancés)**
1. Ouvrez **PowerShell** en tant qu'administrateur
2. Naviguez vers le répertoire de l'application:
   ```powershell
   cd C:\Users\SYST\Desktop\mon_application_job
   ```
3. Lancez le script:
   ```powershell
   .\start_app.ps1
   ```

---

### **Option 3: Windows Task Scheduler (Pour l'exécution en cron/planifiée)**

#### **Créer une tâche planifiée:**

1. **Ouvrir le Planificateur de tâches:**
   - Appuyez sur `Win + R`
   - Tapez `taskschd.msc` et appuyez sur Entrée

2. **Créer une action simple:**
   - Menu latéral gauche → **Bibliothèque du Planificateur de tâches**
   - Actions (droite) → **Créer une tâche**

3. **Onglet "Général":**
   - Nom: `AfriJob App Startup`
   - Description: `Démarrage automatique de l'application AfriJob (Backend + Frontend)`
   - Cochez: ✓ "Exécuter avec les autorisations les plus élevées"
   - ✓ "Exécuter que l'utilisateur soit connecté ou non"

4. **Onglet "Déclencheurs":**
   - Cliquez: **Nouveau**
   - Sélectionnez ce qui déclenche la tâche:
     - **À l'ouverture de session** (lance au démarrage Windows)
     - **À une heure planifiée** (p.ex. 8h du matin quotidiennement)
   - Cliquez **OK**

5. **Onglet "Actions":**
   - Cliquez: **Nouvelle**
   - Action: **Démarrer un programme**
   - Programme/script: `C:\Windows\System32\cmd.exe`
   - Ajouter des arguments: `/c start "" "C:\Users\SYST\Desktop\mon_application_job\START_APP.bat"`
   - Cliquez **OK**

6. **Onglet "Conditions":**
   - Décochez toutes les conditions pour assurer l'exécution systématique

7. **Onglet "Paramètres":**
   - Cochez: ✓ "Arrêter la tâche si elle s'exécute plus de..." → **30 minutes**
   - Décochez: ☐ "N'arrêter le programme que s'il existe"

8. **Cliquez "OK"** pour enregistrer

---

## 🔍 Résolution de Problèmes

### **La page affiche un message "Impossible de se connecter au serveur"**

**Cause probable:** Le backend (Node.js) n'a pas pu démarrer.

**Solutions:**
1. ✓ Vérifiez que **Node.js est installé:**
   ```powershell
   node --version
   ```
   Si absent, téléchargez depuis: https://nodejs.org/

2. ✓ Vérifiez que les dépendances backend sont installées:
   ```powershell
   cd C:\Users\SYST\Desktop\mon_application_job\backend
   npm install
   ```

3. ✓ Vérifiez que **MySQL/WampServer** est en cours d'exécution:
   - Ouvrez WampServer
   - Vérifiez que MySQL est ✓ **Vert**
   - Base de données: `bddiane_sp`

4. ✓ Vérifiez les logs du backend:
   - Regardez le terminal Node.js pour les erreurs
   - Assurez-vous que le port **3001** est libre

5. ✓ Vérifiez les variables d'environnement (`.env`):
   ```
   c:\Users\SYST\Desktop\mon_application_job\backend\.env
   ```
   Exemple:
   ```
   PORT=3001
   DB_HOST=localhost
   DB_USER=root
   DB_PASSWORD=
   DB_NAME=bddiane_sp
   ```

### **La page est blanche mais pas de message d'erreur**

- Appuyez sur **F12** pour ouvrir les outils de développement
- Allez à l'onglet **Console**
- Cherchez les messages d'erreur rouges
- Partagez-les pour diagnostic

### **Impossible d'arrêter l'application avec Ctrl+C**

- Fermez la fenêtre du terminal (elle arrêtera tous les processus)
- Ou tapez `exit` puis Entrée

---

## 📊 Architecture du Démarrage Automatique

```
START_APP.bat (Clic-démarrer)
    ↓
start_app.ps1 (Script PowerShell)
    ├─ Vérification Node.js
    ├─ Vérification Flutter
    ├─ Démarrage du Backend (Node.js)
    │   └─ Écoute sur http://localhost:3001
    ├─ Attente (5 secondes)
    ├─ Vérification de disponibilité (/api/health)
    ├─ Démarrage du Frontend (Flutter Web)
    │   └─ Vérifie la connexion API
    │   └─ Gestion gracieuse des erreurs
    └─ Nettoyage à la fermeture
```

---

## 🆕 Améliorations Apportées

### **Frontend (Flutter)**
- ✅ **Vérification API au démarrage** - Vérifie que le serveur est accessible avant de charger l'app
- ✅ **Gestion d'erreur améliorée** - Affiche un message clair au lieu d'une page blanche
- ✅ **Bouton "Réessayer"** - Permet à l'utilisateur de réessayer la connexion
- ✅ **URL du serveur affichée** - Aide au diagnostic

### **Démarrage Automatique**
- ✅ **Détection des dépendances** - Vérifie Node.js et Flutter
- ✅ **Arrêt propre** - Gère les processus existants
- ✅ **Vérification de disponibilité** - Attend que le backend soit prêt
- ✅ **Logs colorés** - Messages de progression clairs
- ✅ **Nettoyage automatique** - Arrête tous les processus à la fermeture

---

## 📝 Variables d'Environnement

### Frontend
```dart
// Fichier: frontend/lib/config/app_config.dart
API_BASE_URL=http://localhost:3001/api  // Peut être surchargé via --dart-define
```

### Backend
```bash
# Fichier: backend/.env
PORT=3001
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=bddiane_sp
CORS_ORIGIN=http://localhost:3000,http://192.168.11.123:8080
```

---

## 🎯 Pour les Tâches Planifiées (Cron)

Si vous voulez que l'application **démarre automatiquement sur un calendrier**, utilisez **Windows Task Scheduler** (voir Option 3 ci-dessus).

Exemple:
- **Tous les jours à 8h du matin** - Pour démarrer automatiquement le matin
- **À l'ouverture de la session** - Dès que vous vous connectez à Windows
- **Une fois par semaine** - Pour les vérifications régulières

---

## ✨ Prochaines Étapes

1. **Testez le démarrage automatique:**
   - Lancez `START_APP.bat`
   - Vérifiez que l'application s'ouvre dans le navigateur
   - Testez la connexion/inscription

2. **Si tout fonctionne:**
   - Vous pouvez créer un raccourci Windows pour `START_APP.bat`
   - Ou configurer une tâche planifiée (voir Option 3)

3. **Besoin d'aide?**
   - Vérifiez la section "Résolution de Problèmes" ci-dessus
   - Consultez les logs du backend et du frontend (F12 pour le frontend)

---

**Version:** 1.0  
**Dernière mise à jour:** 18 Juin 2026  
**Créé pour:** Plateforme AfriJob
