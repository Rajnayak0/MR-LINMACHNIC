#!/bin/bash
#==============================================================================
#  MR-LINMACHNIC Uninstaller
#  Author: Madan Raj
#==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
DIM='\033[2m'
NC='\033[0m'

INSTALL_DIR="/opt/mr-linmachnic"
BIN_LINK="/usr/local/bin/mr-machine"

echo ""
echo -e "  ${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "  ${CYAN}║  MR-LINMACHNIC Uninstaller                  ║${NC}"
echo -e "  ${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""

if [[ $EUID -ne 0 ]]; then
    echo -e "  ${RED}[✗] Must be run as root (use sudo)${NC}"
    exit 1
fi

read -p "  $(echo -e ${YELLOW})Remove MR-LINMACHNIC? [y/N]:$(echo -e ${NC}) " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "  ${DIM}Cancelled.${NC}"
    exit 0
fi

echo ""

if [[ -L "$BIN_LINK" ]]; then
    rm -f "$BIN_LINK"
    echo -e "  ${GREEN}[✓]${NC} Removed global command"
fi

if [[ -d "$INSTALL_DIR" ]]; then
    rm -rf "$INSTALL_DIR"
    echo -e "  ${GREEN}[✓]${NC} Removed installation directory"
fi

echo ""
echo -e "  ${GREEN}✅ MR-LINMACHNIC has been uninstalled.${NC}"
echo ""
