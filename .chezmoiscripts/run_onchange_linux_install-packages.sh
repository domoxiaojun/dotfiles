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
    sudo apt install -y zsh tmux fzf bat btop || true
elif [ "$PKG_MANAGER" = "dnf" ]; then
    sudo dnf install -y zsh tmux fzf bat btop || true
fi

# 安装 lsd
if ! command -v lsd &> /dev/null; then
    echo "📂 安装 lsd..."
    if [ "$PKG_MANAGER" = "apt" ]; then
        # lsd 不在默认 apt 源中，使用 dpkg
        LSD_VERSION=$(curl -s https://api.github.com/repos/lsd-rs/lsd/releases/latest | grep -oP '"tag_name": "v?\K[^"]+')
        curl -fsSLO "https://github.com/lsd-rs/lsd/releases/latest/download/lsd_${LSD_VERSION}_amd64.deb"
        sudo dpkg -i "lsd_${LSD_VERSION}_amd64.deb" || true
        rm -f "lsd_${LSD_VERSION}_amd64.deb"
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
        DELTA_VERSION=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | grep -oP '"tag_name": "\K[^"]+')
        curl -fsSLO "https://github.com/dandavison/delta/releases/latest/download/git-delta_${DELTA_VERSION}_amd64.deb"
        sudo dpkg -i "git-delta_${DELTA_VERSION}_amd64.deb" || true
        rm -f "git-delta_${DELTA_VERSION}_amd64.deb"
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
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
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
echo "  1. 重启终端"
echo "  2. 启动 tmux 并按 Ctrl+b I 安装插件"
echo "  3. 享受你的新终端环境！"
