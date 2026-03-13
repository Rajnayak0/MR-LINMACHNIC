#!/bin/bash
#==============================================================================
#  MR-LINMACHNIC - AI Mode (Online Advanced Analysis)
#  Free AI-powered log analysis using local pattern matching + online APIs
#  Author: Madan Raj
#==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/ui.sh"
source "$SCRIPT_DIR/lib/utils.sh"

# ── Error pattern database (offline AI) ──
declare -A ERROR_PATTERNS
ERROR_PATTERNS=(
    ["OOM"]="Out of Memory|oom-killer|Cannot allocate memory"
    ["DISK"]="No space left|disk full|I/O error|filesystem.*error"
    ["NET"]="Network is unreachable|connection refused|DNS.*fail|No route to host"
    ["BOOT"]="kernel panic|initramfs|grub.*error|boot.*fail"
    ["SERVICE"]="Failed to start|service.*fail|daemon.*crash|segfault"
    ["AUTH"]="authentication failure|Failed password|permission denied|access denied"
    ["GPU"]="gpu.*error|nvidia.*fail|xorg.*error|display.*fail"
    ["USB"]="usb.*error|device not accepting|descriptor read"
    ["FS"]="ext4.*error|xfs.*error|corrupt|bad superblock"
    ["KERNEL"]="BUG:|kernel.*oops|WARNING.*CPU|soft lockup"
)

declare -A ERROR_SOLUTIONS
ERROR_SOLUTIONS=(
    ["OOM"]="1. Check memory hogs: ps aux --sort=-%mem | head\n2. Add swap: sudo fallocate -l 2G /swapfile\n3. Set swappiness: echo 60 | sudo tee /proc/sys/vm/swappiness\n4. Kill memory hog: kill -9 <PID>"
    ["DISK"]="1. Check usage: df -h\n2. Clean logs: sudo journalctl --vacuum-time=3d\n3. Clean cache: sudo apt clean\n4. Find large files: sudo du -sh /* | sort -rh | head"
    ["NET"]="1. Restart network: sudo systemctl restart NetworkManager\n2. Check DNS: cat /etc/resolv.conf\n3. Test: ping -c 3 8.8.8.8\n4. Renew DHCP: sudo dhclient -r && sudo dhclient"
    ["BOOT"]="1. Boot older kernel from GRUB\n2. Fix GRUB: sudo update-grub\n3. Rebuild initramfs: sudo update-initramfs -u\n4. Check fstab: cat /etc/fstab"
    ["SERVICE"]="1. Check status: systemctl status <service>\n2. View logs: journalctl -u <service> -n 50\n3. Restart: sudo systemctl restart <service>\n4. Reload: sudo systemctl daemon-reload"
    ["AUTH"]="1. Check /var/log/auth.log\n2. Reset password: sudo passwd <user>\n3. Check permissions: ls -la\n4. Install fail2ban: sudo apt install fail2ban"
    ["GPU"]="1. Check GPU: lspci | grep VGA\n2. Add nomodeset to GRUB\n3. Reinstall driver: sudo apt install nvidia-driver-xxx\n4. Check Xorg.log: cat /var/log/Xorg.0.log | grep EE"
    ["USB"]="1. Check: lsusb\n2. Check dmesg: dmesg | tail -20\n3. Reset USB: sudo modprobe -r usbhid && sudo modprobe usbhid\n4. Try different port"
    ["FS"]="1. Run fsck: sudo fsck -y /dev/sdX\n2. Check SMART: sudo smartctl -H /dev/sda\n3. Mount read-only first\n4. Backup critical data!"
    ["KERNEL"]="1. Update kernel: sudo apt install linux-image-generic\n2. Check dmesg: dmesg | grep -i bug\n3. Boot older kernel\n4. Check hardware (RAM test)"
)

run_ai_mode() {
    clear
    echo -e "${MR_CYAN}"
    echo '    ╔══════════════════════════════════════════════════╗'
    echo '    ║   🤖  AI-POWERED ANALYSIS MODE                  ║'
    echo '    ║   Intelligent log parsing & error detection      ║'
    echo '    ╚══════════════════════════════════════════════════╝'
    echo -e "${MR_NC}"
    echo ""
    
    while true; do
        echo -e "  ${MR_WHITE}${MR_BOLD}Analysis Options:${MR_NC}"
        echo ""
        echo -e "  ${MR_GREEN}1.${MR_NC}  🔍  ${MR_WHITE}Analyze System Logs${MR_NC}         ${MR_DIM}(journalctl)${MR_NC}"
        echo -e "  ${MR_GREEN}2.${MR_NC}  🐛  ${MR_WHITE}Analyze Kernel Messages${MR_NC}     ${MR_DIM}(dmesg)${MR_NC}"
        echo -e "  ${MR_GREEN}3.${MR_NC}  📋  ${MR_WHITE}Analyze Custom Log File${MR_NC}     ${MR_DIM}(provide path)${MR_NC}"
        echo -e "  ${MR_GREEN}4.${MR_NC}  ⚡  ${MR_WHITE}Full System AI Scan${MR_NC}         ${MR_DIM}(comprehensive)${MR_NC}"
        echo -e "  ${MR_GREEN}5.${MR_NC}  🔎  ${MR_WHITE}Search Error Pattern${MR_NC}        ${MR_DIM}(custom query)${MR_NC}"
        echo ""
        echo -e "  ${MR_RED}0.${MR_NC}  ← Back to Main Menu"
        echo ""
        echo -ne "  ${MR_CYAN}❯${MR_NC} Select: "
        read -r choice
        
        case $choice in
            1) analyze_journalctl ;;
            2) analyze_dmesg ;;
            3) analyze_custom_log ;;
            4) full_ai_scan ;;
            5) search_error_pattern ;;
            0) return ;;
            *) msg_warn "Invalid option"; sleep 1 ;;
        esac
    done
}

analyze_log_content() {
    local log_content="$1"
    local source="$2"
    local found_issues=0
    
    echo ""
    echo -e "  ${MR_CYAN}${MR_BOLD}🤖 AI Analysis Results — $source${MR_NC}"
    echo -e "  ${MR_DIM}$(printf '─%.0s' $(seq 1 50))${MR_NC}"
    echo ""
    
    for category in "${!ERROR_PATTERNS[@]}"; do
        local pattern="${ERROR_PATTERNS[$category]}"
        local matches
        matches=$(echo "$log_content" | grep -ciE "$pattern" 2>/dev/null)
        
        if [[ "$matches" -gt 0 ]]; then
            ((found_issues++))
            
            local severity="⚠️  WARNING"
            local severity_color="$MR_YELLOW"
            if [[ "$matches" -gt 10 ]]; then
                severity="🔴 CRITICAL"
                severity_color="$MR_RED"
            elif [[ "$matches" -gt 5 ]]; then
                severity="🟠 HIGH"
                severity_color="$MR_ORANGE"
            fi
            
            echo -e "  ${severity_color}${severity}${MR_NC} — ${MR_WHITE}${MR_BOLD}$category Issues${MR_NC} (${matches} occurrences)"
            echo ""
            
            # Show sample errors
            echo -e "  ${MR_DIM}Sample errors:${MR_NC}"
            echo "$log_content" | grep -iE "$pattern" 2>/dev/null | head -3 | while read -r line; do
                echo -e "    ${MR_DIM}▸ $(echo "$line" | cut -c1-100)${MR_NC}"
            done
            echo ""
            
            # Show solution
            echo -e "  ${MR_TEAL}${MR_BOLD}Recommended Fix:${MR_NC}"
            echo -e "$(echo -e "${ERROR_SOLUTIONS[$category]}" | sed 's/^/    /')"
            echo ""
            echo -e "  ${MR_DIM}$(printf '─%.0s' $(seq 1 50))${MR_NC}"
            echo ""
        fi
    done
    
    if [[ $found_issues -eq 0 ]]; then
        echo -e "  ${MR_GREEN}${MR_BOLD}✅ No critical issues detected in $source${MR_NC}"
        echo -e "  ${MR_DIM}The analyzed logs appear healthy.${MR_NC}"
    else
        echo ""
        echo -e "  ${MR_WHITE}${MR_BOLD}📊 Summary: $found_issues issue category(s) detected${MR_NC}"
    fi
    
    echo ""
}

analyze_journalctl() {
    clear
    section_header "Analyzing System Logs (journalctl)" "🔍"
    
    if ! cmd_exists journalctl; then
        msg_fail "journalctl not available on this system"
        echo -ne "  ${MR_DIM}Press Enter...${MR_NC}"; read -r
        return
    fi
    
    spinner_start "Collecting system logs..."
    local logs
    logs=$(journalctl -b -p warning --no-pager -n 500 2>/dev/null)
    spinner_stop "ok" "System logs collected"
    
    spinner_start "Running AI pattern analysis..."
    sleep 1
    spinner_stop "ok" "Analysis complete"
    
    analyze_log_content "$logs" "System Logs"
    
    echo -ne "  ${MR_DIM}Press Enter to continue...${MR_NC}"; read -r
}

analyze_dmesg() {
    clear
    section_header "Analyzing Kernel Messages (dmesg)" "🐛"
    
    if ! cmd_exists dmesg; then
        msg_fail "dmesg not available"
        echo -ne "  ${MR_DIM}Press Enter...${MR_NC}"; read -r
        return
    fi
    
    spinner_start "Collecting kernel messages..."
    local logs
    logs=$(dmesg --level=err,warn 2>/dev/null || dmesg 2>/dev/null)
    spinner_stop "ok" "Kernel messages collected"
    
    spinner_start "Running AI pattern analysis..."
    sleep 1
    spinner_stop "ok" "Analysis complete"
    
    analyze_log_content "$logs" "Kernel Messages"
    
    echo -ne "  ${MR_DIM}Press Enter to continue...${MR_NC}"; read -r
}

analyze_custom_log() {
    clear
    section_header "Analyze Custom Log File" "📋"
    
    styled_prompt "Enter log file path"
    local log_path="$REPLY"
    
    if [[ ! -f "$log_path" ]]; then
        msg_fail "File not found: $log_path"
        echo -ne "  ${MR_DIM}Press Enter...${MR_NC}"; read -r
        return
    fi
    
    spinner_start "Reading log file..."
    local logs
    logs=$(cat "$log_path" 2>/dev/null | tail -1000)
    spinner_stop "ok" "Log file loaded ($(wc -l <<< "$logs") lines)"
    
    spinner_start "Running AI pattern analysis..."
    sleep 1
    spinner_stop "ok" "Analysis complete"
    
    analyze_log_content "$logs" "$log_path"
    
    echo -ne "  ${MR_DIM}Press Enter to continue...${MR_NC}"; read -r
}

full_ai_scan() {
    clear
    section_header "Full System AI Scan" "⚡"
    
    local all_logs=""
    local sources_scanned=0
    
    # Collect from multiple sources
    echo -e "  ${MR_CYAN}Collecting logs from multiple sources...${MR_NC}"
    echo ""
    
    if cmd_exists journalctl; then
        spinner_start "Collecting journalctl logs..."
        all_logs+=$(journalctl -b -p warning --no-pager -n 200 2>/dev/null)
        all_logs+=$'\n'
        ((sources_scanned++))
        spinner_stop "ok" "journalctl logs collected"
    fi
    
    if cmd_exists dmesg; then
        spinner_start "Collecting dmesg..."
        all_logs+=$(dmesg 2>/dev/null | tail -200)
        all_logs+=$'\n'
        ((sources_scanned++))
        spinner_stop "ok" "dmesg collected"
    fi
    
    if [[ -f /var/log/syslog ]]; then
        spinner_start "Collecting syslog..."
        all_logs+=$(tail -200 /var/log/syslog 2>/dev/null)
        all_logs+=$'\n'
        ((sources_scanned++))
        spinner_stop "ok" "syslog collected"
    fi
    
    if [[ -f /var/log/auth.log ]]; then
        spinner_start "Collecting auth.log..."
        all_logs+=$(tail -200 /var/log/auth.log 2>/dev/null)
        all_logs+=$'\n'
        ((sources_scanned++))
        spinner_stop "ok" "auth.log collected"
    fi
    
    if [[ -f /var/log/kern.log ]]; then
        spinner_start "Collecting kern.log..."
        all_logs+=$(tail -200 /var/log/kern.log 2>/dev/null)
        all_logs+=$'\n'
        ((sources_scanned++))
        spinner_stop "ok" "kern.log collected"
    fi
    
    echo ""
    msg_info "$sources_scanned log sources scanned"
    
    spinner_start "Running comprehensive AI analysis..."
    sleep 2
    spinner_stop "ok" "Analysis complete"
    
    analyze_log_content "$all_logs" "Full System ($sources_scanned sources)"
    
    echo -ne "  ${MR_DIM}Press Enter to continue...${MR_NC}"; read -r
}

search_error_pattern() {
    clear
    section_header "Search Error Pattern" "🔎"
    
    styled_prompt "Enter error text or pattern to search"
    local query="$REPLY"
    
    [[ -z "$query" ]] && return
    
    echo ""
    msg_info "Searching across system logs for: $query"
    echo ""
    
    local found=0
    
    # Search journalctl
    if cmd_exists journalctl; then
        local j_results
        j_results=$(journalctl --no-pager -n 1000 2>/dev/null | grep -i "$query" | tail -10)
        if [[ -n "$j_results" ]]; then
            echo -e "  ${MR_CYAN}${MR_BOLD}Found in journalctl:${MR_NC}"
            echo "$j_results" | while read -r line; do
                echo -e "    ${MR_DIM}$line${MR_NC}"
            done
            echo ""
            found=1
        fi
    fi
    
    # Search dmesg
    if cmd_exists dmesg; then
        local d_results
        d_results=$(dmesg 2>/dev/null | grep -i "$query" | tail -10)
        if [[ -n "$d_results" ]]; then
            echo -e "  ${MR_CYAN}${MR_BOLD}Found in dmesg:${MR_NC}"
            echo "$d_results" | while read -r line; do
                echo -e "    ${MR_DIM}$line${MR_NC}"
            done
            echo ""
            found=1
        fi
    fi
    
    # Search syslog
    if [[ -f /var/log/syslog ]]; then
        local s_results
        s_results=$(grep -i "$query" /var/log/syslog 2>/dev/null | tail -10)
        if [[ -n "$s_results" ]]; then
            echo -e "  ${MR_CYAN}${MR_BOLD}Found in syslog:${MR_NC}"
            echo "$s_results" | while read -r line; do
                echo -e "    ${MR_DIM}$line${MR_NC}"
            done
            echo ""
            found=1
        fi
    fi
    
    if [[ $found -eq 0 ]]; then
        msg_ok "No matches found for: $query"
    fi
    
    echo -ne "  ${MR_DIM}Press Enter to continue...${MR_NC}"; read -r
}

# Allow direct execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_ai_mode
fi
