#!/bin/bash
#==============================================================================
#  MR-LINMACHNIC - Advanced Features Library
#  Next-generation capabilities for the Linux repair machine
#  Author: Madan Raj
#==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/ui.sh"
source "$SCRIPT_DIR/lib/utils.sh"

# ── Configuration Management ──
MR_CONFIG_DIR="$HOME/.config/mr-linmachnic"
MR_CONFIG_FILE="$MR_CONFIG_DIR/config.json"
MR_PLUGINS_DIR="$MR_CONFIG_DIR/plugins"
MR_LOG_DIR="$MR_CONFIG_DIR/logs"

# ── Initialize advanced config ──
init_advanced_config() {
    mkdir -p "$MR_CONFIG_DIR" "$MR_PLUGINS_DIR" "$MR_LOG_DIR"
    
    if [[ ! -f "$MR_CONFIG_FILE" ]]; then
        cat > "$MR_CONFIG_FILE" << 'EOF'
{
  "version": "2.0.0",
  "settings": {
    "auto_update": true,
    "notifications": true,
    "privacy_mode": false,
    "advanced_logging": true,
    "cloud_sync": false,
    "theme": "cyberpunk",
    "scan_depth": "medium",
    "ai_timeout": 30,
    "max_log_size": "100MB"
  },
  "monitoring": {
    "enabled": false,
    "interval": 300,
    "alerts": {
      "cpu_threshold": 85,
      "memory_threshold": 90,
      "disk_threshold": 95,
      "failed_services": 3
    }
  },
  "plugins": {
    "enabled": [],
    "disabled": []
  },
  "security": {
    "scan_network": true,
    "scan_processes": true,
    "scan_files": true,
    "auto_quarantine": false
  }
}
EOF
        log_info "Advanced configuration initialized"
    fi
}

# ── Real-time System Monitor ──
start_monitoring() {
    local config
    config=$(cat "$MR_CONFIG_FILE" 2>/dev/null)
    
    if [[ -z "$config" ]]; then
        init_advanced_config
        config=$(cat "$MR_CONFIG_FILE")
    fi
    
    local enabled
    enabled=$(echo "$config" | jq -r '.monitoring.enabled' 2>/dev/null)
    
    if [[ "$enabled" != "true" ]]; then
        msg_warn "Real-time monitoring is disabled in configuration"
        return 1
    fi
    
    local interval
    interval=$(echo "$config" | jq -r '.monitoring.interval' 2>/dev/null || echo 300)
    
    clear
    show_main_banner
    echo -e "  ${MR_CYAN}${MR_BOLD}🔄 REAL-TIME SYSTEM MONITORING${MR_NC}"
    echo -e "  ${MR_DIM}Press Ctrl+C to stop monitoring${MR_NC}"
    echo ""
    
    while true; do
        # Collect metrics
        local cpu mem disk failed_svcs
        cpu=$(get_cpu_usage 2>/dev/null || echo 0)
        mem=$(get_mem_usage 2>/dev/null || echo 0)
        disk=$(get_disk_usage 2>/dev/null || echo 0)
        failed_svcs=$(get_failed_services 2>/dev/null || echo 0)
        
        # Check thresholds
        local alerts=()
        local cpu_t mem_t disk_t svc_t
        cpu_t=$(echo "$config" | jq -r '.monitoring.alerts.cpu_threshold' 2>/dev/null || echo 85)
        mem_t=$(echo "$config" | jq -r '.monitoring.alerts.memory_threshold' 2>/dev/null || echo 90)
        disk_t=$(echo "$config" | jq -r '.monitoring.alerts.disk_threshold' 2>/dev/null || echo 95)
        svc_t=$(echo "$config" | jq -r '.monitoring.alerts.failed_services' 2>/dev/null || echo 3)
        
        [[ $cpu -gt $cpu_t ]] && alerts+=("CPU: ${cpu}%")
        [[ $mem -gt $mem_t ]] && alerts+=("Memory: ${mem}%")
        [[ $disk -gt $disk_t ]] && alerts+=("Disk: ${disk}%")
        [[ $failed_svcs -gt $svc_t ]] && alerts+=("Services: $failed_svcs failed")
        
        # Display dashboard
        dashboard_header "LIVE SYSTEM MONITOR"
        dashboard_bar "CPU" "$cpu" "${cpu}% load"
        dashboard_bar "Memory" "$mem" "${mem}% used"
        dashboard_bar "Disk" "$disk" "${disk}% used"
        dashboard_row "Failed Services:" "$failed_svcs" "$([[ $failed_svcs -eq 0 ]] && echo "ok" || echo "warn")"
        
        if [[ ${#alerts[@]} -gt 0 ]]; then
            dashboard_row "Alerts:" "${alerts[*]}" "fail"
        else
            dashboard_row "Status:" "All systems normal" "ok"
        fi
        dashboard_footer
        
        # Log critical alerts
        if [[ ${#alerts[@]} -gt 0 ]]; then
            log_warn "Monitoring alert: ${alerts[*]}"
            if command -v notify-send &>/dev/null; then
                notify-send "MR-LINMACHNIC Alert" "${alerts[*]}" 2>/dev/null
            fi
        fi
        
        sleep "$interval"
        clear
        show_main_banner
    done
}

# ── Advanced Hardware Diagnostics ──
run_hardware_diagnostics() {
    clear
    show_main_banner
    pulse_text "ADVANCED HARDWARE DIAGNOSTICS" "$MR_VIOLET"
    
    # ── CPU Diagnostics ──
    dashboard_header "CPU DIAGNOSTICS"
    local cpu_info
    cpu_info=$(lscpu 2>/dev/null | grep -E "Model name|CPU\(s\)|Thread|Core" | head -5)
    echo "$cpu_info" | while read -r line; do
        echo -e "    ${MR_WHITE}${line}${MR_NC}"
    done
    
    # Test CPU stress
    if command -v stress &>/dev/null; then
        spinner_start "Running CPU stress test..." "braille"
        timeout 10s stress --cpu 2 --timeout 5s >/dev/null 2>&1
        spinner_stop "ok" "CPU stress test completed"
    else
        dashboard_row "Stress Test:" "Not available (install 'stress')" "warn"
    fi
    dashboard_footer
    echo ""
    
    # ── Memory Diagnostics ──
    dashboard_header "MEMORY DIAGNOSTICS"
    local mem_info
    mem_info=$(free -h 2>/dev/null)
    echo "$mem_info" | while read -r line; do
        echo -e "    ${MR_WHITE}${line}${MR_NC}"
    done
    
    # Check for memory errors
    if command -v memtester &>/dev/null; then
        spinner_start "Testing memory integrity..." "blocks"
        timeout 30s memtester 100M 1 >/dev/null 2>&1
        spinner_stop "ok" "Memory test completed"
    else
        dashboard_row "Memory Test:" "Not available (install 'memtester')" "warn"
    fi
    dashboard_footer
    echo ""
    
    # ── Disk Diagnostics ──
    dashboard_header "STORAGE DIAGNOSTICS"
    local disk_info
    disk_info=$(lsblk -d -o NAME,SIZE,TYPE,MODEL 2>/dev/null | grep -E "disk|nvme")
    echo "$disk_info" | while read -r line; do
        echo -e "    ${MR_WHITE}${line}${MR_NC}"
    done
    
    # SMART data
    if command -v smartctl &>/dev/null; then
        local disk_dev
        disk_dev=$(lsblk -d -n -o NAME 2>/dev/null | grep -E "^sd|^nvme" | head -1)
        if [[ -n "$disk_dev" ]]; then
            spinner_start "Reading SMART data..."
            local smart_health
            smart_health=$(smartctl -H "/dev/$disk_dev" 2>/dev/null | grep -i "overall-health" | awk '{print $NF}')
            spinner_stop "ok" "SMART health: $smart_health"
            dashboard_row "SMART Health:" "$smart_health" "$([[ "$smart_health" == "PASSED" ]] && echo "ok" || echo "fail")"
        fi
    else
        dashboard_row "SMART Test:" "Not available (install 'smartmontools')" "warn"
    fi
    dashboard_footer
    echo ""
    
    # ── Network Diagnostics ──
    dashboard_header "NETWORK DIAGNOSTICS"
    local net_info
    net_info=$(ip -br addr show 2>/dev/null | grep -v "lo")
    echo "$net_info" | while read -r line; do
        echo -e "    ${MR_WHITE}${line}${MR_NC}"
    done
    
    # Network speed test
    if command -v speedtest-cli &>/dev/null; then
        spinner_start "Testing network speed..."
        local speed_result
        speed_result=$(timeout 30s speedtest-cli --simple 2>/dev/null | head -3)
        spinner_stop "ok" "Speed test completed"
        echo "$speed_result" | while read -r line; do
            echo -e "    ${MR_WHITE}${line}${MR_NC}"
        done
    else
        dashboard_row "Speed Test:" "Not available (install 'speedtest-cli')" "warn"
    fi
    dashboard_footer
    echo ""
    
    # ── Overall Assessment ──
    local health_score
    health_score=$(calc_health_score)
    dashboard_header "HARDWARE HEALTH ASSESSMENT"
    dashboard_bar "Overall" "$health_score" ""
    dashboard_footer
    
    echo ""
    echo -ne "  ${MR_DIM}Press Enter to continue...${MR_NC}"
    read -r
}

# ── Security Scanner ──
run_security_scan() {
    clear
    show_main_banner
    pulse_text "COMPREHENSIVE SECURITY SCAN" "$MR_RED"
    
    # ── Network Security ──
    dashboard_header "NETWORK SECURITY"
    local open_ports
    open_ports=$(ss -tuln 2>/dev/null | grep LISTEN | awk '{print $5}' | cut -d: -f2 | sort -u)
    dashboard_row "Open Ports:" "$(echo "$open_ports" | tr '\n' ',' | sed 's/,$//')" "ok"
    
    # Check for suspicious connections
    local suspicious_conns
    suspicious_conns=$(ss -tupn 2>/dev/null | grep -E "ESTAB" | grep -v "127.0.0.1" | wc -l)
    dashboard_row "Active Connections:" "$suspicious_conns" "$([[ $suspicious_conns -lt 10 ]] && echo "ok" || echo "warn")"
    dashboard_footer
    echo ""
    
    # ── Process Security ──
    dashboard_header "PROCESS SECURITY"
    local root_procs
    root_procs=$(ps aux 2>/dev/null | awk '$1=="root" {print $11}' | sort | uniq -c | sort -nr | head -5)
    echo "$root_procs" | while read -r count proc; do
        echo -e "    ${MR_WHITE}${count}x ${proc}${MR_NC}"
    done
    
    # Check for processes with unusual permissions
    local suspicious_procs
    suspicious_procs=$(ps aux 2>/dev/null | awk '$2 ~ /^[0-9]+$/ && $3 > 90 {print $11}' | head -3)
    if [[ -n "$suspicious_procs" ]]; then
        dashboard_row "High CPU Processes:" "$suspicious_procs" "warn"
    else
        dashboard_row "High CPU Processes:" "None detected" "ok"
    fi
    dashboard_footer
    echo ""
    
    # ── File System Security ──
    dashboard_header "FILE SYSTEM SECURITY"
    local world_writable
    world_writable=$(find /usr /bin /sbin 2>/dev/null -type f -perm -002 | wc -l)
    dashboard_row "World Writable Binaries:" "$world_writable" "$([[ $world_writable -eq 0 ]] && echo "ok" || echo "fail")"
    
    local suid_files
    suid_files=$(find /usr /bin /sbin 2>/dev/null -type f -perm -4000 | wc -l)
    dashboard_row "SUID Files:" "$suid_files" "ok"
    dashboard_footer
    echo ""
    
    # ── User Security ──
    dashboard_header "USER SECURITY"
    local empty_passwords
    empty_passwords=$(awk -F: '$2 == "" {print $1}' /etc/shadow 2>/dev/null | wc -l)
    dashboard_row "Empty Password Users:" "$empty_passwords" "$([[ $empty_passwords -eq 0 ]] && echo "ok" || echo "fail")"
    
    local sudo_users
    sudo_users=$(getent group sudo 2>/dev/null | cut -d: -f4 | tr ',' '\n' | wc -l)
    dashboard_row "Sudo Users:" "$sudo_users" "ok"
    dashboard_footer
    echo ""
    
    # ── Overall Security Score ──
    local security_score=100
    [[ $world_writable -gt 0 ]] && security_score=$((security_score - 25))
    [[ $empty_passwords -gt 0 ]] && security_score=$((security_score - 30))
    [[ $suspicious_conns -gt 20 ]] && security_score=$((security_score - 15))
    
    dashboard_header "SECURITY ASSESSMENT"
    dashboard_bar "Security Score" "$security_score" ""
    dashboard_footer
    
    echo ""
    echo -ne "  ${MR_DIM}Press Enter to continue...${MR_NC}"
    read -r
}

# ── Container Diagnostics ──
run_container_diagnostics() {
    clear
    show_main_banner
    pulse_text "CONTAINER INFRASTRUCTURE DIAGNOSTICS" "$MR_TEAL"
    
    # Check Docker
    if command -v docker &>/dev/null; then
        dashboard_header "DOCKER DIAGNOSTICS"
        local docker_status
        docker_status=$(systemctl is-active docker 2>/dev/null || echo "inactive")
        dashboard_row "Docker Service:" "$docker_status" "$([[ "$docker_status" == "active" ]] && echo "ok" || echo "fail")"
        
        if [[ "$docker_status" == "active" ]]; then
            local container_count
            container_count=$(docker ps -q 2>/dev/null | wc -l)
            local image_count
            image_count=$(docker images -q 2>/dev/null | wc -l)
            dashboard_row "Running Containers:" "$container_count" "ok"
            dashboard_row "Local Images:" "$image_count" "ok"
            
            # Check container health
            local unhealthy
            unhealthy=$(docker ps --filter "health=unhealthy" -q 2>/dev/null | wc -l)
            dashboard_row "Unhealthy Containers:" "$unhealthy" "$([[ $unhealthy -eq 0 ]] && echo "ok" || echo "fail")"
        fi
        dashboard_footer
        echo ""
    fi
    
    # Check Podman
    if command -v podman &>/dev/null; then
        dashboard_header "PODMAN DIAGNOSTICS"
        local podman_status
        podman_status=$(systemctl is-active podman 2>/dev/null || echo "inactive")
        dashboard_row "Podman Service:" "$podman_status" "$([[ "$podman_status" == "active" ]] && echo "ok" || echo "warn")"
        
        local podman_containers
        podman_containers=$(podman ps -q 2>/dev/null | wc -l)
        dashboard_row "Running Containers:" "$podman_containers" "ok"
        dashboard_footer
        echo ""
    fi
    
    # Check Kubernetes
    if command -v kubectl &>/dev/null; then
        dashboard_header "KUBERNETES DIAGNOSTICS"
        local k8s_nodes
        k8s_nodes=$(kubectl get nodes 2>/dev/null | grep -c "Ready" || echo 0)
        dashboard_row "Ready Nodes:" "$k8s_nodes" "$([[ $k8s_nodes -gt 0 ]] && echo "ok" || echo "warn")"
        
        local k8s_pods
        k8s_pods=$(kubectl get pods --all-namespaces 2>/dev/null | grep -c "Running" || echo 0)
        dashboard_row "Running Pods:" "$k8s_pods" "ok"
        dashboard_footer
        echo ""
    fi
    
    echo -ne "  ${MR_DIM}Press Enter to continue...${MR_NC}"
    read -r
}

# ── Advanced Reporting System ──
generate_advanced_report() {
    local report_type="$1"
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local report_file="$MR_LOG_DIR/advanced_report_${report_type}_${timestamp}.html"
    
    spinner_start "Generating comprehensive report..."
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>MR-LINMACHNIC Advanced Report - $report_type</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 40px; background: #1a1a1a; color: #ffffff; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 10px; margin-bottom: 30px; }
        .section { background: #2d2d2d; padding: 20px; margin: 20px 0; border-radius: 8px; border-left: 4px solid #667eea; }
        .metric { display: inline-block; margin: 10px; padding: 15px; background: #3d3d3d; border-radius: 5px; }
        .good { color: #4CAF50; }
        .warn { color: #FF9800; }
        .danger { color: #F44336; }
        .code { background: #1d1d1d; padding: 10px; border-radius: 4px; font-family: monospace; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { border: 1px solid #444; padding: 8px; text-align: left; }
        th { background: #3d3d3d; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🛠️ MR-LINMACHNIC Advanced Report</h1>
        <p><strong>Type:</strong> $report_type</p>
        <p><strong>Generated:</strong> $(date)</p>
        <p><strong>Hostname:</strong> $(hostname)</p>
        <p><strong>Kernel:</strong> $(uname -r)</p>
    </div>
EOF

    # System Overview
    cat >> "$report_file" << EOF
    <div class="section">
        <h2>📊 System Overview</h2>
        <div class="metric">
            <strong>CPU Usage:</strong> $(get_cpu_usage)%<br>
            <strong>Memory Usage:</strong> $(get_mem_usage)%<br>
            <strong>Disk Usage:</strong> $(get_disk_usage)%
        </div>
        <div class="metric">
            <strong>Load Average:</strong> $(cat /proc/loadavg | awk '{print $1" "$2" "$3}')<br>
            <strong>Uptime:</strong> $(uptime -p)
        </div>
    </div>
EOF

    # Failed Services
    local failed_svcs
    failed_svcs=$(get_failed_services 2>/dev/null || echo 0)
    cat >> "$report_file" << EOF
    <div class="section">
        <h2>🚨 Failed Services</h2>
        <p class="$([[ $failed_svcs -eq 0 ]] && echo "good" || echo "danger")">Total Failed: $failed_svcs</p>
EOF

    if [[ $failed_svcs -gt 0 ]]; then
        cat >> "$report_file" << EOF
        <div class="code">
$(get_failed_service_names 2>/dev/null | head -10)
        </div>
EOF
    fi

    cat >> "$report_file" << EOF
    </div>
EOF

    # Network Status
    cat >> "$report_file" << EOF
    <div class="section">
        <h2>🌐 Network Status</h2>
        <p class="$([[ $(check_internet && echo 1 || echo 0) -eq 1 ]] && echo "good" || echo "danger")">Internet: $([[ $(check_internet && echo 1 || echo 0) -eq 1 ]] && echo "Connected" || echo "Disconnected")</p>
        <p class="$([[ $(check_dns && echo 1 || echo 0) -eq 1 ]] && echo "good" || echo "warn")">DNS: $([[ $(check_dns && echo 1 || echo 0) -eq 1 ]] && echo "Working" || echo "Failed")</p>
        <h3>Open Ports:</h3>
        <div class="code">
$(ss -tuln 2>/dev/null | grep LISTEN | awk '{print $5}' | sort -u)
        </div>
    </div>
EOF

    # Recent Errors
    cat >> "$report_file" << EOF
    <div class="section">
        <h2>⚠️ Recent System Errors</h2>
        <div class="code">
$(journalctl -p err --no-pager -n 20 2>/dev/null | tail -20)
        </div>
    </div>
EOF

    # Health Score
    local health_score
    health_score=$(calc_health_score)
    cat >> "$report_file" << EOF
    <div class="section">
        <h2>🏥 System Health Score</h2>
        <div style="font-size: 48px; font-weight: bold; color: $([[ $health_score -ge 80 ]] && echo "#4CAF50" || [[ $health_score -ge 60 ]] && echo "#FF9800" || echo "#F44336")">
            $health_score/100
        </div>
        <p>Grade: $([[ $health_score -ge 90 ]] && echo "A+ EXCELLENT" || [[ $health_score -ge 80 ]] && echo "B+ GOOD" || [[ $health_score -ge 60 ]] && echo "C FAIR" || echo "D CRITICAL")</p>
    </div>
EOF

    cat >> "$report_file" << EOF
    <div class="section">
        <p><em>Generated by MR-LINMACHNIC Advanced Reporting System</em></p>
        <p><em>For more information, run: mr-machine --help</em></p>
    </div>
</body>
</html>
EOF

    spinner_stop "ok" "Report generated: $report_file"
    
    # Open in browser if available
    if command -v xdg-open &>/dev/null; then
        xdg-open "$report_file" 2>/dev/null &
    fi
    
    echo -ne "  ${MR_DIM}Press Enter to continue...${MR_NC}"
    read -r
}

# ── Plugin System ──
load_plugins() {
    local plugin_dir="$MR_PLUGINS_DIR"
    [[ ! -d "$plugin_dir" ]] && return 0
    
    for plugin in "$plugin_dir"/*.sh; do
        if [[ -f "$plugin" ]]; then
            source "$plugin"
            log_info "Loaded plugin: $(basename "$plugin")"
        fi
    done
}

# ── Cloud Integration (Optional) ──
sync_to_cloud() {
    local config
    config=$(cat "$MR_CONFIG_FILE" 2>/dev/null)
    
    if [[ -z "$config" ]] || [[ "$(echo "$config" | jq -r '.settings.cloud_sync' 2>/dev/null)" != "true" ]]; then
        return 0
    fi
    
    # Placeholder for cloud sync implementation
    # This would integrate with cloud storage APIs
    msg_info "Cloud sync feature ready (API integration required)"
}

# ── Batch Processing ──
run_batch_scan() {
    clear
    show_main_banner
    pulse_text "BATCH PROCESSING MODE" "$MR_GOLD"
    
    echo -e "  ${MR_WHITE}Available scan types:${MR_NC}"
    echo -e "  ${MR_GREEN}1.${MR_NC} Full System Scan"
    echo -e "  ${MR_GREEN}2.${MR_NC} Security Scan"
    echo -e "  ${MR_GREEN}3.${MR_NC} Hardware Diagnostics"
    echo -e "  ${MR_GREEN}4.${MR_NC} Container Infrastructure"
    echo -e "  ${MR_GREEN}5.${MR_NC} All Scans"
    echo ""
    echo -ne "  ${MR_CYAN}❯${MR_NC} Select scan type: "
    read -r batch_choice
    
    local scans=()
    case "$batch_choice" in
        1) scans=("health_scan" "auto_mode") ;;
        2) scans=("security_scan") ;;
        3) scans=("hardware_diagnostics") ;;
        4) scans=("container_diagnostics") ;;
        5) scans=("health_scan" "auto_mode" "security_scan" "hardware_diagnostics" "container_diagnostics") ;;
        *) msg_warn "Invalid selection"; return 1 ;;
    esac
    
    echo ""
    msg_info "Starting batch scan with ${#scans[@]} modules..."
    
    for scan in "${scans[@]}"; do
        case "$scan" in
            "health_scan")
                source "$SCRIPT_DIR/modules/health_scan.sh"
                run_health_scan
                ;;
            "auto_mode")
                source "$SCRIPT_DIR/modules/auto_mode.sh"
                run_auto_mode
                ;;
            "security_scan")
                run_security_scan
                ;;
            "hardware_diagnostics")
                run_hardware_diagnostics
                ;;
            "container_diagnostics")
                run_container_diagnostics
                ;;
        esac
    done
    
    # Generate combined report
    generate_advanced_report "batch_$(date +%Y%m%d_%H%M%S)"
}

# ── Configuration Editor ──
edit_advanced_config() {
    clear
    show_main_banner
    
    local config
    config=$(cat "$MR_CONFIG_FILE" 2>/dev/null)
    
    if [[ -z "$config" ]]; then
        init_advanced_config
        config=$(cat "$MR_CONFIG_FILE")
    fi
    
    while true; do
        dashboard_header "ADVANCED CONFIGURATION"
        echo ""
        echo -e "  ${MR_WHITE}Current Settings:${MR_NC}"
        echo -e "    Auto Update: $(echo "$config" | jq -r '.settings.auto_update')"
        echo -e "    Notifications: $(echo "$config" | jq -r '.settings.notifications')"
        echo -e "    Privacy Mode: $(echo "$config" | jq -r '.settings.privacy_mode')"
        echo -e "    Scan Depth: $(echo "$config" | jq -r '.settings.scan_depth')"
        echo -e "    Theme: $(echo "$config" | jq -r '.settings.theme')"
        echo ""
        echo -e "  ${MR_WHITE}Monitoring:${MR_NC}"
        echo -e "    Enabled: $(echo "$config" | jq -r '.monitoring.enabled')"
        echo -e "    Interval: $(echo "$config" | jq -r '.monitoring.interval') seconds"
        echo ""
        echo -e "  ${MR_WHITE}Security:${MR_NC}"
        echo -e "    Network Scan: $(echo "$config" | jq -r '.security.scan_network')"
        echo -e "    Process Scan: $(echo "$config" | jq -r '.security.scan_processes')"
        echo -e "    Auto Quarantine: $(echo "$config" | jq -r '.security.auto_quarantine')"
        echo ""
        echo -e "  ${MR_GREEN}1.${MR_NC} Toggle Auto Update"
        echo -e "  ${MR_GREEN}2.${MR_NC} Toggle Notifications"
        echo -e "  ${MR_GREEN}3.${MR_NC} Toggle Privacy Mode"
        echo -e "  ${MR_GREEN}4.${MR_NC} Set Scan Depth"
        echo -e "  ${MR_GREEN}5.${MR_NC} Toggle Monitoring"
        echo -e "  ${MR_GREEN}6.${MR_NC} Set Monitoring Interval"
        echo -e "  ${MR_GREEN}7.${MR_NC} Toggle Security Scans"
        echo -e "  ${MR_GREEN}8.${MR_NC} Edit Raw JSON"
        echo -e "  ${MR_RED}0.${MR_NC} Back"
        echo ""
        echo -ne "  ${MR_CYAN}❯${MR_NC} Select: "
        read -r config_choice
        
        case "$config_choice" in
            1)
                local current
                current=$(echo "$config" | jq -r '.settings.auto_update')
                local new_val
                new_val=$(echo "$config" | jq ".settings.auto_update = $(if [[ "$current" == "true" ]]; then echo false; else echo true; fi)")
                echo "$new_val" > "$MR_CONFIG_FILE"
                msg_ok "Auto Update set to: $(echo "$new_val" | jq -r '.settings.auto_update')"
                ;;
            2)
                current=$(echo "$config" | jq -r '.settings.notifications')
                new_val=$(echo "$config" | jq ".settings.notifications = $(if [[ "$current" == "true" ]]; then echo false; else echo true; fi)")
                echo "$new_val" > "$MR_CONFIG_FILE"
                msg_ok "Notifications set to: $(echo "$new_val" | jq -r '.settings.notifications')"
                ;;
            3)
                current=$(echo "$config" | jq -r '.settings.privacy_mode')
                new_val=$(echo "$config" | jq ".settings.privacy_mode = $(if [[ "$current" == "true" ]]; then echo false; else echo true; fi)")
                echo "$new_val" > "$MR_CONFIG_FILE"
                msg_ok "Privacy Mode set to: $(echo "$new_val" | jq -r '.settings.privacy_mode')"
                ;;
            4)
                echo -ne "  ${MR_CYAN}Enter scan depth (light/medium/heavy):${MR_NC} "
                read -r depth
                if [[ "$depth" =~ ^(light|medium|heavy)$ ]]; then
                    new_val=$(echo "$config" | jq ".settings.scan_depth = \"$depth\"")
                    echo "$new_val" > "$MR_CONFIG_FILE"
                    msg_ok "Scan depth set to: $depth"
                else
                    msg_warn "Invalid depth. Use: light, medium, or heavy"
                fi
                ;;
            5)
                current=$(echo "$config" | jq -r '.monitoring.enabled')
                new_val=$(echo "$config" | jq ".monitoring.enabled = $(if [[ "$current" == "true" ]]; then echo false; else echo true; fi)")
                echo "$new_val" > "$MR_CONFIG_FILE"
                msg_ok "Monitoring set to: $(echo "$new_val" | jq -r '.monitoring.enabled')"
                ;;
            6)
                echo -ne "  ${MR_CYAN}Enter monitoring interval in seconds:${MR_NC} "
                read -r interval
                if [[ "$interval" =~ ^[0-9]+$ ]] && [[ $interval -ge 60 ]]; then
                    new_val=$(echo "$config" | jq ".monitoring.interval = $interval")
                    echo "$new_val" > "$MR_CONFIG_FILE"
                    msg_ok "Monitoring interval set to: ${interval}s"
                else
                    msg_warn "Invalid interval. Must be a number >= 60"
                fi
                ;;
            7)
                echo -ne "  ${MR_CYAN}Toggle all security scans (y/n):${MR_NC} "
                read -r toggle
                if [[ "$toggle" =~ ^[Yy]$ ]]; then
                    new_val=$(echo "$config" | jq '.security.scan_network = true | .security.scan_processes = true | .security.scan_files = true')
                    echo "$new_val" > "$MR_CONFIG_FILE"
                    msg_ok "Security scans enabled"
                else
                    new_val=$(echo "$config" | jq '.security.scan_network = false | .security.scan_processes = false | .security.scan_files = false')
                    echo "$new_val" > "$MR_CONFIG_FILE"
                    msg_ok "Security scans disabled"
                fi
                ;;
            8)
                if command -v nano &>/dev/null; then
                    nano "$MR_CONFIG_FILE"
                elif command -v vim &>/dev/null; then
                    vim "$MR_CONFIG_FILE"
                else
                    msg_warn "No text editor available. Edit manually: $MR_CONFIG_FILE"
                fi
                ;;
            0) return ;;
            *) msg_warn "Invalid selection" ;;
        esac
        
        config=$(cat "$MR_CONFIG_FILE" 2>/dev/null)
    done
}

# ── Performance Optimizer ──
run_performance_optimizer() {
    clear
    show_main_banner
    pulse_text "SYSTEM PERFORMANCE OPTIMIZATION" "$MR_SKY"
    
    if ! require_root; then
        echo -ne "  ${MR_DIM}Press Enter...${MR_NC}"; read -r
        return
    fi
    
    echo -e "  ${MR_WHITE}Performance optimization options:${MR_NC}"
    echo -e "  ${MR_GREEN}1.${MR_NC} Clean system cache and temp files"
    echo -e "  ${MR_GREEN}2.${MR_NC} Optimize swap settings"
    echo -e "  ${MR_GREEN}3.${MR_NC} Tune kernel parameters"
    echo -e "  ${MR_GREEN}4.${MR_NC} Disable unnecessary services"
    echo -e "  ${MR_GREEN}5.${MR_NC} Optimize network settings"
    echo -e "  ${MR_GREEN}6.${MR_NC} All optimizations"
    echo ""
    echo -ne "  ${MR_CYAN}❯${MR_NC} Select optimization: "
    read -r opt_choice
    
    case "$opt_choice" in
        1)
            spinner_start "Cleaning system cache..."
            sudo apt clean 2>/dev/null || sudo yum clean all 2>/dev/null || true
            sudo journalctl --vacuum-time=7d 2>/dev/null || true
            sudo rm -rf /tmp/* 2>/dev/null || true
            spinner_stop "ok" "System cache cleaned"
            ;;
        2)
            spinner_start "Optimizing swap settings..."
            local mem_total
            mem_total=$(free -b | awk '/Mem:/ {print $2}')
            local swap_val
            if [[ $mem_total -lt 4000000000 ]]; then
                swap_val=80
            else
                swap_val=10
            fi
            echo "vm.swappiness=$swap_val" | sudo tee -a /etc/sysctl.conf >/dev/null
            sudo sysctl -w vm.swappiness=$swap_val >/dev/null
            spinner_stop "ok" "Swap optimized (swappiness: $swap_val)"
            ;;
        3)
            spinner_start "Tuning kernel parameters..."
            cat << EOF | sudo tee -a /etc/sysctl.conf >/dev/null
# MR-LINMACHNIC Performance Tuning
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 5000
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
EOF
            sudo sysctl -p >/dev/null
            spinner_stop "ok" "Kernel parameters tuned"
            ;;
        4)
            spinner_start "Disabling unnecessary services..."
            local services_to_disable=("bluetooth" "cups" "avahi-daemon" "ModemManager")
            for svc in "${services_to_disable[@]}"; do
                systemctl is-enabled "$svc" >/dev/null 2>&1 && sudo systemctl disable "$svc" >/dev/null 2>&1
            done
            spinner_stop "ok" "Unnecessary services disabled"
            ;;
        5)
            spinner_start "Optimizing network settings..."
            cat << EOF | sudo tee -a /etc/sysctl.conf >/dev/null
# MR-LINMACHNIC Network Optimization
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
EOF
            sudo sysctl -p >/dev/null
            spinner_stop "ok" "Network settings optimized"
            ;;
        6)
            run_performance_optimizer 1
            run_performance_optimizer 2
            run_performance_optimizer 3
            run_performance_optimizer 4
            run_performance_optimizer 5
            msg_ok "All performance optimizations applied"
            ;;
        *) msg_warn "Invalid selection" ;;
    esac
    
    echo -ne "  ${MR_DIM}Press Enter to continue...${MR_NC}"
    read -r
}

# ── Entry Points for Advanced Features ──
advanced_monitoring() {
    init_advanced_config
    start_monitoring
}

advanced_hardware_diagnostics() {
    init_advanced_config
    run_hardware_diagnostics
}

advanced_security_scan() {
    init_advanced_config
    run_security_scan
}

advanced_container_diagnostics() {
    init_advanced_config
    run_container_diagnostics
}

advanced_reporting() {
    init_advanced_config
    generate_advanced_report "manual_$(date +%Y%m%d_%H%M%S)"
}

advanced_batch_processing() {
    init_advanced_config
    run_batch_scan
}

advanced_configuration() {
    init_advanced_config
    edit_advanced_config
}

advanced_performance_optimizer() {
    init_advanced_config
    run_performance_optimizer
}

# Allow direct execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        "monitoring") advanced_monitoring ;;
        "hardware") advanced_hardware_diagnostics ;;
        "security") advanced_security_scan ;;
        "containers") advanced_container_diagnostics ;;
        "reporting") advanced_reporting ;;
        "batch") advanced_batch_processing ;;
        "config") advanced_configuration ;;
        "optimize") advanced_performance_optimizer ;;
        *) echo "Usage: $0 {monitoring|hardware|security|containers|reporting|batch|config|optimize}"; exit 1 ;;
    esac
fi