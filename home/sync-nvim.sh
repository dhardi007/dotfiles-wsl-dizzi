#!/bin/zsh

# Definir rutas
WINDOWS_CONFIG="/mnt/c/Users/Diego/AppData/Local/nvim/"
WSL_CONFIG="$HOME/.config/nvim/"
# oklch-color-picker: comentado porque auto_download descarga el binario Linux
# Descomentar si en el futuro funciona la versión Windows en WSL
# WINDOWS_PICKER="/mnt/c/Users/Diego/AppData/Local/nvim-data/oklch-color-picker/oklch-color-picker.exe"
# WSL_PICKER_DIR="$HOME/.local/share/nvim/oklch-color-picker"

echo "🔄 Sincronizando Neovim: Windows -> WSL..."

# 1. Crear la carpeta si no existe
mkdir -p "$WSL_CONFIG"
# mkdir -p "$WSL_PICKER_DIR"

# 2. Sincronizar Config
rsync -av --delete \
    --exclude '.git' \
    --exclude 'undo' \
    --exclude 'view' \
    --exclude 'lazy-lock.json' \
    "$WINDOWS_CONFIG" "$WSL_CONFIG"

# 3. Copiar el .exe de Windows si existe (comentado - usando versión Linux)
# if [ -f "$WINDOWS_PICKER" ]; then
#     if [ ! -f "$WSL_PICKER_DIR/oklch-color-picker.exe" ]; then
#         echo "📦 Copiando oklch-color-picker.exe desde Windows..."
#         cp "$WINDOWS_PICKER" "$WSL_PICKER_DIR/oklch-color-picker.exe"
#         chmod +x "$WSL_PICKER_DIR/oklch-color-picker.exe"
#         echo "✅ Ejecutable copiado y permisos asignados"
#     else
#         echo "✅ Ejecutable ya existe en WSL"
#     fi
# else
#     echo "⚠️  oklch-color-picker.exe no encontrado en Windows"
#     echo "   Abre Neovim en Windows una vez para que se descargue"
# fi

echo "✅ ¡Sincronización terminada! Los archivos ahora son nativos de WSL."
