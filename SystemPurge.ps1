<#
.SYNOPSIS
    System Purge v1.0
    Author: Srijan_XD
    GitHub: https://github.com/GitSlinger-025
    Description: Multi-layer Bloatware & App Removal Engine.
#>

function Show-Loader($Message) {
    Write-Host -NoNewline "`n[*] $Message " -ForegroundColor Yellow
    $chars = "/","-","\","|"
    for ($i=0; $i -lt 5; $i++) {
        foreach ($c in $chars) {
            Write-Host -NoNewline "`r[*] $Message $c" -ForegroundColor Yellow
            Start-Sleep -Milliseconds 40
        }
    }
    Write-Host "`r[+] $Message [DONE]" -ForegroundColor Green
}

$host.ui.RawUI.WindowTitle = "SYSTEM_PURGE_v1.0"

do {
    Clear-Host
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host "   >>>        SYSTEM PURGE v1.0 (PRO)       <<<      " -ForegroundColor White -BackgroundColor Cyan
    Write-Host "   Developed by: [Your Name/NextSeed Lab]           " -ForegroundColor Cyan
    Write-Host "   GitHub: github.com/[Your-Username]               " -ForegroundColor Yellow
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host " (Type 'exit' to close the engine)                   " -ForegroundColor Gray

    # 1. Take User Input
    $appName = Read-Host "`n[?] Enter target app name to PURGE"

    if ($appName -eq "exit" -or $appName -eq "EXIT") { break }
    
    if (-not $appName) {
        Write-Host "[!] Error: Target cannot be empty." -ForegroundColor Red
        Start-Sleep -Seconds 1
        continue
    }

    $target = "*$appName*"
    Write-Host "`n[~] INITIALIZING DEEP SCAN FOR: $appName" -ForegroundColor Yellow

    # Layer 1: Appx Packages
    Show-Loader "Purging Modern Packages..."
    $modernApps = Get-AppxPackage -AllUsers | Where-Object { $_.Name -like $target -or $_.PackageFullName -like $target }
    if ($modernApps) {
        foreach ($app in $modernApps) {
            Write-Host " >> FOUND: $($app.Name)" -ForegroundColor Cyan
            try {
                Remove-AppxPackage -Package $app.PackageFullName -ErrorAction Stop
                Write-Host " >> STATUS: VANISHED!" -ForegroundColor Green
            } catch {
                Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like $target } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
                Write-Host " >> STATUS: FORCE PURGED FROM SYSTEM!" -ForegroundColor Green
            }
        }
    }

    # Layer 2: Registry & Packages
    Show-Loader "Purging System Registry..."
    $legacyPackages = Get-Package -Name $target -ErrorAction SilentlyContinue | Where-Object { $_.ProviderName -ne "msi" }
    if ($legacyPackages) {
        foreach ($pkg in $legacyPackages) {
            Write-Host " >> FOUND: $($pkg.Name)" -ForegroundColor Cyan
            Uninstall-Package -InputObject $pkg -Force -ErrorAction SilentlyContinue
            Write-Host " >> STATUS: WIPED FROM REGISTRY!" -ForegroundColor Green
        }
    }

    # Layer 3: MSI Database
    Show-Loader "Purging MSI Database..."
    $msiApps = Get-CimInstance -ClassName Win32_Product -Filter "Name like '$target'" -ErrorAction SilentlyContinue
    if ($msiApps) {
        foreach ($msi in $msiApps) {
            Write-Host " >> FOUND MSI: $($msi.Name)" -ForegroundColor Cyan
            Invoke-CimMethod -InputObject $msi -MethodName Uninstall | Out-Null
            Write-Host " >> STATUS: DEEP CLEAN COMPLETE!" -ForegroundColor Green
        }
    }

    Write-Host "`n[+] Operation Finished for: $appName" -ForegroundColor White
    Write-Host "-----------------------------------------------------" -ForegroundColor Cyan
    
    $choice = Read-Host "Do you want to purge another app? (Y/N)"
    
} while ($choice -eq "y" -or $choice -eq "Y")

Write-Host "`n[*] System Purge Complete. Stay Optimized!" -ForegroundColor Magenta
Write-Host "    GitHub: github.com/[Your-Username]" -ForegroundColor Yellow
Start-Sleep -Seconds 3

