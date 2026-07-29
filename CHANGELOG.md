# Changelog

本项目采用 [Keep a Changelog](https://keepachangelog.com/) 格式记录变更。

## [Unreleased]

### Added
- `.chezmoitemplates/bash-config` 共享模板：bash 配置主体抽出，同时部署到 `~/.bash_aliases`（Debian/Ubuntu 默认 bashrc 加载）与 `~/.bashrc.d/10-dotfiles.sh`（Fedora/RHEL 默认 bashrc 加载），带 `__DOTFILES_BASH_LOADED` 双重加载防护
- Windows 安装脚本嵌入 PowerShell profile 的 sha256（profile 内容变更时 run_onchange 重跑，重新同步 Documents 重定向位置）
- CI 增加仓库内非模板 `.ps1`（Documents/、scripts/）的 PowerShell 解析检查
- starship 补回 `$cmd_duration` 模块（自定义 format 会关闭默认模块），命令超 2s 显示耗时
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

### Changed
- Linux 安装脚本改为遍历 `.chezmoidata/tools.yaml`（`apt`/`dnf`/`apt_cmd` 字段首次真正生效，与 darwin/windows 一致）；yaml 变更即触发脚本重跑；`install_pkg` 增加 alt_command 参数与 `-` 空值哨兵
- `install_deb_from_release` 版本号改经 `releases/latest` 的 302 重定向获取，避开 GitHub API 匿名限流（60 次/小时）
- gitconfig 的 delta 检测改为模板内 `lookPath`：配置数据只在 init 时渲染并冻结，文件模板每次 apply 重新求值，首装装完 delta 后再 apply 一次即自愈
- `.chezmoi.yaml.tmpl` 精简为仅保留模板真正消费的 `git.user`，移除死数据（`tools.*` / `system.*` / `shell.starship.enabled` / `git.delta.*` / 顶层 name+email）；Windows interpreters 加 `-NoProfile -NonInteractive`
- CI shellcheck 由 `|| true` 改为阻断式（跳过跨平台渲染出的空文件）
- tools.yaml 中 gh 的 `apt` 字段置空：Ubuntu 统一走 cli/cli 官方源（universe 版本偏旧）
- zshrc 复用 `.zprofile` 导出的 `HOMEBREW_PREFIX`，避免每次启动派生 brew 子进程
- 安装脚本第三方脚本的安全提示改为直述校验方法（原 `DOTFILES_VERIFY` 提示与实现不符）

### Fixed
- Fedora/RHEL 上 bash 配置完全不生效：其默认 `~/.bashrc` 不加载 `~/.bash_aliases`，改为同时部署 `~/.bashrc.d/10-dotfiles.sh`
- tmux-resurrect 默认保存键 `prefix + Ctrl-s` 与 `bind C-s send-prefix` 冲突（TPM 在配置末尾运行，插件绑定覆盖了前面的 bind），保存键改为 `prefix + S`
- compinit 走全量检查分支后 `touch` dump 文件：dump 内容未变时 compinit 不重写文件，导致超过 24h 后每次启动都走慢路径
- shell-tools-init 中 `__DOTFILES_SHELL=sh` 未加引号被 shellcheck 判为 SC2209
- tmux `status-left-length` / `status-right-length` 重复设置清理
- gitconfig `wip` alias 注释与实际行为不符
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
