Set WshShell = CreateObject("WScript.Shell")
url = WScript.Arguments(0)
scriptDir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
WshShell.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & scriptDir & "\focus-terminal.ps1"" """ & url & """", 0, False
