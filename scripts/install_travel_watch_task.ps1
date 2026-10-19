# 注册「WorkBuddy签到-旅行自动领取」Windows 计划任务（触发器：每 10 分钟重复，持续不断）。
# 用途： Buddy 旅行归来后无需等待下一次签到，10 分钟内自动领取旅行积分；
#       空闲且未达每日派遣上限时也会自动再次派出，形成完整闭环。
# 依赖：travel_watch.ps1 / travel_watch.vbs 需先部署到 %USERPROFILE%\.workbuddy\scripts\。
# 重跑本脚本可安全覆盖（Register-ScheduledTask -Force）；停用/卸载命令见末尾输出。
# 注意：命令一律单行书写（本机 PowerShell 对反引号断行解析有异常），文件带 BOM 防中文乱码。
$ErrorActionPreference = "Stop"

$taskName = "WorkBuddy签到-旅行自动领取"
$vbs = Join-Path $env:USERPROFILE ".workbuddy\scripts\travel_watch.vbs"

$action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument ("//B """ + $vbs + """")
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 10)
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 5) -StartWhenAvailable -MultipleInstances IgnoreNew

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null
Write-Host ("已注册/更新计划任务: " + $taskName + " (触发器: 每 10 分钟)")
Write-Host "停用命令: Disable-ScheduledTask -TaskName '$taskName'"
Write-Host "卸载命令: Unregister-ScheduledTask -TaskName '$taskName' -Confirm:`$false"
