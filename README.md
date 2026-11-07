# termux-openclaw

Installer for OpenClaw on Termux.

## Install from this repository

```sh
pkg update && pkg upgrade
pkg install git
git clone https://github.com/chern744/termux-openclaw.git
cd termux-openclaw
chmod +x install-openclaw.sh
./install-openclaw.sh
```

## Install by copying the script

Create `install-openclaw.sh` in Termux with `nano install-openclaw.sh`, paste in the contents of [`install-openclaw.sh`](install-openclaw.sh), then save with **Ctrl+O**, press **Enter**, and exit with **Ctrl+X**. Then run:

```sh
nano install-openclaw.sh
# Paste the script, save and exit
chmod +x install-openclaw.sh
./install-openclaw.sh
```

## Important

The installer installs the latest Node.js, npm, and OpenClaw releases, and patches a file inside OpenClaw's `@openclaw/fs-safe` package for Android. OpenClaw updates may change those package files or behavior and cause the patch or other parts of this installer to fail. Review the script before running it and back up any important data.
