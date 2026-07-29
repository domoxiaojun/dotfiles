# 使用体验优化任务清单(2026-07-29)

## 一、fzf 体验(高频交互)
- [x] 1. FZF_DEFAULT_OPTS:Catppuccin Mocha 配色,与整套主题统一
- [x] 2. Ctrl+T 文件预览(bat)/ Alt+C 目录预览(lsd --tree),含 Ubuntu 的 batcat 命令名兼容
- [x] 3. FZF_DEFAULT_COMMAND / CTRL_T_COMMAND 改用 fd(尊重 .gitignore,比 find 快);无 fd 时回退

## 二、主题统一(bat / delta / btop)
- [x] 4. bat 主题 —— **方案调整**:实测 bat 0.26 已内置 Catppuccin Mocha(0.25+ 起自带),
      原计划下载的 tmTheme 与 bat cache --build 脚本都是多余的,已删除。
      改为 config.tmpl 用 output 探测本机 bat 是否支持该主题再决定写不写 --theme,
      这样旧版 bat(Ubuntu 22.04=0.19 / 24.04=0.24)不会每次 cat 都打印 Unknown theme 警告。
- [x] 5. ~~bat cache --build 脚本~~ —— 随 4 一并取消(内置主题无需重建缓存,
      且缓存会在 bat 升级后失效反而制造故障)
- [x] 6. delta 显式指定 syntax-theme = "Catppuccin Mocha"(复用 bat 主题资源)
- [x] 7. btop:内置主题确实没有 Catppuccin,下载官方 theme 存入仓库;
      btop.conf 用 create_ 前缀(btop 退出会回写完整配置,不能持续覆盖)

## 三、shell 补全与历史
- [x] 8. zsh 补全 zstyle:大小写不敏感、菜单选择、LS_COLORS 上色、分组标题、补全缓存
      (实测发现本机 LS_COLORS 为空导致上色是死配置,补了兜底配色)
- [x] 9. zsh setopt:AUTO_CD / AUTO_PUSHD + alias d='dirs -v'
- [x] 10. bash 补 HISTTIMEFORMAT + shopt checkwinsize/globstar/autocd/cdspell

## 收尾
- [x] 渲染验证
  - 13 个模板渲染 exit=0;linux/windows 脚本去守卫后渲染 OK
  - zsh -n / bash -n 全通过;shellcheck 阻断模式 exit=0;starship.toml 解析通过
  - fzf:隔离 shell 中 source 后变量正确,fzf 接受 OPTS,bat/lsd/fd 预览命令实测可执行
  - zsh:隔离 ZDOTDIR 启动交互 shell,实测 autocd/autopushd/zstyle/alias d 均生效
  - bat:实测主题名 "Catppuccin Mocha" 在 bat --list-themes 中;delta 用该主题不报错
  - btop:主题文件静态校验(42 个 theme[] 键、必需键齐全、文件名与 color_theme 匹配)
  - chezmoi managed 确认 create_btop.conf → ~/.config/btop/btop.conf
- [x] README / CHANGELOG / CLAUDE.md 同步更新
- [x] 分组提交

## 本轮不做(用户已确认)
- git 全局 excludesfile(~/.gitignore_global)
- git 分目录身份 [includeIf "gitdir:~/work/"]
