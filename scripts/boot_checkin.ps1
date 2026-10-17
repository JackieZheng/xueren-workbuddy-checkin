# WorkBuddy 开机补签启动器
# 由 Windows 计划任务（触发器：AtLogOn，当前用户）在登录时调用。
# 作用：等待 WorkBuddy 客户端启动（5.6.2+ 加密登录态默认通过环境变量/密钥文件/DPAPI 落盘密钥/明文兜底定位密钥；
#       如需从运行中客户端取密钥，须显式开启 WORKBUDDY_ENABLE_ATREST_MEMSCAN=1，默认关闭），
#       随后执行签到 + 派猫猫旅行闭环。等待超时后即便 WB 未起也会尝试（走环境变量/DPAPI/密钥文件兜底）。

$ErrorActionPreference = "SilentlyContinue"

# 通用路径：WorkBuddy 用户数据固定位于 %USERPROFILE%\.workbuddy，不再写死用户名
$wbRoot = Join-Path $env:USERPROFILE ".workbuddy"
$script = Join-Path $wbRoot "scripts\workbuddy_checkin.py"
$log    = Join-Path $wbRoot "scripts\boot_checkin.log"

# 5.6.2+ 加密登录态：解密密钥默认走 环境变量/密钥文件/DPAPI 落盘密钥/明文兜底。
# 开机时若前几级都无密钥且客户端已启动登录，则显式开启跨进程读取运行中客户端密钥（同机同 Windows 用户，幂等安全）。
$env:WORKBUDDY_ENABLE_ATREST_MEMSCAN = "1"

# Python 解析：开机时不在 WorkBuddy 会话内，托管 embedded Python（仅内置运行时会注入 stdlib）往往缺 Lib 而启动即失败，
# 故逐个候选实测 import 能力，优先可用者：系统 Python → 托管版本目录 → PATH 上的 python。
function Test-Python($exe) {
    if (-not (Test-Path $exe)) { return $false }
    try { & $exe -c "import sys,urllib.request,json,sqlite3" *> $null; return ($LASTEXITCODE -eq 0) }
    catch { return $false }
}
$candidates = @(
    "D:\Python\Python312\python.exe",
    (Get-ChildItem (Join-Path $wbRoot "binaries\python\versions\*\python.exe") -ErrorAction SilentlyContinue | Sort-Object -Descending | Select-Object -First 1 | ForEach-Object { $_.FullName })
) | Where-Object { $_ }
$candidates += @("python")
$python = "python"
foreach ($c in $candidates) { if (Test-Python $c) { $python = $c; break } }

# 仅追加时间戳头，避免日志无限膨胀（保留最近几次）
Add-Content -Path $log -Value ("`n===== boot_checkin @ " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " =====")
Add-Content -Path $log -Value ("Python 解释器: $python")

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

# 持续轮询 WorkBuddy 是否就绪：每 30s 轮询一次，就绪即尝试补签（幂等，成功即停），最长 30 分钟。
# 关键：WB 未起时只轮询、不空跑（密钥可能仅驻留运行中客户端内存，空跑既无效又可能触发限流）；
# 客户端无论何时启动（如 06:28 才起）都能在 30 分钟窗口内被轮询命中并补签成功。全部失败则静默退出。
$pollInterval = 30
$maxWaitSec   = 1800
$deadline     = (Get-Date).AddSeconds($maxWaitSec)
$attempts     = 0
$success      = $false
Add-Content -Path $log -Value ("开始持续轮询补签：间隔 ${pollInterval}s，最长 ${maxWaitSec}s，上限 → $(Get-Date -Date $deadline -Format 'HH:mm:ss')")

while ($true) {
    $attempts++
    $now = Get-Date
    $wbUp = [bool](Get-Process -Name "WorkBuddy" -ErrorAction SilentlyContinue)
    Add-Content -Path $log -Value ("轮询 #$attempts @ " + $now.ToString("HH:mm:ss") + "  WorkBuddy 进程:" + ($wbUp ? "已就绪" : "未启动"))
    # WB 未起时只轮询不空跑（密钥可能仅驻留运行中客户端内存，空跑既无效又可能触发限流）；
    # 就绪后再补签；即便此时拿不到密钥，脚本自身有 密钥文件/DPAPI/环境变量 多级兜底。签到幂等，成功即停。
    if ($wbUp) {
        & $python $script boot-catchup *>> $log
        $exitCode = $LASTEXITCODE
        if ($exitCode -eq 0) {
            $success = $true
            Add-Content -Path $log -Value ("补签成功（尝试 #$attempts，exit=0），停止轮询")
            break
        }
    }
    if ($now -ge $deadline) {
        Add-Content -Path $log -Value ("已到轮询上限（$(($maxWaitSec)/60) 分钟内未成功，共轮询 $attempts 次），停止并静默退出")
        break
    }
    Start-Sleep -Seconds $pollInterval
}
