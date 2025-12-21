# sync-nvim.ps1 - Script para Windows Nativo (sin WSL)

$CONFIG_PATH = "$env:LOCALAPPDATA\nvim"
$DATA_PATH = "$env:LOCALAPPDATA\nvim-data"
$PICKER_PATH = "$DATA_PATH\oklch-color-picker"
$PARSER_FILE = "tree-sitter-css.wasm"
$PARSER_PATH = "$PICKER_PATH\$PARSER_FILE"
$PARSER_URL = "https://github.com/eero-lehtinen/oklch-color-picker.nvim/releases/latest/download/$PARSER_FILE"

Write-Host "🔄 Configurando Neovim en Windows..." -ForegroundColor Cyan

# Crear directorios si no existen
New-Item -ItemType Directory -Force -Path $PICKER_PATH | Out-Null

# Verificar si existe el parser
if (Test-Path $PARSER_PATH) {
    Write-Host "✅ Parser ya existe: $PARSER_PATH" -ForegroundColor Green
} else {
    Write-Host "⚠️  Parser no encontrado" -ForegroundColor Yellow
    Write-Host "📥 Descargando desde GitHub..." -ForegroundColor Cyan
    
    try {
        Invoke-WebRequest -Uri $PARSER_URL -OutFile $PARSER_PATH -ErrorAction Stop
        Write-Host "✅ Parser descargado exitosamente" -ForegroundColor Green
        Write-Host "📍 Ubicación: $PARSER_PATH" -ForegroundColor Gray
    } catch {
        Write-Host "❌ Error al descargar: $_" -ForegroundColor Red
        Write-Host "Intenta manualmente con:" -ForegroundColor Yellow
        Write-Host "Invoke-WebRequest -Uri '$PARSER_URL' -OutFile '$PARSER_PATH'" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "✅ Configuración completada!" -ForegroundColor Green
