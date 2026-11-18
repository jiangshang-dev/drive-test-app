<script setup>
import { ref, onMounted, nextTick, computed } from 'vue'
import { useMemberStore } from '@/stores'
import { vipChecker } from '@/utils/vipChecker'

// 响应式数据
const messages = ref([])
const userInput = ref('')
const isLoading = ref(false)
const memoryId = ref(Date.now().toString())
const inputFocused = ref(false)
const scrollView = ref(null)
const isLoginChecked = ref(false)
const isLoggedIn = ref(false)
const isVip = ref(false)

// 计算属性：是否显示登录覆盖层
const showLoginOverlay = computed(() => {
  return isLoginChecked.value && !isLoggedIn.value
})

// 计算属性：是否显示会员覆盖层
const showVipOverlay = computed(() => {
  return isLoginChecked.value && isLoggedIn.value && !isVip.value
})

// 检查用户状态
const checkUserStatus = async () => {
  const memberStore = useMemberStore()

  // 检查登录状态
  isLoggedIn.value = !!memberStore.profile
  isLoginChecked.value = true

  if (isLoggedIn.value) {
    // 检查会员状态
    isVip.value = await vipChecker.checkVipStatus()
  }
}

// 新建会话
const startNewConversation = async () => {
  // 检查用户状态
  await checkUserStatus()

  if (!isLoggedIn.value) {
    return
  }

  if (!isVip.value) {
    return
  }

  messages.value = []
  memoryId.value = Date.now().toString()
  messages.value.push({
    role: 'assistant',
    content: '你好！我是驾考通AI助手，有什么可以帮助你的吗？',
  })
}

// 发送消息
const sendMessage = async () => {
  if (!userInput.value.trim() || isLoading.value) return

  // 检查用户状态
  await checkUserStatus()

  if (!isLoggedIn.value) {
    return
  }

  if (!isVip.value) {
    return
  }

  const userMessage = {
    role: 'user',
    content: userInput.value.trim(),
  }

  messages.value.push(userMessage)

  const assistantMessage = {
    role: 'assistant',
    content: '',
    isLoading: true,
  }

  messages.value.push(assistantMessage)
  const currentMessageIndex = messages.value.length - 1

  userInput.value = ''
  isLoading.value = true

  try {
    // 调用后端AI接口
    const token = useMemberStore().profile?.token || ''

    // 使用uni.request替代fetch以更好地兼容UniApp
    uni.request({
      url: '/ai/chat',
      method: 'POST',
      header: {
        'Content-Type': 'application/json',
        Authorization: token,
      },
      data: {
        message: userMessage.content,
        memoryId: memoryId.value,
      },
      success: (res) => {
        messages.value[currentMessageIndex].content = res.data
        messages.value[currentMessageIndex].isLoading = false
      },
      fail: (err) => {
        messages.value[currentMessageIndex].content = '抱歉，请求过程中出现错误'
        messages.value[currentMessageIndex].isLoading = false
      },
      complete: () => {
        isLoading.value = false
        // 滚动到底部
        nextTick(() => {
          if (scrollView.value) {
            uni
              .createSelectorQuery()
              .select('.chat-content')
              .boundingClientRect()
              .select('.chat-messages')
              .boundingClientRect()
              .exec((res) => {
                if (res[1] && res[0]) {
                  const scrollTop = res[1].height - res[0].height + 20
                  uni.pageScrollTo({
                    scrollTop: scrollTop > 0 ? scrollTop : 0,
                    duration: 300,
                  })
                }
              })
          }
        })
      },
    })
  } catch (error) {
    console.error('请求出错:', error)
    messages.value[currentMessageIndex].content = '抱歉，请求过程中出现错误'
    messages.value[currentMessageIndex].isLoading = false
    isLoading.value = false
  }
}

// 处理输入框焦点
const handleInputFocus = () => {
  // 检查用户状态
  checkUserStatus()
  inputFocused.value = true
}

const handleInputBlur = () => {
  inputFocused.value = false
}

// 去登录
const goToLogin = () => {
  uni.navigateTo({
    url: '/pages/login/login',
  })
}

// 去开通会员
const goToVip = () => {
  uni.navigateTo({
    url: '/pages/vip/vip',
  })
}

// 初始化
onMounted(async () => {
  // 检查用户状态
  await checkUserStatus()

  messages.value.push({
    role: 'assistant',
    content: '你好！我是驾考通AI助手，有什么可以帮助你的吗？',
  })
})
</script>

<template>
  <view class="page">
    <view class="page-toolbar">
      <text class="toolbar-action" @click="startNewConversation">新对话</text>
    </view>

    <!-- 聊天内容区域 -->
    <scroll-view class="chat-content" scroll-y :ref="scrollView" :scroll-with-animation="true">
      <view class="chat-messages">
        <view
          v-for="(msg, idx) in messages"
          :key="idx"
          class="message-wrapper"
          :class="msg.role === 'user' ? 'user-wrapper' : 'assistant-wrapper'"
        >
          <view class="message" :class="msg.role === 'user' ? 'user-message' : 'assistant-message'">
            <text class="message-content">{{ msg.content }}</text>
            <text v-if="msg.isLoading" class="loading-dots">▍</text>
          </view>
        </view>
      </view>
    </scroll-view>

    <!-- 输入区域 -->
    <view class="input-container" :class="{ 'input-focused': inputFocused }">
      <view class="input-wrapper">
        <textarea
          v-model="userInput"
          class="message-input"
          :disabled="isLoading || showLoginOverlay || showVipOverlay"
          placeholder="请输入您的问题..."
          @focus="handleInputFocus"
          @blur="handleInputBlur"
          auto-height
          maxlength="500"
        />
        <button
          class="send-button"
          @click="sendMessage"
          :disabled="!userInput.trim() || isLoading || showLoginOverlay || showVipOverlay"
          :class="{
            'send-disabled': !userInput.trim() || isLoading || showLoginOverlay || showVipOverlay,
          }"
        >
          <text v-if="!isLoading">发送</text>
          <text v-else class="loading-text">...</text>
        </button>
      </view>

      <!-- 未登录提示 -->
      <view v-if="showLoginOverlay" class="overlay-container">
        <view class="overlay-content">
          <text class="overlay-text">登录后即可使用AI助手功能</text>
          <button class="overlay-button small-button" @click="goToLogin">去登录</button>
        </view>
      </view>

      <!-- 非会员提示 -->
      <view v-if="showVipOverlay" class="overlay-container">
        <view class="overlay-content">
          <text class="overlay-text">开通会员即可使用AI助手功能</text>
          <button class="overlay-button small-button" @click="goToVip">去开通</button>
        </view>
      </view>
    </view>
  </view>
</template>

<style lang="scss" scoped>
.page {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background-color: #f5f5f5;
  padding-top: calc(var(--status-bar-height) + 44px);
  padding-bottom: 0;
}

/* 顶部导航栏 */
.header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  height: 44px;
  background: linear-gradient(135deg, #0f766e 0%, #115e59 100%);
  color: white;
  z-index: 1000;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 100%;
  padding: 0 15px;
}

.header-title {
  font-size: 18px;
  font-weight: 600;
}

.header-actions {
  display: flex;
  align-items: center;
}

.action-icon {
  font-size: 20px;
  padding: 8px;
  border-radius: 50%;
  transition: background-color 0.3s;
}

.action-icon:active {
  background-color: rgba(255, 255, 255, 0.2);
}

/* 聊天内容区域 */
.chat-content {
  flex: 1;
  padding: 15px;
  overflow-y: auto;
}

.chat-messages {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.message-wrapper {
  display: flex;
  width: 100%;
}

.user-wrapper {
  justify-content: flex-end;
}

.assistant-wrapper {
  justify-content: flex-start;
}

.message {
  max-width: 80%;
  padding: 12px 16px;
  border-radius: 18px;
  font-size: 16px;
  line-height: 1.5;
  position: relative;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.05);
}

.user-message {
  background: linear-gradient(135deg, #0f766e 0%, #115e59 100%);
  color: white;
  border-bottom-right-radius: 4px;
}

.assistant-message {
  background: white;
  color: #333;
  border-bottom-left-radius: 4px;
}

.message-content {
  display: inline;
  word-wrap: break-word;
  white-space: pre-wrap;
}

.loading-dots {
  display: inline-block;
  margin-left: 5px;
  animation: blink 1s infinite;
}

@keyframes blink {
  0%,
  100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

/* 输入区域 */
.input-container {
  background: white;
  padding: 10px 15px;
  border-top: 1px solid #e0e0e0;
  transition: all 0.3s ease;
  position: relative;
}

.input-wrapper {
  display: flex;
  align-items: flex-end;
  gap: 10px;
  background: #f5f5f5;
  border-radius: 20px;
  padding: 8px 12px;
}

.message-input {
  flex: 1;
  min-height: 24px;
  max-height: 120px;
  padding: 8px 0;
  font-size: 16px;
  background: transparent;
  border: none;
  outline: none;
  resize: none;
}

.send-button {
  background: linear-gradient(135deg, #0f766e 0%, #115e59 100%);
  color: white;
  border: none;
  border-radius: 16px;
  padding: 6px 16px;
  font-size: 14px;
  font-weight: 500;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
}

.send-button:active {
  transform: scale(0.95);
}

.send-disabled {
  opacity: 0.6;
  transform: none !important;
}

.loading-text {
  animation: pulse 1.5s infinite;
}

@keyframes pulse {
  0%,
  100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

/* 覆盖层容器 */
.overlay-container {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
  border-radius: 20px;
  pointer-events: none; /* 允许点击穿透到输入框 */
}

.overlay-content {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 0 15px;
  pointer-events: auto; /* 恢复按钮的点击事件 */
}

.overlay-text {
  font-size: 14px;
  color: #666;
}

.overlay-button {
  background: linear-gradient(135deg, #0f766e 0%, #115e59 100%);
  color: white;
  border: none;
  border-radius: 16px;
  padding: 6px 16px;
  font-size: 14px;
  font-weight: 500;
  height: 32px; /* 与输入框高度一致 */
  display: flex;
  align-items: center;
  justify-content: center;
  white-space: nowrap;
}

.small-button {
  padding: 4px 12px;
  font-size: 13px;
  height: auto;
  min-height: 30px;
}

/* 响应式调整 */
@media (max-width: 375px) {
  .message {
    max-width: 85%;
  }

  .header-title {
    font-size: 16px;
  }
}

@media (min-width: 414px) {
  .message {
    max-width: 75%;
  }
}
</style>
