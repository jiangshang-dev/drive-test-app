<template>
  <view class="container">
    <!-- 成功动画区域 -->
    <view class="success-hero">
      <view class="success-animation">
        <text class="success-icon">✅</text>
        <view class="success-ripple"></view>
      </view>
      <text class="success-title">支付成功！</text>
      <text class="success-subtitle">恭喜您成为VIP会员</text>
    </view>

    <!-- 订单详情 -->
    <view class="order-details">
      <view class="detail-header">
        <text class="detail-title">订单详情</text>
        <text class="order-status success">已完成</text>
      </view>

      <view class="detail-item">
        <text class="detail-label">订单号</text>
        <text class="detail-value">{{ orderInfo.orderId }}</text>
      </view>

      <view class="detail-item">
        <text class="detail-label">商品名称</text>
        <text class="detail-value">{{ orderInfo.planTitle }}</text>
      </view>

      <view class="detail-item">
        <text class="detail-label">支付方式</text>
        <text class="detail-value">{{ orderInfo.paymentMethod }}</text>
      </view>

      <view class="detail-item">
        <text class="detail-label">支付时间</text>
        <text class="detail-value">{{ paymentTime }}</text>
      </view>

      <view class="detail-item total">
        <text class="detail-label">实付金额</text>
        <text class="detail-value price">¥{{ orderInfo.planPrice }}</text>
      </view>

      <view v-if="orderInfo.discount > 0" class="detail-item discount">
        <text class="detail-label">优惠金额</text>
        <text class="detail-value">-¥{{ orderInfo.discount }}</text>
      </view>
    </view>

    <!-- VIP权益提醒 -->
    <view class="vip-benefits">
      <view class="benefits-header">
        <text class="benefits-icon">👑</text>
        <text class="benefits-title">您的VIP权益已激活</text>
      </view>

      <view class="benefits-list">
        <view
          v-for="(benefit, index) in vipBenefits"
          :key="index"
          class="benefit-item"
        >
          <text class="benefit-icon">{{ benefit.icon }}</text>
          <view class="benefit-content">
            <text class="benefit-title">{{ benefit.title }}</text>
            <text class="benefit-desc">{{ benefit.description }}</text>
          </view>
          <text class="benefit-status">已开通</text>
        </view>
      </view>
    </view>

    <!-- 推荐功能 */
    <view class="recommendations">
      <text class="rec-title">推荐您立即体验</text>
      <view class="rec-list">
        <view
          v-for="(rec, index) in recommendations"
          :key="index"
          class="rec-item"
          @click="goToFeature(rec.url)"
        >
          <view class="rec-icon">
            <text class="icon">{{ rec.icon }}</text>
          </view>
          <view class="rec-content">
            <text class="rec-name">{{ rec.name }}</text>
            <text class="rec-desc">{{ rec.description }}</text>
          </view>
          <text class="rec-arrow">›</text>
        </view>
      </view>
    </view>

    <!-- 操作按钮 */
    <view class="action-buttons">
      <button class="secondary-btn" @click="goToHome">
        返回首页
      </button>
      <button class="primary-btn" @click="startLearning">
        立即学习
      </button>
    </view>

    <!-- 客服联系 -->
    <view class="contact-section">
      <text class="contact-text">如有问题，请联系客服</text>
      <view class="contact-methods">
        <view class="contact-item" @click="contactService">
          <text class="contact-icon">💬</text>
          <text class="contact-label">在线客服</text>
        </view>
        <view class="contact-item" @click="callService">
          <text class="contact-icon">📞</text>
          <text class="contact-label">电话客服</text>
        </view>
      </view>
    </view>

    <!-- 发票/收据 -->
    <view class="invoice-section">
      <view class="invoice-item" @click="downloadReceipt">
        <text class="invoice-icon">📄</text>
        <text class="invoice-text">下载电子收据</text>
        <text class="invoice-arrow">›</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'

// 数据状态
const orderInfo = ref({
  orderId: '',
  planTitle: '',
  planPrice: 0,
  paymentMethod: '',
  discount: 0
})

// VIP权益列表
const vipBenefits = ref([
  {
    icon: '🎬',
    title: '全部视频解锁',
    description: '畅享所有交规视频教程'
  },
  {
    icon: '📚',
    title: '题库完整开放',
    description: '刷遍所有驾考题目'
  },
  {
    icon: '🚫',
    title: '无广告体验',
    description: '纯净学习环境'
  },
  {
    icon: '📊',
    title: '学习数据分析',
    description: '详细掌握学习进度'
  }
])

// 推荐功能
const recommendations = ref([
  {
    icon: '🎥',
    name: '交规视频',
    description: '观看最新交规视频教程',
    url: '/pages/videos/videos'
  },
  {
    icon: '📝',
    name: '开始刷题',
    description: '练习最新题库',
    url: '/pages/index/sequential/sequential'
  },
  {
    icon: '🏆',
    name: '模拟考试',
    description: '检验学习成果',
    url: '/pages/index/exam/exam'
  }
])

// 计算属性
const paymentTime = computed(() => {
  return new Date().toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  })
})

// 方法
const goToHome = () => {
  uni.switchTab({
    url: '/pages/index/index',
    success: () => {
      console.log('返回首页成功')
    }
  })
}

const startLearning = () => {
  uni.switchTab({
    url: '/pages/index/index',
    success: () => {
      console.log('开始学习')
      // 可以添加一些引导用户的逻辑
      setTimeout(() => {
        uni.showToast({
          title: 'VIP权益已激活，开始学习吧！',
          icon: 'success',
          duration: 2000
        })
      }, 500)
    }
  })
}

const goToFeature = (url: string) => {
  if (url.includes('index')) {
    uni.switchTab({ url })
  } else {
    uni.navigateTo({ url })
  }
}

const contactService = () => {
  uni.showModal({
    title: '联系客服',
    content: '客服工作时间：9:00-18:00\n我们会尽快为您解答问题',
    confirmText: '我知道了',
    showCancel: false
  })
}

const callService = () => {
  uni.showModal({
    title: '客服电话',
    content: '400-888-9999\n工作时间：9:00-18:00',
    confirmText: '拨打电话',
    cancelText: '取消',
    success: (res) => {
      if (res.confirm) {
        uni.makePhoneCall({
          phoneNumber: '400-888-9999',
          fail: () => {
            uni.showToast({
              title: '拨打失败',
              icon: 'error'
            })
          }
        })
      }
    }
  })
}

const downloadReceipt = () => {
  uni.showToast({
    title: '收据下载功能开发中',
    icon: 'none'
  })
}

onMounted(() => {
  // 获取页面参数
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.options || {}

  orderInfo.value = {
    orderId: options.orderId || `VIP${Date.now()}`,
    planTitle: options.planTitle || 'VIP会员',
    planPrice: parseFloat(options.planPrice || '39'),
    paymentMethod: options.paymentMethod || '微信支付',
    discount: parseFloat(options.discount || '0')
  }

  // 播放成功音效（如果需要）
  // uni.playBackgroundAudio()

  console.log('支付成功页面加载完成', orderInfo.value)
})
</script>

<style lang="scss" scoped>
.container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 40px 20px 20px;
}

/* 成功动画区域 */
.success-hero {
  text-align: center;
  padding: 40px 0;
  color: white;
}

.success-animation {
  position: relative;
  display: inline-block;
  margin-bottom: 30px;
}

.success-icon {
  font-size: 80px;
  display: block;
  animation: bounceIn 0.8s ease-out;
}

.success-ripple {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 120px;
  height: 120px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 50%;
  animation: ripple 2s infinite;
}

.success-title {
  font-size: 28px;
  font-weight: bold;
  margin-bottom: 8px;
  display: block;
}

.success-subtitle {
  font-size: 16px;
  opacity: 0.9;
}

/* 订单详情 */
.order-details {
  background: white;
  border-radius: 20px;
  padding: 25px;
  margin-bottom: 20px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 1px solid #eee;
}

.detail-title {
  font-size: 18px;
  font-weight: bold;
  color: #333;
}

.order-status {
  padding: 6px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: bold;
}

.order-status.success {
  background: #e8f5e8;
  color: #4caf50;
}

.detail-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
  border-bottom: 1px solid #f0f0f0;
}

.detail-item:last-child {
  border-bottom: none;
}

.detail-item.total {
  font-weight: bold;
  font-size: 16px;
  background: #f8f9ff;
  margin: 10px -25px -25px;
  padding: 20px 25px;
  border-radius: 0 0 20px 20px;
}

.detail-item.discount {
  color: #ff6b6b;
}

.detail-label {
  color: #666;
  font-size: 14px;
}

.detail-value {
  color: #333;
  font-size: 14px;
}

.detail-value.price {
  color: #667eea;
  font-size: 18px;
  font-weight: bold;
}

/* VIP权益 */
.vip-benefits {
  background: white;
  border-radius: 20px;
  padding: 25px;
  margin-bottom: 20px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.benefits-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 20px;
}

.benefits-icon {
  font-size: 24px;
}

.benefits-title {
  font-size: 18px;
  font-weight: bold;
  color: #333;
}

.benefits-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.benefit-item {
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 15px;
  background: #f8f9ff;
  border-radius: 12px;
  border-left: 4px solid #667eea;
}

.benefit-icon {
  font-size: 24px;
}

.benefit-content {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.benefit-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 4px;
}

.benefit-desc {
  font-size: 13px;
  color: #666;
}

.benefit-status {
  background: #4caf50;
  color: white;
  font-size: 11px;
  padding: 4px 8px;
  border-radius: 8px;
  font-weight: bold;
}

/* 推荐功能 */
.recommendations {
  background: white;
  border-radius: 20px;
  padding: 25px;
  margin-bottom: 20px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.rec-title {
  font-size: 18px;
  font-weight: bold;
  color: #333;
  margin-bottom: 20px;
  display: block;
}

.rec-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.rec-item {
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.rec-item:hover {
  background: #f0f0f0;
  transform: translateX(5px);
}

.rec-icon {
  width: 50px;
  height: 50px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 25px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.icon {
  font-size: 24px;
  color: white;
}

.rec-content {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.rec-name {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 4px;
}

.rec-desc {
  font-size: 13px;
  color: #666;
}

.rec-arrow {
  font-size: 20px;
  color: #999;
  font-weight: bold;
}

/* 操作按钮 */
.action-buttons {
  display: flex;
  gap: 15px;
  margin-bottom: 30px;
}

.secondary-btn,
.primary-btn {
  flex: 1;
  padding: 16px;
  border-radius: 25px;
  font-size: 16px;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
  border: none;
}

.secondary-btn {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: 2px solid rgba(255, 255, 255, 0.3);
}

.primary-btn {
  background: linear-gradient(135deg, #ffd700 0%, #ffa500 100%);
  color: white;
}

.secondary-btn:hover,
.primary-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
}

/* 客服联系 */
.contact-section {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 15px;
  padding: 20px;
  margin-bottom: 20px;
  text-align: center;
}

.contact-text {
  color: rgba(255, 255, 255, 0.9);
  font-size: 14px;
  margin-bottom: 15px;
  display: block;
}

.contact-methods {
  display: flex;
  gap: 20px;
  justify-content: center;
}

.contact-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  padding: 10px;
  border-radius: 10px;
}

.contact-item:hover {
  background: rgba(255, 255, 255, 0.1);
}

.contact-icon {
  font-size: 24px;
}

.contact-label {
  color: rgba(255, 255, 255, 0.9);
  font-size: 13px;
}

/* 发票收据 */
.invoice-section {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 15px;
  overflow: hidden;
}

.invoice-item {
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.invoice-item:hover {
  background: rgba(255, 255, 255, 0.1);
}

.invoice-icon {
  font-size: 24px;
  color: rgba(255, 255, 255, 0.9);
}

.invoice-text {
  flex: 1;
  color: rgba(255, 255, 255, 0.9);
  font-size: 14px;
}

.invoice-arrow {
  font-size: 20px;
  color: rgba(255, 255, 255, 0.6);
  font-weight: bold;
}

/* 动画效果 */
@keyframes bounceIn {
  0% {
    transform: scale(0.3);
    opacity: 0;
  }
  50% {
    transform: scale(1.05);
  }
  70% {
    transform: scale(0.9);
  }
  100% {
    transform: scale(1);
    opacity: 1;
  }
}

@keyframes ripple {
  0% {
    transform: translate(-50%, -50%) scale(0.8);
    opacity: 1;
  }
  100% {
    transform: translate(-50%, -50%) scale(1.5);
    opacity: 0;
  }
}
</style>
