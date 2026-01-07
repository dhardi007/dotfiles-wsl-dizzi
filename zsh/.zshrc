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
export PATH="$HOME/.npm-global/bin:$PATH"

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
# fastfetch con wallpaper actual
$HOME/dotfiles-wsl-dizzi/home/wallpaper-prompt-fastfetch

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
eval "$(oh-my-posh init zsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json')"

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

# Alias para OLLAMA IA:
alias ollama="/mnt/c/Users/Diego/AppData/Local/Programs/Ollama/ollama.exe"


# ═══════════════════════════════════════════════════════════
# Configuración de opencommit (oco) con Ollama ~ [opencommit]
# ═══════════════════════════════════════════════════════════
alias aicommit='oco'

# Comando para reconfigurar opencommit fácilmente
# Función dinámica para configurar opencommit
aicommitconfig() {
  echo "📦 Configurando opencommit con Ollama..."
  echo ""

  # Verificar que Ollama esté corriendo
  if ! curl -s http://localhost:11434/api/tags &>/dev/null; then
    echo "❌ Ollama no está corriendo. Ejecuta: ollama serve"
    return 1
  fi

  echo "✅ Ollama detectado en http://localhost:11434"
  echo ""

  local models=($(ollama list | tail -n +2 | awk '{print $1}'))

  if [[ ${#models[@]} -eq 0 ]]; then
    echo "❌ No hay modelos. Ejecuta 'ollama pull qwen2.5:0.5b'"
    return 1
  fi

  echo "Modelos disponibles:"
  select model in "${models[@]}" "❌ Cancelar"; do
    if [[ "$model" == "❌ Cancelar" ]] || [[ -z "$model" ]]; then
      echo "Operación cancelada"
      return 0
    fi

    if [[ -n "$model" ]]; then
      # Configuración completa con URL de Ollama
      oco config set OCO_AI_PROVIDER=ollama
      oco config set OCO_MODEL="$model" # ← MODELO, recomendacion: Usa modelos Cloud para commits >>> Local
      oco config set OCO_OLLAMA_API_URL=http://localhost:11434  # ← CLAVE
      oco config set OCO_LANGUAGE=es_ES
      oco config set OCO_TOKENS_MAX_INPUT=12000
      oco config set OCO_TOKENS_MAX_OUTPUT=500
      oco config set OCO_ONE_LINE_COMMIT=false

      echo ""
      echo "✅ opencommit configurado correctamente:"
      echo "   • Provider: ollama"
      echo "   • URL: http://localhost:11434"
      echo "   • Modelo: $model"
      echo "   • Idioma: es_ES"
      echo "   • Max tokens entrada: 12000"
      echo "   • Max tokens salida: 500"
      echo "   • Recomendacion: Usa modelos Cloud, consume 0 GPU y 1.5GB de RAM, Para commits es PERFECTO que >>> Local"
      echo ""
      echo "🧪 Probando conexión..."

      # Test rápido
      if oco --version &>/dev/null; then
        echo "✅ opencommit funcional"
      fi

      break
    fi
  done
}

# Mostrar modelo actual
alias aicommit-showmodel='oco config get OCO_MODEL'

# Alias adicionales útiles
alias aicommitreset='oco config reset'  # Resetear configuración
alias modellist='ollama list'  # Listar modelos disponibles
alias EspacioTotal='dust /*' # Tamaño de los archivos en el directorio actual
# =============================================================================
#                    GIT ALIASES Y FUNCIONES MEJORADAS
# =============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 📦 COMMITS RÁPIDOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Versión 1: Commit con plantilla personalizable
gitcommit() {
  # Archivo de plantilla en ~/.config/git/commit-template.txt
  local template_file="$HOME/commit-template.txt"

  # Crear plantilla por defecto si no existe
  if [ ! -f "$template_file" ]; then
    mkdir -p "$HOME/.config/git"
    cat > "$template_file" << 'TEMPLATE'
feat(arch 󰣇): 󰊢 Best Linux 🐧 Setup

# Agrega contexto adicional aquí:
# -
# -
# -

# Recuerda usar 'gitflow' para commits más complejos
TEMPLATE
    echo "✅ Plantilla creada en: $template_file"
  fi

  # Abrir editor con la plantilla
  git add .
  git commit -t "$template_file"

  # Preguntar si pushear
  echo -n "¿Pushear cambios? (y/n): "
  read push_answer
  if [[ "$push_answer" == "y" || "$push_answer" == "Y" ]]; then
    git push
    echo "✅ Cambios pusheados"
  else
    echo "⚠️ Commit realizado sin push"
  fi
}

# Versión 1b: Commit rápido sin abrir editor (usa plantilla inline)
gitquick() {
  local default_msg="feat(arch 󰣇): 󰊢 Best Linux 🐧 Setup"

  if [ $# -gt 0 ]; then
    # Si pasas argumento, úsalo como contexto adicional
    git add . && git commit -m "$default_msg

- $*" && git push
  else
    git add . && git commit -m "$default_msg" && git push
  fi

  echo "✅ Commit rápido realizado"
}

# Versión 2: Commit con AI LOCAL (sin cloud models)
gitai() {
  # Verificar que existe qwen2.5:0.5b (modelo local)
  if ! ollama list | grep -q "qwen2.5:0.5b"; then
    echo "❌ Modelo local no encontrado. Descargando qwen2.5:0.5b..."
    ollama pull qwen2.5:0.5b
  fi

  # Configurar temporalmente para usar modelo local
  local current_model=$(oco config get OCO_MODEL 2>/dev/null || echo "")

  # Si está usando un modelo cloud, cambiar temporalmente a local
  if [[ "$current_model" == *"cloud"* ]]; then
    echo "⚠️ Detectado modelo cloud, cambiando temporalmente a qwen2.5:0.5b"
    oco config set OCO_MODEL=qwen2.5:0.5b
  fi

  git add . && oco

  # Preguntar si pushear
  echo -n "¿Pushear cambios? (y/n): "
  read push_answer
  if [[ "$push_answer" == "y" || "$push_answer" == "Y" ]]; then
    git push
    echo "✅ Cambios pusheados"
  fi
}

# Versión 3: Función interactiva (mensaje personalizado)
gitc() {
  if [ $# -eq 0 ]; then
    echo "💬 Escribe tu mensaje de commit:"
    read commit_msg
  else
    commit_msg="$*"
  fi

  git add .
  git commit -m "$commit_msg"
  git push

  echo "✅ Cambios pusheados con mensaje: $commit_msg"
}

# Versión 4: Commit con tipo y scope (Conventional Commits)
gitconv() {
  local type scope msg

  echo "📝 Tipo de commit (feat/fix/docs/style/refactor/test/chore):"
  read type

  echo "📦 Scope (opcional, ej: hyprland, waybar, scripts):"
  read scope

  echo "💬 Mensaje del commit:"
  read msg

  if [ -n "$scope" ]; then
    full_msg="${type}(${scope}): ${msg}"
  else
    full_msg="${type}: ${msg}"
  fi

  git add .
  git commit -m "$full_msg"
  git push

  echo "✅ Commit: $full_msg"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🔍 GIT UTILITIES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Ver historial de commits (visual)
alias gitlog='git log --oneline --graph --decorate --all'
alias gitlogfull='git log --graph --pretty=format:"%Cred%h%Creset - %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'

# Ver diferencias antes de commit
alias gitdiff='git diff'
alias gitdiffs='git diff --staged'

# Status con formato limpio
alias gits='git status -sb'

# Deshacer último commit (mantiene cambios)
alias gitundo='git reset --soft HEAD~1'

# Deshacer último commit (borra cambios)
alias gitundobard='git reset --hard HEAD~1'

# Editar commits históricos (últimos 5)
alias CommitsHistorial='git rebase -i HEAD~5'

# Editar el último commit
alias CommitEditar='git commit --amend'

# Stash rápido
alias gitstash='git stash'
alias gitstashpop='git stash pop'
alias gitstashlist='git stash list'

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🔄 BRANCHING
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Ver branches
alias gitb='git branch -a'

# Crear y cambiar a nueva branch
gitnew() {
  if [ $# -eq 0 ]; then
    echo "❌ Uso: gitnew <nombre-de-branch>"
  else
    git checkout -b "$1"
    echo "✅ Branch '$1' creada y activa"
  fi
}

# Cambiar de branch
alias gitco='git checkout'

# Mergear branch
gitmerge() {
  if [ $# -eq 0 ]; then
    echo "❌ Uso: gitmerge <branch-a-mergear>"
  else
    git merge "$1"
    echo "✅ Branch '$1' mergeada"
  fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🚀 PUSH/PULL MEJORADOS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Push forzado (con cuidado)
alias gitpushforce='git push --force-with-lease'

# Pull con rebase (más limpio)
alias gitpull='git pull --rebase'

# Sincronizar fork con upstream
gitsync() {
  git fetch upstream
  git checkout main
  git merge upstream/main
  git push
  echo "✅ Fork sincronizado con upstream"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🧹 LIMPIEZA
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Limpiar branches mergeadas
alias gitclean='git branch --merged | grep -v "\*" | xargs -n 1 git branch -d'

# Limpiar archivos no trackeados
alias gitcleanfiles='git clean -fd'

# Reset completo al último commit
alias gitreset='git reset --hard HEAD'

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 📊 ESTADÍSTICAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Ver contribuciones por autor
alias gitstats='git shortlog -sn --all'

alias gitshowcom='tig'

# Ver tamaño del repo
alias gitsize='git count-objects -vH'

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🎯 FUNCIÓN COMPLETA TODO-EN-UNO
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Workflow completo con menú interactivo
gitflow() {
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "     🚀 GIT WORKFLOW INTERACTIVO"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "0. 🚀 Editar commit actual  "
  echo "1. 📝 Commit con plantilla (abre editor)  "
  echo "2. ⚡ Commit rápido (sin editor)"
  echo "3. 🤖 Commit con AI LOCAL (opencommit)"
  echo "4. 📦 Commit convencional (feat/fix/etc)"
  echo "5. 🔍 Ver status"
  echo "6. 📊 Ver log"
  echo "7. 📄 Editar plantilla de commit"
  echo "8. 📦 Revisar archivos historial de git"
  echo "9. 🔁 Editar Commits históricos  "
  echo "10. ❌ Cancelar"
  echo ""
  echo -n "Elige opción: "
  read option

  case $option in
    0)
      CommitEditar
      ;;
    1)
      gitcommit
      ;;
    2)
      echo "💬 Contexto adicional (opcional, Enter para saltar):"
      read context
      if [ -n "$context" ]; then
        gitquick "$context"
      else
        gitquick
      fi
      ;;
    3)
      gitai
      ;;
    4)
      gitconv
      ;;
    5)
      git status -sb
      ;;
    6)
      git log --oneline --graph --decorate --all -10
      ;;
    7)
      local template_file="$HOME/commit-template.txt"
      if [ ! -f "$template_file" ]; then
        mkdir -p "$HOME/.config/git"
        cat > "$template_file" << 'TEMPLATE'
feat(arch 󰣇): 󰊢 Best Linux 🐧 Setup

# Agrega contexto adicional aquí:
# -
# -
# -

# Recuerda usar 'gitflow' para commits más complejos
TEMPLATE
      fi
      ${EDITOR:-nano} "$template_file"
      echo "✅ Plantilla actualizada"
      ;;
    8)
      tig
      ;;
      #
    9)
      CommitsHistorial
      ;;
    10)
      echo "❌ Cancelado"
      ;;
    *)
      echo "❌ Opción inválida"
      ;;
  esac
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  💡 AYUDA COMPLETA DE GIT 󰊢  
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alias githelp='bash ~/scripts/git-help.sh'

# Pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
# COMANDOS DE OMARCHY
alias omarchy-launch-webapp='bash ~/omarchy-arch-bin/omarchy-launch-webapp'
alias omarchy-webapp-install='bash ~/omarchy-arch-bin/omarchy-webapp-install'
# Config para the clicker de CARGO/rust
export PATH="$HOME/.cargo/bin:$PATH"
export YDOTOOL_SOCKET=/tmp/.ydotool_socket
# Si quieres cambiar el repo rápidamente sin menú: para darle uso a Windows +Z 󱞣
export GIT_CLEAN_REPO="$HOME/dotfiles-dizzi"
                                                    
# ═══════════════════════════════════════════════════════════
# Editor por defecto (Git, etc)
# ═══════════════════════════════════════════════════════════
export EDITOR="nvim"
export VISUAL="nvim"
export GIT_EDITOR="nvim"

# ═══════════════════════════════════════════════════════════
# Sincronizar configs [Pywal, Nvim] ~ con Rsync
# ═══════════════════════════════════════════════════════════

~/sync-nvim.sh
~/sync-wal.sh
