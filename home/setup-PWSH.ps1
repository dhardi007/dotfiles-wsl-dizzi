# setup-paraWindowsPWSH.ps1 - Diego Edition v3 (Workspace Optimized)

# --- COLORES ---
$E_GREEN = "Green"
$E_YELLOW = "Yellow"
$E_CYAN = "Cyan"
$E_RED = "Red"
$E_BLUE = "Blue"

Write-Host "🔮 Iniciando Setup Maestro Windows-PWSH (Diego Edition v3)..." -ForegroundColor $E_BLUE

# 0. VERIFICAR ADMINISTRADOR
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Host "❌ Este script debe ejecutarse como ADMINISTRADOR" -ForegroundColor $E_RED
  exit
}

# --- VARIABLES DE RUTA (BASADAS EN TU WORKSPACE) ---
$WORKSPACE_ROOT = "$HOME\workspace"
$DOTFILES_ROOT = "$HOME\dotfiles-wsl-dizzi"

# Auto-detección de dotfiles si no está en el home
if (!(Test-Path $DOTFILES_ROOT)) {
  $DOTFILES_ROOT = Join-Path $WORKSPACE_ROOT "dotfiles-wsl-dizzi"
  if (!(Test-Path $DOTFILES_ROOT)) {
    # Fallback: intentar ver si se llama dizzi1222 o similar
    $DOTFILES_ROOT = Join-Path $WORKSPACE_ROOT "dizzi1222"
  }
}

$NVIM_CONFIG = "$env:LOCALAPPDATA\nvim"
$PT_DEST = "$HOME\Documents\PowerToys\Backup"

Write-Host "📂 Usando Workspace: $WORKSPACE_ROOT" -ForegroundColor $E_CYAN
Write-Host "� Usando Dotfiles: $DOTFILES_ROOT" -ForegroundColor $E_CYAN

# 1. ACTUALIZACIÓN E INSTALACIÓN DE PAQUETES (WINGET)
Write-Host "`n📦 Instalando/Actualizando paquetes esenciales..." -ForegroundColor $E_GREEN
$packages = @(
  "Microsoft.PowerShell",
  "Neovim.Neovim",
  "BurntSushi.ripgrep",
  "ShiningLight.OpenSSL.Light",
  "sharkdp.fd",
  "junegunn.fzf",
  "Microsoft.Git",
  "7zip.7zip",
  "Gnu.GnuPG",
  "FlorianHeidenreich.Mp3tag",
  "Google.PlayGames",
  "KDE.Krita",
  "ImageMagick.ImageMagick",
  "VideoLAN.VLC",
  "Wondershare.Filmora",
  "GitHub.cli",
  "Warp.Warp",
  "Google.GoogleDrive",
  "glzr-io.zebar",
  "HandBrake.HandBrake",
  "Mega.MEGASync",
  "Brave.Brave",
  "Nota.Gyazo",
  "PowerSoftware.PowerISO",
  "Valve.Steam",
  "Discord.Discord",
  "Fastfetch-cli.Fastfetch",
  "Greenshot.Greenshot",
  "Spotify.Spotify",
  "BurntSushi.ripgrep.MSVC",
  "ajeetdsouza.zoxide",
  "Overwolf.CurseForge",
 "Microsoft.PowerToys",
 "Espanso.Espanso",
 "Ollama.Ollama",
 "maximmax42.CustomRP",
 "Python.Python.3.13",
 "Google.Antigravity",
 "Nvidia.GeForceNow",
 "ARP\User\X64\{DD3870DA-A9C3-4E4C-B1F6-C1D8A4D2E1E0}0.1.14",
 "Microsoft.PowerToys",
 "JackieLiu.NotepadsApp",
 "IObit.IObitUnlocker",
 "BlueStack.BlueStacks"

)

foreach ($pkg in $packages) {
  Write-Host "   Verificando $pkg..." -ForegroundColor $E_CYAN
  # --include-unknown evita fallos si ya está instalado pero no trackeado exactamente
  winget install --id $pkg --silent --accept-package-agreements --accept-source-agreements --upgrade | Out-Null
}

# 2. INSTALACIÓN DE uwal (WinWal)
if (!(Get-Command uwal -ErrorAction SilentlyContinue)) {
  Write-Host "🎨 Instalando WinWal (uwal)..." -ForegroundColor $E_YELLOW
  winget install --id "WinWal.WinWal" --silent --accept-package-agreements --accept-source-agreements | Out-Null
}

# 3. CONFIGURAR POWERSHELL PROFILE ($PROFILE)
Write-Host "`n📝 Configurando Aliases y Perfil..." -ForegroundColor $E_GREEN
$PROFILE_DIR = Split-Path $PROFILE
if (!(Test-Path $PROFILE_DIR)) { New-Item -ItemType Directory -Path $PROFILE_DIR -Force | Out-Null }
if (!(Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force | Out-Null }

$customProfile = @"

# --- CONFIGURACIÓN DIEGO (v3) ---
# Aliases Estilo Zsh
function nv { nvim `$args }
function lsa { Get-ChildItem -Force `$args }
function ll { Get-ChildItem -Force `$args }
function la { Get-ChildItem -Force `$args }

# Sincronización
function sync-nvim {
    if (Test-Path "$DOTFILES_ROOT\home\sync-nvim-pwshWindows.ps1") {
        & "$DOTFILES_ROOT\home\sync-nvim-pwshWindows.ps1"
    } else {
        Write-Host "❌ No se encontró el script de sync en $DOTFILES_ROOT" -ForegroundColor Red
    }
}
function sync-wal { uwal -y }

# Cargar colores de WinWal/Pywal
if (Test-Path "`$HOME\.cache\wal\colors-powershell.ps1") {
    . "`$HOME\.cache\wal\colors-powershell.ps1"
}
"@

if (!(Get-Content $PROFILE | Select-String "sync-nvim")) {
  $customProfile | Add-Content $PROFILE
  Write-Host "✅ Perfil actualizado con aliases estilo Zsh (nv, lsa, ll, sync-nvim)" -ForegroundColor $E_CYAN
}

# 4. SINCRONIZACIÓN NEOVIM INICIAL
Write-Host "`n🚀 Sincronizando Neovim a AppData..." -ForegroundColor $E_GREEN
$NVIM_SRC = Join-Path $DOTFILES_ROOT "nvim-wsl"
if (Test-Path $NVIM_SRC) {
  if (!(Test-Path $NVIM_CONFIG)) { New-Item -ItemType Directory -Path $NVIM_CONFIG -Force | Out-Null }
  robocopy "$NVIM_SRC" "$NVIM_CONFIG" /MIR /XD .git /R:2 /W:5 | Out-Null
  Write-Host "✅ Neovim config sincronizada desde $NVIM_SRC" -ForegroundColor $E_CYAN
}
else {
  Write-Host "⚠️ No se encontró la carpeta nvim-wsl en dotfiles." -ForegroundColor $E_YELLOW
}

# 5. POWERTOYS BACKUP (Búsqueda dinámica)
Write-Host "`n🛠️ Replicando Backup de PowerToys..." -ForegroundColor $E_GREEN
if (!(Test-Path $PT_DEST)) { New-Item -ItemType Directory -Path $PT_DEST -Force | Out-Null }

$PT_SEARCH_PATH = Join-Path $WORKSPACE_ROOT "glaze-wm"
$PT_FILE = Get-ChildItem -Path $PT_SEARCH_PATH -Filter "*.ptb" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

if ($PT_FILE) {
  Copy-Item $PT_FILE.FullName "$PT_DEST\" -Force
  Write-Host "✅ Backup encontrado y copiado: $($PT_FILE.Name)" -ForegroundColor $E_CYAN
  Write-Host "💡 INFO: Abre PowerToys -> General -> Restaurar." -ForegroundColor $E_YELLOW
}
else {
  Write-Host "⚠️ No se encontró el archivo .ptb en $PT_SEARCH_PATH" -ForegroundColor $E_YELLOW
}

Write-Host "`n✨ Setup Completado! Reinicia tu terminal para activar todo." -ForegroundColor $E_BLUE
# En tu setup-paraWindowsPWSH.ps1, agrega después de línea 67:

# 5.5. CREAR .fdignore GLOBAL
Write-Host "`n📝 Creando .fdignore global..." -ForegroundColor $E_GREEN
$FDIGNORE_CONTENT = @'
no_repo/
.git/
node_modules/
.cache/
.vscode-server/
*.log
*.lnk
*.dll
*.exe
*.so
*.dylib
*.bin
*.obj
*.o
*%2*
*%20*
dist/
build/
.turbo/
.next/
target/
out/
'@

$FDIGNORE_CONTENT | Out-File -FilePath "$HOME\.fdignore" -Encoding UTF8 -Force
Write-Host "✅ .fdignore creado en: $HOME\.fdignore" -ForegroundColor $E_CYAN
