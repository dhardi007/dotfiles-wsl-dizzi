# =============================================================================
#
#                    CONFIGURACIÓN DE ZSH EN ARCH LINUX WSL
#
# =============================================================================


# Mapeo de teclas para la edición de comandos.
bindkey '^H' backward-kill-word
bindkey '^[[3;5~' kill-word
bindkey '^W' backward-kill-word
bindkey '^?' backward-kill-word


# Configuración de Oh My Zsh.
export ZSH="$HOME/.oh-my-zsh"

# DESACTIVAR UPDATES DE OH MY ZSH 🚨
zstyle ':omz:update' mode disabled  # disable automatic updates

# Mi tema preferido. ACTIVAR OH MY ZASH/ zsh
ZSH_THEME="powerlevel10k/powerlevel10k"

# Lista de plugins a cargar.
plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  zsh-completions
  zsh-history-substring-search
)

source $ZSH/oh-my-zsh.sh


# =============================================================================
#
#                      CONFIGURACIÓN DE HERRAMIENTAS Y PATH
#
# =============================================================================


# 📌 [Abrir nvim en windows terminal]Añade la ruta de Neovim de Windows al PATH de WSL.
export PATH="/mnt/c/Program Files/Neovim/bin:$PATH"
# alias nvim='wt.exe -d "$(wslpath -w "$PWD")" nvim.exe'

function nvim() {
  # 'whence -p' busca solo binarios externos, ignorando alias y funciones
  local LINUX_NVIM=$(PATH=$(echo "$PATH" | sed -e 's/:\/mnt\/c[^:]*//g') whence -p nvim)

  if [[ -n "$LINUX_NVIM" ]]; then
    "$LINUX_NVIM" "$@"
  else
    if [[ -z "$1" ]]; then
      wt.exe -d "$(wslpath -w "$PWD")" nvim.exe
    else
      wt.exe -d "$(wslpath -w "$PWD")" nvim.exe "$(wslpath -w "$1")"
    fi
  fi
}
# 📌 [Abrir Antigravity o VSCode]
# Si Antigravity está instalado, lo abre; si no, abre > Cursor > VSCode
export PATH="/mnt/c/Users/Diego/AppData/Local/Programs/Microsoft VS Code:$PATH"

function code() {
  # Ruta al ejecutable de Antigravity
  local ANTIGRAVITY_PATH="/mnt/c/Users/Diego/AppData/Local/Programs/Antigravity/Antigravity.exe"
  local CURSOR_PATH="/mnt/c/Users/Diego/AppData/Local/Programs/Cursor/Cursor.exe"

  # Verificar si Antigravity existe
  if [[ -f "$ANTIGRAVITY_PATH" ]]; then
    if [[ -z "$1" ]]; then
      "$ANTIGRAVITY_PATH" .
    else
      "$ANTIGRAVITY_PATH" "$(wslpath -w "$1")"
    fi
  # Si no existe Antigravity, verificar si existe Cursor
  elif [[ -f "$CURSOR_PATH" ]]; then
    if [[ -z "$1" ]]; then
      "$CURSOR_PATH" .
    else
      "$CURSOR_PATH" "$(wslpath -w "$1")"
    fi
  # Si no existe ninguno, usar VS Code
  else
    if [[ -z "$1" ]]; then
      /mnt/c/Users/Diego/AppData/Local/Programs/Microsoft\ VS\ Code/Code.exe .
    else
      /mnt/c/Users/Diego/AppData/Local/Programs/Microsoft\ VS\ Code/Code.exe "$(wslpath -w "$1")"
    fi
  fi
}

# 📌 [Comandos individuales breves]
# 📌  Antigravity (si está instalado)
function antigravity() {
  local EXE="/mnt/c/Users/Diego/AppData/Local/Programs/Antigravity/Antigravity.exe"
  if [[ -f "$EXE" ]]; then
    if [[ -z "$1" ]]; then
      "$EXE" .
    else
      "$EXE" "$(wslpath -w "$1")"
    fi
  else
    echo "❌ Antigravity no está instalado"
  fi
}

# 📌  Cursor (si está instalado)
function cursor() {
  local EXE="/mnt/c/Users/Diego/AppData/Local/Programs/Cursor/Cursor.exe"
  if [[ -f "$EXE" ]]; then
    if [[ -z "$1" ]]; then
      "$EXE" .
    else
      "$EXE" "$(wslpath -w "$1")"
    fi
  else
    echo "❌ Cursor no está instalado"
  fi
}

# 📌  VS Code (siempre disponible)
function vscode() {
  if [[ -z "$1" ]]; then
    /mnt/c/Users/Diego/AppData/Local/Programs/Microsoft\ VS\ Code/Code.exe .
  else
    /mnt/c/Users/Diego/AppData/Local/Programs/Microsoft\ VS\ Code/Code.exe "$(wslpath -w "$1")"
  fi
}

# 📌 Explorer.exe de windows📌
# Abre el explorador de Windows en la ubicación actual de WSL.
# Función para abrir el explorador de Windows
function explorer() {
    if [[ -z "$1" ]]; then
        # Si no hay argumentos, abre la carpeta actual
        explorer.exe .
    else
        # Si hay argumentos, convierte la ruta y la abre
        explorer.exe "$(wslpath -w "$1")"
    fi
}
# 📌[Photo, picasa] Función para abrir el visor de fotos de PREDETERMINADO Windows.
# Equivalente a loupe y feh
function picasa() {
    if [[ -z "$1" ]]; then
        explorer.exe .
    else
        explorer.exe "$(wslpath -w "$1")"
    fi
}

# 📌 [VLC] Abre un video con el VLC de Windows.
function vlc() {
  /mnt/c/Program\ Files/VideoLAN/VLC/vlc.exe "$(wslpath -w "$1")"
}


# 📌 [Notepads] Abre un texto con el notepad de Windows.
function notepad() {
    if [[ -z "$1" ]]; then
        notepads.exe
    else
        notepads.exe "$(wslpath -w "$1")"
    fi
}

# Añade el directorio global de npm al PATH.
export PATH=~/.npm-global/bin:$PATH

# Integración con la terminal Ghostty.
if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
  source "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration"
fi


# =============================================================================
#
#                     ALIAS, FUNCIONES Y OTRAS OPCIONES
#
# =============================================================================


# Alias para reemplazar 'ls' con 'exa' (requiere que 'exa' esté instalado).
alias ls='exa --icons --color=always'

# Carga de plugins externos.
# Nota: La ruta de estos plugins es específica. Si no funcionan, verifica que
# estén instalados en el directorio correcto y que la ruta sea válida.
source ~/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source ~/.zsh/fzf-tab/fzf-tab.plugin.zsh

# Configuración del Historial de Zsh.
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt sharehistory
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt extendedhistory

function zle-line-finish() {
  zle .accept-line
  print -s $BUFFER
}
zle -N zle-line-finish

# Alias para guardar y mostrar el historial.
rm -f /tmp/history
alias history='fc -l 1 > /tmp/history && cat /tmp/history'

# Carga de un programa al iniciar la terminal (opcional).
fastfetch


# =============================================================================
#
#                        CONFIGURACIÓN DEL PROMPT
#
# =============================================================================

# Configuración del prompt instantáneo de Powerlevel10k.
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

# Carga la configuración del prompt.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# HABILITAR OH MY POSH [trae mas temas]
# https://ohmyposh.dev/docs/themes
# eval "$(oh-my-posh init zsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json')"

# Agrega al final del archivo ~/.zshrc
# Reparar problemas de codificación de caracteres. [UTF-8]
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
# Añade Composer al PATH [PHP]
export PATH="$HOME/.config/composer/vendor/bin:$PATH"
# Configuración de Java JDK 21
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
export PATH=$JAVA_HOME/bin:$PATH

# =============================================================================
#
# SINCRONIZAR PYWAL en WINDOWS
#
# =============================================================================

# Only create symlink if it doesn't exist or isn't already a symlink
# if [ ! -L ~/.cache/wal ]; then
#     #                    [CAMBIA USER]
#     # ln -s /mnt/c/Users/username/.cache/wal ~/.cache/wal
#     ln -s /mnt/c/Users/Diego/.cache/wal ~/.cache/wal
# fi

# --- AUTO-GENERATED BY SETUP ---
alias sync-nvim='~/sync-nvim.sh'
alias sync-wal='~/sync-wal.sh'

function nvim() {
  local LINUX_NVIM=$(PATH=$(echo "$PATH" | sed -e 's/:\/mnt\/c[^:]*//g') whence -p nvim)
  if [[ -n "$LINUX_NVIM" ]]; then
    "$LINUX_NVIM" "$@"
  else
    wt.exe -d "$(wslpath -w "$PWD")" nvim.exe "$(wslpath -w "$1")"
  fi
}
# Para: -- ~/.config/nvim/lua/plugins/fzflua.lua
alias cdwin='cd /mnt/c/Users/diego'
alias cddev='cd /mnt/c/dev'

# Ahora en Neovim:
# :cd /mnt/c/Users/diego
# :FzfLua files  # ✅ Busca en Windows desde WSL

# Al final de ~/.zshrc
# Docker desde Windows
export PATH="/mnt/c/Program Files/Docker/Docker/resources/bin:$PATH"
alias docker='docker.exe'
alias docker-compose='docker-compose.exe'

# Cargar colores de Pywal
(cat ~/.cache/wal/sequences &) 2>/dev/null
