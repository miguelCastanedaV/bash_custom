#!/usr/bin/env bash

# ==============================================================================
# INSTALADOR DE .bash.custom - Miguel Castañeda
# Repositorio: https://github.com/miguelCastanedaV/bash_custom
# ==============================================================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuración del repositorio
GITHUB_USER="miguelCastanedaV"
GITHUB_REPO="bash_custom"
BRANCH="main"
BASHCUSTOM_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/.bash.custom"

# Archivos
CUSTOM_FILE=".bash.custom"
LOCAL_FILE="$HOME/${CUSTOM_FILE}"

# Funciones de log
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

# Detectar shell
detect_shell() {
    if [[ -n "$ZSH_VERSION" ]]; then
        SHELL_RC="$HOME/.zshrc"
        SHELL_NAME="zsh"
    elif [[ -n "$BASH_VERSION" ]]; then
        SHELL_RC="$HOME/.bashrc"
        SHELL_NAME="bash"
    else
        SHELL_RC="$HOME/.bashrc"
        SHELL_NAME="bash"
        log_warning "Shell no identificado, usando bash por defecto"
    fi
    log_info "Shell detectado: ${SHELL_NAME}"
}

# Verificar si ya está instalado
check_installed() {
    if [[ -f "$LOCAL_FILE" ]]; then
        log_warning "El archivo ${CUSTOM_FILE} ya existe en ${LOCAL_FILE}"
        echo -n "¿Deseas sobrescribirlo? (s/n): "
        read -r response
        if [[ ! "$response" =~ ^[Ss]$ ]]; then
            log_info "Instalación cancelada"
            exit 0
        fi
    fi
}

# Descargar .bash.custom
download_file() {
    log_info "Descargando ${CUSTOM_FILE} desde GitHub..."
    
    if command -v curl &> /dev/null; then
        if curl -fsSL "$BASHCUSTOM_URL" -o "$LOCAL_FILE"; then
            log_success "Archivo descargado a ${LOCAL_FILE}"
        else
            log_error "Error al descargar el archivo"
            exit 1
        fi
    elif command -v wget &> /dev/null; then
        if wget -q "$BASHCUSTOM_URL" -O "$LOCAL_FILE"; then
            log_success "Archivo descargado a ${LOCAL_FILE}"
        else
            log_error "Error al descargar el archivo"
            exit 1
        fi
    else
        log_error "Se requiere curl o wget. Instala con:"
        log_error "  Ubuntu/Debian: sudo apt install curl"
        log_error "  macOS: brew install curl"
        exit 1
    fi
    
    # Verificar que no esté vacío
    if [[ ! -s "$LOCAL_FILE" ]]; then
        log_error "El archivo descargado está vacío"
        exit 1
    fi
    
    chmod 644 "$LOCAL_FILE"
}

# Configurar shell
configure_shell() {
    local shell_rc="$1"
    
    log_info "Configurando ${shell_rc}..."
    
    # Crear backup si existe
    if [[ -f "$shell_rc" ]]; then
        cp "$shell_rc" "${shell_rc}.backup.$(date +%Y%m%d_%H%M%S)"
        log_success "Backup creado: ${shell_rc}.backup"
    fi
    
    # Remover configuraciones anteriores de este script
    if [[ -f "$shell_rc" ]]; then
        grep -v "source.*${CUSTOM_FILE}" "$shell_rc" | \
        grep -v "# miguelCastanedaV/bash_custom" > "${shell_rc}.tmp" 2>/dev/null || true
        mv "${shell_rc}.tmp" "$shell_rc"
    fi
    
    # Agregar la nueva configuración
    echo "" >> "$shell_rc"
    echo "# ==============================================================================" >> "$shell_rc"
    echo "# Configuración de aliases personalizados" >> "$shell_rc"
    echo "# Repositorio: https://github.com/miguelCastanedaV/bash_custom" >> "$shell_rc"
    echo "# Instalado el $(date)" >> "$shell_rc"
    echo "# ==============================================================================" >> "$shell_rc"
    echo "if [ -f ~/${CUSTOM_FILE} ]; then" >> "$shell_rc"
    echo "    source ~/${CUSTOM_FILE}" >> "$shell_rc"
    echo "fi" >> "$shell_rc"
    echo "" >> "$shell_rc"
    
    log_success "Configuración agregada a ${shell_rc}"
}

# Instalación principal
main() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}    INSTALADOR DE .bash.custom - miguelCastanedaV          ${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    detect_shell
    check_installed
    download_file
    configure_shell "$SHELL_RC"
    
    # Mostrar resumen
    echo ""
    log_success "¡Instalación completada exitosamente!"
    echo ""
    echo -e "${YELLOW}Resumen:${NC}"
    echo "  • Archivo instalado: ${LOCAL_FILE}"
    echo "  • Shell configurado: ${SHELL_NAME}"
    echo "  • Configuración en: ${SHELL_RC}"
    echo ""
    echo -e "${YELLOW}Para usar los aliases inmediatamente:${NC}"
    echo "  source ${SHELL_RC}"
    echo ""
    echo -e "${YELLOW}O abre una nueva terminal.${NC}"
    echo ""
    echo -e "${YELLOW}Comandos disponibles después de la instalación:${NC}"
    echo "  • updatealiases  - Actualizar aliases desde GitHub"
    echo "  • editbash       - Editar el archivo .bash.custom"
    echo "  • sourcebash     - Recargar los aliases"
    echo "  • showaliases    - Mostrar todos los aliases"
    echo ""
}

# Ejecutar
main "$@"