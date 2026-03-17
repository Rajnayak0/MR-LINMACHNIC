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
    echo '    ║   LinkedIn: www.linkedin.com/in/madanraj0        ║'
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
        echo -e "  ${MR_GREEN}6.${MR_NC}  🌐  ${MR_WHITE}Online AI Deep Analysis${MR_NC}     ${MR_DIM}(requires API key)${MR_NC}"
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
            6) online_ai_deep_analysis ;;
            0) return ;;
            *) msg_warn "Invalid option"; sleep 1 ;;
        esac
    done
}

analyze_log_content() {
    local log_content="$1"
    local source="$2"
    local found_issues=0
    
    # ── SYSTEM CONTEXT ──
    dashboard_header "SYSTEM INFO"
    dashboard_row "Hostname:" "$(hostname 2>/dev/null || echo unknown)"
    dashboard_row "Distribution:" "$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo Linux)"
    dashboard_row "Kernel:" "$(uname -r 2>/dev/null || echo unknown)"
    dashboard_row "Uptime:" "$(uptime -p 2>/dev/null | sed 's/up //' || echo unknown)"
    dashboard_footer
    echo ""

    # ── RESOURCE SNAPSHOT ──
    dashboard_header "RESOURCE USAGE"
    dashboard_bar "CPU" "$(get_cpu_usage 2>/dev/null || echo 0)" "$(get_cpu_usage 2>/dev/null || echo 0)% load"
    dashboard_bar "Memory" "$(get_mem_usage 2>/dev/null || echo 0)" "$(free -h 2>/dev/null | awk '/Mem:/ {print $3" / "$2}' || echo 'N/A')"
    dashboard_bar "Disk" "$(get_disk_usage 2>/dev/null || echo 0)" "$(df -h / 2>/dev/null | awk 'NR==2 {print $3" / "$2}' || echo 'N/A')"
    dashboard_footer
    echo ""

    # ── AI LOG FINDINGS ──
    dashboard_header "AI LOG ANALYSIS — $source" "$MR_SKY"
    
    for category in "${!ERROR_PATTERNS[@]}"; do
        local pattern="${ERROR_PATTERNS[$category]}"
        matches=$(echo "$log_content" | grep -ciE "$pattern" 2>/dev/null || true)
        # Ensure it's a number
        if ! [[ "$matches" =~ ^[0-9]+$ ]]; then matches=0; fi
        
        if [[ "$matches" -gt 0 ]]; then
            ((found_issues++))
            
            local severity="WARNING"
            local s_status="warn"
            if [[ "$matches" -gt 10 ]]; then severity="CRITICAL"; s_status="fail";
            elif [[ "$matches" -gt 5 ]]; then severity="HIGH"; s_status="warn"; fi
            
            dashboard_row "Issue:" "$category ($severity)" "$s_status"
            dashboard_row "Occurrences:" "$matches"
            
            # Show sample errors
            local sample_err
            sample_err=$(echo "$log_content" | grep -iE "$pattern" 2>/dev/null | head -1 | cut -c1-60 || true)
            echo -e "    ${MR_DIM}Sample:${MR_NC} ${sample_err}..."
            
            # Show solution
            echo -e "    ${MR_TEAL}${MR_BOLD}Fix:${MR_NC} ${ERROR_SOLUTIONS[$category]%%$'\n'*}"
            echo -e "  ${MR_DIM}  $(printf '┄%.0s' $(seq 1 45))${MR_NC}"
        fi
    done
    
    if [[ $found_issues -eq 0 ]]; then
        dashboard_row "Status:" "Healthy" "ok"
        dashboard_row "Result:" "No issues detected"
    else
        dashboard_row "Total Categories:" "$found_issues" "warn"
    fi
    dashboard_footer "$MR_SKY"
    
    # ── OVERALL HEALTH ──
    echo ""
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
}

analyze_journalctl() {
    show_ascii_banner "Analyzing System Logs" "Journalctl Log Analysis"
    
    if ! cmd_exists journalctl; then
        msg_fail "journalctl not available on this system"
        echo -ne "  ${MR_DIM}Press Enter...${MR_NC}"; read -r
        return
    fi
    
    spinner_start "Collecting system logs..." "braille"
    local logs
    logs=$(journalctl -b -p warning --no-pager -n 500 2>/dev/null || echo "Error: journalctl logs inaccessible")
    sleep 0.5
    spinner_stop "ok" "System logs collected"
    
    pulse_text "Neural Pattern Analysis" "$MR_MAGENTA"
    spinner_start "Running AI pattern analysis..." "blocks"
    sleep 1
    spinner_stop "ok" "Analysis complete"
    
    analyze_log_content "$logs" "System Logs"
    
    echo -ne "  ${MR_DIM}Press Enter to continue...${MR_NC}"; read -r
}

analyze_dmesg() {
    show_ascii_banner "Analyzing Kernel Messages" "DMESG Log Analysis"
    
    if ! cmd_exists dmesg; then
        msg_fail "dmesg not available"
        echo -ne "  ${MR_DIM}Press Enter...${MR_NC}"; read -r
        return
    fi
    
    spinner_start "Collecting kernel messages..." "arrows"
    local logs
    logs=$(dmesg --level=err,warn 2>/dev/null || dmesg 2>/dev/null || echo "Error: kernel logs inaccessible")
    sleep 0.5
    spinner_stop "ok" "Kernel messages collected"
    
    pulse_text "Decoding Kernel Metadata" "$MR_MAGENTA"
    spinner_start "Running AI pattern analysis..." "blocks"
    sleep 1
    spinner_stop "ok" "Analysis complete"
    
    analyze_log_content "$logs" "Kernel Messages"
    
    echo -ne "  ${MR_DIM}Press Enter to continue...${MR_NC}"; read -r
}

analyze_custom_log() {
    show_ascii_banner "Analyze Custom Log File" "Custom Log Analysis"
    
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
    show_ascii_banner "Full System AI Scan" "Comprehensive System Analysis"
    
    local all_logs=""
    local sources_scanned=0
    local initial_health
    local final_health
    
    # Get initial health score
    initial_health=$(calc_health_score)
    
    msg_info "Initializing Full System AI Scan..."
    echo ""
    
    local all_logs=""
    local sources_scanned=0
    
    echo -e "  ${MR_CYAN}Collecting logs from multiple sources...${MR_NC}"
    echo ""
    
    if cmd_exists journalctl; then
        spinner_start "Collecting journalctl logs..."
        local j_logs
        j_logs=$(journalctl -b -p warning --no-pager -n 200 2>/dev/null || echo "Error: journalctl logs inaccessible")
        all_logs+="$j_logs"$'\n'
        ((sources_scanned++))
        spinner_stop "ok" "journalctl logs collected"
    fi
    
    if cmd_exists dmesg; then
        spinner_start "Collecting dmesg..."
        local d_logs
        d_logs=$(dmesg 2>/dev/null | tail -200 || echo "Error: dmesg logs inaccessible")
        all_logs+="$d_logs"$'\n'
        ((sources_scanned++))
        spinner_stop "ok" "dmesg collected"
    fi
    
    if [[ -f /var/log/syslog ]]; then
        spinner_start "Collecting syslog..."
        local s_logs
        s_logs=$(tail -200 /var/log/syslog 2>/dev/null || echo "Error: syslog inaccessible")
        all_logs+="$s_logs"$'\n'
        ((sources_scanned++))
        spinner_stop "ok" "syslog collected"
    fi
    
    if [[ -f /var/log/auth.log ]]; then
        spinner_start "Collecting auth.log..."
        local a_logs
        a_logs=$(tail -200 /var/log/auth.log 2>/dev/null || echo "Error: auth.log inaccessible")
        all_logs+="$a_logs"$'\n'
        ((sources_scanned++))
        spinner_stop "ok" "auth.log collected"
    fi
    
    echo ""
    msg_info "$sources_scanned log sources scanned"
    
    spinner_start "Running comprehensive AI analysis..."
    sleep 1.5
    spinner_stop "ok" "Analysis complete"
    
    analyze_log_content "$all_logs" "Full System ($sources_scanned sources)"
    
    local final_health
    final_health=$(calc_health_score)
    dashboard_header "SCAN RESULTS"
    dashboard_bar "Final Health" "$final_health" ""
    dashboard_footer
    echo ""
    
    # Save report
    save_report "AI System Scan" "$initial_health" "$final_health" "$sources_scanned sources" "N/A" "Performed full system log analysis using local patterns and AI."
    
    echo -ne "  ${MR_DIM}Press Enter to continue...${MR_NC}"; read -r
}

search_error_pattern() {
    show_ascii_banner "Search Error Pattern" "Custom Error Pattern Search"
    
    # ── SYSTEM CONTEXT ──
    dashboard_header "SYSTEM INFO"
    dashboard_row "Hostname:" "$(hostname 2>/dev/null || echo unknown)"
    dashboard_row "Kernel:" "$(uname -r 2>/dev/null || echo unknown)"
    dashboard_footer
    echo ""

    styled_prompt "Enter error text or pattern to search"
    local query="$REPLY"
    [[ -z "$query" ]] && return
    
    echo ""
    msg_info "Searching across system logs for: $query"
    echo ""
    
    local found=0
    dashboard_header "SEARCH RESULTS — $query" "$MR_MAGENTA"
    
    # Search journalctl
    if cmd_exists journalctl; then
        local j_results
        j_results=$(journalctl --no-pager -n 1000 2>/dev/null | grep -i "$query" | tail -5)
        if [[ -n "$j_results" ]]; then
            dashboard_row "Source:" "journalctl" "ok"
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
        d_results=$(dmesg 2>/dev/null | grep -i "$query" | tail -5)
        if [[ -n "$d_results" ]]; then
            dashboard_row "Source:" "dmesg" "ok"
            echo "$d_results" | while read -r line; do
                echo -e "    ${MR_DIM}$line${MR_NC}"
            done
            echo ""
            found=1
        fi
    fi
    
    if [[ $found -eq 0 ]]; then
        dashboard_row "Status:" "No matches found" "warn"
    fi
    dashboard_footer "$MR_MAGENTA"
    
    echo ""
    local health_score
    health_score=$(calc_health_score)
    dashboard_header "CURRENT SYSTEM HEALTH"
    dashboard_bar "Overall" "$health_score" ""
    dashboard_footer
    
    echo ""
    echo -ne "  ${MR_DIM}Press Enter to continue...${MR_NC}"; read -r
}

# ── Online AI Integration ──

call_ai_api() {
    local content="$1"
    local system_prompt="You are MR-LINMACHNIC AI assistant. Analyze the following Linux system logs for errors, security issues, and performance bottlenecks. Provide a concise summary of the problems and clear, actionable bash commands to fix them. Format the output with clear headings and bullet points."
    
    # Check and install dependencies with proper error handling
    if ! check_and_install_dep "curl" "true"; then
        msg_fail "curl is required for online AI analysis"
        return 1
    fi
    
    if ! check_and_install_dep "jq" "true"; then
        msg_fail "jq is required for online AI analysis"
        return 1
    fi

    # Multi-Provider Failover Pool (URL | Auth Header Key | Model)
    local providers=(
        "https://openrouter.ai/api/v1/chat/completions|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|openai/gpt-oss-120b:free"
        "https://openrouter.ai/api/v1/chat/completions|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|google/gemma-3n-e4b-it:free"
        "https://openrouter.ai/api/v1/chat/completions|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|nvidia/nemotron-3-nano-30b-a3b:free"
        "https://openrouter.ai/api/v1/chat/completions|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|qwen/qwen3-next-80b-a3b-instruct:free"
        "https://openrouter.ai/api/v1/chat/completions|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|arcee-ai/trinity-large-preview:free"
        "https://router.huggingface.co/v1/chat/completions|sk-5ebbb0347d5e44cf9fb97bc46c2a1efd|UnfilteredAI/DAN-L3-R1-8B:featherless-ai"
        "https://openrouter.ai/api/v1/chat/completions|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|deepseek/deepseek-r1:free"
        "https://openrouter.ai/api/v1/chat/completions|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|mistralai/mistral-7b-instruct:free"
        "https://api.deepseek.com/chat/completions|sk-0c359ef43ff8412eab96980d9919fe48|deepseek-chat"
        "https://openrouter.ai/api/v1/chat/completions|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|google/gemini-2.0-flash-exp:free"
        "https://openrouter.ai/api/v1/chat/completions|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|google/gemini-2.0-pro-exp-02-05:free"
        "https://api.openai.com/v1/chat/completions|AIzaSyAme4o1yxAbIVe3rNc-okHUXJTkMOCl2cM|gemini"
    )
    
    # Inject user's local .env keys if they exist to the front
    if [[ -n "${OPENROUTER_API_KEY_1:-}" ]]; then
        local clean_k=$(echo "$OPENROUTER_API_KEY_1" | tr -d '"'\'' \r')
        if [[ -n "$clean_k" ]]; then
            providers=("https://openrouter.ai/api/v1/chat/completions|${clean_k}|deepseek/deepseek-r1:free" "${providers[@]}")
        fi
    fi

    local success=0
    local ai_text=""
    local attempt_count=0
    local max_attempts=${#providers[@]}
    
    echo ""
    msg_info "Starting AI analysis with ${max_attempts} providers..."
    
    for provider in "${providers[@]}"; do
        ((attempt_count++))
        local url="${provider%%|*}"
        local rest="${provider#*|}"
        local key="${rest%%|*}"
        local model="${rest#*|}"

        spinner_start "Consulting Cloud AI: $model (Attempt $attempt_count/$max_attempts)..."
        
        # Validate API key format
        if [[ -z "$key" || ${#key} -lt 10 ]]; then
            spinner_stop "fail" "Invalid API key format"
            continue
        fi
        
        # Escape content for JSON safely
        local escaped_content
        escaped_content=$(printf '%s' "$content" | jq -aRs '.' 2>/dev/null)
        
        if [[ -z "$escaped_content" ]]; then
            spinner_stop "fail" "Failed to escape content for JSON"
            continue
        fi

        # Make API request with timeout and error handling
        local response
        response=$(curl -s --connect-timeout 30 --max-time 60 -X POST "$url" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $key" \
            -d "{
                \"model\": \"$model\",
                \"messages\": [
                    {\"role\": \"system\", \"content\": \"$system_prompt\"},
                    {\"role\": \"user\", \"content\": $escaped_content}
                ]
            }" 2>&1)

        # Check for curl errors
        if [[ "$response" == "curl:"* ]]; then
            spinner_stop "fail" "Connection error to $url"
            log_warn "Curl error: $response"
            continue
        fi
        
        # Check for empty response
        if [[ -z "$response" ]]; then
            spinner_stop "fail" "Empty response from $url"
            continue
        fi

        # Parse response with error handling
        ai_text=$(echo "$response" | jq -r '.choices[0].message.content' 2>/dev/null)
        local jq_exit_code=$?

        if [[ $jq_exit_code -eq 0 && -n "$ai_text" && "$ai_text" != "null" ]]; then
            spinner_stop "ok" "Analysis complete via $model"
            success=1
            break
        else
            # Try to extract error message
            local err_msg
            err_msg=$(echo "$response" | jq -r '.error.message // .error // .message // "Unknown error"' 2>/dev/null)
            if [[ -z "$err_msg" || "$err_msg" == "null" ]]; then
                err_msg="Invalid or Unauthorized response"
            fi
            
            # Log detailed error information
            log_warn "AI Provider $model failed: $err_msg"
            log_debug "Full response: $response"
            
            spinner_stop "fail" "Model $model failed: $err_msg"
            
            # Check for rate limiting
            if echo "$response" | grep -qi "rate.limit\|too many requests\|429"; then
                msg_warn "Rate limit reached. Waiting 5 seconds before next attempt..."
                sleep 5
            fi
        fi
    done

    # Fallback to local AI if all online providers failed
    if [[ $success -eq 0 ]]; then
        msg_warn "All Online AI models failed. Switching to Local AI (Ollama)..."
        
        # Check if Ollama is available
        if ! command -v ollama &>/dev/null; then
            msg_info "Ollama not found. Attempting to install..."
            if ! setup_ollama; then
                msg_fail "Ollama installation failed. Please install manually: curl -fsSL https://ollama.com/install.sh | sh"
                ai_text="${MR_RED}Analysis Failed:${MR_NC} All online models failed and Ollama is not available."
            else
                msg_ok "Ollama installed successfully"
            fi
        fi
        
        # Try local AI
        if command -v ollama &>/dev/null; then
            spinner_start "Consulting Local AI (Ollama)..." "braille"
            
            # Check if service is running
            if ! pgrep -x "ollama" >/dev/null; then
                msg_info "Starting Ollama service..."
                sudo systemctl start ollama 2>/dev/null || ollama serve & 2>/dev/null &
                sleep 3
            fi
            
            # Check for available models
            local models
            models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | head -1)
            
            if [[ -z "$models" ]]; then
                msg_info "No models found. Downloading lightweight model (llama3.2)..."
                if ! ollama pull llama3.2 >/dev/null 2>&1; then
                    spinner_stop "fail" "Failed to download model"
                    msg_fail "Local AI model download failed"
                    ai_text="${MR_RED}Analysis Failed:${MR_NC} All online models failed and local model download failed."
                else
                    spinner_stop "ok" "Model downloaded successfully"
                    models="llama3.2"
                fi
            else
                spinner_stop "ok" "Using local model: $models"
            fi
            
            # Make local AI request
            if [[ -n "$models" ]]; then
                local local_prompt="System: $system_prompt\nUser: $content"
                # Use ollama directly since call_ollama_api function is not defined
                ai_text=$(echo "$local_prompt" | ollama run "$models" 2>/dev/null)
                
                if [[ -z "$ai_text" || "$ai_text" == "null" || "$ai_text" == "" ]]; then
                    spinner_stop "fail" "Local AI also failed"
                    msg_fail "All AI models and keys exhausted. Please check your internet or API limits."
                    ai_text="${MR_RED}Analysis Failed:${MR_NC} All online models and local Ollama fallback failed to analyze the log data."
                else
                    spinner_stop "ok" "Analysis complete via Local AI ($models)"
                    success=1
                fi
            fi
        else
            msg_fail "All online models failed and Ollama is not available."
            ai_text="${MR_RED}Analysis Failed:${MR_NC} Online models failed and Ollama is not configured."
        fi
    fi
    
    # Display results
    echo ""
    dashboard_header "SYSTEM INFO"
    dashboard_row "Hostname:" "$(hostname 2>/dev/null || echo unknown)"
    dashboard_row "Distribution:" "$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo Linux)"
    dashboard_row "Kernel:" "$(uname -r 2>/dev/null || echo unknown)"
    dashboard_footer
    echo ""

    dashboard_header "RESOURCE USAGE"
    dashboard_bar "CPU" "$(get_cpu_usage 2>/dev/null || echo 0)" "$(get_cpu_usage 2>/dev/null || echo 0)% load"
    dashboard_bar "Memory" "$(get_mem_usage 2>/dev/null || echo 0)" "$(free -h 2>/dev/null | awk '/Mem:/ {print $3" / "$2}' || echo 'N/A')"
    dashboard_bar "Disk" "$(get_disk_usage 2>/dev/null || echo 0)" "$(df -h / 2>/dev/null | awk 'NR==2 {print $3" / "$2}' || echo 'N/A')"
    dashboard_footer
    echo ""

    dashboard_header "AI DEEP ANALYSIS RESULTS" "$MR_SKY"
    if [[ $success -eq 1 ]]; then
        # Format AI output for better CLI readability
        echo -e "${MR_WHITE}"
        
        # Process each line with enhanced formatting - prevent TL;DR output
        echo "$ai_text" | while IFS= read -r line; do
            # Skip empty lines at the beginning
            [[ -z "$line" && -z "${prev_line:-}" ]] && continue
            
            # Skip TL;DR sections to prevent long output
            if [[ "$line" =~ ^TL\;DR ]] || [[ "$line" =~ ^\|.*Category.*\|.*Symptom ]]; then
                continue
            fi
            
            # Skip table headers that cause long output
            if [[ "$line" =~ ^\|.*Category.*\| ]] || [[ "$line" =~ ^\|.*Symptom.*\| ]]; then
                continue
            fi
            
            # Replace MR-LINMACHNIC with MR-LINMACHANIC in output
            line="${line//MR-LINMACHNIC/MR-LINMACHANIC}"
            
            # Format main headers (##)
            if [[ "$line" =~ ^##[[:space:]]+(.*) ]]; then
                local header_text="${BASH_REMATCH[1]}"
                echo -e ""
                echo -e "  ${MR_CYAN}${MR_BOLD}📋 ${header_text}${MR_NC}"
                echo -e "  ${MR_DIM}$(printf '─%.0s' $(seq 1 ${#header_text}))${MR_NC}"
                
            # Format sub-headers (###)
            elif [[ "$line" =~ ^###[[:space:]]+(.*) ]]; then
                local sub_header="${BASH_REMATCH[1]}"
                echo -e "  ${MR_BLUE}${MR_BOLD}▶ ${sub_header}${MR_NC}"
                
            # Format bold text
            elif [[ "$line" =~ ^\*\*(.*)\*\* ]]; then
                local bold_text="${BASH_REMATCH[1]}"
                echo -e "  ${MR_YELLOW}${MR_BOLD}⚠️  ${bold_text}${MR_NC}"
                
            # Format tables
            elif [[ "$line" =~ ^\|[[:space:]] ]]; then
                echo -e "  ${MR_DIM}${line}${MR_NC}"
                
            # Format bullet points
            elif [[ "$line" =~ ^[[:space:]]*[-*][[:space:]]+(.*) ]]; then
                local bullet_text="${BASH_REMATCH[1]}"
                echo -e "  ${MR_GREEN}  • ${bullet_text}${MR_NC}"
                
            # Format numbered lists
            elif [[ "$line" =~ ^[[:space:]]*([0-9]+)\)[[:space:]]+(.*) ]]; then
                local num="${BASH_REMATCH[1]}"
                local list_text="${BASH_REMATCH[2]}"
                echo -e "  ${MR_TEAL}  ${num}) ${list_text}${MR_NC}"
                
            # Format code blocks or commands
            elif [[ "$line" =~ ^\`\`\` ]]; then
                echo -e "  ${MR_GRAY}$(printf '─%.0s' $(seq 1 50))${MR_NC}"
                
            # Format regular text with proper indentation
            elif [[ -n "$line" ]]; then
                echo -e "    ${MR_WHITE}${line}${MR_NC}"
            fi
            
            prev_line="$line"
        done
        
        # Add spacing after analysis
        echo -e ""
        echo -e "  ${MR_DIM}$(printf '─%.0s' $(seq 1 50))${MR_NC}"
        echo -e "  ${MR_DIM}💡 Analysis complete. Review recommendations above.${MR_NC}"
        
    else
        echo -e "${MR_RED}$ai_text${MR_NC}"
    fi
    dashboard_footer "$MR_SKY"
    
    echo ""
    local health_score
    health_score=$(calc_health_score)
    dashboard_header "OVERALL HEALTH POST-ANALYSIS"
    dashboard_bar "Overall" "$health_score" ""
    dashboard_footer
    echo ""
}

online_ai_deep_analysis() {
    local logs="${1:-}"
    
    if [[ -z "$logs" ]]; then
        clear
        show_main_banner
        dashboard_header "ONLINE AI DEEP ANALYSIS" "$MR_CORAL"
        echo ""
        echo -e "  ${MR_WHITE}Choose log source for Cloud AI analysis:${MR_NC}"
        echo ""
        echo -e "  ${MR_GREEN}1.${MR_NC}  ${MR_WHITE}System Logs${MR_NC}          ${MR_DIM}(journalctl)${MR_NC}"
        echo -e "  ${MR_GREEN}2.${MR_NC}  ${MR_WHITE}Kernel Messages${MR_NC}      ${MR_DIM}(dmesg)${MR_NC}"
        echo -e "  ${MR_GREEN}3.${MR_NC}  ${MR_WHITE}Full Multi-Source${MR_NC}    ${MR_DIM}(Recommended)${MR_NC}"
        echo ""
        echo -ne "  ${MR_CYAN}❯${MR_NC} Select: "
        read -r log_choice
        
        case $log_choice in
            1) logs=$(journalctl -b -p warning --no-pager -n 500 2>/dev/null) ;;
            2) logs=$(dmesg 2>/dev/null | tail -500) ;;
            3)
                spinner_start "Aggregating system telemetry..."
                logs=$(journalctl -b -p warning --no-pager -n 200 2>/dev/null)
                logs+=$'\n'$(dmesg 2>/dev/null | tail -200)
                spinner_stop "ok" "Cloud analysis staging complete"
                ;;
            *) return ;;
        esac
    fi

    if [[ -z "$logs" ]]; then
        msg_fail "No log data collected to analyze."
        echo -ne "  ${MR_DIM}Press Enter...${MR_NC}"; read -r
        return
    fi

    call_ai_api "$logs"
    
    echo -ne "  ${MR_DIM}Press Enter to continue...${MR_NC}"; read -r
}

# Allow direct execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_ai_mode
fi
