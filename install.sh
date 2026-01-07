#!/bin/bash
set -e

echo "=== GOWA + n8n Webhook Auto Reply Installer ==="

# ===== CONFIG =====
GOWA_DIR="/opt/gowa"
N8N_WEBHOOK_URL="https://n8n.wnkm.my.id/webhook/gowa-in"
WEBHOOK_SECRET="super-secret-key"
APP_BASIC_AUTH="admin:admin"
APP_PORT=3000

# ===== INSTALL DOCKER =====
if ! command -v docker &> /dev/null; then
  echo "[+] Installing Docker..."
  curl -fsSL https://get.docker.com | sh
fi

if ! command -v docker-compose &> /dev/null; then
  echo "[+] Installing docker-compose..."
  curl -L "https://github.com/docker/compose/releases/download/v2.25.0/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
fi

# ===== SETUP DIR =====
mkdir -p $GOWA_DIR
cd $GOWA_DIR

# ===== docker-compose.yml =====
cat > docker-compose.yml <<EOF
services:
  gowa:
    image: ghcr.io/aldinokemal/go-whatsapp-web-multidevice:latest
    container_name: gowa
    restart: always
    ports:
      - "${APP_PORT}:3000"
    volumes:
      - gowa_data:/app/storages
    environment:
      APP_PORT: 3000
      APP_BASIC_AUTH: ${APP_BASIC_AUTH}
      APP_DEBUG: true
      APP_OS: debian12

      WHATSAPP_WEBHOOK: ${N8N_WEBHOOK_URL}
      WHATSAPP_WEBHOOK_SECRET: ${WEBHOOK_SECRET}

      WHATSAPP_AUTO_REPLY: ""
      WHATSAPP_AUTO_MARK_READ: false
      WHATSAPP_ACCOUNT_VALIDATION: true
      WHATSAPP_CHAT_STORAGE: true

volumes:
  gowa_data:
EOF

# ===== RUN =====
docker compose up -d

echo ""
echo "======================================"
echo " GOWA INSTALLED & RUNNING "
echo " URL        : http://SERVER_IP:${APP_PORT}"
echo " AUTH       : ${APP_BASIC_AUTH}"
echo " WEBHOOK    : ${N8N_WEBHOOK_URL}"
echo "======================================"
