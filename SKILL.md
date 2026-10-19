---
id: xueren-workbuddy-checkin
name: 雪人老师·WorkBuddy签到助手
title: 雪人老师·WorkBuddy签到助手
description: 读取本机已登录 WorkBuddy 的登录态，直接调用官方接口完成「Buddy 加油站」每日签到（无需点击 GUI），并支持派猫猫旅行（查状态 / 领旅行积分 / 派 Buddy 出门，默认随签到跑全自动闭环）+ 旅行奖励自动领取（计划任务每 10 分钟，Buddy 归来即领、空闲即派）+ 12 类多渠道消息推送 + 桌面通知。同时固化四项雪人定制：账户真实可用余额（取自 get-user-resource-summary，与客户端侧边栏一致）、开机补签（boot-catchup）、积分到期盘点（credits，列出每笔积分的到期时间并按最紧急排序）、旅行奖励自动领取（travel-watch）。当用户说"每天自动签到 WorkBuddy / 每日签到 / 自动领 100 积分 / WorkBuddy 打卡 / 派猫猫旅行 / 自动领旅行奖励 / 查下当前积分情况 / 客户端被更新后签不了 / 5.6.2 签到失败 / 登录态加密了 / 积分 / 查询积分 / 剩余积分 / 我的积分 / 余额 / 当前余额 / 积分到期 / 哪些积分快过期 / 积分还有多久过期"时触发。不适用于网页版（仅 PC 客户端专属，网页版无签到入口）。
slug: xueren-workbuddy-checkin
displayName: 雪人老师·WorkBuddy签到助手
summary: 读取本机已登录 WorkBuddy 的登录态，直接调用官方接口完成每日签到与派猫猫旅行闭环，支持旅行奖励自动领取、积分到期盘点与多渠道推送。
version: 1.3.5
author: 雪人
license: MIT
display_name: xueren-workbuddy-checkin
trigger: ["每天自动签到 WorkBuddy", "每日签到", "自动领 Buddy 加油站积分", "WorkBuddy 打卡", "派猫猫旅行", "自动领旅行奖励", "查下当前积分情况", "积分", "查询积分", "剩余积分", "我的积分", "余额", "当前余额", "积分到期", "哪些积分快过期", "积分还有多久过期", "到期时间", "签到通知", "5.6.2 签到失败", "登录态加密了"]
examples: "用户说「每天自动签到 WorkBuddy」→ 脚本落位到 ~/.workbuddy/scripts/，建每日 09:00 主签到自动化与开机补签触发器；用户说「查下当前积分情况」→ 跑 --check-only，返回本期活动累计积分与账户可用余额；用户说「派猫猫旅行」→ 跑 travel 子命令；用户说「自动领旅行奖励」→ 部署 travel_watch 计划任务（每 10 分钟）。"
platforms: [ima, WorkBuddy, QClaw]
github: https://github.com/JackieZheng/xueren-workbuddy-checkin
skillhub: https://skillhub.cn/skills/indiv-xueren/xueren-workbuddy-checkin
---

# 雪人老师·WorkBuddy签到助手

「查下积分」的可视化效果（会话内彩色卡片 + 到期明细表）：

![积分到期明细效果预览](https://raw.githubusercontent.com/JackieZheng/xueren-workbuddy-checkin/main/assets/preview-credits.png)

## 是什么

读取本机已登录 WorkBuddy 的登录态，直接调用官方接口完成「Buddy 加油站」每日签到——无需打开客户端、无需模拟点击 GUI。派猫猫旅行默认随签到跑全自动闭环（查状态 / 领积分 / 派 Buddy 出门），旅行奖励另由计划任务每 10 分钟自动领取，Buddy 归来即到账、空闲即再派出。

四项雪人定制：账户真实可用余额（与客户端侧边栏一致）、开机补签、积分到期盘点、旅行奖励自动领取。仅支持 PC 客户端，网页版无签到入口。

## 怎么跑

```bash
python workbuddy_checkin.py                  # 签到 + 派猫猫旅行闭环
python workbuddy_checkin.py --check-only     # 只读查询：双口径积分 + 连续签到 + 旅行状态
python workbuddy_checkin.py credits --html   # 积分到期明细（结构化结果，widget 输出）
python workbuddy_checkin.py travel-watch     # 旅行奖励自动领取（计划任务高频调用）
```

## 关键约定

- **双口径积分**：`balance` = 本期活动累计积分（活动口径，每日 +100 累加）；`account_balance` = 账户真实可用余额（带小数，随使用扣减）。汇报两者都给，不混淆。
- **写接口白名单**：仅 `daily-checkin` / `travel/claim` / `travel/depart` 三个端点；登录态只读，token 与推送凭据绝不外泄。
- **域名口径**：签到带 `/v2`；余额与旅行接口不带 `/v2`、域名为 `www.workbuddy.cn`；404 必是域名或前缀错误。
- **派遣纪律**：`daily_limit_reached` 为真绝不派遣；`arrived` 状态不会丢积分，可下次补领；不在网页版尝试签到。
- **结构化结果一律 widget 输出**：积分到期等查询的最终结果用 `show_widget` 呈现美化卡片，不贴 JSON、不贴纯文本表格。
