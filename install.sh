#!/bin/bash
#==============================================================================
#  MR-LINMACHNIC Installer
#  The Machine That Repairs Linux
#  Author: Madan Raj
#  License: Free & Open Source
#==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

INSTALL_DIR="/opt/mr-linmachnic"
BIN_LINK="/usr/local/bin/mr-machine"

print_banner() {
    clear
    echo -e "${CYAN}"
    echo "  ╔══════════════════════════════════════════════════════════════╗"
    echo "  ║                                                              ║"
    echo "  ║   ███╗   ███╗██████╗       ███╗   ███╗ █████╗  ██████╗██╗  ║"
    echo "  ║   ████╗ ████║██╔══██╗      ████╗ ████║██╔══██╗██╔════╝██║  ║"
    echo "  ║   ██╔████╔██║██████╔╝█████╗██╔████╔██║███████║██║     ██║  ║"
    echo "  ║   ██║╚██╔╝██║██╔══██╗╚════╝██║╚██╔╝██║██╔══██║██║     ██║  ║"
    echo "  ║   ██║ ╚═╝ ██║██║  ██║      ██║ ╚═╝ ██║██║  ██║╚██████╗██║  ║"
    echo "  ║   ╚═╝     ╚═╝╚═╝  ╚═╝      ╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ║"
    echo "  ║                                                              ║"
    echo "  ║         🛠️  MR-LINMACHNIC INSTALLER v1.0  🛠️               ║"
    echo "  ║         The Machine That Repairs Linux                       ║"
    echo "  ║         Author: Madan Raj                                    ║"
    echo "  ║                                                              ║"
    echo "  ╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

print_step() {
    echo -e "  ${GREEN}[✓]${NC} ${WHITE}$1${NC}"
}

print_info() {
    echo -e "  ${BLUE}[ℹ]${NC} ${DIM}$1${NC}"
}

print_warn() {
    echo -e "  ${YELLOW}[⚠]${NC} ${YELLOW}$1${NC}"
}

print_error() {
    echo -e "  ${RED}[✗]${NC} ${RED}$1${NC}"
}

spinner() {
    local pid=$1
    local msg=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) % ${#spin} ))
        printf "\r  ${CYAN}[${spin:$i:1}]${NC} ${DIM}%s${NC}" "$msg"
        sleep 0.1
    done
    printf "\r"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This installer must be run as root (use sudo)"
        echo -e "  ${DIM}Usage: sudo bash install.sh${NC}"
        echo ""
        exit 1
    fi
}

check_dependencies() {
    echo -e "  ${CYAN}━━━ Checking Dependencies ━━━${NC}"
    echo ""
    
    local deps=("bash" "grep" "awk" "sed" "curl" "systemctl" "journalctl")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if command -v "$dep" &>/dev/null; then
            print_step "$dep found"
        else
            print_warn "$dep not found (optional)"
            missing+=("$dep")
        fi
    done
    
    echo ""
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        print_warn "Some optional tools are missing. The tool will work but some features may be limited."
    else
        print_step "All dependencies satisfied!"
    fi
    echo ""
}

install_files() {
    echo -e "  ${CYAN}━━━ Installing MR-LINMACHNIC ━━━${NC}"
    echo ""
    
    # Create installation directory
    print_info "Creating installation directory..."
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$INSTALL_DIR/modules"
    mkdir -p "$INSTALL_DIR/lib"
    mkdir -p "$INSTALL_DIR/data"
    mkdir -p "$INSTALL_DIR/logs"
    mkdir -p "$INSTALL_DIR/plugins"
    print_step "Directory structure created"
    
    # Get source directory
    SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Copy main files
    print_info "Copying core files..."
    cp "$SOURCE_DIR/mr-machine.sh" "$INSTALL_DIR/mr-machine.sh"
    chmod +x "$INSTALL_DIR/mr-machine.sh"
    print_step "Core controller installed"
    
    # Copy modules
    print_info "Copying diagnostic modules..."
    if [[ -d "$SOURCE_DIR/modules" ]]; then
        cp -r "$SOURCE_DIR/modules/"* "$INSTALL_DIR/modules/" 2>/dev/null || true
    fi
    print_step "Modules installed"
    
    # Copy library files
    print_info "Copying library files..."
    if [[ -d "$SOURCE_DIR/lib" ]]; then
        cp -r "$SOURCE_DIR/lib/"* "$INSTALL_DIR/lib/" 2>/dev/null || true
    fi
    print_step "Libraries installed"
    
    # Copy data files
    print_info "Copying knowledge database..."
    if [[ -d "$SOURCE_DIR/data" ]]; then
        cp -r "$SOURCE_DIR/data/"* "$INSTALL_DIR/data/" 2>/dev/null || true
    fi
    print_step "Knowledge database installed"
    
    # Make all scripts executable
    find "$INSTALL_DIR" -name "*.sh" -exec chmod +x {} \;
    print_step "Permissions set"
    
    # Create global symlink
    print_info "Creating global command link..."
    ln -sf "$INSTALL_DIR/mr-machine.sh" "$BIN_LINK"
    print_step "Global command 'mr-machine' created"
    
    echo ""
}

verify_installation() {
    echo -e "  ${CYAN}━━━ Verifying Installation ━━━${NC}"
    echo ""
    
    if [[ -x "$BIN_LINK" ]]; then
        print_step "Global command verified"
    else
        print_error "Global command verification failed"
        exit 1
    fi
    
    if [[ -d "$INSTALL_DIR/modules" ]]; then
        local module_count
        module_count=$(find "$INSTALL_DIR/modules" -name "*.sh" | wc -l)
        print_step "$module_count modules installed"
    fi
    
    if [[ -d "$INSTALL_DIR/data" ]]; then
        print_step "Knowledge database ready"
    fi
    
    echo ""
}

print_success() {
    echo -e "${GREEN}"
    echo "  ╔══════════════════════════════════════════════════════════════╗"
    echo "  ║                                                              ║"
    echo "  ║   ✅  MR-LINMACHNIC INSTALLED SUCCESSFULLY!                 ║"
    echo "  ║                                                              ║"
    echo "  ║   Run from anywhere:                                         ║"
    echo "  ║                                                              ║"
    echo "  ║       $ mr-machine                                           ║"
    echo "  ║                                                              ║"
    echo "  ║   Or with options:                                           ║"
    echo "  ║                                                              ║"
    echo "  ║       $ mr-machine --scan        (Quick system scan)         ║"
    echo "  ║       $ mr-machine --auto        (Auto-fix mode)             ║"
    echo "  ║       $ mr-machine --ai          (AI analysis mode)          ║"
    echo "  ║       $ mr-machine --health      (System health score)       ║"
    echo "  ║       $ mr-machine --help        (Show help)                 ║"
    echo "  ║                                                              ║"
    echo "  ║   Installed to: /opt/mr-linmachnic                           ║"
    echo "  ║                                                              ║"
    echo "  ╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# ── Main Installation Flow ──
print_banner

echo -e "  ${WHITE}${BOLD}Welcome to MR-LINMACHNIC Installer${NC}"
echo -e "  ${DIM}The Machine That Repairs Linux${NC}"
echo ""
echo -e "  ${DIM}This will install mr-machine globally on your system.${NC}"
echo ""

check_root

read -p "  $(echo -e ${CYAN})Proceed with installation? [Y/n]:$(echo -e ${NC}) " confirm
if [[ "$confirm" =~ ^[Nn]$ ]]; then
    echo ""
    print_warn "Installation cancelled."
    exit 0
fi
echo ""

check_dependencies
install_files
verify_installation
print_success
