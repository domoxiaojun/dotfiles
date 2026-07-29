# 优化修复任务清单(2026-07-25)

## 一、正确性
- [x] 1. Fedora bash 配置不生效:抽共享模板 bash-config,新增 ~/.bashrc.d/10-dotfiles.sh 部署路径 + 双重加载防护
- [x] 2. tmux resurrect 保存键与 send-prefix 冲突:@resurrect-save 改为 'S',同步注释与 README
- [x] 3. gitconfig delta 检测改为模板内 lookPath(首装第二次 apply 自愈)
- [x] 4. Windows 安装脚本嵌入 profile 内容 hash,profile 变更触发重定向位置重新同步
- [x] 5. CI shellcheck 去掉 `|| true` 改为阻断(跳过空渲染产物);补仓库内非模板 .ps1 的解析检查

## 二、架构一致性
- [x] 6. Linux 安装脚本消费 tools.yaml(apt/dnf/apt_cmd 字段生效;yaml 变更触发脚本重跑);gh 的 apt 字段改 ""(走官方源)
- [x] 7. .chezmoi.yaml.tmpl 死数据清理(tools/system/shell/顶层 name+email/git.delta),interpreters 加 -NoProfile
- [x] 8. .chezmoiignore 补 todos.md / .claude/ / .bashrc.d(非 Linux)

## 三、小优化
- [x] 9. zshrc 复用 HOMEBREW_PREFIX,免每次启动派生 brew 子进程
- [x] 10. compinit 全量分支后 touch dump
- [x] 11. install_deb_from_release 改用 releases/latest 302 重定向取版本(免 GitHub API 限流)
- [x] 12. 安装脚本 DOTFILES_VERIFY 提示与实现不符,改为直述校验方法(darwin/linux)
- [x] 13. tmux status-left/right-length 重复设置清理
- [x] 14. gitconfig wip alias 注释修正
- [x] 15. starship 补 $cmd_duration

## 收尾
- [x] 渲染验证(chezmoi execute-template + bash -n / zsh -n / shellcheck / toml / git config 解析)
  - 12 个模板渲染 exit=0;shellcheck 阻断模式全通过(过程中发现并修掉 SC2209)
  - tmux 配置在独立 socket 实测:prefix=C-s、@resurrect-save=S、status-*-length=100
  - gitconfig lookPath 实测渲染出 delta 段(旧写法因冻结数据永远不会生效)
  - windows 脚本内嵌 hash 与 shasum -a 256 逐字节一致
- [x] README / CHANGELOG / CLAUDE.md 同步更新
- [x] 分组提交
