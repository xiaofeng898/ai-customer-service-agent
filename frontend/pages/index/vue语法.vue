<template>
	<view class="content">
		<button @click="send_data">发送给服务器(非流式)</button>
		<button @click="send_data_stream">发送数据给服务器(流式)</button>
		<button @click="send_agent">agent_智能体</button>
		<view>{{msg}}</view>
		<view class="text-area">
			<text class="title">{{}}</text>
		
		</view>
	</view>
</template>

<script>
	export default {
		data() {
			return {
				title: 'Hello',
				msg:"你是谁"
			}
		},
		onLoad() {
			
		},
		methods: {
			send_agent(){
				console.log("测试点击")
				uni.request({
					url:"http://localhost:8000/chat_agent",
					data:{q:"广安今天天气怎样，适合旅游吗"},
					success:(res) => {
						console.log(res.data)
						this.msg=res.data
					}
				})
			},
			send_data(){
				uni.request({
					url:"http://localhost:8000/chat",
					data:{q:"你是谁"},
					success:(res) => {
						console.log(res.data)
						this.msg=res.data
					}
				})
			},
			async send_data_stream(){
				//网络请求流式对象
				let url="http://localhost:8000/chat_stream?q=你谁啊"
				let res=await fetch(url)//得到一个可读取的流式对象
				// console.log(res)
				let reader=res.body.getReader()//得到这个流式对象的读取工具
				let decoder=new TextDecoder("utf-8")//创建一个二进制数据解码工具
				
				// 循环
				while(true){
					let data1=await reader.read()//读取一次
					if(data1.done){break}//如果没有数据了 就停止循环(读取)
					// console.log(data1)//如果有数据就打印
					let data1_text=decoder.decode(data1.value,{stream:true})// 解析读取出来的二进制数据
					console.log(data1_text)
					this.msg=this.msg+data1_text//把解析的数据拼接到msg变量中(页面就会出现流式渲染的效果)
				}
				
			}
		}
	}
</script>

<style>
	
</style>
