#!/usr/bin/env bash
set -e

CTID="$1"

if [[ -z "$CTID" ]]; then
  echo "Usage: $0 <CTID>"
  exit 1
fi

CONF="/etc/pve/lxc/${CTID}.conf"

if [[ ! -f "$CONF" ]]; then
  echo "❌ Container config not found: $CONF"
  exit 1
fi

echo "▶ Enabling TUN support for container $CTID"

# Ensure tun module exists on host
if [[ ! -e /dev/net/tun ]]; then
  echo "▶ /dev/net/tun not found on host — loading tun module"
  modprobe tun
fi

# Create device node if needed
mkdir -p /dev/net
if [[ ! -e /dev/net/tun ]]; then
  mknod /dev/net/tun c 10 200
  chmod 666 /dev/net/tun
fi

# Add config entries if missing
grep -q "lxc.cgroup2.devices.allow: c 10:200 rwm" "$CONF" || \
  echo "lxc.cgroup2.devices.allow: c 10:200 rwm" >> "$CONF"

grep -q "/dev/net/tun" "$CONF" || \
  echo "lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file" >> "$CONF"

echo "▶ Restarting container $CTID"
pct restart "$CTID"

echo "▶ Verifying inside container..."
pct exec "$CTID" -- ls -l /dev/net/tun

echo "✅ TUN successfully enabled for CT $CTID"
