[![Python](https://img.shields.io/badge/Python-3.11-brightgreen)](https://www.python.org/)
![GitHub issues](https://img.shields.io/github/issues/rotoapanta/zerotier-rpi-setup)
![GitHub repo size](https://img.shields.io/github/repo-size/rotoapanta/zerotier-rpi-setup)
![GitHub last commit](https://img.shields.io/github/last-commit/rotoapanta/zerotier-rpi-setup)
[![Discord Invite](https://img.shields.io/badge/discord-join%20now-green)](https://discord.gg/bf6rWDbJ)
[![Docker](https://img.shields.io/badge/Docker-No-brightgreen)](https://www.docker.com/)
[![Linux](https://img.shields.io/badge/Linux-Supported-brightgreen)](https://www.linux.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Author](https://img.shields.io/badge/Roberto%20-Toapanta-brightgreen)](https://www.linkedin.com/in/roberto-carlos-toapanta-g/)
[![Version](https://img.shields.io/badge/Version-1.0.0-brightgreen)](#changelog)
![GitHub forks](https://img.shields.io/github/forks/rotoapanta/zerotier-rpi-setup?style=social)

<p align="right"><strong>English</strong> | <a href="README.es.md">Español</a></p>

# <p align="center">Zerotier rpi setup</p>

Bash script to install, join, verify, and uninstall ZeroTier One on Raspberry Pi (and Debian/Ubuntu-based systems in general). It automates installing the service, joining a network, waiting for authorization on ZeroTier Central, and optionally testing connectivity with ping. It also supports leaving a network or uninstalling ZeroTier.

---

## ✨ Features

- Detects if the device is a Raspberry Pi and shows the model (Raspberry Pi 3/5 and others), OS and architecture.
- Installs ZeroTier if not present (with minimal dependencies).
- Enables and restarts the `zerotier-one` service.
- Joins the given network and waits up to 180 seconds for authorization on ZeroTier Central.
- Prints a summary: client status (`zerotier-cli status`), joined networks (`listnetworks`), `zt*` interfaces and the assigned ZeroTier IPv4.
- If `-p` is provided, performs a ping test to the specified peer IP.

## 🛠️ System requirements

- Supported systems:
  - Debian 11/12, Ubuntu 20.04/22.04/24.04 (Server/Desktop)
  - Raspberry Pi OS Bullseye/Bookworm (arm64/armhf)
  - Other Debian derivatives may work but are not tested
- Permissions: sudo/admin privileges to install packages and manage services.
- Network and ports:
  - Internet egress over HTTPS (TCP 443) to download the installer.
  - UDP 9993 open to/from the Internet (required by ZeroTier).
  - If using UFW: `sudo ufw allow 9993/udp`
- Architectures: `amd64/x86_64`, `arm64/aarch64`, `armhf`.
- Resources: ~50 MB free disk and ~50 MB RAM for the service.
- ZeroTier account and network:
  - An account at https://my.zerotier.com and your Network ID.
  - Optional: a peer’s ZeroTier IP for ping testing (`-p`) and ping count (`-t`).

Note: if ZeroTier is already installed, the script detects it and won’t reinstall.

## 🗂️ Project structure

```
zerotier-rpi-setup/
├── zerotier-rpi-setup.sh   # Main script: install, join, wait for auth and test connectivity
└── README.md               # Documentation in Spanish
```

## 🚀 Deployment

<p align="center">
  <img src="images/zerotier-network.png" alt="ZeroTier connection architecture" width="500" loading="lazy" style="max-width:100%; height:auto; display:block; margin:0 auto;" />
</p>
<p align="center"><sub>Figure 1. ZeroTier connection architecture (example)</sub></p>

1) 📦 Preparation
   - Clone or copy this repository to the target machine (Raspberry Pi or Ubuntu).

   ```bash
   git clone git@github.com:rotoapanta/zerotier-rpi-setup.git
   ```

2) 🛠️ Deploy using the script (recommended)
   ```bash
   chmod +x zerotier-rpi-setup.sh
   sudo ./zerotier-rpi-setup.sh -n <NETWORK_ID>
   # Example: sudo ./zerotier-rpi-setup.sh -n d5e5fb65374a3986
   ```
   - The script installs missing dependencies, installs ZeroTier, enables and restarts `zerotier-one`, joins the network and waits for authorization.

3) 🔐 Authorize on ZeroTier Central
   - https://my.zerotier.com → Networks → your_network → Members → check "Auth" for the new member.

4) 🔍 Verify status and IP
   ```bash
   sudo zerotier-cli status
   sudo zerotier-cli listnetworks
   ip -o -4 addr show | awk '/zt/{print $4}'
   ```

5) 🧱 Firewall (UFW)
   ```bash
   sudo ufw allow 9993/udp
   ```

6) 📜 Service and logs
   ```bash
   sudo systemctl enable zerotier-one
   sudo systemctl status zerotier-one
   sudo journalctl -u zerotier-one -n 200 --no-pager
   ```

7) 🧹 Rollback / cleanup
   ```bash
   # Leave the network
   sudo zerotier-cli leave <NETWORK_ID>
   # or using the script
   sudo ./zerotier-rpi-setup.sh -n <NETWORK_ID> --leave

   # Uninstall ZeroTier
   sudo apt purge zerotier-one -y && sudo apt autoremove -y
   # or using the script
   sudo ./zerotier-rpi-setup.sh --uninstall
   ```

## 🆘 Help and flags

```text
Usage: sudo ./zerotier-rpi-setup.sh -n <NETWORK_ID> [-p <PEER_IP>] [-t <PING_COUNT>] [--leave] [--uninstall]
  -n   ZeroTier Network ID (required, e.g., 8056c2e21c000001)
  -p   Peer’s ZeroTier virtual IP to test ping (optional)
  -t   Number of ping packets (default: 4)
  --leave     Leave the specified network (-n required)
  --uninstall Uninstall ZeroTier (purge)
Examples:
  sudo ./zerotier-rpi-setup.sh -n 8056c2e21c000001
  sudo ./zerotier-rpi-setup.sh -n 8056c2e21c000001 -p 10.147.20.12 -t 5
```

- -n: ZeroTier Network ID (required)
- -p: Peer’s ZeroTier IPv4 to test connectivity with ping
- -t: Number of packets to send in the ping test
- --leave: Leave the specified network (service not uninstalled)
- --uninstall: Completely uninstall ZeroTier
- -h | --help: Show help

## 🔗 Connect a new device from scratch

Prerequisites:
- Have your `NETWORK_ID` (from https://my.zerotier.com → Networks).
- Permission to authorize members on ZeroTier Central.

1) Linux / Raspberry Pi (Debian/Ubuntu)
   - Recommended (using this script):
     ```bash
     chmod +x zerotier-rpi-setup.sh
     sudo ./zerotier-rpi-setup.sh -n <NETWORK_ID>
     ```
   - Manual alternative:
     ```bash
     curl -s https://install.zerotier.com | sudo bash
     sudo zerotier-cli join <NETWORK_ID>
     ```

2) Windows
   - Install ZeroTier One from https://www.zerotier.com/download/
   - Join Network with `<NETWORK_ID>`, authorize on Central, verify IP.

3) iPhone (iOS)
   - App Store: https://apps.apple.com/app/zerotier-one/id1085978097
   - Join with `<NETWORK_ID>`, allow the VPN profile, enable ZeroTier in Settings if needed, authorize on Central.

## 🧩 Troubleshooting

- ⚠️ Member in PENDING without IP
  - Authorize at https://my.zerotier.com → Networks → Members (Auth checkbox).
  - Ensure the address pool (Auto-Assign) is configured.
- 🛡️ No ZeroTier IP
  - Check pools/rules, restart the service: `sudo systemctl restart zerotier-one`.
- 🔌 No connectivity to peer
  - Ensure both members are on the same network, authorized and with IP; check firewall (ICMP), routes and that the peer is online.
- 📜 Service logs/status
  ```bash
  sudo systemctl status zerotier-one
  sudo journalctl -u zerotier-one -n 200 --no-pager
  ```

## 💬 Feedback

For comments or suggestions: robertocarlos.toapanta@gmail.com

## 🛟 Support

For support, email robertocarlos.toapanta@gmail.com or join our Discord channel.

## License

[MIT](https://opensource.org/licenses/MIT)

## Authors

- [@rotoapanta](https://github.com/rotoapanta)

## Changelog

This project follows Keep a Changelog and Semantic Versioning.

[Unreleased]
- 

- 1.0.0 – 2025-09-23
  - Stable release: step progress ("Step X/Y"), multi-platform connection guide, simplified suggestions, and reorganized README.

- 0.3.0 – 2025-09-23
  - Pre-release with "Connect a new device" guide and iOS integration.

- 0.1.0 – 2025-09-23
  - Initial version of the script.

## ℹ️ More information

Useful links:
- ZeroTier Central: https://my.zerotier.com
- ZeroTier downloads: https://www.zerotier.com/download/
- CLI documentation: https://docs.zerotier.com/zerotier/cli

## 🔗 Links

[![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/roberto-carlos-toapanta-g/)

[![twitter](https://img.shields.io/badge/twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/rotoapanta)
