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
    echo -e "${MR_CYAN}"
    echo '    ╔══════════════════════════════════════════════════╗'
    echo '    ║   ⚡  AUTOMATED DIAGNOSTIC & REPAIR MODE        ║'
    echo '    ║   Scanning system for issues...                 ║'
    echo '    ╚══════════════════════════════════════════════════╝'
    echo -e "${MR_NC}"
    echo ""
    
    local issues_found=0
    local issues_fixed=0
    local total_checks=10
    local current_check=0
    
    log_info "Starting automated diagnostic scan"
    
    # ── Check 1: Disk Space ──
    ((current_check++))
    progress_bar $current_check $total_checks "Scanning"
    echo ""
    section_header "Disk Space Analysis" "💾"
    
    local disk_usage
    disk_usage=$(get_disk_usage)
    
    if [[ -n "$disk_usage" && "$disk_usage" -gt 90 ]]; then
        msg_fail "Disk usage CRITICAL: ${disk_usage}%"
        ((issues_found++))
        
        if require_root; then
            msg_fix "Attempting automatic cleanup..."
            
            # Clean journal logs
            if cmd_exists journalctl; then
                sudo journalctl --vacuum-time=3d --vacuum-size=100M 2>/dev/null
                msg_ok "Cleaned old journal logs"
            fi
            
            # Clean package cache
            local pkg_mgr
            pkg_mgr=$(detect_pkg_manager)
            case "$pkg_mgr" in
                apt)
                    sudo apt clean 2>/dev/null
                    sudo apt autoremove -y 2>/dev/null
                    msg_ok "Cleaned apt cache"
                    ;;
                dnf|yum)
                    sudo "$pkg_mgr" clean all 2>/dev/null
                    msg_ok "Cleaned $pkg_mgr cache"
                    ;;
                pacman)
                    sudo pacman -Sc --noconfirm 2>/dev/null
                    msg_ok "Cleaned pacman cache"
                    ;;
            esac
            
            # Clean /tmp
            sudo find /tmp -type f -atime +7 -delete 2>/dev/null
            msg_ok "Cleaned old temp files"
            
            ((issues_fixed++))
        fi
    elif [[ -n "$disk_usage" && "$disk_usage" -gt 75 ]]; then
        msg_warn "Disk usage WARNING: ${disk_usage}%"
        ((issues_found++))
    else
        msg_ok "Disk usage OK: ${disk_usage:-N/A}%"
    fi
    
    # ── Check 2: Memory Usage ──
    ((current_check++))
    echo ""
    progress_bar $current_check $total_checks "Scanning"
    echo ""
    section_header "Memory Analysis" "🧠"
    
    local mem_usage
    mem_usage=$(get_mem_usage)
    local mem_info
    mem_info=$(get_mem_info)
    
    if [[ "$mem_usage" != "N/A" && "$mem_usage" -gt 90 ]]; then
        msg_fail "Memory usage CRITICAL: ${mem_usage}%"
        msg_info "Memory: $mem_info"
        ((issues_found++))
        
        # Find top memory consumers
        msg_info "Top memory consumers:"
        ps aux --sort=-%mem 2>/dev/null | head -6 | awk 'NR>1 {printf "    %-20s %s%%\n", $11, $4}'
        
        # Check swap
        local swap_total
        swap_total=$(free | awk '/Swap:/ {print $2}')
        if [[ "$swap_total" -eq 0 ]]; then
            msg_warn "No swap space configured!"
            msg_info "Consider creating swap: sudo fallocate -l 2G /swapfile"
        fi
    elif [[ "$mem_usage" != "N/A" && "$mem_usage" -gt 75 ]]; then
        msg_warn "Memory usage HIGH: ${mem_usage}%"
        ((issues_found++))
    else
        msg_ok "Memory usage OK: ${mem_usage:-N/A}%"
    fi
    
    # ── Check 3: CPU Load ──
    ((current_check++))
    echo ""
    progress_bar $current_check $total_checks "Scanning"
    echo ""
    section_header "CPU Load Analysis" "⚡"
    
    local load_avg
    load_avg=$(get_load_avg)
    local cpu_cores
    cpu_cores=$(nproc 2>/dev/null || echo 1)
    local load1
    load1=$(echo "$load_avg" | awk '{print $1}')
    
    if [[ -n "$load1" ]]; then
        local load_int
        load_int=$(echo "$load1" | awk '{printf "%d", $1}')
        if [[ $load_int -gt $((cpu_cores * 2)) ]]; then
            msg_fail "System load VERY HIGH: $load_avg (${cpu_cores} cores)"
            ((issues_found++))
            msg_info "Top CPU consumers:"
            ps aux --sort=-%cpu 2>/dev/null | head -6 | awk 'NR>1 {printf "    %-20s %s%%\n", $11, $3}'
        elif [[ $load_int -gt $cpu_cores ]]; then
            msg_warn "System load HIGH: $load_avg (${cpu_cores} cores)"
            ((issues_found++))
        else
            msg_ok "System load OK: $load_avg (${cpu_cores} cores)"
        fi
    else
        msg_ok "System load: N/A"
    fi
    
    # ── Check 4: Failed Services ──
    ((current_check++))
    echo ""
    progress_bar $current_check $total_checks "Scanning"
    echo ""
    section_header "Service Health" "⚙️"
    
    if cmd_exists systemctl; then
        local failed_count
        failed_count=$(get_failed_services)
        
        if [[ "$failed_count" -gt 0 ]]; then
            msg_fail "$failed_count failed service(s) detected"
            ((issues_found++))
            
            local failed_names
            failed_names=$(get_failed_service_names)
            while IFS= read -r svc; do
                [[ -z "$svc" ]] && continue
                msg_warn "  Failed: $svc"
                
                if require_root; then
                    if confirm_action "Attempt to restart $svc?" "y"; then
                        sudo systemctl restart "$svc" 2>/dev/null
                        if systemctl is-active --quiet "$svc" 2>/dev/null; then
                            msg_ok "  Restarted: $svc"
                            ((issues_fixed++))
                        else
                            msg_fail "  Could not restart: $svc"
                        fi
                    fi
                fi
            done <<< "$failed_names"
        else
            msg_ok "All services running normally"
        fi
    else
        msg_info "systemctl not available"
    fi
    
    # ── Check 5: Network Connectivity ──
    ((current_check++))
    echo ""
    progress_bar $current_check $total_checks "Scanning"
    echo ""
    section_header "Network Connectivity" "🌐"
    
    if check_internet; then
        msg_ok "Internet connection OK"
        
        if check_dns; then
            msg_ok "DNS resolution OK"
        else
            msg_fail "DNS resolution FAILED"
            ((issues_found++))
            
            if require_root; then
                msg_fix "Setting Google DNS..."
                echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" | sudo tee /etc/resolv.conf > /dev/null 2>&1
                if check_dns; then
                    msg_ok "DNS fixed!"
                    ((issues_fixed++))
                fi
            fi
        fi
    else
        msg_fail "No internet connection"
        ((issues_found++))
        
        if require_root; then
            msg_fix "Attempting to restart NetworkManager..."
            sudo systemctl restart NetworkManager 2>/dev/null || sudo systemctl restart networking 2>/dev/null
            sleep 3
            if check_internet; then
                msg_ok "Network restored!"
                ((issues_fixed++))
            else
                msg_warn "Could not restore network automatically"
            fi
        fi
    fi
    
    # ── Check 6: Broken Packages ──
    ((current_check++))
    echo ""
    progress_bar $current_check $total_checks "Scanning"
    echo ""
    section_header "Package Health" "📦"
    
    local pkg_mgr
    pkg_mgr=$(detect_pkg_manager)
    
    case "$pkg_mgr" in
        apt)
            local broken
            broken=$(dpkg --audit 2>/dev/null | wc -l)
            if [[ "$broken" -gt 0 ]]; then
                msg_fail "Broken packages detected"
                ((issues_found++))
                if require_root; then
                    msg_fix "Fixing broken packages..."
                    sudo dpkg --configure -a 2>/dev/null
                    sudo apt --fix-broken install -y 2>/dev/null
                    msg_ok "Package repair attempted"
                    ((issues_fixed++))
                fi
            else
                msg_ok "No broken packages (apt)"
            fi
            ;;
        dnf|yum)
            msg_ok "Package manager: $pkg_mgr"
            ;;
        pacman)
            msg_ok "Package manager: pacman"
            ;;
        *)
            msg_info "Package manager: unknown"
            ;;
    esac
    
    # ── Check 7: Filesystem Errors ──
    ((current_check++))
    echo ""
    progress_bar $current_check $total_checks "Scanning"
    echo ""
    section_header "Filesystem Check" "🔍"
    
    local ro_mounts
    ro_mounts=$(mount 2>/dev/null | grep ' ro,' | grep -v 'snap\|squashfs\|tmpfs' | wc -l)
    if [[ "$ro_mounts" -gt 0 ]]; then
        msg_fail "Read-only filesystem detected!"
        ((issues_found++))
        mount 2>/dev/null | grep ' ro,' | grep -v 'snap\|squashfs\|tmpfs'
    else
        msg_ok "No read-only filesystem issues"
    fi
    
    # Check dmesg for filesystem errors
    if cmd_exists dmesg; then
        local fs_errors
        fs_errors=$(dmesg 2>/dev/null | grep -ci 'filesystem error\|ext4.*error\|io error' 2>/dev/null)
        if [[ "$fs_errors" -gt 0 ]]; then
            msg_warn "Filesystem errors in kernel log: $fs_errors"
            ((issues_found++))
        else
            msg_ok "No filesystem errors in kernel log"
        fi
    fi
    
    # ── Check 8: Boot Errors ──
    ((current_check++))
    echo ""
    progress_bar $current_check $total_checks "Scanning"
    echo ""
    section_header "Boot Health" "🔄"
    
    if cmd_exists journalctl; then
        local boot_errors
        boot_errors=$(journalctl -b -p err --no-pager 2>/dev/null | wc -l)
        if [[ "$boot_errors" -gt 20 ]]; then
            msg_warn "High number of boot errors: $boot_errors"
            ((issues_found++))
        elif [[ "$boot_errors" -gt 0 ]]; then
            msg_info "Minor boot errors: $boot_errors"
        else
            msg_ok "Boot clean — no errors"
        fi
    else
        msg_info "journalctl not available"
    fi
    
    # ── Check 9: Security ──
    ((current_check++))
    echo ""
    progress_bar $current_check $total_checks "Scanning"
    echo ""
    section_header "Security Quick Check" "🔒"
    
    # Check for open ports
    if cmd_exists ss; then
        local open_ports
        open_ports=$(ss -tulnp 2>/dev/null | grep LISTEN | wc -l)
        msg_info "$open_ports listening ports"
    fi
    
    # Check for failed SSH login attempts
    if [[ -f /var/log/auth.log ]]; then
        local ssh_fails
        ssh_fails=$(grep -c "Failed password" /var/log/auth.log 2>/dev/null)
        if [[ "$ssh_fails" -gt 100 ]]; then
            msg_warn "High SSH failure count: $ssh_fails (consider fail2ban)"
            ((issues_found++))
        else
            msg_ok "SSH security normal"
        fi
    fi
    
    # Check if firewall is active
    if cmd_exists ufw; then
        local fw_status
        fw_status=$(sudo ufw status 2>/dev/null | head -1)
        if echo "$fw_status" | grep -qi "inactive"; then
            msg_warn "Firewall is INACTIVE"
            ((issues_found++))
        else
            msg_ok "Firewall active"
        fi
    fi
    
    # ── Check 10: System Updates ──
    ((current_check++))
    echo ""
    progress_bar $current_check $total_checks "Scanning"
    echo ""
    section_header "Update Status" "📥"
    
    case "$pkg_mgr" in
        apt)
            if [[ -f /var/lib/update-notifier/updates-available ]]; then
                cat /var/lib/update-notifier/updates-available 2>/dev/null | while read -r line; do
                    [[ -n "$line" ]] && msg_info "$line"
                done
            else
                msg_ok "Update status check complete"
            fi
            ;;
        *)
            msg_info "Package manager: $pkg_mgr"
            ;;
    esac
    
    # ── Summary ──
    echo ""
    echo ""
    echo -e "  ${MR_CYAN}╔══════════════════════════════════════════════════╗${MR_NC}"
    echo -e "  ${MR_CYAN}║${MR_NC}        ${MR_WHITE}${MR_BOLD}📊 DIAGNOSTIC SUMMARY${MR_NC}"
    echo -e "  ${MR_CYAN}╚══════════════════════════════════════════════════╝${MR_NC}"
    echo ""
    
    local health_score
    health_score=$(calc_health_score)
    
    kv_print "Issues Found:" "$issues_found"
    kv_print "Issues Fixed:" "$issues_fixed"
    kv_print "Health Score:" "${health_score}/100"
    echo ""
    
    health_bar "CPU Health" "$((100 - $(get_cpu_usage 2>/dev/null || echo 0)))"
    health_bar "Memory" "$((100 - $(get_mem_usage 2>/dev/null || echo 0)))"
    health_bar "Disk" "$((100 - $(get_disk_usage 2>/dev/null || echo 0)))"
    health_bar "Overall" "$health_score"
    echo ""
    
    if [[ $issues_found -eq 0 ]]; then
        echo -e "  ${MR_GREEN}${MR_BOLD}✅ System is healthy! No issues detected.${MR_NC}"
    elif [[ $issues_fixed -eq $issues_found ]]; then
        echo -e "  ${MR_GREEN}${MR_BOLD}✅ All $issues_found issue(s) were automatically fixed!${MR_NC}"
    else
        local remaining=$((issues_found - issues_fixed))
        echo -e "  ${MR_YELLOW}⚠️  $remaining issue(s) require manual attention.${MR_NC}"
        echo -e "  ${MR_DIM}Use Manual Mode for step-by-step troubleshooting.${MR_NC}"
    fi
    
    echo ""
    log_info "Scan complete: $issues_found found, $issues_fixed fixed, score $health_score"
    
    echo -ne "  ${MR_DIM}Press Enter to continue...${MR_NC}"
    read -r
}

# Allow direct execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_auto_mode
fi
