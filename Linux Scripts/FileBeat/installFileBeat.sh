#!/bin/bash

# Check for root
if [[ $EUID -ne 0 ]]; then
  echo "❌ Please run this script as root (sudo)."
  exit 1
fi

# Add Elastic GPG key and APT repo
echo "🔑 Adding Elastic GPG key and repository..."
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o /usr/share/keyrings/elastic.gpg

echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" \
  | tee /etc/apt/sources.list.d/elastic-8.x.list

# Update and install Filebeat
echo "📦 Updating package lists and installing Filebeat..."
apt update && apt install -y filebeat

# Enable and start Filebeat
echo "🚀 Enabling and starting Filebeat..."
systemctl enable filebeat
systemctl start filebeat
systemctl status filebeat --no-pager

# Output installed version
echo -e "\n✅ Installed Filebeat version:"
filebeat version
