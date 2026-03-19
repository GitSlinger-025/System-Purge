<#
.SYNOPSIS
    System Purge v1.1 
    Author: GitSlinger-025 | NextSeed Lab
    Features: Auto-Admin, Debloat, Privacy, DNS Opt, Ultimate Power, Hardware Stats.
#>

# --- LAYER -1: ADMIN AUTO-ELEVATE ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

function Show-Loader($Message) {
    Write-Host -NoNewline "`n[*] $Message " -ForegroundColor Yellow
    $chars = "|","/","-","\"
    for ($i=0; $i -lt 4; $i++) {
        foreach ($c in $chars) {
            Write-Host -NoNewline "`r[*] $Message $c" -ForegroundColor Yellow
            Start-Sleep -Milliseconds 40
        }
    }
    Write-Host "`r[+] $Message [DONE]" -ForegroundColor Green
}

function Get-HardwareStats {
    $os = Get-CimInstance Win32_OperatingSystem
    # RAM conversion to GB (Free and Total)
    $freeRam = [Math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $totalRam = [Math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $cpu = (Get-CimInstance Win32_Processor).LoadPercentage
    Write-Host "`n================ SYSTEM HEALTH ================" -ForegroundColor Cyan
    Write-Host " RAM Usage: $($totalRam - $freeRam) GB used of $totalRam GB" -ForegroundColor White
    Write-Host " CPU Load: $cpu%" -ForegroundColor White
    Write-Host "===============================================" -ForegroundColor Cyan
}

# --- MAIN ENGINE LOOP ---
do {
    Clear-Host
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host "   >>>     SYSTEM PURGE v6.1 (TERMINATOR)     <<<    " -ForegroundColor White -BackgroundColor DarkRed
    Write-Host "   NextSeed Lab | Pure Performance Mode              " -ForegroundColor Yellow
    Write-Host "   GitHub: github.com/GitSlinger-025                 " -ForegroundColor Gray
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host " COMMANDS: 'debloat' | 'privacy' | 'boost' | 'clean' " -ForegroundColor White
    Write-Host " NEW:      'dns' (Google) | 'power' (Ultimate Mode)  " -ForegroundColor Green
    Write-Host "           'stats' | 'exit'                          " -ForegroundColor Gray
    Write-Host "-----------------------------------------------------" -ForegroundColor DarkCyan

    $cmd = (Read-Host "`n[?] System Command").ToLower().Trim()
    
    if ($cmd -eq "exit") { break }

    switch ($cmd) {
        "debloat" {
            Show-Loader "Purging Windows Bloatware..."
            $apps = @("ZuneVideo","ZuneMusic","SkypeApp","YourPhone","BingNews","MicrosoftSolitaireCollection","MixedReality.Portal","FeedbackHub")
            foreach($app in $apps) { Get-AppxPackage -AllUsers "*$app*" | Remove-AppxPackage -ErrorAction SilentlyContinue }
            Write-Host "[+] System is now Bloat-Free!" -ForegroundColor Green
        }
        "privacy" {
            Show-Loader "Blocking Microsoft Spyware (Telemetry)..."
            $services = @("DiagTrack", "dmwappushservice", "WerSvc")
            foreach($svc in $services) {
                Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
                Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
            }
            Write-Host "[+] Privacy Shield Active!" -ForegroundColor Green
        }
        "dns" {
            Show-Loader "Optimizing Network DNS (Universal)..."
            $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
            foreach ($adapter in $adapters) {
                Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses ("8.8.8.8","8.8.4.4") -ErrorAction SilentlyContinue
            }
            ipconfig /flushdns | Out-Null
            Write-Host "[+] Google DNS Applied to all active adapters!" -ForegroundColor Green
        }
        "power" {
            Show-Loader "Unlocking Ultimate Performance Mode..."
            # Unlock the scheme and set it as active
            powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
            powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61
            Write-Host "[+] Ultimate Power Plan Activated!" -ForegroundColor Green
        }
        "boost" {
            Show-Loader "Stripping Visual Lag..."
            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value 0
            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0
            Write-Host "[+] GUI Lag Removed! (Restart for full effect)" -ForegroundColor Green
        }
        "clean" {
            Show-Loader "Deep Cleaning Trash (Temp, Prefetch, Logs)..."
            $paths = @("$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*")
            foreach($p in $paths) { Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue }
            Clear-RecycleBin -Force -ErrorAction SilentlyContinue
            Write-Host "[+] System Trash Vanished!" -ForegroundColor Green
        }
        "stats" { Get-HardwareStats }
        default {
            if ($cmd -ne "") {
                Show-Loader "Targeting $cmd..."
                # Process Kill
                Get-Process | Where-Object { $_.Name -like "*$cmd*" } | Stop-Process -Force -ErrorAction SilentlyContinue
                # Appx Remove
                Get-AppxPackage -AllUsers "*$cmd*" | Remove-AppxPackage -ErrorAction SilentlyContinue
                # Winget Remove
                winget uninstall --name $cmd --silent --accept-source-agreements > $null 2>&1
                Write-Host " >> $cmd: DESTROYED!" -ForegroundColor Red
            }
        }
    }
    Read-Host "`n[?] Task Complete. Press Enter to return to menu..."
} while ($true)

Write-Host "`n[*] System Purged. Power level critical! Shutdown..." -ForegroundColor Magenta
Start-Sleep -Seconds 2

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

