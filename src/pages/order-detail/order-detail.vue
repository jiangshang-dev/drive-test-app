<template>
  <view class="container">
    <!-- 订单状态 -->
    <view class="status-section">
      <view class="status-content">
        <text class="status-icon">{{ getStatusIcon(orderInfo.status) }}</text>
        <view class="status-info">
          <text class="status-title">{{ orderInfo.statusText }}</text>
          <text class="status-desc">{{ getStatusDescription(orderInfo.status) }}</text>
        </view>
      </view>
    </view>

    <!-- 商品信息 -->
    <view class="product-section">
      <view class="section-header">
        <text class="section-title">商品信息</text>
      </view>
      <view class="product-detail">
        <view class="product-icon">
          <text class="icon">👑</text>
        </view>
        <view class="product-info">
          <text class="product-name">{{ orderInfo.productName }}</text>
          <text class="product-desc">{{ orderInfo.productDesc }}</text>
          <text class="product-spec">规格：3个月有效期</text>
        </view>
        <view class="product-price">
          <text class="price-symbol">¥</text>
          <text class="price-amount">{{ orderInfo.price }}</text>
        </view>
      </view>
    </view>

    <!-- 订单进度 -->
    <view class="progress-section">
      <view class="section-header">
        <text class="section-title">订单进度</text>
      </view>
      <view class="progress-timeline">
        <view
          v-for="(step, index) in orderSteps"
          :key="index"
          class="timeline-step"
          :class="{ active: step.active, completed: step.completed }"
        >
          <view class="step-dot"></view>
          <view class="step-content">
            <text class="step-title">{{ step.title }}</text>
            <text v-if="step.time" class="step-time">{{ step.time }}</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 订单信息 -->
    <view class="order-section">
      <view class="section-header">
        <text class="section-title">订单信息</text>
      </view>
      <view class="order-details">
        <view class="detail-row">
          <text class="detail-label">订单号</text>
          <text class="detail-value">{{ orderInfo.orderId }}</text>
        </view>
        <view class="detail-row">
          <text class="detail-label">创建时间</text>
          <text class="detail-value">{{ formatTime(orderInfo.createTime) }}</text>
        </view>
        <view v-if="orderInfo.payTime" class="detail-row">
          <text class="detail-label">支付时间</text>
          <text class="detail-value">{{ formatTime(orderInfo.payTime) }}</text>
        </view>
        <view class="detail-row">
          <text class="detail-label">支付方式</text>
          <text class="detail-value">{{ orderInfo.paymentMethod }}</text>
        </view>
      </view>
    </view>

    <!-- 费用详情 -->
    <view class="cost-section">
      <view class="section-header">
        <text class="section-title">费用详情</text>
      </view>
      <view class="cost-details">
        <view class="cost-row">
          <text class="cost-label">商品金额</text>
          <text class="cost-value">¥{{ orderInfo.price }}</text>
        </view>
        <view v-if="orderInfo.discount > 0" class="cost-row">
          <text class="cost-label">优惠金额</text>
          <text class="cost-value discount">-¥{{ orderInfo.discount }}</text>
        </view>
        <view class="cost-row total">
          <text class="cost-label">实付金额</text>
          <text class="cost-value">¥{{ orderInfo.actualPrice || orderInfo.price }}</text>
        </view>
      </view>
    </view>

    <!-- 操作按钮 -->
    <view class="action-section">
      <button
        v-for="(action, index) in orderActions"
        :key="index"
        class="action-btn"
        :class="action.type"
        @click="handleAction(action)"
      >
        {{ action.text }}
      </button>
    </view>

    <!-- 客服联系 -->
    <view class="contact-section">
      <view class="contact-item" @click="contactService">
        <text class="contact-icon">💬</text>
        <text class="contact-text">遇到问题？联系客服</text>
        <text class="contact-arrow">›</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'

// 订单信息
const orderInfo = ref({
  orderId: '',
  productName: '',
  productDesc: '',
  price: 0,
  actualPrice: 0,
  discount: 0,
  status: '',
  statusText: '',
  paymentMethod: '',
  createTime: '',
  payTime: ''
})

// 订单步骤
const orderSteps = ref([
  { title: '订单创建', completed: false, active: false, time: '' },
  { title: '等待支付', completed: false, active: false, time: '' },
  { title: '支付成功', completed: false, active: false, time: '' },
  { title: '服务开通', completed: false, active: false, time: '' }
])

// 订单操作
const orderActions = ref([])

// 计算属性
const getStatusIcon = (status: string) => {
  const icons = {
    pending: '⏳',
    paid: '✅',
    completed: '🎉',
    cancelled: '❌'
  }
  return icons[status] || '📋'
}

const getStatusDescription = (status: string) => {
  const descriptions = {
    pending: '请在30分钟内完成支付',
    paid: '支付成功，正在开通服务',
    completed: 'VIP权益已激活，享受专属特权',
    cancelled: '订单已取消，如有疑问请联系客服'
  }
  return descriptions[status] || '订单状态异常'
}

// 方法
const goBack = () => {
  uni.navigateBack()
}

const formatTime = (timeStr: string) => {
  if (!timeStr) return ''
  const date = new Date(timeStr)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  })
}

const updateOrderSteps = (status: string, createTime: string, payTime: string) => {
  const createTimeFormatted = formatTime(createTime)
  const payTimeFormatted = formatTime(payTime)

  switch (status) {
    case 'pending':
      orderSteps.value = [
        { title: '订单创建', completed: true, active: false, time: createTimeFormatted },
        { title: '等待支付', completed: false, active: true, time: '' },
        { title: '支付成功', completed: false, active: false, time: '' },
        { title: '服务开通', completed: false, active: false, time: '' }
      ]
      orderActions.value = [
        { text: '立即支付', type: 'primary', action: 'pay' },
        { text: '取消订单', type: 'secondary', action: 'cancel' }
      ]
      break
    case 'paid':
      orderSteps.value = [
        { title: '订单创建', completed: true, active: false, time: createTimeFormatted },
        { title: '等待支付', completed: true, active: false, time: createTimeFormatted },
        { title: '支付成功', completed: true, active: true, time: payTimeFormatted },
        { title: '服务开通', completed: false, active: false, time: '' }
      ]
      orderActions.value = [
        { text: '申请退款', type: 'secondary', action: 'refund' }
      ]
      break
    case 'completed':
      const completedTime = payTime ? formatTime(new Date(new Date(payTime).getTime() + 15000).toISOString()) : ''
      orderSteps.value = [
        { title: '订单创建', completed: true, active: false, time: createTimeFormatted },
        { title: '等待支付', completed: true, active: false, time: createTimeFormatted },
        { title: '支付成功', completed: true, active: false, time: payTimeFormatted },
        { title: '服务开通', completed: true, active: true, time: completedTime }
      ]
      orderActions.value = [
        { text: '申请退款', type: 'secondary', action: 'refund' }
      ]
      break
    case 'cancelled':
      orderSteps.value = [
        { title: '订单创建', completed: true, active: false, time: createTimeFormatted },
        { title: '订单取消', completed: true, active: true, time: createTimeFormatted }
      ]
      orderActions.value = []
      break
    default:
      orderActions.value = []
  }
}

const handleAction = (action: any) => {
  console.log('执行操作:', action.action)

  switch (action.action) {
    case 'pay':
      // 跳转到支付页面
      uni.navigateTo({
        url: `/pages/payment/payment?orderId=${orderInfo.value.orderId}&planTitle=${orderInfo.value.productName}&planPrice=${orderInfo.value.price}`
      })
      break
    case 'cancel':
      // 取消订单
      uni.showModal({
        title: '确认取消',
        content: '确定要取消这个订单吗？',
        success: (res) => {
          if (res.confirm) {
            uni.showToast({
              title: '订单已取消',
              icon: 'success'
            })
            setTimeout(() => {
              uni.navigateBack()
            }, 1500)
          }
        }
      })
      break
    case 'refund':
      // 申请退款
      uni.showModal({
        title: '申请退款',
        content: '确定要申请退款吗？退款将在3-5个工作日内到账。',
        success: (res) => {
          if (res.confirm) {
            uni.showToast({
              title: '退款申请已提交',
              icon: 'success'
            })
          }
        }
      })
      break
    default:
      uni.showToast({
        title: '功能开发中',
        icon: 'none'
      })
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

onMounted(() => {
  // 获取页面参数
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.options || {}

  // 解析订单信息
  orderInfo.value = {
    orderId: decodeURIComponent(options.orderId || ''),
    productName: decodeURIComponent(options.productName || 'VIP会员'),
    productDesc: decodeURIComponent(options.productDesc || 'VIP会员套餐'),
    price: parseFloat(options.price || '0'),
    actualPrice: parseFloat(options.actualPrice || options.price || '0'),
    discount: parseFloat(options.discount || '0'),
    status: decodeURIComponent(options.status || 'completed'),
    statusText: decodeURIComponent(options.statusText || '已完成'),
    paymentMethod: decodeURIComponent(options.paymentMethod || '微信支付'),
    createTime: options.createTime ? decodeURIComponent(options.createTime) : new Date().toISOString(),
    payTime: options.payTime ? decodeURIComponent(options.payTime) : ''
  }

  // 更新订单步骤
  updateOrderSteps(orderInfo.value.status, orderInfo.value.createTime, orderInfo.value.payTime)

  console.log('订单详情页面加载完成', orderInfo.value)
})
</script>

<style lang="scss" scoped>
.container {
  min-height: 100vh;
  background-color: #f5f5f5;
  padding-bottom: 20px;
}

/* 顶部导航栏 */
.header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 8px 0;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  padding-top: calc(8px + 14px);
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;
}

.back-btn {
  font-size: 24px;
  font-weight: bold;
  cursor: pointer;
  width: 30px;
}

.logo {
  font-size: 18px;
  font-weight: bold;
  flex: 1;
  text-align: center;
}

.header-right {
  width: 30px;
}

/* 订单状态 */
.status-section {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  margin-top: 0px;
  padding: 30px 20px;
  color: white;
}

.status-content {
  display: flex;
  align-items: center;
  gap: 20px;
}

.status-icon {
  font-size: 48px;
}

.status-info {
  display: flex;
  flex-direction: column;
}

.status-title {
  font-size: 24px;
  font-weight: bold;
  margin-bottom: 8px;
}

.status-desc {
  font-size: 14px;
  opacity: 0.9;
}

/* 通用卡片样式 */
.product-section,
.progress-section,
.order-section,
.cost-section {
  background: white;
  margin: 20px;
  border-radius: 15px;
  padding: 20px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
}

.section-header {
  margin-bottom: 20px;
  padding-bottom: 10px;
  border-bottom: 1px solid #f0f0f0;
}

.section-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
}

/* 商品信息 */
.product-detail {
  display: flex;
  align-items: center;
  gap: 15px;
}

.product-icon {
  width: 60px;
  height: 60px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.icon {
  font-size: 28px;
  color: white;
}

.product-info {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.product-name {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 4px;
}

.product-desc {
  font-size: 13px;
  color: #666;
  margin-bottom: 2px;
}

.product-spec {
  font-size: 12px;
  color: #999;
}

.product-price {
  display: flex;
  align-items: baseline;
}

.price-symbol {
  font-size: 14px;
  color: #667eea;
  font-weight: bold;
}

.price-amount {
  font-size: 20px;
  font-weight: bold;
  color: #667eea;
  margin-left: 2px;
}

/* 订单进度 */
.progress-timeline {
  display: flex;
  flex-direction: column;
  position: relative;
}

.progress-timeline::before {
  content: '';
  position: absolute;
  left: 8px;
  top: 20px;
  bottom: 20px;
  width: 2px;
  background: #e9ecef;
}

.timeline-step {
  display: flex;
  align-items: flex-start;
  margin-bottom: 20px;
  position: relative;
}

.timeline-step:last-child {
  margin-bottom: 0;
}

.step-dot {
  width: 16px;
  height: 16px;
  border-radius: 50%;
  background: #e9ecef;
  margin-right: 15px;
  margin-top: 2px;
  position: relative;
  z-index: 1;
}

.timeline-step.completed .step-dot {
  background: #4caf50;
}

.timeline-step.active .step-dot {
  background: #667eea;
  animation: pulse 2s infinite;
}

.step-content {
  display: flex;
  flex-direction: column;
  flex: 1;
}

.step-title {
  font-size: 14px;
  font-weight: bold;
  color: #333;
  margin-bottom: 2px;
}

.timeline-step.completed .step-title {
  color: #4caf50;
}

.timeline-step.active .step-title {
  color: #667eea;
}

.step-time {
  font-size: 12px;
  color: #999;
}

/* 订单信息和费用详情 */
.order-details,
.cost-details {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.detail-row,
.cost-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.detail-label,
.cost-label {
  font-size: 14px;
  color: #666;
}

.detail-value,
.cost-value {
  font-size: 14px;
  color: #333;
}

.cost-value.discount {
  color: #ff6b6b;
}

.cost-row.total {
  font-weight: bold;
  font-size: 16px;
  border-top: 1px solid #eee;
  padding-top: 12px;
  margin-top: 8px;
}

.cost-row.total .cost-value {
  color: #667eea;
}

/* 操作按钮 */
.action-section {
  display: flex;
  gap: 15px;
  padding: 20px;
}

.action-btn {
  flex: 1;
  padding: 14px;
  border-radius: 25px;
  font-size: 16px;
  font-weight: bold;
  border: none;
  cursor: pointer;
  transition: all 0.3s ease;
}

.action-btn.primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.action-btn.secondary {
  background: #f8f9fa;
  color: #666;
  border: 1px solid #eee;
}

.action-btn:hover {
  transform: translateY(-2px);
}

/* 客服联系 */
.contact-section {
  background: white;
  margin: 0 20px 20px;
  border-radius: 15px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.contact-item {
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.contact-item:hover {
  background: #f8f9fa;
}

.contact-icon {
  font-size: 24px;
  color: #667eea;
}

.contact-text {
  flex: 1;
  font-size: 16px;
  color: #333;
}

.contact-arrow {
  font-size: 20px;
  color: #999;
  font-weight: bold;
}

/* 动画效果 */
@keyframes pulse {
  0% {
    transform: scale(1);
    box-shadow: 0 0 0 0 rgba(102, 126, 234, 0.7);
  }
  70% {
    transform: scale(1.1);
    box-shadow: 0 0 0 10px rgba(102, 126, 234, 0);
  }
  100% {
    transform: scale(1);
    box-shadow: 0 0 0 0 rgba(102, 126, 234, 0);
  }
}
</style>
