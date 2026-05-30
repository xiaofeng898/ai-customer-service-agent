from langchain_mcp_adapters.client import MultiServerMCPClient
# 引入核心库
import os
from langchain_openai import ChatOpenAI
from dotenv import load_dotenv
from langchain.agents import create_agent
import asyncio


mcp_client=MultiServerMCPClient({
    # "mymcp-server": {
    #     "url": "http://localhost:8081/mcp",
    #     "transport": "streamable_http"
    # },
    "mymcp-server2": {
        "url": "http://localhost:8082/mcp",
        "transport": "streamable_http"
    },
    # "my-12306-mcp-server": {
    #     "url": "http://localhost:8083/mcp",
    #     "transport": "streamable_http"
    # },
})

