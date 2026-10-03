# RPiZero Task Manager (web edition)

> The full illustrated guide is in **User Manual.pdf** in this folder.

A Task Manager for the **Raspberry Pi Zero 2 W** that runs as a small web page, so you can watch and control a Pi with no screen from any phone, tablet or laptop on the same network. It has the same features as the RPi400 and RPi500+ desktop editions, apart from the ones the Zero's hardware can't support (see below).

## Install

Use **Raspberry Pi OS Lite (Bookworm or newer)**. Copy this folder to the Pi (for example with `scp` or a USB stick), then over SSH:

```
cd rpizero-taskmgr
sudo bash install.sh
sudo reboot
```

The installer asks you to choose a **control password**. Then open **http://&lt;pi address&gt;:8090** in a browser.

The installer:

- installs the web page as a background service that starts at every boot, on port 8090
- creates the **RPIZERO-OPEN** hotspot (password `fifty-seven57`, Pi at `192.168.1.250`, 2.4 GHz)
- turns on **auto-hotspot at boot**: if the Pi hasn't joined a network ~60 s after powering on, it starts the hotspot by itself, so you can always reach it at **http://192.168.1.250:8090**
- makes the green light **flash while the hotspot is on**
- turns on **SSH**

To remove everything: `sudo bash uninstall.sh`. Your visitor logs are kept.

## Who can do what

- **Anyone on the network** can see the stats: gauges, processes, network, and whether the hotspot is on.
- **With the control password** you can use everything else: start or stop the hotspot, see who's connected and the visitor log, disconnect people, clean memory, Bluetooth, CPU mode, overclock, the stability test, ending programs, and reboot or shut down.

Logging in lasts 12 hours on that browser. After 5 wrong passwords in a row, logins pause for a few minutes. To change the password, run `rpizero-taskmgr --set-password` over SSH.

## Tabs

| Tab | What you get |
|---|---|
| **Overview** | Gauges for CPU, clock, temperature, memory, swap and SD card · 2-minute CPU graph · per-core bars · power-warning lights (now and since boot) · system info |
| **Processes** | Sortable list with a filter, plus End and Kill buttons |
| **Network** | LINK / RX / TX lights, speeds and totals per connection · traffic graph |
| **Hotspot** | Start/stop · join-by-QR code · flash-light switch · phones-keep-mobile-data switch · change name & password · who's connected, with Disconnect · visitor log, with downloads |
| **Tools** | Clean memory · Bluetooth rescue and pairing · CPU mode · overclock · stability test · **Tailscale** (reach the Pi from anywhere) · reboot / shut down · activity log |

## Differences from the desktop editions

| | Why |
|---|---|
| **No AI tab** | A useful AI model needs more than the Zero's 512 MB of memory |
| **No 5 GHz switch** | The Zero 2 W's Wi-Fi is 2.4 GHz only |
| **No VNC or keyboard shortcuts** | Lite has no desktop. This web page replaces them, and SSH is on for a terminal |
| **Visitor log in `~/visitor-logs`** | There's no Desktop on Lite. You can also download the log and a report from the Hotspot tab |
| **Green light only** | The Zero 2 W has a single green LED, so that's the one that flashes for the hotspot |

## Good to know

**Power.** Use a 5 V 2.5 A micro-USB supply. The Zero can't measure its battery or input voltage, but the **Power** light shows the Pi's own low-voltage alarm. Red means the supply or cable can't keep up right now.

**Overclock.** The Zero 2 W runs at 1.0 GHz. **1.1 GHz** is mild. **1.2 GHz** is a common, well-tested boost, and a small heatsink helps a lot. After changing the speed and rebooting, run the **Stability test** on the Tools tab. If the Pi freezes during a test, the page tells you which speed caused it the next time it starts. If the Pi won't boot, put the SD card in another computer, open `config.txt`, and delete the lines between the `rpizero-taskmgr overclock` markers.

**Bluetooth.** Scan & pair shows any pairing code in large digits on the page. Type it on the new keyboard and press its Enter key.

**Phones keep their mobile data.** The hotspot has no internet of its own, and normally a phone on Wi-Fi sends everything over it, so apps like Teams go quiet while you're on The Shelf. With **Phones keep their mobile data** on (the default, on the Hotspot tab), the hotspot hands out an address but no route to the internet, so phones use Wi-Fi only for the Pi and their mobile data for everything else. Switch it off only when the Zero itself is online and you want to share that. If a phone still acts offline, forget the network and join again.

**Your own name and password.** On the Hotspot tab, open **✏ Change the network name & password**, type a new name (1–32 characters) and password (8–63), and press Save. If the hotspot is on it restarts, and everyone joins again with the new password. `sudo rpizero-helper ap-set --default` puts back RPIZERO-OPEN / fifty-seven57.

**Reach the Pi from anywhere (Tailscale).** Normally this page only works on the same network as the Zero. Tailscale is a free private network (a "VPN") that links your own devices together wherever they are.
1. Log in on the page, open **Tools**, and flip the **Tailscale** switch. The first time it downloads Tailscale (needs internet, takes a minute or two on the Zero).
2. A QR code and link appear. Open it on your phone and sign in with a Google, Microsoft, Apple or GitHub account (free for up to 100 devices).
3. Install the Tailscale app on your phone or PC and sign in with the **same** account.
4. The Tools card shows the Zero's Tailscale address (starts with `100.`). Open `http://100.x.y.z:8090` from anywhere. SSH works at that address too.

Visitors who aren't logged in never see the sign-in link or the address. You can also join with an auth key (under **More options**, or `sudo TAILSCALE_AUTHKEY=tskey-... bash install.sh`). From a terminal: `sudo rpizero-helper vpn up`, `vpn down`, `vpn logout`. While the Zero runs its own hotspot it has no internet, so Tailscale waits until it's back on a normal network.

**The Shelf.** If you run The Shelf on the Zero, people on the hotspot reach it at `http://192.168.1.250/` and this page at `:8090`. They don't clash.

## Files

| File | Goes to | Role |
|---|---|---|
| `rpizero_taskmgr.py` + `web/index.html` | `/opt/rpizero-taskmgr/` | The web server and the page |
| `rpizero-helper` | `/usr/local/bin/` | Root-only script for the controls (shared with the desktop editions) |
| `rpizero-fallback-ap` + `.service` | `/usr/local/sbin/`, systemd | Starts the hotspot at boot when offline |
| `90-rpizero-led` | `/etc/NetworkManager/dispatcher.d/` | Flashes the green light while the hotspot is up |
| `rpizero-taskmgr.service` | systemd | Runs the web page at boot |
