#!/bin/bash
#==============================================================================
#  MR-LINMACHNIC - System Utilities Library
#  Core system detection and utility functions
#  Author: Madan Raj
#==============================================================================

# ── Directories ──
MR_BASE_DIR="${MR_BASE_DIR:-/opt/mr-linmachnic}"
MR_LOG_DIR="$MR_BASE_DIR/logs"
MR_DATA_DIR="$MR_BASE_DIR/data"

# ── Log file ──
MR_LOG_FILE="$MR_LOG_DIR/mr-machine-$(date +%Y%m%d).log"

# ── Ensure log directory exists ──
mkdir -p "$MR_LOG_DIR" 2>/dev/null

# ── Logging ──
log_msg() {
    local level="$1"
    local msg="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $msg" >> "$MR_LOG_FILE" 2>/dev/null
}

log_info()  { log_msg "INFO" "$1"; }
log_warn()  { log_msg "WARN" "$1"; }
log_error() { log_msg "ERROR" "$1"; }
log_debug() { log_msg "DEBUG" "$1"; }

# ── Check if running as root ──
is_root() {
    [[ $EUID -eq 0 ]]
}

# ── Require root ──
require_root() {
    if ! is_root; then
        msg_warn "This action requires root privileges."
        msg_info "Please run: sudo mr-machine"
        return 1
    fi
    return 0
}

# ── Detect Linux distribution ──
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    elif command -v lsb_release &>/dev/null; then
        lsb_release -si | tr '[:upper:]' '[:lower:]'
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    elif [[ -f /etc/redhat-release ]]; then
        echo "rhel"
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    else
        echo "unknown"
    fi
}

# ── Get distro full name ──
get_distro_name() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$PRETTY_NAME"
    else
        echo "Unknown Linux"
    fi
}

# ── Detect package manager ──
detect_pkg_manager() {
    if command -v apt &>/dev/null; then
        echo "apt"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v yum &>/dev/null; then
        echo "yum"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v zypper &>/dev/null; then
        echo "zypper"
    elif command -v apk &>/dev/null; then
        echo "apk"
    else
        echo "unknown"
    fi
}

# ── Check if a command exists ──
cmd_exists() {
    command -v "$1" &>/dev/null
}

# ── Get CPU usage percentage ──
get_cpu_usage() {
    if cmd_exists mpstat; then
        mpstat 1 1 2>/dev/null | awk '/Average:/ {printf "%.0f", 100 - $NF}'
    elif [[ -f /proc/stat ]]; then
        local cpu_line
        cpu_line=$(head -1 /proc/stat)
        local user nice system idle iowait
        read -r _ user nice system idle iowait _ <<< "$cpu_line"
        local total=$((user + nice + system + idle + iowait))
        local active=$((total - idle))
        if [[ $total -gt 0 ]]; then
            echo $((active * 100 / total))
        else
            echo "0"
        fi
    else
        echo "N/A"
    fi
}

# ── Get memory usage ──
get_mem_usage() {
    if cmd_exists free; then
        free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}'
    else
        echo "N/A"
    fi
}

# ── Get total/used/free memory ──
get_mem_info() {
    if cmd_exists free; then
        free -h | awk '/Mem:/ {print $2, $3, $4}'
    else
        echo "N/A N/A N/A"
    fi
}

# ── Get disk usage of root ──
get_disk_usage() {
    df / 2>/dev/null | awk 'NR==2 {gsub(/%/,""); print $5}'
}

# ── Get disk info ──
get_disk_info() {
    df -h / 2>/dev/null | awk 'NR==2 {print $2, $3, $4, $5}'
}

# ── Get uptime ──
get_uptime() {
    uptime -p 2>/dev/null || uptime 2>/dev/null | awk -F'up' '{print $2}' | awk -F',' '{print $1}'
}

# ── Get kernel version ──
get_kernel() {
    uname -r
}

# ── Get hostname ──
get_hostname() {
    hostname 2>/dev/null || cat /etc/hostname 2>/dev/null || echo "unknown"
}

# ── Get number of running processes ──
get_process_count() {
    ps aux 2>/dev/null | wc -l
}

# ── Get number of failed systemd services ──
get_failed_services() {
    if cmd_exists systemctl; then
        systemctl --failed --no-legend 2>/dev/null | wc -l
    else
        echo "N/A"
    fi
}

# ── Get failed service names ──
get_failed_service_names() {
    if cmd_exists systemctl; then
        systemctl --failed --no-legend 2>/dev/null | awk '{print $1}'
    fi
}

# ── Get system load ──
get_load_avg() {
    cat /proc/loadavg 2>/dev/null | awk '{print $1, $2, $3}'
}

# ── Get network interfaces ──
get_network_interfaces() {
    if cmd_exists ip; then
        ip -o link show 2>/dev/null | awk -F': ' '{print $2}'
    elif cmd_exists ifconfig; then
        ifconfig -a 2>/dev/null | grep -oP '^[a-z0-9]+' | sort -u
    fi
}

# ── Check internet connectivity ──
check_internet() {
    if ping -c 1 -W 3 8.8.8.8 &>/dev/null; then
        return 0
    elif ping -c 1 -W 3 1.1.1.1 &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# ── Check DNS resolution ──
check_dns() {
    if host google.com &>/dev/null 2>&1; then
        return 0
    elif nslookup google.com &>/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# ── Get recent system errors ──
get_recent_errors() {
    local count="${1:-10}"
    if cmd_exists journalctl; then
        journalctl -p err -n "$count" --no-pager 2>/dev/null
    elif [[ -f /var/log/syslog ]]; then
        grep -i "error\|fail\|critical" /var/log/syslog 2>/dev/null | tail -n "$count"
    fi
}

# ── Get recent boot errors ──
get_boot_errors() {
    if cmd_exists journalctl; then
        journalctl -b -p err --no-pager 2>/dev/null | head -20
    elif [[ -f /var/log/boot.log ]]; then
        grep -i "error\|fail" /var/log/boot.log 2>/dev/null | head -20
    fi
}

# ── Safe command execution ──
safe_exec() {
    local cmd="$1"
    local description="$2"
    
    log_info "Executing: $cmd ($description)"
    
    local output
    output=$(eval "$cmd" 2>&1)
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        log_info "Success: $description"
    else
        log_error "Failed: $description (exit code: $exit_code)"
        log_error "Output: $output"
    fi
    
    echo "$output"
    return $exit_code
}

# ── Calculate system health score ──
calc_health_score() {
    local score=100
    
    # CPU impact
    local cpu
    cpu=$(get_cpu_usage)
    if [[ "$cpu" != "N/A" && "$cpu" -gt 90 ]]; then
        score=$((score - 25))
    elif [[ "$cpu" != "N/A" && "$cpu" -gt 70 ]]; then
        score=$((score - 10))
    fi
    
    # Memory impact
    local mem
    mem=$(get_mem_usage)
    if [[ "$mem" != "N/A" && "$mem" -gt 90 ]]; then
        score=$((score - 25))
    elif [[ "$mem" != "N/A" && "$mem" -gt 70 ]]; then
        score=$((score - 10))
    fi
    
    # Disk impact
    local disk
    disk=$(get_disk_usage)
    if [[ -n "$disk" && "$disk" -gt 95 ]]; then
        score=$((score - 30))
    elif [[ -n "$disk" && "$disk" -gt 85 ]]; then
        score=$((score - 15))
    elif [[ -n "$disk" && "$disk" -gt 70 ]]; then
        score=$((score - 5))
    fi
    
    # Failed services impact
    local failed
    failed=$(get_failed_services)
    if [[ "$failed" != "N/A" && "$failed" -gt 0 ]]; then
        score=$((score - failed * 5))
    fi
    
    # Ensure score is 0-100
    [[ $score -lt 0 ]] && score=0
    [[ $score -gt 100 ]] && score=100
    
    echo "$score"
}

# ── Format bytes to human readable ──
human_readable() {
    local bytes="$1"
    if [[ $bytes -ge 1073741824 ]]; then
        echo "$(echo "scale=1; $bytes/1073741824" | bc)G"
    elif [[ $bytes -ge 1048576 ]]; then
        echo "$(echo "scale=1; $bytes/1048576" | bc)M"
    elif [[ $bytes -ge 1024 ]]; then
        echo "$(echo "scale=1; $bytes/1024" | bc)K"
    else
        echo "${bytes}B"
    fi
}

# ── Timestamp ──
timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}
