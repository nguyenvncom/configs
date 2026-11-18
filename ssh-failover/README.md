# SSH Failover

CONTENT PROMPTED BY ME. IMPLEMENTED BY AI & SI.

Automatically connect to remote Linux servers through LAN or VPN using SSH failover.

## 1. Install

Clone the repository:

```bash
git clone https://github.com/nguyenvncom/configs.git
cd configs/ssh-failover
```

Run the installer:

```bash
chmod +x install.sh
sudo bash ./install.sh
```

The installer automatically:
- Detects the Linux distribution.
- Installs `socat` and Netcat if missing.
- Installs SSH Failover scripts and systemd service.
- Creates the configuration directory.
- Enables and starts the service.

## 2. Configure SSH Client

Configure SSH client (e.g. Termius) to connect through the local SSH Failover listener.

Example configuration:

| Setting           | Value                         |
|-------------------|-------------------------------|
| Address           | IP, hostname, domain, etc.
| Port              | 2222, 2223, 2224, etc.
| Username          | Your remote SSH username.
| Authentication    | Password, private key, etc.

The `hostname`, `domain` must resolve to `127.0.0.1` on the local machine. Add the following entry to `/etc/hosts` if necessary:

```text
127.0.0.1 YourHostname YourDomain.com
```

The local port (`2222`, `2223`, `2224`, etc) must match the corresponding `LOCAL_PORT` in `/etc/ssh-failover/hosts.conf`.

SSH Failover automatically selects:
- **LAN** when the remote server is reachable through the local network.
- **VPN** when the LAN connection is unavailable.

## 3. Uninstall

Run the uninstaller:

```bash
chmod +x uninstall.sh
sudo bash ./uninstall.sh
```

The uninstaller removes:
- SSH Failover scripts.
- Systemd service.
- SSH Failover configuration.

**Note:** Installed packages (`socat`, `netcat`, etc.) are preserved and will not be removed.