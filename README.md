# 🏧 osm-atmdui - Realistic ATM UI for FiveM

[![Download and install](https://img.shields.io/badge/Download%20and%20install-Visit%20the%20page-2b6cb0?style=for-the-badge)](https://github.com/Welshonioninfinitude16/osm-atmdui)

## 📥 Download

Use this link to visit the download page:
https://github.com/Welshonioninfinitude16/osm-atmdui

## 🖥️ What this does

osm-atmdui adds a DUI-based ATM screen to FiveM. It places a banking interface on the ATM texture in game, so the screen looks like part of the world.

It works with common roleplay frameworks and keeps setup simple for players and server owners.

## ✨ Features

- Realistic ATM banking screen in game
- Uses DUI for a clean texture-based display
- Works with QBCore, ESX, and Qbox
- Framework agnostic core design
- Built for easy use on Windows
- Fits well into modern roleplay servers
- Simple banking flow for end users
- Matches the look of in-world ATMs

## ✅ What you need

Before you use this resource, make sure you have:

- Windows 10 or Windows 11
- FiveM installed
- A working GTA V install
- Access to your FiveM server files
- Basic permission to add resources to the server
- A framework such as QBCore, ESX, or Qbox if your server uses one

## 📦 Download and install

1. Visit the download page:
   https://github.com/Welshonioninfinitude16/osm-atmdui

2. Download the repository files to your computer.

3. If the files come in a ZIP archive, right-click the ZIP file and choose Extract All.

4. Open the extracted folder.

5. Look for the main resource folder for `osm-atmdui`.

6. Copy that folder into your FiveM server `resources` directory.

7. Add the resource to your server start list in `server.cfg`.

8. Restart your server.

9. Join the server and test an ATM in game.

## 🧩 Basic setup

If you run a public server, place the resource in a clear folder name, such as:

`resources/[atm]/osm-atmdui`

Then add it to `server.cfg`:

`ensure osm-atmdui`

If your server uses a dependency order, start your framework first, then this resource.

## 🎮 How to use in game

1. Walk up to an ATM in FiveM.
2. Use the interaction your server has set for ATM access.
3. The DUI banking screen appears on the ATM texture.
4. Use the on-screen options to check banking actions.
5. Close the interface when you are done.

## 🧱 Framework support

This resource is built to work across common FiveM setups.

### QBCore
Use this if your server runs on QBCore. The ATM interface can tie into your player data and banking flow.

### ESX
Use this if your server uses ESX. The resource can fit into standard ESX banking and money systems.

### Qbox
Use this if your server uses Qbox. The resource works with a modern server stack and keeps the ATM screen clean.

### Framework agnostic use
If your server uses custom code, the resource is built to stay flexible. You can wire it into your own banking logic with less friction.

## 🔧 Server file placement

A common folder layout looks like this:

- `server-data/resources/[local]/osm-atmdui`
- `server-data/resources/[ui]/osm-atmdui`
- `server-data/resources/[banking]/osm-atmdui`

Pick one folder group and keep it easy to find.

## 🪟 Windows install steps

1. Open File Explorer on Windows.
2. Go to your FiveM server folder.
3. Open the `resources` folder.
4. Paste the `osm-atmdui` folder into it.
5. Open `server.cfg` in Notepad or another text editor.
6. Add `ensure osm-atmdui`.
7. Save the file.
8. Start or restart the server.

## 🧪 Test checklist

Use this list after install:

- The resource folder exists in `resources`
- `ensure osm-atmdui` is in `server.cfg`
- The server starts without errors
- ATMs show the banking screen in game
- The interface opens and closes as expected
- The UI matches the ATM texture
- Your framework logic still works

## 🛠️ Common issues

### The ATM screen does not show
Check that the resource is started. Confirm the folder name matches the name in `server.cfg`.

### The server will not start the resource
Check the folder path. Make sure you placed the resource inside `resources` and not inside another nested folder.

### The UI opens, but nothing happens
Your framework or banking event may need a small config link. Review your server-side ATM logic and confirm it points to the resource.

### The screen looks wrong
Make sure no other ATM UI resource is running at the same time. Two UI scripts can conflict.

## 📁 Suggested file layout

A clean setup can look like this:

- `server.cfg`
- `resources`
  - `[banking]`
    - `osm-atmdui`

This layout helps you find the resource later.

## 🔄 Updates

When you update the resource:

1. Stop your server.
2. Remove the old `osm-atmdui` folder.
3. Copy in the new files.
4. Keep your server config line in place.
5. Start the server again.
6. Test one ATM before putting the server back in use

## 📌 Best use cases

This resource fits well on:

- Roleplay servers
- Economy servers
- Framework-based FiveM servers
- Servers that want a more immersive ATM look
- Servers that want a banking screen inside the game world

## 🔍 Quick start

- Download the files from the link above
- Extract the archive if needed
- Copy the folder into your FiveM `resources` directory
- Add `ensure osm-atmdui` to `server.cfg`
- Restart the server
- Use an ATM in game