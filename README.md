# 雪人老师·WorkBuddy签到助手

> 读取本机已登录 WorkBuddy 的登录态，直接调用官方接口完成「Buddy 加油站」每日签到（无需点击 GUI），并支持派猫猫旅行（查状态 / 领旅行积分 / 派 Buddy 出门，默认随签到跑全自动闭环）+ 12 类多渠道消息推送 + 桌面通知。同时固化两项雪人定制：账户真实可用余额（取自 get-user-resource-summary，与客户端侧边栏一致）与开机补签（boot-catchup）。当用户说"每天自动签到 WorkBuddy / 每日签到 / 自动领 100 积分 / WorkBuddy 打卡 / 派猫猫旅行 / 查下当前积分情况 / 签到通知发微信 / 客户端被更新后签不了 / 5.6.2 签到失败 / 登录态加密了 / 积分 / 查询积分 / 剩余积分 / 我的积分 / 余额 / 当前余额"时触发。不适用于网页版（仅 PC 客户端专属，网页版无签到入口）。
本 skill 遵循通用 SKILL 规范（`SKILL.md` + `meta.json` + 资源目录），可装入任何支持 skill 的 AI 工具（WorkBuddy、Claude Code、Cursor 等）。

## 使用方式

装好后使用就是普通的对话形式——在 AI 工具里说出对应意图，它会按 `SKILL.md` 的流程引导你完成。详细流程见 `SKILL.md`。

## 效果预览

「查下积分」的可视化输出（show_widget 渲染，实际以会话内组件展示）：彩色指标卡 + 单表到期明细（以「使用中」为基准，前后各 10 条），含获取方式、剩余/总量进度条、到期提示与状态标签。

![积分到期明细效果预览](https://raw.githubusercontent.com/JackieZheng/xueren-workbuddy-checkin/main/assets/preview-credits.png)

