Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public class Win32Focus {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
}
'@

Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes

# Parse tab index from protocol URL: claudefocus://2
$tabIndex = 0
if ($args.Count -gt 0) {
    $url = $args[0] -replace 'claudefocus://', '' -replace '/$', ''
    if ($url -match '^\d+$') { $tabIndex = [int]$url }
}

$wt = Get-Process WindowsTerminal -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
if ($wt) {
    $hwnd = $wt.MainWindowHandle
    if ([Win32Focus]::IsIconic($hwnd)) {
        [Win32Focus]::ShowWindow($hwnd, 9)
    }
    [Win32Focus]::SetForegroundWindow($hwnd)

    # Use UI Automation to select the correct tab
    Start-Sleep -Milliseconds 150
    $element = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)
    $tabCondition = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
        [System.Windows.Automation.ControlType]::TabItem
    )
    $tabs = $element.FindAll([System.Windows.Automation.TreeScope]::Descendants, $tabCondition)

    if ($tabIndex -lt $tabs.Count) {
        $targetTab = $tabs[$tabIndex]
        $pattern = $targetTab.GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern)
        $pattern.Select()
    }
}
