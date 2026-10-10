' WorkBuddy boot check-in launcher (SILENT: window style 0 = fully hidden, no flash)
' Runs boot_checkin.ps1 invisibly in background; idempotent, no duplicate credit.
Dim sh, ps1
Set sh = CreateObject("Wscript.Shell")
ps1 = sh.ExpandEnvironmentStrings("%USERPROFILE%") & "\.workbuddy\scripts\boot_checkin.ps1"
sh.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & ps1 & """", 0, False
