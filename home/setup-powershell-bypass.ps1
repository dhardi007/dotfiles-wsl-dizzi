# setup-powershell-fixed.ps1
Write-Host "Setting up PowerShell for dotfiles..." -ForegroundColor Blue

function Set-Policy {
    param($shell)
    
    $command = @"
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force -ErrorAction SilentlyContinue
    Write-Host "'$shell' → \$(Get-ExecutionPolicy)" -ForegroundColor Green
"@
    
    try {
        & $shell -Command $command
    } catch {
        Write-Host "'$shell' → Failed: $_" -ForegroundColor Red
    }
}

# Configura ambos PowerShells
Set-Policy -shell "pwsh"
Set-Policy -shell "powershell"

Write-Host "`n✅ Done! PowerShell is ready for dotfiles." -ForegroundColor Green
