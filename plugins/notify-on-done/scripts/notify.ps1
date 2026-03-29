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

$binding = New-BTBinding -Children (New-BTText -Text $project), (New-BTText -Text $msg)
$visual = New-BTVisual -BindingGeneric $binding
$audio = New-BTAudio -Source 'ms-winsoundevent:Notification.IM'
$content = New-BTContent -Visual $visual -Audio $audio
Submit-BTNotification -Content $content -UniqueIdentifier 'claude-code'
