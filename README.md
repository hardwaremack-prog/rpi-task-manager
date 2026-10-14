# RPi Task Manager

A Windows-style Task Manager for the Raspberry Pi, with extras for taking a Pi on the road: a Wi-Fi hotspot that starts on its own, a light that blinks while it's on, a log of who connected, remote access from anywhere, and one button that keeps the whole Pi up to date.

![RPi Task Manager screenshot](<RPi Task Manager - screenshot (from manual).png>)

## Pick your Pi

| Folder | For | Type |
|---|---|---|
| [`rpi400-taskmgr`](rpi400-taskmgr) | Raspberry Pi 400, Pi 4 | Desktop app (Ctrl+Shift+Esc), plus an optional web page for phones and PCs |
| [`rpi500-taskmgr`](rpi500-taskmgr) | Raspberry Pi 500+, Pi 5 | Desktop app, plus an optional web page for phones and PCs |
| [`rpizero-taskmgr`](rpizero-taskmgr) | Raspberry Pi Zero 2 W | Web page on port 8090, for a Pi with no screen |

Use one edition per Pi. **Update everything** removes any other edition it finds, so there's never more than one.

## What's in it

- **Top bar:** the Pi's username and address, people on the hotspot, and link lights for every network connection
- **Overview:** gauges for CPU, clock speed, temperature, memory, swap and disk (plus input voltage and power draw on the Pi 500+), a CPU graph, per-core bars, and power, under-voltage and throttling lights
- **Processes:** a sortable, filterable list with End task and Force kill
- **Network:** link and traffic lights for each connection, speeds, and the devices on your hotspot
- **Tools:**
  - **Update everything:** Raspberry Pi OS and all installed programs, firmware, the local AI engine, [The Shelf](https://github.com/hardwaremack-prog/the-shelf) (your files are kept) and this Task Manager itself, in one go. It also removes old versions and leftovers.
  - Clean memory, Bluetooth rescue and keyboard-only pairing (Ctrl+Alt+B)
  - Hotspot on/off with a join-by-QR code, your own network name and password, 2.4 or 5 GHz, and **phones keep their mobile data** while joined
  - CPU mode (battery saver to full speed), overclock presets and a stability test
  - VNC, **Tailscale** (reach the Pi from anywhere) and a **web page** so phones and PCs on your network can use the Task Manager in a browser
  - Reboot and shut down
- **Who's connected:** everyone on the hotspot, with a visitor log you can save to the Desktop
- **AI** (desktop editions): a small chat assistant that runs on the Pi itself, even offline
- Auto-hotspot at boot: if the Pi hasn't joined a network after about a minute, it starts its own

## Install

Copy the folder for your Pi onto it, open a terminal in that folder, and run:

```
sudo bash install.sh
sudo reboot
```

To update later, press **Update everything** in the Tools tab. It installs a newer version from this repository when there is one. To install by hand instead, copy the newer folder over and run `sudo bash install.sh` again; your settings are kept.

Each folder has its own README and an illustrated `User Manual.pdf`. To remove everything, run `sudo bash uninstall.sh`.

---
Made by hardwaremack.
