#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Colors
G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; N='\033[0m'
info() { printf "${G}[*]${N} %s\n" "$*"; }
warn() { printf "${Y}[!]${N} %s\n" "$*"; }
fail() { printf "${R}[x]${N} %s\n" "$*" >&2; exit 1; }

[ -n "${TERMUX_VERSION:-}" ] || fail "Run this inside Termux."

# 1. System
info "Upgrading packages..."
pkg update -y && pkg upgrade -y

# 2. Node.js (latest, NOT LTS)
info "Installing latest Node.js..."
pkg install -y nodejs
node --version

# 3. npm
info "Upgrading npm..."
npm install -g npm@latest

# 4. OpenClaw
info "Installing OpenClaw..."
npm install -g openclaw@latest

# 5. Verify fs-safe version
FS_SAFE_VERSION=$(node -e "console.log(require('$NPM_GLOBAL_ROOT/openclaw/node_modules/@openclaw/fs-safe/package.json').version)")
info "fs-safe version: $FS_SAFE_VERSION"

# 6. Patch fs-safe for Android
info "Patching fs-safe for Android /data permissions..."
NPM_GLOBAL_ROOT="$NPM_GLOBAL_ROOT" node <<'PATCH'
const fs = require('fs');
const path = require('path');

const dist = path.join(process.env.NPM_GLOBAL_ROOT, 'openclaw/node_modules/@openclaw/fs-safe/dist');
if (!fs.existsSync(dist)) { console.log('[!] fs-safe dist not found'); process.exit(0); }

const MARKER = '/* android-uid1000-fix */';
const NEEDLE = 'if (stat.isSymbolicLink())';

const PATCH = `${MARKER}
    if (process.platform === "android" && (stat.uid === 1000 || stat.uid === 1000n)) {
        if (!(stat.mode & 0o002) || (stat.mode & 0o1000)) return;
    }

    `;

for (const f of fs.readdirSync(dist)) {
  if (!f.endsWith('.js')) continue;
  const p = path.join(dist, f);
  let src = fs.readFileSync(p, 'utf8');
  if (src.includes(MARKER)) { console.log(`[=] ${f} already patched`); continue; }
  if (!src.includes(NEEDLE)) continue;
  if (!src.includes('secureTempDirectoryFailure')) continue;
  fs.writeFileSync(p, src.replace(NEEDLE, PATCH + NEEDLE));
  console.log(`[+] patched ${f}`);
}
PATCH

# 7. Hand off to onboarding
info "Done. Launching onboarding..."
echo
mkdir .openclaw
chmod +x $HOME/.openclaw
openclaw onboard
