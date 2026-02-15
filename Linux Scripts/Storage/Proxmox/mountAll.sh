#!/bin/bash
# Script to mount CIFS shares on Proxmox host and bind them into ALL unprivileged LXC containers.

CRED_FILE="/etc/samba/nas-credentials"

# CIFS shares (mounted once on host, bind-mounted into every container)
declare -a SHARES=(
  "//192.168.1.69/MediaDrive   /mnt/NASMedia"
  "//192.168.1.69/PictureDrive /mnt/PictureBackup"
  "//192.168.1.69/FileDrive    /mnt/FileDrive"
  "//192.168.1.69/NFSConfigs   /mnt/NFSConfigs"
)

# --- Step 1: Ensure CIFS mounts on Proxmox host ---
for entry in "${SHARES[@]}"; do
  set -- $entry
  CIFS_PATH=$1
  HOST_MOUNT=$2

  # Create mount dir if missing
  if [ ! -d "$HOST_MOUNT" ]; then
    mkdir -p "$HOST_MOUNT"
    echo "Created $HOST_MOUNT"
  fi

  # Add CIFS mount to /etc/fstab if not already present
  if ! grep -q "$CIFS_PATH" /etc/fstab; then
    echo "$CIFS_PATH $HOST_MOUNT cifs credentials=$CRED_FILE,rw,iocharset=utf8,vers=3.0 0 0" >> /etc/fstab
    echo "Added $CIFS_PATH to /etc/fstab"
  fi

  # Mount now
  mount "$HOST_MOUNT" || echo "Warning: Could not mount $CIFS_PATH"
done

# --- Step 2: Detect all LXC container IDs automatically ---
CONTAINERS=$(pct list | awk 'NR>1 {print $1}')

# --- Step 3: Bind mounts into each container ---
for CTID in $CONTAINERS; do
  INDEX=0
  for entry in "${SHARES[@]}"; do
    set -- $entry
    HOST_MOUNT=$2
    pct set "$CTID" -mp${INDEX} "$HOST_MOUNT,mp=$HOST_MOUNT"
    echo "Bound $HOST_MOUNT into container $CTID as mp${INDEX}"
    INDEX=$((INDEX + 1))
  done
done

echo "✅ All shares mounted on host and bound into ALL containers
