#agent.py文件
from langchain_mcp_adapters.client import MultiServerMCPClient
# 引入核心库
import os
from langchain_openai import ChatOpenAI
from dotenv import load_dotenv
from langchain.agents import create_agent
import asyncio
from my_mcp.mcp_client import mcp_client
from prompts.prompt import SYSTEM_PROMPTS
# 引入网络请求工具库
import requests
# 设置电脑中的环境变量
# 把相对路径改为绝对路径
current_path=os.path.dirname(os.path.dirname(os.path.abspath(__file__)))#项目根目录
env_path=os.path.join(current_path,".env")# .env文件路径拼接成绝对路径
load_dotenv(dotenv_path=env_path,override=True)

# 获取电脑中的环境变量
api_key=os.getenv("QWENG_API_KEY")
base_url=os.getenv("QWENG_BASE_URL")
model=os.getenv("QWENG_MODEL")

# 加载大模型的函数
def load_llm():
    # 创建大模型对象:参数分别是(模型名,申请的apikey,使用模型需要的网址)
    llm=ChatOpenAI(model=model,api_key=api_key,base_url=base_url)
    return llm

# 加载智能体的函数
async def load_agent():
    # 创建大模型对象
    llm=load_llm()
    # 系统提示词
    # 创建智能体对象:参数分别是(大模型对象,工具,提示词)
    tools = await mcp_client.get_tools()
    agent=create_agent(model=llm,tools=tools,system_prompt=SYSTEM_PROMPTS)
    return agent

if __name__ == '__main__':
    """llm invoke"""
    # # 调用函数加载模型对象
    # llm=load_llm()
    # # 使用模型对象进行推理(一次性输出最后的结果)
    # result=llm.invoke("你是谁？")
    # print(result.content)

    """llm stream"""
    # llm=load_llm()
    # # 使用大模型进行流式推理(每次输出一个推理的词 得到一个生成器对象,迭代[for]这个对象可以得到每一个词[也就是token])
    # res=llm.stream("你是谁？")
    # # print(res)
    # for chunk in res:
    #     print(chunk.content)

    """agent ainvoke"""
    # 创建一个异步函数
    async def test():
        # 加载智能体对象
        agent = await load_agent()
        # 使用智能体对象进行推理
        # 数据的格式是固定的字典列表格式,其中role表示角色[user system ai] content表示内容
        msg = {"messages": [{"role": "user", "content": "张三今年多大?"}]}
        msg = {"messages":[{"role":"user","content":"张三比李四大几岁?"}]}
        msg = {"messages":[{"role":"user","content":"今天广安天气如何?"}]}
        msg = {"messages": [{"role": "user", "content": "张三比李四大几岁?今天北京天气如何?今天北京适合出门玩吗?"}]}
        msg = {"messages": [{"role": "user", "content": "总结数据库有什么名称的商品，哪些商品运输到达"}]}
        res=await agent.ainvoke(msg)
        print(res["messages"][-1].content)

    #调用test异步函数
    asyncio.run(test())

