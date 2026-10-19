' WorkBuddy travel-watch launcher (SILENT: window style 0 = fully hidden, no flash)
' Runs travel_watch.ps1 invisibly every 10 minutes via Task Scheduler; idempotent.
Dim sh, ps1
Set sh = CreateObject("Wscript.Shell")
ps1 = sh.ExpandEnvironmentStrings("%USERPROFILE%") & "\.workbuddy\scripts\travel_watch.ps1"
sh.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & ps1 & """", 0, False
