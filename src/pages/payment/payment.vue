<template>
  <view class="container">
    <!-- 顶部导航栏 -->
    <view class="header">
      <view class="header-content">
        <text class="logo">确认支付</text>
      </view>
    </view>

    <!-- 订单信息 -->
    <view class="order-section">
      <view class="order-header">
        <text class="order-title">订单信息</text>
      </view>

      <view class="order-item">
        <view class="item-icon">
          <text class="icon">👑</text>
        </view>
        <view class="item-info">
          <text class="item-name">{{ orderInfo.planTitle }}</text>
          <text class="item-desc">VIP会员{{ orderInfo.planUnit }}</text>
          <view class="item-features">
            <text
              v-for="(feature, index) in orderFeatures"
              :key="index"
              class="feature-tag"
            >
              {{ feature }}
            </text>
          </view>
        </view>
        <view class="item-price">
          <text class="price-symbol">¥</text>
          <text class="price-amount">{{ orderInfo.planPrice }}</text>
        </view>
      </view>

      <view class="order-summary">
        <view class="summary-row">
          <text class="summary-label">商品金额</text>
          <text class="summary-value">¥{{ orderInfo.planPrice }}</text>
        </view>
        <view class="summary-row">
          <text class="summary-label">优惠金额</text>
          <text class="summary-value discount">-¥{{ discount }}</text>
        </view>
        <view class="summary-row total">
          <text class="summary-label">实付金额</text>
          <text class="summary-value">¥{{ finalPrice }}</text>
        </view>
      </view>
    </view>

    <!-- 支付方式 -->
    <view class="payment-section">
      <view class="payment-header">
        <text class="payment-title">选择支付方式</text>
      </view>

      <view class="payment-methods">
        <view
          v-for="(method, index) in paymentMethods"
          :key="index"
          class="payment-method"
          :class="{ active: selectedPayment === index }"
          @click="selectPayment(index)"
        >
          <view class="method-icon">
            <text class="icon">{{ method.icon }}</text>
          </view>
          <view class="method-info">
            <text class="method-name">{{ method.name }}</text>
            <text class="method-desc">{{ method.description }}</text>
          </view>
          <view class="method-radio">
            <text class="radio" :class="{ checked: selectedPayment === index }">
              {{ selectedPayment === index ? '●' : '○' }}
            </text>
          </view>
        </view>
      </view>
    </view>

    <!-- 安全保障 */
    <view class="security-section">
      <view class="security-item">
        <text class="security-icon">🔒</text>
        <text class="security-text">支付安全保障，7天无理由退款</text>
      </view>
      <view class="security-item">
        <text class="security-icon">⚡</text>
        <text class="security-text">开通后立即生效，无需等待</text>
      </view>
    </view>

    <!-- 优惠券选择 -->
    <view class="coupon-section" @click="showCouponModal = true">
      <view class="coupon-content">
        <text class="coupon-icon">🎫</text>
        <view class="coupon-info">
          <text class="coupon-title">优惠券</text>
          <text class="coupon-desc">
            {{ selectedCoupon ? `已选择: ${selectedCoupon.name}` : '选择可用优惠券' }}
          </text>
        </view>
        <text class="coupon-arrow">›</text>
      </view>
    </view>

    <!-- 立即支付按钮 -->
    <view class="action-section">
      <button class="pay-btn" @click="processPay">
        立即支付 ¥{{ finalPrice }}
      </button>
      <text class="pay-note">点击支付即表示同意相关协议</text>
    </view>

    <!-- 优惠券弹窗 -->
    <view v-if="showCouponModal" class="modal" @click="closeCouponModal">
      <view class="modal-content" @click.stop>
        <view class="modal-header">
          <text class="modal-title">选择优惠券</text>
          <text class="close-btn" @click="closeCouponModal">&times;</text>
        </view>
        <view class="modal-body">
          <view class="coupon-list">
            <view
              v-for="(coupon, index) in availableCoupons"
              :key="index"
              class="coupon-item"
              :class="{ selected: selectedCouponIndex === index }"
              @click="selectCoupon(index)"
            >
              <view class="coupon-left">
                <text class="coupon-amount">¥{{ coupon.amount }}</text>
                <text class="coupon-condition">{{ coupon.condition }}</text>
              </view>
              <view class="coupon-right">
                <text class="coupon-name">{{ coupon.name }}</text>
                <text class="coupon-expire">有效期至: {{ coupon.expireDate }}</text>
              </view>
            </view>

            <view
              class="coupon-item no-coupon"
              :class="{ selected: selectedCouponIndex === -1 }"
              @click="selectCoupon(-1)"
            >
              <text class="no-coupon-text">不使用优惠券</text>
            </view>
          </view>

          <button class="confirm-coupon-btn" @click="confirmCoupon">
            确定
          </button>
        </view>
      </view>
    </view>

    <!-- 支付加载 -->
    <view v-if="showPaymentLoading" class="payment-loading">
      <view class="loading-content">
        <text class="loading-icon">💳</text>
        <text class="loading-text">正在处理支付...</text>
        <text class="loading-desc">请不要关闭页面</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'

// 数据状态
const orderInfo = ref({
  planTitle: '',
  planPrice: 0,
  planUnit: '',
  planIndex: 0
})

const selectedPayment = ref(0)
const showCouponModal = ref(false)
const selectedCouponIndex = ref(-1)
const showPaymentLoading = ref(false)

// 订单特性
const orderFeatures = ref(['全部视频解锁', '题库完整开放', '无广告体验'])

// 支付方式
const paymentMethods = ref([
  {
    icon: '💚',
    name: '微信支付',
    description: '推荐使用，安全便捷'
  },
  {
    icon: '💙',
    name: '支付宝',
    description: '支持花呗分期付款'
  },
  {
    icon: '💳',
    name: '银行卡支付',
    description: '支持各大银行卡'
  }
])

// 可用优惠券
const availableCoupons = ref([
  {
    name: '新用户专享券',
    amount: 10,
    condition: '满39元可用',
    expireDate: '2024-12-31'
  },
  {
    name: '限时优惠券',
    amount: 20,
    condition: '满89元可用',
    expireDate: '2024-11-30'
  },
  {
    name: '年度大促券',
    amount: 50,
    condition: '满299元可用',
    expireDate: '2024-12-25'
  }
])

// 计算属性
const selectedCoupon = computed(() => {
  if (selectedCouponIndex.value >= 0) {
    return availableCoupons.value[selectedCouponIndex.value]
  }
  return null
})

const discount = computed(() => {
  if (selectedCoupon.value) {
    const price = orderInfo.value.planPrice
    const couponAmount = selectedCoupon.value.amount
    const condition = parseInt(selectedCoupon.value.condition.match(/\d+/)?.[0] || '0')

    if (price >= condition) {
      return couponAmount
    }
  }
  return 0
})

const finalPrice = computed(() => {
  return Math.max(orderInfo.value.planPrice - discount.value, 0)
})

// 方法
const selectPayment = (index: number) => {
  selectedPayment.value = index
}

const selectCoupon = (index: number) => {
  selectedCouponIndex.value = index
}

const confirmCoupon = () => {
  showCouponModal.value = false
  if (selectedCoupon.value) {
    uni.showToast({
      title: `已选择优惠券，减免¥${discount.value}`,
      icon: 'success'
    })
  }
}

const closeCouponModal = () => {
  showCouponModal.value = false
}

const processPay = async () => {
  showPaymentLoading.value = true

  // 模拟支付处理
  try {
    await new Promise(resolve => setTimeout(resolve, 2000))

    // 跳转到支付成功页面
    const successParams = new URLSearchParams({
      planTitle: orderInfo.value.planTitle,
      planPrice: finalPrice.value.toString(),
      paymentMethod: paymentMethods.value[selectedPayment.value].name,
      orderId: `VIP${Date.now()}`,
      discount: discount.value.toString()
    }).toString()

    uni.redirectTo({
      url: `/pages/payment-success/payment-success?${successParams}`,
      success: () => {
        console.log('跳转到支付成功页面')
      },
      fail: (err) => {
        console.error('跳转失败:', err)
        uni.showToast({
          title: '支付失败',
          icon: 'error'
        })
      }
    })
  } catch (error) {
    console.error('支付处理失败:', error)
    uni.showToast({
      title: '支付失败',
      icon: 'error'
    })
  } finally {
    showPaymentLoading.value = false
  }
}

onMounted(() => {
  // 获取页面参数
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.options || {}

  orderInfo.value = {
    planTitle: options.planTitle || 'VIP会员',
    planPrice: parseInt(options.planPrice || '39'),
    planUnit: options.planUnit || '/月',
    planIndex: parseInt(options.planIndex || '0')
  }

  // 根据套餐设置特性
  const planIndex = orderInfo.value.planIndex
  if (planIndex === 0) {
    orderFeatures.value = ['全部视频解锁', '题库完整开放', '无广告体验']
  } else if (planIndex === 1) {
    orderFeatures.value = ['全部功能解锁', '专属学习计划', '优先客服支持']
  } else {
    orderFeatures.value = ['所有功能无限制', '离线下载功能', '一对一指导']
  }
})
</script>

<style lang="scss" scoped>
.container {
  min-height: 100vh;
  background-color: #f5f5f5;
  padding-bottom: 100px;
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
  justify-content: center;
  align-items: center;
  padding: 0 20px;
}

.logo {
  font-size: 18px;
  font-weight: bold;
}

/* 订单信息 */
.order-section {
  background: white;
  margin: 80px 20px 20px;
  border-radius: 15px;
  padding: 20px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
}

.order-header {
  margin-bottom: 20px;
}

.order-title {
  font-size: 18px;
  font-weight: bold;
  color: #333;
}

.order-item {
  display: flex;
  align-items: flex-start;
  gap: 15px;
  padding: 15px;
  background: #f8f9ff;
  border-radius: 12px;
  margin-bottom: 20px;
}

.item-icon {
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

.item-info {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.item-name {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 4px;
}

.item-desc {
  font-size: 13px;
  color: #666;
  margin-bottom: 8px;
}

.item-features {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.feature-tag {
  background: #667eea;
  color: white;
  font-size: 11px;
  padding: 3px 8px;
  border-radius: 10px;
}

.item-price {
  display: flex;
  align-items: baseline;
}

.price-symbol {
  font-size: 14px;
  color: #667eea;
  font-weight: bold;
}

.price-amount {
  font-size: 24px;
  font-weight: bold;
  color: #667eea;
  margin-left: 2px;
}

.order-summary {
  border-top: 1px solid #eee;
  padding-top: 15px;
}

.summary-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
}

.summary-row.total {
  font-weight: bold;
  font-size: 16px;
  color: #333;
  border-top: 1px solid #eee;
  padding-top: 10px;
  margin-bottom: 0;
}

.summary-label {
  color: #666;
  font-size: 14px;
}

.summary-value {
  color: #333;
  font-size: 14px;
}

.summary-value.discount {
  color: #ff6b6b;
}

/* 支付方式 */
.payment-section {
  background: white;
  margin: 0 20px 20px;
  border-radius: 15px;
  padding: 20px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
}

.payment-header {
  margin-bottom: 20px;
}

.payment-title {
  font-size: 18px;
  font-weight: bold;
  color: #333;
}

.payment-methods {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.payment-method {
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 15px;
  border: 2px solid #eee;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.payment-method.active {
  border-color: #667eea;
  background: #f8f9ff;
}

.method-icon {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 20px;
  background: #f8f9fa;
}

.method-info {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.method-name {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 2px;
}

.method-desc {
  font-size: 13px;
  color: #666;
}

.method-radio {
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.radio {
  font-size: 16px;
  color: #ccc;
  transition: color 0.3s ease;
}

.radio.checked {
  color: #667eea;
}

/* 安全保障 */
.security-section {
  background: white;
  margin: 0 20px 20px;
  border-radius: 15px;
  padding: 20px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
}

.security-item {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
}

.security-item:last-child {
  margin-bottom: 0;
}

.security-icon {
  font-size: 16px;
}

.security-text {
  font-size: 14px;
  color: #666;
}

/* 优惠券选择 */
.coupon-section {
  background: white;
  margin: 0 20px 20px;
  border-radius: 15px;
  padding: 20px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  cursor: pointer;
}

.coupon-content {
  display: flex;
  align-items: center;
  gap: 15px;
}

.coupon-icon {
  font-size: 24px;
}

.coupon-info {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.coupon-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 2px;
}

.coupon-desc {
  font-size: 13px;
  color: #666;
}

.coupon-arrow {
  font-size: 20px;
  color: #999;
  font-weight: bold;
}

/* 立即支付按钮 */
.action-section {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: white;
  padding: 15px 20px;
  box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.1);
  text-align: center;
}

.pay-btn {
  width: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 25px;
  padding: 16px;
  font-size: 18px;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
  margin-bottom: 8px;
}

.pay-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.4);
}

.pay-note {
  font-size: 12px;
  color: #999;
}

/* 模态框 */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  z-index: 2000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.modal-content {
  background: white;
  border-radius: 20px;
  width: 100%;
  max-width: 400px;
  max-height: 70vh;
  overflow: hidden;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.modal-title {
  font-size: 18px;
  font-weight: bold;
}

.close-btn {
  font-size: 24px;
  cursor: pointer;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.2);
}

.modal-body {
  padding: 20px;
  max-height: 50vh;
  overflow-y: auto;
}

.coupon-list {
  margin-bottom: 20px;
}

.coupon-item {
  display: flex;
  gap: 15px;
  padding: 15px;
  border: 2px solid #eee;
  border-radius: 12px;
  margin-bottom: 10px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.coupon-item.selected {
  border-color: #667eea;
  background: #f8f9ff;
}

.coupon-item.no-coupon {
  justify-content: center;
  align-items: center;
}

.coupon-left {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%);
  color: white;
  border-radius: 8px;
  padding: 10px;
  min-width: 80px;
}

.coupon-amount {
  font-size: 18px;
  font-weight: bold;
}

.coupon-condition {
  font-size: 11px;
  opacity: 0.9;
}

.coupon-right {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.coupon-name {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 4px;
}

.coupon-expire {
  font-size: 12px;
  color: #999;
}

.no-coupon-text {
  font-size: 16px;
  color: #666;
}

.confirm-coupon-btn {
  width: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 20px;
  padding: 12px;
  font-size: 16px;
  font-weight: bold;
  cursor: pointer;
}

/* 支付加载 */
.payment-loading {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.8);
  z-index: 3000;
  display: flex;
  align-items: center;
  justify-content: center;
}

.loading-content {
  background: white;
  border-radius: 20px;
  padding: 40px;
  text-align: center;
  min-width: 200px;
}

.loading-icon {
  font-size: 48px;
  margin-bottom: 20px;
  display: block;
  animation: pulse 1.5s infinite;
}

.loading-text {
  font-size: 18px;
  font-weight: bold;
  color: #333;
  margin-bottom: 8px;
  display: block;
}

.loading-desc {
  font-size: 14px;
  color: #666;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}
</style>
