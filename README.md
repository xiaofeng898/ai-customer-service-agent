# AI Customer Service Agent

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-yellow.svg" alt="License"></a>
  <a href="#"><img src="https://img.shields.io/badge/Python-3.10%2B-blue.svg" alt="Python"></a>
  <a href="#"><img src="https://img.shields.io/badge/FastAPI-%E2%89%A50.100-teal.svg" alt="FastAPI"></a>
  <a href="#"><img src="https://img.shields.io/badge/MCP-Streamable%20HTTP-purple.svg" alt="MCP"></a>
  <a href="#"><img src="https://img.shields.io/badge/MySQL-5.7-orange.svg" alt="MySQL"></a>
</p>

<p align="center">
  <a href="README.zh.md">中文</a>
</p>

<p align="center"><em>LLM + MCP Tool Calling · FastAPI Backend · uni-app Frontend · E-Commerce Customer Service</em></p>

## Overview

An AI-powered e-commerce customer service system. An LLM agent autonomously calls MCP tools to query a MySQL database, look up after-sales policies, and escalate to human support — all behind a chat-style uni-app frontend.

## Contents

| Deliverable | Description |
|-------------|-------------|
| `backend/app.py` | FastAPI server — chat, streaming, agent endpoints |
| `backend/agent.py` | LLM loader + LangChain agent factory |
| `my_mcp/mcp_server.py` | MCP server (FastMCP) — database, policies, tickets |
| `my_mcp/mcp_client.py` | MCP client config (connects to mcp_server) |
| `prompts/prompt.py` | System prompt — e-commerce after-sales agent persona |
| `frontend/` | uni-app mini-program — chat UI with Markdown rendering |
| `sql/init.sql` | MySQL schema and seed data |

## Key Capabilities

- **Order query** — by username, order ID, or date range
- **Logistics tracking** — real-time shipment status
- **After-sales services** — return, exchange, refund, damage policies
- **Human support escalation** — auto-generated ticket IDs with status tracking
- **Data analysis** — sales ranking, purchase frequency, order distribution
- **Streaming responses** — SSE-based real-time output
- **Autonomous tool calling** — LLM decides when to invoke MCP tools; no hardcoded routing

## System Components

| Component | Stack | Role |
|-----------|-------|------|
| **LLM Agent** | LangChain + Qwen (DashScope) | Intent understanding, SQL generation, response composition |
| **MCP Server** | FastMCP (streamable-http, port 8082) | Tool layer bridging LLM ↔ MySQL |
| **Backend** | FastAPI + uvicorn (port 8000) | HTTP API, CORS, static files, streaming |
| **Frontend** | uni-app (Vue) | Chat-style UI, Markdown rendering, mobile-optimized |
| **Database** | MySQL 5.7 | Orders, users, products, logistics, policies, tickets |

## MCP Tools

| Tool | Purpose |
|------|---------|
| `get_data_base(sql)` | Execute arbitrary SQL — query orders, users, products, statistics |
| `get_after_sales_policy(type)` | Look up official rules for return / exchange / refund / damage |
| `create_human_service_ticket(...)` | Create a support ticket (auto-generates ID, status "pending") |
| `query_human_service_ticket(id)` | Check ticket status and details |

## Quick Start

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Set up MySQL
# Create database `chatbi` and run:
mysql -u root -p chatbi < sql/init.sql

# 3. Configure environment
cp env_example.txt .env
# Edit .env — fill in QWENG_API_KEY (DashScope / Alibaba Cloud)

# 4. Start MCP server (terminal 1)
python my_mcp/mcp_server.py
# → MCP server on http://localhost:8082/mcp

# 5. Start FastAPI backend (terminal 2)
python backend/app.py
# → API on http://localhost:8000
# → Test: http://localhost:8000/chat?q=hello
# → Agent: http://localhost:8000/chat_agent?q=帮我查订单

# 6. Open frontend
# Open frontend/ in HBuilder X → run on mini-program dev tool
```

## Project Structure

```
ai-customer-service-agent/
├── backend/
│   ├── app.py                 # FastAPI entry point
│   └── agent.py               # LLM + agent factory
├── my_mcp/
│   ├── mcp_server.py           # MCP server (4 tools)
│   └── mcp_client.py           # MCP client config
├── prompts/
│   └── prompt.py               # System prompt
├── frontend/                   # uni-app mini-program
│   ├── pages/index/index.vue   # Chat UI
│   └── uni_modules/            # Markdown renderer
├── static/
│   └── index.html
├── .env                        # API keys (gitignored)
├── env_example.txt             # Config template
├── requirements.txt            # Dependencies
└── .gitignore
```

## Workflow

```
User Message (Frontend uni-app)
    ↓
FastAPI Backend (/chat_agent)
    ↓
LLM Agent (LangChain + Qwen)
    ↓
MCP Tool Invocation ──→ MySQL / Policy / Ticket
    ↓
Natural-Language Response
    ↓
Streaming → Frontend Chat UI
```

## Database Tables

| Table | Description |
|-------|-------------|
| `users` | Customer accounts |
| `products` | Product catalog |
| `orders` | Order records |
| `logistics` | Shipment tracking |
| `after_sales_policy` | Return / exchange / refund / damage rules |
| `human_service_ticket` | Support tickets (AI → human escalation) |

## Notes

- This project is for **learning and demonstration**. The MCP database tool has full SQL permissions — **not safe for production**.
- Requires MySQL 5.7 with the `chatbi` database initialized.
- Default LLM: Qwen3-Max via DashScope. Configurable via `.env` (OpenAI-compatible).
- The frontend is a uni-app project — open in HBuilder X to build as a mini-program.

## License

Apache 2.0.
