#!/bin/bash

# Replace this with your IP or internal subnet
TRUSTED_IP="192.168.1.0/24"

echo "🔒 Installing UFW and configuring firewall rules..."

# Install ufw
sudo apt update
sudo apt install -y ufw

# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH
sudo ufw allow ssh

# Allow NPM UI only from your trusted IP or subnet
echo "🔐 Allowing NPM UI (port 81) from $TRUSTED_IP"
sudo ufw allow from "$TRUSTED_IP" to any port 81 proto tcp

# Allow Tailscale subnet full access (if you want limited ports, modify this line)
echo "🔐 Allowing full access from Tailscale subnet (100.64.0.0/10)"
sudo ufw allow from 100.64.0.0/10

# Cloudflare IP ranges
CLOUDFLARE_IPS=(
  "173.245.48.0/20"
  "103.21.244.0/22"
  "103.22.200.0/22"
  "103.31.4.0/22"
  "141.101.64.0/18"
  "108.162.192.0/18"
  "190.93.240.0/20"
  "188.114.96.0/20"
  "197.234.240.0/22"
  "198.41.128.0/17"
  "162.158.0.0/15"
  "104.16.0.0/13"
  "104.24.0.0/14"
  "172.64.0.0/13"
  "131.0.72.0/22"
)

echo "🌐 Allowing Cloudflare IPs on ports 80 and 443..."

for ip in "${CLOUDFLARE_IPS[@]}"; do
  sudo ufw allow from "$ip" to any port 80,443 proto tcp
done

echo "Logging is now enabled for this sytem, they're stored at: /var/log/ufw.log"
sudo ufw logging on
sudo ufw logging high

# Enable UFW
echo "✅ Enabling UFW..."
sudo ufw --force enable

echo "🎉 UFW is now active and protecting your server."
