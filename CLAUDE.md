# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 仓库概述

chezmoi 管理的跨平台 dotfiles(macOS=zsh+brew / Linux=bash+dnf/apt / Windows=PowerShell+scoop)。全仓库使用中文注释、中文提交信息(conventional commits 前缀,如 `fix: CI Windows 把 scoop shims 加到 GITHUB_PATH`)。变更需同步更新 CHANGELOG.md(Keep a Changelog 格式,写入 Unreleased 段)。

## 常用命令

本仓库没有构建/单测,「测试」= 模板渲染 + 语法检查(与 CI test.yml 一致):

```bash
# 渲染普通模板(最常用的验证手段;需本机已有 ~/.config/chezmoi/chezmoi.yaml)
chezmoi execute-template --source . -f dot_zshrc.tmpl

# 渲染 .chezmoi.yaml.tmpl(必须用 --init 模式 + promptString 提供交互答案)
chezmoi execute-template --source . --init \
  --promptString "name=CI" --promptString "email=ci@example.com" \
  < .chezmoi.yaml.tmpl

# 语法检查渲染结果
bash -n <rendered.sh>
zsh -n <rendered_zshrc>
shellcheck -e SC1090,SC1091,SC2155,SC2034 -S warning <rendered.sh>
yamllint -d "{extends: relaxed, rules: {line-length: disable, document-start: disable}}" .chezmoidata/

# 查看差异 / 应用到本机
chezmoi diff
chezmoi apply -v
```

注意:`--init` 模式下 `.chezmoitemplates/` 不可用,所以只有 `.chezmoi.yaml.tmpl` 用 init 模式渲染,其余模板必须用普通模式;普通模式渲染依赖 chezmoi.yaml 提供 `.git.user.name` 等数据(CI 里是先 init 渲染再把结果拷到 `~/.config/chezmoi/chezmoi.yaml`)。

本地验证时**不要**把渲染出的 yaml 拷到 `~/.config/chezmoi/chezmoi.yaml`(会覆盖用户真实配置,其 `sourceDir` 可能指向别处),改为渲染到临时目录后用 `--config` 指定:

```bash
RD=$(mktemp -d)
chezmoi execute-template --source . --init --promptString "name=CI" --promptString "email=ci@example.com" \
  < .chezmoi.yaml.tmpl > "$RD/chezmoi.yaml"
chezmoi execute-template --config "$RD/chezmoi.yaml" --source . -f dot_zshrc.tmpl
```

另外,`.chezmoiscripts/run_onchange_{linux,windows}_*` 外层有 `{{ if eq .chezmoi.os "..." }}` 包裹,在 macOS 上渲染结果为空。要在本机检查它们,先去掉首尾两行守卫再渲染:`sed '1d;$d' <file> | chezmoi execute-template --config "$RD/chezmoi.yaml" --source .`。CI 的 shellcheck 是**阻断式**的(不再 `|| true`),只跳过空渲染产物。

## 架构

### 数据流:tools.yaml 是唯一工具清单源

```
.chezmoidata/tools.yaml  (字段: cmd/brew/apt/apt_cmd/dnf/scoop/bucket/special)
   └→ .chezmoiscripts/run_onchange_{darwin,linux,windows}_install-packages.*
                                 三个平台脚本都遍历清单安装
                                 (chezmoi apply 时脚本渲染结果变化才执行)
```

添加新工具:改 tools.yaml 即可——darwin 用 `brew` 字段、windows 用 `scoop`/`bucket`、linux 用 `apt`/`dnf` 字段;Ubuntu 命令名不同的用 `apt_cmd`(如 bat→batcat、fd→fdfind)。字段留空表示该平台跳过,由安装脚本里的「特殊安装」各节手工处理(如 Ubuntu 的 gh/delta/lsd/glow/ghostty 走官方源或 GitHub release)。Linux 脚本把清单渲染成 heredoc(`<cmd> <apt> <dnf> <apt_cmd>`,空值为 `-`)喂给 `install_pkg` 循环。

### chezmoi 关键机制

- 命名映射:`dot_zshrc.tmpl` → `~/.zshrc`,`private_dot_config/` → `~/.config/`,`.tmpl` 后缀 = Go 模板。
- **配置数据 vs 文件模板的求值时机**:`.chezmoi.yaml.tmpl` 只在 `chezmoi init` 时渲染一次并冻结,`dot_*.tmpl` 每次 `apply` 重新渲染。所以「本机是否装了某工具」这类会变化的检测必须写在文件模板里(如 gitconfig 用 `{{ if lookPath "delta" }}`),放进配置数据会永久冻结在首次 init 的状态。`.chezmoi.yaml.tmpl` 现在只产出 `git.user`(gitconfig 消费)+ Windows interpreters。
- `.chezmoitemplates/` 存放共享片段:`shell-tools-init`、`shell-aliases`(bash/zsh 共用),以及 `bash-config`(bash 配置主体)——共用逻辑改这里,不要在两边重复。
- **bash 双路径部署**:各发行版默认 `~/.bashrc` 加载的文件不同,所以 `bash-config` 同一份内容部署到两个目标——`~/.bash_aliases`(Debian/Ubuntu)和 `~/.bashrc.d/10-dotfiles.sh`(Fedora/RHEL);内部用 `__DOTFILES_BASH_LOADED` 防双重加载。改 bash 行为只改 `.chezmoitemplates/bash-config`。
- `.chezmoiignore` 按平台条件忽略(Windows 跳过 Unix 配置、Linux 默认跳过 zshrc/zprofile、非 Windows 跳过 Documents/、非 Linux 跳过 .bashrc.d/)。**任何仅仓库内有意义的文件(README、CLAUDE.md、todos.md、scripts/ 等)必须加入 .chezmoiignore,否则 chezmoi apply 会把它部署到 $HOME**。
- 模板内条件渲染使用 `.chezmoi.os`(darwin/linux/windows)、`.git.user.*` 和 `lookPath`。
- `run_onchange_` 脚本只在渲染结果变化时重跑。要让「别的文件变了也重跑」,在脚本里嵌入哈希注释,如 windows 脚本的 `# profile hash: {{ include "..." | sha256sum }}`;linux 脚本因为内联了 tools.yaml 内容,天然随 yaml 变化重跑。
- **`create_` 前缀**用于「首次创建后就不再覆盖」的文件,`private_dot_config/btop/create_btop.conf` → `~/.config/btop/btop.conf`。btop 退出时会把完整配置回写该文件,普通管理会让 `chezmoi diff` 永远有差异。
- 需要按本机工具**能力**(而不只是有没有装)分支时,用 `output` 在模板里探测,例:`private_dot_config/bat/config.tmpl` 用 `output $bat "--list-themes"` 判断该版本 bat 是否内置 Catppuccin 主题(bat ≥ 0.25 才有),旧版就不写 `--theme`,避免每次 `cat` 都打印警告。注意 `output` 的命令返回非零会中断整个 apply,只对稳定命令使用。
- git 用户信息在 `chezmoi init` 时通过 `promptChoiceOnce/promptStringOnce` 交互获取并缓存在 chezmoi state;重置:`chezmoi state delete-bucket --bucket=entryState` 后删掉 `~/.config/chezmoi/chezmoi.yaml` 再 init。

### 主题一致性

全套配色是 Catppuccin Mocha,分布在:ghostty(`theme =`)、tmux(catppuccin 插件)、fzf(`FZF_DEFAULT_OPTS` 里的 `--color`,在 `.chezmoitemplates/shell-tools-init`)、bat(`.config/bat/config`)、delta(gitconfig 的 `syntax-theme`,复用 bat 的主题资源)、btop(`.config/btop/themes/`,内置主题不含 Catppuccin 故随仓库部署)、starship。改配色需要同步这几处。

### 跨平台约定

- 换行符由 `.gitattributes` 强制:全仓库 LF,仅 `*.ps1/*.psm1/*.psd1/*.bat/*.cmd` 用 CRLF。PowerShell 相关改动不要破坏这一点。
- 缩进(.editorconfig):默认 2 空格;sh/ps1 用 4 空格。
- 安装脚本头部有 `version:` 注释和修改记录,实质性改动时递增并补一行说明。
- tmux prefix 是 `Ctrl+s`(非默认 Ctrl+b),shell 配置里有对应的 `stty -ixon` 配合,相关改动需保持一致。
