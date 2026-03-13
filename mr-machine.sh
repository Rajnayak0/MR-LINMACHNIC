#!/bin/bash
#==============================================================================
#  MR-LINMACHNIC v1.0.0 (Genesis)
#  🛠️  The Machine That Repairs Linux
#  Author: Madan Raj
#  License: Free & Open Source
#
#  Global command: mr-machine
#  Usage: mr-machine [--scan|--auto|--ai|--health|--boot|--help]
#==============================================================================

set -euo pipefail

# ── Resolve script location ──
if [[ -L "${BASH_SOURCE[0]}" ]]; then
    SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
else
    SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
fi
export MR_BASE_DIR="$(dirname "$SCRIPT_PATH")"

# ── Source libraries ──
source "$MR_BASE_DIR/lib/ui.sh"
source "$MR_BASE_DIR/lib/utils.sh"

# ── Trap for clean exit ──
cleanup() {
    tput cnorm 2>/dev/null  # Restore cursor
    echo -e "${MR_NC}"
    [[ -n "${SPINNER_PID:-}" ]] && kill "$SPINNER_PID" 2>/dev/null
}
trap cleanup EXIT INT TERM

# ── Show help ──
show_help() {
    echo -e "${MR_CYAN}${MR_BOLD}"
    echo "  MR-LINMACHNIC v${MR_VERSION} — The Machine That Repairs Linux"
    echo -e "${MR_NC}"
    echo -e "  ${MR_WHITE}Usage:${MR_NC}"
    echo -e "    mr-machine              ${MR_DIM}Launch interactive menu${MR_NC}"
    echo -e "    mr-machine --scan       ${MR_DIM}Quick system scan${MR_NC}"
    echo -e "    mr-machine --auto       ${MR_DIM}Automated diagnostic & repair${MR_NC}"
    echo -e "    mr-machine --ai         ${MR_DIM}AI-powered log analysis${MR_NC}"
    echo -e "    mr-machine --health     ${MR_DIM}System health score${MR_NC}"
    echo -e "    mr-machine --boot       ${MR_DIM}Boot repair tools${MR_NC}"
    echo -e "    mr-machine --manual     ${MR_DIM}Manual troubleshooting guide${MR_NC}"
    echo -e "    mr-machine --version    ${MR_DIM}Show version${MR_NC}"
    echo -e "    mr-machine --help       ${MR_DIM}Show this help${MR_NC}"
    echo ""
    echo -e "  ${MR_DIM}Author: Madan Raj${MR_NC}"
    echo -e "  ${MR_DIM}100% Free & Open Source${MR_NC}"
    echo ""
}

# ── Quick scan (non-interactive) ──
quick_scan() {
    echo ""
    echo -e "  ${MR_CYAN}${MR_BOLD}⚡ MR-LINMACHNIC Quick Scan${MR_NC}"
    echo -e "  ${MR_DIM}$(printf '─%.0s' $(seq 1 40))${MR_NC}"
    echo ""
    
    kv_print "Hostname:" "$(get_hostname)" 
    kv_print "Distro:" "$(get_distro_name)"
    kv_print "Kernel:" "$(get_kernel)"
    kv_print "Uptime:" "$(get_uptime)"
    echo ""
    
    local cpu mem disk
    cpu=$(get_cpu_usage 2>/dev/null || echo "0")
    mem=$(get_mem_usage 2>/dev/null || echo "0")
    disk=$(get_disk_usage 2>/dev/null || echo "0")
    
    local cpu_s="ok" mem_s="ok" disk_s="ok"
    [[ $cpu -gt 80 ]] && cpu_s="fail"; [[ $cpu -gt 60 ]] && cpu_s="warn"
    [[ $mem -gt 85 ]] && mem_s="fail"; [[ $mem -gt 65 ]] && mem_s="warn"
    [[ $disk -gt 90 ]] && disk_s="fail"; [[ $disk -gt 75 ]] && disk_s="warn"
    
    kv_print "CPU:" "${cpu}%" "$cpu_s"
    kv_print "Memory:" "${mem}%" "$mem_s"
    kv_print "Disk (/):" "${disk}%" "$disk_s"
    
    local failed
    failed=$(get_failed_services 2>/dev/null || echo "0")
    local svc_s="ok"
    [[ "$failed" -gt 0 ]] && svc_s="fail"
    kv_print "Failed Svcs:" "$failed" "$svc_s"
    
    if check_internet 2>/dev/null; then
        kv_print "Internet:" "Connected" "ok"
    else
        kv_print "Internet:" "Disconnected" "fail"
    fi
    
    echo ""
    local score
    score=$(calc_health_score)
    health_bar "Health" "$score"
    echo ""
}

# ── Main interactive menu ──
main_menu() {
    while true; do
        show_main_banner
        
        echo -e "  ${MR_WHITE}${MR_BOLD}  SELECT A MODE${MR_NC}"
        echo ""
        echo -e "  ${MR_GREEN}  1.${MR_NC}  📖  ${MR_WHITE}Manual Mode${MR_NC}              ${MR_DIM}Interactive troubleshooting guide${MR_NC}"
        echo -e "  ${MR_GREEN}  2.${MR_NC}  ⚡  ${MR_WHITE}Automated Diagnostic${MR_NC}      ${MR_DIM}Auto-detect and fix issues${MR_NC}"
        echo -e "  ${MR_GREEN}  3.${MR_NC}  🤖  ${MR_WHITE}AI Analysis Mode${MR_NC}          ${MR_DIM}Intelligent log analysis${MR_NC}"
        echo -e "  ${MR_GREEN}  4.${MR_NC}  🔄  ${MR_WHITE}Boot Repair${MR_NC}               ${MR_DIM}GRUB, kernel, initramfs tools${MR_NC}"
        echo -e "  ${MR_GREEN}  5.${MR_NC}  💊  ${MR_WHITE}System Health Score${MR_NC}        ${MR_DIM}Full health dashboard${MR_NC}"
        echo -e "  ${MR_GREEN}  6.${MR_NC}  ⚡  ${MR_WHITE}Quick System Scan${MR_NC}          ${MR_DIM}Fast overview of system state${MR_NC}"
        echo ""
        echo -e "  ${MR_DIM}  ─────────────────────────────────────────────────────${MR_NC}"
        echo -e "  ${MR_RED}  0.${MR_NC}  🚪  ${MR_WHITE}Exit${MR_NC}"
        echo ""
        echo -ne "  ${MR_CYAN}  ❯${MR_NC} Select option: "
        read -r choice
        
        case $choice in
            1)
                source "$MR_BASE_DIR/modules/manual_mode.sh"
                run_manual_mode
                ;;
            2)
                source "$MR_BASE_DIR/modules/auto_mode.sh"
                run_auto_mode
                ;;
            3)
                source "$MR_BASE_DIR/modules/ai_mode.sh"
                run_ai_mode
                ;;
            4)
                source "$MR_BASE_DIR/modules/boot_repair.sh"
                run_boot_repair
                ;;
            5)
                source "$MR_BASE_DIR/modules/health_scan.sh"
                run_health_scan
                ;;
            6)
                clear
                quick_scan
                echo -ne "  ${MR_DIM}Press Enter to continue...${MR_NC}"
                read -r
                ;;
            0|q|Q)
                clear
                echo ""
                echo -e "  ${MR_CYAN}${MR_BOLD}Thank you for using MR-LINMACHNIC! 🛠️${MR_NC}"
                echo -e "  ${MR_DIM}The Machine That Repairs Linux — by Madan Raj${MR_NC}"
                echo ""
                exit 0
                ;;
            *)
                msg_warn "Invalid option. Please try again."
                sleep 1
                ;;
        esac
    done
}

# ── Entry Point ──
main() {
    # Handle CLI arguments
    case "${1:-}" in
        --help|-h)
            show_help
            exit 0
            ;;
        --version|-v)
            echo "MR-LINMACHNIC v${MR_VERSION} (${MR_CODENAME})"
            exit 0
            ;;
        --scan)
            quick_scan
            exit 0
            ;;
        --auto)
            source "$MR_BASE_DIR/modules/auto_mode.sh"
            run_auto_mode
            exit 0
            ;;
        --ai)
            source "$MR_BASE_DIR/modules/ai_mode.sh"
            run_ai_mode
            exit 0
            ;;
        --health)
            source "$MR_BASE_DIR/modules/health_scan.sh"
            run_health_scan
            exit 0
            ;;
        --boot)
            source "$MR_BASE_DIR/modules/boot_repair.sh"
            run_boot_repair
            exit 0
            ;;
        --manual)
            source "$MR_BASE_DIR/modules/manual_mode.sh"
            run_manual_mode
            exit 0
            ;;
        "")
            main_menu
            ;;
        *)
            echo -e "  ${MR_RED}Unknown option: $1${MR_NC}"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
