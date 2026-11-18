
#!/usr/bin/env bash

# CONTENT PROMPTED BY ME. IMPLEMENTED BY AI & SI.

set -Eeuo pipefail

echo "Uninstalling SSH Failover..."

if [[ "$EUID" -ne 0 ]]; then
    echo "Please run: sudo bash $0"
    exit 1
fi

SERVICE="ssh-failover.service"

# Stop and disable service
if systemctl list-unit-files "$SERVICE" --no-legend 2>/dev/null |
    grep -q "$SERVICE"; then
    systemctl disable --now "$SERVICE" || true
fi

# Stop any remaining failover processes
pkill -f '^/usr/local/bin/ssh-failover-manager$' 2>/dev/null || true
pkill -f '^/usr/local/bin/ssh-failover([[:space:]]|$)' 2>/dev/null || true

# Remove installed files
rm -f /usr/local/bin/ssh-failover
rm -f /usr/local/bin/ssh-failover-manager
rm -f /etc/systemd/system/ssh-failover.service

# Remove configuration
rm -rf /etc/ssh-failover

# Reload systemd
systemctl daemon-reload
systemctl reset-failed "$SERVICE" 2>/dev/null || true
sleep 3

cat <<EOF
Removed:
  - SSH Failover scripts
  - Systemd service
  - SSH Failover configuration

Preserved:
  - socat
  - Netcat (nc/ncat)
EOF