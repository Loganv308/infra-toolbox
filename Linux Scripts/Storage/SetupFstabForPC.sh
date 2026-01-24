#!/usr/bin/env bash
echo "Setting up FStab..."

# NAS Local IP
NASIP="192.168.1.69"

# File Array
files=("NASMedia" "FileDrive" "PictureBackup")

# fstab entries appending to /etc/fstab file
fstab_entries=(
"//192.168.1.69/MediaDrive   /mnt/NASMedia      cifs  credentials=/etc/samba/nas-credentials,iocharset=utf8,vers=3.1.1,_netdev,nofail  0  0"
"//192.168.1.69/PictureDrive /mnt/PictureBackup cifs  credentials=/etc/samba/nas-credentials,iocharset=utf8,vers=3.1.1,_netdev,nofail  0  0"
"//192.168.1.69/FileDrive /mnt/FileDrive cifs credentials=/etc/samba/nas-credentials,iocharset=utf8,vers=3.1.1,uid=logan,gid=logan,rw,_netdev,nofail 0 0"
)

# Check if files exist for mounts, if not, create them. 
for file in ${files[@]}; do
    # -d means directory, -f for files. 
    if [[ ! -d /mnt/${file} ]]; then
        mkdir /mnt/${file}
        echo "▶ Folder /mnt/${file} has been made." 
    else
        echo "▶ Folders already created at /mnt/${file}"
    fi
done

echo "▶ All folders created."

for entry in "${fstab_entries[@]}"; do
    # Extract the mount point (2nd field)
    mount_point=$(echo "$entry" | awk '{print $2}')
    
    # Check if the mount point is already in /etc/fstab
    if ! grep -q "^[^#]*$mount_point" /etc/fstab; then
        echo "$entry" | sudo tee -a /etc/fstab
        echo "▶ Added $mount_point to /etc/fstab"
    else
        echo "▶ $mount_point already exists in /etc/fstab, skipping."
    fi
done

# Mount all fstab entries
sudo mount -a
echo "▶ All mounts checked."