#!/bin/bash
# configure-opencommit-ollama.sh - Configurar opencommit para usar Ollama

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🤖 Configurando opencommit para Ollama...${NC}"
echo ""

# Verificar que oco existe
if ! command -v oco &>/dev/null; then
  echo -e "${RED}❌ opencommit no está instalado${NC}"
  echo -e "${YELLOW}Instala con: npm install -g opencommit${NC}"
  exit 1
fi

# Verificar que Ollama está corriendo
if ! curl -s http://localhost:11434/api/tags &>/dev/null; then
  echo -e "${RED}❌ Ollama no está corriendo${NC}"
  echo -e "${YELLOW}Inicia con: ollama serve${NC}"
  exit 1
fi

echo -e "${GREEN}✓ opencommit encontrado${NC}"
echo -e "${GREEN}✓ Ollama está corriendo${NC}"
echo ""

# Listar modelos disponibles
echo -e "${YELLOW}📋 Modelos disponibles en Ollama:${NC}"
ollama list
echo ""

# Pedir al usuario que elija modelo
echo -e "${YELLOW}Selecciona un modelo de la lista (o presiona Enter para qwen3-vl:235b-cloud):${NC}"
read -p "Modelo: " MODEL_CHOICE

# Usar default si no se especifica
if [ -z "$MODEL_CHOICE" ]; then
  MODEL_CHOICE="qwen3-vl:235b-cloud"
fi

echo ""
echo -e "${BLUE}[⚡]${NC} Configurando opencommit..."

# Configurar opencommit para Ollama
oco config set OCO_AI_PROVIDER=ollama
oco config set OCO_MODEL="$MODEL_CHOICE"
oco config set OCO_API_URL=http://localhost:11434
oco config set OCO_LANGUAGE=es  # Español (no OCO_LOCALE)

echo ""
echo -e "${GREEN}✅ Configuración completada${NC}"
echo ""

# Mostrar configuración actual
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${CYAN}📋 CONFIGURACIÓN ACTUAL${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
oco config get

echo ""
echo -e "${GREEN}🎉 ¡Listo! Ahora puedes usar opencommit con Ollama${NC}"
echo ""
echo -e "${YELLOW}Uso:${NC}"
echo -e "  ${BLUE}1.${NC} Haz cambios en archivos"
echo -e "  ${BLUE}2.${NC} git add ."
echo -e "  ${BLUE}3.${NC} aicommit  ${GREEN}# o 'oco'${NC}"
echo ""
