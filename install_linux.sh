#!/bin/bash
# DayApp Linux Installer

set -e

INSTALL_DIR="/opt/dayapp"
APP_BIN="build/linux/x64/release/bundle/dayapp"
DESKTOP_FILE="/usr/share/applications/dayapp.desktop"
ICON_FILE="/usr/share/pixmaps/dayapp.png"

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== DayApp Linux Installer ===${NC}\n"

# Verificar se o build existe
if [ ! -f "$APP_BIN" ]; then
    echo -e "${RED}❌ Erro: App não encontrado em $APP_BIN${NC}"
    echo "   Execute 'flutter build linux --release' primeiro"
    exit 1
fi

# Verificar se é root para instalação global
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}❌ Este instalador precisa de permissões de sudo${NC}"
    echo "   Rode: sudo ./install_linux.sh"
    exit 1
fi

echo -e "${BLUE}1. Copiando app para $INSTALL_DIR...${NC}"
rm -rf "$INSTALL_DIR"
cp -r "$(dirname "$APP_BIN")" "$INSTALL_DIR"
chmod +x "$INSTALL_DIR/dayapp"
echo -e "${GREEN}✓ App copiado${NC}\n"

echo -e "${BLUE}2. Criando link simbólico no PATH...${NC}"
ln -sf "$INSTALL_DIR/dayapp" /usr/local/bin/dayapp
echo -e "${GREEN}✓ Comando 'dayapp' disponível${NC}\n"

echo -e "${BLUE}3. Criando entry no menu do sistema...${NC}"
cat > "$DESKTOP_FILE" << 'DESKTOP_EOF'
[Desktop Entry]
Name=DayApp
Comment=Aplicativo para registrar histórias e memórias do dia
Exec=/opt/dayapp/dayapp
Icon=dayapp
Type=Application
Categories=Utility;Office;
Keywords=diary;stories;memories;notes;
StartupNotify=true
DESKTOP_EOF
chmod 644 "$DESKTOP_FILE"
echo -e "${GREEN}✓ Entry criado em $DESKTOP_FILE${NC}\n"

echo -e "${BLUE}4. Procurando ícone...${NC}"
if [ -f "assets/icon/app_icon.png" ]; then
    cp assets/icon/app_icon.png "$ICON_FILE"
    echo -e "${GREEN}✓ Ícone instalado${NC}\n"
elif [ -f "assets/icon/icon.png" ]; then
    cp assets/icon/icon.png "$ICON_FILE"
    echo -e "${GREEN}✓ Ícone instalado${NC}\n"
else
    echo -e "${BLUE}ℹ Nenhum ícone encontrado em assets/icon/ (opcional)${NC}\n"
fi

echo -e "${GREEN}=== Instalação Concluída ===${NC}\n"
echo -e "Opções de execução:"
echo -e "  ${BLUE}$INSTALL_DIR/dayapp${NC}    (executável direto)"
echo -e "  ${BLUE}dayapp${NC}                 (comando no terminal)"
echo -e "  ${BLUE}Menu do sistema${NC}        (procure por 'DayApp')\n"

echo -e "Para desinstalar, execute:"
echo -e "  ${RED}sudo rm -rf $INSTALL_DIR $DESKTOP_FILE $ICON_FILE /usr/local/bin/dayapp${NC}\n"
