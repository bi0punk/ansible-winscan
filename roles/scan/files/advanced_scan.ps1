Write-Output "### Escaneo de amenazas avanzadas (Metasploit, shells, persistencia) ###"

# == 1. Procesos en rutas sospechosas ==
Write-Output "`n== Procesos ejecutándose desde rutas inusuales =="
Get-Process | ForEach-Object {
    try {
        if ($_.Path -match "temp|Users\\Public|AppData\\Roaming|\\Tasks") {
            Write-Output "⚠️ Proceso sospechoso: $($_.ProcessName) en $($_.Path)"
        }
    } catch {}
}

# == 2. Puertos en escucha desde procesos inusuales ==
Write-Output "`n== Puertos abiertos por procesos potencialmente maliciosos =="
$procesos_criticos = @("cmd", "powershell", "wscript", "cscript", "svchost", "explorer", "regsvr32", "rundll32")
Get-NetTCPConnection | Where-Object { $_.State -eq "Listen" } | ForEach-Object {
    try {
        $proc = Get-Process -Id $_.OwningProcess -ErrorAction Stop
        if ($procesos_criticos -contains $proc.ProcessName.ToLower()) {
            Write-Output "⚠️ $($proc.ProcessName) escuchando en $($_.LocalAddress):$($_.LocalPort)"
        }
    } catch {}
}

# == 3. Conexiones establecidas a IPs externas ==
Write-Output "`n== Conexiones salientes activas =="
Get-NetTCPConnection | Where-Object {
    $_.RemoteAddress -ne '127.0.0.1' -and $_.RemoteAddress -notmatch '^192\.168\.|^10\.|^172\.(1[6-9]|2[0-9]|3[01])\.' -and $_.State -eq "Established"
} | ForEach-Object {
    $proc = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
    Write-Output "⚠️ Conexión externa: $($_.RemoteAddress):$($_.RemotePort) ← $($proc.ProcessName)"
}

# == 4. Persistencia vía claves Run/RunOnce ==
Write-Output "`n== Claves de inicio sospechosas (registro) =="
$run_keys = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
)
foreach ($rk in $run_keys) {
    if (Test-Path $rk) {
        Get-ItemProperty -Path $rk | ForEach-Object {
            $_.PSObject.Properties | ForEach-Object {
                if ($_.Value -match "temp|Users\\Public|\.bat|\.vbs|\.dll|\.ps1") {
                    Write-Output "⚠️ Persistencia sospechosa en $rk → $($_.Name): $($_.Value)"
                }
            }
        }
    }
}

# == 5. Tareas programadas fuera del path Microsoft ==
Write-Output "`n== Tareas programadas no estándar =="
Get-ScheduledTask | Where-Object { $_.TaskPath -notlike '\Microsoft*' } | ForEach-Object {
    try {
        $info = Get-ScheduledTaskInfo -TaskName $_.TaskName -TaskPath $_.TaskPath
        Write-Output "⚠️ Tarea no estándar: $($_.TaskName) – Último run: $($info.LastRunTime)"
    } catch {}
}

# == 6. Historial PowerShell sospechoso (si aplica) ==
Write-Output "`n== Comandos recientes de PowerShell =="
$histFile = "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt"
if (Test-Path $histFile) {
    Get-Content $histFile | Where-Object {
        $_ -match "Invoke|IEX|Base64|DownloadString|Add-MpPreference|Set-MpPreference"
    } | ForEach-Object {
        Write-Output "⚠️ Historial sospechoso: $_"
    }
}

# == 7. Archivos nuevos en carpetas típicas de drop (últimos 3 días) ==
Write-Output "`n== Archivos sospechosos recientes =="
$dirs = @("C:\Users\*\AppData\Local\Temp", "C:\Users\Public", "C:\Windows\Tasks", "C:\Windows\Temp")
foreach ($dir in $dirs) {
    try {
        Get-ChildItem $dir -Recurse -Force -ErrorAction SilentlyContinue | Where-Object {
            $_.LastWriteTime -gt (Get-Date).AddDays(-3) -and $_.Length -gt 0
        } | ForEach-Object {
            if ($_.Name -match "\.bat|\.ps1|\.dll|\.vbs|\.exe") {
                Write-Output "⚠️ Archivo reciente: $($_.FullName) – Fecha: $($_.LastWriteTime)"
            }
        }
    } catch {}
}
