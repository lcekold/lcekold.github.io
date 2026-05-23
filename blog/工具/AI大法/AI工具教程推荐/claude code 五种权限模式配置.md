claude code官方文档：<a href="https://code.claude.com/docs/zh-CN/permission-modes">选择权限模式</a>

| 模式 | 无需询问即可运行的操作 | 最适合 |
|------|------------------------|--------|
| default | 仅读取 | 入门、敏感工作 |
| acceptEdits | 读取、文件编辑和常见文件系统命令（mkdir、touch、mv、cp 等） | 迭代您正在审查的代码 |
| plan | 仅读取 | 在更改代码库前进行探索 |
| auto | 所有操作，带后台安全检查 | 长时间任务、减少提示疲劳 |
| dontAsk | 仅预先批准的工具 | 锁定的 CI 和脚本 |
| bypassPermissions | 所有操作，带后台安全检查 | 仅隔离容器和 VM |

值得注意的是，如果是使用第三方API那么是无法使用auto模式的


