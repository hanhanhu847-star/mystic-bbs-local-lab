# Read-only listener check. No connections, writes, firewall changes or process starts.
[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [ValidateRange(1,65535)]
    [int[]]$Port = @(2323,2324,24554,24555)
)
$uniquePorts = @($Port | Sort-Object -Unique)
$all = @(Get-NetTCPConnection -State Listen -ErrorAction Stop)
foreach ($p in $uniquePorts) {
    $listeners = @($all | Where-Object LocalPort -eq $p)
    $outside = @($listeners | Where-Object { $_.LocalAddress -notlike '127.*' -and $_.LocalAddress -ne '::1' })
    $status = if (!$listeners) { 'NotListening' } elseif ($outside) { 'NonLoopback' } else { 'LoopbackOnly' }
    [pscustomobject]@{ Port=$p; Status=$status; Address=($listeners.LocalAddress -join ', '); PID=($listeners.OwningProcess -join ', ') }
}
