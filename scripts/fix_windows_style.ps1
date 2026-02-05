$ErrorActionPreference = 'Stop'

Write-Host "🚑 开始 Windows 终端环境诊断与修复..." -ForegroundColor Cyan

# ================================
# 1. 检查 Nerd Font
# ================================
Write-Host "`n---------- 1. 字体检查 ----------"
$FontTarget = "MesloLGS NF"
$FontInstalled = $false

# 简单检查注册表或字体文件夹
$FontsReg = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' -ErrorAction SilentlyContinue
foreach ($font in $FontsReg.PSObject.Properties) {
    if ($font.Name -like "*$FontTarget*") { $FontInstalled = $true; break }
}

if (-not $FontInstalled) {
    # 尝试在 User 目录查找
    if (Test-Path "$env:LOCALAPPDATA\Microsoft\Windows\Fonts\*Meslo*NF*") { $FontInstalled = $true }
}

if ($FontInstalled) {
    Write-Host "✅ 字体已安装: $FontTarget" -ForegroundColor Green
}
else {
    Write-Host "⚠️ 未检测到 $FontTarget 字体" -ForegroundColor Yellow
    Write-Host "   正在尝试通过 Scoop 修复..." -ForegroundColor DarkGray
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        scoop bucket add nerd-fonts 2>$null
        scoop install Meslo-NF-Mono 2>$null
        Write-Host "   已执行安装命令，请重启终端后确认。" -ForegroundColor Cyan
    }
    else {
        Write-Host "   ❌ Scoop 未安装，无法自动修复字体。" -ForegroundColor Red
    }
}

# ================================
# 2. 检查 Windows Terminal 配置
# ================================
Write-Host "`n---------- 2. Windows Terminal 配置 ----------"
$WT_Path = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_*\LocalState\settings.json"
$WT_Settings = Get-ChildItem $WT_Path | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($WT_Settings) {
    Write-Host "✅ 找到配置文件: $($WT_Settings.Name)" -ForegroundColor Green
    try {
        $JsonContent = Get-Content $WT_Settings.FullName -Raw
        $Json = $JsonContent | ConvertFrom-Json
        
        # 检查这三个位置：defaults, list[PowerShell], list[Windows PowerShell]
        $CurrentDefaultFont = $null
        if ($Json.profiles.defaults.font) { $CurrentDefaultFont = $Json.profiles.defaults.font.face }
        elseif ($Json.profiles.defaults.face) { $CurrentDefaultFont = $Json.profiles.defaults.face } # 旧版配置
        
        if ($CurrentDefaultFont -like "*Meslo*NF*") {
            Write-Host "✅ [全局默认] 字体已正确配置: $CurrentDefaultFont" -ForegroundColor Green
        }
        else {
            Write-Host "⚠️ [全局默认] 字体未配置为 Nerd Font (当前: $CurrentDefaultFont)" -ForegroundColor Yellow
             
            # 询问是否修复
            Write-Error "Windows Terminal 字体配置不正确，这可能导致乱码。" -ErrorAction Continue
            # 自动修复 defaults
            if (-not $Json.profiles.defaults.font) { 
                $Json.profiles.defaults | Add-Member -NotePropertyName "font" -NotePropertyValue @{ "face" = "MesloLGS NF" } -Force
            }
            else {
                $Json.profiles.defaults.font | Add-Member -NotePropertyName "face" -NotePropertyValue "MesloLGS NF" -Force
            }
            $NewJson = $Json | ConvertTo-Json -Depth 10
            Set-Content $WT_Settings.FullName -Value $NewJson
            Write-Host "🔧 已自动修复全局默认字体配置为 MesloLGS NF" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "❌ 解析/修改配置文件失败: $_" -ForegroundColor Red
    }
}
else {
    Write-Host "⚠️ 未找到 settings.json，可能是未安装 Windows Terminal 或版本过旧。" -ForegroundColor Yellow
}

# ================================
# 3. 检查 PowerShell Profile
# ================================
Write-Host "`n---------- 3. 环境配置 (Profile) ----------"
if (Test-Path $PROFILE) {
    Write-Host "✅ Profile 文件存在: $PROFILE" -ForegroundColor Green
    # 检查是否包含 Starship
    $Content = Get-Content $PROFILE -Raw
    if ($Content -match "starship init") {
        Write-Host "✅ Starship 初始化代码已包含" -ForegroundColor Green
    }
    else {
        Write-Host "⚠️ Profile 中未找到 Starship 初始化代码" -ForegroundColor Yellow
    }
}
else {
    Write-Host "❌ Profile 文件不存在: $PROFILE" -ForegroundColor Red
    Write-Host "   尝试从 dotfiles 恢复..." -ForegroundColor Cyan
    $SourceProfile = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
    # 此时如果 Documents 被重定向，USERPROFILE 下的路径可能找不到，尝试找 dotfiles 仓库
    $DotfilesProfile = "d:\Antigravity\dotfiles\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" 
    
    if (Test-Path $DotfilesProfile) {
        New-Item -ItemType Directory -Force -Path (Split-Path $PROFILE) | Out-Null
        Copy-Item $DotfilesProfile $PROFILE -Force
        Write-Host "🔧 已从 dotfiles 仓库恢复 Profile" -ForegroundColor Green
    }
    else {
        Write-Host "❌ 无法找到源 Profile 文件，请运行 chezmoi apply" -ForegroundColor Red
    }
}

# ================================
# 4. 检查是否需要重启
# ================================
Write-Host "`n---------- 诊断总结 ----------"
Write-Host "✅ 检查完成！如果进行了修复，请 重启 Windows Terminal 即可生效。" -ForegroundColor Cyan
Write-Host ""
