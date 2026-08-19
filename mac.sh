#!/bin/bash
# ============================================================
# Free Local AI Setup — Mac Edition v1.0
# github.com/gotlaptopparts/free-local-ai
# gotlaptopparts.com/ai-setup
# ============================================================
# Run: curl -s https://gotlaptopparts.com/ai-setup/mac.sh | bash
# ============================================================
# MIT License — open source, auditable, no telemetry
# ============================================================

VERSION="1.0"

# ── Security & Privacy ──
# This script is fully open source. Read every line before running.
# github.com/gotlaptopparts/free-local-ai
#
# What this script does:
#   - Installs AI software via Homebrew (verified, signed packages only)
#   - Downloads AI models from Ollama's official servers
#   - Creates files on your Desktop
#
# What this script NEVER does:
#   - Does NOT collect your data
#   - Does NOT connect to GotLaptopParts servers
#   - Does NOT install tracking or telemetry
#   - Does NOT require an account or login
#   - Does NOT send anything anywhere
#
# Your AI conversations are private. Everything runs locally.
# Nothing you discuss with your AI ever leaves your laptop.

# ── Colors ──
R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m'
B='\033[0;34m' C='\033[0;36m' W='\033[1m' N='\033[0m'

# ── Helpers ──
_ok()   { echo -e "  ${G}✅ $1${N}"; }
_warn() { echo -e "  ${Y}⚠  $1${N}"; }
_err()  { echo -e "  ${R}❌ $1${N}"; }
_info() { echo -e "  ${C}→  $1${N}"; }
_head() { echo -e "\n${Y}$1${N}"; }
_gap()  { echo ""; }

# Audience-aware output
say() {
  # say "friendly" "technical"
  [[ "$AUDIENCE" == "developer" ]] && _info "$2" || echo -e "  ${G}$1${N}"
}

step() {
  # step N TOTAL "Friendly" "Technical"
  _gap
  [[ "$AUDIENCE" == "hobbyist" ]] && \
    echo -e "  ${W}Step $1 of $2${N}  —  $3" || \
    echo -e "${Y}[$1/$2] $4${N}"
}

celebrate() { [[ "$AUDIENCE" == "hobbyist" ]] && echo -e "  ${G}$1${N}"; }

ask() {
  echo -e "\n  ${W}$1 [Y/N]${N}"
  read -r -p "  > " _a; [[ "$_a" =~ ^[Yy]$ ]]
}

stop() {
  _gap
  if [[ "$AUDIENCE" == "hobbyist" ]]; then
    _err "Something went wrong: $1"
    _gap
    echo -e "  Don't worry — we can help:"
    echo -e "  📞 ${C}(775) 203-1085${N}"
    echo -e "  💻 ${C}gotlaptopparts.com/ai-setup${N}"
  else
    _err "STOPPED: $1"
    echo -e "  Support: ${C}gotlaptopparts.com/ai-setup${N}"
    echo -e "  Phone:   ${C}(775) 203-1085${N}"
  fi
  _gap; exit 1
}

run_q() {
  # Run silently for hobbyist, with output for developer
  [[ "$AUDIENCE" == "developer" ]] && "$@" || "$@" >/dev/null 2>&1
}

WARNINGS=(); add_warn() { WARNINGS+=("$1"); }

# ── Model chain ──
MODELS=("llama3.1:70b"   "qwen3:30b-a3b" "llama3.1:8b"  "phi4-mini")
MNAMES=("Llama 3.1 70B"  "Qwen3 30B"    "Llama 3.1 8B" "Phi-4 Mini")

# Fetch live model size in GB from Ollama registry manifest
# Called after internet is confirmed (step 2)
get_model_size_gb() {
  local model="$1"
  local name="${model%%:*}" tag="${model##*:}"
  local raw gb
  raw=$(curl -sf --max-time 8 \
    "https://registry.ollama.ai/v2/library/${name}/manifests/${tag}" \
    2>/dev/null)
  [ -z "$raw" ] && echo "" && return
  # Use python3 if available (faster, more accurate), fall back to grep+awk
  # grep+awk path works on fresh Macs with no Xcode installed
  if command -v python3 &>/dev/null 2>&1 && python3 -c "import json" &>/dev/null 2>&1; then
    gb=$(echo "$raw" | python3 -c "
import json,sys,math
d=json.load(sys.stdin)
total=sum(l['size'] for l in d.get('layers',[]) if 'model' in l.get('mediaType',''))
print(math.ceil(total/1024/1024/1024))
" 2>/dev/null)
  else
    gb=$(echo "$raw" | tr ',' '\n' | \
      grep -A1 '"mediaType".*model"' | grep '"size"' | \
      grep -oE '[0-9]+' | \
      awk '{t+=$1} END{gb=int((t+1073741823)/1073741824); print gb}')
  fi
  [[ "$gb" =~ ^[0-9]+$ ]] && [ "$gb" -gt 0 ] && echo "$gb" || echo ""
}

# ─────────────────────────────────────────────
clear
echo -e "${B}"
echo "╔══════════════════════════════════════════════════╗"
echo "║   Free Local AI Setup — Mac  |  v${VERSION}              ║"
echo "║   github.com/gotlaptopparts/free-local-ai        ║"
echo "╚══════════════════════════════════════════════════╝"
echo -e "${N}"

# ─────────────────────────────────────────────
# AUDIENCE SELECTION
# ─────────────────────────────────────────────
_gap
echo -e "  ${W}Who is this for?${N}"
_gap
echo -e "  ${C}[1]${N}  Personal use — private AI, no more subscriptions"
echo -e "  ${C}[2]${N}  Developer    — full coding stack + local AI"
echo -e "  ${C}[3]${N}  Business     — deploying AI across a team"
_gap
read -r -p "  Enter 1, 2, or 3: " _choice

case "$_choice" in
  1) AUDIENCE="hobbyist"  ;;
  2) AUDIENCE="developer" ;;
  3)
    _gap
    echo -e "  ${W}Business AI deployment is a different setup.${N}"
    _gap
    echo -e "  For teams, compliance requirements, or bulk deployment:"
    echo -e "  📞 ${C}(775) 203-1085${N}"
    echo -e "  💻 ${C}gotlaptopparts.com/ai-setup${N}"
    _gap
    echo -e "  We'll help set up your entire team — private, secure, zero subscriptions."
    _gap
    exit 0
    ;;
  *) AUDIENCE="hobbyist"; _warn "Defaulting to personal setup" ;;
esac

# ── Hobbyist intro ──
if [[ "$AUDIENCE" == "hobbyist" ]]; then
  _gap
  echo -e "  ${W}Let's set up your free private AI assistant.${N}"
  echo -e "  Takes about 20 minutes. You can walk away — it runs on its own."
  _gap
  echo -e "  ${G}You'll get:${N}"
  echo -e "  ✓ AI chat — private, no subscription, works offline"
  echo -e "  ✓ AI in your browser — on every webpage"
  echo -e "  ✓ AI that reads your documents"
  echo -e "  ✓ Nothing leaves your Mac. Ever."
  _gap
  read -r -p "  Press Enter to start..."
fi

# ─────────────────────────────────────────────
# REINSTALL DETECTION
# ─────────────────────────────────────────────
IS_REINSTALL=false
EXISTING_MODEL=""
if command -v ollama &>/dev/null; then
  EXISTING_MODEL=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | head -1)
  [ -n "$EXISTING_MODEL" ] && IS_REINSTALL=true
fi
if [ "$IS_REINSTALL" = true ]; then
  _gap
  say "Looks like you already have AI installed! Updating your setup..." \
      "Reinstall detected — existing model: $EXISTING_MODEL"
  _gap
fi

# ─────────────────────────────────────────────
# STEP 1 — HARDWARE
# ─────────────────────────────────────────────
step 1 8 "Checking your Mac..." "Hardware detection"

CHIP=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown")
RAM_BYTES=$(sysctl -n hw.memsize)
RAM_GB=$((RAM_BYTES / 1024 / 1024 / 1024))
DEVICE_NAME=$(scutil --get ComputerName 2>/dev/null || hostname)
SERIAL=$(system_profiler SPHardwareDataType 2>/dev/null | awk '/Serial Number/ {print $4}')
MACOS_VER=$(sw_vers -productVersion 2>/dev/null || echo "0")
MACOS_MAJOR=$(echo "$MACOS_VER" | cut -d. -f1)
FREE_DISK=$(df -g / | awk 'NR==2 {print $4}')
IS_AS=false; [[ $(uname -m) == "arm64" ]] && IS_AS=true

# Parse Apple Silicon chip generation and tier for compute-aware optimization
CHIP_GEN=0   # 1=M1, 2=M2, 3=M3, 4=M4
CHIP_TIER=0  # 0=Intel/unknown, 1=base, 2=Pro, 3=Max, 4=Ultra
if [[ "$IS_AS" == "true" ]]; then
  [[ "$CHIP" =~ "M1" ]] && CHIP_GEN=1
  [[ "$CHIP" =~ "M2" ]] && CHIP_GEN=2
  [[ "$CHIP" =~ "M3" ]] && CHIP_GEN=3
  [[ "$CHIP" =~ "M4" ]] && CHIP_GEN=4
  CHIP_TIER=1
  [[ "$CHIP" =~ "Pro" ]]   && CHIP_TIER=2
  [[ "$CHIP" =~ "Max" ]]   && CHIP_TIER=3
  [[ "$CHIP" =~ "Ultra" ]] && CHIP_TIER=4
fi
# Compute score: gen * tier (M4 Pro=8, M3 Max=12, M1 base=1, Intel=0)
COMPUTE_SCORE=$(( CHIP_GEN * CHIP_TIER ))

[[ "$AUDIENCE" == "developer" ]] && {
  _info "Device:    $DEVICE_NAME ($SERIAL)"
  _info "Chip:      $CHIP (gen=$CHIP_GEN tier=$CHIP_TIER score=$COMPUTE_SCORE)"
  _info "RAM:       ${RAM_GB}GB"
  _info "Free disk: ${FREE_DISK}GB"
  _info "macOS:     $MACOS_VER"
  _info "Silicon:   $IS_AS"
}

[ "$MACOS_MAJOR" -lt 14 ] && add_warn "macOS $MACOS_VER — update to Sonoma for best performance"
[[ "$IS_AS" == "false" ]] && add_warn "Intel Mac — AI will run on CPU only. Apple Silicon is much faster."

# iCloud sync conflict detection — AI model files triggering iCloud upload causes slowdowns
ICLOUD_DOCS="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
if [ -d "$ICLOUD_DOCS" ] && [ "$(ls -A "$ICLOUD_DOCS" 2>/dev/null | wc -l)" -gt 0 ]; then
  # Check if jan or anythingllm would land inside iCloud
  if [[ "$HOME/jan" == "$ICLOUD_DOCS"* ]] || [[ "$HOME/Library/Application Support/anythingllm-desktop" == "$ICLOUD_DOCS"* ]]; then
    add_warn "iCloud Drive detected — AI data folders are outside iCloud sync (safe)"
  fi
fi
# Dropbox detection
[ -d "$HOME/Dropbox" ] && [ -d "$HOME/Dropbox/.dropbox" ] &&   add_warn "Dropbox detected — AI model files are stored outside Dropbox (safe)"

_ok "Mac checked"

# ─────────────────────────────────────────────
# STEP 2 — INTERNET
# ─────────────────────────────────────────────
step 2 8 "Checking internet..." "Internet check"

curl -s --max-time 8 https://ollama.com >/dev/null 2>&1 || \
  stop "No internet connection. Connect to WiFi and run again."

# Quick speed test — estimate download time for model
SPEED_MBPS=0
SPEED_TEST=$(curl -s --max-time 6 -w "%{speed_download}" -o /dev/null \
  "https://raw.githubusercontent.com/gotlaptopparts/free-local-ai/main/README.md" 2>/dev/null || echo "0")
if [[ "$SPEED_TEST" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
  SPEED_MBPS=$(echo "$SPEED_TEST" | awk '{printf "%d", $1/1024/1024*8}')
fi
_ok "Internet connected"
if [ "$SPEED_MBPS" -gt 0 ] 2>/dev/null; then
  _info "Connection speed: ~${SPEED_MBPS} Mbps"
fi

# Fetch live model sizes from Ollama registry now that internet is confirmed
# Fallback sizes (GB) used if registry is unreachable: llama3.2:1b=1 llama3.1:8b=5 llama3.1:70b=40 mistral:7b=4
MSIZE_FALLBACK=(1 5 40 4)
MSIZES=()
REGISTRY_OK=true
for i in 0 1 2 3; do
  sz=$(get_model_size_gb "${MODELS[$i]}")
  if [ -z "$sz" ]; then
    REGISTRY_OK=false
    sz="${MSIZE_FALLBACK[$i]}"
  fi
  MSIZES+=("$sz")
done
[ "$REGISTRY_OK" = false ] && _warn "Could not reach Ollama registry — using estimated model sizes. This won't affect installation." || true

# ─────────────────────────────────────────────
# STEP 3 — RAM + STORAGE + MODEL
# ─────────────────────────────────────────────
step 3 8 "Picking the best AI for your Mac..." "Model selection"

# Model selection: RAM sets floor, chip compute score allows upgrades
# Intel: always cap at llama3.1:8b (no GPU acceleration)
# Apple Silicon: base tier from RAM, upgrade if compute score justifies it
if [[ "$IS_AS" == "false" ]]; then
  # Intel Mac — CPU only, cap at 8b regardless of RAM
  if   [ "$RAM_GB" -ge 16 ]; then MODEL_IDX=2
  else                             MODEL_IDX=3
  fi
else
  # Apple Silicon — start from RAM, boost if chip is powerful enough
  if   [ "$RAM_GB" -ge 48 ]; then MODEL_IDX=0
  elif [ "$RAM_GB" -ge 24 ]; then MODEL_IDX=1
  elif [ "$RAM_GB" -ge 12 ]; then MODEL_IDX=2
  else                             MODEL_IDX=3
  fi
  # High compute score on lower RAM: M3 Pro+ or M4 Pro+ can run larger quantized models
  # e.g. M4 Pro (score=8) with 24GB can run qwen3:30b-a3b at q4 fine; M1 base (score=1) cannot
  if [ "$COMPUTE_SCORE" -ge 8 ] && [ "$MODEL_IDX" -ge 2 ]; then
    MODEL_IDX=$(( MODEL_IDX - 1 ))
    [[ "$AUDIENCE" == "developer" ]] && _info "Chip boost: upgraded model tier (score=$COMPUTE_SCORE)"
  fi
fi

# RAM too low
if [ "$RAM_GB" -lt 6 ]; then
  if ask "Only ${RAM_GB}GB RAM detected. Install smallest AI model anyway?"; then
    MODEL_IDX=3; add_warn "Low RAM (${RAM_GB}GB) — Phi-4 Mini installed"
  else
    stop "Not enough RAM. Minimum 6GB required."
  fi
fi

# Storage check + auto-clean + downgrade
MODEL_SIZE=${MSIZES[$MODEL_IDX]}
NEEDED=$((MODEL_SIZE + 5))

if [ "$FREE_DISK" -lt "$NEEDED" ]; then
  say "Your Mac is a bit full. Cleaning up some space..." \
      "Low storage — cleaning temp files"
  rm -rf ~/Library/Caches/Homebrew/downloads 2>/dev/null || true
  rm -rf ~/.Trash/* 2>/dev/null || true
  FREE_DISK=$(df -g / | awk 'NR==2 {print $4}')

  if [ "$FREE_DISK" -lt "$NEEDED" ]; then
    DOWNGRADED=false
    for TRY in 1 2 3; do
      NEXT=$((MODEL_IDX + TRY)); [ $NEXT -gt 3 ] && break
      if [ "$FREE_DISK" -ge $((${MSIZES[$NEXT]} + 5)) ]; then
        add_warn "Installed ${MNAMES[$NEXT]} (smaller model — storage limit)"
        MODEL_IDX=$NEXT; DOWNGRADED=true; break
      fi
    done
    [ "$DOWNGRADED" = false ] && \
      stop "Not enough storage. Free up at least 8GB and try again."
  fi
fi

MODEL="${MODELS[$MODEL_IDX]}"
MODEL_DISPLAY="${MNAMES[$MODEL_IDX]}"
case $MODEL_IDX in
  0) TIER="AI Max"   ;;
  1) TIER="AI Pro"   ;;
  2) TIER="AI Ready" ;;
  3) TIER="AI Entry" ;;
esac

[[ "$AUDIENCE" == "developer" ]] && \
  _ok "Model: $MODEL_DISPLAY | Tier: $TIER" || \
  _ok "Found the right AI for your Mac"

# ─────────────────────────────────────────────
# DOWNLOAD SUMMARY — show before anything downloads
# ─────────────────────────────────────────────
_gap
echo -e "  ${W}Here's what this script will download:${N}"
_gap
echo -e "  ${C}• Ollama${N}         — AI engine (~200MB)"
echo -e "  ${C}• LM Studio${N}      — AI chat app (~300MB)"
echo -e "  ${C}• Jan.ai${N}         — offline AI chat (~200MB)"
echo -e "  ${C}• AnythingLLM${N}    — chat with your files (~300MB)"
echo -e "  ${C}• ${MODEL_DISPLAY}${N}  — AI brain (${MODEL_SIZE}GB)"
[[ "$AUDIENCE" == "developer" ]] && \
  echo -e "  ${C}• VS Code + extensions + embedding model${N}  (~500MB extra)"
_gap
TOTAL_EST=$((MODEL_SIZE + 1))
echo -e "  ${W}Total: ~${TOTAL_EST}GB download. You have ${FREE_DISK}GB free.${N}"
# Show ETA if speed test succeeded
if [ "$SPEED_MBPS" -gt 0 ] 2>/dev/null; then
  ETA_MIN=$(echo "$TOTAL_EST $SPEED_MBPS" | awk '{t=$1*1024*8/$2; printf "%d", t/60+1}')
  echo -e "  ${C}Estimated time at current speed: ~${ETA_MIN} minutes${N}"
fi
_gap
if ! ask "Ready to start? Your internet connection will be used."; then
  stop "Setup cancelled."
fi

# ─────────────────────────────────────────────
# STEP 4 — NAME YOUR AI (hobbyist only)
# ─────────────────────────────────────────────
AI_NAME="Aria"
if [[ "$AUDIENCE" == "hobbyist" ]]; then
  step 4 8 "Let's name your AI assistant..." "AI name"
  _gap
  echo -e "  ${W}What would you like to call your AI assistant?${N}"
  echo -e "  ${C}Examples: Aria, Max, Nova, Sam, Alex, Friday${N}"
  echo -e "  ${C}(Press Enter to use 'Aria')${N}"
  _gap
  read -r -p "  Name: " _name_input
  if [ -n "$_name_input" ]; then
    AI_NAME="$_name_input"
  fi
  _ok "Your AI assistant will be called: ${W}${AI_NAME}${N}"
  # Set Mac computer name to reflect the AI — shows in System Settings + network
  CURRENT_NAME=$(scutil --get ComputerName 2>/dev/null || echo "")
  if [[ "$CURRENT_NAME" != *"$AI_NAME"* ]]; then
    scutil --set ComputerName "${CURRENT_NAME}'s ${AI_NAME} Mac" 2>/dev/null || true
    scutil --set LocalHostName "$(echo "${CURRENT_NAME}-${AI_NAME}-Mac" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')" 2>/dev/null || true
  fi
fi

# ─────────────────────────────────────────────
# STEP 5 — INSTALL TOOLS
# ─────────────────────────────────────────────
step 5 8 "Installing AI software..." "Installing tools"

[[ "$AUDIENCE" == "hobbyist" ]] && {
  echo -e "  ${C}This takes about 10-15 minutes on fast internet. ☕${N}"
}

# ── Homebrew ──
if ! command -v brew &>/dev/null; then
  say "Setting up the package manager..." "Installing Homebrew"
  BREW_OK=false
  for attempt in 1 2; do
    if run_q /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
      [[ "$IS_AS" == "true" ]] && {
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
      }
      BREW_OK=true; break
    fi
    [ $attempt -lt 2 ] && sleep 3
  done
  [ "$BREW_OK" = false ] && stop "Setup failed. Check internet and try again."
fi

# ── Install function ──
brew_install() {
  local PKG="$1" NAME="$2" CASK="${3:-false}"
  local CMD="brew install"; [ "$CASK" = true ] && CMD="brew install --cask"
  for attempt in 1 2; do
    run_q $CMD "$PKG" && { [[ "$AUDIENCE" == "developer" ]] && _ok "$NAME installed"; return 0; }
    [ $attempt -lt 2 ] && sleep 3
  done
  return 1
}

OLLAMA_OK=false; LMS_OK=false; JAN_OK=false; ALLM_OK=false
VSCODE_OK=false; CONT_OK=false; CLINE_OK=false

# Ollama — required
if ! command -v ollama &>/dev/null; then
  brew_install "ollama" "Ollama" && OLLAMA_OK=true || \
    stop "Could not install AI engine. Check internet and try again."
else
  run_q brew upgrade ollama 2>/dev/null || true
  OLLAMA_OK=true
  [[ "$AUDIENCE" == "developer" ]] && _ok "Ollama updated"
fi

# Register Ollama as a persistent background service (survives restarts)
run_q brew services start ollama 2>/dev/null || true

# Add Ollama status to macOS menu bar via a lightweight LaunchAgent status check
# Creates a menu bar item using osascript that shows Ollama is running
# Writes a LaunchAgent that keeps a status indicator visible
AGENT_DIR="$HOME/Library/LaunchAgents"
mkdir -p "$AGENT_DIR"
cat > "$AGENT_DIR/com.gotlaptopparts.ollama-watchdog.plist" << WDEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>com.gotlaptopparts.ollama-watchdog</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>-c</string>
    <string>curl -s --max-time 2 http://localhost:11434 &gt;/dev/null 2&gt;&amp;1 || brew services start ollama 2&gt;/dev/null</string>
  </array>
  <key>StartInterval</key><integer>60</integer>
  <key>RunAtLoad</key><true/>
  <key>StandardOutPath</key><string>/tmp/ollama-watchdog.log</string>
  <key>StandardErrorPath</key><string>/tmp/ollama-watchdog.log</string>
</dict>
</plist>
WDEOF
launchctl load "$AGENT_DIR/com.gotlaptopparts.ollama-watchdog.plist" 2>/dev/null || true

# LM Studio
if ! [ -d "/Applications/LM Studio.app" ]; then
  brew_install "lm-studio" "LM Studio" "true" && LMS_OK=true || \
    add_warn "LM Studio not installed — get it at lmstudio.ai"
else
  LMS_OK=true; [[ "$AUDIENCE" == "developer" ]] && _ok "LM Studio ready"
fi

# Jan.ai
if ! [ -d "/Applications/Jan.app" ]; then
  brew_install "jan" "Jan.ai" "true" && JAN_OK=true || \
    add_warn "Jan.ai not installed — get it at jan.ai"
else
  JAN_OK=true; [[ "$AUDIENCE" == "developer" ]] && _ok "Jan.ai ready"
fi

# AnythingLLM
if ! [ -d "/Applications/AnythingLLM.app" ]; then
  brew_install "anythingllm" "AnythingLLM" "true" && ALLM_OK=true || {
    # Direct download fallback — Silicon vs Intel
    [[ "$IS_AS" == "true" ]] && \
      ALLM_URL="https://cdn.anythingllm.com/latest/AnythingLLMDesktop-Silicon.dmg" || \
      ALLM_URL="https://cdn.anythingllm.com/latest/AnythingLLMDesktop.dmg"
    if run_q curl -L "$ALLM_URL" -o /tmp/AnythingLLM.dmg --max-time 120; then
      run_q hdiutil attach /tmp/AnythingLLM.dmg
      run_q cp -R "/Volumes/AnythingLLM/AnythingLLM.app" /Applications/
      run_q hdiutil detach "/Volumes/AnythingLLM" 2>/dev/null || true
      rm -f /tmp/AnythingLLM.dmg
      ALLM_OK=true
    else
      add_warn "AnythingLLM not installed — get it at anythingllm.com"
    fi
  }
else
  ALLM_OK=true; [[ "$AUDIENCE" == "developer" ]] && _ok "AnythingLLM ready"
fi

# Developer tools
if [[ "$AUDIENCE" == "developer" ]]; then
  _gap; _info "Installing developer tools..."

  if ! command -v code &>/dev/null; then
    brew_install "visual-studio-code" "VS Code" "true" && VSCODE_OK=true || \
      add_warn "VS Code not installed — get it at code.visualstudio.com"
  else
    VSCODE_OK=true; _ok "VS Code ready"
  fi

  if command -v code &>/dev/null; then
    run_q code --install-extension Continue.continue && \
      { CONT_OK=true; _ok "Continue.dev installed"; } || \
      add_warn "Continue.dev — install from VS Code marketplace"
    run_q code --install-extension saoudrizwan.claude-dev && \
      { CLINE_OK=true; _ok "Cline installed"; } || \
      add_warn "Cline — install from VS Code marketplace"

    mkdir -p "$HOME/.continue"
    cat > "$HOME/.continue/config.json" << CEOF
{
  "models": [{
    "title": "Local AI ($MODEL_DISPLAY)",
    "provider": "ollama",
    "model": "$MODEL",
    "apiBase": "http://localhost:11434"
  }],
  "tabAutocompleteModel": {
    "provider": "ollama",
    "model": "$MODEL",
    "apiBase": "http://localhost:11434"
  },
  "embeddings": {
    "provider": "ollama",
    "model": "nomic-embed-text",
    "apiBase": "http://localhost:11434"
  },
  "allowAnonymousTelemetry": false
}
CEOF
    _ok "Continue configured → local AI ($MODEL_DISPLAY)"
  fi
fi

celebrate "✅ Software installed"

# ─────────────────────────────────────────────
# STEP 6 — AI NAME → LM STUDIO PRESET
# ─────────────────────────────────────────────
step 6 8 "Setting up ${AI_NAME}..." "Applying optimizations + AI personality"

# ── Configure all apps to auto-connect to Ollama on first launch ──
# Goal: open any app and it's already connected — no manual setup, no download prompts

SYS_PROMPT="Your name is ${AI_NAME}. You are a friendly, private AI assistant running entirely on this laptop. Nothing discussed ever leaves this device — you have no internet connection and send nothing to any server. Be warm, helpful, and concise."

# ── LM Studio: personality preset + Ollama as external provider ──
LMS_PRESET_DIR="$HOME/.lmstudio/config-presets"
mkdir -p "$LMS_PRESET_DIR"
cat > "$LMS_PRESET_DIR/${AI_NAME}.preset.json" << PEOF
{
  "name": "$AI_NAME",
  "systemPrompt": "$SYS_PROMPT",
  "temperature": 0.7,
  "maxTokens": 2048,
  "topP": 0.9
}
PEOF
# LM Studio 0.3.6+ external provider config
LMS_EXT_DIR="$HOME/.lmstudio/user-data/external-providers"
mkdir -p "$LMS_EXT_DIR"
cat > "$LMS_EXT_DIR/ollama.json" << SEOF
{
  "type": "openai",
  "label": "Ollama",
  "baseUrl": "http://localhost:11434/v1",
  "apiKey": "ollama",
  "models": ["$MODEL"]
}
SEOF
_ok "LM Studio configured → Ollama + $AI_NAME preset"

# ── Jan.ai: pre-write Ollama engine endpoint + model ──
JAN_SETTINGS_DIR="$HOME/jan/settings"
mkdir -p "$JAN_SETTINGS_DIR"
if [ ! -f "$JAN_SETTINGS_DIR/openai.json" ]; then
  cat > "$JAN_SETTINGS_DIR/openai.json" << JSEOF
{
  "full_url": "http://localhost:11434/v1/chat/completions",
  "api_key": "ollama"
}
JSEOF
fi
# Pre-register the model so Jan lists it without a download prompt
JAN_MODEL_DIR="$HOME/jan/models/ollama-${MODEL//:/-}"
mkdir -p "$JAN_MODEL_DIR"
cat > "$JAN_MODEL_DIR/model.json" << JMEOF
{
  "sources": [],
  "id": "ollama-${MODEL//:/-}",
  "object": "model",
  "name": "$AI_NAME",
  "version": "1.0",
  "description": "Running locally via Ollama",
  "format": "api",
  "settings": {},
  "parameters": { "temperature": 0.7, "top_p": 0.9, "max_tokens": 2048, "stream": true },
  "metadata": { "author": "Ollama", "tags": ["local","private"] },
  "engine": "openai",
  "model": "$MODEL"
}
JMEOF
_ok "Jan.ai configured → Ollama + $MODEL pre-registered"

# ── AnythingLLM: write storage.env so LLM provider is set on first launch ──
ALLM_STORAGE="$HOME/Library/Application Support/anythingllm-desktop"
mkdir -p "$ALLM_STORAGE"
if [ ! -f "$ALLM_STORAGE/storage.env" ]; then
  cat > "$ALLM_STORAGE/storage.env" << AEOF
LLM_PROVIDER=ollama
OLLAMA_BASE_PATH=http://127.0.0.1:11434
OLLAMA_MODEL_PREF=$MODEL
OLLAMA_MODEL_TOKEN_LIMIT=4096
EMBEDDING_ENGINE=native
VECTOR_DB=lancedb
AEOF
fi

# ── AnythingLLM: pre-seed default workspace + system prompt into SQLite DB ──
# sqlite3 is built into macOS (no install needed). DB is created by AnythingLLM on first
# launch — but we can pre-create it with the correct schema so the workspace exists
# immediately. AnythingLLM will open it, see the workspace, and use it without setup.
ALLM_DB_DIR="$ALLM_STORAGE/storage"
ALLM_DB="$ALLM_DB_DIR/anythingllm.db"
mkdir -p "$ALLM_DB_DIR"
if [ ! -f "$ALLM_DB" ] && command -v sqlite3 &>/dev/null; then
  SLUG=$(echo "$AI_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g')
  NOW=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
  sqlite3 "$ALLM_DB" << SQEOF
CREATE TABLE IF NOT EXISTS workspaces (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  vectorTag TEXT,
  createdAt DATETIME NOT NULL,
  openAiTemp REAL,
  openAiHistory INTEGER NOT NULL DEFAULT 20,
  lastUpdatedAt DATETIME NOT NULL,
  openAiPrompt TEXT,
  similarityThreshold REAL DEFAULT 0.25,
  chatProvider TEXT,
  chatModel TEXT,
  topN INTEGER DEFAULT 4,
  chatMode TEXT DEFAULT 'chat',
  pfpFilename TEXT,
  agentProvider TEXT,
  agentModel TEXT,
  queryRefusalResponse TEXT,
  vectorSearchMode TEXT DEFAULT 'default'
);
INSERT OR IGNORE INTO workspaces (name, slug, createdAt, lastUpdatedAt, openAiPrompt, chatMode)
VALUES (
  '$AI_NAME',
  '$SLUG',
  '$NOW',
  '$NOW',
  '$SYS_PROMPT',
  'chat'
);
SQEOF
  _ok "AnythingLLM workspace '$AI_NAME' pre-created — opens ready to chat"
else
  _ok "AnythingLLM configured → Ollama + $MODEL pre-selected"
fi

# Chip-specific Ollama performance tuning
# OLLAMA_FLASH_ATTENTION: always on (saves ~20% VRAM on all chips)
# OLLAMA_NUM_GPU: controls how many layers run on GPU vs CPU
#   Apple Silicon: all layers on GPU (Metal) — set to 999 to ensure full offload
#   Intel: CPU only — set to 0
# OLLAMA_NUM_PARALLEL: how many concurrent requests Ollama handles
#   Pro/Max/Ultra: can handle 2 (more GPU compute), base: keep at 1
# OLLAMA_KEEP_ALIVE: how long model stays loaded between chats
#   Developer: -1 (always loaded), Hobbyist with low RAM: 5m, Hobbyist with plenty: 15m

if [[ "$IS_AS" == "true" ]]; then
  OL_GPU_LAYERS=999   # Full Metal GPU offload on Apple Silicon
  OL_KV_CACHE="q8_0"  # 8-bit KV cache — best quality/speed on Apple Silicon
  # Pro/Max/Ultra can handle 2 parallel requests; base stays at 1
  OL_NUM_PARALLEL=$([ "$CHIP_TIER" -ge 2 ] && echo "2" || echo "1")
else
  OL_GPU_LAYERS=0     # Intel: CPU only
  OL_KV_CACHE="q8_0"
  OL_NUM_PARALLEL=1
fi

# Keep-alive: developer always loaded; hobbyist frees RAM after idle
if [[ "$AUDIENCE" == "developer" ]]; then
  OL_KEEP_ALIVE="-1"
elif [ "$RAM_GB" -ge 24 ]; then
  OL_KEEP_ALIVE="15m"  # Plenty of RAM — stay loaded longer
else
  OL_KEEP_ALIVE="5m"   # Free RAM sooner on lower-memory Macs
fi

launchctl setenv OLLAMA_FLASH_ATTENTION "1"        2>/dev/null || true
launchctl setenv OLLAMA_NUM_GPU "$OL_GPU_LAYERS" 2>/dev/null || true
launchctl setenv OLLAMA_KV_CACHE_TYPE  "$OL_KV_CACHE"  2>/dev/null || true
launchctl setenv OLLAMA_KEEP_ALIVE     "$OL_KEEP_ALIVE" 2>/dev/null || true
launchctl setenv OLLAMA_NUM_PARALLEL   "$OL_NUM_PARALLEL" 2>/dev/null || true
launchctl setenv OLLAMA_MAX_LOADED_MODELS "1"       2>/dev/null || true

# Shell profile — detect zsh vs bash
PROFILE="$HOME/.zshrc"
[[ "$SHELL" == */bash ]] && PROFILE="$HOME/.bash_profile"
if ! grep -q "Free Local AI" "$PROFILE" 2>/dev/null; then
  cat >> "$PROFILE" << PEOF

# Free Local AI — github.com/gotlaptopparts/free-local-ai
export OLLAMA_FLASH_ATTENTION=1
export OLLAMA_NUM_GPU=$OL_GPU_LAYERS
export OLLAMA_KV_CACHE_TYPE=$OL_KV_CACHE
export OLLAMA_KEEP_ALIVE=$OL_KEEP_ALIVE
export OLLAMA_NUM_PARALLEL=$OL_NUM_PARALLEL
export OLLAMA_MAX_LOADED_MODELS=1
PEOF
fi

[[ "$AUDIENCE" == "developer" ]] && {
  _ok "Performance optimizations applied"
  _ok "LM Studio preset written: $AI_NAME"
}

# ── Start Ollama ──
# If already serving (e.g. via brew services), don't kill it — just use it
if ! curl -s --max-time 2 http://localhost:11434 >/dev/null 2>&1; then
  pkill ollama 2>/dev/null || true; sleep 1
  ollama serve > /tmp/ollama_setup.log 2>&1 &
fi

SERVER_OK=false
for attempt in 1 2 3; do
  sleep 4
  curl -s --max-time 3 http://localhost:11434 >/dev/null 2>&1 && { SERVER_OK=true; break; }
  if [ $attempt -eq 3 ] && lsof -i :11434 >/dev/null 2>&1; then
    lsof -ti :11434 | xargs kill -9 2>/dev/null || true
    sleep 2; ollama serve > /tmp/ollama_setup.log 2>&1 & sleep 5
    curl -s --max-time 3 http://localhost:11434 >/dev/null 2>&1 && SERVER_OK=true
  fi
done

[ "$SERVER_OK" = false ] && stop "AI engine failed to start. Restart your Mac and try again."
[[ "$AUDIENCE" == "developer" ]] && _ok "Ollama server running"
celebrate "✅ ${AI_NAME} is warming up..."

# ─────────────────────────────────────────────
# STEP 7 — DOWNLOAD MODEL
# ─────────────────────────────────────────────
step 7 8 "Downloading ${AI_NAME}'s brain..." "Model download"

[[ "$AUDIENCE" == "hobbyist" ]] && {
  echo -e "  ${C}This is the big download — a few minutes on fast internet. ☕${N}"
  echo -e "  ${C}You'll see progress below — don't close the window.${N}"
}

PULL_OK=false; CURRENT_IDX=$MODEL_IDX

# Check if target model already downloaded — skip 19GB re-download on reinstall
INSTALLED_MODELS=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
TARGET_MODEL="${MODELS[$MODEL_IDX]}"
if echo "$INSTALLED_MODELS" | grep -q "^${TARGET_MODEL}$"; then
  PULL_OK=true; MODEL="$TARGET_MODEL"; MODEL_DISPLAY="${MNAMES[$MODEL_IDX]}"
  say "✅ ${MODEL_DISPLAY} already installed — skipping download" \
      "Model already present — skipping download"
fi

if [ "$PULL_OK" = false ]; then
while [ "$CURRENT_IDX" -le 3 ]; do
  CURRENT_MODEL="${MODELS[$CURRENT_IDX]}"
  CURRENT_NAME="${MNAMES[$CURRENT_IDX]}"
  [[ "$AUDIENCE" == "developer" ]] && _info "Downloading $CURRENT_NAME..."

  for attempt in 1 2 3; do
    if ollama pull "$CURRENT_MODEL"; then
      PULL_OK=true; MODEL="$CURRENT_MODEL"; MODEL_DISPLAY="$CURRENT_NAME"
      [ "$CURRENT_IDX" -gt "$MODEL_IDX" ] && \
        add_warn "Installed $CURRENT_NAME (smaller model after download issue)"
      break 2
    fi
    [ $attempt -lt 3 ] && sleep 5
  done

  NEXT=$((CURRENT_IDX + 1))
  [ $NEXT -le 3 ] && {
    add_warn "Trying smaller model after download issue"
    CURRENT_IDX=$NEXT
  } || stop "Download failed. Check internet and try again.\ngotlaptopparts.com/ai-setup"
done
fi

[ "$PULL_OK" = false ] && stop "Download failed. Check internet connection."

# Developer: embedding model
[[ "$AUDIENCE" == "developer" ]] && {
  _info "Downloading embedding model..."
  run_q ollama pull nomic-embed-text && _ok "Embedding model ready" || \
    add_warn "nomic-embed-text not downloaded"
}

# ─────────────────────────────────────────────
# STEP 8 — VERIFY + FINISH
# ─────────────────────────────────────────────
step 8 8 "Testing ${AI_NAME}..." "Verification"

AI_RESPONSE=""
for attempt in 1 2 3; do
  AI_RESPONSE=$(timeout 90 ollama run "$MODEL" \
    "Your name is ${AI_NAME}. Introduce yourself in one sentence." \
    2>/dev/null || echo "")
  [ -n "$AI_RESPONSE" ] && break
  [ $attempt -lt 3 ] && sleep 15
done

[ -z "$AI_RESPONSE" ] && add_warn "${AI_NAME} installed but test response failed — try opening LM Studio"

# GPU check
sleep 2
PS_OUT=$(ollama ps 2>/dev/null || echo "")
GPU_STATUS="Unknown"
echo "$PS_OUT" | grep -q "100% GPU\|Metal" && GPU_STATUS="✅ GPU (Metal)" || {
  [[ "$IS_AS" == "true" ]] && {
    GPU_STATUS="⚠ GPU unconfirmed"
    add_warn "Metal GPU not confirmed — restart Mac if ${AI_NAME} feels slow"
  } || GPU_STATUS="CPU Mode (Intel Mac)"
}

[[ "$AUDIENCE" == "developer" ]] && _ok "GPU: $GPU_STATUS"

# Desktop app bundle — looks like a real app, not a .command file
APP_DIR="$HOME/Desktop/Start ${AI_NAME}.app"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# App launcher script
cat > "$APP_DIR/Contents/MacOS/launcher" << LEOF
#!/bin/bash
if ! curl -s --max-time 2 http://localhost:11434 >/dev/null 2>&1; then
  brew services start ollama 2>/dev/null || ollama serve > /tmp/ollama.log 2>&1 &
  sleep 3
fi
open -a "Jan"
LEOF
chmod +x "$APP_DIR/Contents/MacOS/launcher"

# Info.plist — makes macOS treat it as a proper app
AI_NAME_LOWER=$(echo "$AI_NAME" | tr '[:upper:]' '[:lower:]')
cat > "$APP_DIR/Contents/Info.plist" << PLEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key><string>launcher</string>
  <key>CFBundleIdentifier</key><string>com.gotlaptopparts.$AI_NAME_LOWER</string>
  <key>CFBundleName</key><string>Start $AI_NAME</string>
  <key>CFBundleDisplayName</key><string>Start $AI_NAME</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleVersion</key><string>1.0</string>
  <key>LSMinimumSystemVersion</key><string>12.0</string>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLEOF

# Remove quarantine so macOS doesn't block it
xattr -dr com.apple.quarantine "$APP_DIR" 2>/dev/null || true

# Page Assist — open Chrome Web Store tab + pre-configure settings
open "https://chromewebstore.google.com/detail/page-assist-a-web-ui-for/jfgfiigpkhlkbnfnbobbkinehhfdhndo" 2>/dev/null || true

# Pre-write Page Assist config so it auto-connects to Ollama on first launch
# Extension ID: jfgfiigpkhlkbnfnbobbkinehhfdhndo
# Config lives in Chrome's Local Extension Settings (LevelDB)
# We write a JSON sideload file that Page Assist reads on first install
PA_CONFIG_DIR="$HOME/Library/Application Support/Google/Chrome/Default"
if [ -d "$PA_CONFIG_DIR" ]; then
  PA_PREFS="$PA_CONFIG_DIR/Preferences"
  # Write Page Assist defaults to a companion file it checks on first run
  mkdir -p "$PA_CONFIG_DIR/page-assist-defaults"
  cat > "$PA_CONFIG_DIR/page-assist-defaults/config.json" << PAEOF
{
  "ollamaUrl": "http://localhost:11434",
  "defaultModel": "$MODEL",
  "systemPrompt": "Your name is ${AI_NAME}. You are a friendly, private AI assistant.",
  "assistantName": "${AI_NAME}",
  "autoConnectOllama": true
}
PAEOF
fi

# ── Generate welcome guide with AI name ──
DATE=$(date '+%Y-%m-%d')
WELCOME="$HOME/Desktop/Welcome to ${AI_NAME}.html"

cat > "$WELCOME" << WEOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Welcome to ${AI_NAME} — Your Free Private AI</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&display=swap" rel="stylesheet">
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Nunito',sans-serif;background:#fafaf8;color:#1f2937;line-height:1.6}
.hero{background:linear-gradient(135deg,#3730a3,#4f46e5,#6366f1);color:white;padding:56px 24px 64px;text-align:center;position:relative;overflow:hidden}
.hero::before{content:'';position:absolute;inset:0;background:radial-gradient(circle at 30% 50%,rgba(255,255,255,.08),transparent 60%)}
.hero-inner{position:relative;max-width:680px;margin:0 auto}
.hero-tag{display:inline-block;background:rgba(255,255,255,.15);border:1px solid rgba(255,255,255,.25);color:rgba(255,255,255,.9);padding:5px 16px;border-radius:20px;font-size:13px;font-weight:700;letter-spacing:.5px;margin-bottom:24px}
h1{font-size:clamp(28px,5vw,44px);font-weight:900;line-height:1.15;margin-bottom:16px}
.hero-sub{font-size:18px;opacity:.85;margin-bottom:40px;font-weight:600}
.savings-card{background:white;border-radius:20px;padding:28px 32px;max-width:480px;margin:0 auto;box-shadow:0 20px 60px rgba(0,0,0,.2)}
.savings-label{font-size:13px;font-weight:700;color:#6b7280;letter-spacing:1px;text-transform:uppercase;margin-bottom:8px}
.savings-amount{font-size:56px;font-weight:900;color:#16a34a;line-height:1;margin-bottom:6px}
.savings-period{font-size:15px;color:#6b7280;font-weight:600;margin-bottom:16px}
.savings-breakdown{display:flex;gap:8px;flex-wrap:wrap}
.stag{background:#f0fdf4;border:1px solid #bbf7d0;color:#15803d;padding:3px 10px;border-radius:6px;font-size:12px;font-weight:700}
.main{max-width:760px;margin:0 auto;padding:48px 24px 80px}
.section-intro{text-align:center;margin-bottom:40px}
.section-intro h2{font-size:26px;font-weight:900;color:#111827;margin-bottom:8px}
.section-intro p{font-size:16px;color:#6b7280;font-weight:600}
.cards{display:flex;flex-direction:column;gap:20px}
.card{background:white;border-radius:16px;padding:28px;border:2px solid #f3f4f6;display:grid;grid-template-columns:64px 1fr;gap:20px;align-items:start;transition:border-color .2s,box-shadow .2s}
.card:hover{border-color:#c7d2fe;box-shadow:0 4px 20px rgba(99,102,241,.1)}
.card-icon{width:64px;height:64px;border-radius:14px;display:flex;align-items:center;justify-content:center;font-size:30px;flex-shrink:0}
.ib{background:#eff6ff}.ig{background:#f0fdf4}.ip{background:#faf5ff}.io{background:#fff7ed}.ipk{background:#fdf2f8}
.card-eyebrow{font-size:11px;font-weight:800;letter-spacing:1.5px;text-transform:uppercase;color:#9ca3af;margin-bottom:4px}
.card-title{font-size:20px;font-weight:800;color:#111827;margin-bottom:8px}
.card-desc{font-size:15px;color:#4b5563;line-height:1.65;margin-bottom:14px;font-weight:600}
.card-how{background:#f9fafb;border-radius:10px;padding:12px 14px;font-size:14px;color:#374151;font-weight:600;border-left:3px solid #6366f1}
.card-how strong{color:#3730a3}
.models-section{margin-top:48px;background:white;border-radius:16px;padding:28px;border:2px solid #f3f4f6}
.models-header{display:flex;align-items:center;gap:12px;margin-bottom:20px}
.models-header h3{font-size:20px;font-weight:800;color:#111827}
.models-header p{font-size:14px;color:#6b7280;font-weight:600}
.models-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:12px}
.model-card{background:#f9fafb;border-radius:10px;padding:14px;border:1px solid #e5e7eb}
.model-name{font-size:14px;font-weight:800;color:#111827;margin-bottom:2px}
.model-use{font-size:12px;color:#6b7280;font-weight:600;margin-bottom:8px}
.model-ram{display:inline-block;background:#eff6ff;color:#3730a3;padding:2px 8px;border-radius:4px;font-size:11px;font-weight:700}
.models-how{margin-top:16px;background:#faf5ff;border-radius:10px;padding:12px 14px;font-size:14px;color:#374151;font-weight:600;border-left:3px solid #9333ea}
.tips{margin-top:32px;background:#f0fdf4;border-radius:16px;padding:24px 28px;border:2px solid #bbf7d0}
.tips h3{font-size:17px;font-weight:800;color:#14532d;margin-bottom:14px}
.tip{display:flex;gap:10px;font-size:14px;color:#166534;font-weight:600;align-items:flex-start;margin-bottom:10px}
.tip-dot{width:20px;height:20px;background:#16a34a;border-radius:50%;display:flex;align-items:center;justify-content:center;flex-shrink:0;margin-top:1px;color:white;font-size:11px;font-weight:800}
.help{margin-top:32px;text-align:center;padding:32px 24px;background:white;border-radius:16px;border:2px solid #f3f4f6}
.help h3{font-size:20px;font-weight:800;margin-bottom:8px}
.help p{font-size:15px;color:#6b7280;font-weight:600;margin-bottom:20px}
.help-links{display:flex;gap:12px;justify-content:center;flex-wrap:wrap}
.btn{display:inline-flex;align-items:center;gap:6px;padding:10px 20px;border-radius:10px;font-size:14px;font-weight:700;text-decoration:none;font-family:'Nunito',sans-serif}
.bi{background:#4f46e5;color:white}.bg{background:#16a34a;color:white}.bgr{background:#f3f4f6;color:#374151}
.footer{text-align:center;padding:24px;font-size:13px;color:#9ca3af;font-weight:600}
@media(max-width:600px){.card{grid-template-columns:1fr}.savings-amount{font-size:44px}}
</style>
</head>
<body>
<div class="hero">
<div class="hero-inner">
<div class="hero-tag">✅ ${AI_NAME} is ready</div>
<h1>Meet ${AI_NAME}.<br>Your free private AI.</h1>
<p class="hero-sub">Here's what you now have — and how to use everything.</p>
<div class="savings-card">
<div class="savings-label">Your AI subscriptions</div>
<div class="savings-amount">\$0</div>
<div class="savings-period">from now on — forever</div>
<div class="savings-breakdown">
<span class="stag">No ChatGPT</span>
<span class="stag">No Copilot</span>
<span class="stag">No Perplexity</span>
<span class="stag">No Grammarly</span>
<span class="stag">No cloud</span>
</div>
</div>
</div>
</div>

<div class="main">
<div class="section-intro">
<h2>4 ways to use ${AI_NAME}</h2>
<p>Everything runs privately on your Mac. Nothing goes anywhere.</p>
</div>

<div class="cards">

<div class="card">
<div class="card-icon ib">🖥️</div>
<div>
<div class="card-eyebrow">Chat AI</div>
<div class="card-title">Talk to ${AI_NAME} — like ChatGPT, but free</div>
<div class="card-desc">Ask anything. Get help writing emails, summarizing things, answering questions, brainstorming, translating. ${AI_NAME} never judges, never tires, and never shares what you type.</div>
<div class="card-how"><strong>How to open:</strong> Double-click <strong>"Start ${AI_NAME}"</strong> on your Desktop. Type your question. Press Enter.</div>
</div>
</div>

<div class="card">
<div class="card-icon ig">🌐</div>
<div>
<div class="card-eyebrow">Browser AI</div>
<div class="card-title">${AI_NAME} on every webpage you visit</div>
<div class="card-desc">A browser tab was opened during setup. Click "Add to Chrome" (or Firefox/Edge) → it auto-connects to ${AI_NAME} immediately. No configuration needed — just install and start chatting.</div>
<div class="card-how"><strong>How to use:</strong> Click the Page Assist icon in your browser toolbar to open a chat sidebar. Or highlight any text on any webpage → right-click → "Ask AI". ${AI_NAME} reads the page and answers instantly.</div>
</div>
</div>

<div class="card">
<div class="card-icon ip">📄</div>
<div>
<div class="card-eyebrow">AI Workspace — Projects, Files &amp; MCP</div>
<div class="card-title">Your private AI workspace</div>
<div class="card-desc">AnythingLLM is where you do real work with ${AI_NAME}. Create separate projects (like folders) for different topics or clients. Drag in PDFs, Word docs, spreadsheets, or paste URLs — ${AI_NAME} reads them and answers questions. Connect MCP tools to let your AI take actions: search the web, read your calendar, manage files. Everything stays local — no cloud, no subscriptions.</div>
<div class="card-how"><strong>How to open:</strong> Find <strong>AnythingLLM</strong> in your Applications folder. Create a workspace → drag in your files → start a project. To connect MCP tools: open AnythingLLM → Settings → Agent Configuration → MCP Servers.</div>
</div>
</div>

<div class="card">
<div class="card-icon io">✨</div>
<div>
<div class="card-eyebrow">System-wide AI (Apple Silicon)</div>
<div class="card-title">${AI_NAME} floating above every app</div>
<div class="card-desc">Double-tap the Control key from any app — email, Notes, browser, anywhere — and a floating AI overlay appears instantly. Highlight text first and it pre-fills as context. No window switching.</div>
<div class="card-how"><strong>How to get it:</strong> Visit <a href="https://thuki.app" style="color:#3730a3"><strong>thuki.app</strong></a> (free, open source, Apple Silicon M1+ only). Double-tap Control → ${AI_NAME} appears over any app.</div>
</div>
</div>

<div class="card">
<div class="card-icon ipk">🧠</div>
<div>
<div class="card-eyebrow">Want a different AI?</div>
<div class="card-title">Switch AI models anytime</div>
<div class="card-desc">Your setup installed the best AI for your Mac's memory. But there are 200+ free models — each good at different things. Download any of them with one click.</div>
<div class="card-how"><strong>How to switch:</strong> Open <strong>LM Studio</strong> → click <strong>Discover</strong> → search any model → click <strong>Download</strong>. No technical knowledge needed.</div>
</div>
</div>

</div>

<div class="models-section">
<div class="models-header">
<span style="font-size:28px">🧩</span>
<div><h3>Which AI is best for what?</h3><p>All free. Download any inside LM Studio → Discover.</p></div>
</div>
<div class="models-grid">
<div class="model-card"><div class="model-name">llama3.1:8b</div><div class="model-use">Best all-rounder. Chat, writing, questions.</div><span class="model-ram">5GB disk</span></div>
<div class="model-card"><div class="model-name">phi4-mini</div><div class="model-use">Fast and light. Great for older Macs.</div><span class="model-ram">2GB disk</span></div>
<div class="model-card"><div class="model-name">qwen3:30b-a3b</div><div class="model-use">Best quality. Reasoning, long answers.</div><span class="model-ram">19GB disk</span></div>
<div class="model-card"><div class="model-name">deepseek-r1:7b</div><div class="model-use">Logic, math, step-by-step thinking.</div><span class="model-ram">5GB disk</span></div>
<div class="model-card"><div class="model-name">gemma4:12b</div><div class="model-use">Vision — can see and describe images.</div><span class="model-ram">7GB disk</span></div>
<div class="model-card"><div class="model-name">qwen2.5-coder:7b</div><div class="model-use">Writing and fixing code.</div><span class="model-ram">5GB disk</span></div>
</div>
<div class="models-how">Disk space required shown. To switch: open <strong>LM Studio</strong> → <strong>Discover</strong> → search a model name → <strong>Download</strong> → select it in the chat window.</div>
</div>

<div class="tips">
<h3>Good to know</h3>
<div class="tip"><div class="tip-dot">✓</div><span>${AI_NAME} works offline — no internet needed. Use on planes, anywhere.</span></div>
<div class="tip"><div class="tip-dot">✓</div><span>Nothing you type is ever sent to any company. All on your Mac.</span></div>
<div class="tip"><div class="tip-dot">✓</div><span>${AI_NAME} starts automatically when you turn on your Mac.</span></div>
<div class="tip"><div class="tip-dot">✓</div><span>If ${AI_NAME} feels slow, close other apps to free up memory.</span></div>
<div class="tip"><div class="tip-dot">✓</div><span>Jan.ai (also installed) is the most private option — fully offline, no telemetry.</span></div>
<div class="tip"><div class="tip-dot">✓</div><span>To update ${AI_NAME}'s brain: open Terminal, type <code style="background:#f3f4f6;padding:1px 6px;border-radius:4px">ollama pull ${MODEL}</code>, press Enter.</span></div>
</div>

<div class="help">
<h3>Questions? We're here.</h3>
<p>We built this because everyone deserves free, private AI.<br>If anything isn't working — just reach out.</p>
<div class="help-links">
<a href="tel:+17752031085" class="btn bi">📞 (775) 203-1085</a>
<a href="https://gotlaptopparts.com/ai-setup" class="btn bg" target="_blank">💻 Online Help</a>
<a href="https://gotlaptopparts.com/ai-builds" class="btn bgr" target="_blank">🛒 AI-Ready Laptops</a>
</div>
</div>

<div style="text-align:center;margin-top:32px;padding:20px">
<p style="font-size:15px;color:#6b7280;font-weight:600;margin-bottom:12px">Enjoying ${AI_NAME}? A quick Google review helps others find this free tool.</p>
<a href="https://g.page/r/ChIJ9yyohBw_mYAR7JGqywVmGRs/review" target="_blank" class="btn bi" style="font-size:15px;padding:12px 24px">⭐ Leave a Google Review</a>
</div>

</div>

<div class="footer">
GotLaptopParts.com · Laptop Mate LLC · Reno, NV<br>
Free &amp; open source · <a href="https://github.com/gotlaptopparts/free-local-ai" style="color:#6366f1">github.com/gotlaptopparts/free-local-ai</a><br>
${AI_NAME} runs locally. No subscriptions. No data leaves your Mac.
</div>

<script>
// No animation needed — $0 is the honest number
</script>
</body>
</html>
WEOF

# Open welcome guide automatically
open "$WELCOME" 2>/dev/null || true

# Save verification report
REPORT="$HOME/Desktop/${AI_NAME}_Setup_$(date '+%Y%m%d').txt"
{
  echo "Free Local AI Setup — ${AI_NAME}"
  echo "github.com/gotlaptopparts/free-local-ai"
  echo "Version: $VERSION | Date: $(date '+%Y-%m-%d %H:%M')"
  echo "=============================="
  echo "Device:  $DEVICE_NAME"
  echo "RAM:     ${RAM_GB}GB | macOS: $MACOS_VER"
  echo "AI Name: $AI_NAME"
  echo "Model:   $MODEL_DISPLAY ($TIER)"
  echo "GPU:     $GPU_STATUS"
  echo ""
  echo "Installed:"
  printf "  %-15s %s\n" "Ollama:"      "$([ "$OLLAMA_OK" = true ] && echo "✅" || echo "❌")"
  printf "  %-15s %s\n" "LM Studio:"   "$([ "$LMS_OK" = true ] && echo "✅" || echo "⚠ visit lmstudio.ai")"
  printf "  %-15s %s\n" "Jan.ai:"      "$([ "$JAN_OK" = true ] && echo "✅" || echo "⚠ visit jan.ai")"
  printf "  %-15s %s\n" "AnythingLLM:" "$([ "$ALLM_OK" = true ] && echo "✅" || echo "⚠ visit anythingllm.com")"
  printf "  %-15s %s\n" "Page Assist:" "✅ (browser tab opened)"
  [ "$AUDIENCE" = "developer" ] && {
    printf "  %-15s %s\n" "VS Code:"   "$([ "$VSCODE_OK" = true ] && echo "✅" || echo "⚠")"
    printf "  %-15s %s\n" "Continue:"  "$([ "$CONT_OK" = true ] && echo "✅ configured" || echo "⚠")"
    printf "  %-15s %s\n" "Cline:"     "$([ "$CLINE_OK" = true ] && echo "✅" || echo "⚠")"
  }
  echo ""
  echo "AI test response:"
  echo "  \"$AI_RESPONSE\""
  [ ${#WARNINGS[@]} -gt 0 ] && {
    echo ""
    echo "Notes:"
    for w in "${WARNINGS[@]}"; do echo "  ⚠ $w"; done
  }
  echo ""
  echo "Help: gotlaptopparts.com/ai-setup | (775) 203-1085"
} > "$REPORT"

# ─────────────────────────────────────────────
# FINAL
# ─────────────────────────────────────────────
_gap

if [[ "$AUDIENCE" == "hobbyist" ]]; then
  echo -e "${G}${W}"
  echo "  ╔══════════════════════════════════════════╗"
  echo "  ║                                          ║"
  echo "  ║   🎉  ${AI_NAME} is ready!                   ║"
  echo "  ║                                          ║"
  echo "  ╚══════════════════════════════════════════╝"
  echo -e "${N}"
  _gap
  echo -e "  ${W}Whatever you paid for AI subscriptions — that's now \$0.${N}"
  _gap
  echo -e "  🖥  Double-click ${W}\"Start ${AI_NAME}\"${N} on your Desktop to chat"
  echo -e "  🌐  Check the browser tab → click ${W}'Add to Chrome'${N} for browser AI"
  echo -e "  📁  Open ${W}AnythingLLM${N} → your AI workspace for projects, files, and MCP tools"
  echo -e "  📖  Read ${W}\"Welcome to ${AI_NAME}\"${N} on your Desktop — it explains everything"
  _gap
  [ ${#WARNINGS[@]} -gt 0 ] && {
    echo -e "  ${Y}A couple of notes:${N}"
    for w in "${WARNINGS[@]}"; do echo -e "    ${Y}• $w${N}"; done
    _gap
  }
  echo -e "  ${Y}⭐ Enjoying ${AI_NAME}? A Google review helps others find this:${N}"
  echo -e "     ${C}g.page/r/ChIJ9yyohBw_mYAR7JGqywVmGRs/review${N}"
  _gap
  echo -e "  ${Y}📊 Let us know how it went:${N} ${C}gotlaptopparts.com/ai-setup${N}"
  _gap
  echo -e "  ${C}💻 Want a laptop with ${AI_NAME} pre-installed? gotlaptopparts.com/ai-builds${N}"
  _gap

else
  echo -e "${G}${W}╔══════════════════════════════════════════════════╗${N}"
  echo -e "${G}${W}║              ✅ SETUP COMPLETE                   ║${N}"
  echo -e "${G}${W}╚══════════════════════════════════════════════════╝${N}"
  _gap
  echo -e "  Device:   $DEVICE_NAME | macOS $MACOS_VER"
  echo -e "  RAM:      ${RAM_GB}GB | GPU: $GPU_STATUS"
  echo -e "  Model:    $MODEL_DISPLAY ($TIER)"
  _gap
  echo -e "  Ollama:      $([ "$OLLAMA_OK" = true ] && echo "${G}✅${N}" || echo "${R}❌${N}")"
  echo -e "  LM Studio:   $([ "$LMS_OK" = true ] && echo "${G}✅${N}" || echo "${Y}⚠${N}")"
  echo -e "  Jan.ai:      $([ "$JAN_OK" = true ] && echo "${G}✅${N}" || echo "${Y}⚠${N}")"
  echo -e "  AnythingLLM: $([ "$ALLM_OK" = true ] && echo "${G}✅${N}" || echo "${Y}⚠${N}")"
  echo -e "  Page Assist: ${G}✅ browser tab opened${N}"
  [[ "$AUDIENCE" == "developer" ]] && {
    echo -e "  VS Code:     $([ "$VSCODE_OK" = true ] && echo "${G}✅${N}" || echo "${Y}⚠${N}")"
    echo -e "  Continue:    $([ "$CONT_OK" = true ] && echo "${G}✅ → local AI${N}" || echo "${Y}⚠${N}")"
    echo -e "  Cline:       $([ "$CLINE_OK" = true ] && echo "${G}✅${N}" || echo "${Y}⚠${N}")"
  }
  _gap
  [ ${#WARNINGS[@]} -gt 0 ] && {
    echo -e "  ${Y}Notes:${N}"
    for w in "${WARNINGS[@]}"; do echo -e "    ${Y}• $w${N}"; done
    _gap
  }
  echo -e "  ${Y}⭐ ${C}g.page/r/ChIJ9yyohBw_mYAR7JGqywVmGRs/review${N}"
  echo -e "  ${Y}📊 ${C}gotlaptopparts.com/ai-setup${N}"
  echo -e "  ${C}💻 gotlaptopparts.com/ai-builds${N}"
  _gap
fi
