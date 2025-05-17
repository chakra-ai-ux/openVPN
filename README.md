# openVPN
Secure and automated OpenVPN installation script for Ubuntu 24.04

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
wget https://...

Run the installer as root:
sudo ./install.vpn.sh

🔐 "How to add system users for login/password authentication" — sudo adduser username
📱 "How to import .ovpn config into clients" — for Windows/macOS/Android/iOS
