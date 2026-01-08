#!/bin/bash
# ~/scripts/git_clean.sh - Gestión completa de repositorios Git

# ============================================
# 1. SELECCIONAR REPOSITORIO
# ============================================

# Lista de repositorios comunes (agrega/quita según necesites)
REPOS=(
  "$HOME/dotfiles-dizzi"
  "$HOME/dotfiles-wsl-dizzi"
  "$HOME/workspace/GLAZE-WM-make-windows-pretty-main-dizzi"
  "$HOME/workspace/Proyecto-App-MCSD"
  "$HOME/workspace/REACT-Diego-Dizzi-Dashboard"
  "$HOME/workspace/portfolio-terminal-dhardi"
  "$HOME/workspace/Librezam"
  "$HOME/workspace/FCTicService.github.6c-Diego-05"
  "$HOME/projects"
)

# Auto-detectar repos en carpetas comunes
AUTO_DETECT_PATHS=(
  "$HOME/workspace"
  "$HOME/projects"
  "$HOME/repos"
  "$HOME/dotfiles-dizzi"
  "$HOME/dotfiles-wsl-dizzi"
  "$HOME/workspace/GLAZE-WM-make-windows-pretty-main-dizzi"
  "$HOME/workspace/Proyecto-App-MCSD"
  "$HOME/workspace/REACT-Diego-Dizzi-Dashboard"
  "$HOME/workspace/portfolio-terminal-dhardi"
  "$HOME/workspace/Librezam"
  "$HOME/workspace/FCTicService.github.6c-Diego-05"
  "$(pwd)"
)

# Buscar repos automáticamente
for base_path in "${AUTO_DETECT_PATHS[@]}"; do
  if [[ -d "$base_path" ]]; then
    # Si es un repo, agregarlo
    if [[ -d "$base_path/.git" ]]; then
      REPOS+=("$base_path")
    fi

    # Buscar repos en subdirectorios (1 nivel)
    if [[ -d "$base_path" && "$base_path" != "$(pwd)" ]]; then
      for subdir in "$base_path"/*; do
        if [[ -d "$subdir/.git" ]]; then
          REPOS+=("$subdir")
        fi
      done
    fi
  fi
done

# Eliminar duplicados
REPOS=($(printf '%s\n' "${REPOS[@]}" | sort -u))

# Construir menú de repos existentes
REPO_MENU=""
for repo in "${REPOS[@]}"; do
  if [[ -d "$repo/.git" ]]; then
    REPO_NAME=$(basename "$repo")
    REPO_MENU+="󰊢  $REPO_NAME ($repo)\n"
  fi
done

# Agregar opción manual
REPO_MENU+="󰈞  Escribir ruta manualmente"

# Mostrar menú
SELECTED_REPO=$(echo -e "$REPO_MENU" | rofi -dmenu -p "󰊢   Seleccionar  Repositorio   " -config ~/.config/rofi/config-power-grid.rasi -theme-str 'window {width: 1000px; height: 400px;} listview {columns: 3; spacing: 20px;} element {min-width: 260px; padding: 35px 30px;}')

[[ -z "$SELECTED_REPO" ]] && exit 0

# Procesar selección
if [[ "$SELECTED_REPO" == *"Escribir ruta"* ]]; then
  # Crear un archivo temporal con instrucciones para rofi
  INSTRUCTIONS_TEMP=$(mktemp)
  cat >"$INSTRUCTIONS_TEMP" <<'EOF'
📝 ESCRIBIR RUTA MANUALMENTE

Ejemplos de rutas válidas:
• ~/dotfiles-dizzi
• ~/workspace/mi-proyecto  
• /home/usuario/repos/app
• /ruta/completa/al/repo

Escribe la ruta completa y presiona Enter
EOF

  while true; do
    # Mostrar diálogo de entrada con instrucciones
    REPO_PATH=$(echo -e "📝 Escribe la ruta completa del repositorio:\n\nEjemplos:\n• ~/dotfiles-dizzi\n• ~/workspace/mi-proyecto\n• /home/usuario/repos/app\n" | rofi -dmenu -p "Ruta del repositorio" \
      -show run -config ~/.config/rofi/config-power-grid.rasi \
      -theme-str 'window {width: 1600px; height: 400px;} entry {placeholder: "Ej: ~/mi-proyecto";}')

    # Si cancela, salir
    [[ -z "$REPO_PATH" ]] && exit 0

    # Expandir ~ a HOME
    REPO_PATH="${REPO_PATH/#\~/$HOME}"
    REPO_PATH="${REPO_PATH//\~/$HOME}" # También reemplazar cualquier ~

    # Validar que existe
    if [[ ! -d "$REPO_PATH" ]]; then
      ERROR_CHOICE=$(echo -e "󰩖  Reintentar\n󰜺  Cancelar" | rofi -dmenu -p "❌ Ruta no encontrada" \
        -config ~/.config/rofi/config-power-grid.rasi \
        -theme-str 'window {width: 1000px; height: 200px;} element {padding: 20px;}' \
        -mesg "La ruta '$REPO_PATH' no existe.\n¿Quieres intentar de nuevo?")

      [[ "$ERROR_CHOICE" != *"Reintentar"* ]] && exit 0
      continue
    fi

    # Si existe pero no es repo Git
    if [[ ! -d "$REPO_PATH/.git" ]]; then
      ERROR_CHOICE=$(echo -e "󰩖  Reintentar\n󰜺  Cancelar" | rofi -dmenu -p "❌ No es un repositorio Git" \
        -config ~/.config/rofi/config-power-grid.rasi \
        -theme-str 'window {width: 1000px; height: 250px;} element {padding: 25px;}' \
        -mesg "La carpeta existe pero no tiene .git:\n$REPO_PATH\n\n¿Quieres intentar con otra ruta?")

      [[ "$ERROR_CHOICE" != *"Reintentar"* ]] && exit 0
      continue
    fi

    # Ruta válida, salir del bucle
    break
  done

  # Limpiar archivo temporal
  rm -f "$INSTRUCTIONS_TEMP"
else
  REPO_PATH=$(echo "$SELECTED_REPO" | grep -oP '\(.*?\)' | tr -d '()')
fi

# Validar repositorio
if [[ ! -d "$REPO_PATH/.git" ]]; then
  notify-send -u critical "Git Clean" "❌ '$REPO_PATH' no es un repositorio Git válido"
  exit 1
fi

cd "$REPO_PATH" || exit 1
REPO_NAME=$(basename "$REPO_PATH")
notify-send "󰊢  Git Clean" "📂 Repositorio: $REPO_NAME\n📁 $REPO_PATH"

# ============================================
# 2. SELECCIONAR ACCIÓN
# ============================================

ACTION=$(printf "󰁨  Limpieza normal\n󰁨  Limpieza profunda\n󰈈  Ver espacio\n󰚰  Filter-Repo\n󰈛  Eliminar historial\n󰚮  RESET 100%% (NUCLEAR)\n󰓦  Cambiar repositorio" | rofi -dmenu -p "󰊢 󱎝 Git Clean -   $REPO_NAME  " -config ~/.config/rofi/config-power-grid.rasi -theme-str 'window {width: 1400px; height: 350px;} listview {columns: 3; spacing: 20px;} element {min-width: 260px; padding: 35px 30px;}')

[[ -z "$ACTION" ]] && exit 0

# ============================================
# 3. EJECUTAR ACCIÓN SELECCIONADA
# ============================================

case "$ACTION" in
*"Cambiar repositorio"*)
  # Reiniciar script
  exec "$0"
  ;;

*"Limpieza normal"*)
  kitty -e bash -c "
      cd '$REPO_PATH'
      echo '📂 Repositorio: $REPO_NAME'
      echo '📁 Ruta: $REPO_PATH'
      echo ''
      echo 'Limpiando repositorio...'
      git gc --prune=now
      echo ''
      echo '✓ Limpieza completada'
      read -p 'Presiona Enter para cerrar'
    "
  notify-send "Git" "✅ Limpieza normal completada en $REPO_NAME"
  ;;

*"Limpieza profunda"*)
  kitty -e bash -c "
      cd '$REPO_PATH'
      echo '📂 Repositorio: $REPO_NAME'
      echo '📁 Ruta: $REPO_PATH'
      echo ''
      echo 'Iniciando limpieza profunda...'
      git reflog expire --expire=now --all
      git gc --prune=now --aggressive
      git repack -a -d --depth=50 --window=250
      echo ''
      echo '✓ Limpieza profunda completada'
      read -p 'Presiona Enter para cerrar'
    "
  notify-send "Git" "✅ Limpieza profunda completada en $REPO_NAME"
  ;;

*"Ver espacio"*)
  kitty -e bash -c "
      cd '$REPO_PATH'
      echo '📂 Repositorio: $REPO_NAME'
      echo '📁 Ruta: $REPO_PATH'
      echo ''
      echo '=== Espacio usado por Git ==='
      git count-objects -vH
      echo ''
      echo '=== Archivos grandes ==='
      git rev-list --objects --all |
        git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' |
        awk '/^blob/ {print \$3, \$4}' |
        sort -n -r |
        head -20 |
        numfmt --to=iec-i --suffix=B --field=1 --padding=7
      echo ''
      echo '=== Tamaño del repositorio ==='
      du -sh .git
      echo ''
      echo '=== Análisis con dust ==='
      command -v dust &>/dev/null && dust -d 3 .git || echo 'dust no instalado'
      read -p 'Presiona Enter para cerrar'
    "
  ;;

*"RESET 100%"*)
  # Advertencia especial para RESET
  CONFIRM=$(echo -e "󰩖  CANCELAR\n󰚮  CONFIRMAR RESET 100%%" | rofi -dmenu -p "⚠️  RESET NUCLEAR - $REPO_NAME" -config ~/.config/rofi/config-power-grid.rasi -theme-str 'window {width: 800px;} element {padding: 40px;}' -mesg "⚠️ ESTO HARÁ:
1. Eliminará TODOS los commits del historial
2. Eliminará archivos grandes (wallpapers, fonts, caches)
3. Creará un commit inicial limpio desde cero
4. Reducirá el tamaño del repo en ~90%

💀 IRREVERSIBLE - Se creará backup en .git.backup

¿Estás 100% seguro?")

  if [[ "$CONFIRM" == *"CONFIRMAR"* ]]; then
    kitty -e bash -c "
      set -e
      cd '$REPO_PATH'
      
      echo '╔═══════════════════════════════════════════════════════════╗'
      echo '║  🔥 RESET 100%% - LIMPIEZA NUCLEAR                       ║'
      echo '╠═══════════════════════════════════════════════════════════╣'
      echo '║  📂 Repositorio: $REPO_NAME'
      echo '║  📁 Ruta: $REPO_PATH'
      echo '╚═══════════════════════════════════════════════════════════╝'
      echo ''
      
      # Tamaño inicial
      BEFORE_SIZE=\$(du -sh .git | awk '{print \$1}')
      echo \"📊 Tamaño inicial: \$BEFORE_SIZE\"
      echo ''
      
      # 1. Backup
      echo '📦 [1/7] Creando backup de seguridad...'
      cp -r .git .git.backup
      echo '   ✓ Backup: .git.backup'
      echo ''
      
      # 2. Mover archivos grandes
      echo '🖼️  [2/7] Moviendo archivos grandes fuera de Git...'
      mkdir -p ~/.local/share/dotfiles-assets
      
      if [[ -d wallpapers ]]; then
        mv wallpapers ~/.local/share/dotfiles-assets/ 2>/dev/null || true
        ln -sf ~/.local/share/dotfiles-assets/wallpapers wallpapers
        echo '   ✓ Wallpapers movidos'
      fi
      
      [[ -f font/.config/font/minecraft_font.ttc ]] && \
        mv font/.config/font/minecraft_font.ttc ~/.local/share/dotfiles-assets/ 2>/dev/null || true
      
      echo ''
      
      # 3. Crear .gitignore
      echo '📝 [3/7] Creando .gitignore...'
      cat > .gitignore << 'EOFIGNORE'
# Archivos grandes
wallpapers/
*.ttc
*.ttf
*.woff2

# Caches
*.cache
*.pyc
__pycache__/

# Temporales
*.tmp
*.swp
.DS_Store

# Logs
*.log

# Específicos
copyq/.config/copyq/*.dat
local/.local/share/icons/*.cache
nvim*/.config/nvim/spell/*.spl
EOFIGNORE
      echo '   ✓ .gitignore creado'
      echo ''
      
      # 4. Detectar rama actual
      echo '🌿 [4/7] Detectando rama actual...'
      CURRENT_BRANCH=\$(git branch --show-current)
      [[ -z \"\$CURRENT_BRANCH\" ]] && CURRENT_BRANCH=\"main\"
      echo \"   ✓ Rama: \$CURRENT_BRANCH\"
      echo ''
      
      # 5. Crear rama huérfana
      echo '🔄 [5/7] Creando nuevo historial limpio...'
      git checkout --orphan temp-clean-branch
      git add -A
      git commit -m \"🧹 Fresh start - Repo limpio desde cero

✨ Cambios aplicados:
- Historial resetado completamente
- Archivos grandes movidos fuera de Git
- .gitignore configurado
- Tamaño reducido: \$BEFORE_SIZE → (calculando...)

🚀 Generado por clean-git-RESET100%.sh\"
      
      echo '   ✓ Commit inicial creado'
      echo ''
      
      # 6. Reemplazar rama vieja
      echo '🗑️  [6/7] Eliminando historial antiguo...'
      git branch -D \$CURRENT_BRANCH 2>/dev/null || true
      git branch -m \$CURRENT_BRANCH
      echo \"   ✓ Rama \$CURRENT_BANCH actualizada\"
      echo ''
      
      # 7. Optimizar
      echo '⚡ [7/7] Optimizando repositorio...'
      git reflog expire --expire=now --all
      git gc --prune=now --aggressive
      git repack -a -d
      echo '   ✓ Optimización completada'
      echo ''
      
      # Resultado
      AFTER_SIZE=\$(du -sh .git | awk '{print \$1}')
      
      echo '╔═══════════════════════════════════════════════════════════╗'
      echo '║  ✅ RESET 100%% COMPLETADO                               ║'
      echo '╠═══════════════════════════════════════════════════════════╣'
      echo \"║  Antes:   \$BEFORE_SIZE                                    ║\"
      echo \"║  Después: \$AFTER_SIZE                                     ║\"
      echo '║                                                           ║'
      echo '║  💾 Backup: .git.backup                                   ║'
      echo '║  🖼️  Assets: ~/.local/share/dotfiles-assets              ║'
      echo '╚═══════════════════════════════════════════════════════════╝'
      echo ''
      echo '🚀 SIGUIENTE PASO:'
      echo \"   git push -u origin \$CURRENT_BRANCH --force\"
      echo ''
      echo '⚠️  ADVERTENCIA: Esto reescribirá el historial remoto'
      echo ''
      read -p 'Presiona Enter para cerrar'
    "

    notify-send -u critical "Git Clean" "🔥 RESET 100% completado en $REPO_NAME\n⚠️ Ejecuta: git push --force"
  else
    notify-send "Git Clean" "❌ RESET cancelado"
  fi
  ;;

*"Filter-Repo"*)
  FILTER_CHOICE=$(echo -e "󰨞  Instalar filter-repo\n󰚰  Limpiar archivos grandes\n󰙆  Limpiar logs (*.log)\n󱁤  Limpiar temporales\n󰩺  Limpiar carpeta específica\n󰙴  Limpiar extensión específica" | rofi -dmenu -p "Filter-Repo - $REPO_NAME" -config ~/.config/rofi/config-power-grid.rasi -theme-str 'window {width: 1000px; height: 400px;} listview {columns: 3; spacing: 20px;}')

  case "$FILTER_CHOICE" in
  *"Instalar filter-repo"*)
    kitty -e bash -c "
          echo 'Instalando git-filter-repo...'
          pip install --user git-filter-repo
          echo ''
          echo '✓ git-filter-repo instalado'
          read -p 'Presiona Enter para cerrar'
        "
    notify-send "Git" "✅ git-filter-repo instalado"
    ;;

  *"Limpiar archivos grandes"*)
    kitty -e bash -c "
          cd '$REPO_PATH'
          echo '📂 Repositorio: $REPO_NAME'
          echo ''
          echo '=== Archivos más grandes (top 10) ==='
          git rev-list --objects --all |
            git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' |
            awk '/^blob/ {print \$3, \$4}' |
            sort -n -r |
            head -10 |
            numfmt --to=iec-i --suffix=B --field=1 --padding=7
          echo ''
          read -p 'Tamaño mínimo a eliminar (ej: 10M, 5M, 1M): ' SIZE
          
          if [[ -n \$SIZE ]]; then
              echo ''
              echo 'Creando backup en .git.backup...'
              cp -r .git .git.backup
              
              echo 'Eliminando archivos mayores a '\$SIZE'...'
              git filter-repo --strip-blobs-bigger-than \$SIZE --force
              
              echo ''
              echo '✓ Archivos grandes eliminados'
              echo '⚠️  Ejecuta: git push --force --all'
              echo '💾 Backup: .git.backup'
          fi
          
          read -p 'Presiona Enter para cerrar'
        "
    notify-send "Git" "✅ Archivos grandes eliminados de $REPO_NAME"
    ;;

  *"Limpiar logs"*)
    kitty -e bash -c "
          cd '$REPO_PATH'
          echo '📂 Repositorio: $REPO_NAME'
          echo ''
          echo 'Limpiando archivos .log del historial...'
          cp -r .git .git.backup
          git filter-repo --path-glob '*.log' --invert-paths --force
          echo ''
          echo '✓ Logs eliminados'
          echo '⚠️  Ejecuta: git push --force --all'
          read -p 'Presiona Enter para cerrar'
        "
    notify-send "Git" "✅ Logs eliminados de $REPO_NAME"
    ;;

  *"Limpiar temporales"*)
    kitty -e bash -c "
          cd '$REPO_PATH'
          echo '📂 Repositorio: $REPO_NAME'
          echo ''
          echo 'Limpiando archivos temporales...'
          cp -r .git .git.backup
          git filter-repo \
            --path-glob 'tmp/*' \
            --path-glob 'temp/*' \
            --path-glob '*.tmp' \
            --path-glob '*.cache' \
            --path-glob '__pycache__/*' \
            --path-glob 'node_modules/*' \
            --invert-paths --force
          echo ''
          echo '✓ Temporales eliminados'
          echo '⚠️  Ejecuta: git push --force --all'
          read -p 'Presiona Enter para cerrar'
        "
    notify-send "Git" "✅ Temporales eliminados de $REPO_NAME"
    ;;

  *"Limpiar carpeta específica"*)
    FOLDER=$(rofi -dmenu -p "Carpeta a eliminar (ej: logs/, temp/)" -config ~/.config/rofi/config-power-grid.rasi -theme-str 'window {width: 600px;}')
    if [[ -n "$FOLDER" ]]; then
      kitty -e bash -c "
            cd '$REPO_PATH'
            echo '📂 Repositorio: $REPO_NAME'
            echo ''
            echo 'Eliminando carpeta: $FOLDER'
            cp -r .git .git.backup
            git filter-repo --path '$FOLDER' --invert-paths --force
            echo ''
            echo '✓ Carpeta eliminada del historial'
            echo '⚠️  Ejecuta: git push --force --all'
            read -p 'Presiona Enter para cerrar'
          "
      notify-send "Git" "✅ Carpeta '$FOLDER' eliminada de $REPO_NAME"
    fi
    ;;

  *"Limpiar extensión específica"*)
    EXT=$(rofi -dmenu -p "Extensión (ej: *.mp4, *.zip, *.log)" -config ~/.config/rofi/config-power-grid.rasi -theme-str 'window {width: 600px;}')
    if [[ -n "$EXT" ]]; then
      kitty -e bash -c "
            cd '$REPO_PATH'
            echo '📂 Repositorio: $REPO_NAME'
            echo ''
            echo 'Eliminando archivos: $EXT'
            cp -r .git .git.backup
            git filter-repo --path-glob '$EXT' --invert-paths --force
            echo ''
            echo '✓ Archivos eliminados del historial'
            echo '⚠️  Ejecuta: git push --force --all'
            read -p 'Presiona Enter para cerrar'
          "
      notify-send "Git" "✅ Extensión '$EXT' eliminada de $REPO_NAME"
    fi
    ;;
  esac
  ;;

*"Eliminar historial"*)
  RESPONSE=$(echo -e "󰩖  Cancelar\n󰚮  Continuar (DESTRUCTIVO)" | rofi -dmenu -p "⚠️ ¿Eliminar TODO el historial de $REPO_NAME?" -config ~/.config/rofi/config-power-grid.rasi -theme-str 'window {width: 700px;} element {padding: 35px;}')

  if [[ "$RESPONSE" == *"Continuar"* ]]; then
    kitty -e bash -c "
        cd '$REPO_PATH'
        echo '📂 Repositorio: $REPO_NAME'
        echo ''
        echo '⚠️  ADVERTENCIA: Eliminando TODO el historial'
        echo ''
        
        # Backup
        cp -r .git .git.backup
        echo '💾 Backup creado: .git.backup'
        echo ''
        
        # Detectar rama
        CURRENT_BRANCH=\$(git branch --show-current)
        [[ -z \"\$CURRENT_BRANCH\" ]] && CURRENT_BRANCH=\"main\"
        echo \"Rama actual: \$CURRENT_BRANCH\"
        echo ''
        
        # Crear rama huérfana
        git checkout --orphan new-\$CURRENT_BRANCH
        git add -A
        git commit -m 'Fresh start - Historia reiniciada'
        
        # Eliminar rama vieja
        git branch -D \$CURRENT_BRANCH
        
        # Renombrar
        git branch -m \$CURRENT_BRANCH
        
        # Optimizar
        git gc --prune=now
        
        echo ''
        echo '✓ Historial eliminado'
        echo ''
        echo '⚠️  SIGUIENTE PASO:'
        echo \"git push -u origin \$CURRENT_BRANCH --force\"
        echo ''
        read -p 'Presiona Enter para cerrar'
      "
    notify-send "Git" "⚠️ Historial eliminado de $REPO_NAME\nListo para push --force"
  fi
  ;;
esac
