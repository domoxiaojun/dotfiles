# =========================
# PowerShell Profile - Domo's Dotfiles
# 由 chezmoi 管理，功能对标 .zshrc
# =========================


# =========================
# Locale / Encoding
# =========================
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


# =========================
# PSReadLine (自动补全和语法高亮)
# =========================
if (Get-Module -ListAvailable -Name PSReadLine) {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
}


# =========================
# Starship Prompt
# =========================
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}


# =========================
# 别名 - 终端美化工具（24-bit 真彩色）
# =========================

# lsd - 彩色 ls（带图标和文件类型）
if (Get-Command lsd -ErrorAction SilentlyContinue) {
    Remove-Alias -Name ls -ErrorAction SilentlyContinue
    function ls { lsd @args }
    function ll { lsd -l @args }
    function la { lsd -la @args }
    function lt { lsd --tree @args }
}

# bat - 彩色 cat（语法高亮）
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Alias -Name cat -ErrorAction SilentlyContinue
    # --paging=never: 不使用分页器，直接输出（像 cat 一样）
    function cat { bat --style=plain --paging=never @args }
    function catt { bat --paging=never @args }  # 带行号和 git 状态，无分页
    function batp { bat @args }  # 需要分页时用这个
}

# glow - Markdown 渲染
if (Get-Command glow -ErrorAction SilentlyContinue) {
    function md { glow @args }
}

# btop - 系统监控（替代 top/htop）
if (Get-Command btop -ErrorAction SilentlyContinue) {
    function top { btop @args }
}


# =========================
# PATH 扩展
# =========================
$CustomBinPath = "$env:USERPROFILE\.antigravity\antigravity\bin"
if (Test-Path $CustomBinPath) {
    $env:PATH = "$CustomBinPath;$env:PATH"
}
