#!/bin/bash
# ============================================================
# U-Claw - Portable AI Agent
# Linux version - run: bash Linux-Start.sh
# ============================================================

UCLAW_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$UCLAW_DIR/app"
CORE_DIR="$APP_DIR/core"
DATA_DIR="$UCLAW_DIR/data"
SYSTEM_DIR="$UCLAW_DIR/system"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo ""
echo -e "${CYAN}"
echo "  ╔══════════════════════════════════════╗"
echo "  ║     🦞 U-Claw v1.1                  ║"
echo "  ║     Portable AI Agent (Linux)        ║"
echo "  ╚══════════════════════════════════════╝"
echo -e "${NC}"

# ---- 1. Detect CPU & set runtime ----
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    NODE_DIR="$APP_DIR/runtime/node-linux-x64"
    echo -e "  ${GREEN}Linux x86_64${NC}"
elif [ "$ARCH" = "aarch64" ]; then
    NODE_DIR="$APP_DIR/runtime/node-linux-arm64"
    echo -e "  ${GREEN}Linux ARM64${NC}"
else
    echo -e "  ${RED}Unsupported architecture: $ARCH${NC}"
    echo -e "  ${RED}Only x86_64 and arm64 are supported.${NC}"
    echo ""
    read -p "  Press Enter to exit..."
    exit 1
fi

NODE_BIN="$NODE_DIR/bin/node"
export PATH="$NODE_DIR/bin:$PATH"

# ---- 2. Check runtime ----
if [ ! -f "$NODE_BIN" ]; then
    echo -e "  ${RED}Error: Node.js runtime not found${NC}"
    echo "  Expected: $NODE_BIN"
    echo "  Please run setup.sh first or ensure app/runtime/ is complete"
    read -p "  Press Enter to exit..."
    exit 1
fi

NODE_VER=$("$NODE_BIN" --version)
echo -e "  Node.js: ${GREEN}${NODE_VER}${NC}"
echo ""

# ---- 3. Check & init data ----
mkdir -p "$DATA_DIR/memory" "$DATA_DIR/backups" "$DATA_DIR/logs"

if [ ! -f "$DATA_DIR/config.json" ] && [ ! -f "$DATA_DIR/.openclaw/openclaw.json" ]; then
    echo -e "  ${YELLOW}First run - creating default config...${NC}"
    mkdir -p "$DATA_DIR/.openclaw"
    cat > "$DATA_DIR/.openclaw/openclaw.json" << 'CFGEOF'
{
  "gateway": {
    "mode": "local",
    "auth": { "token": "uclaw" }
  }
}
CFGEOF
    echo -e "  ${GREEN}Config created${NC}"
    echo ""
fi

# ---- 4. Set environment (portable mode) ----
STATE_DIR="$DATA_DIR/.openclaw"
mkdir -p "$STATE_DIR"

# Sync config to where OpenClaw expects it
if [ -f "$DATA_DIR/config.json" ] && [ ! -f "$STATE_DIR/openclaw.json" ]; then
    cp "$DATA_DIR/config.json" "$STATE_DIR/openclaw.json"
fi

export OPENCLAW_HOME="$DATA_DIR"
export OPENCLAW_STATE_DIR="$STATE_DIR"
export OPENCLAW_CONFIG_PATH="$STATE_DIR/openclaw.json"

# ---- 5. Run migration if exists ----
if [ -f "$SYSTEM_DIR/migrate.js" ]; then
    "$NODE_BIN" "$SYSTEM_DIR/migrate.js" "$DATA_DIR" 2>/dev/null || true
fi

# ---- 6. Check dependencies ----
if [ ! -d "$CORE_DIR/node_modules" ]; then
    echo -e "  ${YELLOW}First run - installing dependencies...${NC}"
    echo "  (Using China mirror)"
    cd "$CORE_DIR"
    "$NODE_BIN" "$NODE_DIR/bin/npm" install --registry=https://registry.npmmirror.com 2>&1
    echo -e "  ${GREEN}Dependencies installed${NC}"
    echo ""
fi

# ---- 7. Find available port ----
PORT=18789
while ss -tlnp 2>/dev/null | grep -q ":$PORT " || netstat -tlnp 2>/dev/null | grep -q ":$PORT "; do
    echo -e "  ${YELLOW}Port $PORT in use, trying next...${NC}"
    PORT=$((PORT + 1))
    if [ $PORT -gt 18799 ]; then
        echo -e "  ${RED}No available port (18789-18799)${NC}"
        read -p "  Press Enter to exit..."
        exit 1
    fi
done

# Update config with correct port if changed
if [ $PORT -ne 18789 ]; then
    "$NODE_BIN" -e "
        const fs = require('fs');
        const p = '$DATA_DIR/config.json';
        if (fs.existsSync(p)) {
            const c = JSON.parse(fs.readFileSync(p, 'utf8'));
            c.gateway = c.gateway || {};
            c.gateway.port = $PORT;
            fs.writeFileSync(p, JSON.stringify(c, null, 2));
        }
    " 2>/dev/null || true
fi

# ---- 8. Start gateway ----
echo -e "  ${CYAN}Starting OpenClaw on port $PORT...${NC}"
echo "  Do NOT close this window."
echo ""

cd "$CORE_DIR"

TOKEN=$(python3 -c "import json,os; p='$STATE_DIR/openclaw.json' if os.path.exists('$STATE_DIR/openclaw.json') else '$DATA_DIR/config.json'; d=json.load(open(p)); print(d.get('gateway',{}).get('auth',{}).get('token','uclaw'))" 2>/dev/null || echo "uclaw")

OPENCLAW_MJS="$CORE_DIR/node_modules/openclaw/openclaw.mjs"
GW_LOG="$DATA_DIR/logs/gateway.log"
"$NODE_BIN" "$OPENCLAW_MJS" gateway run --allow-unconfigured --force --port $PORT 2>&1 | tee -a "$GW_LOG" &
GW_PID=$!

# ---- 9. Wait & open browser ----
for i in $(seq 1 30); do
    sleep 0.5
    if curl -s -o /dev/null -w '' "http://127.0.0.1:$PORT/" 2>/dev/null; then
        DASHBOARD_URL="http://127.0.0.1:$PORT/#token=${TOKEN}"
        CONFIG_PAGE="$UCLAW_DIR/Config.html?port=$PORT"
        echo ""
        echo -e "  ${GREEN}✅ Started successfully!${NC}"
        echo ""

        # Check if model is configured
        HAS_MODEL=$(python3 -c "
import json,os
for p in ['$STATE_DIR/openclaw.json','$DATA_DIR/config.json']:
    if os.path.exists(p):
        d=json.load(open(p))
        if d.get('agent',{}).get('model'):
            print('yes'); break
" 2>/dev/null)

        if [ "$HAS_MODEL" = "yes" ]; then
            echo -e "  ${CYAN}Dashboard: ${DASHBOARD_URL}${NC}"
            echo ""
            xdg-open "$DASHBOARD_URL" 2>/dev/null || echo -e "  ${YELLOW}Please open in browser: ${DASHBOARD_URL}${NC}"
        else
            echo -e "  ${YELLOW}首次使用，打开配置页面...${NC}"
            echo -e "  ${CYAN}配置页面: Config.html${NC}"
            echo -e "  ${CYAN}控制台: ${DASHBOARD_URL}${NC}"
            echo ""
            xdg-open "$CONFIG_PAGE" 2>/dev/null || echo -e "  ${YELLOW}Please open in browser: ${CONFIG_PAGE}${NC}"
        fi
        break
    fi
done

wait $GW_PID

echo ""
echo -e "  ${YELLOW}OpenClaw stopped.${NC}"
read -p "  Press Enter to close..."
