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
| 📖 **Manual Mode** | Interactive A-Z troubleshooting guide with quick-copy commands |
| ⚡ **Automated Mode** | **New Dashboard UI** auto-detect and fix 10+ issue categories |
| 🤖 **AI Analysis** | Intelligent log parsing with **Multi-AI Failover System** |
| 🌐 **Online AI** | Deep analysis using Gemini, Qwen, and Mistral via OpenRouter |
| 🔄 **Boot Repair** | GRUB, kernel, initramfs recovery tools |
| 💊 **Health Score** | Visual **Premium Dashboard** with A+ to F grading |
| 🛡️ **AI Failover** | Automatic rotation between 5 AI models and redundant API keys |
| 📦 **Auto-Deps** | Intelligent dependency installer (curl, jq, xclip, etc.) |

---

## 🚀 Quick Start

### Installation

#### Method 1: Global Installation (Recommended)
```bash
# Clone the repository
git clone https://github.com/Rajnayak0/MR-LINMACHNIC.git
cd MR-LINMACHNIC

# Install globally (adds mr-machine command to PATH)
sudo bash install.sh

# Run from anywhere
mr-machine
```

#### Method 2: Direct Execution (No Installation)
```bash
# Clone the repository
git clone https://github.com/Rajnayak0/MR-LINMACHNIC.git
cd MR-LINMACHNIC

# Run directly from project directory
bash mr-machine.sh

# Or run specific modes directly
bash modules/ai_mode.sh          # AI Analysis Mode
bash modules/auto_mode.sh        # Automated Mode
bash modules/manual_mode.sh      # Manual Mode
bash modules/health_scan.sh      # Health Dashboard
bash modules/boot_repair.sh      # Boot Repair Tools
```

#### Method 3: Manual Setup
```bash
# Clone the repository
git clone https://github.com/Rajnayak0/MR-LINMACHNIC.git
cd MR-LINMACHNIC

# Make scripts executable
chmod +x *.sh
chmod +x modules/*.sh
chmod +x lib/*.sh

# Create symlink for global access (optional)
sudo ln -sf "$(pwd)/mr-machine.sh" /usr/local/bin/mr-machine

# Run
mr-machine
```

### System Requirements

#### Minimum Requirements
- **Operating System**: Linux (any distribution)
- **Shell**: Bash 4.0+ (tested on Bash 5.0+)
- **Disk Space**: 50MB (1GB+ recommended for AI models)
- **Memory**: 512MB RAM

#### For Full Functionality
- **Internet Connection**: Required for Online AI features
- **Root Access**: Required for system repairs and installations
- **Dependencies**: curl, jq (auto-installed if missing)

#### Optional Dependencies
- **Ollama**: For local AI processing (auto-installed if needed)
- **Git**: For updates and version control

### Setup for Different Distributions

#### Ubuntu/Debian
```bash
# Install dependencies
sudo apt update
sudo apt install -y curl jq git

# Clone and install
git clone https://github.com/Rajnayak0/MR-LINMACHNIC.git
cd MR-LINMACHNIC
sudo bash install.sh
```

#### Fedora/CentOS/RHEL
```bash
# Install dependencies
sudo dnf install -y curl jq git
# or for older systems: sudo yum install -y curl jq git

# Clone and install
git clone https://github.com/Rajnayak0/MR-LINMACHNIC.git
cd MR-LINMACHNIC
sudo bash install.sh
```

#### Arch Linux/Manjaro
```bash
# Install dependencies
sudo pacman -Sy curl jq git

# Clone and install
git clone https://github.com/Rajnayak0/MR-LINMACHNIC.git
cd MR-LINMACHNIC
sudo bash install.sh
```

#### Kali Linux
```bash
# Dependencies usually pre-installed
git clone https://github.com/Rajnayak0/MR-LINMACHNIC.git
cd MR-LINMACHNIC
sudo bash install.sh
```

### AI Features Setup

#### Online AI Configuration
1. **Get API Keys**: Sign up at [OpenRouter.ai](https://openrouter.ai)
2. **Create .env file** in the project root:
   ```bash
   nano .env
   ```
3. **Add your API keys**:
   ```bash
   OPENROUTER_API_KEY_1=your_primary_api_key_here
   OPENROUTER_API_KEY_2=your_backup_api_key_here
   ```
4. **Save and exit** (Ctrl+X, Y, Enter)

#### Local AI (Ollama) Setup
No setup required! The system will automatically:
1. Detect if Ollama is available
2. Install Ollama if needed
3. Download a lightweight model (llama3.2)
4. Configure local AI processing

Manual Ollama installation:
```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Download model
ollama pull llama3.2
```

### Usage Examples

#### Basic Usage
```bash
# Launch interactive menu
mr-machine

# Quick system scan
mr-machine --scan

# Automated diagnosis and repair
mr-machine --auto

# AI-powered log analysis
mr-machine --ai

# System health dashboard
mr-machine --health

# Boot repair tools
mr-machine --boot

# Manual troubleshooting guide
mr-machine --manual
```

#### Advanced Usage
```bash
# Real-time system monitoring
mr-machine --monitoring

# Hardware diagnostics
mr-machine --hardware

# Security scan
mr-machine --security

# Container diagnostics
mr-machine --containers

# Generate detailed reports
mr-machine --reporting

# Performance optimization
mr-machine --optimize

# Advanced configuration
mr-machine --config
```

#### Command Line Options
```bash
mr-machine --help              # Show all options
mr-machine --version           # Show version info
mr-machine --scan              # Quick system overview
mr-machine --auto              # Automated diagnostic & repair
mr-machine --ai                # AI log analysis
mr-machine --health            # Health score dashboard
mr-machine --boot              # Boot repair tools
mr-machine --manual            # Interactive troubleshooting
mr-machine --monitoring        # Real-time monitoring
mr-machine --hardware          # Hardware diagnostics
mr-machine --security          # Security scan
mr-machine --containers        # Container diagnostics
mr-machine --reporting         # Generate HTML reports
mr-machine --optimize          # Performance optimization
mr-machine --config            # Advanced configuration
```

### First-Time Setup Checklist

- [ ] Clone repository: `git clone https://github.com/Rajnayak0/MR-LINMACHNIC.git`
- [ ] Navigate to directory: `cd MR-LINMACHNIC`
- [ ] Install globally: `sudo bash install.sh` (or run directly)
- [ ] Install dependencies: `curl`, `jq`, `git` (auto-installed if missing)
- [ ] [Optional] Set up AI: Create `.env` file with OpenRouter API keys
- [ ] [Optional] Test installation: `mr-machine --help`
- [ ] [Optional] Run quick scan: `mr-machine --scan`

### Troubleshooting Installation

#### Permission Denied
```bash
# Make scripts executable
chmod +x *.sh
chmod +x modules/*.sh
chmod +x lib/*.sh
```

#### Command Not Found
```bash
# Add to PATH manually
export PATH="$PATH:$(pwd)"
# Or create symlink
sudo ln -sf "$(pwd)/mr-machine.sh" /usr/local/bin/mr-machine
```

#### Missing Dependencies
The system will automatically prompt to install missing dependencies, or install manually:
```bash
# Ubuntu/Debian
sudo apt install curl jq git

# Fedora/CentOS
sudo dnf install curl jq git

# Arch Linux
sudo pacman -Sy curl jq git
```

#### AI Features Not Working
```bash
# Check API keys
cat .env

# Test curl connectivity
curl -I https://openrouter.ai

# Install Ollama manually
curl -fsSL https://ollama.com/install.sh | sh
```

---

## 📖 Usage Guide

### Interactive Menu
When you run `mr-machine` without arguments, you'll see the main menu with 13 different modes:

1. **Manual Mode** - Step-by-step troubleshooting guide
2. **Automated Diagnostic** - Auto-detect and fix issues
3. **AI Analysis Mode** - Intelligent log analysis
4. **Boot Repair** - GRUB, kernel, initramfs tools
5. **System Health Score** - Full health dashboard
6. **Quick System Scan** - Fast overview of system state
7. **Real-time Monitoring** - Live system monitoring
8. **Hardware Diagnostics** - Advanced hardware testing
9. **Security Scanner** - Comprehensive security audit
10. **Container Diagnostics** - Docker/Podman/K8s analysis
11. **Advanced Reporting** - Generate detailed HTML reports
12. **Performance Optimizer** - System performance tuning
13. **Advanced Configuration** - Edit advanced settings

### Understanding the Health Score
The system provides a health score from 0-100 with letter grades:
- **A+ (90-100)**: Excellent health
- **B+ (80-89)**: Good health
- **C (60-79)**: Fair health
- **D (40-59)**: Poor health
- **F (0-39)**: Critical issues

### AI Analysis Features
The AI mode includes three tiers of analysis:
1. **Offline Pattern Matching** - Fast local analysis
2. **Online Cloud AI** - Advanced analysis via OpenRouter
3. **Local LLM** - Offline AI via Ollama

---

## 🔧 Advanced Configuration

### Environment Variables
Create a `.env` file in the project root to configure advanced options:

```bash
# AI Configuration
OPENROUTER_API_KEY_1=your_primary_key
OPENROUTER_API_KEY_2=your_backup_key

# System Configuration
MR_BASE_DIR=/custom/path/to/mr-linmachnic
MR_LOG_DIR=/custom/log/path
MR_DATA_DIR=/custom/data/path

# Advanced Options
MR_DEBUG=true
MR_VERBOSE=true
MR_AUTO_INSTALL=true
```

### Customizing Error Patterns
Edit `data/error_codes.txt` to add custom error patterns for your environment.

### Adding Custom Modules
Place custom module scripts in the `modules/` directory following the naming convention `module_name.sh`.

---

## 🛡️ Security Considerations

### Running with Root Privileges
Many features require root access for system repairs. Always:
- Review commands before executing
- Understand what changes will be made
- Use in trusted environments only

### API Key Security
- Store API keys in `.env` file (not in scripts)
- Add `.env` to `.gitignore` to prevent accidental commits
- Use strong, unique API keys
- Regularly rotate API keys

### Network Security
- The system makes HTTPS requests to trusted APIs
- All API communications are encrypted
- No sensitive system data is transmitted

---

## 🤝 Contributing

We welcome contributions! Here's how to get started:

### Development Setup
```bash
# Fork and clone the repository
git clone https://github.com/your-username/MR-LINMACHNIC.git
cd MR-LINMACHNIC

# Set up development environment
chmod +x *.sh
chmod +x modules/*.sh
chmod +x lib/*.sh

# Test your changes
bash mr-machine.sh --help
```

### Contribution Guidelines
1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature-name`
3. **Make your changes**
4. **Test thoroughly**
5. **Commit your changes**: `git commit -m "Add feature"`
6. **Push to the branch**: `git push origin feature-name`
7. **Create a Pull Request**

### Code Style
- Use Bash 4.0+ compatible syntax
- Follow existing code style and conventions
- Add comments for complex logic
- Test on multiple distributions

### Reporting Issues
When reporting bugs or issues:
1. Include your Linux distribution and version
2. Provide the exact error message
3. Describe steps to reproduce the issue
4. Include relevant system information

---

## 📊 Performance & Optimization

### System Requirements by Feature
| Feature | CPU | RAM | Disk | Network |
|---------|-----|-----|------|---------|
| Basic Diagnostics | 1 core | 256MB | 10MB | No |
| AI Analysis | 2 cores | 1GB | 100MB | Yes |
| Hardware Diagnostics | 1 core | 512MB | 50MB | No |
| Real-time Monitoring | 1 core | 256MB | 10MB | No |

### Optimization Tips
- Run during low-usage periods for best performance
- Use `--scan` for quick checks instead of full diagnostics
- Configure AI features only if needed
- Regularly clean log files to save disk space

---

## 🚨 Emergency Procedures

### System Recovery
If your system becomes unbootable:
1. Boot from live USB/CD
2. Mount your root filesystem
3. Run `bash mr-machine.sh --boot` from the mounted system
4. Follow the boot repair procedures

### Rollback Changes
The system logs all changes made. To review:
```bash
# View recent logs
tail -f logs/mr-machine-$(date +%Y%m%d).log

# Check for system changes
journalctl -n 50
```

---

## 📞 Support & Community

### Getting Help
- **GitHub Issues**: Report bugs and feature requests
- **Documentation**: Check this README and module comments
- **Community**: Join discussions on GitHub

### Known Limitations
- Requires Bash 4.0+ (older systems may need updates)
- Some features require internet connectivity
- Hardware diagnostics may not work on all systems
- AI features require API keys for full functionality

### Frequently Asked Questions

**Q: Can I run this on production servers?**
A: Yes, but test thoroughly in development first. Always backup critical data.

**Q: Does this modify system files?**
A: Yes, for repairs. Always review changes before applying.

**Q: How often should I run diagnostics?**
A: Weekly for servers, monthly for desktops, or when issues occur.

**Q: Can I disable AI features?**
A: Yes, they're optional. The system works fully offline.

**Q: Is this safe for beginners?**
A: Yes, it provides clear explanations and warnings before making changes.

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
      │   (Offline)    │  │   (Offline)     │  │ (Online/Offline) │
      └────────────────┘  └─────────────────┘  └────────┬─────────┘
               │                   │                    │
               ▼                   ▼                    ▼
      ┌────────────────┐  ┌─────────────────┐  ┌────────┴─────────┐
      │ A-Z Solutions  │  │ Diagnostic Scan │  │  Pattern Match   │
      │ Interactive    │  │ Auto-Fix Engine │  │  Online Gemini   │
      └────────────────┘  └─────────────────┘  └──────────────────┘
```

---

## 📋 Requirements

For **Online AI Deep Analysis**, the following are required:
- `curl` - For API communication
- `jq` - For JSON parsing
- `OpenRouter API Key` - Defined in `.env` file
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

## 🤖 AI Analysis & Failover System

The Machine features a robust 3-tier analysis engine:

1. **Tier 1: Offline Pattern Matching**: High-speed local matching engine with 10+ error categories (OOM, Disk, Network, etc.).
2. **Tier 2: Online Cloud AI**: Features a **Multi-AI Failover System** rotating through 5 models (Gemini, Qwen, Mistral) via OpenRouter.
3. **Tier 3: Local LLM (Ollama)**: The ultimate fallback. If no internet is available or API keys fail, the machine installs and uses **Ollama** locally to provide intelligent solutions.

### Setting up Online AI

1. Create/Update a `.env` file in the root directory:
   ```bash
   OPENROUTER_API_KEY_1=your_primary_key
   OPENROUTER_API_KEY_2=your_backup_key
   ```

### Local AI (Ollama)
No setup required! If the machine detects that online APIs are failing, it will automatically offer to install Ollama and download a lightweight model (`llama3.2`) for offline intelligence.

---

## 💊 Premium Dashboard UI

The health dashboard and automated scans now feature a premium, framed interface:

```
  ╔══ RESOURCE USAGE ══════════════════════════════════╗
    Disk (/)           ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░  91% load
    Memory             ▓▓▓▓▓▓▓▓▓░░░░░░░░░░░  45% load
    CPU                ▓▓▓▓░░░░░░░░░░░░░░░░  12% load
  ╚══════════════════════════════════════════════════╝
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
