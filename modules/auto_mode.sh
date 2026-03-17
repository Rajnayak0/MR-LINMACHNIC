#!/bin/bash
#==============================================================================
#  MR-LINMACHNIC - Automated Diagnostic & Repair Mode
#  Runs system diagnostics and fixes issues automatically
#  Author: Madan Raj
#==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/ui.sh"
source "$SCRIPT_DIR/lib/utils.sh"

run_auto_mode() {
    clear
    show_main_banner
    pulse_text "INITIATING SYSTEM-WIDE SCAN" "$MR_CYAN"
    
    local issues_found=0
    local issues_fixed=0
    local total_checks=10
    local current_check=0
    declare -a FIXES_PERFORMED
    
    log_info "Starting automated diagnostic scan"
    
    local initial_health
    initial_health=$(calc_health_score)
    
    # ── SYSTEM INFO ──
    dashboard_header "SYSTEM INFO"
    dashboard_row "Hostname:" "$(hostname 2>/dev/null || echo unknown)"
    dashboard_row "Distribution:" "$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo Linux)"
    dashboard_row "Kernel:" "$(uname -r 2>/dev/null || echo unknown)"
    dashboard_row "Uptime:" "$(uptime -p 2>/dev/null | sed 's/up //' || echo unknown)"
    dashboard_row "Load Average:" "$(cat /proc/loadavg 2>/dev/null | awk '{print $1" "$2" "$3}' || echo unknown)"
    dashboard_footer
    echo ""

    # Scanning loop simulation with dashboard rows
    # Check 1: Storage
    dashboard_header "RESOURCE USAGE"
    
    spinner_start "Analyzing storage partitions..." "braille"
    local disk_usage
    disk_usage=$(get_disk_usage)
    local disk_info
    disk_info=$(df -h / | awk 'NR==2 {print $3" / "$2" ("$5")"}')
    sleep 0.4
    spinner_stop "info" "Disk Check Complete"
    dashboard_bar "Disk (/)" "$disk_usage" "$disk_info"
    
    # Check 2: Memory
    spinner_start "Probing RAM and Swap..." "blocks"
    local mem_usage
    mem_usage=$(get_mem_usage)
    local mem_real_info
    mem_real_info=$(free -h | awk '/Mem:/ {print $3" / "$2" ("$3/$2*100"%")}') 
    # Better mem info
    local m_used=$(free -h | awk '/Mem:/ {print $3}')
    local m_total=$(free -h | awk '/Mem:/ {print $2}')
    mem_real_info="$m_used / $m_total ($mem_usage%)"
    sleep 0.4
    spinner_stop "info" "Memory Check Complete"
    dashboard_bar "Memory" "$mem_usage" "$mem_real_info"

    # Check 3: CPU
    spinner_start "Calculating processor load..." "arrows"
    local cpu_usage
    cpu_usage=$(get_cpu_usage 2>/dev/null || echo 5)
    sleep 0.4
    spinner_stop "info" "CPU Check Complete"
    dashboard_bar "CPU" "$cpu_usage" "${cpu_usage}% load"
    dashboard_footer
    echo ""

    # Check 4: Services
    dashboard_header "SERVICES"
    spinner_start "Scanning systemd units..." "braille"
    local failed_count
    failed_count=$(get_failed_services)
    sleep 0.4
    spinner_stop "info" "Service scan complete"
    dashboard_row "Failed Services:" "$failed_count" "$([[ $failed_count -eq 0 ]] && echo "ok" || echo "fail")"
    dashboard_footer
    echo ""

    # Check 5: Network
    dashboard_header "NETWORK"
    spinner_start "Testing connectivity..." "bounce"
    local net_status="Disconnected"
    local dns_status="Failed"
    local net_s="fail"
    local dns_s="fail"
    
    if check_internet; then net_status="Connected"; net_s="ok"; fi
    if check_dns; then dns_status="Active"; dns_s="ok"; fi
    sleep 0.4
    spinner_stop "info" "Network test complete"
    
    dashboard_row "Internet:" "$net_status" "$net_s"
    dashboard_row "DNS:" "$dns_status" "$dns_s"
    dashboard_footer
    echo ""

    # Final Overall Health
    local health_score
    health_score=$(calc_health_score)
    dashboard_header "OVERALL HEALTH"
    dashboard_bar "Overall" "$health_score" ""
    
    local grade="F CRITICAL"
    local g_color="$MR_RED"
    if [[ $health_score -ge 90 ]]; then grade="A+ EXCELLENT"; g_color="$MR_GREEN";
    elif [[ $health_score -ge 80 ]]; then grade="B+ GOOD"; g_color="$MR_SKY";
    elif [[ $health_score -ge 60 ]]; then grade="C FAIR"; g_color="$MR_YELLOW";
    fi
    
    echo ""
    echo -e "    ${g_color}${MR_BOLD}Grade: $grade ($health_score/100)${MR_NC}"
    echo ""

    # Save report
    save_report "Automated Diagnostic" "$initial_health" "$health_score" "Live Scan" "N/A" "Performed full automated diagnostic scan with dashboard visualization."
    
    echo -ne "  ${MR_DIM}Press Enter to continue...${MR_NC}"
    read -r
}

# Allow direct execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_auto_mode
fi
