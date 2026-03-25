#!/bin/bash
# 此脚本在 Linux 上 chezmoi apply 时自动运行
# 用于安装必要的工具和依赖

set -e

echo "🚀 开始安装依赖工具..."

# 检测包管理器
if command -v apt &> /dev/null; then
    PKG_MANAGER="apt"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
else
    echo "⚠️  未检测到支持的包管理器 (apt/dnf)"
    exit 1
fi

# 检测系统架构
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        ARCH_SUFFIX="amd64"
        ARCH_ALT="x86_64"
        ;;
    aarch64|arm64)
        ARCH_SUFFIX="arm64"
        ARCH_ALT="aarch64"
        ;;
    *)
        echo "⚠️  未支持的架构: $ARCH"
        ARCH_SUFFIX="amd64"
        ARCH_ALT="x86_64"
        ;;
esac

# 安装 Ghostty
if ! command -v ghostty &> /dev/null; then
    echo "👻 安装 Ghostty..."
    if [ "$PKG_MANAGER" = "apt" ]; then
        # Ubuntu: 使用社区维护的安装脚本
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        # Fedora: 使用 COPR
        sudo dnf copr enable -y scottames/ghostty
        sudo dnf install -y ghostty
    fi
else
    echo "✅ Ghostty 已安装"
fi

# 安装 Starship
if ! command -v starship &> /dev/null; then
    echo "🚀 安装 Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
else
    echo "✅ Starship 已安装"
fi

# 安装常用工具
echo "📦 安装常用工具..."
if [ "$PKG_MANAGER" = "apt" ]; then
    sudo apt update
    sudo apt install -y git zsh tmux fzf bat btop || true
elif [ "$PKG_MANAGER" = "dnf" ]; then
    sudo dnf install -y git zsh tmux fzf bat btop || true
fi

# 安装 lsd
if ! command -v lsd &> /dev/null; then
    echo "📂 安装 lsd..."
    if [ "$PKG_MANAGER" = "apt" ]; then
        # lsd 不在默认 apt 源中，使用 dpkg
        LSD_VERSION=$(curl -s https://api.github.com/repos/lsd-rs/lsd/releases/latest | grep -o '"tag_name": "[^"]*"' | head -1 | cut -d'"' -f4 | sed 's/^v//')
        if [ -z "$LSD_VERSION" ]; then
            echo "⚠️  无法获取 lsd 最新版本号，跳过安装"
        else
            curl -fsSLO "https://github.com/lsd-rs/lsd/releases/latest/download/lsd_${LSD_VERSION}_${ARCH_SUFFIX}.deb"
            sudo dpkg -i "lsd_${LSD_VERSION}_${ARCH_SUFFIX}.deb" || true
            rm -f "lsd_${LSD_VERSION}_${ARCH_SUFFIX}.deb"
        fi
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        sudo dnf install -y lsd || true
    fi
else
    echo "✅ lsd 已安装"
fi

# 安装 delta
if ! command -v delta &> /dev/null; then
    echo "📊 安装 git-delta..."
    if [ "$PKG_MANAGER" = "apt" ]; then
        DELTA_VERSION=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | grep -o '"tag_name": "[^"]*"' | head -1 | cut -d'"' -f4)
        if [ -z "$DELTA_VERSION" ]; then
            echo "⚠️  无法获取 delta 最新版本号，跳过安装"
        else
            curl -fsSLO "https://github.com/dandavison/delta/releases/latest/download/git-delta_${DELTA_VERSION}_${ARCH_SUFFIX}.deb"
            sudo dpkg -i "git-delta_${DELTA_VERSION}_${ARCH_SUFFIX}.deb" || true
            rm -f "git-delta_${DELTA_VERSION}_${ARCH_SUFFIX}.deb"
        fi
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        sudo dnf install -y git-delta || true
    fi
else
    echo "✅ delta 已安装"
fi

# 安装 glow
if ! command -v glow &> /dev/null; then
    echo "✨ 安装 glow..."
    if [ "$PKG_MANAGER" = "apt" ]; then
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
        sudo apt update && sudo apt install -y glow
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        sudo dnf install -y glow || true
    fi
else
    echo "✅ glow 已安装"
fi

# 安装 yazi (终端文件管理器)
if ! command -v yazi &> /dev/null; then
    echo "📁 安装 yazi..."
    # 优先使用预编译二进制，cargo 编译耗时长
    YAZI_VERSION=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest | grep -o '"tag_name": "[^"]*"' | head -1 | cut -d'"' -f4 | sed 's/^v//')
    YAZI_ARCH="${ARCH_ALT}-unknown-linux-musl"
    if [ -n "$YAZI_VERSION" ] && curl -fsSLO "https://github.com/sxyazi/yazi/releases/latest/download/yazi-${YAZI_ARCH}.zip" 2>/dev/null; then
        unzip -o "yazi-${YAZI_ARCH}.zip" -d yazi-tmp
        sudo mv yazi-tmp/yazi-${YAZI_ARCH}/yazi /usr/local/bin/
        rm -rf yazi-tmp "yazi-${YAZI_ARCH}.zip"
    elif command -v cargo &> /dev/null; then
        cargo install --locked yazi-fm
    else
        echo "⚠️  无法安装 yazi（需要 cargo 或网络连接）"
    fi
else
    echo "✅ yazi 已安装"
fi

# 安装 zsh 插件
echo "🔌 安装 Zsh 插件..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
    if [ "$PKG_MANAGER" = "apt" ]; then
        sudo apt install -y zsh-syntax-highlighting || true
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        sudo dnf install -y zsh-syntax-highlighting || true
    fi
fi
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
    if [ "$PKG_MANAGER" = "apt" ]; then
        sudo apt install -y zsh-autosuggestions || true
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        sudo dnf install -y zsh-autosuggestions || true
    fi
fi

# 安装 TPM（Tmux 插件管理器）
if [ ! -d ~/.tmux/plugins/tpm ]; then
    echo "📦 安装 TPM (Tmux Plugin Manager)..."
    git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo "✅ TPM 已安装"
fi

# 安装 Nerd Font
if ! fc-list | grep -qi "MesloLGS Nerd Font" 2>/dev/null; then
    echo "🔤 安装 MesloLGS Nerd Font..."
    mkdir -p ~/.local/share/fonts
    cd ~/.local/share/fonts
    curl -fsSLO "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.tar.xz"
    tar -xf Meslo.tar.xz
    rm -f Meslo.tar.xz
    fc-cache -f
    cd -
else
    echo "✅ Nerd Font 已安装"
fi

echo ""
echo "✅ 所有依赖安装完成！"
echo ""
echo "📝 后续步骤："
echo "  1. 重新打开一个终端窗口，以加载最新的 Bash 配置"
echo "  2. 启动 tmux 并按 Ctrl+s Shift+i 安装插件"
echo "     Ctrl+s 已保留为 tmux 主前缀；交互式终端会自动关闭软件流控"
echo "  3. 享受你的新终端环境！"
