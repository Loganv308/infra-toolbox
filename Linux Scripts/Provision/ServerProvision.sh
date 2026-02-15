#!/bin/bash
# List of environment variables that will be setup
env_vars=("TRUSTEDIP" "SMBUSERNAME" "SMBPASSWORD")

# Trusted Lan network that will be applied to other firewall rules
TRUSTED_IP="192.168.1.0/24"

# Log File Location
LOGFILE="./"${HOSTNAME}"_Provision_Log.log"

# Timestamp format
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Services port list
PORT_LIST=(
    "8096"
    "5055"
    "3001"
    "8081"
    "8989"
    "7878"
    "3000"
    "9898"
)

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
# Exit on any error
set -e
# Creates log file
sudo touch "$LOGFILE"
# Makes sure the log file is executable
sudo chown "$USER":"$USER" "$LOGFILE"

# Runs APT maintenance (apt update, apt upgrade, etc.)
packageMaintenance() {

    echo "[$TIMESTAMP] Starting APT maintenance" | tee -a "$LOGFILE"

    # Install updates to freshly imaged Server
    sudo apt update && sudo apt dist-upgrade && sudo apt full-upgrade -y | tee -a "$LOGFILE"

    sudo apt autoremove -y | tee -a "$LOGFILE"

    echo "[$TIMESTAMP] APT maintenance completed successfully" | tee -a "$LOGFILE" 

    printf "\n" | tee -a "$LOGFILE" 
} 

# Sets up all the firewall rules including 
firewallSetup() {
    # installs ufw
    sudo apt install -y ufw

    # Set default policies
    sudo ufw default deny incoming
    sudo ufw default allow outgoing

    # Allow Nginx Proxy Manager UI only from your trusted IP or subnet
    echo "🔐 Allowing Nginx Proxy Manager UI (port 81) from $TRUSTED_IP"
    sudo ufw allow from "$TRUSTED_IP" to any port 81 proto tcp

    # Allow Tailscale subnet full access (if you want limited ports, modify this line)
    echo "🔐 Allowing full access from Tailscale subnet (100.64.0.0/10)"
    sudo ufw allow from 100.64.0.0/10

    # Allow for SSH into this PC
    sudo ufw allow ssh

    # Allowing various service IPs for docker containers
    echo "Allowing access to docker container ports. For future ports, add them below or do "ufw allow <port>""

    for port in "${PORT_LIST[@]}"; do
        sudo ufw allow "$port"
    done

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
}
    
setupFileMounts() {
    sudo apt-get install cifs-utils

    touch ~/.smbcredentials

    cd ~/

    echo "username=yourUsername\npassword=yourPassword" >> .smbcredentials
}

setupEnvVariables() {
    source ./setupEnv.sh

    for env in "${env_vars[@]}"; do
        echo "Environment Variable set: $env=${!env}"
    done
}

packageMaintenance
# setupEnvVariables
# setupFileMounts
# firewallSetup
