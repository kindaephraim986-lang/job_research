# Script de démarrage automatique du backend et du frontend
# Démarre le serveur Node.js et l'application Flutter

$ErrorActionPreference = "Stop"

# Chemins vers les répertoires
$backendPath = "C:\Users\SYST\Desktop\mon_application_job\backend"
$frontendPath = "C:\Users\SYST\Desktop\mon_application_job\frontend"
$appName = "Job Research - AfriJob"

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     $appName      ║" -ForegroundColor Cyan
Write-Host "║     Démarrage automatique du serveur et de l'application  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Vérifier si Node.js est installé
Write-Host "✓ Vérification des dépendances..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version
    Write-Host "  ✓ Node.js détecté: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Node.js n'est pas installé ou non accessible" -ForegroundColor Red
    exit 1
}

# Vérifier si Flutter est installé
try {
    $flutterVersion = flutter --version
    Write-Host "  ✓ Flutter détecté" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Flutter n'est pas installé ou non accessible" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Vérifier si le backend est déjà en cours d'exécution
$backendProcess = Get-Process node -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "node" }

if ($backendProcess) {
    Write-Host "⚠ Un processus Node.js est déjà en cours d'exécution" -ForegroundColor Yellow
    Write-Host "  Voulez-vous arrêter les processus existants ? (O/N): " -ForegroundColor Yellow -NoNewline
    $response = Read-Host
    if ($response -eq "O" -or $response -eq "o") {
        Write-Host "  Arrêt des processus Node.js..." -ForegroundColor Yellow
        Stop-Process -Name node -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    }
}

# Démarrer le backend
Write-Host "▶ Démarrage du backend (Node.js)..." -ForegroundColor Cyan
Write-Host "  Répertoire: $backendPath" -ForegroundColor Gray
Write-Host "  Port: 3001" -ForegroundColor Gray

try {
    # Vérifier que le fichier server.js existe
    if (-not (Test-Path "$backendPath\server.js")) {
        Write-Host "  ✗ Fichier server.js introuvable" -ForegroundColor Red
        exit 1
    }

    # Démarrer le serveur en arrière-plan
    $backendJob = Start-Process -FilePath "node" -ArgumentList "server.js" `
                                 -WorkingDirectory $backendPath `
                                 -PassThru `
                                 -NoNewWindow

    Write-Host "  ✓ Serveur backend démarré (PID: $($backendJob.Id))" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Erreur lors du démarrage du backend: $_" -ForegroundColor Red
    exit 1
}

# Attendre que le backend soit prêt
Write-Host ""
Write-Host "⏳ Attente du démarrage du serveur (5 secondes)..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Vérifier que le backend est accessible
Write-Host "🔍 Vérification de la disponibilité du serveur..." -ForegroundColor Cyan
$serverReady = $false
$attempts = 0
$maxAttempts = 10

while (-not $serverReady -and $attempts -lt $maxAttempts) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3001/api/health" `
                                     -Method GET `
                                     -TimeoutSec 2 `
                                     -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            $serverReady = $true
            Write-Host "  ✓ Serveur accessible sur http://localhost:3001" -ForegroundColor Green
        }
    } catch {
        $attempts++
        if ($attempts -lt $maxAttempts) {
            Write-Host "  ⏳ Tentative $attempts/$maxAttempts..." -ForegroundColor Gray
            Start-Sleep -Seconds 1
        }
    }
}

if (-not $serverReady) {
    Write-Host "  ⚠ Le serveur ne répond pas après $maxAttempts tentatives" -ForegroundColor Yellow
    Write-Host "  Vérifiez les logs du backend ou assurez-vous que la base de données est accessible" -ForegroundColor Yellow
}

Write-Host ""

# Démarrer le frontend
Write-Host "▶ Démarrage du frontend (Flutter)..." -ForegroundColor Cyan
Write-Host "  Répertoire: $frontendPath" -ForegroundColor Gray

try {
    # Vérifier que pubspec.yaml existe
    if (-not (Test-Path "$frontendPath\pubspec.yaml")) {
        Write-Host "  ✗ Fichier pubspec.yaml introuvable" -ForegroundColor Red
        Stop-Process -Id $backendJob.Id -Force -ErrorAction SilentlyContinue
        exit 1
    }

    # Changer de répertoire et démarrer Flutter
    Push-Location $frontendPath
    
    Write-Host "  Récupération des dépendances (flutter pub get)..." -ForegroundColor Gray
    & flutter pub get | Out-Null

    Write-Host "  ✓ Dépendances Flutter à jour" -ForegroundColor Green
    Write-Host "  Lancement de l'application web..." -ForegroundColor Gray
    
    & flutter run -d web

    Pop-Location
} catch {
    Write-Host "  ✗ Erreur lors du démarrage du frontend: $_" -ForegroundColor Red
    Stop-Process -Id $backendJob.Id -Force -ErrorAction SilentlyContinue
    exit 1
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║     Application fermée                                      ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green

# Nettoyage: arrêter le backend quand le frontend est fermé
Write-Host ""
Write-Host "Arrêt du serveur backend..." -ForegroundColor Yellow
Stop-Process -Id $backendJob.Id -Force -ErrorAction SilentlyContinue
Write-Host "✓ Tous les processus arrêtés" -ForegroundColor Green
