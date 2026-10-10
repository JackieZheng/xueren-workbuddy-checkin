# WorkBuddy 开机补签启动器
# 由 Windows 计划任务（触发器：AtLogOn，当前用户）在登录时调用。
# 作用：等待 WorkBuddy 客户端启动（5.6.2+ 加密登录态默认通过环境变量/密钥文件/DPAPI 落盘密钥/明文兜底定位密钥；
#       如需从运行中客户端取密钥，须显式开启 WORKBUDDY_ENABLE_ATREST_MEMSCAN=1，默认关闭），
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

# 右下角气泡：无窗口启动后让用户知道自动签到已在后台运行（失败静默，不影响签到）
function Show-Balloon($title, $msg) {
    try {
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
        $ni = New-Object System.Windows.Forms.NotifyIcon
        $ni.Icon    = [System.Drawing.SystemIcons]::Information
        $ni.Visible = $true
        $ni.ShowBalloonTip(5000, $title, $msg, [System.Windows.Forms.ToolTipIcon]::Info)
        Start-Sleep -Seconds 6
        $ni.Dispose()
    } catch { }
}
Show-Balloon "WorkBuddy 自动签到" "已在后台静默启动，正在等待客户端就绪…"

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
