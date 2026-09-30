---
id: xueren-workbuddy-checkin
name: 雪人老师·WorkBuddy签到助手
title: 雪人老师·WorkBuddy签到助手
description: 读取本机已登录 WorkBuddy 的登录态，直接调用官方接口完成「Buddy 加油站」每日签到（无需点击 GUI），并支持派猫猫旅行（查状态 / 领旅行积分 / 派 Buddy 出门，默认随签到跑全自动闭环）+ 12 类多渠道消息推送 + 桌面通知。同时固化两项雪人定制：账户真实可用余额（取自 get-user-resource-summary，与客户端侧边栏一致）与开机补签（boot-catchup）。当用户说"每天自动签到 WorkBuddy / 每日签到 / 自动领 100 积分 / WorkBuddy 打卡 / 派猫猫旅行 / 查下当前积分情况 / 客户端被更新后签不了 / 5.6.2 签到失败 / 登录态加密了 / 积分 / 查询积分 / 剩余积分 / 我的积分 / 余额 / 当前余额"时触发。不适用于网页版（仅 PC 客户端专属，网页版无签到入口）。
slug: xueren-workbuddy-checkin
displayName: 雪人老师·WorkBuddy签到助手
summary: 读取本机已登录 WorkBuddy 的登录态，直接调用官方接口完成「Buddy 加油站」每日签到（无需点击 GUI），并支持派猫猫旅行（查状态 / 领旅行积分 / 派 Buddy 出门，默认随签到跑全自动闭环）+ 12 类多渠道消息推送 + 桌面通知。
description_en: xueren-workbuddy-checkin
version: 1.0.2
author: 雪人
license: MIT
allowed-tools: ""
display_name: xueren-workbuddy-checkin
display_name_zh: 雪人老师·WorkBuddy签到助手
trigger: ["每天自动签到 WorkBuddy", "每日签到", "自动领 Buddy 加油站积分", "WorkBuddy 打卡", "派猫猫旅行", "查下当前积分情况", "积分", "查询积分", "剩余积分", "我的积分", "余额", "当前余额", "签到通知", "5.6.2 签到失败", "登录态加密了"]
examples: "用户说「每天自动签到 WorkBuddy」→ 把 scripts/ 下脚本落位到 ~/.workbuddy/scripts/，建每日 09:00 主签到自动化，并布置开机补签触发器（将 boot_checkin.ps1 经启动文件夹 .bat 或计划任务 onlogon 在登录时触发）；用户说「查下当前积分情况」→ 跑 --check-only，返回本期活动累计积分与账户可用余额；用户说「派猫猫旅行」→ 跑 travel 子命令。"
platforms: [ima, WorkBuddy, QClaw]
github: https://github.com/JackieZheng/xueren-workbuddy-checkin
skillhub: https://skillhub.cn/skills/indiv-xueren/xueren-workbuddy-checkin
metadata:
  author: 雪人
  category: 自动化
---

# 雪人老师·WorkBuddy签到助手

## 概述

本技能是「WorkBuddy 每日自动签到」的**雪人定制封装版**，基于上游 totorosir-workbuddy-checkin v3.1.2 二次封装，仅在脚本层面固化了两项个性化修改，接口与行为主体与该上游一致。签到本质是一次带本机登录 Token 的 HTTP 请求，**不需要**模拟点击 GUI（自动化代理也没有点击桌面 UI 的能力）。

核心能力：
1. **接口直签**：读取本机 `workbuddy-desktop.info` 登录态，调用官方签到接口完成领取，无需打开 WorkBuddy。
2. **派猫猫旅行闭环**：查状态 / 领旅行积分 / 派 Buddy 出门全自动（先领后派），默认随签到执行。
3. **多渠道推送 + 桌面通知**：12 类渠道（钉钉/飞书/企业微信/微信/邮件/短信/QQ/Slack/Telegram/Bark/通用 Webhook/系统通知），可配置成功后也推送。
4. **雪人定制①**：展示**账户真实可用余额**（取自 `get-user-resource-summary`，与客户端侧边栏一致，带小数），并明确区分「本期活动累计积分」(`total_credits`，活动口径) 与「账户可用余额」(真实余额)，不再把活动累计误标为余额。
5. **雪人定制②**：**开机补签（boot-catchup）**——电脑开机/登录、WorkBuddy 启动后自动触发，确保「今天」完成签到闭环（幂等，服务端当天重复签到有保护，不会重复加分；本地今日已成功则跳过，避免同天多次弹窗/重派）。

脚本 `scripts/workbuddy_checkin.py` 仅用 Python 标准库，零第三方依赖；`scripts/push_message.py` 为推送模块（同目录被主脚本导入，也可独立调试）。

> 接口规范、登录态格式、字段与错误码、推送模块接口见 `@references/api-spec.md`。
> 自动化提示词、命令示例与推送配置示例见 `@references/examples.md`。
> 面向用户的完整说明（快速开始 / 桌面通知 / 消息推送配置 / 环境自检 / FAQ / 排错）见 `@references/user-guide.md`。

## 你的工作方式

1. **落位与校验** — 把 `scripts/` 下 `workbuddy_checkin.py` 与 `push_message.py` 一起复制到 `~/.workbuddy/scripts/`（两文件必须同目录），跑 `--check-only` 验证 token 有效、接口通；可顺带 `--diagnose` 看环境自检。
2. **建触发器** — 用 `automation_update` 建每天 09:00「每日自动签到」recurring 自动化（兜底：电脑全天不关机不重启时仍每日签到）；另建**开机补签触发器**：将 `scripts/boot_checkin.ps1`（等待 WorkBuddy 启动后执行 `boot-catchup`）经「启动文件夹 .bat」或「计划任务 onlogon」在用户登录时触发（替代原 09:05 定时自动化）。提示词见 `@references/examples.md`。
3. **汇报与交付** — 按脚本输出的 JSON 脱敏汇报（action / travel / balance / account_balance）；绝不回显 token 或推送凭据；如需手机推送，指导用户配置 `~/.workbuddy/scripts/notify_config.json`（模板见 `templates/notify_config.json.example`）。

## 执行流程

### Phase 1：准备阶段

- 定位登录态文件 `workbuddy-desktop.info`（通常在 `%LOCALAPPDATA%\CodeBuddyExtension\Data\Public\auth\`，旧版 `%APPDATA%` 同路径；v5.3.8+ 为明文 JSON，5.6.2+ 为 AtRestEncryption 信封）。确认 `auth.accessToken` 存在且未过期；不存在或失效 → 如实告知"请先在 WorkBuddy 客户端登录"，不伪造。
- 把本技能 `scripts/workbuddy_checkin.py` 与 `push_message.py` 复制到 `~/.workbuddy/scripts/`（同目录）。用 Python 3.10+ 跑：`python "%USERPROFILE%/.workbuddy/scripts/workbuddy_checkin.py" --check-only`（脚本仅用标准库，无第三方依赖）。

### Phase 2：核心执行

主脚本逻辑（无需打开 WorkBuddy GUI）：
1. 在 `LOCALAPPDATA` / `APPDATA` / `~/Library/Application Support` / `~/.config`（及 `~/.workbuddy/auth` 兜底）定位登录态，只读取出 `accessToken` 与 `domain`；加密态（5.6.2+）自动 AES-256-GCM 解密（密钥优先环境变量 `WORKBUDDY_ATREST_KEY` / `WORKBUDDY_ATREST_KEY_FILE`，其次进程内存扫描，失败回退明文兜底登录态）。
2. 调 `POST https://<domain>/v2/billing/meter/checkin-activity-status`：若 `today_checked_in` → `skip_already_signed` 退出；否则调 `POST https://<domain>/v2/billing/meter/daily-checkin` 领取（已签 `code:10001` 视为安全跳过，不重复发）。
3. **雪人定制①｜账户真实可用余额**：调 `POST https://<domain>/billing/meter/get-user-resource-summary`（注意**无 `/v2` 前缀**，且签名用登录态 `domain`，与签到同域）对 `data.Packages[].CycleRemainCapacity` 求和（保留 2 位小数）得真实余额；同时保留活动口径 `total_credits` 作"本期活动累计积分"。失败静默返回 None，绝不影响签到。
4. **派猫猫旅行**（默认随签到）：旅行接口域名为 `https://www.workbuddy.cn`、**无 `/v2` 前缀**——`GET /activity/growth/buddy/travel/status` → `arrived` 领积分 → `idle` 且未达 `daily_limit_reached` 才派；`traveling` 仅展示到达倒计时；不可用时静默降级。
5. 输出 JSON，全程不打印真实 token（仅脱敏 `eyJhbG...xxxx`）；退出码 成功 0 / 失败 1。

**雪人定制②｜开机补签（boot-catchup）**：
- 状态文件 `~/.workbuddy/scripts/checkin_status.json` 记录"今日是否已成功执行签到"（主 09:00 自动化与 boot-catchup 都会写入）。
- 子命令 `boot-catchup`：**不依赖固定时刻**，由系统层在「电脑开机/用户登录、WorkBuddy 启动后」触发。逻辑：若本地状态显示今日已成功 → 直接跳过（避免同天多次弹窗/重派）；否则跑一次完整签到闭环（签到 + 派猫猫旅行），服务端当天已签则 `skip_already_signed`（不重复加分），且仅在产生新动作时弹窗。
- 启动器 `scripts/boot_checkin.ps1` 会先等待 `WorkBuddy.exe` 进程出现（最多 180s，因 5.6.2+ 加密登录态的解密可能需要运行中的进程内存密钥），再执行 `boot-catchup`；超时未等到也仍尝试（走环境变量/DPAPI/密钥文件兜底）。
- 触发器布置二选一（都幂等，冗余无害）：① 用 PowerShell 跑一次 `scripts/install_boot_task.ps1` 注册「计划任务（AtLogOn）」；② 或把 `WorkBuddy-boot-checkin.bat`（调用上面的 ps1）放进「启动」文件夹（`%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\`）。推荐两者都做：计划任务更稳，启动文件夹作兜底。

### Phase 3：输出与交付

- **积分/余额类查询**（用户说"积分 / 查询积分 / 剩余积分 / 我的积分 / 余额 / 当前余额"等）→ 立即跑 `--check-only` 取实时数据，并**当场在会话窗口**汇报（本期活动累计积分 + 账户可用余额 + 连续签到天数 + 派猫猫旅行状态）；数据严格以本次实查为准，不凭记忆、不猜测。
- 主流程把结果写入 JSON 的 `action`（`clicked` / `skip_already_signed` / `skip_check_only` / `travel`）、`balance`（本期活动累计积分）、`account_balance`（账户真实可用余额）、`travel` 字段；桌面通知与推送（按 `notify_config.json` 配置）同步展示。
- 自动化提示词（脱敏汇报规范 + 旅行字段转述 + 失败如实报告）见 `@references/examples.md`，直接复用为 `automation_update` 的 prompt。
- 交付后提醒用户：当日若已手动签到会自动跳过；每日 09:00 主任务兜底（电脑不关机时仍签到），电脑开机/登录后由开机补签触发器确保当日签到；请在 Buddy 加油站核对 +100。

## 配置与参数

- **脚本落位目录**：`~/.workbuddy/scripts/`（主脚本与 `push_message.py` 必须同目录；只复制主脚本时推送自动降级）。
- **Python 运行环境**：脚本仅用标准库，Python 3.10+ 即可；系统无 `python` 命令时用托管 Python（如 WorkBuddy 用户目录下的 `.workbuddy/binaries/python/versions/*/python.exe`）或任意已装 Python。
- **推送配置**：`~/.workbuddy/scripts/notify_config.json`（不存在 → 完全不推送）。`enabled` 总开关；`success_notify: true` 时签到成功也推送（默认 false 仅失败推）。微信推送（PushPlus 中转）按用户要求**暂不启用/已忽略**，无需配置 token。
- **补签状态文件**：`~/.workbuddy/scripts/checkin_status.json`（开机补签用，主任务成功写入；非脚本源码，不进 skill 目录）。
- **主脚本参数**：`--check-only`（只读查询）/ `--no-travel`（只签到）/ `travel`（只查旅行）/ `--location N`（1-4 指定地点）/ `--push-channels` / `--confirm-paid`（放行付费短信）/ `--no-notify` / `--diagnose` / `--self-test-atrest` / `--init-config` / `--version` / `boot-catchup`（雪人定制补签）。
- **AtRestEncryption 密钥**：优先环境变量，其次进程内存扫描（需客户端已启动并登录、同 Windows 用户），失败回退 `~/.workbuddy/auth` 明文兜底登录态。

## 资源目录

### scripts/
- `workbuddy_checkin.py`：签到 + 派猫猫旅行主流程（含雪人定制的真实余额与 boot-catchup）。
- `push_message.py`：12 渠道推送模块（被主脚本按同目录导入，也可独立运行：`push_message.py --ready` 列就绪渠道）。
- `boot_checkin.ps1`：开机补签启动器（等待 `WorkBuddy.exe` 进程后调用 `boot-catchup`），由「启动文件夹 .bat」或「计划任务 onlogon」在登录时触发。
- `install_boot_task.ps1`：一键注册「计划任务（AtLogOn）」的 PowerShell 脚本（重跑可覆盖）。

### references/
- `api-spec.md`：接口规范、登录态格式、字段与错误码、推送模块接口。
- `examples.md`：自动化提示词、命令示例、推送配置示例、安装/卸载说明。
- `user-guide.md`：面向用户的快速开始 / 桌面通知 / 推送配置 / 自检 / FAQ / 排错。

### assets/
（本技能无静态资源）

### data/
（本技能无结构化数据）

### log/
- `~/.workbuddy/scripts/checkin.log`：脚本本地运行日志（系统定时任务无对话汇报时靠它核查；非 skill 内文件）。

## 资源固化与自包含（强制）

**凡与本 skill 强相关的资源，一律固化进 skill 目录内**，使 skill **自包含、可独立运行**。适用于 skill 的**创建、修改、更新全过程**，是长期标准。

1. **判断口径**：**没有它 skill 就跑不出正确结果** → 属于强相关，必须固化。典型：主/推送脚本、参考文档、配置模板。
2. **放置位置**：参考文档 → `references/`；配置模板 → `templates/`；可执行脚本 → `scripts/`。
3. **取资源顺序固定**：`skill 内 scripts → 外部路径回退`。脚本里禁止只写外部绝对路径（本技能脚本的状态文件/推送配置文件路径为固定的 `~/.workbuddy/scripts/`，属用户级运行产物，不随 skill 打包）。
4. **不固化的例外**：① 系统自带资源；② 凭据 / API Key / Token —— **绝不写入 skill**，`notify_config.json`（含真实密钥）只存用户本地、不进 skill 目录、不提交仓库；③ 可随时再生的缓存、`__pycache__`、本地运行日志 `checkin.log` 与状态文件 `checkin_status.json`。
5. **更新即备份**：每次修改 skill 后**自动重新封装并同步**到 `WB Skill 备份目录（用户侧本地技能库）\xueren-workbuddy-checkin\`（目录结构一致，**排除 `__pycache__`**），无需用户另外吩咐。备份库是用户侧权威存档。
6. **交付前自检**：假设把外部素材目录改名/移走，本 skill 还能跑通吗？不能 → 说明资源没固化到位。

## 注意事项

- **雪人定制与上游的差异**：本技能脚本为 v3.1.2 的雪人分支（内部版本号 `3.1.2-xueren`），仅新增"账户真实可用余额"与"开机补签"两项，未改动签到/旅行/推送主逻辑；若 WorkBuddy 服务端接口变更，需回到 `@references/api-spec.md` 核对并同步上游修复。
- **余额口径务必分清**：`balance` = 本期活动累计积分（`total_credits`，每天 +100 累加，非账户余额）；`account_balance` = 账户真实可用余额（取自 `get-user-resource-summary`，带小数，随 AI 使用持续扣减）。汇报时两者都给、不混淆。
- **开机补签触发器（已改为系统层）**：补签不再依赖 WorkBuddy 自动化引擎的固定时刻，而由 Windows「启动文件夹 .bat」与/或「计划任务 onlogon」在用户登录时触发，电脑开机即签；脚本层面幂等安全、本地今日已成功则跳过，不会重复加分。登录态解密（5.6.2+）可能需 WorkBuddy 运行中（进程内存密钥），启动器已内置"等待 WorkBuddy.exe"逻辑，故请保持 WorkBuddy 开机自启（默认即如此）。
- **微信推送已搁置**：按用户要求，个人微信推送（PushPlus/小程序原生订阅消息）不再跟进，脚本保留占位但不启用，汇报中不再列为待办。
- **安全约束**：只读登录态，绝不修改/删除/外传 token；任何输出不得含真实 token 或推送凭据；写操作仅限 `daily-checkin`、`travel/claim`、`travel/depart` 三个端点；不引入第三方 SDK；不在网页版尝试签到。
- **排错要点**：`code=10001` 是已签非错误；404 必是域名/前缀错（签到带 `/v2`、旅行不带且域名为 `www.workbuddy.cn`）；推送没发先 `--diagnose` 看 `notify_config.ready`；5.6.2+ 解不开密钥确保客户端已启动登录且与脚本同用户。
