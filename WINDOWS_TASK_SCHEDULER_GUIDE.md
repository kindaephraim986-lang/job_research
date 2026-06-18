# 📅 Configuration Windows Task Scheduler - Exécution en Cron

## 🎯 Objectif
Faire démarrer automatiquement votre application AfriJob **sans intervention manuelle** à une heure définie ou au démarrage de Windows.

---

## 📋 Prérequis
- ✅ Windows 10 ou supérieur
- ✅ Accès administrateur
- ✅ Le fichier `START_APP.bat` créé (dans le répertoire racine)
- ✅ MySQL/WampServer configuré et prêt

---

## 🚀 Étape 1: Ouvrir le Planificateur de Tâches

1. Appuyez sur les touches: **`Win + R`**
2. Tapez: **`taskschd.msc`**
3. Appuyez sur **Entrée**
4. L'application **Planificateur de tâches** s'ouvre

> 💡 Alternative: Menu Démarrer → Recherchez "Planificateur de tâches"

---

## 🔧 Étape 2: Créer une Nouvelle Tâche

1. Dans le volet **gauche**, sélectionnez: **Bibliothèque du Planificateur de tâches**
2. Dans le volet **droit** (Actions), cliquez sur: **Créer une tâche...**

![Étape 2](./docs/scheduler_step1.png)

---

## 📝 Étape 3: Configurer l'Onglet "Général"

Une fenêtre **"Créer une tâche"** s'ouvre.

### A. Nom de la tâche
- **Champ "Nom":** Tapez: `AfriJob Auto-Startup`
- **Description:** `Démarrage automatique du serveur Backend et Frontend - AfriJob`

### B. Paramètres de sécurité
- ✓ Cochez: **"Exécuter avec les autorisations les plus élevées"**
- ✓ Cochez: **"Exécuter que l'utilisateur soit connecté ou non"**
- Système d'exploitation: **Windows 10 ou supérieur** (le vôtre)

### C. Configuration (section bas)
- **Configurer pour:** Windows 10 ou supérieur ✓

![Étape 3](./docs/scheduler_step2.png)

---

## ⏰ Étape 4: Configurer le Déclencheur (Quand exécuter)

1. Cliquez sur l'onglet: **"Déclencheurs"**
2. Cliquez sur le bouton: **"Nouveau..."**

### Option A: Au Démarrage Windows (Recommandé)
```
Déclencheur: Au démarrage
Délai: 30 secondes (optionnel, pour attendre le démarrage complet)
État: ✓ Activé
```

### Option B: À une Heure Fixe Chaque Jour
```
Déclencheur: Selon un calendrier
Récurrence: Quotidienne
Heure: 08:00 (exemple: 8h du matin)
État: ✓ Activé
```

### Option C: À l'Ouverture de la Session
```
Déclencheur: À l'ouverture de session
État: ✓ Activé
```

3. Cliquez **OK** après configuration

![Étape 4](./docs/scheduler_step3.png)

---

## ▶️ Étape 5: Configurer l'Action (Quoi exécuter)

1. Cliquez sur l'onglet: **"Actions"**
2. Cliquez sur le bouton: **"Nouvelle..."**

### Configuration de l'action
```
Action: Démarrer un programme

Programme/script: 
C:\Windows\System32\cmd.exe

Ajouter des arguments (paramètres):
/c start "" "C:\Users\SYST\Desktop\mon_application_job\START_APP.bat"

Dossier de départ (répertoire de travail):
C:\Users\SYST\Desktop\mon_application_job\
```

### Explication
- **Programme:** `cmd.exe` lance l'invite de commandes
- **Paramètres:** `/c` exécute la commande, puis ferme (sauf si l'app s'exécute)
- **Chemin du script:** Le chemin complet vers `START_APP.bat`
- **Dossier de départ:** Permet au script de trouver les fichiers relatives

3. Cliquez **OK**

![Étape 5](./docs/scheduler_step4.png)

---

## 🔐 Étape 6: Configurer les Conditions (Optionnel)

1. Cliquez sur l'onglet: **"Conditions"**

### Recommandations
- ☐ **Décochez:** "Ne démarrer la tâche que si l'ordinateur est sur batterie"
- ☐ **Décochez:** "N'arrêter que si l'ordinateur bascule sur batterie"
- ☐ **Décochez:** "Arrêter la tâche si elle s'exécute plus de..."
- ✓ **Cochez:** "S'il est déjà en cours d'exécution, appliquer la règle:" → **"Ne pas démarrer une nouvelle instance"**

![Étape 6](./docs/scheduler_step5.png)

---

## ⚙️ Étape 7: Configurer les Paramètres Avancés

1. Cliquez sur l'onglet: **"Paramètres"**

### Configuration Recommandée
```
☐ Arrêter la tâche si elle s'exécute plus de: [NON COCHÉ]
✓ S'il est déjà en cours d'exécution, appliquer la règle: "Ne pas démarrer une nouvelle instance"
✓ Arrêter la tâche s'il existe une instance en cours d'exécution
✓ Autoriser la tâche à être demandée à la demande
☐ Ajouter des majuscules à tous les chemins d'accès locaux (tâche historique)
```

![Étape 7](./docs/scheduler_step6.png)

---

## ✅ Étape 8: Enregistrer la Tâche

1. Cliquez sur le bouton: **"OK"**
2. Vous serez peut-être invité à entrer le mot de passe administrateur
3. Tapez votre mot de passe Windows et appuyez sur **Entrée**

La tâche est maintenant créée et active! ✨

---

## 🧪 Étape 9: Tester la Tâche

### Test 1: Exécution Manuelle
1. Dans le **Planificateur de tâches**, recherchez votre tâche: **`AfriJob Auto-Startup`**
2. **Clic droit** → Sélectionnez **"Exécuter"**
3. La tâche doit démarrer le serveur et l'application

### Test 2: Au Démarrage Windows
1. **Redémarrez votre ordinateur**
2. Attendez quelques secondes après l'ouverture de session
3. L'application devrait se lancer automatiquement

### Test 3: À l'Heure Programmée
1. Attendez l'heure que vous avez configurée
2. L'application devrait démarrer automatiquement

---

## 🔍 Dépannage

### La tâche ne s'exécute pas
**Problème:** La tâche est créée mais n'exécute rien

**Solutions:**
1. ✓ Vérifiez que la tâche est **activée** (voir Conditions)
2. ✓ Vérifiez que l'onglet **Général** a: **"Exécuter avec les autorisations les plus élevées"** ✓
3. ✓ Consultez les **Historiques** de la tâche:
   - **Clic droit** sur la tâche → **Propriétés** → **Onglet "Historique"**
   - Cherchez les messages d'erreur rouges

### "Accès refusé" ou erreur d'autorisation
**Cause:** Les autorisations administrateur ne sont pas suffisantes

**Solution:**
- Répétez l'étape 3 et cochez: **"Exécuter avec les autorisations les plus élevées"** ✓

### "Fichier introuvable"
**Cause:** Le chemin du script `START_APP.bat` est incorrect

**Solution:**
- Vérifiez que le fichier existe:
  ```
  C:\Users\SYST\Desktop\mon_application_job\START_APP.bat
  ```
- Corrigez le chemin à l'étape 5 si nécessaire

### L'application démarre mais affiche "page blanche"
- C'est un problème de backend, pas de Task Scheduler
- Consultez: **AUTOSTART_GUIDE.md** → Section "Résolution de Problèmes"

---

## 📊 Vérifier l'Exécution

Après avoir créé la tâche, vous pouvez vérifier son historique:

1. Dans le **Planificateur de tâches**
2. Sélectionnez votre tâche: **`AfriJob Auto-Startup`**
3. Cliquez sur l'onglet: **"Historique"**
4. Vous verrez:
   - ✓ Dernière exécution
   - ✓ Durée de l'exécution
   - ✓ Message de résultat

---

## 🎯 Cas d'Usage Courants

### **Démarrage automatique chaque matin à 8h**
```
Déclencheur: Selon un calendrier
Récurrence: Quotidienne
Heure: 08:00
Jours: Lun, Mar, Mer, Jeu, Ven (au travail)
```

### **Au démarrage de Windows (24h/24)**
```
Déclencheur: Au démarrage
Délai: 30 secondes
```

### **À l'ouverture de la session (quand vous vous connectez)**
```
Déclencheur: À l'ouverture de session
```

### **Après une mise à jour Windows (une fois par semaine)**
```
Déclencheur: Selon un calendrier
Récurrence: Hebdomadaire (tous les lundis à 09:00)
```

---

## ⏹️ Arrêter ou Désactiver la Tâche

Si vous souhaitez **arrêter** la tâche sans la supprimer:

1. **Planificateur de tâches** → Sélectionnez votre tâche
2. **Clic droit** → **Désactiver**

Pour **réactiver:**
1. **Clic droit** → **Activer**

Pour **supprimer définitivement:**
1. **Clic droit** → **Supprimer**

---

## 📝 Notes Importantes

⚠️ **La tâche démarre le script en arrière-plan** - Les fenêtres du terminal peuvent ne pas être visibles si elles s'exécutent sans l'utilisateur connecté. Vous pouvez:
- Vérifier les logs du backend/frontend
- Accéder à l'application via le navigateur: `http://localhost:3000`

⚠️ **S'il y a des conflits de port:**
- Le port `3001` pour le backend doit être libre
- Vous pouvez modifier le port dans `backend/.env` si nécessaire

---

## 🆘 Besoin d'Aide?

Consultez:
- **AUTOSTART_GUIDE.md** - Guide général de démarrage automatique
- **README.md** - Documentation du projet
- **backend/DEMARRAGE.md** - Guide spécifique au backend

---

**Version:** 1.0  
**Dernière mise à jour:** 18 Juin 2026  
**Pour:** Windows 10 ou supérieur
