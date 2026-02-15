#!/bin/bash

# Target SIEM IP
SIEM_IP="<SIEM-IP>"
SIEM_PORT="5044"

# Backup existing config
cp /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.bak

# Generate minimal Filebeat config
cat <<EOF > /etc/filebeat/filebeat.yml
filebeat.inputs:
  - type: log
    enabled: true
    paths:
      - /var/log/syslog
      - /var/log/auth.log

output.logstash:
  hosts: ["$SIEM_IP:$SIEM_PORT"]

setup.template.enabled: false
EOF

# Set correct permissions
chmod 640 /etc/filebeat/filebeat.yml

# Restart Filebeat
systemctl restart filebeat
systemctl enable filebeat

