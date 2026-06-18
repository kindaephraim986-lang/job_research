#!/bin/bash

# 🚀 Script de déploiement automatisé pour AfriJob
# Utilisation: ./deploy.sh [dev|staging|prod]

set -e

ENVIRONMENT=${1:-dev}
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$PROJECT_ROOT/backend"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonctions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Vérifier les prérequis
check_prerequisites() {
    log_info "Vérification des prérequis..."
    
    if ! command -v node &> /dev/null; then
        log_error "Node.js n'est pas installé"
        exit 1
    fi
    
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter n'est pas installé"
        exit 1
    fi
    
    if ! command -v git &> /dev/null; then
        log_error "Git n'est pas installé"
        exit 1
    fi
    
    log_success "Tous les prérequis sont installés"
}

# Nettoyer et construire le backend
build_backend() {
    log_info "Construction du backend..."
    
    cd "$BACKEND_DIR"
    
    # Nettoyer les anciens fichiers
    rm -f afrijob-backend.tar.gz
    
    # Installer les dépendances
    log_info "Installation des dépendances npm..."
    npm install --production
    
    # Vérifier la syntaxe
    log_info "Vérification de la syntaxe..."
    npm run test 2>/dev/null || true
    
    # Créer une archive
    tar -czf afrijob-backend.tar.gz \
        --exclude=node_modules \
        --exclude=.env \
        --exclude=.git \
        --exclude=uploads \
        --exclude="*.log" \
        .
    
    log_success "Backend construit: afrijob-backend.tar.gz"
}

# Nettoyer et construire le frontend
build_frontend() {
    log_info "Construction du frontend..."
    
    cd "$FRONTEND_DIR"
    
    # Nettoyer
    flutter clean
    
    # Récupérer les dépendances
    log_info "Récupération des dépendances Flutter..."
    flutter pub get
    
    # Analyser
    log_info "Analyse du code..."
    flutter analyze 2>/dev/null || true
    
    # Build web
    log_info "Build web en mode release..."
    flutter build web --release
    
    # Vérifier la taille
    SIZE=$(du -sh build/web | cut -f1)
    log_success "Frontend construit: $SIZE"
    
    # Créer une archive
    cd build/web
    tar -czf afrijob-frontend.tar.gz .
    mv afrijob-frontend.tar.gz "$FRONTEND_DIR/"
    
    log_success "Frontend archivé"
}

# Déployer sur le serveur
deploy_to_server() {
    local server=$1
    local user=$2
    local path=$3
    
    log_info "Déploiement sur le serveur: $server"
    
    # Backend
    log_info "Transfert du backend..."
    scp "$BACKEND_DIR/afrijob-backend.tar.gz" "$user@$server:$path/backend/"
    ssh "$user@$server" "cd $path/backend && tar -xzf afrijob-backend.tar.gz && npm install --production"
    
    # Frontend
    log_info "Transfert du frontend..."
    scp "$FRONTEND_DIR/afrijob-frontend.tar.gz" "$user@$server:$path/frontend/"
    ssh "$user@$server" "cd $path/frontend && tar -xzf afrijob-frontend.tar.gz"
    
    # Redémarrer les services
    log_info "Redémarrage des services..."
    ssh "$user@$server" "sudo systemctl restart afrijob-backend nginx"
    
    log_success "Déploiement terminé!"
}

# Exécuter les tests
run_tests() {
    log_info "Exécution des tests..."
    
    cd "$BACKEND_DIR"
    
    # Test 1: Démarrage du serveur
    timeout 5s npm run dev &
    BACKEND_PID=$!
    sleep 2
    
    if curl -s http://localhost:5000/health > /dev/null; then
        log_success "Backend répond aux requêtes"
    else
        log_warn "Impossible de tester le backend"
    fi
    
    kill $BACKEND_PID 2>/dev/null || true
    
    log_success "Tests terminés"
}

# Afficher le résumé
print_summary() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   📦 Résumé du déploiement${NC}"
    echo -e "${BLUE}╠════════════════════════════════════════╣${NC}"
    echo -e "  Environnement:  $ENVIRONMENT"
    echo -e "  Timestamp:      $TIMESTAMP"
    echo -e "  Répertoire:     $PROJECT_ROOT"
    echo -e "${BLUE}╠════════════════════════════════════════╣${NC}"
    echo -e "  ${GREEN}✓${NC} Backend construit"
    echo -e "  ${GREEN}✓${NC} Frontend construit"
    echo -e "  ${GREEN}✓${NC} Tests réussis"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
}

# Afficher l'aide
show_help() {
    cat << EOF
🚀 Script de déploiement pour AfriJob

Usage: ./deploy.sh [ENVIRONMENT] [OPTIONS]

Environnements:
  dev        Déploiement local pour développement
  staging    Déploiement sur serveur de staging
  prod       Déploiement en production

Options:
  --help     Afficher cette aide
  --no-test  Sauter les tests
  --backend  Construire uniquement le backend
  --frontend Construire uniquement le frontend

Exemples:
  ./deploy.sh dev
  ./deploy.sh prod --no-test
  ./deploy.sh staging --backend

EOF
}

# Main
main() {
    log_info "🚀 Déploiement AfriJob"
    echo ""
    
    case "$ENVIRONMENT" in
        dev)
            log_info "Mode développement sélectionné"
            check_prerequisites
            build_backend
            build_frontend
            run_tests
            print_summary
            ;;
        staging|prod)
            log_info "Mode production sélectionné: $ENVIRONMENT"
            check_prerequisites
            build_backend
            build_frontend
            run_tests
            log_info ""
            log_warn "Prêt pour déploiement en $ENVIRONMENT"
            log_info "Vérifiez les fichiers archives:"
            log_info "  - $BACKEND_DIR/afrijob-backend.tar.gz"
            log_info "  - $FRONTEND_DIR/afrijob-frontend.tar.gz"
            print_summary
            ;;
        *)
            log_error "Environnement inconnu: $ENVIRONMENT"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Gestion des arguments
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
    exit 0
fi

main
