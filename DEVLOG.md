# xueren-workbuddy-checkin 版本演进记录

## v1.0.3（2026-10-01）

开机补签改为系统层登录触发(替代09:05定时)；启动器通用路径化(%USERPROFILE%/动态匹配托管Python)；修复开机补签未触发(bat中文注释UTF-8被cmd按GBK误解码，重写纯ASCII+CRLF；ps1加UTF-8 BOM修日志乱码)
