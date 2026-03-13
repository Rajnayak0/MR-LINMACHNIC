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
    echo -e "${MR_CYAN}"
    echo '    ╔══════════════════════════════════════════════════╗'
    echo '    ║   💊  SYSTEM HEALTH DASHBOARD                   ║'
    echo '    ║   Comprehensive health scoring                  ║'
    echo '    ╚══════════════════════════════════════════════════╝'
    echo -e "${MR_NC}"
    echo ""
    
    spinner_start "Collecting system telemetry..."
    
    # Collect data
    local cpu_usage mem_usage disk_usage load_avg
    local uptime_str kernel_ver hostname_str distro_name
    local failed_svcs process_count
    
    cpu_usage=$(get_cpu_usage 2>/dev/null || echo "0")
    mem_usage=$(get_mem_usage 2>/dev/null || echo "0")
    disk_usage=$(get_disk_usage 2>/dev/null || echo "0")
    load_avg=$(get_load_avg 2>/dev/null || echo "N/A")
    uptime_str=$(get_uptime 2>/dev/null || echo "N/A")
    kernel_ver=$(get_kernel 2>/dev/null || echo "N/A")
    hostname_str=$(get_hostname 2>/dev/null || echo "N/A")
    distro_name=$(get_distro_name 2>/dev/null || echo "N/A")
    failed_svcs=$(get_failed_services 2>/dev/null || echo "0")
    process_count=$(get_process_count 2>/dev/null || echo "N/A")
    
    local mem_info
    mem_info=$(get_mem_info 2>/dev/null || echo "N/A N/A N/A")
    local mem_total mem_used mem_free
    mem_total=$(echo "$mem_info" | awk '{print $1}')
    mem_used=$(echo "$mem_info" | awk '{print $2}')
    mem_free=$(echo "$mem_info" | awk '{print $3}')
    
    local disk_info
    disk_info=$(get_disk_info 2>/dev/null || echo "N/A N/A N/A N/A")
    local disk_total disk_used disk_free disk_pct
    disk_total=$(echo "$disk_info" | awk '{print $1}')
    disk_used=$(echo "$disk_info" | awk '{print $2}')
    disk_free=$(echo "$disk_info" | awk '{print $3}')
    
    sleep 1
    spinner_stop "ok" "Telemetry collected"
    
    # ── System Info ──
    echo ""
    echo -e "  ${MR_CYAN}${MR_BOLD}╔══ SYSTEM INFO ══════════════════════════════════╗${MR_NC}"
    echo ""
    kv_print "Hostname:" "$hostname_str"
    kv_print "Distribution:" "$distro_name"
    kv_print "Kernel:" "$kernel_ver"
    kv_print "Uptime:" "$uptime_str"
    kv_print "Processes:" "$process_count"
    kv_print "Load Average:" "$load_avg"
    echo ""
    
    # ── Resource Usage ──
    echo -e "  ${MR_CYAN}${MR_BOLD}╔══ RESOURCE USAGE ═══════════════════════════════╗${MR_NC}"
    echo ""
    
    # CPU
    local cpu_health=$((100 - cpu_usage))
    local cpu_status="ok"
    [[ $cpu_usage -gt 80 ]] && cpu_status="fail"
    [[ $cpu_usage -gt 60 ]] && cpu_status="warn"
    kv_print "CPU Usage:" "${cpu_usage}%" "$cpu_status"
    health_bar "  CPU" "$cpu_health"
    echo ""
    
    # Memory
    local mem_health=$((100 - mem_usage))
    local mem_status="ok"
    [[ $mem_usage -gt 85 ]] && mem_status="fail"
    [[ $mem_usage -gt 65 ]] && mem_status="warn"
    kv_print "Memory:" "${mem_used} / ${mem_total} (${mem_usage}%)" "$mem_status"
    health_bar "  Memory" "$mem_health"
    echo ""
    
    # Disk
    local disk_health=$((100 - disk_usage))
    local disk_status="ok"
    [[ $disk_usage -gt 90 ]] && disk_status="fail"
    [[ $disk_usage -gt 75 ]] && disk_status="warn"
    kv_print "Disk (/):" "${disk_used} / ${disk_total} (${disk_usage}%)" "$disk_status"
    health_bar "  Disk" "$disk_health"
    echo ""
    
    # ── Services ──
    echo -e "  ${MR_CYAN}${MR_BOLD}╔══ SERVICES ═════════════════════════════════════╗${MR_NC}"
    echo ""
    if [[ "$failed_svcs" -gt 0 ]]; then
        kv_print "Failed Services:" "$failed_svcs" "fail"
        get_failed_service_names 2>/dev/null | while read -r svc; do
            [[ -n "$svc" ]] && echo -e "    ${MR_RED}● $svc${MR_NC}"
        done
    else
        kv_print "Failed Services:" "0" "ok"
    fi
    echo ""
    
    # ── Network ──
    echo -e "  ${MR_CYAN}${MR_BOLD}╔══ NETWORK ══════════════════════════════════════╗${MR_NC}"
    echo ""
    if check_internet 2>/dev/null; then
        kv_print "Internet:" "Connected" "ok"
    else
        kv_print "Internet:" "Disconnected" "fail"
    fi
    if check_dns 2>/dev/null; then
        kv_print "DNS:" "Working" "ok"
    else
        kv_print "DNS:" "Failed" "fail"
    fi
    echo ""
    
    # ── Overall Health Score ──
    local health_score
    health_score=$(calc_health_score)
    
    echo -e "  ${MR_CYAN}${MR_BOLD}╔══ OVERALL HEALTH ═══════════════════════════════╗${MR_NC}"
    echo ""
    
    local grade grade_color
    if [[ $health_score -ge 90 ]]; then
        grade="A+ EXCELLENT"
        grade_color="$MR_GREEN"
    elif [[ $health_score -ge 80 ]]; then
        grade="A  GOOD"
        grade_color="$MR_GREEN"
    elif [[ $health_score -ge 70 ]]; then
        grade="B  FAIR"
        grade_color="$MR_YELLOW"
    elif [[ $health_score -ge 50 ]]; then
        grade="C  NEEDS ATTENTION"
        grade_color="$MR_ORANGE"
    elif [[ $health_score -ge 30 ]]; then
        grade="D  POOR"
        grade_color="$MR_RED"
    else
        grade="F  CRITICAL"
        grade_color="$MR_RED"
    fi
    
    health_bar "  Overall" "$health_score"
    echo ""
    echo -e "  ${grade_color}${MR_BOLD}  Grade: $grade (${health_score}/100)${MR_NC}"
    echo ""
    
    # Recommendations
    if [[ $health_score -lt 90 ]]; then
        echo -e "  ${MR_CYAN}${MR_BOLD}╔══ RECOMMENDATIONS ══════════════════════════════╗${MR_NC}"
        echo ""
        [[ $cpu_usage -gt 70 ]] && msg_info "High CPU: Check processes with 'top' or 'htop'"
        [[ $mem_usage -gt 80 ]] && msg_info "High Memory: Consider adding swap or closing apps"
        [[ $disk_usage -gt 80 ]] && msg_info "High Disk: Run 'mr-machine --auto' to clean up"
        [[ "$failed_svcs" -gt 0 ]] && msg_info "Failed services: Run 'systemctl --failed' to check"
        echo ""
    fi
    
    log_info "Health scan: score=$health_score cpu=$cpu_usage mem=$mem_usage disk=$disk_usage"
    
    echo -ne "  ${MR_DIM}Press Enter to continue...${MR_NC}"
    read -r
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_health_scan
fi
