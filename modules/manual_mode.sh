#!/bin/bash
#==============================================================================
#  MR-LINMACHNIC - Manual Mode (Offline Interactive Troubleshooting)
#  Author: Madan Raj
#==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/ui.sh"
source "$SCRIPT_DIR/lib/utils.sh"

show_manual_menu() {
    while true; do
        clear
        echo -e "${MR_CYAN}"
        echo '    ╔══════════════════════════════════════════════════╗'
        echo '    ║   📖  MANUAL TROUBLESHOOTING MODE (Offline)     ║'
        echo '    ║   Select a category to troubleshoot             ║'
        echo '    ╚══════════════════════════════════════════════════╝'
        echo -e "${MR_NC}"
        echo ""
        echo -e "  ${MR_WHITE}${MR_BOLD}CATEGORY${MR_NC}                          ${MR_DIM}DESCRIPTION${MR_NC}"
        echo -e "  ${MR_DIM}────────────────────────────────────────────────────${MR_NC}"
        echo -e "  ${MR_GREEN}1.${MR_NC}  🖥️  ${MR_WHITE}System & Boot${MR_NC}              ${MR_DIM}Boot failures, kernel panic, GRUB${MR_NC}"
        echo -e "  ${MR_GREEN}2.${MR_NC}  💾  ${MR_WHITE}Storage & Disk${MR_NC}             ${MR_DIM}Disk full, filesystem, RAID${MR_NC}"
        echo -e "  ${MR_GREEN}3.${MR_NC}  🌐  ${MR_WHITE}Network & Internet${MR_NC}         ${MR_DIM}DNS, WiFi, no internet${MR_NC}"
        echo -e "  ${MR_GREEN}4.${MR_NC}  🔧  ${MR_WHITE}Hardware & Drivers${MR_NC}         ${MR_DIM}GPU, audio, USB, Bluetooth${MR_NC}"
        echo -e "  ${MR_GREEN}5.${MR_NC}  📦  ${MR_WHITE}Software & Packages${MR_NC}        ${MR_DIM}Package errors, dependencies${MR_NC}"
        echo -e "  ${MR_GREEN}6.${MR_NC}  ⚙️   ${MR_WHITE}Services & Daemons${MR_NC}        ${MR_DIM}systemd, cron, daemon crashes${MR_NC}"
        echo -e "  ${MR_GREEN}7.${MR_NC}  🔒  ${MR_WHITE}Security & Permissions${MR_NC}     ${MR_DIM}SSH, firewall, file permissions${MR_NC}"
        echo -e "  ${MR_GREEN}8.${MR_NC}  🐧  ${MR_WHITE}A-Z Linux Problems${MR_NC}         ${MR_DIM}Alphabetical issue guide${MR_NC}"
        echo ""
        echo -e "  ${MR_RED}0.${MR_NC}  ← Back to Main Menu"
        echo ""
        echo -ne "  ${MR_CYAN}❯${MR_NC} Select option: "
        read -r choice
        
        case $choice in
            1) troubleshoot_system ;;
            2) troubleshoot_storage ;;
            3) troubleshoot_network ;;
            4) troubleshoot_hardware ;;
            5) troubleshoot_software ;;
            6) troubleshoot_services ;;
            7) troubleshoot_security ;;
            8) troubleshoot_az ;;
            0) return ;;
            *) msg_warn "Invalid option"; sleep 1 ;;
        esac
    done
}

troubleshoot_system() {
    while true; do
        clear
        section_header "System & Boot Troubleshooting" "🖥️"
        echo -e "  ${MR_GREEN}1.${MR_NC}  GRUB bootloader not found / rescue mode"
        echo -e "  ${MR_GREEN}2.${MR_NC}  Kernel panic on boot"
        echo -e "  ${MR_GREEN}3.${MR_NC}  initramfs / initrd errors"
        echo -e "  ${MR_GREEN}4.${MR_NC}  System freeze / hang"
        echo -e "  ${MR_GREEN}5.${MR_NC}  Black screen after boot"
        echo -e "  ${MR_GREEN}6.${MR_NC}  Emergency mode / rescue mode"
        echo -e "  ${MR_GREEN}7.${MR_NC}  Slow boot"
        echo -e "  ${MR_RED}0.${MR_NC}  ← Back"
        echo ""
        echo -ne "  ${MR_CYAN}❯${MR_NC} Select: "
        read -r choice
        case $choice in
            1) show_solution "GRUB Bootloader Recovery" \
                "1. Boot from Live USB" \
                "2. Mount your root partition:" \
                "   sudo mount /dev/sdX1 /mnt" \
                "   sudo mount --bind /dev /mnt/dev" \
                "   sudo mount --bind /proc /mnt/proc" \
                "   sudo mount --bind /sys /mnt/sys" \
                "3. Chroot into the system:" \
                "   sudo chroot /mnt" \
                "4. Reinstall GRUB:" \
                "   grub-install /dev/sdX" \
                "   update-grub" \
                "5. Exit and reboot:" \
                "   exit && sudo reboot" ;;
            2) show_solution "Kernel Panic Fix" \
                "1. Boot with older kernel from GRUB menu" \
                "2. At GRUB, press 'e' to edit boot params" \
                "3. Add 'nomodeset' to kernel line" \
                "4. Boot and reinstall kernel:" \
                "   sudo apt install --reinstall linux-image-\$(uname -r)" \
                "5. Update GRUB: sudo update-grub" \
                "6. Reboot: sudo reboot" ;;
            3) show_solution "initramfs/initrd Recovery" \
                "1. Boot with older kernel from GRUB" \
                "2. Rebuild initramfs:" \
                "   sudo update-initramfs -u -k all" \
                "3. Or on RHEL/Fedora:" \
                "   sudo dracut --force" \
                "4. Update GRUB: sudo update-grub" \
                "5. Reboot" ;;
            4) show_solution "System Freeze Fix" \
                "1. Check system logs: journalctl -xe" \
                "2. Check dmesg for hardware errors: dmesg | tail -50" \
                "3. Check memory: sudo memtest86+" \
                "4. Check CPU temp: sensors (install lm-sensors)" \
                "5. Try: echo 1 > /proc/sys/kernel/sysrq" \
                "6. Magic SysRq: Alt+SysRq+REISUB (safe reboot)" ;;
            5) show_solution "Black Screen After Boot" \
                "1. At GRUB, add 'nomodeset' to kernel params" \
                "2. Switch to TTY: Ctrl+Alt+F2" \
                "3. Check GPU driver: lspci | grep VGA" \
                "4. Reinstall display manager:" \
                "   sudo apt install --reinstall gdm3  (or lightdm/sddm)" \
                "5. Reinstall GPU drivers if needed" \
                "6. Check Xorg log: cat /var/log/Xorg.0.log | grep EE" ;;
            6) show_solution "Emergency/Rescue Mode Fix" \
                "1. Check fstab for errors: cat /etc/fstab" \
                "2. Fix filesystem: sudo fsck -y /dev/sdX1" \
                "3. Remount root as rw: mount -o remount,rw /" \
                "4. Fix broken packages:" \
                "   apt --fix-broken install" \
                "5. Check systemd: systemctl --failed" \
                "6. Reboot: reboot" ;;
            7) show_solution "Slow Boot Diagnosis" \
                "1. Analyze boot time: systemd-analyze" \
                "2. Blame slow services: systemd-analyze blame" \
                "3. Plot boot chart: systemd-analyze plot > boot.svg" \
                "4. Disable slow services:" \
                "   sudo systemctl disable <service-name>" \
                "5. Check for disk errors: sudo smartctl -a /dev/sda" ;;
            0) return ;;
        esac
    done
}

troubleshoot_storage() {
    while true; do
        clear
        section_header "Storage & Disk Troubleshooting" "💾"
        echo -e "  ${MR_GREEN}1.${MR_NC}  Disk full (no space left)"
        echo -e "  ${MR_GREEN}2.${MR_NC}  Filesystem corruption"
        echo -e "  ${MR_GREEN}3.${MR_NC}  Disk not detected"
        echo -e "  ${MR_GREEN}4.${MR_NC}  Slow disk performance"
        echo -e "  ${MR_GREEN}5.${MR_NC}  Mount errors"
        echo -e "  ${MR_GREEN}6.${MR_NC}  RAID problems"
        echo -e "  ${MR_RED}0.${MR_NC}  ← Back"
        echo ""
        echo -ne "  ${MR_CYAN}❯${MR_NC} Select: "
        read -r choice
        case $choice in
            1) show_solution "Disk Full - Free Space" \
                "1. Check usage: df -h" \
                "2. Find large files: sudo du -sh /* | sort -rh | head -20" \
                "3. Clear journal logs:" \
                "   sudo journalctl --vacuum-time=3d" \
                "4. Clean package cache:" \
                "   sudo apt clean && sudo apt autoremove" \
                "5. Find old logs: sudo find /var/log -name '*.gz' -delete" \
                "6. Empty trash: rm -rf ~/.local/share/Trash/*" \
                "7. Clean /tmp: sudo rm -rf /tmp/*" ;;
            2) show_solution "Filesystem Corruption Fix" \
                "1. Unmount the partition first (boot from USB if root)" \
                "2. Run filesystem check:" \
                "   sudo fsck -y /dev/sdX1" \
                "3. For ext4: sudo e2fsck -f /dev/sdX1" \
                "4. For XFS: sudo xfs_repair /dev/sdX1" \
                "5. Check SMART data: sudo smartctl -a /dev/sda" \
                "6. Backup data if disk is failing!" ;;
            3) show_solution "Disk Not Detected" \
                "1. List all disks: lsblk -f" \
                "2. Check dmesg: dmesg | grep -i 'sd\|nvme\|sata'" \
                "3. Check if driver loaded: lsmod | grep ahci" \
                "4. Load SATA driver: sudo modprobe ahci" \
                "5. Check BIOS/UEFI settings for SATA mode" \
                "6. Check cables and connections" ;;
            4) show_solution "Slow Disk Performance" \
                "1. Check I/O: iostat -x 1 5" \
                "2. Check processes using disk: iotop" \
                "3. Check SMART health: sudo smartctl -H /dev/sda" \
                "4. Enable TRIM (SSD): sudo fstrim -v /" \
                "5. Check for filesystem errors: sudo fsck -n /dev/sdX1" \
                "6. Consider I/O scheduler change" ;;
            5) show_solution "Mount Errors Fix" \
                "1. Check fstab: cat /etc/fstab" \
                "2. Check UUID: blkid" \
                "3. Test mount manually: sudo mount /dev/sdX1 /mnt" \
                "4. Fix fstab UUID if changed" \
                "5. Regenerate fstab entry with correct UUID" ;;
            6) show_solution "RAID Problems" \
                "1. Check RAID status: cat /proc/mdstat" \
                "2. Detail RAID info: sudo mdadm --detail /dev/md0" \
                "3. Re-add failed disk:" \
                "   sudo mdadm --manage /dev/md0 --add /dev/sdX" \
                "4. Check for errors: sudo mdadm --examine /dev/sdX" ;;
            0) return ;;
        esac
    done
}

troubleshoot_network() {
    while true; do
        clear
        section_header "Network & Internet Troubleshooting" "🌐"
        echo -e "  ${MR_GREEN}1.${MR_NC}  No internet connection"
        echo -e "  ${MR_GREEN}2.${MR_NC}  DNS resolution failure"
        echo -e "  ${MR_GREEN}3.${MR_NC}  WiFi not working"
        echo -e "  ${MR_GREEN}4.${MR_NC}  Network adapter missing"
        echo -e "  ${MR_GREEN}5.${MR_NC}  Slow network speed"
        echo -e "  ${MR_GREEN}6.${MR_NC}  SSH connection issues"
        echo -e "  ${MR_GREEN}7.${MR_NC}  Firewall blocking connections"
        echo -e "  ${MR_RED}0.${MR_NC}  ← Back"
        echo ""
        echo -ne "  ${MR_CYAN}❯${MR_NC} Select: "
        read -r choice
        case $choice in
            1) show_solution "No Internet Fix" \
                "1. Check network interface: ip link show" \
                "2. Test connectivity: ping -c 3 8.8.8.8" \
                "3. Test DNS: ping -c 3 google.com" \
                "4. Restart NetworkManager:" \
                "   sudo systemctl restart NetworkManager" \
                "5. Release/renew DHCP:" \
                "   sudo dhclient -r && sudo dhclient" \
                "6. Check default route: ip route show" \
                "7. Check resolv.conf: cat /etc/resolv.conf" ;;
            2) show_solution "DNS Resolution Fix" \
                "1. Test DNS: nslookup google.com" \
                "2. Set Google DNS:" \
                "   echo 'nameserver 8.8.8.8' | sudo tee /etc/resolv.conf" \
                "   echo 'nameserver 8.8.4.4' | sudo tee -a /etc/resolv.conf" \
                "3. Flush DNS cache:" \
                "   sudo systemd-resolve --flush-caches" \
                "4. Restart resolved:" \
                "   sudo systemctl restart systemd-resolved" ;;
            3) show_solution "WiFi Fix" \
                "1. Check WiFi interface: iwconfig" \
                "2. Scan networks: sudo iwlist wlan0 scan | grep ESSID" \
                "3. Check rfkill: rfkill list" \
                "4. Unblock WiFi: sudo rfkill unblock wifi" \
                "5. Restart WiFi:" \
                "   sudo ip link set wlan0 down" \
                "   sudo ip link set wlan0 up" \
                "6. Connect: nmcli dev wifi connect SSID password PASS" ;;
            4) show_solution "Network Adapter Missing" \
                "1. List PCI devices: lspci | grep -i net" \
                "2. Check loaded modules: lsmod | grep -i 'e1000\|r8169\|iwl'" \
                "3. Check dmesg: dmesg | grep -i 'eth\|wlan\|net'" \
                "4. Load driver manually: sudo modprobe <driver-name>" \
                "5. Install firmware: sudo apt install linux-firmware" ;;
            5) show_solution "Slow Network Fix" \
                "1. Test speed: curl -o /dev/null http://speedtest.tele2.net/10MB.zip" \
                "2. Check for packet loss: ping -c 20 8.8.8.8" \
                "3. Check MTU: ip link show" \
                "4. Test with iperf3 to local server" \
                "5. Check for bandwidth hogs: iftop or nethogs" ;;
            6) show_solution "SSH Connection Fix" \
                "1. Check SSH service: sudo systemctl status sshd" \
                "2. Start SSH: sudo systemctl start sshd" \
                "3. Check firewall: sudo ufw status" \
                "4. Allow SSH: sudo ufw allow 22" \
                "5. Check config: cat /etc/ssh/sshd_config" \
                "6. Verbose connect: ssh -vvv user@host" ;;
            7) show_solution "Firewall Issues" \
                "1. Check UFW: sudo ufw status verbose" \
                "2. Check iptables: sudo iptables -L -n" \
                "3. Allow port: sudo ufw allow <port>" \
                "4. Disable firewall temporarily:" \
                "   sudo ufw disable" \
                "5. Reset rules: sudo ufw reset" ;;
            0) return ;;
        esac
    done
}

troubleshoot_hardware() {
    while true; do
        clear
        section_header "Hardware & Drivers Troubleshooting" "🔧"
        echo -e "  ${MR_GREEN}1.${MR_NC}  GPU / Display driver issues"
        echo -e "  ${MR_GREEN}2.${MR_NC}  Audio not working"
        echo -e "  ${MR_GREEN}3.${MR_NC}  USB device not detected"
        echo -e "  ${MR_GREEN}4.${MR_NC}  Bluetooth issues"
        echo -e "  ${MR_GREEN}5.${MR_NC}  Overheating / fan issues"
        echo -e "  ${MR_GREEN}6.${MR_NC}  Keyboard / mouse issues"
        echo -e "  ${MR_RED}0.${MR_NC}  ← Back"
        echo ""
        echo -ne "  ${MR_CYAN}❯${MR_NC} Select: "
        read -r choice
        case $choice in
            1) show_solution "GPU / Display Driver Fix" \
                "1. Identify GPU: lspci | grep VGA" \
                "2. Check current driver: lsmod | grep -i 'nvidia\|amd\|i915'" \
                "3. For NVIDIA:" \
                "   sudo apt install nvidia-driver-XXX" \
                "   sudo nvidia-xconfig" \
                "4. For AMD: sudo apt install firmware-amd-graphics" \
                "5. Boot with 'nomodeset' if screen is black" \
                "6. Check Xorg: cat /var/log/Xorg.0.log | grep EE" ;;
            2) show_solution "Audio Fix" \
                "1. Check PulseAudio: pulseaudio --check" \
                "2. Restart PulseAudio: pulseaudio -k && pulseaudio --start" \
                "3. Check ALSA: aplay -l" \
                "4. Unmute: alsamixer (press M to unmute)" \
                "5. Install PipeWire (modern replacement):" \
                "   sudo apt install pipewire pipewire-pulse" \
                "6. Check modules: lsmod | grep snd" ;;
            3) show_solution "USB Device Fix" \
                "1. List USB devices: lsusb" \
                "2. Check dmesg: dmesg | tail -20" \
                "3. Check power: cat /sys/bus/usb/devices/*/power/control" \
                "4. Reset USB: echo 0 > /sys/bus/usb/devices/X-Y/authorized" \
                "5. Load USB module: sudo modprobe usbhid" ;;
            4) show_solution "Bluetooth Fix" \
                "1. Check status: sudo systemctl status bluetooth" \
                "2. Start: sudo systemctl start bluetooth" \
                "3. Check rfkill: rfkill list bluetooth" \
                "4. Unblock: sudo rfkill unblock bluetooth" \
                "5. Scan: bluetoothctl → scan on" \
                "6. Install firmware: sudo apt install bluez firmware-atheros" ;;
            5) show_solution "Overheating Fix" \
                "1. Check temp: sensors (install lm-sensors first)" \
                "2. Setup sensors: sudo sensors-detect" \
                "3. Check fan: cat /sys/class/hwmon/hwmon*/fan*_input" \
                "4. Install TLP for laptops: sudo apt install tlp" \
                "5. CPU governor: cpupower frequency-set -g powersave" ;;
            6) show_solution "Keyboard/Mouse Fix" \
                "1. Check input devices: cat /proc/bus/input/devices" \
                "2. Check Xorg input: xinput list" \
                "3. Check dmesg: dmesg | grep -i 'input\|hid'" \
                "4. Reload HID module: sudo modprobe -r usbhid && sudo modprobe usbhid" ;;
            0) return ;;
        esac
    done
}

troubleshoot_software() {
    while true; do
        clear
        section_header "Software & Package Troubleshooting" "📦"
        echo -e "  ${MR_GREEN}1.${MR_NC}  Broken packages"
        echo -e "  ${MR_GREEN}2.${MR_NC}  Dependency conflicts"
        echo -e "  ${MR_GREEN}3.${MR_NC}  dpkg/apt lock error"
        echo -e "  ${MR_GREEN}4.${MR_NC}  Repository errors"
        echo -e "  ${MR_GREEN}5.${MR_NC}  Missing libraries"
        echo -e "  ${MR_RED}0.${MR_NC}  ← Back"
        echo ""
        echo -ne "  ${MR_CYAN}❯${MR_NC} Select: "
        read -r choice
        case $choice in
            1) show_solution "Fix Broken Packages" \
                "1. Fix broken: sudo apt --fix-broken install" \
                "2. Reconfigure: sudo dpkg --configure -a" \
                "3. Force install: sudo apt install -f" \
                "4. Clean cache: sudo apt clean" \
                "5. Update: sudo apt update && sudo apt upgrade" ;;
            2) show_solution "Dependency Conflicts" \
                "1. Check held packages: apt-mark showhold" \
                "2. Unhold: sudo apt-mark unhold <package>" \
                "3. Force resolution: sudo apt -o Debug::pkgProblemResolver=yes install" \
                "4. Use aptitude: sudo aptitude install <package>" ;;
            3) show_solution "dpkg/apt Lock Error" \
                "1. Check for running apt: ps aux | grep apt" \
                "2. Kill process: sudo kill <PID>" \
                "3. Remove lock files:" \
                "   sudo rm /var/lib/apt/lists/lock" \
                "   sudo rm /var/cache/apt/archives/lock" \
                "   sudo rm /var/lib/dpkg/lock-frontend" \
                "4. Reconfigure: sudo dpkg --configure -a" ;;
            4) show_solution "Repository Errors" \
                "1. Update sources: sudo apt update 2>&1 | grep Err" \
                "2. Check sources: cat /etc/apt/sources.list" \
                "3. Fix GPG key:" \
                "   sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys <KEY>" \
                "4. Remove broken PPA: sudo add-apt-repository --remove ppa:xxx" ;;
            5) show_solution "Missing Libraries" \
                "1. Find library: apt-file search <library.so>" \
                "2. Install apt-file: sudo apt install apt-file && sudo apt-file update" \
                "3. Check ldconfig: sudo ldconfig" \
                "4. Set LD path: export LD_LIBRARY_PATH=/usr/local/lib" ;;
            0) return ;;
        esac
    done
}

troubleshoot_services() {
    while true; do
        clear
        section_header "Services & Daemons Troubleshooting" "⚙️"
        echo -e "  ${MR_GREEN}1.${MR_NC}  Service won't start"
        echo -e "  ${MR_GREEN}2.${MR_NC}  Service keeps crashing"
        echo -e "  ${MR_GREEN}3.${MR_NC}  Cron job not running"
        echo -e "  ${MR_GREEN}4.${MR_NC}  View failed services"
        echo -e "  ${MR_RED}0.${MR_NC}  ← Back"
        echo ""
        echo -ne "  ${MR_CYAN}❯${MR_NC} Select: "
        read -r choice
        case $choice in
            1) show_solution "Service Won't Start" \
                "1. Check status: sudo systemctl status <service>" \
                "2. View logs: journalctl -u <service> -n 50" \
                "3. Check config files for syntax errors" \
                "4. Restart: sudo systemctl restart <service>" \
                "5. Enable: sudo systemctl enable <service>" \
                "6. Reload systemd: sudo systemctl daemon-reload" ;;
            2) show_solution "Service Keeps Crashing" \
                "1. Check logs: journalctl -u <service> --since today" \
                "2. Check resource limits: ulimit -a" \
                "3. Check if OOM killed: dmesg | grep -i oom" \
                "4. Set restart policy in service file:" \
                "   Restart=always" \
                "   RestartSec=5" ;;
            3) show_solution "Cron Job Not Running" \
                "1. Check crontab: crontab -l" \
                "2. Check cron service: sudo systemctl status cron" \
                "3. Check cron log: grep CRON /var/log/syslog" \
                "4. Use full paths in cron scripts" \
                "5. Ensure correct permissions on script" ;;
            4) echo ""
               msg_info "Checking failed services..."
               echo ""
               systemctl --failed 2>/dev/null || msg_warn "systemctl not available"
               echo ""
               echo -ne "  ${MR_DIM}Press Enter to continue...${MR_NC}"
               read -r ;;
            0) return ;;
        esac
    done
}

troubleshoot_security() {
    while true; do
        clear
        section_header "Security & Permissions Troubleshooting" "🔒"
        echo -e "  ${MR_GREEN}1.${MR_NC}  Permission denied errors"
        echo -e "  ${MR_GREEN}2.${MR_NC}  SSH hardening"
        echo -e "  ${MR_GREEN}3.${MR_NC}  Check open ports"
        echo -e "  ${MR_GREEN}4.${MR_NC}  Rootkit detection"
        echo -e "  ${MR_GREEN}5.${MR_NC}  Firewall setup"
        echo -e "  ${MR_RED}0.${MR_NC}  ← Back"
        echo ""
        echo -ne "  ${MR_CYAN}❯${MR_NC} Select: "
        read -r choice
        case $choice in
            1) show_solution "Permission Denied Fix" \
                "1. Check file perms: ls -la <file>" \
                "2. Change owner: sudo chown user:group <file>" \
                "3. Set permissions: sudo chmod 755 <file>" \
                "4. Check SELinux: getenforce" \
                "5. Fix SELinux context: restorecon -Rv /path" ;;
            2) show_solution "SSH Hardening" \
                "1. Disable root login: PermitRootLogin no" \
                "2. Use key-based auth: PubkeyAuthentication yes" \
                "3. Change port: Port 2222" \
                "4. Disable password auth: PasswordAuthentication no" \
                "5. Install fail2ban: sudo apt install fail2ban" ;;
            3) show_solution "Check Open Ports" \
                "1. List open ports: sudo ss -tulnp" \
                "2. Or: sudo netstat -tulnp" \
                "3. Scan with nmap: nmap -sV localhost" \
                "4. Close port via firewall: sudo ufw deny <port>" ;;
            4) show_solution "Rootkit Detection" \
                "1. Install rkhunter: sudo apt install rkhunter" \
                "2. Run scan: sudo rkhunter --check" \
                "3. Install chkrootkit: sudo apt install chkrootkit" \
                "4. Run: sudo chkrootkit" \
                "5. Check for suspicious processes: ps aux" ;;
            5) show_solution "UFW Firewall Setup" \
                "1. Enable: sudo ufw enable" \
                "2. Default deny: sudo ufw default deny incoming" \
                "3. Allow SSH: sudo ufw allow 22/tcp" \
                "4. Allow HTTP: sudo ufw allow 80/tcp" \
                "5. Status: sudo ufw status verbose" ;;
            0) return ;;
        esac
    done
}

troubleshoot_az() {
    while true; do
        clear
        section_header "A-Z Linux Problems Guide" "🐧"
        echo ""
        echo -e "  ${MR_CYAN}${MR_BOLD}CODE  ISSUE                      QUICK FIX${MR_NC}"
        echo -e "  ${MR_DIM}─────────────────────────────────────────────────────────────${MR_NC}"
        echo -e "  ${MR_GOLD}A${MR_NC}     ACPI boot error            ${MR_DIM}Disable ACPI in kernel params${MR_NC}"
        echo -e "  ${MR_GOLD}B${MR_NC}     Bootloader missing         ${MR_DIM}Reinstall GRUB${MR_NC}"
        echo -e "  ${MR_GOLD}C${MR_NC}     Corrupted kernel           ${MR_DIM}Reinstall linux-image${MR_NC}"
        echo -e "  ${MR_GOLD}D${MR_NC}     Disk not detected          ${MR_DIM}Check SATA/NVMe drivers${MR_NC}"
        echo -e "  ${MR_GOLD}E${MR_NC}     Ethernet failure           ${MR_DIM}Restart NetworkManager${MR_NC}"
        echo -e "  ${MR_GOLD}F${MR_NC}     Filesystem errors          ${MR_DIM}Run fsck${MR_NC}"
        echo -e "  ${MR_GOLD}G${MR_NC}     GRUB rescue mode           ${MR_DIM}grub-install repair${MR_NC}"
        echo -e "  ${MR_GOLD}H${MR_NC}     Hardware driver missing    ${MR_DIM}modprobe / firmware install${MR_NC}"
        echo -e "  ${MR_GOLD}I${MR_NC}     initramfs error            ${MR_DIM}update-initramfs -u${MR_NC}"
        echo -e "  ${MR_GOLD}J${MR_NC}     Journal fill disk          ${MR_DIM}journalctl --vacuum-size=100M${MR_NC}"
        echo -e "  ${MR_GOLD}K${MR_NC}     Kernel module issues       ${MR_DIM}modprobe / lsmod${MR_NC}"
        echo -e "  ${MR_GOLD}L${MR_NC}     Library missing            ${MR_DIM}apt-file search / ldconfig${MR_NC}"
        echo -e "  ${MR_GOLD}M${MR_NC}     Mount failure              ${MR_DIM}Check fstab / UUID${MR_NC}"
        echo -e "  ${MR_GOLD}N${MR_NC}     No internet                ${MR_DIM}Check DNS / dhclient${MR_NC}"
        echo -e "  ${MR_GOLD}O${MR_NC}     OOM (Out of Memory)        ${MR_DIM}Check RAM / swap / processes${MR_NC}"
        echo -e "  ${MR_GOLD}P${MR_NC}     Package lock               ${MR_DIM}Remove lock files${MR_NC}"
        echo -e "  ${MR_GOLD}Q${MR_NC}     Quota exceeded             ${MR_DIM}Clean disk / extend quota${MR_NC}"
        echo -e "  ${MR_GOLD}R${MR_NC}     Root password lost         ${MR_DIM}Boot recovery, passwd${MR_NC}"
        echo -e "  ${MR_GOLD}S${MR_NC}     Service crash              ${MR_DIM}journalctl -u / restart${MR_NC}"
        echo -e "  ${MR_GOLD}T${MR_NC}     Time zone wrong            ${MR_DIM}timedatectl set-timezone${MR_NC}"
        echo -e "  ${MR_GOLD}U${MR_NC}     USB not recognized         ${MR_DIM}lsusb / modprobe usbhid${MR_NC}"
        echo -e "  ${MR_GOLD}V${MR_NC}     VPN connection failure     ${MR_DIM}Check config / restart daemon${MR_NC}"
        echo -e "  ${MR_GOLD}W${MR_NC}     WiFi drop                  ${MR_DIM}rfkill unblock / driver reload${MR_NC}"
        echo -e "  ${MR_GOLD}X${MR_NC}     X server not starting      ${MR_DIM}Reinstall GPU drivers${MR_NC}"
        echo -e "  ${MR_GOLD}Y${MR_NC}     Yum/DNF errors             ${MR_DIM}Clean cache / fix repos${MR_NC}"
        echo -e "  ${MR_GOLD}Z${MR_NC}     Zombie processes           ${MR_DIM}kill -9 / find parent PID${MR_NC}"
        echo ""
        echo -ne "  ${MR_DIM}Press Enter to go back...${MR_NC}"
        read -r
        return
    done
}

# ── Show solution helper ──
show_solution() {
    local title="$1"
    shift
    clear
    echo ""
    echo -e "  ${MR_CYAN}╔══════════════════════════════════════════════════╗${MR_NC}"
    echo -e "  ${MR_CYAN}║${MR_NC}  ${MR_WHITE}${MR_BOLD}🔧 $title${MR_NC}"
    echo -e "  ${MR_CYAN}╚══════════════════════════════════════════════════╝${MR_NC}"
    echo ""
    for step in "$@"; do
        if [[ "$step" == "   "* ]]; then
            echo -e "      ${MR_GOLD}$step${MR_NC}"
        else
            echo -e "  ${MR_WHITE}$step${MR_NC}"
        fi
    done
    echo ""
    echo -e "  ${MR_DIM}────────────────────────────────────────────────────${MR_NC}"
    
    if confirm_action "Would you like to copy any command to clipboard?" "n"; then
        styled_prompt "Enter the command to copy"
        echo "$REPLY" | xclip -selection clipboard 2>/dev/null && msg_ok "Copied!" || msg_info "xclip not installed, manually copy the command above"
    fi
    
    echo ""
    echo -ne "  ${MR_DIM}Press Enter to continue...${MR_NC}"
    read -r
}

# ── Entry Point ──
run_manual_mode() {
    show_manual_menu
}

# Allow direct execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_manual_mode
fi
