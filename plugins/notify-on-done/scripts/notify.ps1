$raw = $input | Out-String
$project = Split-Path -Leaf (Get-Location)

try {
    # Fix encoding: stdin may arrive as UTF-16LE with null bytes
    $clean = $raw -replace "`0", ""
    $data = $clean | ConvertFrom-Json

    # Use last assistant message, truncated to fit notification
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
