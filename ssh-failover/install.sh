
#!/usr/bin/env bash
# PROMPTED BY ME. IMPLEMENTED BY AI & SI.

set -Eeuo pipefail
echo "Installing SSH Failover..."

# Configuration
REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/ssh-failover"
SYSTEMD_DIR="/etc/systemd/system"
RUN_USER="${SUDO_USER:-root}"

# Check root and systemd
if [[ "$EUID" -ne 0 ]]; then
    echo "Run: sudo $0"
    exit 1
fi

if [[ ! -d /run/systemd/system ]]; then
    echo "ERROR: systemd is not running."
    exit 1
fi

# Detect Linux distribution
source /etc/os-release
DISTRO="${ID,,}"

# Check repository files
for file in \
    src/hosts.conf \
    src/ssh-failover \
    src/ssh-failover-manager \
    src/ssh-failover.service
do
    [[ -f "$REPO_DIR/$file" ]] || {
        echo "ERROR: Missing $file"
        exit 1
    }
done

# Install dependencies if missing
if ! command -v socat >/dev/null || \
   { ! command -v nc >/dev/null && ! command -v ncat >/dev/null; }; then

    echo "Installing socat and Netcat..."

    case "$DISTRO" in
        fedora)
            dnf install -y socat nmap-ncat
            ;;
        ubuntu|debian|linuxmint|pop)
            apt-get update >> /dev/null
            apt-get install -y socat netcat-openbsd
            ;;
        *)
            echo "ERROR: Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
fi

# Verify dependencies
command -v socat >/dev/null || {
    echo "ERROR: socat installation failed."
    exit 1
}

if ! command -v nc >/dev/null && ! command -v ncat >/dev/null; then
    echo "ERROR: Netcat installation failed."
    exit 1
fi

# Check service user
id "$RUN_USER" >/dev/null 2>&1 || {
    echo "ERROR: User $RUN_USER does not exist."
    exit 1
}

# Create directories
install -d -m 755 \
    "$INSTALL_DIR" \
    "$CONFIG_DIR" \
    "$SYSTEMD_DIR"

# Install scripts
install -m 755 "$REPO_DIR/src/ssh-failover" \
    "$INSTALL_DIR/ssh-failover"

install -m 755 "$REPO_DIR/src/ssh-failover-manager" \
    "$INSTALL_DIR/ssh-failover-manager"

# Install configuration without overwriting existing file
if [[ ! -f "$CONFIG_DIR/hosts.conf" ]]; then
    install -m 644 "$REPO_DIR/src/hosts.conf" \
        "$CONFIG_DIR/hosts.conf"
else
    echo "Existing hosts.conf preserved"
fi

# Install systemd service
sed "s|@RUN_USER@|$RUN_USER|g" \
    "$REPO_DIR/src/ssh-failover.service" \
    > "$SYSTEMD_DIR/ssh-failover.service"

chmod 644 "$SYSTEMD_DIR/ssh-failover.service"

# Enable and start service
systemctl daemon-reload
systemctl enable ssh-failover.service
systemctl restart ssh-failover.service
sleep 3

echo
echo "SSH Failover installed successfully."
echo "Service: systemctl status ssh-failover.service"