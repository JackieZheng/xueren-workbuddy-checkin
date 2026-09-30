@echo off
REM WorkBuddy boot check-in launcher (runs at logon)
REM Waits for WorkBuddy client, then runs boot-catchup (idempotent).
powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%USERPROFILE%\.workbuddy\scripts\boot_checkin.ps1"
