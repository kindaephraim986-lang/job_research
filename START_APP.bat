@echo off
REM Script de démarrage automatique - Clic-démarrer pour Windows
REM Double-cliquez sur ce fichier pour démarrer automatiquement le backend et le frontend

setlocal enabledelayedexpansion
cd /d "%~dp0"

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║     Job Research - AfriJob                                  ║
echo ║     Démarrage automatique du serveur et de l'application   ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM Vérifier que PowerShell est disponible
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo ✗ PowerShell n'est pas accessible
    pause
    exit /b 1
)

REM Exécuter le script PowerShell
powershell -NoProfile -ExecutionPolicy Bypass -File "start_app.ps1"

pause
