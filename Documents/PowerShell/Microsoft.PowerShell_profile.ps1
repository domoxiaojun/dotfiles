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
# PSReadLine (自动补全和语法高亮，需要 2.3+ 才支持 ListView 预测)
# =========================
if (Get-Module -ListAvailable -Name PSReadLine) {
    try {
        Set-PSReadLineOption -PredictionSource History
        Set-PSReadLineOption -PredictionViewStyle ListView
        Set-PSReadLineOption -EditMode Windows
        Set-PSReadLineOption -HistorySearchCursorMovesToEnd
        Set-PSReadLineOption -MaximumHistoryCount 4096
        Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
        Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    } catch {
        # PSReadLine 版本过旧不支持某些选项，忽略错误
    }
}


# =========================
# PSFzf - fzf 集成（Ctrl+R 历史搜索 / Ctrl+T 文件搜索）
# =========================
if (Get-Module -ListAvailable PSFzf) {
    try {
        Import-Module PSFzf
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    } catch {
        # PSFzf 加载失败不影响其他功能
    }
}


# =========================
# Starship Prompt
# =========================
if (Get-Command starship -ErrorAction SilentlyContinue) {
    try {
        Invoke-Expression (&starship init powershell)
    } catch { }
}


# =========================
# zoxide（智能 cd，'z foo' 跳到含 foo 的常用目录）
# =========================
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    try {
        Invoke-Expression (& { (zoxide init powershell | Out-String) })
    } catch { }
}


# =========================
# EDITOR 智能选择（code -w > nvim > vim > notepad）
# =========================
if (-not $env:EDITOR) {
    if (Get-Command code -ErrorAction SilentlyContinue) {
        $env:EDITOR = 'code --wait'
    } elseif (Get-Command nvim -ErrorAction SilentlyContinue) {
        $env:EDITOR = 'nvim'
    } elseif (Get-Command vim -ErrorAction SilentlyContinue) {
        $env:EDITOR = 'vim'
    } else {
        $env:EDITOR = 'notepad'
    }
    $env:VISUAL = $env:EDITOR
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
    function cat { bat --style=plain --paging=never @args }
    function catt { bat --paging=never @args }
    function batp { bat @args }
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
# PATH 扩展（一次性追加，用户级 PATH 通过安装脚本永久注入）
# 这里只兜底处理：当前会话已有 USER PATH 未生效时的情况
# =========================
$ExtraPaths = @(
    "$env:USERPROFILE\bin",
    "$env:USERPROFILE\.local\bin"
)
$pathsToAdd = $ExtraPaths | Where-Object { (Test-Path $_) -and ($env:PATH -notlike "*$_*") }
if ($pathsToAdd) {
    $env:PATH = "$($pathsToAdd -join ';');$env:PATH"
}
