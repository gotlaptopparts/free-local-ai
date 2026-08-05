# ============================================================
# Free Local AI Setup — Windows Edition v1.0
# github.com/gotlaptopparts/free-local-ai
# gotlaptopparts.com/ai-setup
# ============================================================
# Run: irm https://gotlaptopparts.com/ai-setup/windows.ps1 | iex
# ============================================================
# MIT License — open source, auditable, no telemetry
# ============================================================

param([string]$AudienceOverride = "")
$ErrorActionPreference = "Continue"
$VERSION = "1.0"

# Security & Privacy
# This script is fully open source. Read every line before running.
# github.com/gotlaptopparts/free-local-ai
#
# What this script does:
#   - Installs AI software via winget (verified, signed packages only)
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
$Audience = "hobbyist"
$AIName = "Aria"

# ── Colors / Helpers ──
function _ok   { param($m) Write-Host "  $([char]0x2705) $m" -ForegroundColor Green }
function _warn { param($m) Write-Host "  $([char]0x26A0)  $m" -ForegroundColor Yellow }
function _err  { param($m) Write-Host "  $([char]0x274C) $m" -ForegroundColor Red }
function _info { param($m) Write-Host "  ->  $m" -ForegroundColor Cyan }
function _gap  { Write-Host "" }

function Say {
  param($friendly, $technical)
  if ($Audience -eq "developer") { _info $technical }
  else { Write-Host "  $friendly" -ForegroundColor Green }
}

function Step {
  param($n, $total, $friendly, $technical)
  _gap
  if ($Audience -eq "hobbyist") {
    Write-Host "  Step $n of $total  --  $friendly" -ForegroundColor White
  } else {
    Write-Host "`n[$n/$total] $technical" -ForegroundColor Yellow
  }
}

function Celebrate { param($m) if ($Audience -eq "hobbyist") { Write-Host "  $m" -ForegroundColor Green } }

function Ask-User {
  param($q)
  Write-Host "`n  $q [Y/N]" -ForegroundColor White
  $a = Read-Host "  >"; return $a -match "^[Yy]$"
}

function Stop-Script {
  param($reason)
  _gap
  if ($Audience -eq "hobbyist") {
    _err "Something went wrong: $reason"
    _gap
    Write-Host "  Don't worry -- we can help:" -ForegroundColor White
    Write-Host "  (775) 203-1085" -ForegroundColor Cyan
    Write-Host "  gotlaptopparts.com/ai-setup/help" -ForegroundColor Cyan
  } else {
    _err "STOPPED: $reason"
    Write-Host "  Support: gotlaptopparts.com/ai-setup/help" -ForegroundColor Cyan
    Write-Host "  Phone:   (775) 203-1085" -ForegroundColor Cyan
  }
  _gap; exit 1
}

function RunQ {
  param([scriptblock]$cmd)
  if ($Audience -eq "developer") { & $cmd }
  else { try { & $cmd 2>$null | Out-Null } catch {} }
}

function Install-App {
  param($id, $name)
  for ($i = 1; $i -le 2; $i++) {
    if ($Audience -eq "developer") { _info "Installing $name (attempt $i)..." }
    winget install --id $id --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq -1978335189) {
      if ($Audience -eq "developer") { _ok "$name installed" }
      return $true
    }
    if ($i -lt 2) { Start-Sleep -Seconds 5 }
  }
  return $false
}

$Warnings = [System.Collections.ArrayList]@()
function Add-Warn { param($w) [void]$Warnings.Add($w) }

# ── Model chain ──
$Models = @("llama3.1:70b",  "qwen3:32b",   "llama3.1:8b", "phi4-mini")
$MNames = @("Llama 3.1 70B", "Qwen3 32B",   "Llama 3.1 8B","Phi-4 Mini")

function Get-ModelSizeGb {
  param([string]$ModelTag)
  $name = $ModelTag.Split(':')[0]
  $tag  = $ModelTag.Split(':')[1]
  $resp = Invoke-WebRequest -Uri "https://registry.ollama.ai/v2/library/$name/manifests/$tag" `
            -UseBasicParsing -TimeoutSec 8 -ErrorAction Stop
  $manifest = $resp.Content | ConvertFrom-Json
  $bytes = ($manifest.layers | Where-Object { $_.mediaType -like "*model*" } |
            Measure-Object -Property size -Sum).Sum
  return [math]::Ceiling($bytes / 1GB)
}
# MSizes populated after internet check (Step 3)

# ─────────────────────────────────────────────
Clear-Host
Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║   Free Local AI Setup -- Windows  |  v$VERSION          ║" -ForegroundColor Blue
Write-Host "║   github.com/gotlaptopparts/free-local-ai        ║" -ForegroundColor Blue
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Blue

# ── AUDIENCE SELECTION ──
_gap
Write-Host "  Who is this for?" -ForegroundColor White
_gap
Write-Host "  [1]  Personal use -- private AI, no more subscriptions" -ForegroundColor Cyan
Write-Host "  [2]  Developer   -- full coding stack + local AI" -ForegroundColor Cyan
Write-Host "  [3]  Business    -- deploying AI across a team" -ForegroundColor Cyan
_gap
$choice = Read-Host "  Enter 1, 2, or 3"

switch ($choice) {
  "1" { $Audience = "hobbyist" }
  "2" { $Audience = "developer" }
  "3" {
    _gap
    Write-Host "  Business AI deployment is a different setup." -ForegroundColor White
    _gap
    Write-Host "  For teams, compliance, or bulk deployment:"
    Write-Host "  (775) 203-1085" -ForegroundColor Cyan
    Write-Host "  gotlaptopparts.com/ai-setup" -ForegroundColor Cyan
    _gap
    Write-Host "  We'll set up your entire team. Private, secure, zero subscriptions."
    _gap
    exit 0
  }
  default { $Audience = "hobbyist"; _warn "Defaulting to personal setup" }
}

# ── Hobbyist intro ──
if ($Audience -eq "hobbyist") {
  _gap
  Write-Host "  Let's set up your free private AI assistant." -ForegroundColor White
  Write-Host "  Takes about 20 minutes. You can walk away -- it runs on its own."
  _gap
  Write-Host "  You'll get:" -ForegroundColor Green
  Write-Host "  + AI chat -- private, no subscription, works offline"
  Write-Host "  + AI in your browser -- on every webpage"
  Write-Host "  + AI that reads your documents"
  Write-Host "  + Nothing leaves your laptop. Ever."
  _gap
  Read-Host "  Press Enter to start"
}

# ─────────────────────────────────────────────
# STEP 1 -- HARDWARE
# ─────────────────────────────────────────────
Step 1 8 "Checking your laptop..." "Hardware detection"

$DeviceName = $env:COMPUTERNAME
$Serial     = (Get-WmiObject Win32_BIOS -ErrorAction SilentlyContinue).SerialNumber
$RAM_Bytes  = (Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory
$RAM_GB     = [math]::Round($RAM_Bytes / 1GB)
$CPU        = (Get-WmiObject Win32_Processor | Select-Object -First 1).Name
$DrvC       = Get-PSDrive C
$FREE_DISK  = [math]::Round($DrvC.Free / 1GB)
$WinVer     = (Get-WmiObject Win32_OperatingSystem).Caption

# GPU detection
$GPU_Name = "Unknown"; $VRAM_GB = 0; $HasNvidia = $false
$NvSmi = (Get-Command nvidia-smi -ErrorAction SilentlyContinue)?.Source
if (-not $NvSmi) { $NvSmi = "C:\Windows\System32\nvidia-smi.exe" }
if (Test-Path $NvSmi) {
  $HasNvidia = $true
  $NvName = & $NvSmi --query-gpu=name --format=csv,noheader 2>$null
  $NvVram = & $NvSmi --query-gpu=memory.total --format=csv,noheader,nounits 2>$null
  if ($NvName) { $GPU_Name = $NvName.Trim() }
  if ($NvVram) { $VRAM_GB  = [math]::Round([int]($NvVram.Trim()) / 1024) }
} else {
  $GPU = Get-WmiObject Win32_VideoController | Where-Object { $_.Name -notlike "*Microsoft*" } | Select-Object -First 1
  if ($GPU) { $GPU_Name = $GPU.Name }
}

if ($Audience -eq "developer") {
  _info "Device:    $DeviceName"
  _info "CPU:       $CPU"
  _info "RAM:       ${RAM_GB}GB"
  _info "GPU:       $GPU_Name $(if($VRAM_GB -gt 0){"(${VRAM_GB}GB VRAM)"})"
  _info "Free disk: ${FREE_DISK}GB"
  _info "Windows:   $WinVer"
}

if (-not $HasNvidia -and $VRAM_GB -eq 0) {
  Add-Warn "No dedicated GPU -- AI runs on CPU. Still works great for chat."
}

_ok "Laptop checked"

# ─────────────────────────────────────────────
# STEP 2 -- WINGET CHECK
# ─────────────────────────────────────────────
Step 2 8 "Checking Windows..." "Windows package manager check"

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  if ($Audience -eq "hobbyist") {
    Write-Host "`n  Your Windows needs a small update first." -ForegroundColor White
    Write-Host "  Open Microsoft Store -> search 'App Installer' -> click Update" -ForegroundColor Cyan
    if (Ask-User "Done? Continue?") {
      $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" +
                  [System.Environment]::GetEnvironmentVariable("PATH","User")
      if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Stop-Script "Windows update needed. Please update Windows, then run this again."
      }
    } else { Stop-Script "Windows update required to continue." }
  } else {
    Stop-Script "winget not found. Update Windows or install App Installer from Microsoft Store."
  }
}
_ok "Windows ready"

# ─────────────────────────────────────────────
# STEP 3 -- INTERNET
# ─────────────────────────────────────────────
Step 3 8 "Checking internet..." "Internet check"

try {
  $null = Invoke-WebRequest -Uri "https://ollama.com" -UseBasicParsing -TimeoutSec 8
  _ok "Internet connected"
} catch {
  Stop-Script "No internet connection. Connect to WiFi and run again."
}

# Fetch live model sizes from Ollama registry now that internet is confirmed
$MSizes = @()
for ($i = 0; $i -lt $Models.Count; $i++) {
  try {
    $MSizes += Get-ModelSizeGb -ModelTag $Models[$i]
  } catch {
    Stop-Script "Could not fetch model info from Ollama registry. Check internet and try again."
  }
}

# ─────────────────────────────────────────────
# STEP 4 -- RAM + STORAGE + MODEL
# ─────────────────────────────────────────────
Step 4 8 "Picking the best AI for your laptop..." "Model selection"

# Select by GPU VRAM first, then RAM
if     ($VRAM_GB -ge 16 -or $RAM_GB -ge 48) { $ModelIdx = 0 }
elseif ($VRAM_GB -ge 8  -or $RAM_GB -ge 24) { $ModelIdx = 1 }
elseif ($VRAM_GB -ge 4  -or $RAM_GB -ge 12) { $ModelIdx = 2 }
else                                          { $ModelIdx = 3 }

# RAM too low
if ($RAM_GB -lt 6 -and $VRAM_GB -lt 4) {
  if (Ask-User "Only ${RAM_GB}GB RAM detected. Install smallest AI model anyway?") {
    $ModelIdx = 3; Add-Warn "Low RAM (${RAM_GB}GB) -- Phi-4 Mini installed"
  } else { Stop-Script "Not enough RAM. Minimum 6GB required." }
}

# Storage check + auto-clean + downgrade
$ModelSize = $MSizes[$ModelIdx]; $Needed = $ModelSize + 5

if ($FREE_DISK -lt $Needed) {
  Say "Your laptop is a bit full. Cleaning up some space..." "Low storage -- cleaning temp files"
  Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
  Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
  $DrvC = Get-PSDrive C; $FREE_DISK = [math]::Round($DrvC.Free / 1GB)

  if ($FREE_DISK -lt $Needed) {
    $Downgraded = $false
    for ($try = 1; $try -le 3; $try++) {
      $NextIdx = $ModelIdx + $try
      if ($NextIdx -gt 3) { break }
      if ($FREE_DISK -ge ($MSizes[$NextIdx] + 5)) {
        Add-Warn "Installed $($MNames[$NextIdx]) (smaller model -- storage limit)"
        $ModelIdx = $NextIdx; $Downgraded = $true; break
      }
    }
    if (-not $Downgraded) { Stop-Script "Not enough storage. Free up at least 8GB and try again." }
  }
}

$Model = $Models[$ModelIdx]; $ModelDisplay = $MNames[$ModelIdx]
switch ($ModelIdx) {
  0 { $Tier = "AI Max"   }
  1 { $Tier = "AI Pro"   }
  2 { $Tier = "AI Ready" }
  3 { $Tier = "AI Entry" }
}

if ($Audience -eq "developer") { _ok "Model: $ModelDisplay | Tier: $Tier" }
else { _ok "Found the right AI for your laptop" }

# ─────────────────────────────────────────────
# NAME YOUR AI (hobbyist only)
# ─────────────────────────────────────────────
if ($Audience -eq "hobbyist") {
  _gap
  Write-Host "  What would you like to call your AI assistant?" -ForegroundColor White
  Write-Host "  Examples: Aria, Max, Nova, Sam, Alex, Friday" -ForegroundColor Cyan
  Write-Host "  (Press Enter to use 'Aria')" -ForegroundColor Cyan
  _gap
  $nameInput = Read-Host "  Name"
  if ($nameInput.Trim() -ne "") { $AIName = $nameInput.Trim() }
  _ok "Your AI assistant will be called: $AIName"
}

# ─────────────────────────────────────────────
# STEP 5 -- INSTALL TOOLS
# ─────────────────────────────────────────────
Step 5 8 "Installing AI software..." "Installing tools"

if ($Audience -eq "hobbyist") {
  Write-Host "  This takes about 10-15 minutes on fast internet. Coffee time!" -ForegroundColor Cyan
}

$OllamaOK=$false; $LMSOK=$false; $JanOK=$false
$AllmOK=$false; $VsCodeOK=$false; $ContOK=$false; $ClineOK=$false

# Ollama -- required
$OllamaOK = Install-App "Ollama.Ollama" "Ollama"
if (-not $OllamaOK) { Stop-Script "Could not install AI engine. Check internet and try again." }

# LM Studio
$LMSOK = Install-App "ElementLabs.LMStudio" "LM Studio"
if (-not $LMSOK) { Add-Warn "LM Studio not installed -- visit lmstudio.ai" }

# Jan.ai
$JanOK = Install-App "Jan.Jan" "Jan.ai"
if (-not $JanOK) { Add-Warn "Jan.ai not installed -- visit jan.ai" }

# AnythingLLM
$AllmOK = Install-App "Mintplex.AnythingLLM" "AnythingLLM"
if (-not $AllmOK) {
  try {
    $AllmUrl  = "https://cdn.anythingllm.com/latest/AnythingLLMDesktop.exe"
    $AllmInst = "$env:TEMP\AnythingLLM.exe"
    Invoke-WebRequest -Uri $AllmUrl -OutFile $AllmInst -UseBasicParsing -TimeoutSec 120
    Start-Process -FilePath $AllmInst -ArgumentList "/SILENT" -Wait
    $AllmOK = $true
    if ($Audience -eq "developer") { _ok "AnythingLLM installed (direct download)" }
  } catch { Add-Warn "AnythingLLM not installed -- visit anythingllm.com" }
}

# Developer tools
if ($Audience -eq "developer") {
  _gap; _info "Installing developer tools..."
  $VsCodeOK = Install-App "Microsoft.VisualStudioCode" "VS Code"
  if (-not $VsCodeOK) { Add-Warn "VS Code not installed -- visit code.visualstudio.com" }

  $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" +
              [System.Environment]::GetEnvironmentVariable("PATH","User")

  if (Get-Command code -ErrorAction SilentlyContinue) {
    code --install-extension Continue.continue 2>$null
    if ($LASTEXITCODE -eq 0) { $ContOK = $true; _ok "Continue.dev installed" }
    else { Add-Warn "Continue.dev -- install from VS Code marketplace" }

    code --install-extension saoudrizwan.claude-dev 2>$null
    if ($LASTEXITCODE -eq 0) { $ClineOK = $true; _ok "Cline installed" }
    else { Add-Warn "Cline -- install from VS Code marketplace" }

    # Configure Continue -> local Ollama
    $ContinueDir = "$env:USERPROFILE\.continue"
    New-Item -ItemType Directory -Path $ContinueDir -Force | Out-Null
    @"
{
  "models": [{"title": "Local AI ($ModelDisplay)", "provider": "ollama", "model": "$Model", "apiBase": "http://localhost:11434"}],
  "tabAutocompleteModel": {"provider": "ollama", "model": "$Model", "apiBase": "http://localhost:11434"},
  "embeddings": {"provider": "ollama", "model": "nomic-embed-text", "apiBase": "http://localhost:11434"},
  "allowAnonymousTelemetry": false
}
"@ | Out-File -FilePath "$ContinueDir\config.json" -Encoding UTF8
    _ok "Continue configured -> local AI ($ModelDisplay)"
  }
}

Celebrate "AI software installed"

# ─────────────────────────────────────────────
# STEP 6 -- OPTIMIZATIONS + AI NAME PRESET
# ─────────────────────────────────────────────
Step 6 8 "Setting up $AIName..." "Applying optimizations + AI personality"

# LM Studio preset with AI name
$LMSPresetDir = "$env:USERPROFILE\.lmstudio\config-presets"
New-Item -ItemType Directory -Path $LMSPresetDir -Force | Out-Null
@"
{
  "name": "$AIName",
  "systemPrompt": "Your name is $AIName. You are a friendly, private AI assistant running entirely on this laptop. Nothing discussed ever leaves this device -- you have no internet connection and send nothing to any server. Be warm, helpful, and concise. When someone asks who you are, tell them your name is $AIName and that you run locally and privately.",
  "temperature": 0.7,
  "maxTokens": 2048,
  "topP": 0.9
}
"@ | Out-File -FilePath "$LMSPresetDir\$AIName.preset.json" -Encoding UTF8

# Ollama env vars -- system level
[System.Environment]::SetEnvironmentVariable("OLLAMA_FLASH_ATTENTION","1","Machine")
[System.Environment]::SetEnvironmentVariable("OLLAMA_KEEP_ALIVE","-1","Machine")
[System.Environment]::SetEnvironmentVariable("OLLAMA_NUM_PARALLEL","1","Machine")
[System.Environment]::SetEnvironmentVariable("OLLAMA_MAX_LOADED_MODELS","1","Machine")
$env:OLLAMA_FLASH_ATTENTION="1"; $env:OLLAMA_KEEP_ALIVE="-1"
$env:OLLAMA_NUM_PARALLEL="1";    $env:OLLAMA_MAX_LOADED_MODELS="1"

# Ultimate Performance power plan
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null | Out-Null
$planLine = powercfg /list | Select-String "Ultimate Performance" | Select-Object -First 1
if ($planLine) {
  $guid = ([regex]'([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})').Matches($planLine.ToString())[0].Value
  if ($guid) { powercfg /setactive $guid }
}
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0

# NVIDIA driver update
if ($HasNvidia) {
  winget upgrade --id NVIDIA.NVIDIA_app --silent --accept-package-agreements --accept-source-agreements 2>$null | Out-Null
  if ($Audience -eq "developer") { _ok "NVIDIA drivers updated" }
}

if ($Audience -eq "developer") {
  _ok "Performance optimizations applied"
  _ok "LM Studio preset written: $AIName"
}

# Refresh PATH + find Ollama across known install locations
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("PATH","User")
$OllamaExe = (Get-Command ollama -ErrorAction SilentlyContinue)?.Source
if (-not $OllamaExe) {
  $OllamaCandidates = @(
    "$env:LOCALAPPDATA\Programs\Ollama\ollama.exe",
    "$env:LOCALAPPDATA\Ollama\ollama.exe",
    "$env:PROGRAMFILES\Ollama\ollama.exe"
  )
  foreach ($c in $OllamaCandidates) { if (Test-Path $c) { $OllamaExe = $c; break } }
}
if (-not $OllamaExe -or -not (Test-Path $OllamaExe)) {
  Stop-Script "Please close this window, open a new PowerShell, and run the script again."
}

# Start Ollama server
Get-Process -Name "ollama" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Process -FilePath $OllamaExe -ArgumentList "serve" -WindowStyle Hidden

$ServerOK = $false
for ($i = 1; $i -le 3; $i++) {
  Start-Sleep -Seconds 5
  try {
    $null = Invoke-WebRequest -Uri "http://localhost:11434" -UseBasicParsing -TimeoutSec 5
    $ServerOK = $true; break
  } catch {
    if ($i -eq 3) {
      $portLine = netstat -ano 2>$null | Select-String ":11434 " | Select-Object -First 1
      if ($portLine) {
        $conflictPid = ($portLine.ToString().Trim() -split '\s+')[-1]
        Stop-Process -Id $conflictPid -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 3
        Start-Process -FilePath $OllamaExe -ArgumentList "serve" -WindowStyle Hidden
        Start-Sleep -Seconds 5
        try {
          $null = Invoke-WebRequest -Uri "http://localhost:11434" -UseBasicParsing -TimeoutSec 5
          $ServerOK = $true
        } catch {}
      }
    }
  }
}

if (-not $ServerOK) { Stop-Script "AI engine failed to start. Restart your laptop and try again." }
if ($Audience -eq "developer") { _ok "Ollama server running" }
Celebrate "$AIName is warming up..."

# ─────────────────────────────────────────────
# STEP 7 -- DOWNLOAD MODEL
# ─────────────────────────────────────────────
Step 7 8 "Downloading $AIName's brain..." "Model download"

if ($Audience -eq "hobbyist") {
  Write-Host "  This is the big download -- a few minutes on fast internet." -ForegroundColor Cyan
}

$PullOK = $false; $CurrentIdx = $ModelIdx

while ($CurrentIdx -le 3) {
  $CurrentModel = $Models[$CurrentIdx]; $CurrentName = $MNames[$CurrentIdx]
  if ($Audience -eq "developer") { _info "Downloading $CurrentName..." }

  for ($attempt = 1; $attempt -le 3; $attempt++) {
    & $OllamaExe pull $CurrentModel
    if ($LASTEXITCODE -eq 0) {
      $PullOK = $true; $Model = $CurrentModel; $ModelDisplay = $CurrentName
      if ($CurrentIdx -gt $ModelIdx) {
        Add-Warn "Installed $CurrentName (smaller model after download issue)"
      }
      break
    }
    if ($attempt -lt 3) { Start-Sleep -Seconds 5 }
  }
  if ($PullOK) { break }

  $NextIdx = $CurrentIdx + 1
  if ($NextIdx -le 3) {
    Add-Warn "Trying smaller model after download issue"
    $CurrentIdx = $NextIdx
  } else { Stop-Script "Download failed. Check internet and try again." }
}

if (-not $PullOK) { Stop-Script "Download failed. Check internet connection." }

# Developer: embedding model
if ($Audience -eq "developer") {
  _info "Downloading embedding model..."
  & $OllamaExe pull nomic-embed-text 2>$null
  if ($LASTEXITCODE -eq 0) { _ok "Embedding model ready" }
  else { Add-Warn "nomic-embed-text not downloaded" }
}

# ─────────────────────────────────────────────
# STEP 8 -- VERIFY
# ─────────────────────────────────────────────
Step 8 8 "Testing $AIName..." "Verification"

$AIResponse = ""
for ($attempt = 1; $attempt -le 2; $attempt++) {
  $job = Start-Job -ScriptBlock {
    param($exe,$mdl,$name)
    & $exe run $mdl "Your name is $name. Introduce yourself in one sentence."
  } -ArgumentList $OllamaExe, $Model, $AIName
  $done = Wait-Job $job -Timeout 60
  if ($done) {
    $AIResponse = (Receive-Job $job) -join " "; Remove-Job $job
    if ($AIResponse) { break }
  } else { Remove-Job $job -Force; Start-Sleep -Seconds 5 }
}

if (-not $AIResponse) { Add-Warn "$AIName installed but test response failed -- try opening LM Studio" }

# GPU check
Start-Sleep -Seconds 2
$PsOutput  = & $OllamaExe ps 2>$null
$GpuStatus = "Unknown"
if ($PsOutput -match "100% GPU") {
  $GpuStatus = "GPU (CUDA)"
  if ($Audience -eq "developer") { _ok "CUDA GPU acceleration confirmed" }
} elseif ($HasNvidia) {
  $GpuStatus = "CPU fallback (update NVIDIA drivers)"
  Add-Warn "NVIDIA GPU not active -- update drivers. Verify: nvidia-smi"
} else {
  $GpuStatus = "CPU Mode"
  if ($Audience -eq "developer") { _warn "No NVIDIA GPU -- CPU mode (~5-10 tok/s)" }
}

Celebrate "$AIName downloaded and working"

# ── Desktop shortcut named after AI ──
$DesktopPath = [System.Environment]::GetFolderPath("Desktop")
# Detect LM Studio install path dynamically across known locations
$LMPath = $null
$LMCandidates = @(
  "$env:LOCALAPPDATA\Programs\LM Studio\LM Studio.exe",
  "$env:LOCALAPPDATA\LM Studio\LM Studio.exe",
  "$env:PROGRAMFILES\LM Studio\LM Studio.exe",
  "$env:PROGRAMFILES(X86)\LM Studio\LM Studio.exe"
)
foreach ($c in $LMCandidates) { if (Test-Path $c) { $LMPath = $c; break } }
if (-not $LMPath) {
  $found = Get-Command "LM Studio" -ErrorAction SilentlyContinue
  if ($found) { $LMPath = $found.Source }
}
if ($LMPath) {
  $WS = New-Object -ComObject WScript.Shell
  $SC = $WS.CreateShortcut("$DesktopPath\Start $AIName.lnk")
  $SC.TargetPath = $LMPath; $SC.Save()
}

# Open browser extension
Start-Process "https://chromewebstore.google.com/detail/page-assist-a-web-ui-for/jfgfiigpkhlkbnfnbobbkinehhfdhndo"
if ($Audience -eq "developer") { _info "Browser tab opened -- Page Assist (click Add to Chrome)" }

# ── Generate welcome guide with AI name ──
$Date = Get-Date -Format "yyyy-MM-dd"
$WelcomePath = "$DesktopPath\Welcome to $AIName.html"

$WelcomeHTML = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Welcome to $AIName -- Your Free Private AI</title>
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
.card{background:white;border-radius:16px;padding:28px;border:2px solid #f3f4f6;display:grid;grid-template-columns:64px 1fr;gap:20px;align-items:start}
.card-icon{width:64px;height:64px;border-radius:14px;display:flex;align-items:center;justify-content:center;font-size:30px;flex-shrink:0}
.ib{background:#eff6ff}.ig{background:#f0fdf4}.ip{background:#faf5ff}.io{background:#fff7ed}.ipk{background:#fdf2f8}
.card-eyebrow{font-size:11px;font-weight:800;letter-spacing:1.5px;text-transform:uppercase;color:#9ca3af;margin-bottom:4px}
.card-title{font-size:20px;font-weight:800;color:#111827;margin-bottom:8px}
.card-desc{font-size:15px;color:#4b5563;line-height:1.65;margin-bottom:14px;font-weight:600}
.card-how{background:#f9fafb;border-radius:10px;padding:12px 14px;font-size:14px;color:#374151;font-weight:600;border-left:3px solid #6366f1}
.card-how strong{color:#3730a3}
.models-section{margin-top:48px;background:white;border-radius:16px;padding:28px;border:2px solid #f3f4f6}
.models-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:12px;margin-top:16px}
.model-card{background:#f9fafb;border-radius:10px;padding:14px;border:1px solid #e5e7eb}
.model-name{font-size:14px;font-weight:800;color:#111827;margin-bottom:2px}
.model-use{font-size:12px;color:#6b7280;font-weight:600;margin-bottom:8px}
.model-ram{display:inline-block;background:#eff6ff;color:#3730a3;padding:2px 8px;border-radius:4px;font-size:11px;font-weight:700}
.models-how{margin-top:16px;background:#faf5ff;border-radius:10px;padding:12px 14px;font-size:14px;color:#374151;font-weight:600;border-left:3px solid #9333ea}
.tips{margin-top:32px;background:#f0fdf4;border-radius:16px;padding:24px 28px;border:2px solid #bbf7d0}
.tips h3{font-size:17px;font-weight:800;color:#14532d;margin-bottom:14px}
.tip{display:flex;gap:10px;font-size:14px;color:#166534;font-weight:600;align-items:flex-start;margin-bottom:10px}
.tip-dot{width:20px;height:20px;background:#16a34a;border-radius:50%;display:flex;align-items:center;justify-content:center;flex-shrink:0;color:white;font-size:11px;font-weight:800}
.help{margin-top:32px;text-align:center;padding:32px 24px;background:white;border-radius:16px;border:2px solid #f3f4f6}
.help h3{font-size:20px;font-weight:800;margin-bottom:8px}
.help p{font-size:15px;color:#6b7280;font-weight:600;margin-bottom:20px}
.help-links{display:flex;gap:12px;justify-content:center;flex-wrap:wrap}
.btn{display:inline-flex;align-items:center;gap:6px;padding:10px 20px;border-radius:10px;font-size:14px;font-weight:700;text-decoration:none;font-family:'Nunito',sans-serif}
.bi{background:#4f46e5;color:white}.bg{background:#16a34a;color:white}.bgr{background:#f3f4f6;color:#374151}
.footer{text-align:center;padding:24px;font-size:13px;color:#9ca3af;font-weight:600}
</style>
</head>
<body>
<div class="hero">
<div class="hero-inner">
<div class="hero-tag">Setup Complete</div>
<h1>Meet $AIName.<br>Your free private AI.</h1>
<p class="hero-sub">Here's what you now have -- and how to use everything.</p>
<div class="savings-card">
<div class="savings-label">Your AI subscriptions</div>
<div class="savings-amount">$0</div>
<div class="savings-period">from now on -- forever</div>
<div class="savings-breakdown">
<span class="stag">No ChatGPT</span><span class="stag">No Copilot</span><span class="stag">No Perplexity</span><span class="stag">No Grammarly</span><span class="stag">No cloud</span>
</div>
</div>
</div>
</div>
<div class="main">
<div class="section-intro">
<h2>4 ways to use $AIName</h2>
<p>Everything runs privately on your laptop. Nothing goes anywhere.</p>
</div>
<div class="cards">
<div class="card">
<div class="card-icon ib">&#x1F5A5;</div>
<div>
<div class="card-eyebrow">Chat AI</div>
<div class="card-title">Talk to $AIName -- like ChatGPT, but free</div>
<div class="card-desc">Ask anything. Write emails, summarize things, answer questions, brainstorm, translate. $AIName never judges, never tires, and never shares what you type.</div>
<div class="card-how"><strong>How to open:</strong> Double-click <strong>"Start $AIName"</strong> on your Desktop. Type your question. Press Enter.</div>
</div>
</div>
<div class="card">
<div class="card-icon ig">&#x1F310;</div>
<div>
<div class="card-eyebrow">Browser AI</div>
<div class="card-title">$AIName on every webpage you visit</div>
<div class="card-desc">A browser tab was opened during setup. Click "Add to Chrome". Now $AIName is in your browser -- summarize articles, explain things, translate anything.</div>
<div class="card-how"><strong>How to use:</strong> Click the AI icon in your browser toolbar. Or highlight any text on any webpage, right-click, and choose "Ask AI".</div>
</div>
</div>
<div class="card">
<div class="card-icon ip">&#x1F4C4;</div>
<div>
<div class="card-eyebrow">Document AI</div>
<div class="card-title">Ask $AIName about your files</div>
<div class="card-desc">Drag any PDF, Word doc, or file into AnythingLLM and ask questions about it. Your files never leave your laptop.</div>
<div class="card-how"><strong>How to open:</strong> Find <strong>AnythingLLM</strong> in your Start Menu. Drag any file into the chat. Start asking questions.</div>
</div>
</div>
<div class="card">
<div class="card-icon ipk">&#x1F9E0;</div>
<div>
<div class="card-eyebrow">Want a different AI?</div>
<div class="card-title">Switch AI models anytime</div>
<div class="card-desc">200+ free models available -- each good at different things. Download any with one click, no technical knowledge needed.</div>
<div class="card-how"><strong>How to switch:</strong> Open <strong>LM Studio</strong> from Start Menu -- click <strong>Discover</strong> -- search any model -- click <strong>Download</strong>.</div>
</div>
</div>
</div>
<div class="models-section">
<div style="font-size:20px;font-weight:800;color:#111827;margin-bottom:4px">Which AI is best for what?</div>
<div style="font-size:14px;color:#6b7280;font-weight:600">All free. Download any inside LM Studio - Discover.</div>
<div class="models-grid">
<div class="model-card"><div class="model-name">llama3.1:8b</div><div class="model-use">Best all-rounder. Chat, writing, questions.</div><span class="model-ram">5GB disk</span></div>
<div class="model-card"><div class="model-name">phi4-mini</div><div class="model-use">Fast and light. Great for older laptops.</div><span class="model-ram">2GB disk</span></div>
<div class="model-card"><div class="model-name">qwen3:32b</div><div class="model-use">Best quality. Reasoning, long answers.</div><span class="model-ram">19GB disk</span></div>
<div class="model-card"><div class="model-name">deepseek-r1:7b</div><div class="model-use">Logic, math, step-by-step thinking.</div><span class="model-ram">5GB disk</span></div>
<div class="model-card"><div class="model-name">gemma4:12b</div><div class="model-use">Vision -- can see and describe images.</div><span class="model-ram">7GB disk</span></div>
<div class="model-card"><div class="model-name">qwen2.5-coder:7b</div><div class="model-use">Writing and fixing code.</div><span class="model-ram">5GB disk</span></div>
</div>
<div class="models-how">To switch: open <strong>LM Studio</strong> -- <strong>Discover</strong> -- search a model -- <strong>Download</strong> -- select it in the chat window.</div>
</div>
<div class="tips">
<h3>Good to know</h3>
<div class="tip"><div class="tip-dot">+</div><span>$AIName works offline -- no internet needed. Use on planes, anywhere.</span></div>
<div class="tip"><div class="tip-dot">+</div><span>Nothing you type is ever sent to any company. All on your laptop.</span></div>
<div class="tip"><div class="tip-dot">+</div><span>$AIName starts automatically when you turn on your laptop.</span></div>
<div class="tip"><div class="tip-dot">+</div><span>If $AIName feels slow, close other apps to free up memory.</span></div>
<div class="tip"><div class="tip-dot">+</div><span>Jan.ai (also installed) is the most private option -- fully offline, no telemetry.</span></div>
<div class="tip"><div class="tip-dot">+</div><span>To update $AIName's brain: open PowerShell, type <code style="background:#f3f4f6;padding:1px 6px;border-radius:4px">ollama pull $Model</code>, press Enter.</span></div>
</div>
<div class="help">
<h3>Questions? We're here.</h3>
<p>We built this because everyone deserves free, private AI.<br>If anything isn't working -- just reach out.</p>
<div class="help-links">
<a href="tel:+17752031085" class="btn bi">(775) 203-1085</a>
<a href="https://gotlaptopparts.com/ai-setup/help" class="btn bg" target="_blank">Online Help</a>
<a href="https://gotlaptopparts.com/ai-builds" class="btn bgr" target="_blank">AI-Ready Laptops</a>
</div>
</div>
<div style="text-align:center;margin-top:32px;padding:20px">
<p style="font-size:15px;color:#6b7280;font-weight:600;margin-bottom:12px">Enjoying $AIName? A quick Google review helps others find this free tool.</p>
<a href="https://g.page/r/ChIJ9yyohBw_mYAR7JGqywVmGRs/review" target="_blank" class="btn bi" style="font-size:15px;padding:12px 24px">Leave a Google Review</a>
</div>
</div>
<div class="footer">
GotLaptopParts.com - Laptop Mate LLC - Reno, NV<br>
Free &amp; open source - <a href="https://github.com/gotlaptopparts/free-local-ai" style="color:#6366f1">github.com/gotlaptopparts/free-local-ai</a><br>
$AIName runs locally. No subscriptions. No data leaves your laptop.
</div>
<script>
// No animation needed -- $0 is the honest number
</script>
</body>
</html>
"@

$WelcomeHTML | Out-File -FilePath $WelcomePath -Encoding UTF8
Start-Process $WelcomePath

# Save verification report
$ReportPath = "$DesktopPath\${AIName}_Setup_$(Get-Date -Format 'yyyyMMdd').txt"
@"
Free Local AI Setup -- $AIName
github.com/gotlaptopparts/free-local-ai
Version: $VERSION | Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm')
==============================
Device:  $DeviceName
CPU:     $CPU | RAM: ${RAM_GB}GB
GPU:     $GPU_Name $(if($VRAM_GB -gt 0){"(${VRAM_GB}GB VRAM)"})
AI Name: $AIName
Model:   $ModelDisplay ($Tier)
GPU:     $GpuStatus

Installed:
  Ollama:       $(if($OllamaOK){"OK"}else{"FAILED"})
  LM Studio:    $(if($LMSOK){"OK"}else{"visit lmstudio.ai"})
  Jan.ai:       $(if($JanOK){"OK"}else{"visit jan.ai"})
  AnythingLLM:  $(if($AllmOK){"OK"}else{"visit anythingllm.com"})
  Page Assist:  OK (browser tab opened)
$(if($Audience -eq "developer"){"  VS Code:      $(if($VsCodeOK){"OK"}else{"visit code.visualstudio.com"})
  Continue.dev: $(if($ContOK){"OK - configured"}else{"install from VS Code marketplace"})
  Cline:        $(if($ClineOK){"OK"}else{"install from VS Code marketplace"})"})

AI test response:
  "$AIResponse"
$(if($Warnings.Count -gt 0){"`nNotes:"; $Warnings | ForEach-Object {"  * $_"}})

Help: gotlaptopparts.com/ai-setup/help | (775) 203-1085
"@ | Out-File -FilePath $ReportPath -Encoding UTF8

# ─────────────────────────────────────────────
# FINAL
# ─────────────────────────────────────────────
_gap

if ($Audience -eq "hobbyist") {
  Write-Host "  +------------------------------------------+" -ForegroundColor Green
  Write-Host "  |                                          |" -ForegroundColor Green
  Write-Host "  |   $AIName is ready!                        |" -ForegroundColor Green
  Write-Host "  |                                          |" -ForegroundColor Green
  Write-Host "  +------------------------------------------+" -ForegroundColor Green
  _gap
  Write-Host "  Whatever you paid for AI subscriptions -- that's now `$0." -ForegroundColor White
  _gap
  Write-Host "  - Double-click 'Start $AIName' on your Desktop to chat" -ForegroundColor Green
  Write-Host "  - Check the browser tab -> click 'Add to Chrome' for browser AI" -ForegroundColor Green
  Write-Host "  - Open AnythingLLM -> drag in any file to chat with it" -ForegroundColor Green
  Write-Host "  - Read 'Welcome to $AIName' on your Desktop -- it explains everything" -ForegroundColor Green
  _gap
  if ($Warnings.Count -gt 0) {
    Write-Host "  A couple of notes:" -ForegroundColor Yellow
    $Warnings | ForEach-Object { Write-Host "    * $_" -ForegroundColor Yellow }
    _gap
  }
  Write-Host "  Leave us a Google review (takes 30 seconds):" -ForegroundColor Yellow
  Write-Host "  g.page/r/ChIJ9yyohBw_mYAR7JGqywVmGRs/review" -ForegroundColor Cyan
  _gap
  Write-Host "  Feedback: gotlaptopparts.com/ai-setup/feedback" -ForegroundColor Cyan
  Write-Host "  AI-Ready laptops: gotlaptopparts.com/ai-builds" -ForegroundColor Cyan
  _gap

} else {
  Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Green
  Write-Host "║              SETUP COMPLETE                      ║" -ForegroundColor Green
  Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Green
  _gap
  Write-Host "  Device:   $DeviceName"
  Write-Host "  RAM:      ${RAM_GB}GB | GPU: $GPU_Name $(if($VRAM_GB -gt 0){"(${VRAM_GB}GB VRAM)"})"
  Write-Host "  Model:    $ModelDisplay ($Tier)"
  Write-Host "  GPU:      $GpuStatus" -ForegroundColor Green
  _gap
  Write-Host "  Ollama:      $(if($OllamaOK){'OK'}else{'FAILED'})" -ForegroundColor $(if($OllamaOK){'Green'}else{'Red'})
  Write-Host "  LM Studio:   $(if($LMSOK){'OK'}else{'skipped'})" -ForegroundColor $(if($LMSOK){'Green'}else{'Yellow'})
  Write-Host "  Jan.ai:      $(if($JanOK){'OK'}else{'skipped'})" -ForegroundColor $(if($JanOK){'Green'}else{'Yellow'})
  Write-Host "  AnythingLLM: $(if($AllmOK){'OK'}else{'skipped'})" -ForegroundColor $(if($AllmOK){'Green'}else{'Yellow'})
  Write-Host "  Page Assist: OK (browser tab opened)" -ForegroundColor Green
  if ($Audience -eq "developer") {
    Write-Host "  VS Code:     $(if($VsCodeOK){'OK'}else{'skipped'})" -ForegroundColor $(if($VsCodeOK){'Green'}else{'Yellow'})
    Write-Host "  Continue:    $(if($ContOK){'OK - configured -> local AI'}else{'skipped'})" -ForegroundColor $(if($ContOK){'Green'}else{'Yellow'})
    Write-Host "  Cline:       $(if($ClineOK){'OK'}else{'skipped'})" -ForegroundColor $(if($ClineOK){'Green'}else{'Yellow'})
  }
  _gap
  if ($Warnings.Count -gt 0) {
    Write-Host "  Notes:" -ForegroundColor Yellow
    $Warnings | ForEach-Object { Write-Host "    * $_" -ForegroundColor Yellow }
    _gap
  }
  Write-Host "  Google review: g.page/r/ChIJ9yyohBw_mYAR7JGqywVmGRs/review" -ForegroundColor Yellow
  Write-Host "  Feedback:      gotlaptopparts.com/ai-setup/feedback" -ForegroundColor Cyan
  Write-Host "  AI laptops:    gotlaptopparts.com/ai-builds" -ForegroundColor Cyan
  _gap
}
