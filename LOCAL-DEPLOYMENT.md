# 本机部署

项目目录：`D:\Postgraduate\source\FakeAPI`

需要 Node.js 18 或更高版本。Node 本地服务仅使用内置模块，无需安装 npm 依赖；package.json 中的 Wrangler 仅用于 Cloudflare 部署。

在此文件夹打开 PowerShell，然后启动后台服务：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\start-local.ps1
```

默认地址：<http://localhost:3000>

OpenAI 接口 Base URL：`http://localhost:3000/v1`

健康检查：<http://localhost:3000/health>

API Key 使用 `config.js` 中的 `apiKey` 值；修改后重启生效。此仓库会优先使用配置文件中的 Key，只有清空 `apiKey` 后才使用环境变量 `FAKE_API_KEY`。直接运行 Node 不会自动加载 `.env`。

停止服务：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\stop-local.ps1
```

更换端口（先停止已有服务）：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\start-local.ps1 -Port 3001
```

启动日志：`server.log`；错误日志：`server-error.log`。服务会在后台运行，重启电脑后需要重新启动。

这个项目是模拟 AI API，普通请求会返回字符画，不会调用真实大模型。
