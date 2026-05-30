<template>
	<view class="page">
		<!-- 背景层 -->
		<view class="page_bg"></view>

		<!-- 顶部区域 -->
		<view class="topbar">
			<view class="status_bar"></view>
			<view class="nav_bar">
				<image class="nav_bar_img" src="/static/caidan.png"></image>
				<view class="nav_bar_center">
					<view class="nav_bar_title">XX电商智能客服</view>
					<view class="nav_bar_subtitle">订单查询 · 数据分析 · 售后服务</view>
				</view>
			</view>
		</view>

		<!-- 欢迎卡片 -->
		<view class="hero_card">
			<view class="hero_left">
				<view class="hero_title">您好，欢迎来到XX电商客服中心</view>
				<view class="hero_desc">
					可为您提供订单查询、物流跟踪、退换货规则、售后工单、商品与订单数据分析等服务
				</view>
			</view>
			<image class="hero_icon" src="/static/right.png"></image>
		</view>

		<!-- 聊天内容区 -->
		<scroll-view
			class="content"
			scroll-y="true"
			:scroll-with-animation="true"
			:scroll-into-view="scrollIntoView"
		>
			<view class="chat_list">
				<view
					v-for="(el, index) in arr"
					:key="index"
					:id="'msg-' + index"
				>
					<!-- 左侧 AI -->
					<view v-if="el.flag === 0" class="left_content">
						<image class="touxiang" src="/static/left.jpg"></image>
						<view class="bubble bubble_left">
							<zeromarkdown class="markdown_box" :markdown="el.text"></zeromarkdown>
						</view>
					</view>

					<!-- 右侧 用户 -->
					<view v-else class="right_content">
						<view class="bubble bubble_right">{{ el.text }}</view>
						<image class="touxiang" src="/static/right.png"></image>
					</view>
				</view>

				<!-- 加载中 -->
				<view v-if="loading" class="left_content" id="msg-loading">
					<image class="touxiang" src="/static/left.jpg"></image>
					<view class="bubble bubble_left loading_text">正在为您分析，请稍候...</view>
				</view>

				<!-- 底部锚点 -->
				<view id="chat-bottom" class="bottom_anchor"></view>
			</view>
		</scroll-view>

		<!-- 底部输入区 -->
		<view class="bottom_bar">
			<input
				class="chat_input"
				type="text"
				v-model="msg"
				placeholder="请输入您的问题，例如：帮我查一下订单 / 退货规则是什么"
				confirm-type="send"
				@confirm="send_data"
				:disabled="loading"
			/>
			<view
				class="send_btn"
				:class="{ send_btn_disabled: loading }"
				@click="send_data"
			>
				{{ loading ? "发送中" : "发送" }}
			</view>
		</view>

		<!-- 页尾 -->
		<view class="footer_bar">
			<view class="footer_text">XX电商客户服务中心 · 智能客服为您在线服务</view>
		</view>

		<!-- 右下角联系电话 -->
		<view class="contact_float">
			<view class="contact_title">客服热线</view>
			<view class="contact_phone">400-888-2026</view>
		</view>
	</view>
</template>

<script>
import zeromarkdown from "@/uni_modules/zero-markdown-view/components/zero-markdown-view/zero-markdown-view.vue"

export default {
	components: {
		zeromarkdown
	},
	data() {
		return {
			msg: "",
			loading: false,
			scrollIntoView: "chat-bottom",
			arr: [
				{
					flag: 0,
					text: "您好，欢迎来到**XX电商智能客服**。\n\n我可以帮您处理：\n- 订单查询\n- 物流跟踪\n- 退货/换货规则\n- 售后服务与人工工单\n- 商品与订单数据分析"
				}
			]
		}
	},
	methods: {
		scrollToBottom() {
			this.$nextTick(() => {
				if (this.loading) {
					this.scrollIntoView = ""
					this.$nextTick(() => {
						this.scrollIntoView = "msg-loading"
					})
				} else {
					this.scrollIntoView = ""
					this.$nextTick(() => {
						this.scrollIntoView = "chat-bottom"
					})
				}
			})
		},

		send_data() {
			const user_input = (this.msg || "").trim()

			if (!user_input) {
				uni.showToast({
					title: "请输入内容",
					icon: "none"
				})
				return
			}

			if (this.loading) return

			// 用户消息入列
			this.arr.push({
				flag: 1,
				text: user_input
			})

			// 清空输入框
			this.msg = ""
			this.loading = true
			this.scrollToBottom()

			// 请求后端
			uni.request({
				timeout: 600000,
				url: "http://localhost:8000/chat_agent",
				method: "GET",
				data: {
					q: user_input
				},
				success: (res) => {
					console.log("服务器返回:", res)

					let aiText = ""

					if (typeof res.data === "string") {
						aiText = res.data
					} else if (res.data && typeof res.data === "object") {
						aiText = JSON.stringify(res.data, null, 2)
					} else {
						aiText = "服务器返回内容为空"
					}

					this.arr.push({
						flag: 0,
						text: aiText
					})
				},
				fail: (err) => {
					console.log("请求失败:", err)
					this.arr.push({
						flag: 0,
						text: "请求失败，请检查后端服务是否启动，或接口是否正常。"
					})
				},
				complete: () => {
					this.loading = false
					this.scrollToBottom()
				}
			})
		}
	},
	mounted() {
		this.scrollToBottom()
	}
}
</script>

<style>
page {
	height: 100%;
}

.page {
	width: 100%;
	height: 100vh;
	display: flex;
	flex-direction: column;
	position: relative;
	overflow: hidden;
	background: linear-gradient(180deg, #eef7ff 0%, #f8fbff 36%, #f4f6f8 100%);
}

/* 背景装饰 */
.page_bg {
	position: absolute;
	top: 0;
	left: 0;
	right: 0;
	height: 420rpx;
	background: linear-gradient(135deg, #2b6ff3 0%, #53a7ff 55%, #87d1ff 100%);
	border-bottom-left-radius: 40rpx;
	border-bottom-right-radius: 40rpx;
	z-index: 0;
}

/* 顶部 */
.topbar {
	width: 100%;
	height: 132rpx;
	position: relative;
	z-index: 2;
	flex-shrink: 0;
}

.status_bar {
	width: 100%;
	height: 40rpx;
}

.nav_bar {
	width: 100%;
	height: 92rpx;
	display: flex;
	align-items: center;
	padding: 0 24rpx;
	box-sizing: border-box;
}

.nav_bar_img {
	width: 52rpx;
	height: 52rpx;
	margin-right: 20rpx;
}

.nav_bar_center {
	display: flex;
	flex-direction: column;
	justify-content: center;
}

.nav_bar_title {
	font-size: 34rpx;
	font-weight: 700;
	color: #ffffff;
	line-height: 1.2;
}

.nav_bar_subtitle {
	font-size: 22rpx;
	color: rgba(255, 255, 255, 0.88);
	margin-top: 6rpx;
}

/* 欢迎卡片 */
.hero_card {
	width: 702rpx;
	margin: 0 auto 14rpx auto;
	padding: 28rpx 26rpx;
	box-sizing: border-box;
	border-radius: 24rpx;
	background: rgba(255, 255, 255, 0.96);
	box-shadow: 0 10rpx 24rpx rgba(32, 85, 168, 0.12);
	display: flex;
	justify-content: space-between;
	align-items: center;
	position: relative;
	z-index: 2;
	flex-shrink: 0;
}

.hero_left {
	flex: 1;
	padding-right: 20rpx;
}

.hero_title {
	font-size: 30rpx;
	font-weight: 700;
	color: #1f2d3d;
	line-height: 1.4;
}

.hero_desc {
	font-size: 24rpx;
	color: #5c6b77;
	line-height: 1.6;
	margin-top: 12rpx;
}

.hero_icon {
	width: 84rpx;
	height: 84rpx;
	border-radius: 20rpx;
}

/* 聊天区 */
.content {
	flex: 1;
	min-height: 0;
	width: 100%;
	position: relative;
	z-index: 1;
}

.chat_list {
	padding: 12rpx 0 20rpx 0;
	box-sizing: border-box;
}

.left_content,
.right_content {
	width: 100%;
	display: flex;
	align-items: flex-start;
	margin-top: 18rpx;
	padding: 0 18rpx;
	box-sizing: border-box;
}

.left_content {
	justify-content: flex-start;
}

.right_content {
	justify-content: flex-end;
}

.touxiang {
	width: 64rpx;
	height: 64rpx;
	border-radius: 16rpx;
	flex-shrink: 0;
	box-shadow: 0 4rpx 10rpx rgba(0, 0, 0, 0.08);
}

.left_content .touxiang {
	margin-right: 12rpx;
}

.right_content .touxiang {
	margin-left: 12rpx;
}

.bubble {
	max-width: 520rpx;
	padding: 18rpx 20rpx;
	border-radius: 18rpx;
	word-break: break-word;
	line-height: 1.7;
	font-size: 28rpx;
	box-sizing: border-box;
}

.bubble_left {
	background-color: rgba(255, 255, 255, 0.98);
	color: #2d3436;
	box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.05);
}

.bubble_right {
	background: linear-gradient(135deg, #2b6ff3 0%, #4aa5ff 100%);
	color: #ffffff;
	box-shadow: 0 4rpx 12rpx rgba(43, 111, 243, 0.18);
}

.markdown_box {
	color: #2d3436;
}

.loading_text {
	color: #6b7280;
	font-style: italic;
}

.bottom_anchor {
	height: 2rpx;
}

/* 底部输入区 */
.bottom_bar {
	width: 100%;
	min-height: 104rpx;
	background: rgba(255, 255, 255, 0.96);
	display: flex;
	align-items: center;
	padding: 12rpx 20rpx;
	padding-bottom: calc(12rpx + env(safe-area-inset-bottom));
	box-sizing: border-box;
	flex-shrink: 0;
	border-top: 1rpx solid #e9eef5;
	position: relative;
	z-index: 2;
}

.chat_input {
	flex: 1;
	height: 74rpx;
	background-color: #f7f9fc;
	border-radius: 16rpx;
	padding: 0 20rpx;
	box-sizing: border-box;
	font-size: 28rpx;
	border: 1rpx solid #e5ebf3;
}

.send_btn {
	width: 124rpx;
	height: 74rpx;
	margin-left: 14rpx;
	background: linear-gradient(135deg, #2b6ff3 0%, #4aa5ff 100%);
	border-radius: 16rpx;
	line-height: 74rpx;
	text-align: center;
	color: #fff;
	font-size: 28rpx;
	font-weight: 600;
	box-shadow: 0 6rpx 14rpx rgba(43, 111, 243, 0.18);
}

.send_btn_disabled {
	background: #9cbcf5;
	box-shadow: none;
}

/* 页尾 */
.footer_bar {
	width: 100%;
	height: 56rpx;
	display: flex;
	align-items: center;
	justify-content: center;
	background: rgba(240, 244, 248, 0.95);
	color: #7a8794;
	font-size: 22rpx;
	flex-shrink: 0;
	position: relative;
	z-index: 2;
	border-top: 1rpx solid #eef1f5;
}

.footer_text {
	text-align: center;
	padding: 0 20rpx;
	box-sizing: border-box;
}

/* 右下角联系电话 */
.contact_float {
	position: fixed;
	right: 22rpx;
	bottom: 180rpx;
	z-index: 10;
	background: rgba(255, 255, 255, 0.96);
	border-radius: 20rpx;
	padding: 16rpx 18rpx;
	box-shadow: 0 8rpx 20rpx rgba(0, 0, 0, 0.12);
	border: 1rpx solid rgba(43, 111, 243, 0.12);
}

.contact_title {
	font-size: 22rpx;
	color: #7b8794;
	line-height: 1.4;
}

.contact_phone {
	font-size: 28rpx;
	font-weight: 700;
	color: #2b6ff3;
	line-height: 1.5;
	margin-top: 4rpx;
}
</style>