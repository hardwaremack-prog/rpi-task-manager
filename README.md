# RPi Task Manager

A Windows-style Task Manager for the Raspberry Pi, with extras for taking a Pi on the road: a Wi-Fi hotspot that starts on its own, a light that blinks while it's on, and a log of who connected.

![RPi Task Manager screenshot](<RPi Task Manager - screenshot (from manual).png>)

## Pick your Pi

| Folder | For | Type |
|---|---|---|
| [`rpi400-taskmgr`](rpi400-taskmgr) | Raspberry Pi 400 | Desktop app (Ctrl+Shift+Esc) |
| [`rpi500-taskmgr`](rpi500-taskmgr) | Raspberry Pi 500+ | Desktop app |
| [`rpizero-taskmgr`](rpizero-taskmgr) | Raspberry Pi Zero 2 W | Web page on port 8090, for a Pi with no screen |

## What's in it

- **Overview:** gauges for CPU, clock speed, temperature, memory, swap and disk, a CPU graph, per-core bars, and power, under-voltage and throttling lights
- **Processes:** a sortable, filterable list with End task and Force kill
- **Network:** link and traffic lights for each connection, speeds, and the devices on your hotspot
- **Tools:** clean memory, Bluetooth rescue and pairing, hotspot on/off with a join-by-QR code, CPU mode (battery saver to full speed), overclock presets, stability test, VNC, Tailscale, reboot and shut down
- **Who's connected:** everyone on the hotspot, with a visitor log you can save to the Desktop
- Auto-hotspot at boot: if the Pi hasn't joined a network after about a minute, it starts its own

## Install

Copy the folder for your Pi onto it, open a terminal in that folder, and run:

```
sudo bash install.sh
sudo reboot
```

Each folder has its own README and an illustrated `User Manual.pdf`. To remove everything, run `sudo bash uninstall.sh`.

---
Made by hardwaremack.
