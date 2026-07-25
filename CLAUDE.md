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

## 架构

### 数据流:tools.yaml 是唯一工具清单源

```
.chezmoidata/tools.yaml  (字段: cmd/brew/apt/apt_cmd/dnf/scoop/bucket/special)
   ├→ .chezmoi.yaml.tmpl        init 时 lookPath 检测,生成 .tools.<cmd> 布尔值(目前无模板消费)
   └→ .chezmoiscripts/run_onchange_{darwin,windows}_install-packages.*
                                 遍历清单安装(chezmoi apply 时内容变化才执行)
```

添加新工具:改 tools.yaml 后 darwin(`brew` 字段)/windows(`scoop` 字段)安装脚本自动遍历;**Linux 安装脚本是手写的,`apt`/`dnf`/`bucket` 字段目前无消费者,新工具需同步手改 linux 脚本**。Ubuntu 命令名不同的工具用 `apt_cmd` 字段(如 bat→batcat、fd→fdfind)。`.chezmoi.yaml.tmpl` 在 init 阶段 `.chezmoidata` 尚未加载,所以它用 `include ".chezmoidata/tools.yaml" | fromYaml` 直接读文件——修改时保持这个模式。

### chezmoi 关键机制

- 命名映射:`dot_zshrc.tmpl` → `~/.zshrc`,`private_dot_config/` → `~/.config/`,`.tmpl` 后缀 = Go 模板。
- `.chezmoitemplates/` 存放跨 shell 共享片段(`shell-tools-init`、`shell-aliases`),由 `dot_zshrc.tmpl` 和 `dot_bash_aliases.tmpl` 通过 `{{ template "shell-tools-init" . }}` 引用——bash/zsh 共用逻辑改这里,不要在两边重复。
- `.chezmoiignore` 按平台条件忽略(Windows 跳过 Unix 配置、Linux 默认跳过 zshrc、非 Windows 跳过 Documents/)。**任何仅仓库内有意义的文件(README、CLAUDE.md、scripts/ 等)必须加入 .chezmoiignore,否则 chezmoi apply 会把它部署到 $HOME**。
- 模板内条件渲染实际使用的是 `.chezmoi.os`(darwin/linux/windows)和 `.git.*`;chezmoi.yaml 里生成的 `.system.*`/`.tools.*` 目前没有任何模板消费。
- git 用户信息在 `chezmoi init` 时通过 `promptChoiceOnce/promptStringOnce` 交互获取并缓存在 chezmoi state;重置:`chezmoi state delete-bucket --bucket=entryState` 后删掉 `~/.config/chezmoi/chezmoi.yaml` 再 init。

### 跨平台约定

- 换行符由 `.gitattributes` 强制:全仓库 LF,仅 `*.ps1/*.psm1/*.psd1/*.bat/*.cmd` 用 CRLF。PowerShell 相关改动不要破坏这一点。
- 缩进(.editorconfig):默认 2 空格;sh/ps1 用 4 空格。
- 安装脚本头部有 `version:` 注释和修改记录,实质性改动时递增并补一行说明。
- tmux prefix 是 `Ctrl+s`(非默认 Ctrl+b),shell 配置里有对应的 `stty -ixon` 配合,相关改动需保持一致。
