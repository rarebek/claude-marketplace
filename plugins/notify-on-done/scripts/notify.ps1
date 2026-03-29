[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$raw = $input | Out-String
$project = Split-Path -Leaf (Get-Location)

try {
    $clean = $raw -replace "`0", ""
    $data = $clean | ConvertFrom-Json

    $msg = $data.last_assistant_message
    if ($msg) {
        # Strip markdown formatting and special chars
        $msg = $msg -replace '`[^`]*`', '' -replace '\*\*([^*]*)\*\*', '$1' -replace '\*([^*]*)\*', '$1'
        # Replace em/en dashes and other unicode punctuation with ASCII
        $msg = $msg -replace [char]0x2014, '-' -replace [char]0x2013, '-' -replace [char]0x2018, "'" -replace [char]0x2019, "'" -replace [char]0x201C, '"' -replace [char]0x201D, '"'
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
