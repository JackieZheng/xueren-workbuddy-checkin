# WorkBuddy 旅行奖励自动领取启动器
# 由 Windows 计划任务（触发器：每 10 分钟重复）调用，无窗口静默运行。
# 作用： Buddy 旅行归来（arrived）立即领取积分；空闲且未达每日上限则再次派出。
#       仅在真正产生动作（领到奖励/成功派出）时由 Python 侧弹系统通知，此处不弹窗。
# 日志分工：Python 每次运行写 checkin.log（一行摘要）；本脚本只记录异常退出，
#           便于区分「计划任务有没有在跑」与「跑了之后发生了什么」。

$ErrorActionPreference = "SilentlyContinue"

# 通用路径：WorkBuddy 用户数据固定位于 %USERPROFILE%\.workbuddy，不再写死用户名
$wbRoot = Join-Path $env:USERPROFILE ".workbuddy"
# 优先用技能目录的最新脚本；技能被卸载时才回退到本目录部署副本
$script = Join-Path $wbRoot "skills\xueren-workbuddy-checkin\scripts\workbuddy_checkin.py"
if (-not (Test-Path $script)) { $script = Join-Path $wbRoot "scripts\workbuddy_checkin.py" }
$log    = Join-Path $wbRoot "scripts\travel_watch.log"

# 5.6.2+ 加密登录态：与开机补签保持一致，显式开启跨进程读取运行中客户端密钥
$env:WORKBUDDY_ENABLE_ATREST_MEMSCAN = "1"

# Python 解析：与开机补签同一套候选顺序（系统 Python → 托管版本目录 → PATH）
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

if (-not (Test-Path $script)) {
    Add-Content -Path $log -Value ((Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " | 主脚本缺失: $script")
    exit 1
}

# 执行旅行闭环；捕获输出供异常时排查（stdout 为 JSON，不含 token）
$out = & $python $script travel-watch 2>&1
$code = $LASTEXITCODE

# 仅异常退出或输出里出现真实动作时记录，避免日志被高频轮询刷满
$text = ($out | Out-String)
if ($code -ne 0 -or $text -match "已领取|已派出") {
    $head = ($text -split "`n" | Where-Object { $_.Trim() } | Select-Object -First 3) -join " / "
    Add-Content -Path $log -Value ((Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " | exit=$code | " + $head)
}
exit $code
