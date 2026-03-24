#!/usr/bin/env pwsh
# Windows 依赖安装脚本
# 此脚本在 Windows 上通过 chezmoi apply 自动运行
# version: 1.0.0

$ErrorActionPreference = 'Stop'
try {

    Write-Host "🚀 开始安装 Windows 终端工具..." -ForegroundColor Cyan

    # 检查并安装 Scoop
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue) -and -not (Test-Path "$env:USERPROFILE\scoop")) {
        Write-Host "⚠️  未检测到 Scoop 包管理器" -ForegroundColor Yellow
        Write-Host "   Scoop 是 Windows 下优秀的包管理工具，用于安装终端工具" -ForegroundColor Gray
        $installScoop = Read-Host "是否安装 Scoop? (Y/n)"
        if ($installScoop -eq '' -or $installScoop -match '^[Yy]$') {
            Write-Host "📦 安装 Scoop..." -ForegroundColor Yellow
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
        }
        else {
            Write-Host "⏭️  跳过 Scoop 安装，部分工具将无法安装" -ForegroundColor Yellow
            Write-Host "   后续可手动安装: irm get.scoop.sh | iex" -ForegroundColor Gray
            exit 0
        }
    }
    else {
        Write-Host "✅ Scoop 已安装" -ForegroundColor Green
    }

    # 确保 Scoop 在当前会话可用
    $env:PATH = "$env:USERPROFILE\scoop\shims;$env:PATH"

    # 添加 extras bucket（某些工具需要）
    scoop bucket add extras 2>$null

    # 安装核心工具
    Write-Host "📦 安装终端工具..." -ForegroundColor Yellow
    $tools = @("starship", "lsd", "bat", "delta", "btop", "glow", "fzf", "yazi")
    foreach ($tool in $tools) {
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
            Write-Host "  安装 $tool..." -ForegroundColor Gray
            scoop install $tool
        }
        else {
            Write-Host "  ✅ $tool 已安装" -ForegroundColor Green
        }
    }

    # 安装 Nerd Font
    Write-Host "🔤 安装 Nerd Font..." -ForegroundColor Yellow
    scoop bucket add nerd-fonts 2>$null
    scoop install Meslo-NF-Mono 2>$null

    Write-Host ""
    Write-Host "✅ 所有依赖安装完成！" -ForegroundColor Green

    # 自动同步 Profile（解决 Documents 路径可能被重定向的问题）
    $SourceProfile = Join-Path (Split-Path -Parent $PSScriptRoot) "Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
    if (Test-Path $SourceProfile) {
        Write-Host "🔄 同步 Profile 到 $PROFILE ..." -ForegroundColor Cyan
        New-Item -ItemType Directory -Force -Path (Split-Path $PROFILE) | Out-Null
        Copy-Item $SourceProfile $PROFILE -Force
    }

    Write-Host ""
    Write-Host "📝 后续步骤：" -ForegroundColor Cyan
    Write-Host "  1. 重启 PowerShell"
    Write-Host "  2. 在 Windows Terminal 设置中选择 'MesloLGS NF' 字体"
    Write-Host "  3. 享受你的新终端环境！"

    exit 0

}
catch {
    Write-Host "⚠️ 安装过程中出现非致命错误: $_" -ForegroundColor Yellow
    exit 0
}
