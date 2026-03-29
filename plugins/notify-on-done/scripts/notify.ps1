$json = $input | Out-String
$project = Split-Path -Leaf (Get-Location)

# Save debug dump
$json | Out-File -FilePath "$env:USERPROFILE\.claude\stop-hook-debug.json" -Force

# Parse JSON for context
$title = "Claude Code - $project"
$body = "Ready"

try {
    $data = $json | ConvertFrom-Json
    if ($data.stop_hook_active_task_subject) {
        $body = $data.stop_hook_active_task_subject
    }
    if ($data.transcript_summary) {
        $body = $data.transcript_summary
    }
} catch {}

New-BurntToastNotification -Text $title, $body -Sound 'IM' -UniqueIdentifier 'claude-code'
