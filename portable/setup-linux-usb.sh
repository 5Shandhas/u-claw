#!/bin/bash
# ============================================================
# U-Claw - Linux 启动盘 OpenClaw 安装脚本
# 在 Linux Mint 启动盘环境中运行此脚本安装 OpenClaw
#
# 使用方法：
#   1. 用 Rufus 制作 Linux Mint 启动盘（开启 Persistent Storage）
#   2. 从 USB 启动进入 Linux Mint
#   3. 连接网络
#   4. 打开终端，运行: bash setup-linux-usb.sh
# ============================================================

set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'

NODE_VER="v22.14.0"
MIRROR="https://registry.npmmirror.com"
NODE_MIRROR="https://npmmirror.com/mirrors/node"

INSTALL_DIR="$HOME/U-Claw"

clear
echo ""
echo -e "${CYAN}${BOLD}"
echo "  ╔══════════════════════════════════════╗"
echo "  ║   U-Claw Linux 启动盘安装            ║"
echo "  ║   在 Live Linux 环境中安装 OpenClaw   ║"
echo "  ╚══════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# ---- Check network ----
echo -e "  ${BOLD}[0/4] 检查网络连接...${NC}"
if ! ping -c 1 -W 3 npmmirror.com >/dev/null 2>&1; then
    echo -e "  ${RED}无法连接到网络！${NC}"
    echo -e "  ${YELLOW}请先连接 WiFi 或插入网线，然后重新运行此脚本。${NC}"
    echo ""
    read -p "  按回车退出..."
    exit 1
fi
echo -e "  ${GREEN}网络正常 ✓${NC}"
echo ""

# ---- Check CPU ----
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    NODE_PLATFORM="linux-x64"
    NODE_DIR_NAME="node-linux-x64"
    echo -e "  ${GREEN}架构: x86_64 ✓${NC}"
elif [ "$ARCH" = "aarch64" ]; then
    NODE_PLATFORM="linux-arm64"
    NODE_DIR_NAME="node-linux-arm64"
    echo -e "  ${GREEN}架构: ARM64 ✓${NC}"
else
    echo -e "  ${RED}不支持的架构: $ARCH${NC}"
    exit 1
fi
echo ""

# ---- Step 1: Install Node.js ----
echo -e "  ${BOLD}[1/4] 安装 Node.js $NODE_VER...${NC}"

NODE_INSTALL_DIR="$INSTALL_DIR/runtime/$NODE_DIR_NAME"

if [ -f "$NODE_INSTALL_DIR/bin/node" ]; then
    echo -e "  ${GREEN}Node.js 已存在，跳过${NC}"
else
    TARBALL="node-${NODE_VER}-${NODE_PLATFORM}.tar.gz"
    URL="${NODE_MIRROR}/${NODE_VER}/${TARBALL}"

    echo -e "  ${CYAN}下载: $URL${NC}"
    mkdir -p "$NODE_INSTALL_DIR"
    curl -# -L "$URL" -o "/tmp/$TARBALL"
    tar -xzf "/tmp/$TARBALL" -C "$NODE_INSTALL_DIR" --strip-components=1
    rm -f "/tmp/$TARBALL"
    chmod +x "$NODE_INSTALL_DIR/bin/node"
    echo -e "  ${GREEN}Node.js 安装完成 ✓${NC}"
fi

NODE_BIN="$NODE_INSTALL_DIR/bin/node"
NPM_BIN="$NODE_INSTALL_DIR/bin/npm"
export PATH="$NODE_INSTALL_DIR/bin:$PATH"

echo -e "  版本: $("$NODE_BIN" --version)"
echo ""

# ---- Step 2: Install OpenClaw ----
echo -e "  ${BOLD}[2/4] 安装 OpenClaw...${NC}"

CORE_DIR="$INSTALL_DIR/core"
mkdir -p "$CORE_DIR"

cat > "$CORE_DIR/package.json" << 'PKGEOF'
{
  "name": "u-claw-core",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "openclaw": "latest"
  }
}
PKGEOF

cd "$CORE_DIR"
echo -e "  ${CYAN}从国内镜像下载 OpenClaw...${NC}"
"$NODE_BIN" "$NPM_BIN" install --registry="$MIRROR" 2>&1 | tail -5
echo -e "  ${CYAN}安装 QQ 插件...${NC}"
"$NODE_BIN" "$NPM_BIN" install @sliverp/qqbot@latest --registry="$MIRROR" 2>&1 | tail -2
echo -e "  ${GREEN}OpenClaw 安装完成 ✓${NC}"
echo ""

# ---- Step 3: Create config & launch script ----
echo -e "  ${BOLD}[3/4] 创建配置和启动脚本...${NC}"

# Default config
mkdir -p "$INSTALL_DIR/data/.openclaw"
mkdir -p "$INSTALL_DIR/data/memory"
mkdir -p "$INSTALL_DIR/data/backups"

CONFIG_PATH="$INSTALL_DIR/data/.openclaw/openclaw.json"
if [ ! -f "$CONFIG_PATH" ]; then
    cat > "$CONFIG_PATH" << 'CFGEOF'
{
  "gateway": {
    "mode": "local",
    "auth": { "token": "uclaw" }
  }
}
CFGEOF
fi

# Launch script
cat > "$INSTALL_DIR/start.sh" << STARTEOF
#!/bin/bash
DIR="$INSTALL_DIR"
NODE_BIN="$NODE_BIN"
CORE_DIR="\$DIR/core"
OPENCLAW_MJS="\$CORE_DIR/node_modules/openclaw/openclaw.mjs"

export OPENCLAW_HOME="\$DIR/data"
export OPENCLAW_STATE_DIR="\$DIR/data/.openclaw"
export OPENCLAW_CONFIG_PATH="\$DIR/data/.openclaw/openclaw.json"

PORT=18789
while ss -tlnp 2>/dev/null | grep -q ":\$PORT " || netstat -tlnp 2>/dev/null | grep -q ":\$PORT "; do
    PORT=\$((PORT + 1))
    [ \$PORT -gt 18799 ] && echo "No available port" && exit 1
done

echo "Starting OpenClaw on port \$PORT..."
cd "\$CORE_DIR"
"\$NODE_BIN" "\$OPENCLAW_MJS" gateway run --allow-unconfigured --force --port \$PORT &
PID=\$!

for i in \$(seq 1 30); do
    sleep 0.5
    if curl -s -o /dev/null "http://127.0.0.1:\$PORT/" 2>/dev/null; then
        xdg-open "http://127.0.0.1:\$PORT/#token=uclaw" 2>/dev/null || echo "Open: http://127.0.0.1:\$PORT/#token=uclaw"
        break
    fi
done

wait \$PID
STARTEOF
chmod +x "$INSTALL_DIR/start.sh"

echo -e "  ${GREEN}启动脚本已创建 ✓${NC}"
echo ""

# ---- Step 4: Create desktop shortcut ----
echo -e "  ${BOLD}[4/4] 创建桌面快捷方式...${NC}"

DESKTOP_FILE="$HOME/Desktop/U-Claw.desktop"
cat > "$DESKTOP_FILE" << DESKEOF
[Desktop Entry]
Name=U-Claw AI 助手
Comment=Portable AI Agent powered by OpenClaw
Exec=bash $INSTALL_DIR/start.sh
Terminal=true
Type=Application
Categories=Utility;
DESKEOF
chmod +x "$DESKTOP_FILE"

# Also add to applications menu
mkdir -p "$HOME/.local/share/applications"
cp "$DESKTOP_FILE" "$HOME/.local/share/applications/u-claw.desktop"

echo -e "  ${GREEN}桌面快捷方式已创建 ✓${NC}"
echo ""

# ---- Summary ----
INSTALL_SIZE=$(du -sh "$INSTALL_DIR" | cut -f1)

echo -e "  ${GREEN}${BOLD}╔══════════════════════════════════════╗"
echo -e "  ║   ✅ 安装成功！                       ║"
echo -e "  ╚══════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BOLD}安装位置:${NC} $INSTALL_DIR"
echo -e "  ${BOLD}大小:${NC}     $INSTALL_SIZE"
echo ""
echo -e "  ${BOLD}启动方式:${NC}"
echo -e "    双击桌面的 ${CYAN}U-Claw AI 助手${NC} 图标"
echo -e "    或终端运行: ${CYAN}bash ~/U-Claw/start.sh${NC}"
echo ""
echo -e "  ${BOLD}首次使用:${NC}"
echo -e "    启动后浏览器自动打开 → 选择 AI 模型 → 填写 API Key"
echo ""
echo -e "  ${YELLOW}${BOLD}⚠️ 持久化提醒:${NC}"
echo -e "  ${YELLOW}如果你用 Rufus 制作启动盘时开启了 Persistent Storage，${NC}"
echo -e "  ${YELLOW}上述安装和配置在重启后仍然保留。${NC}"
echo -e "  ${YELLOW}如果没有开启持久化，重启后需要重新运行此脚本。${NC}"
echo ""
read -p "  按回车关闭..."
