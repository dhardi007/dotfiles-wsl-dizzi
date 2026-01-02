#!/bin/bash
# zsh-setup-final.sh - Configuración definitiva de Zsh con dotfiles
# Versión WSL adaptada para dotfiles-wsl-dizzi
# Después de esto, solo necesitas: git clone + stow zsh

set -e

DOTFILES_DIR="$HOME/dotfiles-wsl-dizzi" # ← CAMBIO 1: Ruta WSL
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}🚀 Setup DEFINITIVO de Zsh - WSL Edition${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
echo ""

cd "$DOTFILES_DIR"

# ═══════════════════════════════════════════════════════════
# 1. LIMPIAR SUBMÓDULOS (adiós para siempre)
# ═══════════════════════════════════════════════════════════
echo -e "${YELLOW}🧹 Paso 1: Eliminando submódulos (nunca más los necesitarás)...${NC}"

# Eliminar el symlink problemático
rm -f zsh/.oh-my-zsh/.oh-my-zsh
cd ~/dotfiles-wsl-dizzi # ← CAMBIO 2: Ruta WSL

# Eliminar el directorio problemático de forma recursiva
rm -rf zsh/.oh-my-zsh/.oh-my-zsh

# Eliminar todos los submódulos
if [ -f .gitmodules ]; then
  git submodule deinit -f .
  rm -rf .git/modules/zsh
  git rm -rf zsh/.oh-my-zsh/custom/plugins/* 2>/dev/null || true
  git rm -rf zsh/.oh-my-zsh/custom/themes/* 2>/dev/null || true
  git rm -rf zsh/.zsh/* 2>/dev/null || true
  # rm -f .gitmodules
fi

echo -e "${GREEN}✅ Submódulos eliminados${NC}"
echo ""

# ═══════════════════════════════════════════════════════════
# 2. CREAR ESTRUCTURA DE DIRECTORIOS
# ═══════════════════════════════════════════════════════════
echo -e "${YELLOW}📁 Paso 2: Creando estructura de directorios...${NC}"

mkdir -p zsh/.oh-my-zsh/custom/plugins
mkdir -p zsh/.oh-my-zsh/custom/themes
mkdir -p zsh/.zsh

echo -e "${GREEN}✅ Estructura creada${NC}"
echo ""

# ═══════════════════════════════════════════════════════════
# 3. CLONAR PLUGINS DIRECTAMENTE (sin submódulos)
# ═══════════════════════════════════════════════════════════
echo -e "${YELLOW}📦 Paso 3: Descargando plugins (esto tomará un momento)...${NC}"

# Plugins de Oh My Zsh
declare -A PLUGINS_OMZ=(
  ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
  ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions.git"
  ["zsh-completions"]="https://github.com/zsh-users/zsh-completions.git"
  ["zsh-history-substring-search"]="https://github.com/zsh-users/zsh-history-substring-search.git"
  ["alias-tips"]="https://github.com/djui/alias-tips.git"
  ["zsh-vi-mode"]="https://github.com/jeffreytse/zsh-vi-mode.git"
)

for plugin in "${!PLUGINS_OMZ[@]}"; do
  PLUGIN_PATH="zsh/.oh-my-zsh/custom/plugins/$plugin"
  if [ -d "$PLUGIN_PATH/.git" ]; then
    echo -e "  ${BLUE}↻ Actualizando $plugin...${NC}"
    (cd "$PLUGIN_PATH" && git pull)
  elif [ ! -d "$PLUGIN_PATH" ]; then
    echo -e "  ${GREEN}↓ Descargando $plugin...${NC}"
    git clone --depth 1 "${PLUGINS_OMZ[$plugin]}" "$PLUGIN_PATH"
  else
    echo -e "  ${GREEN}✅ $plugin ya existe${NC}"
  fi
done

# Tema Powerlevel10k
THEME_PATH="zsh/.oh-my-zsh/custom/themes/powerlevel10k"
if [ -d "$THEME_PATH/.git" ]; then
  echo -e "  ${BLUE}↻ Actualizando powerlevel10k...${NC}"
  (cd "$THEME_PATH" && git pull)
elif [ ! -d "$THEME_PATH" ]; then
  echo -e "  ${GREEN}↓ Descargando powerlevel10k...${NC}"
  git clone --depth 1 https://github.com/romkatv/powerlevel10k.git "$THEME_PATH"
else
  echo -e "  ${GREEN}✅ powerlevel10k ya existe${NC}"
fi

# Plugins externos
declare -A PLUGINS_EXTERNAL=(
  ["fzf-tab"]="https://github.com/Aloxaf/fzf-tab.git"
  ["zsh-autocomplete"]="https://github.com/marlonrichert/zsh-autocomplete.git"
)

for plugin in "${!PLUGINS_EXTERNAL[@]}"; do
  PLUGIN_PATH="zsh/.zsh/$plugin"
  if [ -d "$PLUGIN_PATH/.git" ]; then
    echo -e "  ${BLUE}↻ Actualizando $plugin...${NC}"
    (cd "$PLUGIN_PATH" && git pull)
  elif [ ! -d "$PLUGIN_PATH" ]; then
    echo -e "  ${GREEN}↓ Descargando $plugin...${NC}"
    git clone --depth 1 "${PLUGINS_EXTERNAL[$plugin]}" "$PLUGIN_PATH"
  else
    echo -e "  ${GREEN}✅ $plugin ya existe${NC}"
  fi
done

echo ""
echo -e "${GREEN}✅ Todos los plugins descargados${NC}"
echo ""

# ═══════════════════════════════════════════════════════════
# 4. LIMPIAR .git DE LOS PLUGINS (importante)
# ═══════════════════════════════════════════════════════════
echo -e "${YELLOW}🧹 Paso 4: Convirtiendo plugins a archivos normales...${NC}"

find zsh/.oh-my-zsh/custom/plugins -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true
find zsh/.oh-my-zsh/custom/themes -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true
find zsh/.zsh -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true

echo -e "${GREEN}✅ Plugins convertidos a archivos normales${NC}"
echo ""

# ═══════════════════════════════════════════════════════════
# 5. AGREGAR TODO A GIT
# ═══════════════════════════════════════════════════════════
echo -e "${YELLOW}📤 Paso 5: Agregando todo al repositorio...${NC}"

git add zsh/
git status

echo ""
echo -e "${GREEN}✅ Archivos listos para commit${NC}"
echo ""

# ═══════════════════════════════════════════════════════════
# 6. INSTALAR OH MY ZSH EN EL SISTEMA
# ═══════════════════════════════════════════════════════════
echo -e "${YELLOW}🔧 Paso 6: Instalando Oh My Zsh en el sistema...${NC}"

if [ ! -d ~/.oh-my-zsh ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  echo -e "${GREEN}✅ Oh My Zsh instalado${NC}"
else
  echo -e "${GREEN}✅ Oh My Zsh ya está instalado${NC}"
fi

echo ""

# ═══════════════════════════════════════════════════════════
# 7. APLICAR CONFIGURACIÓN CON STOW
# ═══════════════════════════════════════════════════════════
echo -e "${YELLOW}🔗 Paso 7: Aplicando configuración con Stow...${NC}"

stow -R zsh

echo -e "${GREEN}✅ Configuración aplicada${NC}"
echo ""

# ═══════════════════════════════════════════════════════════
# 8. VERIFICACIÓN FINAL
# ═══════════════════════════════════════════════════════════
echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}🔍 VERIFICACIÓN FINAL${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
echo ""

ALL_PLUGINS=(
  "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
  "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
  "$HOME/.oh-my-zsh/custom/plugins/zsh-completions"
  "$HOME/.oh-my-zsh/custom/plugins/zsh-history-substring-search"
  "$HOME/.oh-my-zsh/custom/plugins/alias-tips"
  "$HOME/.oh-my-zsh/custom/plugins/zsh-vi-mode"
  "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
  "$HOME/.zsh/fzf-tab"
  "$HOME/.zsh/zsh-autocomplete"
)

MISSING_COUNT=0
for plugin in "${ALL_PLUGINS[@]}"; do
  PLUGIN_NAME=$(basename "$plugin")
  if [ -d "$plugin" ]; then
    echo -e "${GREEN}  ✅ $PLUGIN_NAME${NC}"
  else
    echo -e "${RED}  ❌ $PLUGIN_NAME FALTA${NC}"
    ((MISSING_COUNT++))
  fi
done

echo ""
if [ $MISSING_COUNT -eq 0 ]; then
  echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
  echo -e "${GREEN}✅ ¡PERFECTO! Todo está configurado correctamente${NC}"
  echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
  echo ""
  echo -e "${YELLOW}📋 PRÓXIMOS PASOS:${NC}"
  echo ""
  echo -e "${BLUE}1.${NC} Hacer commit de los cambios:"
  echo -e "   ${YELLOW}git commit -m \"feat: add all zsh plugins as regular files\"${NC}"
  echo ""
  echo -e "${BLUE}2.${NC} Subir al repositorio:"
  echo -e "   ${YELLOW}git push${NC}"
  echo ""
  echo -e "${BLUE}3.${NC} En cualquier otra máquina WSL, solo necesitas:"
  echo -e "   ${YELLOW}git clone tu-repo${NC}"
  echo -e "   ${YELLOW}cd dotfiles-wsl-dizzi${NC}"
  echo -e "   ${YELLOW}stow zsh${NC}"
  echo -e "   ${YELLOW}exec zsh${NC}"
  echo ""
  echo -e "${GREEN}🎉 ¡NUNCA MÁS tendrás que configurar Zsh en WSL!${NC}"
else
  echo -e "${RED}⚠️  Faltan $MISSING_COUNT plugins. Revisa los errores arriba.${NC}"
fi

echo ""
