# WorkBuddy 开机补签启动器
# 由 Windows 计划任务（触发器：AtLogOn，当前用户）在登录时调用。
# 作用：等待 WorkBuddy 客户端启动（登录态 AtRest 信封解密可能需要运行中的进程内存密钥），
#       随后执行签到 + 派猫猫旅行闭环。等待超时后即便 WB 未起也会尝试（走环境变量/DPAPI/密钥文件兜底）。

$ErrorActionPreference = "SilentlyContinue"

# 通用路径：WorkBuddy 用户数据固定位于 %USERPROFILE%\.workbuddy，不再写死用户名
$wbRoot = Join-Path $env:USERPROFILE ".workbuddy"
# 托管 Python：动态匹配版本目录，避免硬编码 3.13.12 随 WorkBuddy 升级失效；缺失则回退系统 python
$pyHit  = Get-ChildItem (Join-Path $wbRoot "binaries\python\versions\*\python.exe") -ErrorAction SilentlyContinue | Sort-Object -Descending | Select-Object -First 1
$python = if ($pyHit) { $pyHit.FullName } else { "python" }
$script = Join-Path $wbRoot "scripts\workbuddy_checkin.py"
$log    = Join-Path $wbRoot "scripts\boot_checkin.log"

# 仅追加时间戳头，避免日志无限膨胀（保留最近几次）
Add-Content -Path $log -Value ("`n===== boot_checkin @ " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " =====")

# 最多等待 180 秒让 WorkBuddy 进程出现
$waited = 0
while ($waited -lt 180) {
    if (Get-Process -Name "WorkBuddy" -ErrorAction SilentlyContinue) { break }
    Start-Sleep -Seconds 5
    $waited += 5
}
Add-Content -Path $log -Value ("WorkBuddy 进程等待耗时(秒): $waited")

# 执行补签（无论是否等到 WB，都尝试；拿不到密钥则由脚本自身静默失败并记录日志）
& $python $script boot-catchup *>> $log
