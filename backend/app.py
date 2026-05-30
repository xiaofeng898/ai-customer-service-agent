import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import StreamingResponse
from backend.agent import load_llm
from backend.agent import load_agent
app=FastAPI()
# 跨域访问配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# 静态资源托管配置
app.mount("/static",StaticFiles(directory=os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "static")),name="static")

# 配置url
@app.get("/")
def index():
    return "欢迎访问某某公司的服务"
# 服务器网址: http://localhost:8000/chat?q=你好
@app.get("/chat")
def chat(q:str):
    print("客户端发送的数据:",q)  # 获取客户端发送给服务器的数据
    # 加载模型对象
    llm=load_llm()
    # 使用大模型对象进行推理
    result=llm.invoke(q)
    print("大模型的推理结果",result.content)
    return  f"客户端提交给服务器的数据是:{q},大模型的推理结果是:{result.content}"
def stream_with_llm(q:str):
    # 加载模型对象
    llm = load_llm()
    # 模型对象进行流式推理
    for chunk in llm.stream(q):
        yield chunk.content
# 服务器网址: http://localhost:8000/chat_stream?q=你好
@app.get("/chat_stream")
def chat_stream(q:str):
    print("客户端发送的数据:",q)
    return StreamingResponse(stream_with_llm(q), media_type="text/event-stream")

@app.get("/chat_agent")
async def chat_agent(q:str):
    print("客户端发送的数据:", q)
    #创建智能体对象
    agent=await load_agent()
    # 给智能体输入的数据
    msg = {"messages": [{"role": "user", "content":q}]}
    # 智能体运行完成任务
    res = await agent.ainvoke(msg)
    # 结果
    print("智能体的推理结果",res["messages"][-1].content)
    return res["messages"][-1].content


if __name__=="__main__":
    import uvicorn
    uvicorn.run("backend.app:app", host="0.0.0.0", port=8000, reload=True)
