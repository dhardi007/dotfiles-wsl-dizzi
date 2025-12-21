#!/bin/zsh

# Definir rutas
WINDOWS_CONFIG="/mnt/c/Users/Diego/AppData/Local/nvim/"
WSL_CONFIG="$HOME/.config/nvim/"

echo "🔄 Sincronizando Neovim: Windows -> WSL..."

# 1. Crear la carpeta si no existe
mkdir -p "$WSL_CONFIG"

# 2. Sincronizar (usamos rsync para que sea instantáneo)
# --delete: borra en WSL lo que borraste en Windows para que estén IGUALES
# --exclude: evita copiar carpetas pesadas de cache que no sirven entre OS
rsync -av --delete \
    --exclude '.git' \
    --exclude 'undo' \
    --exclude 'view' \
    --exclude 'lazy-lock.json' \
    "$WINDOWS_CONFIG" "$WSL_CONFIG"

echo "✅ ¡Sincronización terminada! Los archivos ahora son nativos de WSL."
