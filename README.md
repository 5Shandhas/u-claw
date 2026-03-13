# 🦞 U-Claw

> **制作「插上就能用」的 AI 助手 U 盘 — 教程与源代码**
> **Build a plug-and-play AI assistant USB drive — Tutorial & Source Code**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[中文](#中文) | [English](#english)

---

<a id="中文"></a>

## 中文

### 这是什么

这个仓库是一个**制作教程 + 全套源代码**，教你把 [OpenClaw](https://github.com/openclaw/openclaw)（开源 AI 助手框架）做成 U 盘——插上任意电脑，双击就能用 AI。

代码库本身就是 U 盘的文件骨架，运行 `setup.sh` 补齐大依赖后，整个 `portable/` 目录直接拷贝到 U 盘即可。

### 两种 U 盘模式

| | 便携版 U 盘 | Linux 启动盘 |
|---|---|---|
| **原理** | 在已有系统（Mac/Win/Linux）上运行 U 盘里的脚本 | 从 U 盘启动整个 Linux 系统 + OpenClaw |
| **U 盘要求** | 4GB+ | **64GB+ USB 3.0**（USB 2.0 太慢不推荐） |
| **依赖** | 电脑已有操作系统 | 不依赖任何已装系统 |
| **适合** | 临时用、公共电脑、演示 | 专用 AI 工作站、无系统裸机 |

### 快速开始：制作便携版 U 盘

```bash
# 1. 克隆代码
git clone https://github.com/dongsheng123132/u-claw.git

# 2. 补齐大依赖（Node.js + OpenClaw，国内镜像，约 1 分钟）
cd u-claw/portable && bash setup.sh

# 3. 拷贝到 U 盘
cp -R portable/ /Volumes/你的U盘/U-Claw/   # Mac
# 或 Windows 资源管理器直接拖过去
```

**完成！** 插上 U 盘，双击启动脚本就能用。

### 制作 Linux 启动盘

把整个 Linux 系统 + OpenClaw 刻在 U 盘，开机从 USB 启动直接进入 AI 助手桌面。

**准备：**
- **64GB+ USB 3.0 U 盘**（推荐三星 BAR Plus、闪迪 CZ880 等高速盘）
- Linux Mint ISO（[清华镜像](https://mirrors.tuna.tsinghua.edu.cn/linuxmint-cd/stable/) / [中科大镜像](https://mirrors.ustc.edu.cn/linuxmint-cd/stable/)）
- Rufus v4.0+（[rufus.ie](https://rufus.ie/zh/)）

**步骤：**
1. Rufus 刻录 ISO → 开启 **Persistent Storage**（8-16GB）
2. USB 启动 → 进入 Linux Mint 桌面 → 连网
3. 运行安装脚本：
```bash
curl -O https://raw.githubusercontent.com/dongsheng123132/u-claw/main/portable/setup-linux-usb.sh
bash setup-linux-usb.sh
```

详细图文教程见 [guide.html → Linux 启动盘模式](https://u-claw.org/guide.html)。

### U 盘功能一览

| 功能 | Mac | Windows | Linux |
|------|-----|---------|-------|
| **免安装运行** | `Mac-Start.command` | `Windows-Start.bat` | `bash Linux-Start.sh` |
| **功能菜单** | `Mac-Menu.command` | `Windows-Menu.bat` | `bash Linux-Menu.sh` |
| **安装到电脑** | `Mac-Install.command` | `Windows-Install.bat` | `bash Linux-Install.sh` |
| **首次配置** | `Config.html` | `Config.html` | `Config.html` |

### U 盘文件结构

```
U-Claw/                          ← 整个拷到 U 盘
├── Mac-Start.command             Mac 免安装运行
├── Mac-Menu.command              Mac 功能菜单
├── Mac-Install.command           安装到 Mac
├── Windows-Start.bat             Windows 免安装运行
├── Windows-Menu.bat              Windows 功能菜单
├── Windows-Install.bat           安装到 Windows
├── Linux-Start.sh                Linux 免安装运行
├── Linux-Menu.sh                 Linux 功能菜单
├── Linux-Install.sh              安装到 Linux
├── setup-linux-usb.sh            Linux 启动盘内安装 OpenClaw
├── Config.html                   首次配置页面
├── setup.sh                      补齐依赖（开发者用）
├── app/                          ← 大依赖（setup.sh 下载，不进 git）
│   ├── core/                        OpenClaw + QQ 插件
│   └── runtime/
│       ├── node-mac-arm64/          Mac Apple Silicon
│       ├── node-win-x64/           Windows 64-bit
│       └── node-linux-x64/         Linux x86_64
└── data/                         ← 用户数据（不进 git）
    ├── .openclaw/                   配置文件
    ├── memory/                      AI 记忆
    └── backups/                     备份
```

### 桌面安装版（Electron App）

除了 U 盘便携版，还有桌面 App 版本：

```bash
cd u-claw-app
bash setup.sh            # 一键安装开发环境（国内镜像）
npm run dev              # 开发模式运行
npm run build:mac-arm64  # 打包 → release/*.dmg
npm run build:win        # 打包 → release/*.exe
```

### 支持的 AI 模型

**国产模型（无需翻墙）：**

| 模型 | 推荐场景 |
|------|----------|
| DeepSeek | 编程首选，极便宜 |
| Kimi K2.5 | 长文档，256K 上下文 |
| 通义千问 Qwen | 免费额度大 |
| 智谱 GLM | 学术场景 |
| MiniMax | 语音多模态 |
| 豆包 Doubao | 火山引擎 |

**国际模型：** Claude · GPT · Gemini（需翻墙或中转）

### 支持的聊天平台

| 平台 | 状态 | 说明 |
|------|------|------|
| QQ | ✅ 已预装 | 输入 AppID + Secret 即可 |
| 飞书 | ✅ 内置 | 企业首选 |
| Telegram | ✅ 内置 | 海外推荐 |
| WhatsApp | ✅ 内置 | Baileys 协议 |
| Discord | ✅ 内置 | — |
| 微信 | ✅ 社区插件 | iPad 协议 |

### 国内镜像

所有脚本默认走国内镜像，无需翻墙：

| 资源 | 镜像 |
|------|------|
| npm 包 | `registry.npmmirror.com` |
| Node.js | `npmmirror.com/mirrors/node` |
| Electron | `npmmirror.com/mirrors/electron` |

### 开发 & 贡献

```bash
git clone https://github.com/dongsheng123132/u-claw.git
cd u-claw/portable && bash setup.sh
bash Mac-Start.command   # Mac 测试
bash Linux-Start.sh      # Linux 测试
```

**平台支持：**

| 平台 | 状态 |
|------|------|
| Mac Apple Silicon (M1-M4) | ✅ |
| Linux x86_64 | ✅ |
| Linux ARM64 | ✅ |
| Windows x64 | 🚧 开发中 |
| Mac Intel | ❌ 暂不支持 |

欢迎 PR！特别需要：Windows 脚本完善、新平台支持、教程翻译。

### FAQ

**Q: 需要翻墙吗？**
不需要。安装和运行全程使用国内镜像，国产模型 API 直连。

**Q: U 盘需要多大？**
便携版 4GB+（完整约 2.3GB）。Linux 启动盘 64GB+ USB 3.0。

**Q: 能分发吗？**
MIT 协议，随便复制分发。

**Q: Mac 提示"未验证的开发者"？**
右键脚本 → 打开。

### 联系

- 微信: hecare888
- GitHub: [@dongsheng123132](https://github.com/dongsheng123132)
- 官网: [u-claw.org](https://u-claw.org)

---

<a id="english"></a>

## English

### What is this

This repo is a **tutorial + complete source code** for building an [OpenClaw](https://github.com/openclaw/openclaw) (open-source AI assistant framework) USB drive — plug it into any computer, double-click, and start using AI.

The codebase itself is the USB file skeleton. Run `setup.sh` to download large dependencies, then copy the entire `portable/` directory to a USB drive.

### Two USB modes

| | Portable USB | Linux Live USB |
|---|---|---|
| **How it works** | Runs scripts from USB on existing OS (Mac/Win/Linux) | Boots entire Linux system + OpenClaw from USB |
| **USB requirement** | 4GB+ | **64GB+ USB 3.0** (USB 2.0 too slow) |
| **Depends on** | Existing OS on computer | Nothing — boots independently |
| **Best for** | Temporary use, public computers, demos | Dedicated AI workstation, bare metal |

### Quick Start: Build a Portable USB

```bash
# 1. Clone
git clone https://github.com/dongsheng123132/u-claw.git

# 2. Download dependencies (Node.js + OpenClaw, ~1 min)
cd u-claw/portable && bash setup.sh

# 3. Copy to USB drive
cp -R portable/ /Volumes/YOUR_USB/U-Claw/   # Mac
# Or drag & drop on Windows/Linux
```

**Done!** Plug in the USB, double-click the start script, and you're running AI.

### Build a Linux Live USB

Boot an entire Linux system + OpenClaw directly from USB — no existing OS required.

**You need:**
- **64GB+ USB 3.0 drive** (recommended: Samsung BAR Plus, SanDisk Extreme)
- Linux Mint ISO ([linuxmint.com](https://linuxmint.com/download.php))
- Rufus v4.0+ ([rufus.ie](https://rufus.ie/en/))

**Steps:**
1. Flash ISO with Rufus → enable **Persistent Storage** (8-16GB)
2. Boot from USB → enter Linux Mint desktop → connect to internet
3. Run the install script:
```bash
curl -O https://raw.githubusercontent.com/dongsheng123132/u-claw/main/portable/setup-linux-usb.sh
bash setup-linux-usb.sh
```

Full guide at [guide.html → Linux Live USB](https://u-claw.org/guide.html).

### USB Features

| Feature | Mac | Windows | Linux |
|---------|-----|---------|-------|
| **Run (no install)** | `Mac-Start.command` | `Windows-Start.bat` | `bash Linux-Start.sh` |
| **Menu** | `Mac-Menu.command` | `Windows-Menu.bat` | `bash Linux-Menu.sh` |
| **Install to PC** | `Mac-Install.command` | `Windows-Install.bat` | `bash Linux-Install.sh` |
| **First-time config** | `Config.html` | `Config.html` | `Config.html` |

### File Structure

```
U-Claw/                          ← Copy entire folder to USB
├── Mac-Start.command             Mac launcher
├── Mac-Menu.command              Mac menu (8 options)
├── Mac-Install.command           Install to Mac
├── Windows-Start.bat             Windows launcher
├── Windows-Menu.bat              Windows menu
├── Windows-Install.bat           Install to Windows
├── Linux-Start.sh                Linux launcher
├── Linux-Menu.sh                 Linux menu
├── Linux-Install.sh              Install to Linux
├── setup-linux-usb.sh            Install OpenClaw in Linux live USB
├── Config.html                   First-time config page
├── setup.sh                      Download dependencies (dev use)
├── app/                          ← Large deps (downloaded by setup.sh, not in git)
│   ├── core/                        OpenClaw + QQ plugin
│   └── runtime/
│       ├── node-mac-arm64/          Mac Apple Silicon
│       ├── node-win-x64/           Windows 64-bit
│       └── node-linux-x64/         Linux x86_64
└── data/                         ← User data (not in git)
    ├── .openclaw/                   Config file
    ├── memory/                      AI memory
    └── backups/                     Backups
```

### Desktop App (Electron)

```bash
cd u-claw-app
bash setup.sh            # One-click dev setup (China mirrors)
npm run dev              # Dev mode
npm run build:mac-arm64  # Build → release/*.dmg
npm run build:win        # Build → release/*.exe
```

### Supported AI Models

**Chinese models (no VPN needed):**

| Model | Best for |
|-------|----------|
| DeepSeek | Coding, extremely cheap |
| Kimi K2.5 | Long documents, 256K context |
| Qwen | Large free tier |
| GLM (Zhipu) | Academic use |
| MiniMax | Voice & multimodal |
| Doubao | Volcengine ecosystem |

**International models:** Claude · GPT · Gemini (VPN or relay required in China)

### Supported Chat Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| QQ | ✅ Pre-installed | Enter AppID + Secret |
| Feishu (Lark) | ✅ Built-in | Enterprise favorite |
| Telegram | ✅ Built-in | International |
| WhatsApp | ✅ Built-in | Baileys protocol |
| Discord | ✅ Built-in | — |
| WeChat | ✅ Community plugin | iPad protocol |

### China Mirrors

All scripts use China mirrors by default — no VPN needed:

| Resource | Mirror |
|----------|--------|
| npm packages | `registry.npmmirror.com` |
| Node.js | `npmmirror.com/mirrors/node` |
| Electron | `npmmirror.com/mirrors/electron` |

### Development & Contributing

```bash
git clone https://github.com/dongsheng123132/u-claw.git
cd u-claw/portable && bash setup.sh
bash Mac-Start.command   # Test on Mac
bash Linux-Start.sh      # Test on Linux
```

**Platform Support:**

| Platform | Status |
|----------|--------|
| Mac Apple Silicon (M1-M4) | ✅ |
| Linux x86_64 | ✅ |
| Linux ARM64 | ✅ |
| Windows x64 | 🚧 In progress |
| Mac Intel | ❌ Not yet |

PRs welcome! Especially: Windows scripts, new platform support, documentation.

### FAQ

**Q: Do I need a VPN?**
No. All downloads use China mirrors. Chinese AI model APIs work directly.

**Q: How big should the USB drive be?**
Portable mode: 4GB+ (~2.3GB full). Linux live USB: 64GB+ USB 3.0.

**Q: Can I redistribute?**
MIT license — copy and share freely.

**Q: Mac says "unverified developer"?**
Right-click the script → Open.

### Contact

- WeChat: hecare888
- GitHub: [@dongsheng123132](https://github.com/dongsheng123132)
- Website: [u-claw.org](https://u-claw.org)

---

**Made with 🦞 by [dongsheng](https://github.com/dongsheng123132)**
