#!/bin/bash

# --- COLORES ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔮 Iniciando Setup Maestro Arch-WSL...${NC}"

# 1. ACTUALIZACIÓN E INSTALACIÓN DE PAQUETES
echo -e "${GREEN}📦 Instalando paquetes esenciales...${NC}"
sudo pacman -Sy --noconfirm
sudo pacman -S --noconfirm git base-devel zsh sudo neovim rsync gcc ripgrep fd eza fastfetch stow fzf github-cli win32yank

# 2. CONFIGURAR OH MY ZSH
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${GREEN}🐚 Instalando Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 3. INSTALAR TEMAS Y PLUGINS
echo -e "${GREEN}🎨 Instalando Powerlevel10k y Plugins...${NC}"
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ] && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null
git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null
git clone https://github.com/zsh-users/zsh-completions.git "$ZSH_CUSTOM/plugins/zsh-completions" 2>/dev/null
git clone https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/zsh-history-substring-search" 2>/dev/null
git clone https://github.com/marlonrichert/zsh-autocomplete.git ~/.zsh/zsh-autocomplete 2>/dev/null
git clone https://github.com/Aloxaf/fzf-tab.git ~/.zsh/fzf-tab 2>/dev/null

# 4. CREAR SCRIPT DE SINCRONIZACIÓN NEOVIM (0-LAG)
echo -e "${GREEN}🚀 Configurando Sincronización Neovim...${NC}"
cat << 'EOF' > ~/sync-nvim.sh
#!/bin/zsh
# Definir rutas (AJUSTA EL USUARIO SI NO ES DIEGO)
WINDOWS_CONFIG="/mnt/c/Users/Diego/AppData/Local/nvim/"
WSL_CONFIG="$HOME/.config/nvim/"

mkdir -p "$WSL_CONFIG"
echo "🔄 Sincronizando Windows -> WSL..."
rsync -av --delete --exclude '.git' --exclude 'lazy-lock.json' --exclude 'undo' --exclude 'view' "$WINDOWS_CONFIG" "$WSL_CONFIG"
echo "✅ Neovim listo para usar en modo nativo."
EOF
chmod +x ~/sync-nvim.sh

# 5. CONFIGURACIÓN FINAL .ZSHRC
echo -e "${GREEN}📝 Añadiendo Alias y Funciones Inteligentes a .zshrc...${NC}"
if ! grep -q "sync-nvim" ~/.zshrc; then
cat << 'EOF' >> ~/.zshrc

# --- CONFIGURACIÓN AGREGADA POR SETUP AUTO ---
alias sync-nvim='~/sync-nvim.sh'

# Fallback inteligente para nvim (Prioriza Nativo > Windows Terminal)
function nvim() {
  local LINUX_NVIM=$(PATH=$(echo "$PATH" | sed -e 's/:\/mnt\/c[^:]*//g') whence -p nvim)
  if [[ -n "$LINUX_NVIM" ]]; then
    "$LINUX_NVIM" "$@"
  else
    wt.exe -d "$(wslpath -w "$PWD")" nvim.exe "$(wslpath -w "$1")"
  fi
}
EOF
fi

echo -e "${BLUE}✨ Setup Completado! Ejecuta 'source ~/.zshrc' para activar todo.${NC}"
