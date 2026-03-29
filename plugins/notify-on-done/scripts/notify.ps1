# Read stdin with explicit UTF-8 encoding (bypasses PowerShell's default encoding)
$reader = New-Object System.IO.StreamReader([Console]::OpenStandardInput(), [System.Text.Encoding]::UTF8)
$raw = $reader.ReadToEnd()
$reader.Close()

$project = Split-Path -Leaf (Get-Location)

try {
    $data = $raw | ConvertFrom-Json

    $msg = $data.last_assistant_message
    if ($msg) {
        # Strip markdown formatting
        $msg = $msg -replace '`[^`]*`', '' -replace '\*\*([^*]*)\*\*', '$1' -replace '\*([^*]*)\*', '$1'
        $msg = $msg.Trim()
        if ($msg.Length -gt 120) {
            $msg = $msg.Substring(0, 117) + "..."
        }
    }
    if (-not $msg) { $msg = "Ready" }
} catch {
    $msg = "Ready"
}

# Auto-register claudefocus:// protocol handler if missing
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$launcherPath = Join-Path $scriptDir "focus-launcher.vbs"
$regPath = 'HKCU:\Software\Classes\claudefocus'
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
    Set-ItemProperty -Path $regPath -Name '(Default)' -Value 'URL:Claude Focus Protocol'
    Set-ItemProperty -Path $regPath -Name 'URL Protocol' -Value ''
    New-Item -Path "$regPath\shell\open\command" -Force | Out-Null
    Set-ItemProperty -Path "$regPath\shell\open\command" -Name '(Default)' -Value "wscript.exe `"$launcherPath`" `"%1`""
}

# Find which WT tab we're in by walking up the PID chain
$tabIndex = 0
try {
    $wtProc = Get-Process WindowsTerminal -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($wtProc) {
        $wtPid = $wtProc.Id
        $p = Get-CimInstance Win32_Process -Filter "ProcessId = $PID"
        $shellPid = $null
        while ($p -and $p.ProcessId -ne $wtPid) {
            if ($p.ParentProcessId -eq $wtPid) { $shellPid = $p.ProcessId; break }
            $p = Get-CimInstance Win32_Process -Filter "ProcessId = $($p.ParentProcessId)" -ErrorAction SilentlyContinue
        }
        if ($shellPid) {
            $shells = Get-CimInstance Win32_Process | Where-Object {
                $_.ParentProcessId -eq $wtPid -and $_.Name -match '(pwsh|powershell|bash|cmd|zsh|fish|nu)\.exe'
            } | Sort-Object CreationDate
            for ($i = 0; $i -lt $shells.Count; $i++) {
                if ($shells[$i].ProcessId -eq $shellPid) { $tabIndex = $i; break }
            }
        }
    }
} catch {}

$binding = New-BTBinding -Children (New-BTText -Text $project), (New-BTText -Text $msg)
$visual = New-BTVisual -BindingGeneric $binding
$audio = New-BTAudio -Source 'ms-winsoundevent:Notification.IM'
$content = New-BTContent -Visual $visual -Audio $audio -Launch "claudefocus://$tabIndex" -ActivationType Protocol
Submit-BTNotification -Content $content -UniqueIdentifier 'claude-code'
