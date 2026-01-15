#!/bin/bash

# --- COLORES ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- VARIABLES ---
WINDOWS_USER="Diego"
WIN_HOME="/mnt/c/Users/$WINDOWS_USER"
WIN_APPDATA="$WIN_HOME/AppData/Local"

echo -e "${BLUE}🔮 Iniciando Setup Maestro Arch-WSL (Diego Edition v5 - PERFECTED)...${NC}"

# ═══════════════════════════════════════════════════════════
# 0. VERIFICAR PERMISOS Y DETECTAR USUARIO
# ═══════════════════════════════════════════════════════════
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}❌ Este script debe ejecutarse con sudo${NC}"
  echo -e "${YELLOW}Ejecuta: sudo bash $0${NC}"
  exit 1
fi

# Detectar usuario real
REAL_USER=$SUDO_USER
if [ -z "$REAL_USER" ]; then
  REAL_USER=$(ls /home | head -n 1)
fi
[ -z "$REAL_USER" ] && REAL_USER="diego"

# Detectar grupo principal del usuario
USER_GROUP=$(id -gn "$REAL_USER")

HOME_DIR="/home/$REAL_USER"
DOTFILES_DIR="$HOME_DIR/dotfiles-wsl-dizzi"
WORKSPACE_DIR="$HOME_DIR/workspace"

echo -e "${YELLOW}👤 Usuario: $REAL_USER${NC}"
echo -e "${YELLOW}👥 Grupo: $USER_GROUP${NC}"
echo -e "${YELLOW}📁 Home: $HOME_DIR${NC}"
echo ""

# Función CORREGIDA para ejecutar como usuario
run_as_user() {
  sudo -u "$REAL_USER" bash <<EOF
cd "$HOME_DIR"
$1
EOF
}

# ═══════════════════════════════════════════════════════════
# INTRO
# ═══════════════════════════════════════════════════════════
clear
cat <<"ASCIIART"

░██╗░░░░░░░██╗░██████╗██╗░░░░░
░██║░░██╗░░██║██╔════╝██║░░░░░
░╚██╗████╗██╔╝╚█████╗░██║░░░░░
░░████╔═████║░░╚═══██╗██║░░░░░
░░╚██╔╝░╚██╔╝░██████╔╝███████╗
░░░╚═╝░░░╚═╝░░╚═════╝░╚══════╝

╔══════════════════════════════════════════════════════════════════════╗
║        🚀 INSTALACIÓN ULTRA-FAST WSL 🚀          	               ║
║            VERSIÓN PERFECTED V5                                      ║
╚══════════════════════════════════════════════════════════════════════╝

ASCIIART

sleep 2

# ═══════════════════════════════════════════════════════════
# 1. ARREGLAR PERMISOS
# ═══════════════════════════════════════════════════════════
echo -e "${GREEN}🔧 Arreglando permisos...${NC}"
chown -R "$REAL_USER:$USER_GROUP" "$HOME_DIR" 2>/dev/null || true
chmod 755 "$HOME_DIR"

mkdir -p "$HOME_DIR/.local/bin"
mkdir -p "$HOME_DIR/.local/share"
mkdir -p "$HOME_DIR/.config"
mkdir -p "$HOME_DIR/.cache"
mkdir -p "$HOME_DIR/.npm"
mkdir -p "$HOME_DIR/.npm-global"

chown -R "$REAL_USER:$USER_GROUP" "$HOME_DIR/.local"
chown -R "$REAL_USER:$USER_GROUP" "$HOME_DIR/.config"
chown -R "$REAL_USER:$USER_GROUP" "$HOME_DIR/.cache"
chown -R "$REAL_USER:$USER_GROUP" "$HOME_DIR/.npm" 2>/dev/null || true
chown -R "$REAL_USER:$USER_GROUP" "$HOME_DIR/.npm-global" 2>/dev/null || true

# ═══ NUEVO: Permisos para scripts en dotfiles ═══
if [ -d "$DOTFILES_DIR" ]; then
  echo -e "${YELLOW}   Arreglando permisos de scripts...${NC}"

  # Wallpaper script
  if [ -f "$DOTFILES_DIR/home/wallpaper-prompt-fastfetch" ]; then
    chmod +x "$DOTFILES_DIR/home/wallpaper-prompt-fastfetch"
    chown "$REAL_USER:$USER_GROUP" "$DOTFILES_DIR/home/wallpaper-prompt-fastfetch"
    echo -e "   ✓ wallpaper-prompt-fastfetch ejecutable"
  fi

  # Sync scripts si existen
  for script in sync-nvim.sh sync-wal.sh; do
    if [ -f "$DOTFILES_DIR/home/$script" ]; then
      chmod +x "$DOTFILES_DIR/home/$script"
      chown "$REAL_USER:$USER_GROUP" "$DOTFILES_DIR/home/$script"
      echo -e "   ✓ $script ejecutable"
    fi
  done

  # Todos los .sh en home
  find "$DOTFILES_DIR/home" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
  find "$DOTFILES_DIR/home" -type f -name "*.sh" -exec chown "$REAL_USER:$USER_GROUP" {} \; 2>/dev/null || true
fi

echo -e "✅ Permisos corregidos"

# ═══════════════════════════════════════════════════════════
# 2. PAQUETES ESENCIALES
# ═══════════════════════════════════════════════════════════
echo -e "${GREEN}📦 Instalando paquetes esenciales...${NC}"
pacman -Sy --needed --noconfirm
pacman -S --needed --noconfirm \
  git base-devel zsh neovim rsync gcc \
  ripgrep fd eza fastfetch stow fzf \
  github-cli python-pywal imagemagick \
  python-pip expat nodejs npm curl wget

# ═══════════════════════════════════════════════════════════
# 3. YAY
# ═══════════════════════════════════════════════════════════
echo -e "${GREEN}🔧 Verificando yay...${NC}"

if ! run_as_user "command -v yay" &>/dev/null; then
  echo -e "${YELLOW}   Instalando yay...${NC}"

  rm -rf /tmp/yay-bin
  run_as_user "
    cd /tmp
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si --noconfirm
  "

  if run_as_user "command -v yay" &>/dev/null; then
    echo -e "${GREEN}   ✓ yay instalado${NC}"
  else
    echo -e "${RED}   ✗ yay falló${NC}"
  fi
else
  echo -e "${GREEN}   ✓ yay ya instalado${NC}"
fi

# ═══════════════════════════════════════════════════════════
# 4. PAQUETES AUR
# ═══════════════════════════════════════════════════════════
echo -e "${GREEN}📦 Instalando paquetes AUR...${NC}"
run_as_user "yay -S --needed --noconfirm pokemon-colorscripts-git win32yank-bin" || {
  echo -e "${YELLOW}⚠️ Algunos paquetes AUR fallaron${NC}"
}

# ═══════════════════════════════════════════════════════════
# 5. PYWAL BACKENDS
# ═══════════════════════════════════════════════════════════
echo -e "${GREEN}🎨 Instalando backends de Pywal...${NC}"
run_as_user "pip install --user --upgrade colorz colorthief haishoku --break-system-packages" || {
  echo -e "${YELLOW}⚠️ Algunos backends fallaron${NC}"
}

# ═══════════════════════════════════════════════════════════
# 6. CONFIGURAR NPM GLOBAL
# ═══════════════════════════════════════════════════════════
echo -e "${GREEN}🔧 Configurando npm global...${NC}"

run_as_user "npm config set prefix \"\$HOME/.npm-global\""

# Agregar PATH a shell configs si no existe
for rc in .zshrc .bashrc; do
  if [ -f "$HOME_DIR/$rc" ]; then
    if ! grep -q ".npm-global/bin" "$HOME_DIR/$rc"; then
      echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >>"$HOME_DIR/$rc"
      chown "$REAL_USER:$USER_GROUP" "$HOME_DIR/$rc"
    fi
  fi
done

echo -e "✅ npm configurado"

# ═══════════════════════════════════════════════════════════
# 7. HERRAMIENTAS IA
# ═══════════════════════════════════════════════════════════
echo -e "${GREEN}🤖 Instalando herramientas de IA...${NC}"

# tgpt
if ! run_as_user "command -v tgpt" &>/dev/null; then
  echo -e "${YELLOW}   Instalando tgpt...${NC}"
  run_as_user "yay -S --needed --noconfirm opencommit tgpt-git ollama-bin opencode tabnine claude-code" &&
    echo -e "${GREEN}   ✓ tgpt instalado${NC}" ||
    echo -e "${YELLOW}   ⚠️ tgpt falló${NC}"
else
  echo -e "${GREEN}   ✓ tgpt ya instalado${NC}"
fi

# Gemini CLI
if ! run_as_user "command -v gemini" &>/dev/null; then
  echo -e "${YELLOW}   Instalando Gemini CLI...${NC}"
  run_as_user "
    export PATH=\"\$HOME/.npm-global/bin:\$PATH\"
    npm install -g @google/gemini-cli
  " &&
    echo -e "${GREEN}   ✓ Gemini CLI instalado${NC}" ||
    echo -e "${YELLOW}   ⚠️ Gemini CLI falló${NC}"
else
  echo -e "${GREEN}   ✓ Gemini CLI ya instalado${NC}"
fi

# opencommit
if ! run_as_user "command -v oco" &>/dev/null; then
  echo -e "${YELLOW}   Instalando opencommit...${NC}"
  run_as_user "
    export PATH=\"\$HOME/.npm-global/bin:\$PATH\"
    npm install -g opencommit
  " && {
    echo -e "${GREEN}   ✓ opencommit instalado${NC}"

    # Configurar para Ollama si está disponible
    if curl -s http://localhost:11434/api/tags &>/dev/null; then
      echo -e "${BLUE}   [⚡] Configurando para Ollama...${NC}"
      run_as_user "
        export PATH=\"\$HOME/.npm-global/bin:\$PATH\"
        oco config set OCO_AI_PROVIDER=ollama
        oco config set OCO_MODEL=qwen3-vl:235b-cloud
        oco config set OCO_API_URL=http://localhost:11434
        oco config set OCO_LANGUAGE=es
      " 2>/dev/null || true
      echo -e "${GREEN}   ✓ Configurado para Ollama${NC}"
    else
      echo -e "${YELLOW}   ⚠️ Ollama no detectado, configura con OpenAI:${NC}"
      echo -e "      ${BLUE}oco config set OCO_API_KEY=sk-tu-key${NC}"
    fi
  } || echo -e "${YELLOW}   ⚠️ opencommit falló${NC}"
else
  echo -e "${GREEN}   ✓ opencommit ya instalado${NC}"
fi

echo -e "${GREEN}✅ Herramientas IA instaladas${NC}"
echo ""

# ═══════════════════════════════════════════════════════════
# 8. DRIVE I: (OPCIONAL)
# ═══════════════════════════════════════════════════════════
echo -e "${GREEN}📂 Configurando Drive I:...${NC}"
if ! grep -q "I:" /etc/fstab; then
  echo "I: /mnt/i drvfs defaults 0 0" >>/etc/fstab
  mkdir -p /mnt/i 2>/dev/null || true
  mount /mnt/i 2>/dev/null || echo -e "${YELLOW}⚠️ I: no disponible${NC}"
  echo -e "✅ Drive I: agregado"
else
  echo -e "✅ Drive I: ya configurado"
fi

# ═══════════════════════════════════════════════════════════
# 9. ZSH + OH-MY-ZSH
# ═══════════════════════════════════════════════════════════
echo -e "${GREEN}🐚 Configurando Zsh...${NC}"

if [ ! -d "$HOME_DIR/.oh-my-zsh" ]; then
  echo -e "${YELLOW}   Instalando Oh My Zsh...${NC}"
  run_as_user 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
  echo -e "${GREEN}   ✓ Oh My Zsh instalado${NC}"
fi

# Plugins
echo -e "${YELLOW}   Instalando plugins...${NC}"
ZSH_CUSTOM="$HOME_DIR/.oh-my-zsh/custom"

if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  run_as_user "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git '$ZSH_CUSTOM/themes/powerlevel10k'"
fi

for plugin in zsh-syntax-highlighting zsh-autosuggestions zsh-completions zsh-history-substring-search; do
  if [ ! -d "$ZSH_CUSTOM/plugins/$plugin" ]; then
    run_as_user "git clone https://github.com/zsh-users/$plugin.git '$ZSH_CUSTOM/plugins/$plugin' 2>/dev/null || true"
  fi
done

~/zsh-istall-wsl.sh

echo -e "${GREEN}✅ Zsh configurado${NC}"

# ═══════════════════════════════════════════════════════════
# 10. DOTFILES (STOW)
# ═══════════════════════════════════════════════════════════
echo -e "${GREEN}🔗 Aplicando dotfiles con Stow...${NC}"

if [[ ! -d ~/dotfiles-wsl-dizzi ]]; then
  print_installing "Clonando dotfiles desde GitHub"
  git clone https://github.com/dizzi1222/dotfiles-dizzi.git ~/dotfiles-dizzi || {
    print_warning "Error clonando dotfiles"
  }
fi

if [[ -d ~/dotfiles-wsl-dizzi ]]; then
  cd ~/dotfiles-dizzi

  print_status "Inicializando submódulos git..."
  git submodule update --init --recursive 2>/dev/null || print_warning "No hay submódulos o falló su actualización"

  print_status "Aplicando dotfiles con stow..."

  for pkg in fastfetch home nvim-wsl yazi htop tmux zsh; do
    if [[ -d $pkg ]]; then
      print_package "Stow: $pkg"
      stow $pkg 2>/dev/null || print_warning "Stow falló para $pkg"
    fi
  done

  cd ~
  print_success "Dotfiles aplicados"
fi

# ═══════════════════════════════════════════════════════════
# 11. NEOVIM SYNC
# ═══════════════════════════════════════════════════════════
echo -e "${GREEN}🚀 Sincronizando Neovim...${NC}"
if [ -d "$DOTFILES_DIR/nvim-wsl" ]; then
  mkdir -p "$WIN_APPDATA/nvim"
  rsync -av --delete --exclude '.git' "$DOTFILES_DIR/nvim-wsl/" "$WIN_APPDATA/nvim/"
  echo -e "${GREEN}✅ Neovim sincronizado${NC}"
fi

# ═══════════════════════════════════════════════════════════
# 12. .ZSHRC + ALIASES
# ═══════════════════════════════════════════════════════════
echo -e "${GREEN}📝 Configurando .zshrc...${NC}"
ZSHRC="$HOME_DIR/.zshrc"

if [ ! -f "$ZSHRC" ]; then
  touch "$ZSHRC"
  chown "$REAL_USER:$USER_GROUP" "$ZSHRC"
fi

if ! grep -q "opencommit aliases" "$ZSHRC"; then
  cat <<'ZSHRC_CONTENT' >>"$ZSHRC"

# ═══════════════════════════════════════════════════════════
# AUTO-GENERATED BY SETUP
# ═══════════════════════════════════════════════════════════

# Sync scripts
alias sync-nvim='~/sync-nvim.sh'
alias sync-wal='~/sync-wal.sh'

# Neovim wrapper
function nvim() {
  local LINUX_NVIM=$(PATH=$(echo "$PATH" | sed -e 's/:\/mnt\/c[^:]*//g') whence -p nvim)
  if [[ -n "$LINUX_NVIM" ]]; then
    "$LINUX_NVIM" "$@"
  else
    wt.exe -d "$(wslpath -w "$PWD")" nvim.exe "$(wslpath -w "$1")"
  fi
}

# Pywal colors
(cat ~/.cache/wal/sequences &) 2>/dev/null

# ═══════════════════════════════════════════════════════════
# opencommit aliases
# ═══════════════════════════════════════════════════════════
alias aicommit='oco'                         # Commit con IA
alias oc='oco'                               # Ultra-corto
alias aiconfig='oco config get'              # Ver config
alias aikey='oco config set OCO_API_KEY'     # Set API key
alias aimodel='oco config set OCO_MODEL'     # Cambiar modelo
alias aigit='git add . && oco'               # Add + commit
alias aipush='git add . && oco && git push'  # Add + commit + push
ZSHRC_CONTENT

  chown "$REAL_USER:$USER_GROUP" "$ZSHRC"
  echo -e "${GREEN}✅ .zshrc configurado${NC}"
fi

# ═══════════════════════════════════════════════════════════
# 13. SYMLINKS
# ═══════════════════════════════════════════════════════════
if [ -f "$HOME_DIR/.fdignore" ]; then
  rm -f "/mnt/c/Users/$WINDOWS_USER/.fdignore"
  ln -sf "$HOME_DIR/.fdignore" "/mnt/c/Users/$WINDOWS_USER/.fdignore" 2>/dev/null || true
fi

# ═══════════════════════════════════════════════════════════
# 14. POWERSHELL CONFIG
# ═══════════════════════════════════════════════════════════
echo -e "${GREEN}🪟 Configurando PowerShell...${NC}"

# Git Bash locale
GIT_BASHRC="/mnt/c/Users/$WINDOWS_USER/.bashrc"
if [ ! -f "$GIT_BASHRC" ] || ! grep -q "LC_ALL=C.UTF-8" "$GIT_BASHRC"; then
  cat >>"$GIT_BASHRC" <<'BASHRC'
# Fix Git locale warnings
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export LC_CTYPE=C.UTF-8
BASHRC
  echo -e "✅ Git Bash configurado"
fi

# ═══════════════════════════════════════════════════════════
# 15. CAMBIAR SHELL
# ═══════════════════════════════════════════════════════════
echo -e "${GREEN}🐚 Configurando Zsh como shell por defecto...${NC}"
if [ "$(getent passwd $REAL_USER | cut -d: -f7)" != "/bin/zsh" ]; then
  chsh -s /bin/zsh "$REAL_USER" 2>/dev/null ||
    echo -e "${YELLOW}⚠️ Cambio de shell manual requerido${NC}"
fi

# ═══════════════════════════════════════════════════════════
# RESUMEN
# ═══════════════════════════════════════════════════════════
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${CYAN}🤖 HERRAMIENTAS INSTALADAS${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""

if run_as_user "command -v tgpt" &>/dev/null; then
  echo -e "${GREEN}✓${NC} tgpt - Terminal GPT"
fi

if run_as_user "command -v gemini" &>/dev/null; then
  echo -e "${GREEN}✓${NC} Gemini CLI"
fi

if run_as_user "command -v oco" &>/dev/null; then
  echo -e "${GREEN}✓${NC} opencommit (oco)"

  # Verificar si está configurado para Ollama
  if curl -s http://localhost:11434/api/tags &>/dev/null; then
    echo -e "   ${BLUE}Configurado para:${NC} Ollama (qwen3-vl:235b-cloud)"
  else
    echo -e "   ${YELLOW}Configura API key:${NC} aikey sk-tu-key"
  fi
fi

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${CYAN}✨ SETUP COMPLETADO${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Próximos pasos:${NC}"
echo -e "  1. ${BLUE}exit${NC} (salir de root)"
echo -e "  2. ${BLUE}exec zsh${NC} (reiniciar shell)"
echo -e "  3. Verificar: ${BLUE}which oco${NC}"
echo ""
echo -e "${YELLOW}Uso de opencommit:${NC}"
echo -e "  ${BLUE}git add .${NC}"
echo -e "  ${BLUE}aicommit${NC}  ${GREEN}# Genera commit automático${NC}"
echo ""
