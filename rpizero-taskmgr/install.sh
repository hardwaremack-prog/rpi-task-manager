#!/bin/bash
# RPiZero Task Manager (web edition) installer, for the Raspberry Pi Zero 2 W
# Run from this folder:   sudo bash install.sh
#
# Optional settings, typed after sudo, e.g.:   sudo WEB_PASSWORD=secret123 bash install.sh
#   WEB_PASSWORD=...     the control password (otherwise you're asked, or one is made up for you)
#   WIFI_COUNTRY=US      Wi-Fi country used only if none is set yet (the hotspot needs it)
#   RZ_PORT=8090         port for the web page
#   TAILSCALE_AUTHKEY=tskey-...   join your Tailscale network straight away (otherwise switch it on in the page)
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run with sudo:   sudo bash install.sh"
    exit 1
fi

USER_NAME="${SUDO_USER:-}"
if [ -z "$USER_NAME" ] || [ "$USER_NAME" = root ]; then
    USER_NAME="$(getent passwd 1000 | cut -d: -f1)"
fi
USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"
WIFI_COUNTRY="${WIFI_COUNTRY:-US}"
RZ_PORT="${RZ_PORT:-8090}"

step() { echo; echo "==> $*"; }
warn() { echo "   ! $*"; }

echo "Installing RPiZero Task Manager (web edition) for user: $USER_NAME"

step "Installing packages"
apt-get update -qq || warn "apt update failed (offline?) — continuing"
apt-get install -y python3-psutil python3-qrcode iw rfkill \
    || apt-get install -y python3-psutil iw rfkill \
    || warn "Some packages didn't install — the app needs python3-psutil"

step "Copying program files"
install -d /opt/rpizero-taskmgr /opt/rpizero-taskmgr/web
install -m 755 "$HERE/rpizero_taskmgr.py" /opt/rpizero-taskmgr/rpizero_taskmgr.py
install -m 644 "$HERE/web/index.html" /opt/rpizero-taskmgr/web/index.html
install -m 755 -o root -g root "$HERE/rpizero-helper" /usr/local/bin/rpizero-helper
install -m 755 -o root -g root "$HERE/rpizero-fallback-ap" /usr/local/sbin/rpizero-fallback-ap
cat > /usr/local/bin/rpizero-taskmgr <<'EOF'
#!/bin/sh
exec python3 /opt/rpizero-taskmgr/rpizero_taskmgr.py "$@"
EOF
chmod 755 /usr/local/bin/rpizero-taskmgr

step "Letting the web page run its root helper without a password prompt"
TMP_SUDO="$(mktemp)"
echo "$USER_NAME ALL=(root) NOPASSWD: /usr/local/bin/rpizero-helper" > "$TMP_SUDO"
if visudo -cf "$TMP_SUDO" >/dev/null; then
    install -m 440 -o root -g root "$TMP_SUDO" /etc/sudoers.d/rpizero-taskmgr
else
    warn "sudo rule failed validation — the controls won't work until this is fixed"
fi
rm -f "$TMP_SUDO"

step "Setting up the RPIZERO-OPEN hotspot (2.4 GHz)"
if command -v nmcli >/dev/null; then
    if command -v raspi-config >/dev/null; then
        CUR_COUNTRY="$(raspi-config nonint get_wifi_country 2>/dev/null || true)"
        if [ -z "$CUR_COUNTRY" ]; then
            raspi-config nonint do_wifi_country "$WIFI_COUNTRY" && echo "   Wi-Fi country set to $WIFI_COUNTRY"
        else
            echo "   Wi-Fi country already set: $CUR_COUNTRY"
        fi
    fi
    /usr/local/bin/rpizero-helper ap-ensure || warn "Couldn't create the hotspot profile"
    install -m 644 "$HERE/rpizero-fallback-ap.service" /etc/systemd/system/rpizero-fallback-ap.service
    systemctl daemon-reload || true
    systemctl enable rpizero-fallback-ap.service >/dev/null 2>&1 || true
    echo "   Auto-hotspot at boot: on (starts ~60 s after boot if there's no network)"
    install -d /etc/NetworkManager/dispatcher.d
    install -m 755 -o root -g root "$HERE/90-rpizero-led" /etc/NetworkManager/dispatcher.d/90-rpizero-led
    grep -qs '^LED_BLINK=' /etc/rpizero-taskmgr.conf || echo "LED_BLINK=1" >> /etc/rpizero-taskmgr.conf
    chmod 644 /etc/rpizero-taskmgr.conf
    echo "   Green light flashes while the hotspot is on: $(/usr/local/bin/rpizero-helper led status)"
else
    warn "NetworkManager isn't in use on this system, so the hotspot is skipped."
    warn "Raspberry Pi OS Bookworm or newer (including Lite) uses it by default."
fi

step "Turning on SSH (for when you need a terminal)"
if command -v raspi-config >/dev/null; then
    raspi-config nonint do_ssh 0 && echo "   SSH is on"
else
    warn "raspi-config not found — enable SSH yourself if you want it"
fi

step "Remote access from anywhere (Tailscale)"
if [ -n "${TAILSCALE_AUTHKEY:-}" ]; then
    if /usr/local/bin/rpizero-helper vpn install >/dev/null && /usr/local/bin/rpizero-helper vpn key "$TAILSCALE_AUTHKEY"; then
        :
    else
        warn "Tailscale setup didn't finish. Switch it on from the Tools tab instead."
    fi
else
    echo "   Switch on Tailscale in the page's Tools tab whenever you want to reach this Pi from anywhere."
fi

step "Control password for the web page"
if [ -f "$USER_HOME/.config/rpizero-taskmgr/web-password.json" ] && [ -z "${WEB_PASSWORD:-}" ]; then
    echo "   Keeping your existing password (change it any time with: rpizero-taskmgr --set-password)"
else
    PW="${WEB_PASSWORD:-}"
    if [ -z "$PW" ] && [ -t 0 ]; then
        while :; do
            read -r -s -p "   Choose a control password (6+ characters): " PW; echo
            read -r -s -p "   Type it again: " PW2; echo
            [ "$PW" = "$PW2" ] && [ "${#PW}" -ge 6 ] && break
            echo "   Those didn't match or were too short. Try again."
        done
    fi
    MADE_UP=""
    if [ -z "$PW" ]; then
        PW="$(python3 -c 'import secrets; print(secrets.token_urlsafe(9))')"
        MADE_UP=1
    fi
    printf '%s\n' "$PW" | sudo -u "$USER_NAME" HOME="$USER_HOME" python3 /opt/rpizero-taskmgr/rpizero_taskmgr.py --set-password >/dev/null
    if [ -n "$MADE_UP" ]; then
        echo "   No password was typed, so one was made for you:  $PW"
        echo "   Write it down. Change it any time with:  rpizero-taskmgr --set-password"
    else
        echo "   Password saved."
    fi
fi

step "Starting the web page now and at every boot"
sed -e "s/@USER@/$USER_NAME/" -e "s#ExecStart=.*#Environment=RZ_PORT=$RZ_PORT\nExecStart=/usr/bin/python3 /opt/rpizero-taskmgr/rpizero_taskmgr.py#" \
    "$HERE/rpizero-taskmgr.service" > /etc/systemd/system/rpizero-taskmgr.service
systemctl daemon-reload || true
systemctl enable rpizero-taskmgr.service >/dev/null 2>&1 || warn "couldn't enable the web service"
systemctl restart rpizero-taskmgr.service >/dev/null 2>&1 || warn "couldn't start the web service right now (it will start at boot)"

IP_NOW="$(hostname -I 2>/dev/null | awk '{print $1}')"
[ -n "$IP_NOW" ] || IP_NOW="this Pi's address"
cat <<EOF

────────────────────────────────────────────────────────
 Done!  RPiZero Task Manager is installed.

 • Open it in any browser on the same network:
       http://${IP_NOW}:${RZ_PORT}
 • No network at boot? After ~60 s the Pi creates Wi-Fi
       RPIZERO-OPEN   password fifty-seven57
   Join it and open  http://192.168.1.250:${RZ_PORT}
   (the green light flashes while that hotspot is on)
 • Anyone can look; the controls need your control password.

 Reboot once to make sure everything starts cleanly:  sudo reboot
────────────────────────────────────────────────────────
EOF
