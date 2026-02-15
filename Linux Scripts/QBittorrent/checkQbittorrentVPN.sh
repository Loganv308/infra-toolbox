#!/usr/bin/env bash
set -euo pipefail

# Constants
readonly CONTAINER_NAME="qbittorrent"
readonly IP_ENDPOINTS=(
    "https://ipinfo.io/ip"
    "https://api.ipify.org"
    "https://checkip.amazonaws.com"
    "https://tnedi.me"
    "https://api.myip.la"
    "https://wtfismyip.com/text"
)

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Logging
log_success() { echo -e "${GREEN}$1${NC}"; }
log_error() { echo -e "${RED}$1${NC}" >&2; exit 1; }
log_warning() { echo -e "${YELLOW}$1${NC}"; }

# Try endpoints until one works
get_ip_with_retries() {
    local mode=$1  # "local" or "container"
    local ip=""

    for endpoint in "${IP_ENDPOINTS[@]}"; do
        if [ "$mode" = "local" ]; then
            ip=$(curl -s --connect-timeout 5 "$endpoint")
        else
            ip=$(docker exec "$CONTAINER_NAME" curl -s --connect-timeout 5 "$endpoint")
        fi

        if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "$ip"
            return 0
        fi
    done

    return 1
}

# Main check
check_vpn_leak() {
    echo "Getting your local IP..."
    local your_ip
    your_ip=$(get_ip_with_retries "local") || log_error "❌ Failed to get your public IP"
    echo "Your IP: $your_ip"

    echo -e "\nGetting your qBittorrent container IP..."
    local qbit_ip
    qbit_ip=$(get_ip_with_retries "container") || log_error "❌ Failed to get qBittorrent container IP"
    echo "qBittorrent IP: $qbit_ip"

    if [ "$your_ip" == "$qbit_ip" ]; then
        log_error "⚠️  IPs match! VPN is NOT working. Your IP is exposed through qBittorrent!"
    else
        log_success "✅ IPs are different. VPN is active for qBittorrent!"
    fi
}

check_vpn_leak
