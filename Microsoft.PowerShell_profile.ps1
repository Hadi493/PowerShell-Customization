# PowerShell Profile Configuration

# Set colors
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "Cyan"

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Add Flutter to PATH if directory exists
$flutterPath = "$HOME\Downloads\flutter_linux_3.27.1-stable\flutter\flutter\bin"
if (Test-Path $flutterPath) {
    $env:Path += ";$flutterPath"
}

# Set window title
$Host.UI.RawUI.WindowTitle = "PowerShell Terminal"

# Aliases
Set-Alias ll Get-ChildItem
Set-Alias la Get-ChildItem
Set-Alias ls Get-ChildItem
Set-Alias cat Get-Content
Set-Alias grep Select-String
Set-Alias pwd Get-Location
Set-Alias clear Clear-Host

# Custom prompt function
function prompt {
    $lastSuccess = $?
    $locationPath = (Get-Location).Path
    $username = $env:USERNAME.ToLower()
    $hostname = $env:COMPUTERNAME.ToLower()
    $homePath = $env:USERPROFILE
    
    # Format the path with ~ for home directory and compact directories
    if ($locationPath.StartsWith($homePath)) {
        $displayPath = "~" + $locationPath.Substring($homePath.Length)
    } else {
        $displayPath = $locationPath
    }
    
    # Compact the path if it's not just the home directory
    if ($displayPath -ne "~" -and $displayPath.Contains("\")) {
        $parts = $displayPath -split '\\'
        # Keep drive letter or ~ at beginning
        $compactPath = $parts[0]
        # For middle directories, use first letter only
        for ($i = 1; $i -lt $parts.Length - 1; $i++) {
            if ($parts[$i]) {
                $compactPath += "\" + $parts[$i][0]
            }
        }
        # Keep the full name of the current directory
        if ($parts.Length -gt 1) {
            $compactPath += "\" + $parts[-1]
        }
        $displayPath = $compactPath
    }
    
    # First line
    Write-Host "┌──(" -NoNewline -ForegroundColor Cyan
    Write-Host $username -NoNewline -ForegroundColor Green
    if ($isAdmin) {
        Write-Host "[ADMIN]" -NoNewline -ForegroundColor Green
    }
    Write-Host "(🚀)" -NoNewline -ForegroundColor Cyan
    Write-Host "windows" -NoNewline -ForegroundColor Green
    Write-Host ")-[" -NoNewline -ForegroundColor Cyan
    Write-Host $displayPath -NoNewline -ForegroundColor Yellow
    Write-Host "]" -NoNewline -ForegroundColor Cyan
    
    # Git branch
    try {
        $gitBranch = git rev-parse --abbrev-ref HEAD 2>$null
        if ($gitBranch) {
            Write-Host " " -NoNewline -ForegroundColor Cyan; Write-Host "🐙" -NoNewline -ForegroundColor Magenta; Write-Host "(" -NoNewline -ForegroundColor Cyan
            Write-Host $gitBranch -NoNewline -ForegroundColor Red
            Write-Host ")" -NoNewline -ForegroundColor Cyan
        }
    } catch {}

    # Second line with status indicator
    Write-Host
    Write-Host "└─" -NoNewline -ForegroundColor Cyan
    if ($lastSuccess) {
        Write-Host "$" -NoNewline -ForegroundColor Green
    } else {
        Write-Host "x" -NoNewline -ForegroundColor Red
    }
    " "
}

# Start SSH agent if not running
$sshAgent = Get-Process ssh-agent -ErrorAction SilentlyContinue
if (-not $sshAgent) {
    Start-Service ssh-agent
    ssh-add
}

# Register cleanup on exit
Register-EngineEvent PowerShell.Exiting -Action {
    Get-Process ssh-agent -ErrorAction SilentlyContinue | Stop-Process
} | Out-Null

Clear-Host


