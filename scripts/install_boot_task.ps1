# 注册「WorkBuddy 开机补签」Windows 计划任务（触发器：用户登录 AtLogOn）。
# 用途：替代原来固定的 09:05 定时自动化，改为电脑开机/登录、WorkBuddy 启动后自动签到。
# 重跑本脚本可安全覆盖（Register-ScheduledTask -Force）。
$ErrorActionPreference = "Stop"

$taskName = "WorkBuddy签到-开机补签"
$ps1      = Join-Path $env:USERPROFILE ".workbuddy\scripts\boot_checkin.ps1"

$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument ("-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File " + $ps1)
$trigger = New-ScheduledTaskTrigger -AtLogOn

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Force | Out-Null
Write-Host ("已注册/更新计划任务: " + $taskName + " (触发器: 登录时)")
