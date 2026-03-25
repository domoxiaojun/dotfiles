$ErrorActionPreference = 'Stop'

Write-Host "Starting Windows terminal diagnostics..." -ForegroundColor Cyan

# ================================
# 1. Check Nerd Font
# ================================
Write-Host "`n---------- 1. Font Check ----------"
$FontTarget = "MesloLGS NF"
$FontInstalled = $false

$FontsReg = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' -ErrorAction SilentlyContinue
foreach ($font in $FontsReg.PSObject.Properties) {
    if ($font.Name -like "*$FontTarget*") { $FontInstalled = $true; break }
}

if (-not $FontInstalled) {
    if (Test-Path "$env:LOCALAPPDATA\Microsoft\Windows\Fonts\*Meslo*NF*") { $FontInstalled = $true }
}

if ($FontInstalled) {
    Write-Host "[OK] Font installed: $FontTarget" -ForegroundColor Green
}
else {
    Write-Host "[WARN] Font not found: $FontTarget" -ForegroundColor Yellow
    Write-Host "   Attempting to fix via Scoop..." -ForegroundColor DarkGray
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        scoop bucket add nerd-fonts 2>$null
        scoop install Meslo-NF-Mono 2>$null
        Write-Host "   Install command executed. Please restart terminal to confirm." -ForegroundColor Cyan
    }
    else {
        Write-Host "   [ERROR] Scoop not installed, cannot auto-fix font." -ForegroundColor Red
    }
}

# ================================
# 2. Check Windows Terminal Config
# ================================
Write-Host "`n---------- 2. Windows Terminal Config ----------"
$WT_Path = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_*\LocalState\settings.json"
$WT_Settings = Get-ChildItem $WT_Path | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($WT_Settings) {
    Write-Host "[OK] Config found: $($WT_Settings.Name)" -ForegroundColor Green
    try {
        $JsonContent = Get-Content $WT_Settings.FullName -Raw
        $Json = $JsonContent | ConvertFrom-Json

        $CurrentDefaultFont = $null
        if ($Json.profiles.defaults.font) { $CurrentDefaultFont = $Json.profiles.defaults.font.face }
        elseif ($Json.profiles.defaults.face) { $CurrentDefaultFont = $Json.profiles.defaults.face }

        if ($CurrentDefaultFont -like "*Meslo*NF*") {
            Write-Host "[OK] Default font configured: $CurrentDefaultFont" -ForegroundColor Green
        }
        else {
            Write-Host "[WARN] Default font is not Nerd Font (current: $CurrentDefaultFont)" -ForegroundColor Yellow

            # Auto-fix defaults
            if (-not $Json.profiles.defaults.font) {
                $Json.profiles.defaults | Add-Member -NotePropertyName "font" -NotePropertyValue @{ "face" = "MesloLGS NF" } -Force
            }
            else {
                $Json.profiles.defaults.font | Add-Member -NotePropertyName "face" -NotePropertyValue "MesloLGS NF" -Force
            }
            $NewJson = $Json | ConvertTo-Json -Depth 10
            Set-Content $WT_Settings.FullName -Value $NewJson
            Write-Host "[FIXED] Default font set to MesloLGS NF" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "[ERROR] Failed to parse/modify config: $_" -ForegroundColor Red
    }
}
else {
    Write-Host "[WARN] settings.json not found. Windows Terminal may not be installed." -ForegroundColor Yellow
}

# ================================
# 3. Check PowerShell Profile
# ================================
Write-Host "`n---------- 3. Profile Check ----------"
if (Test-Path $PROFILE) {
    Write-Host "[OK] Profile exists: $PROFILE" -ForegroundColor Green
    $Content = Get-Content $PROFILE -Raw
    if ($Content -match "starship init") {
        Write-Host "[OK] Starship init found in profile" -ForegroundColor Green
    }
    else {
        Write-Host "[WARN] Starship init not found in profile" -ForegroundColor Yellow
    }
}
else {
    Write-Host "[ERROR] Profile not found: $PROFILE" -ForegroundColor Red
    Write-Host "   Attempting to restore from dotfiles..." -ForegroundColor Cyan
    $RepoProfile = Join-Path (Split-Path -Parent $PSScriptRoot) "Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
    $SourceProfile = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
    $ProfileCandidates = @($RepoProfile, $SourceProfile) | Select-Object -Unique

    $RestoreProfile = $ProfileCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

    if ($RestoreProfile) {
        New-Item -ItemType Directory -Force -Path (Split-Path $PROFILE) | Out-Null
        Copy-Item $RestoreProfile $PROFILE -Force
        Write-Host "[FIXED] Profile restored from: $RestoreProfile" -ForegroundColor Green
    }
    else {
        Write-Host "[ERROR] Cannot find source profile. Run chezmoi apply first." -ForegroundColor Red
    }
}

# ================================
# 4. Summary
# ================================
Write-Host "`n---------- Summary ----------"
Write-Host "[OK] Diagnostics complete! Restart Windows Terminal if fixes were applied." -ForegroundColor Cyan
Write-Host ""
