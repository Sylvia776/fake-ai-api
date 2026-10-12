param([int]$Port = 3000)
$ErrorActionPreference = 'Stop'
$pidFile = Join-Path $PSScriptRoot '.local-server.pid'
$serverFile = Join-Path $PSScriptRoot 'server.js'
if (Test-Path -LiteralPath $pidFile) {
    $serverProcessId = [int](Get-Content -LiteralPath $pidFile)
    $existing = Get-CimInstance Win32_Process -Filter "ProcessId = $serverProcessId"
    if ($existing -and $existing.Name -eq 'node.exe' -and $existing.CommandLine.Contains($serverFile)) {
        Write-Host "Service is already running (PID $serverProcessId)."
        exit 0
    }
}
$listeners = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().GetActiveTcpListeners()
if ($listeners | Where-Object { $_.Port -eq $Port }) {
    throw "Port $Port is already in use. Choose another port with -Port."
}
$nodePath = (Get-Command node.exe).Source
$previousPort = $env:PORT
try {
    $env:PORT = [string]$Port
    $serviceProcess = Start-Process -FilePath $nodePath -ArgumentList @('"' + $serverFile + '"') -WorkingDirectory $PSScriptRoot -WindowStyle Hidden -RedirectStandardOutput (Join-Path $PSScriptRoot 'server.log') -RedirectStandardError (Join-Path $PSScriptRoot 'server-error.log') -PassThru
    Set-Content -LiteralPath $pidFile -Value $serviceProcess.Id -Encoding ascii
} finally {
    $env:PORT = $previousPort
}
for ($attempt = 0; $attempt -lt 20; $attempt++) {
    Start-Sleep -Milliseconds 250
    if ($serviceProcess.HasExited) {
        throw 'Service failed to start. See server-error.log.'
    }
    try {
        $health = Invoke-RestMethod -Uri "http://localhost:$Port/health" -TimeoutSec 2
        if ($health.status -ne 'ok') { throw 'Unexpected health response.' }
        Write-Host "Service started: http://localhost:$Port (PID $($serviceProcess.Id))"
        exit 0
    } catch {
        if ($attempt -eq 19) { throw 'Service did not become ready. See server.log and server-error.log.' }
    }
}
