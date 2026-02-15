#!/bin/bash

# Create the primary group 'dan' with GID 1001 (if it doesn't exist)
if ! getent group dan >/dev/null; then
    groupadd -g 1001 dan
fi

# Create the user 'dan' with UID 1001 and GID 1001
if ! id -u dan >/dev/null 2>&1; then
    useradd -m -u 1001 -g 1001 -s /bin/bash dan
fi

# Ensure the extra groups exist
for grp in sudo users docker; do
    if ! getent group "$grp" >/dev/null; then
        groupadd "$grp"
    fi
done

# Add dan to the groups
usermod -aG sudo,users,docker dan

echo "User 'dan' created/updated successfully!"
id dan
