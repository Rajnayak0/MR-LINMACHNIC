#!/bin/bash
#==============================================================================
#  MR-LINMACHNIC - UI Library
#  Beautiful terminal interface components
#  Author: Madan Raj
#==============================================================================

# ── Color Palette ──
export MR_BLACK='\033[0;30m'
export MR_RED='\033[0;31m'
export MR_GREEN='\033[0;32m'
export MR_YELLOW='\033[1;33m'
export MR_BLUE='\033[0;34m'
export MR_MAGENTA='\033[0;35m'
export MR_CYAN='\033[0;36m'
export MR_WHITE='\033[1;37m'
export MR_GRAY='\033[0;37m'

# ── Style Modifiers ──
export MR_BOLD='\033[1m'
export MR_DIM='\033[2m'
export MR_ITALIC='\033[3m'
export MR_UNDERLINE='\033[4m'
export MR_BLINK='\033[5m'
export MR_REVERSE='\033[7m'
export MR_NC='\033[0m'

# ── Background Colors ──
export MR_BG_RED='\033[41m'
export MR_BG_GREEN='\033[42m'
export MR_BG_YELLOW='\033[43m'
export MR_BG_BLUE='\033[44m'
export MR_BG_MAGENTA='\033[45m'
export MR_BG_CYAN='\033[46m'
export MR_BG_WHITE='\033[47m'

# ── Accent Colors (256-color) ──
export MR_ORANGE='\033[38;5;208m'
export MR_PINK='\033[38;5;205m'
export MR_LIME='\033[38;5;118m'
export MR_SKY='\033[38;5;117m'
export MR_GOLD='\033[38;5;220m'
export MR_CORAL='\033[38;5;209m'
export MR_VIOLET='\033[38;5;141m'
export MR_TEAL='\033[38;5;43m'

# Version
export MR_VERSION="1.0.0"
export MR_CODENAME="Genesis"

# ── Get terminal width ──
get_term_width() {
    local width
    width=$(tput cols 2>/dev/null || echo 80)
    echo "$width"
}

# ── Center text ──
center_text() {
    local text="$1"
    local width
    width=$(get_term_width)
    local text_len=${#text}
    local padding=$(( (width - text_len) / 2 ))
    printf "%*s%s\n" "$padding" "" "$text"
}

# ── Print horizontal rule ──
hr() {
    local char="${1:-━}"
    local color="${2:-$MR_DIM}"
    local width
    width=$(get_term_width)
    echo -e "${color}$(printf '%*s' "$width" '' | tr ' ' "$char")${MR_NC}"
}

# ── Box drawing ──
draw_box() {
    local title="$1"
    local color="${2:-$MR_CYAN}"
    local width
    width=$(get_term_width)
    local inner=$((width - 4))
    
    echo -e "${color}  ╔$(printf '═%.0s' $(seq 1 $inner))╗${MR_NC}"
    if [[ -n "$title" ]]; then
        local padding=$(( (inner - ${#title}) / 2 ))
        echo -e "${color}  ║$(printf ' %.0s' $(seq 1 $padding))${MR_WHITE}${MR_BOLD}${title}${MR_NC}${color}$(printf ' %.0s' $(seq 1 $((inner - padding - ${#title}))))║${MR_NC}"
    fi
    echo -e "${color}  ╚$(printf '═%.0s' $(seq 1 $inner))╝${MR_NC}"
}

# ── Section header ──
section_header() {
    local title="$1"
    local icon="${2:-🔧}"
    echo ""
    echo -e "  ${MR_CYAN}${MR_BOLD}$icon $title${MR_NC}"
    echo -e "  ${MR_DIM}$(printf '─%.0s' $(seq 1 ${#title}))───${MR_NC}"
    echo ""
}

# ── Status messages ──
msg_ok() {
    echo -e "  ${MR_GREEN}[${MR_BOLD}✓${MR_NC}${MR_GREEN}]${MR_NC} ${MR_WHITE}$1${MR_NC}"
}

msg_fail() {
    echo -e "  ${MR_RED}[${MR_BOLD}✗${MR_NC}${MR_RED}]${MR_NC} ${MR_RED}$1${MR_NC}"
}

msg_warn() {
    echo -e "  ${MR_YELLOW}[${MR_BOLD}⚠${MR_NC}${MR_YELLOW}]${MR_NC} ${MR_YELLOW}$1${MR_NC}"
}

msg_info() {
    echo -e "  ${MR_BLUE}[${MR_BOLD}ℹ${MR_NC}${MR_BLUE}]${MR_NC} ${MR_DIM}$1${MR_NC}"
}

msg_action() {
    echo -e "  ${MR_MAGENTA}[${MR_BOLD}▶${MR_NC}${MR_MAGENTA}]${MR_NC} ${MR_WHITE}$1${MR_NC}"
}

msg_fix() {
    echo -e "  ${MR_TEAL}[${MR_BOLD}🔧${MR_NC}${MR_TEAL}]${MR_NC} ${MR_WHITE}$1${MR_NC}"
}

# ── Animated spinner ──
spinner_start() {
    local msg="$1"
    local spin_chars='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    
    (
        local i=0
        while true; do
            i=$(( (i + 1) % ${#spin_chars} ))
            printf "\r  ${MR_CYAN}[${spin_chars:$i:1}]${MR_NC} ${MR_DIM}%s${MR_NC}" "$msg"
            sleep 0.08
        done
    ) &
    SPINNER_PID=$!
    disown $SPINNER_PID 2>/dev/null
}

spinner_stop() {
    local status="$1"  # ok, fail, warn
    local msg="$2"
    
    if [[ -n "$SPINNER_PID" ]]; then
        kill "$SPINNER_PID" 2>/dev/null
        wait "$SPINNER_PID" 2>/dev/null
        unset SPINNER_PID
    fi
    
    printf "\r"
    case "$status" in
        ok)   msg_ok "$msg" ;;
        fail) msg_fail "$msg" ;;
        warn) msg_warn "$msg" ;;
        *)    msg_info "$msg" ;;
    esac
}

# ── Progress bar ──
progress_bar() {
    local current="$1"
    local total="$2"
    local label="${3:-Progress}"
    local width=40
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    
    # Color based on percentage
    local color
    if [[ $percent -lt 30 ]]; then
        color="$MR_RED"
    elif [[ $percent -lt 70 ]]; then
        color="$MR_YELLOW"
    else
        color="$MR_GREEN"
    fi
    
    printf "\r  ${MR_DIM}%s${MR_NC} ${color}%s${MR_NC} ${MR_WHITE}%3d%%${MR_NC}" "$label" "$bar" "$percent"
}

# ── Interactive menu ──
show_menu() {
    local title="$1"
    shift
    local options=("$@")
    local selected=0
    local total=${#options[@]}
    
    # Hide cursor
    tput civis 2>/dev/null
    
    while true; do
        # Clear menu area
        for ((i=0; i<=total+2; i++)); do
            tput cuu1 2>/dev/null
            tput el 2>/dev/null
        done
        
        echo ""
        echo -e "  ${MR_CYAN}${MR_BOLD}$title${MR_NC}"
        echo ""
        
        for ((i=0; i<total; i++)); do
            if [[ $i -eq $selected ]]; then
                echo -e "  ${MR_BG_CYAN}${MR_BLACK} ▸ ${options[$i]} ${MR_NC}"
            else
                echo -e "  ${MR_DIM}   ${options[$i]}${MR_NC}"
            fi
        done
        
        # Read key
        read -rsn1 key
        case "$key" in
            A) # Up arrow
                ((selected--))
                [[ $selected -lt 0 ]] && selected=$((total - 1))
                ;;
            B) # Down arrow
                ((selected++))
                [[ $selected -ge $total ]] && selected=0
                ;;
            '') # Enter
                tput cnorm 2>/dev/null
                return $selected
                ;;
        esac
    done
}

# ── Prompt with style ──
styled_prompt() {
    local prompt_text="$1"
    local default="${2:-}"
    
    if [[ -n "$default" ]]; then
        echo -ne "  ${MR_CYAN}❯${MR_NC} ${MR_WHITE}$prompt_text${MR_NC} ${MR_DIM}[$default]${MR_NC}: "
    else
        echo -ne "  ${MR_CYAN}❯${MR_NC} ${MR_WHITE}$prompt_text${MR_NC}: "
    fi
    read -r REPLY
    [[ -z "$REPLY" && -n "$default" ]] && REPLY="$default"
}

# ── Yes/No prompt ──
confirm_action() {
    local msg="$1"
    local default="${2:-n}"
    
    if [[ "$default" == "y" ]]; then
        echo -ne "  ${MR_YELLOW}❯${MR_NC} ${MR_WHITE}$msg${MR_NC} ${MR_DIM}[Y/n]${MR_NC}: "
    else
        echo -ne "  ${MR_YELLOW}❯${MR_NC} ${MR_WHITE}$msg${MR_NC} ${MR_DIM}[y/N]${MR_NC}: "
    fi
    read -rn1 yn
    echo ""
    
    case "$yn" in
        [Yy]) return 0 ;;
        [Nn]) return 1 ;;
        '')
            [[ "$default" == "y" ]] && return 0 || return 1
            ;;
        *) return 1 ;;
    esac
}

# ── Print key-value pair ──
kv_print() {
    local key="$1"
    local value="$2"
    local status="${3:-}"  # ok, warn, fail, or empty
    
    local status_icon=""
    case "$status" in
        ok)   status_icon="${MR_GREEN}●${MR_NC}" ;;
        warn) status_icon="${MR_YELLOW}●${MR_NC}" ;;
        fail) status_icon="${MR_RED}●${MR_NC}" ;;
    esac
    
    printf "  ${MR_DIM}%-20s${MR_NC} ${MR_WHITE}%s${MR_NC} %b\n" "$key" "$value" "$status_icon"
}

# ── Animated text ──
typewriter() {
    local text="$1"
    local delay="${2:-0.02}"
    
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep "$delay"
    done
    echo ""
}

# ── System notification sound (bell) ──
alert_bell() {
    echo -ne '\a'
}

# ── Countdown timer ──
countdown() {
    local seconds="$1"
    local msg="${2:-Continuing in}"
    
    for ((i=seconds; i>0; i--)); do
        printf "\r  ${MR_DIM}%s %d...${MR_NC}" "$msg" "$i"
        sleep 1
    done
    printf "\r%*s\r" 60 ""
}

# ── Print a table row ──
table_row() {
    local col1="$1"
    local col2="$2"
    local col3="${3:-}"
    
    if [[ -n "$col3" ]]; then
        printf "  ${MR_DIM}│${MR_NC} ${MR_WHITE}%-15s${MR_NC} ${MR_DIM}│${MR_NC} %-25s ${MR_DIM}│${MR_NC} %-30s ${MR_DIM}│${MR_NC}\n" "$col1" "$col2" "$col3"
    else
        printf "  ${MR_DIM}│${MR_NC} ${MR_WHITE}%-15s${MR_NC} ${MR_DIM}│${MR_NC} %-30s ${MR_DIM}│${MR_NC}\n" "$col1" "$col2"
    fi
}

# ── Table separator ──
table_sep() {
    local style="${1:-single}"
    if [[ "$style" == "double" ]]; then
        echo -e "  ${MR_DIM}╠═══════════════════╪════════════════════════════════╣${MR_NC}"
    else
        echo -e "  ${MR_DIM}├───────────────────┼────────────────────────────────┤${MR_NC}"
    fi
}

# ── Health bar (visual) ──
health_bar() {
    local label="$1"
    local value="$2"  # 0-100
    local width=20
    
    local filled=$((value * width / 100))
    local empty=$((width - filled))
    
    local color
    if [[ $value -ge 80 ]]; then
        color="$MR_GREEN"
    elif [[ $value -ge 50 ]]; then
        color="$MR_YELLOW"
    elif [[ $value -ge 25 ]]; then
        color="$MR_ORANGE"
    else
        color="$MR_RED"
    fi
    
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="▓"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    
    printf "  %-14s ${color}%s${MR_NC} ${MR_WHITE}%3d%%${MR_NC}\n" "$label" "$bar" "$value"
}

# ── Main banner ──
show_main_banner() {
    clear
    
    echo -e "${MR_CYAN}"
    echo ""
    echo '    ╔══════════════════════════════════════════════════════════════════╗'
    echo '    ║                                                                  ║'
    echo '    ║    ███╗   ███╗██████╗                                            ║'
    echo '    ║    ████╗ ████║██╔══██╗       ╦  ╦╔╗╔╔╦╗╔═╗╔═╗╦ ╦╔╗╔╦╔═╗       ║'
    echo '    ║    ██╔████╔██║██████╔╝       ║  ║║║║║║║╠═╣║  ╠═╣║║║║║  ║       ║'
    echo '    ║    ██║╚██╔╝██║██╔══██╗       ╩═╝╩╝╚╝╩ ╩╩ ╩╚═╝╩ ╩╝╚╝╩╚═╝      ║'
    echo '    ║    ██║ ╚═╝ ██║██║  ██║                                           ║'
    echo '    ║    ╚═╝     ╚═╝╚═╝  ╚═╝                                          ║'
    echo '    ║                                                                  ║'
    echo -e "    ║    ${MR_WHITE}${MR_BOLD}🛠️  The Machine That Repairs Linux${MR_NC}${MR_CYAN}                          ║"
    echo -e "    ║    ${MR_DIM}Version ${MR_VERSION} (${MR_CODENAME})${MR_NC}${MR_CYAN}                                   ║"
    echo -e "    ║    ${MR_DIM}Author: Madan Raj${MR_NC}${MR_CYAN}                                            ║"
    echo '    ║                                                                  ║'
    echo '    ╚══════════════════════════════════════════════════════════════════╝'
    echo -e "${MR_NC}"
    echo ""
}
