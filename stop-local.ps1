$ErrorActionPreference = 'Stop'
$pidFile = Join-Path $PSScriptRoot '.local-server.pid'
if (!(Test-Path -LiteralPath $pidFile)) {
    Write-Host 'No local service PID file found.'
    exit 0
}
$serverProcessId = [int](Get-Content -LiteralPath $pidFile)
$serviceProcess = Get-CimInstance Win32_Process -Filter "ProcessId = $serverProcessId"
$serverFile = Join-Path $PSScriptRoot 'server.js'
if ($serviceProcess) {
    if ($serviceProcess.Name -ne 'node.exe' -or !$serviceProcess.CommandLine.Contains($serverFile)) {
        throw 'PID belongs to another process. Refusing to stop it.'
    }
    Stop-Process -Id $serverProcessId
    Write-Host "Service stopped (PID $serverProcessId)."
} else {
    Write-Host 'Service is already stopped.'
}
Remove-Item -LiteralPath $pidFile
