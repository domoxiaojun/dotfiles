# 🎨 Domo's Dotfiles

> 我的 macOS 终端配置文件，使用 [chezmoi](https://www.chezmoi.io/) 管理

![Ghostty + Starship + Tmux](https://img.shields.io/badge/Terminal-Ghostty-blue)
![Theme](https://img.shields.io/badge/Theme-Catppuccin_Mocha-pink)

## ✨ 特性

- 🎨 **24-bit 真彩色支持** - Catppuccin Mocha 主题
- 🚀 **一键安装** - 新机器上一条命令完成所有配置
- 🔧 **模块化配置** - 使用 chezmoi 模板支持多环境
- 🛠️ **自动化脚本** - 自动安装所有依赖工具
- 📦 **丰富的工具集** - 精选的终端美化和生产力工具

## 📦 包含的配置

### 核心工具

| 工具 | 描述 | 配置文件 |
|------|------|---------|
| **Ghostty** | 现代终端模拟器 | `.config/ghostty/config` |
| **Starship** | 跨 Shell 的提示符 | `.config/starship.toml` |
| **Zsh** | Shell + 插件 | `.zshrc` |
| **Tmux** | 终端复用器 | `.tmux.conf` |
| **Git** | 版本控制 + delta | `.gitconfig` |

### 美化工具

- `lsd` - 彩色 ls（带图标和文件类型）
- `bat` - 彩色 cat（语法高亮）
- `delta` - Git diff 美化工具
- `btop` - 系统资源监控
- `glow` - Markdown 渲染器
- `fx` - 交互式 JSON 查看器

### Zsh 插件

- `zsh-syntax-highlighting` - 命令语法高亮
- `zsh-autosuggestions` - 智能命令补全提示

### Tmux 插件

- `tmux-resurrect` - 会话保存和恢复
- `tmux-continuum` - 自动保存会话
- `tmux-open` - 快速打开 URL 和文件
- `tmux-copycat` - 搜索和高亮增强
- `extrakto` - 模糊搜索选择文本（需要 fzf）

## 🚀 快速开始

### 新 macOS 一键安装

```bash
# 安装 chezmoi 并应用所有配置
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply domoxiaojun
```

这条命令会：
1. ✅ 安装 chezmoi
2. ✅ 克隆此仓库
3. ✅ 应用所有配置文件
4. ✅ 自动安装所有依赖工具（通过安装脚本）

### 手动安装（分步骤）

#### 1. 安装 Homebrew（如果还没有）

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### 2. 安装 chezmoi

```bash
brew install chezmoi
```

#### 3. 初始化配置

```bash
# 克隆仓库
chezmoi init domoxiaojun

# 查看将要应用的更改
chezmoi diff

# 应用配置
chezmoi apply -v
```

#### 4. 安装 Tmux 插件

```bash
# 启动 tmux
tmux

# 在 tmux 内按 Ctrl+b I（大写 I）安装所有插件
```

#### 5. 重启终端

关闭并重新打开 Ghostty，所有配置即可生效！

## 📝 日常使用

### 更新配置

在原机器上修改配置后：

```bash
# 查看修改
chezmoi diff

# 添加修改的文件
chezmoi add ~/.zshrc

# 提交更改
chezmoi cd
git add .
git commit -m "更新 zsh 配置"
git push
exit
```

在新机器上同步：

```bash
chezmoi update
```

### 添加新配置文件

```bash
# 添加文件到 chezmoi
chezmoi add ~/.config/newapp/config

# 查看管理的文件
chezmoi managed
```

## ⌨️ 常用快捷键

### Ghostty

| 快捷键 | 功能 |
|--------|------|
| `⌘+T` | 新建标签页 |
| `⌘+W` | 关闭标签页 |
| `⌘+1~9` | 快速跳转标签页 |
| `⌘+D` | 右分屏 |
| `⌘+Shift+D` | 下分屏 |
| `⌘+Ctrl+H/J/K/L` | Vim 风格切换分屏 |
| `⌘+=` | 等分所有分屏 |
| `Shift+Enter` | 换行 |

### Tmux

| 快捷键 | 功能 |
|--------|------|
| `⌃+b \|` | 垂直分屏 |
| `⌃+b -` | 水平分屏 |
| `⌃+b h/j/k/l` | Vim 风格切换面板 |
| `⌃+b Ctrl+s` | 保存会话 |
| `⌃+b Ctrl+r` | 恢复会话 |
| `⌃+b o` | 打开 URL |
| `⌃+b r` | 重载配置 |

### Zsh 别名

| 命令 | 原命令 | 功能 |
|------|--------|------|
| `ls` | `lsd` | 彩色列表（带图标） |
| `ll` | `lsd -l` | 详细列表 |
| `la` | `lsd -la` | 显示隐藏文件 |
| `lt` | `lsd --tree` | 树状显示 |
| `cat` | `bat --paging=never` | 语法高亮显示 |
| `catt` | `bat --paging=never` | 带行号显示 |
| `md` | `glow` | 渲染 Markdown |
| `top` | `btop` | 系统监控 |

## 🎨 主题预览

**Ghostty**:
- 主题: Catppuccin Mocha
- 字体: MesloLGS Nerd Font Mono 13.5pt
- 颜色: 24-bit 真彩色
- 背景: 95% 不透明度 + 毛玻璃效果

**Starship**:
- Git 分支: 紫色  图标
- Python 版本: 黄色  图标
- 目录: 青色
- 提示符: 绿色 ❯

**Tmux**:
- 简洁默认样式
- 紫色窗口标签

## 📚 参考资料

- [chezmoi 官方文档](https://www.chezmoi.io/)
- [Ghostty 文档](https://ghostty.org/)
- [Starship 文档](https://starship.rs/)
- [Catppuccin 主题](https://github.com/catppuccin/catppuccin)

## 🐛 故障排除

### Ghostty 图标不显示

确保安装了 Nerd Font：
```bash
brew install --cask font-meslo-lg-nerd-font
```

### Tmux 插件未加载

```bash
~/.tmux/plugins/tpm/bin/install_plugins
tmux source ~/.tmux.conf
```

### Zsh 插件未生效

```bash
source ~/.zshrc
```

### Chezmoi 模板变量错误

编辑数据文件：
```bash
chezmoi edit-config
```

## 🔧 自定义

### 修改 Git 用户信息

编辑 `.chezmoidata.yaml`:
```yaml
email: "your-email@example.com"
```

### 修改终端主题

编辑 `.chezmoi.yaml.tmpl`:
```yaml
terminal:
  ghostty:
    theme: "nord"  # 或其他主题
```

## 📄 License

MIT

---

Made with ❤️ by Domo
