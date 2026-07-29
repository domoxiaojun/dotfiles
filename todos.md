# chezmoi 本地改动检测工具(2026-07-29)

## 背景
安装器(openclaw / grok / otty 等)会自行往 ~/.zshrc 追加内容,
chezmoi apply 会静默覆盖。本轮已把这类内容迁到 ~/.zshrc.local(不受管理),
但**新的**安装器仍会往 ~/.zshrc 追加,需要一个主动发现的手段。

## 已知的 chezmoi 原生能力(不重复造轮子)
- `chezmoi status` 第一列非空 = 该文件自上次 apply 后被本地改过
- `chezmoi apply` 遇到被改过的文件**会交互询问**(本轮实测触发了
  "has changed since chezmoi last wrote it?",因无 TTY 而中止)
- `chezmoi add` 反向收编 / `chezmoi merge` 三方合并 / `chezmoi cat` 打印目标状态
→ 工具的价值在**编排**它们 + 识别「安装器追加块」+ 一键搬到 .local

## 任务
- [x] 1. 脚本骨架:private_dot_local/bin/executable_chezmoi-check → ~/.local/bin/chezmoi-check
- [x] 2. 检测 A:遍历 chezmoi status,列出第一列非空的条目
- [x] 3. 检测 B:用 `diff <(chezmoi cat f) f` 取「本地多出来的行」,
       并按 >>>/<<</Added by/installer/Completion 等特征标注「像安装器追加」
- [x] 4. 检测 C:检查 ~/.zshrc.local 中 source 路径是否失效
       (修了一个 bug:BSD sed/grep 不支持 \s,导致路径解析出错误报)
- [x] 5. 交互处理:m 搬到 .zshrc.local / a 收编进仓库 / d 看 diff / s 跳过;
       非 TTY 自动降级为只报告
- [x] 6. 退出码:0=无差异,1=有差异待处理
- [x] 7. ~~挂 hooks.apply.pre~~ —— **决定不做**:脚本内部会调用 chezmoi apply 恢复文件,
       挂成 pre hook 会递归调用。需要自动化的话必须先加环境变量守卫,
       收益不抵复杂度,改为在 README 写明手动运行。

## 验收
- [x] 端到端回归:往真实 ~/.zshrc 追加假的 ">>> faketool installer >>>" 块,
      工具正确识别为安装器追加并列出 4 行;测后已还原(快照 /tmp/zshrc_pretest)
- [x] 隔离测试(临时 HOME + chezmoi 桩,不碰真实文件)4 项断言全通过:
      .zshrc 恢复为仓库版本 / 块已迁入 .zshrc.local / 新建文件带说明头 / 覆盖前有备份
- [x] shellcheck 通过(CI 同参数);bash -n 通过
- [x] 非 TTY 下不卡住,输出「非交互模式:只报告,不询问」
- [x] CI 增加对 private_dot_local/bin/ 的 shellcheck(此前只覆盖 *.sh.tmpl)
- [x] .chezmoiignore:Windows 忽略该脚本
- [x] README / CHANGELOG / CLAUDE.md 同步
- [x] 分组提交

## 遗留
- 安装脚本 `R .chezmoiscripts/darwin_install-packages.sh` 仍待运行
  (会联网 brew install,按用户规矩需明确确认后再跑)
- `chezmoi init` 未重跑:配置模板已精简,旧 ~/.config/chezmoi/chezmoi.yaml 里
  还残留 tools/system/delta 等死数据(无害,模板已不消费)
