#!/bin/bash
# Removes RPiZero Task Manager.   Run:  sudo bash uninstall.sh
# Leaves SSH and any overclock alone (set the overclock back to Stock first if you changed it).
# Your visitor logs in ~/visitor-logs are kept.
[ "$(id -u)" -eq 0 ] || { echo "Please run with sudo:  sudo bash uninstall.sh"; exit 1; }
USER_NAME="${SUDO_USER:-$(getent passwd 1000 | cut -d: -f1)}"
USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"

/usr/local/bin/rpizero-helper led stop >/dev/null 2>&1
systemctl disable --now rpizero-taskmgr.service 2>/dev/null
systemctl disable --now rpizero-fallback-ap.service 2>/dev/null
rm -f /etc/systemd/system/rpizero-taskmgr.service /etc/systemd/system/rpizero-fallback-ap.service
systemctl daemon-reload 2>/dev/null
nmcli con delete RPIZERO-OPEN 2>/dev/null
rm -f /etc/NetworkManager/dispatcher.d/90-rpizero-led /etc/rpizero-taskmgr.conf
rm -rf /opt/rpizero-taskmgr "$USER_HOME/.config/rpizero-taskmgr"
rm -f /usr/local/bin/rpizero-taskmgr /usr/local/bin/rpizero-helper /usr/local/sbin/rpizero-fallback-ap
rm -f /etc/sudoers.d/rpizero-taskmgr
echo "RPiZero Task Manager removed. Your visitor logs in $USER_HOME/visitor-logs were kept."
if command -v tailscale >/dev/null; then
    echo "Tailscale was left installed (other programs may use it). To remove it:  sudo apt remove tailscale"
fi
