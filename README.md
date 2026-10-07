<div align="center">

# Clarity Makcu V2.8 — Cracked

**Hardwareless AI aimbot. No MAKCU board. No license. Any key works.**

[![Platform](https://img.shields.io/badge/Platform-Windows%2010%2F11-blue)](#)
[![Python](https://img.shields.io/badge/Python-3.10-yellow)](#)
[![Status](https://img.shields.io/badge/Status-Cracked-brightgreen)](#)

**cracked by sassylol**

</div>

---

## What is this?

**Clarity Makcu V2.8** is a neural-network AI aimbot. The license check has been
removed — the app no longer contacts the real auth servers. It talks to a local
mock server instead, so **any key you type is accepted**.

This runs fully **hardwareless** (the "MAKCU" USB device is optional). It works
out of the box on Windows — no paid key, no account, no extra board.

---

## 📹 Watch the tutorial

**▶ [Clarity Hardwareless Tutorial](clarity_hardwareless_tutorial.mp4)**

Click to watch in GitHub's player, or download the `.mp4`. Covers the full
setup end to end.

---

## Features

- AI aimbot (ONNX models, DirectML GPU accelerated)
- Aimbot / triggerbot / anti-recoil / FOV circle / target boxes & tracers
- Neural preview (live detection overlay)
- Stream-proof mode
- Multiple input methods: **SendInput**, **GamePadEmu**, serial proxy, RP2040 HID, MAKCU (1-PC & 2-PC), DS4
- Supported games: CS2, Fortnite, Blood Strike, Roblox, Marvel Rivals

---

## Requirements

- Windows 10 / 11 (64-bit)
- Internet for the one-time dependency install

---

## Setup (first time only)

1. Run **`installs.bat`** as administrator.
2. It installs Python 3.10, VC++ redist, PyTorch / onnxruntime, PyQt5, bettercam,
   and the rest. Takes a few minutes and downloads a few GB. Let it finish.
3. When it says **"Installation completed"** — done.

---

## How to run

1. Double-click **`crack.bat`** → click **Yes** on the admin prompt.
2. Loader window → leave the hardware boxes unchecked → click **Start**.
3. Key window → type **anything** (e.g. `123`) → **Verify Key**.
4. Main window opens. Load your game config, launch the game, hold the aim hotkey.

> No key required — the license check is cracked.

---

## Games & configs

| Game           | Config file            | Model                |
|----------------|------------------------|----------------------|
| CS2            | `config.json`          | `cs2.onnx`           |
| Fortnite       | `insane fortnite.json` | `fortnite.onnx`      |
| Blood Strike   | `bloodstrike.json`     | `universal.onnx`     |
| Roblox         | —                      | `roblox.onnx`        |
| Marvel Rivals  | —                      | `marvel rivals.onnx` |

In the main window: **Load Config** → pick the file for your game.

---

## ⚠️ GamePadEmu / SendInput — read this

- The AI **defaults to SendInput** even when you select **GamePadEmu**.
- To use the controller input, go to **Misc** and switch the input method to **GamePadEmu**.
- The default/preset configs **revert back to SendInput** when loaded. If your aim
  silently stops working, go back into **Misc** and switch it back to **GamePadEmu**.
- Any config made **before** switching to GamePadEmu needs the same fix.

---

## Using a controller (GamePadEmu + AntiMicroX)

The aim only turns on while you **hold** the Aim Hotkey. A controller can't press
a keyboard key by itself, so map a key onto a controller button with the free tool
**AntiMicroX**.

1. Download AntiMicroX: <https://github.com/AntiMicroX/antimicrox/releases> — install and open it with your controller plugged in.
2. Pick a button/trigger you don't use much, and bind a keyboard key to it (e.g. **K**).
3. In the aimbot: **AI AIMBOT → AIMBOT tab → Aim Hotkey** → click the box and press that same key (**K**).
4. Holding that controller trigger = holding **K** = aim turns on.

Leave AntiMicroX running in the background while you play.

---

## Quick smoke test (no game needed)

Tick **Neural Preview** in the main window and point your screen at a person/player
image. If detection boxes draw around the body, the model + capture + GPU are all
working. Then open your game and hold the aim hotkey.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `Python 3.10 not found` | Run `installs.bat` first |
| Aim not tracking | Check **Misc → input method = GamePadEmu** (see note above) |
| `onnxruntime` error | Re-run `installs.bat` (auto-fixes the gpu/directml conflict) |
| Nothing captured | Run the game in borderless/fullscreen, **not** exclusive fullscreen |

---

## Notes

- The folder is portable — place it anywhere and run `crack.bat`.
- The "license server" is faked on `127.0.0.1`, so the app never reaches the real
  servers and never needs a real key.
- Every copy is identical — share the folder and it works out of the box.

---

<div align="center">

**cracked by sassylol** · for educational use on your own machine

</div>
