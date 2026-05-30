# AI 客服智能体

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-yellow.svg" alt="License"></a>
  <a href="#"><img src="https://img.shields.io/badge/Python-3.10%2B-blue.svg" alt="Python"></a>
  <a href="#"><img src="https://img.shields.io/badge/FastAPI-%E2%89%A50.100-teal.svg" alt="FastAPI"></a>
  <a href="#"><img src="https://img.shields.io/badge/MCP-Streamable%20HTTP-purple.svg" alt="MCP"></a>
  <a href="#"><img src="https://img.shields.io/badge/MySQL-5.7-orange.svg" alt="MySQL"></a>
</p>

<p align="center">
  <a href="README.md">English</a>
</p>

<p align="center"><em>LLM + MCP 工具调用 · FastAPI 后端 · uni-app 前端 · 电商智能客服</em></p>

## 项目简介

基于 LLM + MCP（模型上下文协议）+ MySQL 的电商智能客服系统。大模型自主调用 MCP 工具查询数据库、获取售后规则、创建人工工单，前端为 uni-app 聊天界面，支持 Markdown 渲染。

## 内容

| 模块 | 说明 |
|------|------|
| `backend/app.py` | FastAPI 服务端 — 聊天、流式输出、智能体调用 |
| `backend/agent.py` | LLM 加载 + LangChain Agent 工厂 |
| `mcp/mcp_server.py` | MCP 服务端（FastMCP）— 数据库查询、售后规则、工单管理 |
| `mcp/mcp_client.py` | MCP 客户端配置（连接 mcp_server） |
| `prompts/prompt.py` | 系统提示词 — 电商售后客服智能体人设 |
| `frontend/` | uni-app 小程序前端 — 聊天界面 + Markdown 渲染 |

## 关键能力

- **订单查询** — 按用户名、订单号、日期范围查询
- **物流追踪** — 实时物流状态
- **售后服务** — 退货、换货、退款、破损等标准化规则
- **人工兜底** — 自动生成工单编号，支持状态追踪
- **数据分析** — 商品销量排名、用户购买频次、订单分布
- **流式输出** — SSE 实时逐字回复
- **工具自主调用** — LLM 自行决策调用 MCP 工具，无硬编码路由

## 系统组件

| 组件 | 技术栈 | 职责 |
|------|--------|------|
| **LLM 智能体** | LangChain + 通义千问（DashScope） | 意图理解、SQL 生成、回复组合 |
| **MCP 服务** | FastMCP（streamable-http，端口 8082） | 工具层：数据库 / 规则 / 工单 |
| **后端** | FastAPI + uvicorn（端口 8000） | HTTP API，CORS，静态资源，流式输出 |
| **前端** | uni-app（Vue） | 类微信聊天界面，Markdown 渲染，移动端适配 |
| **数据库** | MySQL 5.7 | 订单、用户、商品、物流、售后规则、工单 |

## MCP 工具

| 工具 | 功能 |
|------|------|
| `get_data_base(sql)` | 执行 SQL 语句 — 查询订单、用户、商品、统计数据 |
| `get_after_sales_policy(type)` | 查询售后规则 — 退货 / 换货 / 退款 / 破损 |
| `create_human_service_ticket(...)` | 创建人工客服工单（自动生成 ID，状态"待处理"） |
| `query_human_service_ticket(id)` | 查询工单状态与详情 |

## 快速上手

```bash
# 1. 安装依赖
pip install -r requirements.txt

# 2. 初始化 MySQL
# 创建 chatbi 库后执行：
mysql -u root -p chatbi < sql/init.sql

# 3. 配置环境变量
cp env_example.txt .env
# 编辑 .env — 填入 QWENG_API_KEY（阿里云百炼 / DashScope）

# 4. 启动 MCP 服务（终端 1）
python mcp/mcp_server.py
# → MCP 服务运行在 http://localhost:8082/mcp

# 5. 启动 FastAPI 后端（终端 2）
python backend/app.py
# → API 运行在 http://localhost:8000
# → 测试：http://localhost:8000/chat?q=你好
# → 智能体：http://localhost:8000/chat_agent?q=帮我查订单

# 6. 打开前端
# 用 HBuilder X 打开 frontend/ → 运行到小程序开发工具
```

## 目录结构

```
ai-customer-service-agent/
├── backend/
│   ├── app.py                 # FastAPI 入口
│   └── agent.py               # LLM + Agent 工厂
├── mcp/
│   ├── mcp_server.py           # MCP 服务端（4 个工具）
│   └── mcp_client.py           # MCP 客户端配置
├── prompts/
│   └── prompt.py               # 系统提示词
├── frontend/                   # uni-app 小程序
│   ├── pages/index/index.vue   # 聊天界面
│   └── uni_modules/            # Markdown 渲染组件
├── static/
│   └── index.html
├── .env                        # API 密钥（已 gitignore）
├── env_example.txt             # 配置模板
├── requirements.txt            # 依赖清单
└── .gitignore
```

## 工作流程

```
用户消息（前端 uni-app）
    ↓
FastAPI 后端 (/chat_agent)
    ↓
LLM 智能体（LangChain + 通义千问）
    ↓
MCP 工具调用 ──→ MySQL / 售后规则 / 工单
    ↓
自然语言回复
    ↓
流式输出 → 前端聊天界面
```

## 数据库表结构

| 表名 | 说明 |
|------|------|
| `users` | 用户信息 |
| `products` | 商品信息 |
| `orders` | 订单记录 |
| `logistics` | 物流信息 |
| `after_sales_policy` | 售后规则（退货 / 换货 / 退款 / 破损） |
| `human_service_ticket` | 人工客服工单 |

## 注意事项

- 本项目用于**学习与演示**，MCP 数据库工具拥有完整 SQL 权限——**不适合直接用于生产环境**。
- 需要本地运行 MySQL 5.7 并初始化 `chatbi` 数据库。
- 默认 LLM 为通义千问 Qwen3-Max，通过 `.env` 可切换为任意 OpenAI 兼容接口。
- 前端为 uni-app 项目，使用 HBuilder X 打开可编译为小程序。

## 许可证

Apache 2.0。
