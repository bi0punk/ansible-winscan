Write-Output "== Servicios en ejecución =="
Get-Service | Where-Object {$_.Status -eq 'Running'} | Select-Object Name, DisplayName, StartType

Write-Output "`n== Conexiones de red activas =="
Get-NetTCPConnection | Where-Object { $_.State -eq 'Established' -or $_.State -eq 'Listen' } |
  Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess

Write-Output "`n== Procesos asociados a puertos =="
$connections = Get-NetTCPConnection | Where-Object { $_.State -ne 'Closed' }

foreach ($conn in $connections) {
  $proc = Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue
  if ($proc) {
    Write-Output "PID: $($proc.Id), Nombre: $($proc.ProcessName), Puerto local: $($conn.LocalPort), Estado: $($conn.State)"
  }
}
