# MR-LINMACHNIC 🛠️

### Mr. LinMachine — Your Autonomous Linux System Mechanic

> **The Machine That Repairs Linux**

[![License: MIT](https://img.shields.io/badge/License-MIT-cyan.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Linux-orange.svg)]()
[![Bash](https://img.shields.io/badge/Shell-Bash%205.0+-green.svg)]()
[![Cost](https://img.shields.io/badge/Cost-FREE-brightgreen.svg)]()

---

## 🌟 What is MR-LINMACHNIC?

**MR-LINMACHNIC** is a **powerful, free, and open-source** Linux diagnostic and repair framework that detects, analyzes, and resolves Linux system issues — **automatically or interactively**.

Designed for **sysadmins**, **cybersecurity professionals**, **DevOps engineers**, and **Linux enthusiasts** who want a single tool to diagnose and fix any Linux problem.

**Author:** Madan Raj

---

## ⚡ Features

| Feature | Description |
|---------|-------------|
| 📖 **Manual Mode** | Interactive A-Z troubleshooting guide |
| ⚡ **Automated Mode** | Auto-detect and fix 10+ issue categories |
| 🤖 **AI Analysis** | Intelligent log parsing with pattern matching engine |
| 🔄 **Boot Repair** | GRUB, kernel, initramfs recovery tools |
| 💊 **Health Score** | Visual dashboard with A-F grading |
| 🔍 **Quick Scan** | Fast system overview in seconds |
| 🔒 **Security Check** | Open ports, SSH, firewall analysis |
| 🌐 **Network Diagnostics** | DNS, WiFi, connectivity troubleshooting |
| 📦 **Package Repair** | Fix broken packages across all distros |
| 🐧 **Multi-Distro** | Ubuntu, Debian, Fedora, Arch, CentOS, Kali |

---

## 🚀 Quick Start

### Install

```bash
git clone https://github.com/your-username/MR-LINMACHNIC.git
cd MR-LINMACHNIC
sudo bash install.sh
```

### Run

```bash
mr-machine
```

That's it! Run from **any directory** on your Linux system.

### CLI Options

```bash
mr-machine              # Interactive menu
mr-machine --scan       # Quick system scan
mr-machine --auto       # Auto-diagnose & fix
mr-machine --ai         # AI log analysis
mr-machine --health     # Health score dashboard
mr-machine --boot       # Boot repair tools
mr-machine --manual     # Interactive troubleshooting
mr-machine --help       # Show help
```

---

## 🏛️ Architecture

```
                     ┌──────────────────────────┐
                     │     mr-machine (CLI)     │
                     └────────────┬─────────────┘
                                  │
              ┌───────────────────┼────────────────────┐
              ▼                   ▼                    ▼
     ┌────────────────┐  ┌─────────────────┐  ┌──────────────────┐
     │  Manual Mode   │  │  Automated Mode │  │    AI Mode       │
     │   (Offline)    │  │   (Offline)     │  │   (Offline/AI)   │
     └────────────────┘  └─────────────────┘  └──────────────────┘
              │                   │                    │
              ▼                   ▼                    ▼
     ┌────────────────┐  ┌─────────────────┐  ┌──────────────────┐
     │ A-Z Solutions  │  │ Diagnostic Scan │  │ Pattern Matching │
     │ Interactive    │  │ Auto-Fix Engine │  │ Error Classifier │
     └────────────────┘  └─────────────────┘  └──────────────────┘
```

---

## 📁 Project Structure

```
MR-LINMACHNIC/
├── mr-machine.sh           # Main controller (entry point)
├── install.sh              # Global installer
├── uninstall.sh            # Clean uninstaller
├── README.md               # This file
├── LICENSE                 # MIT License
├── lib/
│   ├── ui.sh               # UI library (colors, spinners, menus)
│   └── utils.sh            # System utilities (detection, monitoring)
├── modules/
│   ├── manual_mode.sh      # Interactive troubleshooting
│   ├── auto_mode.sh        # Automated diagnostic & repair
│   ├── ai_mode.sh          # AI-powered log analysis
│   ├── boot_repair.sh      # Boot recovery tools
│   └── health_scan.sh      # System health dashboard
├── data/
│   └── error_codes.txt     # Error pattern database
├── logs/                   # Runtime logs
└── plugins/                # Future plugin support
```

---

## 🔧 Troubleshooting Categories

### System & Boot
Boot failures • Kernel panic • initramfs • GRUB • Black screen • Emergency mode • Slow boot

### Storage & Disk
Disk full • Filesystem corruption • Disk not detected • Slow I/O • Mount errors • RAID

### Network & Internet
No internet • DNS failure • WiFi drop • Network adapter • Slow speed • SSH • Firewall

### Hardware & Drivers
GPU drivers • Audio • USB • Bluetooth • Overheating • Keyboard/Mouse

### Software & Packages
Broken packages • Dependency conflicts • dpkg lock • Repository errors • Missing libraries

### Services & Security
Service crashes • Cron jobs • File permissions • SSH hardening • Rootkits • Open ports

---

## 🤖 AI Analysis Engine

The AI Mode uses a **built-in pattern matching engine** with 10+ error categories:

| Category | Patterns Detected |
|----------|-------------------|
| OOM | Out of Memory, oom-killer |
| DISK | No space left, I/O error |
| NET | Network unreachable, DNS fail |
| BOOT | Kernel panic, GRUB error |
| SERVICE | Failed to start, segfault |
| AUTH | Authentication failure |
| GPU | GPU error, Xorg error |
| USB | USB error, descriptor read |
| FS | ext4 error, corrupt |
| KERNEL | BUG, oops, soft lockup |

**100% Free — No API keys, no subscriptions, no internet required for core features.**

---

## 💊 Health Score System

The health dashboard grades your system from **A+ to F**:

```
  CPU       ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░  82%
  Memory    ▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░  61%
  Disk      ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░  87%
  Overall   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░  76%

  Grade: B  FAIR (76/100)
```

---

## 🔒 Supported Distributions

- ✅ Ubuntu / Debian / Linux Mint
- ✅ Fedora / RHEL / CentOS
- ✅ Arch Linux / Manjaro
- ✅ Kali Linux
- ✅ openSUSE
- ✅ Alpine Linux

---

## 🗑️ Uninstall

```bash
sudo bash uninstall.sh
```

---

## 📝 License

MIT License — Free to use, modify, and distribute.

---

## 👤 Author

**Madan Raj**

---

<p align="center">
  <b>MR-LINMACHNIC 🛠️</b><br>
  <i>The Machine That Repairs Linux</i><br>
  <i>Your Autonomous Linux System Mechanic</i>
</p>
