#!/bin/bash
#==============================================================================
#  MR-LINMACHNIC - System Health Score Module
#  Comprehensive health scoring with visual dashboard
#  Author: Madan Raj
#==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/ui.sh"
source "$SCRIPT_DIR/lib/utils.sh"

run_health_scan() {
    clear
    show_main_banner
    pulse_text "INITIATING SYSTEM HEALTH SCAN" "$MR_CYAN"
    
    spinner_start "Collecting system telemetry..." "bounce"
    
    # Collect data
    local cpu_usage mem_usage disk_usage load_avg
    local uptime_str kernel_ver hostname_str distro_name
    local failed_svcs process_count
    
    cpu_usage=$(get_cpu_usage 2>/dev/null || echo "0")
    mem_usage=$(get_mem_usage 2>/dev/null || echo "0")
    disk_usage=$(get_disk_usage 2>/dev/null || echo "0")
    load_avg=$(cat /proc/loadavg | awk '{print $1" "$2" "$3}' 2>/dev/null || echo "N/A")
    uptime_str=$(get_uptime 2>/dev/null || echo "N/A")
    kernel_ver=$(uname -r)
    hostname_str=$(hostname 2>/dev/null || echo unknown)
    distro_name=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo "Linux")
    failed_svcs=$(get_failed_services 2>/dev/null || echo "0")
    process_count=$(ps aux 2>/dev/null | wc -l || echo 0)
    
    local m_used=$(free -h 2>/dev/null | awk '/Mem:/ {print $3}' || echo N/A)
    local m_total=$(free -h 2>/dev/null | awk '/Mem:/ {print $2}' || echo N/A)
    local d_used=$(df -h / 2>/dev/null | awk 'NR==2 {print $3}' || echo N/A)
    local d_total=$(df -h / 2>/dev/null | awk 'NR==2 {print $2}' || echo N/A)
    
    sleep 0.8
    spinner_stop "ok" "Telemetry aggregated"
    echo ""

    # ── SYSTEM INFO ──
    dashboard_header "SYSTEM INFO"
    dashboard_row "Hostname:" "$hostname_str"
    dashboard_row "Distribution:" "$distro_name"
    dashboard_row "Kernel:" "$kernel_ver"
    dashboard_row "Uptime:" "$uptime_str"
    dashboard_row "Processes:" "$process_count"
    dashboard_row "Load Average:" "$load_avg"
    dashboard_footer
    echo ""
    
    # ── RESOURCE USAGE ──
    dashboard_header "RESOURCE USAGE"
    dashboard_bar "CPU" "$cpu_usage" "${cpu_usage}% load"
    dashboard_bar "Memory" "$mem_usage" "$m_used / $m_total"
    dashboard_bar "Disk" "$disk_usage" "$d_used / $d_total"
    dashboard_footer
    echo ""
    
    # ── SERVICES ──
    dashboard_header "SERVICES"
    dashboard_row "Failed Services:" "$failed_svcs" "$([[ "$failed_svcs" -eq 0 ]] && echo "ok" || echo "fail")"
    if [[ "$failed_svcs" -gt 0 ]]; then
        get_failed_service_names | head -3 | while read -r svc; do
            echo -e "    ${MR_RED}● $svc${MR_NC}"
        done
    fi
    dashboard_footer
    echo ""
    
    # ── NETWORK ──
    dashboard_header "NETWORK"
    local net_s="fail"; local dns_s="fail"
    if check_internet; then net_s="ok"; fi
    if check_dns; then dns_s="ok"; fi
    dashboard_row "Internet:" "$([[ "$net_s" == "ok" ]] && echo "Connected" || echo "Disconnected")" "$net_s"
    dashboard_row "DNS:" "$([[ "$dns_s" == "ok" ]] && echo "Active" || echo "Failed")" "$dns_s"
    dashboard_footer
    echo ""
    
    # ── OVERALL HEALTH ──
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
    dashboard_footer
    echo ""
    
    log_info "Health scan complete: $health_score/100"
    echo -ne "  ${MR_DIM}Press Enter to continue...${MR_NC}"; read -r
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_health_scan
fi
