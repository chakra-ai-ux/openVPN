# 🚀 OpenVPN Auto Installer for Ubuntu 24.04

This project provides a fully automated script to install and configure a secure OpenVPN server on a **clean Ubuntu 24.04** system.

---

## ✅ Features

- ✅ **TCP protocol** (port **1194**)
- ✅ **Google** and **Cloudflare** DNS
- ✅ **IPv6 disabled** for enhanced privacy
- ✅ **UFW firewall** configured automatically
- ✅ **PAM login/password authentication**
- ✅ **.ovpn config auto-generated** for each user
- ✅ Function to **generate multiple user configs** anytime

---

## 📦 Installation

1. **Download the script:**

```bash
wget https://raw.githubusercontent.com/chakra-ai-ux/openVPN/main/install.vpn.sh
chmod +x install.vpn.sh
Run the installer as root:
sudo ./install.vpn.sh
This will install OpenVPN, configure the firewall, disable IPv6, enable password login, and create the first client config: client1.ovpn.
👤 Adding VPN Users

OpenVPN is configured to authenticate users via Linux system accounts. To create a new VPN user:
sudo adduser yourusername
You will be prompted to enter a password — this will be used to connect to the VPN.
🎟️ Generating .ovpn Configs for Users

To generate a new .ovpn configuration file for a specific user:
sudo su
source ./install.vpn.sh
generate_ovpn yourusername
The config file will be saved to:
~/clients/yourusername.ovpn
📲 Importing .ovpn on Client Devices

You can use the generated .ovpn file on any OpenVPN-compatible client:
Windows: Use OpenVPN GUI
macOS: Use Tunnelblick
Linux: Use the command-line or NetworkManager plugin
Android: Use OpenVPN for Android
iOS: Use OpenVPN Connect
Transfer the .ovpn file securely to the device and import it via the respective app.
🛡️ Security Tips

Always create strong passwords for system users.
Do not share .ovpn files publicly — they contain sensitive certificates and keys.
If possible, rotate TLS and CA certificates periodically.
Keep your system and OpenVPN package up-to-date.
⚠️ Disclaimer

This script is provided "as is", without warranty of any kind. Use it at your own risk.
Designed for educational, personal, and secure self-hosted VPN deployment.
📜 License

This project is licensed under the MIT License. See the LICENSE file for more info.
