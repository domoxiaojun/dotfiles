# Changelog

本项目采用 [Keep a Changelog](https://keepachangelog.com/) 格式记录变更。

## [Unreleased]

### Added
- LICENSE / .editorconfig / .gitattributes / CHANGELOG.md 项目元数据
- shell-tools-init 跨 shell 共享模板（提取 starship/fzf/zoxide/aliases 等共享逻辑）
- dot_zprofile.tmpl（macOS 登录 shell 加载 brew shellenv）
- gh (GitHub CLI) 加入工具清单
- shell history 配置（HISTSIZE / SHARE_HISTORY 等）
- export EDITOR 智能选择（nvim > vim > vi）
- gitconfig 加 git aliases (co/br/st/lg/...) + diff.algorithm + blame.coloring
- gitconfig Windows editor 智能选择 (code -w > nvim > vim > notepad)
- starship/zoxide/fzf init 输出缓存（按 binary mtime 失效，shell 启动加速）
- CI 加 shellcheck / yamllint / 语法检查 / 配置加载验证
- tmux TPM 未装时友好提示

### Fixed
- ZSH_AUTOSUGGEST_STRATEGY/HIGHLIGHT_STYLE 配置位置错位（之前在 plugin source 之后，配置实际不生效）
- LANG/LC_ALL 强制覆盖系统 locale 改为 fallback 模式
- tmux status-interval 1s → 5s（CPU 唤醒过频）

### Removed
- 废弃文件 .chezmoidata.yaml（早期遗留，现使用 .chezmoidata/tools.yaml 目录）

## [0.4.0] - 2026-05-01

### Added
- 工具清单数据化（.chezmoidata/tools.yaml 集中管理）
- vim 跨平台最小配置（dot_vimrc.tmpl）
- GitHub Actions CI（跨平台 chezmoi 模板渲染校验）
- zoxide 集成（智能 cd）
- fzf shell 集成（Ctrl+R / Ctrl+T / Alt+C 快捷键）
- PowerShell PSFzf 模块支持
- gitconfig 现代化：zdiff3、rerere、autosquash、autoStash、prune、autoSetupRemote
- chezmoiignore 默认忽略 .ssh / .gnupg

### Changed
- Linux 安装脚本重构：提取 install_pkg / install_deb_from_release 函数（393 → 270 行）
- macOS 安装脚本：brew list 一次拉到 set，避免每包重复 grep
- Windows 安装报告：去除 ASCII 框（中文宽度对不齐），改竖向列表
- PowerShell PATH 注入：从 profile 每次循环改为安装脚本一次性写入用户 PATH
- compinit 改用 24h 缓存检查（启动加速 ~50%）
- git user 交互改为 promptStringOnce + promptChoiceOnce 菜单模式

### Fixed
- git user 交互失效（首次 init 写入占位符后，后续 init 永远跳过菜单）
- yazi v25.x 兼容性（[mgr]/[pick] 段名 + create_title 数组化 + previewers url 字段）
- Windows fix_windows_style.ps1 的 Set-Content 编码（改用 .NET API 写 UTF-8 无 BOM）
- Linux 安装脚本 apt 索引未更新导致后续安装 404
- Nerd Font 解压污染 ~/.local/share/fonts 根目录（改解压到 Meslo/ 子目录）
- tmux terminal-overrides 通配（覆盖 tmux-256color 和 xterm-256color）

## [0.3.0] - 2026-04-15

### Added
- PowerShell Profile 同步（处理 Documents 重定向）

### Fixed
- Scoop safe.directory 和路径检测
- 跨平台安装脚本可靠性问题
- Windows 平台兼容性

## [0.2.0] - 2026-04-14

### Changed
- 项目全面优化和问题修复

## [0.1.0] - 2026-02-05

### Added
- 项目首版：跨平台 dotfiles（macOS/Linux/Windows）
- chezmoi 模板化配置：zsh / bash / PowerShell / tmux / git / starship / yazi / ghostty
