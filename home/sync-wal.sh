#!/bin/bash
# ~/sync-wal.sh
# Sincroniza wallpaper de Windows → Pywal en WSL (OPTIMIZADO - no sincroniza si es el mismo)
set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Archivo de caché del último wallpaper procesado
CACHE_FILE="$HOME/.cache/wal/last_wallpaper.cache"

echo -e "${YELLOW}🔍 [1/6] Leyendo wallpaper de Windows...${NC}"

# Leer wallpaper actual
wallpaper=$(powershell.exe -NoProfile -NonInteractive -Command "(Get-ItemProperty 'HKCU:\Control Panel\Desktop').Wallpaper" 2>/dev/null | tr -d '\r\n')

if [ -z "$wallpaper" ]; then
  echo -e "${RED}❌ No se pudo leer el wallpaper${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Windows path: $wallpaper${NC}"

# Verificar si es el mismo wallpaper que la última vez
echo -e "${YELLOW}🔍 [2/6] Verificando si cambió el wallpaper...${NC}"

if [ -f "$CACHE_FILE" ]; then
  last_wallpaper=$(cat "$CACHE_FILE")
  if [ "$wallpaper" = "$last_wallpaper" ]; then
    echo -e "${BLUE}⏭️  Wallpaper no ha cambiado. Omitiendo sincronización.${NC}"
    echo -e "${GREEN}✅ Fondo actual: $(basename "$wallpaper")${NC}"
    exit 0
  fi
fi

echo -e "${GREEN}✅ Wallpaper cambió, procediendo...${NC}"

# Convertir ruta Windows → WSL
echo -e "${YELLOW}🔍 [3/6] Convirtiendo ruta Windows → WSL...${NC}"
wsl_path=$(echo "$wallpaper" | sed 's/\\/\//g')
echo -e "   Paso 1: $wsl_path"
wsl_path=$(echo "$wsl_path" | sed -E 's|^([A-Za-z]):|/mnt/\L\1|')
echo -e "   Paso 2: $wsl_path"
echo -e "${GREEN}✅ WSL path: $wsl_path${NC}"

# Verificar que el archivo existe
echo -e "${YELLOW}🔍 [4/6] Verificando que la imagen existe...${NC}"
if [ ! -f "$wsl_path" ]; then
  echo -e "${RED}❌ Imagen NO encontrada en: $wsl_path${NC}"
  echo ""
  echo -e "${YELLOW}🔍 Intentando encontrar la imagen...${NC}"

  filename=$(basename "$wsl_path")
  echo "   Buscando: $filename"

  if [ -d "/mnt/i" ]; then
    found=$(find /mnt/i -iname "$filename" 2>/dev/null | head -n 1)
    if [ -n "$found" ]; then
      echo -e "${GREEN}✅ Encontrada en: $found${NC}"
      wsl_path="$found"
    else
      echo -e "${RED}❌ No se encontró en /mnt/i${NC}"
      exit 1
    fi
  else
    echo -e "${RED}❌ /mnt/i no existe (drive no montado?)${NC}"
    echo "   Drives disponibles:"
    ls -1 /mnt/ | grep -v "wsl"
    exit 1
  fi
fi

echo -e "${GREEN}✅ Imagen encontrada: $wsl_path${NC}"

# Ejecutar Pywal
echo -e "${YELLOW}🔍 [5/6] Generando colores con Pywal...${NC}"
wal -i "$wsl_path" -n -q 2>&1

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Pywal ejecutado correctamente${NC}"
else
  echo -e "${RED}❌ Error ejecutando Pywal${NC}"
  exit 1
fi

# Verificar archivos generados
echo -e "${YELLOW}🔍 [6/6] Verificando archivos generados...${NC}"
if [ -f ~/.cache/wal/colors.json ]; then
  echo -e "${GREEN}✅ colors.json generado${NC}"

  # Guardar wallpaper actual en caché
  mkdir -p "$(dirname "$CACHE_FILE")"
  echo "$wallpaper" >"$CACHE_FILE"

  echo ""
  echo -e "${YELLOW}🎨 Colores generados:${NC}"
  if command -v jq &>/dev/null; then
    cat ~/.cache/wal/colors.json | jq -C '.'
  else
    cat ~/.cache/wal/colors.json
  fi
else
  echo -e "${RED}❌ colors.json NO generado${NC}"
  exit 1
fi

echo ""
echo -e "${GREEN}✅ ¡Completado! Wallpaper: $(basename "$wsl_path")${NC}"
