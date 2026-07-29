# Domo's Dotfiles

> 我的跨平台终端配置文件，使用 [chezmoi](https://www.chezmoi.io/) 管理

![CI](https://github.com/domoxiaojun/dotfiles/actions/workflows/test.yml/badge.svg)
![Ghostty + Starship + Tmux](https://img.shields.io/badge/Terminal-Ghostty-blue)
![Theme](https://img.shields.io/badge/Theme-Catppuccin_Mocha-pink)
![Platform](https://img.shields.io/badge/Platform-macOS%20|%20Linux%20|%20Windows-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

## 特性

- **24-bit 真彩色支持** - Catppuccin Mocha 主题
- **一键安装** - 新机器上一条命令完成所有配置
- **跨平台支持** - macOS / Linux (Fedora, Ubuntu) / Windows
- **模块化配置** - 使用 chezmoi 模板支持多环境
- **自动化脚本** - 自动安装所有依赖工具

## 包含的配置

### 核心工具

| 工具           | 描述               | 配置文件                                                | 平台                |
| -------------- | ------------------ | ------------------------------------------------------- | ------------------- |
| **Ghostty**    | 现代终端模拟器     | `.config/ghostty/config`                                | macOS / Linux       |
| **Starship**   | 跨 Shell 的提示符  | `.config/starship.toml`                                 | 全平台              |
| **Bash**       | Shell + 别名       | `.bash_aliases`(Debian/Ubuntu)<br>`.bashrc.d/10-dotfiles.sh`(Fedora/RHEL) | Linux |
| **Zsh**        | Shell + 插件       | `.zshrc`                                                | macOS               |
| **PowerShell** | Shell + PSReadLine | `Documents/PowerShell/Microsoft.PowerShell_profile.ps1` | Windows             |
| **Tmux**       | 终端复用器         | `.tmux.conf`                                            | macOS / Linux       |
| **Git**        | 版本控制 + delta   | `.gitconfig`                                            | 全平台              |

### 美化工具

- `lsd` - 彩色 ls（带图标和文件类型）
- `bat` - 彩色 cat（语法高亮）
- `delta` - Git diff 美化工具
- `btop` - 系统资源监控
- `glow` - Markdown 渲染器
- `fx` - JSON 交互式查看器
- `fd` - 更好的 find 替代品
- `ripgrep` - 更好的 grep 替代品
- `yazi` - 终端文件管理器
- `zoxide` - 智能 cd（`z 项目名` 跳到含该名的常用目录）
- `gh` - GitHub CLI（命令行操作 issue/pr/release）
- `vim` - 跨平台最小可用配置（行号 / mouse / clipboard）

### Shell 增强

- `fzf` 集成 - **Ctrl+R**（历史搜索）/ **Ctrl+T**（文件搜索）/ **Alt+C**（目录跳转）
- `zsh-syntax-highlighting` - 命令语法高亮
- `zsh-autosuggestions` - 智能命令补全提示

### Tmux 插件

- `tmux-resurrect` - 会话保存和恢复
- `tmux-continuum` - 自动保存会话
- `tmux-yank` - 系统剪贴板集成
- `extrakto` - 模糊搜索选择文本（需要 fzf）
- `catppuccin/tmux` - Catppuccin 主题

## 快速开始

### Fedora 一键安装

```bash
# 安装 chezmoi
sudo dnf install chezmoi

# 初始化并应用所有配置
chezmoi init --apply domoxiaojun
```

这条命令会：

1. 克隆此仓库
2. 应用所有配置文件
3. 自动安装所有依赖工具（Ghostty, Starship, lsd, bat 等）
4. 安装 wl-clipboard (Wayland 剪贴板)
5. 安装 MesloLGS Nerd Font

### Ubuntu/Debian 一键安装

```bash
# 安装 chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# 初始化并应用所有配置
chezmoi init --apply domoxiaojun
```

### macOS 一键安装

```bash
# 安装 chezmoi 并应用所有配置
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply domoxiaojun
```

这条命令会：

1. 安装 chezmoi
2. 克隆此仓库
3. 应用所有配置文件
4. 自动安装所有依赖工具（通过 Homebrew）

### Windows 一键安装

```powershell
# 安装 Scoop（如果还没有）
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
irm get.scoop.sh | iex

# 通过 Scoop 安装 chezmoi
scoop install chezmoi

# 初始化并应用所有配置
chezmoi init --apply domoxiaojun
```

这条命令会：

1. 安装 chezmoi
2. 克隆此仓库
3. 通过 Scoop 自动安装所有工具（starship, lsd, bat, delta, btop, glow, fzf, yazi, fd, ripgrep, fx）
4. 安装 MesloLGS Nerd Font
5. 配置 PowerShell 7 profile 和 Windows Terminal

### 手动安装（分步骤）

#### 1. 安装 chezmoi

```bash
# macOS
brew install chezmoi

# Fedora
sudo dnf install chezmoi

# Ubuntu/Debian
sh -c "$(curl -fsLS get.chezmoi.io)"
```

#### 2. 初始化配置

```bash
# 克隆仓库
chezmoi init domoxiaojun

# 查看将要应用的更改
chezmoi diff

# 应用配置
chezmoi apply -v
```

#### 3. 安装 Tmux 插件

```bash
# 启动 tmux
tmux

# 在 tmux 内按 Ctrl+s Shift+I（大写 I）安装所有插件
```

#### 4. 重启终端

关闭并重新打开终端，所有配置即可生效！

## 日常使用

### 更新配置

在原机器上修改配置后：

```bash
# 查看修改
chezmoi diff

# 添加修改的文件
chezmoi add ~/.bashrc

# 提交更改
chezmoi cd
git add .
git commit -m "更新配置"
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

## 常用快捷键

### Ghostty

| 快捷键           | 功能             |
| ---------------- | ---------------- |
| `Cmd+T`          | 新建标签页       |
| `Cmd+W`          | 关闭标签页       |
| `Cmd+1~9`        | 快速跳转标签页   |
| `Cmd+D`          | 右分屏           |
| `Cmd+Shift+D`    | 下分屏           |
| `Cmd+Ctrl+H/J/K/L` | Vim 风格切换分屏 |
| `Cmd+=`          | 等分所有分屏     |
| `Shift+Enter`    | 换行             |

### Tmux

| 快捷键        | 功能             |
| ------------- | ---------------- |
| `Ctrl+s \|`   | 垂直分屏         |
| `Ctrl+s -`    | 水平分屏         |
| `Ctrl+s h/j/k/l` | Vim 风格切换面板 |
| `Ctrl+s Ctrl+s`  | 发送 Ctrl+s (前缀本身) |
| `Ctrl+s S`    | 保存会话         |
| `Ctrl+s Ctrl+r`  | 恢复会话      |
| `Ctrl+s r`    | 重载配置         |

### Shell 别名

| 命令   | 原命令                           | 功能               |
| ------ | -------------------------------- | ------------------ |
| `ls`   | `lsd`                            | 彩色列表（带图标） |
| `ll`   | `lsd -l`                         | 详细列表           |
| `la`   | `lsd -la`                        | 显示隐藏文件       |
| `lt`   | `lsd --tree`                     | 树状显示           |
| `cat`  | `bat --style=plain --paging=never` | 语法高亮显示     |
| `catt` | `bat --paging=never`             | 带行号显示         |
| `md`   | `glow`                           | 渲染 Markdown      |
| `top`  | `btop`                           | 系统监控           |

## 主题预览

**Ghostty**:

- 主题: Catppuccin Mocha
- 字体: MesloLGS Nerd Font Mono 13.5pt
- 颜色: 24-bit 真彩色
- 背景: 95% 不透明度 + 毛玻璃效果 (macOS)

**Starship**:

- Git 分支: 紫色图标
- Python 版本: 黄色图标
- 目录: 青色
- 提示符: 绿色 ❯

**Tmux**:

- 主题: Catppuccin Mocha
- 圆角窗口标签
- 状态栏显示 CPU、会话名、运行时间

## 平台差异

| 功能           | macOS              | Fedora              | Ubuntu             | Windows            |
| -------------- | ------------------ | ------------------- | ------------------ | ------------------ |
| 终端           | Ghostty            | Ghostty (COPR)      | Ghostty (脚本)     | Windows Terminal   |
| Shell          | Zsh                | Bash                | Bash               | PowerShell 7       |
| Shell 配置入口 | `.zshrc`           | `.bashrc.d/10-dotfiles.sh` | `.bash_aliases` | PowerShell profile |
| 包管理器       | Homebrew           | dnf                 | apt                | Scoop              |
| 剪贴板         | pbcopy             | wl-copy (Wayland)   | xclip/wl-copy      | 系统内置           |
| bat 命令       | `bat`              | `bat`               | `batcat`           | `bat`              |
| fd 命令        | `fd`               | `fd`                | `fdfind`           | `fd`               |
| Git 编辑器     | vim                | vim                 | vim                | notepad            |

## 故障排除

### Ghostty 图标不显示

确保安装了 Nerd Font：

```bash
# macOS
brew install --cask font-meslo-lg-nerd-font

# Linux (自动安装)
# 如果没有，手动安装：
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fsSLO "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.tar.xz"
tar -xf Meslo.tar.xz && rm Meslo.tar.xz
fc-cache -f
```

### Tmux 插件未加载

```bash
~/.tmux/plugins/tpm/bin/install_plugins
tmux source ~/.tmux.conf
```

### Tmux 剪贴板不工作 (Fedora/Wayland)

确保安装了 wl-clipboard：

```bash
sudo dnf install wl-clipboard
```

### chezmoi 模板变量错误

编辑数据文件：

```bash
chezmoi edit-config
```

### 重新输入 git 用户名/邮箱

首次 `chezmoi init` 时会询问 Git 用户配置（如果系统检测到有效 git config 会弹菜单二选一）。
如果当时填错了，或者本机 git config 后来更新了，按以下步骤重新交互：

```bash
# 清掉 chezmoi 缓存的答案
chezmoi state delete-bucket --bucket=entryState
# 删掉已生成的 yaml
rm ~/.config/chezmoi/chezmoi.yaml
# 再次 init，这次会重新弹菜单/输入框
chezmoi init
```

### Windows 终端字体异常

如果 Windows Terminal 没有显示 Nerd Font 字体（图标变成方块），运行诊断脚本：

```powershell
pwsh F:\path\to\dotfiles\scripts\fix_windows_style.ps1
```

它会检查 Meslo Nerd Font 是否安装、Windows Terminal 默认字体是否设置正确，
能自动修复缺失的字体配置。

### Starship 未生效

```bash
# 检查是否安装
starship --version

# 如果未安装
curl -sS https://starship.rs/install.sh | sh
```

## 自定义

### 修改 Git 用户信息

首次 `chezmoi init` 会自动检测系统的 `git config user.name` / `user.email`：

- **检测到有效配置** → 弹二选一菜单：
  ```
  检测到当前 git 配置: Domo <you@example.com>。
  选择来源 (git=使用当前 / custom=手动输入) [git]: _
  ```
  回车（默认 `git`）→ 直接采用当前 git config 的值。
  输入 `custom` 回车 → 进入自定义输入，可分别改名字和邮箱。

- **未检测到 / 是占位符** → 直接逐项询问 `Git 用户名` 和 `Git 邮箱`，回车采用默认值。

答案会被 chezmoi state 缓存，**后续 `chezmoi apply` 不再询问**。要重新输入见
「故障排除」章节。

也可以直接配置 git：

```bash
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"
```

### 在 Linux 上使用 Zsh

编辑 `.chezmoiignore`，注释掉 Linux 段里的 `.zshrc` / `.zprofile`：

```yaml
# {{ if eq .chezmoi.os "linux" }}
# .zshrc
# .zprofile
# {{ end }}
```

然后：

```bash
# 安装 zsh
sudo dnf install zsh  # Fedora
sudo apt install zsh  # Ubuntu

# 设为默认 shell
chsh -s $(which zsh)

# 重新应用配置
chezmoi apply
```

## 参考资料

- [chezmoi 官方文档](https://www.chezmoi.io/)
- [Ghostty 文档](https://ghostty.org/)
- [Starship 文档](https://starship.rs/)
- [Catppuccin 主题](https://github.com/catppuccin/catppuccin)

## License

MIT

---

Made with ❤ by Domo
