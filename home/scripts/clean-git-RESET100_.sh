#!/bin/bash
# ~/cleanup-dotfiles-dizzi.sh
# Limpia el repo de dotfiles-dizzi (452MB → ~50MB)

set -e # Salir si hay errores

REPO_PATH="$HOME/dotfiles-dizzi"
ASSETS_PATH="$HOME/dotfiles-assets"
BACKUP_PATH="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  🧹 LIMPIEZA DOTFILES-DIZZI                               ║"
echo "║  452MB → ~50MB (Reducción 89%)                            ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# ============================================
# 1. BACKUP DE SEGURIDAD
# ============================================
echo "📦 [1/6] Creando backup de seguridad..."
cp -r "$REPO_PATH/.git" "$BACKUP_PATH"
echo "   ✓ Backup guardado en: $BACKUP_PATH"
echo ""

cd "$REPO_PATH" || exit 1

# ============================================
# 2. MOVER WALLPAPERS FUERA DE GIT
# ============================================
echo "🖼️  [2/6] Moviendo wallpapers fuera de Git..."

# Crear directorio de assets si no existe
mkdir -p "$ASSETS_PATH"

# Mover wallpapers si existen
if [[ -d "wallpapers" ]]; then
  mv wallpapers "$ASSETS_PATH/" 2>/dev/null || echo "   ⚠️  wallpapers ya movidos"
  ln -sf "$ASSETS_PATH/wallpapers" wallpapers
  echo "   ✓ Wallpapers → $ASSETS_PATH/wallpapers"
fi

# Mover archivos grandes de configuración
if [[ -f "font/.config/font/minecraft_font.ttc" ]]; then
  mkdir -p "$ASSETS_PATH/fonts"
  mv "font/.config/font/minecraft_font.ttc" "$ASSETS_PATH/fonts/" 2>/dev/null || true
  ln -sf "$ASSETS_PATH/fonts/minecraft_font.ttc" "font/.config/font/minecraft_font.ttc"
  echo "   ✓ Fuente Minecraft → $ASSETS_PATH/fonts/"
fi

echo ""

# ============================================
# 3. CREAR .gitignore
# ============================================
echo "📝 [3/6] Creando .gitignore completo..."

cat >.gitignore <<'EOF'
# === ARCHIVOS GRANDES ===
wallpapers/
*.ttc
*.ttf
*.otf
*.woff2

# === CACHES ===
*.cache
*.pyc
__pycache__/
node_modules/
.vscode/
.idea/

# === TEMPORALES ===
*.tmp
*.swp
*.swo
*~
.DS_Store
Thumbs.db

# === LOGS ===
*.log
logs/

# === NVIM ESPECÍFICO ===
nvim*/.config/nvim/spell/*.spl
nvim*/.config/nvim/spell/*.spl.sug
local/.local/share/nvim/

# === COPYQ ===
copyq/.config/copyq/*.dat

# === ICONS ===
local/.local/share/icons/*.cache
local/.local/share/icons/*.png
EOF

git add .gitignore
echo "   ✓ .gitignore creado"
echo ""

# ============================================
# 4. ELIMINAR ARCHIVOS DEL ÍNDICE
# ============================================
echo "🗑️  [4/6] Eliminando archivos grandes del índice actual..."

# Remover del staging (sin borrar físicamente)
git rm -r --cached wallpapers/ 2>/dev/null || true
git rm --cached font/.config/font/minecraft_font.ttc 2>/dev/null || true
git rm --cached local/.local/share/icons/*.cache 2>/dev/null || true
git rm --cached copyq/.config/copyq/*.dat 2>/dev/null || true
git rm -r --cached local/.local/share/icons/ 2>/dev/null || true

echo "   ✓ Archivos removidos del índice"
echo ""

# ============================================
# 5. LIMPIAR HISTORIAL CON FILTER-REPO
# ============================================
echo "🔥 [5/6] Limpiando historial de Git (esto puede tardar)..."

# Verificar si filter-repo está instalado
if ! command -v git-filter-repo &>/dev/null; then
  echo "   📥 Instalando git-filter-repo..."
  pip install --user git-filter-repo --quiet
fi

# Eliminar archivos grandes del historial
git filter-repo --force \
  --path-glob 'wallpapers/*' --invert-paths \
  --path-glob '*.ttc' --invert-paths \
  --path-glob '*.cache' --invert-paths \
  --path-glob 'copyq/.config/copyq/*.dat' --invert-paths \
  --path-glob 'local/.local/share/icons/*' --invert-paths \
  --path 'nvim-gentleman/.config/nvim/spell/en_custom.txt' --invert-paths \
  --path 'nvim-gentleman/.config/nvim/spell/es_words.txt' --invert-paths

echo "   ✓ Historial limpiado"
echo ""

# ============================================
# 6. OPTIMIZAR REPOSITORIO
# ============================================
echo "⚡ [6/6] Optimizando repositorio..."

git reflog expire --expire=now --all
git gc --prune=now --aggressive
git repack -a -d --depth=50 --window=250

echo "   ✓ Repositorio optimizado"
echo ""

# ============================================
# RESULTADO FINAL
# ============================================
BEFORE_SIZE="452MB"
AFTER_SIZE=$(du -sh .git | awk '{print $1}')

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  ✅ LIMPIEZA COMPLETADA                                   ║"
echo "╠═══════════════════════════════════════════════════════════╣"
echo "║  Antes:  $BEFORE_SIZE                                          ║"
echo "║  Después: $AFTER_SIZE (estimado)                              ║"
echo "║                                                           ║"
echo "║  📂 Wallpapers movidos a: $ASSETS_PATH/wallpapers       ║"
echo "║  💾 Backup disponible en: $BACKUP_PATH                  ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# ============================================
# SIGUIENTE PASO
# ============================================
echo "🚀 SIGUIENTE PASO:"
echo ""
echo "   El repositorio remoto está desincronizado."
echo "   Debes hacer FORCE PUSH para subir los cambios:"
echo ""
echo "   git remote add origin https://github.com/dizzi1222/dotfiles-dizzi.git"
echo "   git push -u origin main --force"
echo ""
echo "   ⚠️  ADVERTENCIA: Esto reescribirá el historial remoto"
echo ""
echo "Presiona Enter para continuar..."
read

echo ""
echo "¿Ejecutar push --force ahora? (y/N): "
read -r PUSH_NOW

if [[ "$PUSH_NOW" =~ ^[Yy]$ ]]; then
  echo ""
  echo "🚀 Ejecutando git push --force..."

  # Re-añadir remote si fue eliminado por filter-repo
  git remote add origin https://github.com/dizzi1222/dotfiles-dizzi.git 2>/dev/null ||
    git remote set-url origin https://github.com/dizzi1222/dotfiles-dizzi.git

  git push -u origin main --force

  echo ""
  echo "✅ Push completado!"
  echo ""
  echo "📊 Verifica el tamaño en GitHub:"
  echo "   https://github.com/dizzi1222/dotfiles-dizzi"
else
  echo ""
  echo "⏸️  Push pospuesto. Ejecuta manualmente cuando estés listo:"
  echo "   git push -u origin main --force"
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  🎉 ¡PROCESO TERMINADO!                                   ║"
echo "╚═══════════════════════════════════════════════════════════╝"
