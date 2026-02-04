# sync-nvim-pwshWindows.ps1 - Script para Windows Nativo (Diego Edition)

# --- DEFINICIÓN DE RUTAS CON VARIABLES DE ENTORNO ---
# Usamos backslashes (\) estrictos para compatibilidad total con Windows Pro
$WINDOWS_CONFIG = Join-Path $env:LOCALAPPDATA "nvim\"
$WSL_CONFIG = "\\wsl.localhost\archlinux\root\.config\nvim\"

# Rutas para el color picker (extraídas de AppData\Local)
$WINDOWS_PICKER = Join-Path $env:LOCALAPPDATA "nvim-data\oklch-color-picker\oklch-color-picker.exe"
$WSL_PICKER_DIR = "\\wsl.localhost\archlinux\root\.local\share\nvim\oklch-color-picker\"

Write-Host "🔄 Sincronizando Neovim: Windows -> WSL..." -ForegroundColor Yellow

# 1. Crear carpetas de destino en WSL si faltan
if (!(Test-Path $WSL_CONFIG)) {
  Write-Host "📂 Creando directorio de config en WSL..." -ForegroundColor Cyan
  New-Item -Path $WSL_CONFIG -ItemType Directory -Force | Out-Null
}
if (!(Test-Path $WSL_PICKER_DIR)) {
  Write-Host "📂 Creando directorio para color-picker en WSL..." -ForegroundColor Cyan
  New-Item -Path $WSL_PICKER_DIR -ItemType Directory -Force | Out-Null
}

# 2. Sincronizar Config (Robocopy con modo Mirror)
# /MIR = Espejo perfecto (borra en el destino lo que no está en el origen)
# /XD = Excluir directorios pesados/innecesarios
# /XF = Excluir archivos dinámicos
Write-Host "🚀 Ejecutando Robocopy..." -ForegroundColor Cyan
robocopy $WINDOWS_CONFIG $WSL_CONFIG /MIR /XD .git undo view /XF lazy-lock.json /R:2 /W:5 | Out-Null

# 3. Copiar el ejecutable del Color Picker si existe
if (Test-Path $WINDOWS_PICKER) {
  $WSL_EXEC_PATH = Join-Path $WSL_PICKER_DIR "oklch-color-picker.exe"
  if (!(Test-Path $WSL_EXEC_PATH)) {
    Write-Host "📦 Copiando oklch-color-picker.exe desde Windows..." -ForegroundColor Cyan
    Copy-Item -Path $WINDOWS_PICKER -Destination $WSL_EXEC_PATH -Force
    Write-Host "✅ Ejecutable copiado correctamente" -ForegroundColor Green
  }
  else {
    Write-Host "✅ El ejecutable ya está presente en WSL" -ForegroundColor Green
  }
}
else {
  Write-Host "⚠️ oklch-color-picker.exe no encontrado en $WINDOWS_PICKER" -ForegroundColor Yellow
}

Write-Host "`n✅ ¡Sincronización Windows -> WSL completada!" -ForegroundColor Green
# sync-nvim.ps1 - Script para Windows Nativo (sin WSL)

# Definir rutas
$WINDOWS_CONFIG = "C:\Users\Diego\AppData\Local\nvim\"
$WSL_CONFIG = "\\wsl.localhost\archlinux\root\.config\nvim\"
$WINDOWS_PICKER = "C:\Users\Diego\AppData\Local\nvim-data\oklch-color-picker\oklch-color-picker.exe"
$WSL_PICKER_DIR = "\\wsl.localhost\archlinux\root\.local\share\nvim\oklch-color-picker\"

Write-Host "🔄 Sincronizando Neovim: Windows -> WSL..." -ForegroundColor Yellow

# 1. Crear la carpeta si no existe
if (!(Test-Path $WSL_CONFIG)) {
  New-Item -Path $WSL_CONFIG -ItemType Directory -Force | Out-Null
}
if (!(Test-Path $WSL_PICKER_DIR)) {
  New-Item -Path $WSL_PICKER_DIR -ItemType Directory -Force | Out-Null
}

# 2. Sincronizar Config (Robocopy es el equivalente a rsync)
# /MIR = Mirror (borra archivos en destino que no están en origen)
# /XD = Exclude Directories
# /XF = Exclude Files
robocopy $WINDOWS_CONFIG $WSL_CONFIG /MIR /XD .git undo view /XF lazy-lock.json /R:2 /W:5

# 3. Copiar el .exe de Windows si existe
if (Test-Path $WINDOWS_PICKER) {
  $WSL_EXEC_PATH = Join-Path $WSL_PICKER_DIR "oklch-color-picker.exe"
  if (!(Test-Path $WSL_EXEC_PATH)) {
    Write-Host "📦 Copiando oklch-color-picker.exe desde Windows..." -ForegroundColor Cyan
    Copy-Item -Path $WINDOWS_PICKER -Destination $WSL_EXEC_PATH -Force
    Write-Host "✅ Ejecutable copiado" -ForegroundColor Green
  }
  else {
    Write-Host "✅ Ejecutable ya existe en WSL" -ForegroundColor Green
  }
}
else {
  Write-Host "⚠️  oklch-color-picker.exe no encontrado en Windows" -ForegroundColor Yellow
  Write-Host "   Abre Neovim en Windows una vez para que se descargue"
}

Write-Host "✅ ¡Sincronización terminada!" -ForegroundColor Green
