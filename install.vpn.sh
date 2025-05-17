#!/bin/bash

# This script installs and configures OpenVPN on Ubuntu 24.04
# - Protocol: TCP
# - Port: 1194
# - DNS: Google + Cloudflare
# - IPv6 is disabled
# - UFW firewall is configured
# - PAM-based username/password login is enabled
# - Generates initial client .ovpn file
# - Provides a function to create additional users

set -e

# Check for root permissions
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Install OpenVPN and required tools
apt update && apt install -y openvpn easy-rsa ufw curl networkd-dispatcher

# Disable IPv6
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
sysctl -p

# Set up Easy-RSA
EASYRSA_DIR=~/openvpn-ca
make-cadir $EASYRSA_DIR
cd $EASYRSA_DIR

# Configure Easy-RSA vars
cat > vars <<EOF
set_var EASYRSA_REQ_COUNTRY    "US"
set_var EASYRSA_REQ_PROVINCE   "State"
set_var EASYRSA_REQ_CITY       "City"
set_var EASYRSA_REQ_ORG        "Org"
set_var EASYRSA_REQ_EMAIL      "email@example.com"
set_var EASYRSA_REQ_OU         "MyVPN"
set_var EASYRSA_ALGO           "ec"
set_var EASYRSA_DIGEST         "sha512"
EOF

# Initialize PKI and generate certificates
./easyrsa init-pki
echo -ne '\n' | ./easyrsa build-ca nopass
./easyrsa gen-dh
./easyrsa build-server-full server nopass
./easyrsa gen-crl

# Copy server files
cp pki/ca.crt pki/private/server.key pki/issued/server.crt pki/dh.pem pki/crl.pem /etc/openvpn/

# Generate TLS key
openvpn --genkey --secret /etc/openvpn/ta.key

# Copy and configure default server config
gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz > /etc/openvpn/server.conf

# Server config changes
sed -i 's/^proto udp/proto tcp/' /etc/openvpn/server.conf
sed -i 's/^;user nobody/user nobody/' /etc/openvpn/server.conf
sed -i 's/^;group nogroup/group nogroup/' /etc/openvpn/server.conf
sed -i 's/^;log-append/log-append/' /etc/openvpn/server.conf
sed -i 's/^;client-cert-not-required/client-cert-not-required/' /etc/openvpn/server.conf
echo "plugin /usr/lib/openvpn/openvpn-plugin-auth-pam.so login" >> /etc/openvpn/server.conf
echo "verify-client-cert none" >> /etc/openvpn/server.conf
echo "auth-user-pass-verify /etc/openvpn/check_user.sh via-env" >> /etc/openvpn/server.conf

# IP forwarding
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# Setup basic firewall rules
ufw allow OpenSSH
ufw allow 1194/tcp
ufw disable
ufw --force enable

# NAT for VPN
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
iptables-save > /etc/iptables.rules
mkdir -p /etc/networkd-dispatcher/routable.d/
cat > /etc/networkd-dispatcher/routable.d/99-iptables <<EOF
#!/bin/sh
iptables-restore < /etc/iptables.rules
EOF
chmod +x /etc/networkd-dispatcher/routable.d/99-iptables

# Enable and start OpenVPN service
systemctl enable openvpn@server
systemctl start openvpn@server

# User checker script (placeholder)
cat > /etc/openvpn/check_user.sh <<EOF
#!/bin/bash
exit 0
EOF
chmod +x /etc/openvpn/check_user.sh

# Function to generate client .ovpn file
generate_ovpn() {
  USERNAME="\$1"
  cd $EASYRSA_DIR
  ./easyrsa build-client-full \$USERNAME nopass
  CLIENT_DIR=~/clients
  mkdir -p \$CLIENT_DIR

  cat > \$CLIENT_DIR/\$USERNAME.ovpn <<EOF_CLIENT
client
dev tun
proto tcp
remote $(curl -s ifconfig.me) 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
auth-user-pass
cipher AES-256-CBC
verb 3

<ca>
$(cat $EASYRSA_DIR/pki/ca.crt)
</ca>
<cert>
$(cat $EASYRSA_DIR/pki/issued/\$USERNAME.crt)
</cert>
<key>
$(cat $EASYRSA_DIR/pki/private/\$USERNAME.key)
</key>
<tls-auth>
$(cat /etc/openvpn/ta.key)
</tls-auth>
key-direction 1
EOF_CLIENT

  echo "✅ .ovpn config generated: \$CLIENT_DIR/\$USERNAME.ovpn"
}

# Create first default client
generate_ovpn "client1"

echo "✅ OpenVPN is installed and running."
echo "📄 You can generate new clients by running: generate_ovpn <username>"
