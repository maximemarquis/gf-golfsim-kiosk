param(
  [string]$ProcessName = "GolfzonVision2.exe",
  [int]$GraceSeconds = 30
)

$base = [System.IO.Path]::GetFileNameWithoutExtension($ProcessName)

# Get all matching processes
$procs = Get-Process -Name $base -ErrorAction SilentlyContinue
if (-not $procs) {
  Write-Output "NOT_RUNNING"
  exit 0
}

Write-Output "RUNNING"

# 1) Try graceful close
$didRequestClose = $false
foreach ($p in $procs) {
  try {
    if ($p.MainWindowHandle -ne 0) {
      $null = $p.CloseMainWindow()
      $didRequestClose = $true
    }
  } catch {
    # ignore
  }
}

if ($didRequestClose) {
  Write-Output "GRACEFUL_CLOSE_REQUESTED"
} else {
  Write-Output "NO_MAIN_WINDOW (cannot close gracefully)"
}

# 2) Wait up to GraceSeconds for it to exit
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

while ($stopwatch.Elapsed.TotalSeconds -lt $GraceSeconds) {
  Start-Sleep -Milliseconds 500
  $still = Get-Process -Name $base -ErrorAction SilentlyContinue
  if (-not $still) {
    Write-Output "CLOSED_GRACEFULLY"
    exit 0
  }
}

Write-Output "STILL_RUNNING_AFTER_GRACE"

# 3) Force kill if still running
Start-Process -FilePath "taskkill.exe" -ArgumentList "/IM `"$ProcessName`" /T /F" -WindowStyle Hidden

Start-Sleep -Milliseconds 500
$stillAfterKill = Get-Process -Name $base -ErrorAction SilentlyContinue

if (-not $stillAfterKill) {
  Write-Output "KILLED"
  exit 0
}

Write-Output "KILL_FAILED"
exit 1
