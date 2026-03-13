#!/bin/bash
#==============================================================================
#  MR-LINMACHNIC - Boot Repair Mode
#  Advanced boot recovery and GRUB repair tools
#  Author: Madan Raj
#==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/ui.sh"
source "$SCRIPT_DIR/lib/utils.sh"

run_boot_repair() {
    while true; do
        clear
        echo -e "${MR_CYAN}"
        echo '    ╔══════════════════════════════════════════════════╗'
        echo '    ║   🔄  BOOT REPAIR MODE                          ║'
        echo '    ║   Advanced boot recovery tools                  ║'
        echo '    ╚══════════════════════════════════════════════════╝'
        echo -e "${MR_NC}"
        echo ""
        echo -e "  ${MR_GREEN}1.${MR_NC}  🔍  ${MR_WHITE}Diagnose Boot Issues${MR_NC}"
        echo -e "  ${MR_GREEN}2.${MR_NC}  🔧  ${MR_WHITE}Repair GRUB Bootloader${MR_NC}"
        echo -e "  ${MR_GREEN}3.${MR_NC}  📋  ${MR_WHITE}View Boot Logs${MR_NC}"
        echo -e "  ${MR_GREEN}4.${MR_NC}  ⏱️   ${MR_WHITE}Analyze Boot Time${MR_NC}"
        echo -e "  ${MR_GREEN}5.${MR_NC}  🔄  ${MR_WHITE}Rebuild initramfs${MR_NC}"
        echo -e "  ${MR_GREEN}6.${MR_NC}  🐧  ${MR_WHITE}Manage Kernels${MR_NC}"
        echo -e "  ${MR_GREEN}7.${MR_NC}  💾  ${MR_WHITE}Fix fstab Issues${MR_NC}"
        echo ""
        echo -e "  ${MR_RED}0.${MR_NC}  ← Back"
        echo ""
        echo -ne "  ${MR_CYAN}❯${MR_NC} Select: "
        read -r choice
        
        case $choice in
            1) diagnose_boot ;;
            2) repair_grub ;;
            3) view_boot_logs ;;
            4) analyze_boot_time ;;
            5) rebuild_initramfs ;;
            6) manage_kernels ;;
            7) fix_fstab ;;
            0) return ;;
        esac
    done
}

diagnose_boot() {
    clear
    section_header "Boot Diagnostics" "🔍"
    
    # Check GRUB
    msg_info "Checking GRUB..."
    if [[ -f /boot/grub/grub.cfg ]] || [[ -f /boot/grub2/grub.cfg ]]; then
        msg_ok "GRUB config found"
    else
        msg_fail "GRUB config NOT found!"
    fi
    
    # Check kernels
    msg_info "Installed kernels:"
    ls /boot/vmlinuz-* 2>/dev/null | while read -r k; do
        msg_ok "  $(basename "$k")"
    done
    
    # Check initramfs
    msg_info "Initramfs images:"
    ls /boot/initrd* /boot/initramfs* 2>/dev/null | while read -r i; do
        msg_ok "  $(basename "$i")"
    done
    
    # Check boot errors
    if cmd_exists journalctl; then
        echo ""
        msg_info "Recent boot errors:"
        journalctl -b -p err --no-pager 2>/dev/null | head -10 | while read -r line; do
            echo -e "    ${MR_DIM}$line${MR_NC}"
        done
    fi
    
    # Check EFI
    if [[ -d /sys/firmware/efi ]]; then
        msg_ok "System boots in UEFI mode"
        if cmd_exists efibootmgr; then
            msg_info "EFI boot entries:"
            efibootmgr 2>/dev/null | head -10 | while read -r line; do
                echo -e "    ${MR_DIM}$line${MR_NC}"
            done
        fi
    else
        msg_info "System boots in Legacy/BIOS mode"
    fi
    
    echo ""
    echo -ne "  ${MR_DIM}Press Enter...${MR_NC}"; read -r
}

repair_grub() {
    clear
    section_header "GRUB Repair" "🔧"
    
    if ! require_root; then
        echo -ne "  ${MR_DIM}Press Enter...${MR_NC}"; read -r
        return
    fi
    
    msg_warn "This will reinstall and update GRUB."
    if ! confirm_action "Proceed with GRUB repair?" "n"; then
        return
    fi
    
    # Detect boot disk
    local boot_disk
    boot_disk=$(mount | grep ' /boot ' | awk '{print $1}' | sed 's/[0-9]*$//')
    [[ -z "$boot_disk" ]] && boot_disk=$(mount | grep ' / ' | awk '{print $1}' | sed 's/[0-9]*$//')
    
    msg_info "Detected boot disk: $boot_disk"
    
    if [[ -d /sys/firmware/efi ]]; then
        msg_info "UEFI mode — running grub-install..."
        sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB 2>&1 | while read -r line; do
            msg_info "$line"
        done
    else
        msg_info "BIOS mode — running grub-install..."
        sudo grub-install "$boot_disk" 2>&1 | while read -r line; do
            msg_info "$line"
        done
    fi
    
    msg_info "Updating GRUB config..."
    sudo update-grub 2>&1 | while read -r line; do
        msg_info "$line"
    done
    
    msg_ok "GRUB repair complete!"
    echo -ne "  ${MR_DIM}Press Enter...${MR_NC}"; read -r
}

view_boot_logs() {
    clear
    section_header "Boot Logs" "📋"
    
    if cmd_exists journalctl; then
        journalctl -b --no-pager 2>/dev/null | tail -40
    else
        [[ -f /var/log/boot.log ]] && tail -40 /var/log/boot.log 2>/dev/null
    fi
    
    echo ""
    echo -ne "  ${MR_DIM}Press Enter...${MR_NC}"; read -r
}

analyze_boot_time() {
    clear
    section_header "Boot Time Analysis" "⏱️"
    
    if cmd_exists systemd-analyze; then
        echo -e "  ${MR_WHITE}${MR_BOLD}Overall Boot Time:${MR_NC}"
        systemd-analyze 2>/dev/null
        echo ""
        echo -e "  ${MR_WHITE}${MR_BOLD}Top 15 Slowest Services:${MR_NC}"
        systemd-analyze blame 2>/dev/null | head -15
    else
        msg_warn "systemd-analyze not available"
    fi
    
    echo ""
    echo -ne "  ${MR_DIM}Press Enter...${MR_NC}"; read -r
}

rebuild_initramfs() {
    clear
    section_header "Rebuild initramfs" "🔄"
    
    if ! require_root; then
        echo -ne "  ${MR_DIM}Press Enter...${MR_NC}"; read -r
        return
    fi
    
    if ! confirm_action "Rebuild initramfs for all kernels?" "n"; then return; fi
    
    local pkg_mgr
    pkg_mgr=$(detect_pkg_manager)
    
    case "$pkg_mgr" in
        apt|dpkg)
            sudo update-initramfs -u -k all 2>&1 | while read -r l; do msg_info "$l"; done
            ;;
        dnf|yum)
            sudo dracut --force 2>&1 | while read -r l; do msg_info "$l"; done
            ;;
        *)
            msg_warn "Unsupported package manager for auto-rebuild"
            ;;
    esac
    
    msg_ok "initramfs rebuild complete"
    echo -ne "  ${MR_DIM}Press Enter...${MR_NC}"; read -r
}

manage_kernels() {
    clear
    section_header "Kernel Management" "🐧"
    
    msg_info "Current kernel: $(uname -r)"
    echo ""
    msg_info "Installed kernels:"
    
    local pkg_mgr
    pkg_mgr=$(detect_pkg_manager)
    case "$pkg_mgr" in
        apt) dpkg --list 'linux-image-*' 2>/dev/null | grep '^ii' | awk '{print "    " $2}' ;;
        dnf|yum) rpm -qa kernel 2>/dev/null | while read -r k; do echo "    $k"; done ;;
        *) ls /boot/vmlinuz-* 2>/dev/null | while read -r k; do echo "    $(basename "$k")"; done ;;
    esac
    
    echo ""
    echo -ne "  ${MR_DIM}Press Enter...${MR_NC}"; read -r
}

fix_fstab() {
    clear
    section_header "Fix fstab Issues" "💾"
    
    msg_info "Current /etc/fstab:"
    echo ""
    cat /etc/fstab 2>/dev/null | while read -r line; do
        if [[ "$line" == "#"* ]] || [[ -z "$line" ]]; then
            echo -e "    ${MR_DIM}$line${MR_NC}"
        else
            echo -e "    ${MR_WHITE}$line${MR_NC}"
        fi
    done
    
    echo ""
    msg_info "Block device UUIDs:"
    blkid 2>/dev/null | while read -r line; do
        echo -e "    ${MR_DIM}$line${MR_NC}"
    done
    
    echo ""
    msg_info "If UUIDs don't match fstab, update fstab with correct UUIDs."
    echo -ne "  ${MR_DIM}Press Enter...${MR_NC}"; read -r
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_boot_repair
fi
