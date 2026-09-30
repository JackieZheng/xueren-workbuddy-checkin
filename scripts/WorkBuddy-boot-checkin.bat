@echo off
REM WorkBuddy 开机补签启动器（登录时自动运行）
REM 等待 WorkBuddy 客户端启动后执行签到 + 派猫猫旅行闭环；幂等，不重复加分。
powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%USERPROFILE%\.workbuddy\scripts\boot_checkin.ps1"
