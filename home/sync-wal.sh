#!/bin/bash
# ~/sync-wal.sh
# Sincroniza wallpaper de Windows → Pywal en WSL (con debug)

set -e # Salir si hay error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔍 [1/5] Leyendo wallpaper de Windows...${NC}"

# Leer wallpaper (sin errores de PSReadLine)
wallpaper=$(powershell.exe -NoProfile -NonInteractive -Command "(Get-ItemProperty 'HKCU:\Control Panel\Desktop').Wallpaper" 2>/dev/null | tr -d '\r\n')

if [ -z "$wallpaper" ]; then
  echo -e "${RED}❌ No se pudo leer el wallpaper${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Windows path: $wallpaper${NC}"

# Convertir ruta (CORREGIDO)
echo -e "${YELLOW}🔍 [2/5] Convirtiendo ruta Windows → WSL...${NC}"

# Paso 1: Reemplazar \ por /
wsl_path=$(echo "$wallpaper" | sed 's/\\/\//g')
echo -e "   Paso 1: $wsl_path"

# Paso 2: Convertir I: → /mnt/i (case insensitive)
wsl_path=$(echo "$wsl_path" | sed -E 's|^([A-Za-z]):|/mnt/\L\1|')
echo -e "   Paso 2: $wsl_path"

# Paso 3: Normalizar mayúsculas/minúsculas en la ruta
# (WSL es case-sensitive, Windows no)
echo -e "${GREEN}✅ WSL path: $wsl_path${NC}"

# Verificar que el archivo existe
echo -e "${YELLOW}🔍 [3/5] Verificando que la imagen existe...${NC}"

if [ ! -f "$wsl_path" ]; then
  echo -e "${RED}❌ Imagen NO encontrada en: $wsl_path${NC}"
  echo ""
  echo -e "${YELLOW}🔍 Intentando encontrar la imagen...${NC}"

  # Extraer nombre del archivo
  filename=$(basename "$wsl_path")
  echo "   Buscando: $filename"

  # Buscar en /mnt/i (si existe)
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
echo -e "${YELLOW}🔍 [4/5] Generando colores con Pywal...${NC}"

wal -i "$wsl_path" -n -q 2>&1

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Pywal ejecutado correctamente${NC}"
else
  echo -e "${RED}❌ Error ejecutando Pywal${NC}"
  exit 1
fi

# Verificar que se generaron los archivos
echo -e "${YELLOW}🔍 [5/5] Verificando archivos generados...${NC}"

if [ -f ~/.cache/wal/colors.json ]; then
  echo -e "${GREEN}✅ colors.json generado${NC}"

  # Mostrar preview de colores
  echo ""
  echo -e "${YELLOW}🎨 Colores generados:${NC}"
  if command -v jq &>/dev/null; then
    jq -r '.colors | to_entries[] | "\(.key): \(.value)"' ~/.cache/wal/colors.json | head -8
  else
    cat ~/.cache/wal/colors.json
  fi
else
  echo -e "${RED}❌ colors.json NO generado${NC}"
  exit 1
fi

echo ""
echo -e "${GREEN}✅ ¡Completado! Wallpaper: $(basename "$wsl_path")${NC}"
