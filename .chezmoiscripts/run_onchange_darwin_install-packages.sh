#!/bin/bash
# 此脚本在 chezmoi apply 时自动运行
# 用于安装必要的工具和依赖

set -e

echo "🚀 开始安装依赖工具..."

# 检查 Homebrew
if ! command -v brew &> /dev/null; then
    echo "📦 安装 Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "✅ Homebrew 已安装"
fi

# 安装核心工具
echo "📦 安装终端和 Shell 工具..."
brew install git ghostty starship zsh-syntax-highlighting zsh-autosuggestions

# 安装美化工具
echo "🎨 安装终端美化工具..."
brew install lsd bat git-delta btop glow fx fzf yazi

# 安装 tmux 和插件管理器
echo "🖥️  安装 Tmux..."
brew install tmux

# 安装 TPM（Tmux 插件管理器）
if [ ! -d ~/.tmux/plugins/tpm ]; then
    echo "📦 安装 TPM (Tmux Plugin Manager)..."
    git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo "✅ TPM 已安装"
fi

# 安装 Nerd Font
echo "🔤 安装 Nerd Font..."
brew install --cask font-meslo-lg-nerd-font || true

echo ""
echo "✅ 所有依赖安装完成！"
echo ""
echo "📝 后续步骤："
echo "  1. 重启终端"
echo "  2. 启动 tmux 并按 Ctrl+s Shift+i 安装插件"
echo "     Ctrl+s 已保留为 tmux 主前缀；交互式终端会自动关闭软件流控"
echo "  3. 享受你的新终端环境！"
