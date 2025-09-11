<template>
  <view class="container">

    <!-- 订单状态筛选 -->
    <view class="filter-tabs">
      <view
        v-for="(tab, index) in statusTabs"
        :key="index"
        class="filter-tab"
        :class="{ active: activeTab === index }"
        @click="switchTab(index)"
      >
        <text class="tab-text">{{ tab.name }}</text>
        <text v-if="tab.count > 0" class="tab-count">{{ tab.count }}</text>
      </view>
    </view>

    <!-- 订单列表 -->
    <view class="orders-list">
      <view
        v-for="(order, index) in filteredOrders"
        :key="index"
        class="order-item"
        @click="goToOrderDetail(order)"
      >
        <!-- 订单头部 -->
        <view class="order-header">
          <text class="order-id">订单号：{{ order.orderId }}</text>
          <text class="order-status" :class="order.statusClass">
            {{ order.statusText }}
          </text>
        </view>

        <!-- 订单商品信息 -->
        <view class="order-product">
          <view class="product-icon">
            <text class="icon">{{ order.productIcon }}</text>
          </view>
          <view class="product-info">
            <text class="product-name">{{ order.productName }}</text>
            <text class="product-desc">{{ order.productDesc }}</text>
            <text class="product-spec">{{ order.productSpec }}</text>
          </view>
          <view class="product-price">
            <text class="price-symbol">¥</text>
            <text class="price-amount">{{ order.price }}</text>
          </view>
        </view>

        <!-- 订单时间和支付方式 -->
        <view class="order-meta">
          <text class="order-time">{{ formatOrderTime(order.createTime) }}</text>
          <text class="payment-method">{{ order.paymentMethod }}</text>
        </view>

        <!-- 订单操作按钮 -->
        <view class="order-actions">
          <button
            v-for="(action, aIndex) in order.actions"
            :key="aIndex"
            class="action-btn"
            :class="action.type"
            @click.stop="handleAction(action, order)"
          >
            {{ action.text }}
          </button>
        </view>
      </view>
    </view>

    <!-- 空状态 -->
    <view v-if="filteredOrders.length === 0" class="empty-orders">
      <text class="empty-icon">📋</text>
      <text class="empty-title">暂无订单</text>
      <text class="empty-desc">{{ emptyMessage }}</text>
      <button class="go-shopping-btn" @click="goToVipPage">
        去开通VIP会员
      </button>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'

// 状态筛选标签
const statusTabs = ref([
  { name: '全部', status: 'all', count: 0 },
  { name: '待支付', status: 'pending', count: 0 },
  { name: '已支付', status: 'paid', count: 0 },
  { name: '已完成', status: 'completed', count: 0 },
  { name: '已取消', status: 'cancelled', count: 0 }
])

const activeTab = ref(0)

// 模拟订单数据
const orders = ref([
  {
    orderId: 'VIP1704067200001',
    productIcon: '👑',
    productName: 'VIP会员',
    productDesc: 'VIP季度会员套餐',
    productSpec: '3个月有效期',
    price: 89,
    actualPrice: 89,
    discount: 0,
    paymentMethod: '微信支付',
    status: 'completed',
    statusText: '已完成',
    statusClass: 'completed',
    createTime: new Date('2024-01-01 10:30:00'),
    payTime: new Date('2024-01-01 10:31:15'),
    actions: [
      { text: '查看详情', type: 'primary', action: 'detail' },
      { text: '申请退款', type: 'secondary', action: 'refund' }
    ]
  },
  {
    orderId: 'VIP1704153600002',
    productIcon: '👑',
    productName: 'VIP会员',
    productDesc: 'VIP月度会员套餐',
    productSpec: '1个月有效期',
    price: 39,
    actualPrice: 29,
    discount: 10,
    paymentMethod: '支付宝',
    status: 'completed',
    statusText: '已完成',
    statusClass: 'completed',
    createTime: new Date('2024-01-02 15:45:00'),
    payTime: new Date('2024-01-02 15:46:30'),
    actions: [
      { text: '查看详情', type: 'primary', action: 'detail' }
    ]
  }
])

// 计算属性
const filteredOrders = computed(() => {
  const currentStatus = statusTabs.value[activeTab.value].status
  if (currentStatus === 'all') {
    return orders.value
  }
  return orders.value.filter(order => order.status === currentStatus)
})

const emptyMessage = computed(() => {
  const currentTab = statusTabs.value[activeTab.value]
  return `您还没有${currentTab.name === '全部' ? '' : currentTab.name}的订单`
})

// 方法
const goBack = () => {
  uni.navigateBack()
}

const switchTab = (index: number) => {
  activeTab.value = index
}

const goToOrderDetail = (order: any) => {
  console.log('查看订单详情:', order)
  // 跳转到订单详情页面，传递订单信息
  const orderParams = new URLSearchParams({
    orderId: order.orderId,
    productName: order.productName,
    productDesc: order.productDesc,
    price: order.price.toString(),
    status: order.status,
    statusText: order.statusText,
    paymentMethod: order.paymentMethod,
    createTime: order.createTime.toISOString(),
    payTime: order.payTime ? order.payTime.toISOString() : ''
  }).toString()

  uni.navigateTo({
    url: `/pages/order-detail/order-detail?${orderParams}`,
    success: () => {
      console.log('跳转到订单详情页面成功')
    },
    fail: (err) => {
      console.error('跳转到订单详情页面失败:', err)
      uni.showToast({
        title: '页面跳转失败',
        icon: 'error'
      })
    }
  })
}

const handleAction = (action: any, order: any) => {
  console.log('执行操作:', action.action, order)

  switch (action.action) {
    case 'pay':
      // 跳转到支付页面
      uni.navigateTo({
        url: `/pages/payment/payment?orderId=${order.orderId}&planTitle=${order.productName}&planPrice=${order.price}`
      })
      break
    case 'cancel':
      // 取消订单
      uni.showModal({
        title: '确认取消',
        content: '确定要取消这个订单吗？',
        success: (res) => {
          if (res.confirm) {
            order.status = 'cancelled'
            order.statusText = '已取消'
            order.statusClass = 'cancelled'
            order.actions = []
            uni.showToast({
              title: '订单已取消',
              icon: 'success'
            })
            updateOrderCounts()
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

const goToVipPage = () => {
  uni.navigateTo({
    url: '/pages/vip/vip'
  })
}

const formatOrderTime = (date: Date) => {
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const updateOrderCounts = () => {
  statusTabs.value[0].count = orders.value.length // 全部
  statusTabs.value[1].count = orders.value.filter(o => o.status === 'pending').length // 待支付
  statusTabs.value[2].count = orders.value.filter(o => o.status === 'paid').length // 已支付
  statusTabs.value[3].count = orders.value.filter(o => o.status === 'completed').length // 已完成
  statusTabs.value[4].count = orders.value.filter(o => o.status === 'cancelled').length // 已取消
}

onMounted(() => {
  updateOrderCounts()
  console.log('订单页面加载完成')
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

/* 筛选标签 */
.filter-tabs {
  background: white;
  display: flex;
  margin-top: 0px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
  position: sticky;
  top: 0px;
  z-index: 999;
}

.filter-tab {
  flex: 1;
  text-align: center;
  padding: 15px 10px;
  position: relative;
  cursor: pointer;
  transition: all 0.3s ease;
}

.filter-tab.active {
  color: #667eea;
  font-weight: bold;
}

.filter-tab.active::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 30px;
  height: 3px;
  background: #667eea;
  border-radius: 2px;
}

.tab-text {
  font-size: 14px;
}

.tab-count {
  background: #ff4444;
  color: white;
  font-size: 10px;
  padding: 2px 5px;
  border-radius: 8px;
  margin-left: 4px;
  min-width: 16px;
  text-align: center;
}

/* 订单列表 */
.orders-list {
  padding: 20px;
}

.order-item {
  background: white;
  border-radius: 15px;
  padding: 20px;
  margin-bottom: 15px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  cursor: pointer;
  transition: all 0.3s ease;
}

.order-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.12);
}

/* 订单头部 */
.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
  padding-bottom: 10px;
  border-bottom: 1px solid #f0f0f0;
}

.order-id {
  font-size: 13px;
  color: #666;
}

.order-status {
  font-size: 12px;
  padding: 4px 8px;
  border-radius: 8px;
  font-weight: bold;
}

.order-status.pending {
  background: #fff3cd;
  color: #856404;
}

.order-status.paid {
  background: #d1ecf1;
  color: #0c5460;
}

.order-status.completed {
  background: #d4edda;
  color: #155724;
}

.order-status.cancelled {
  background: #f8d7da;
  color: #721c24;
}

/* 订单商品 */
.order-product {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 15px;
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

/* 订单元信息 */
.order-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
  font-size: 13px;
  color: #666;
}

/* 订单操作 */
.order-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
}

.action-btn {
  padding: 6px 12px;
  border-radius: 15px;
  font-size: 12px;
  border: none;
  cursor: pointer;
  transition: all 0.3s ease;
  min-width: 60px;
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

/* 空状态 */
.empty-orders {
  text-align: center;
  padding: 80px 20px;
  color: #999;
}

.empty-icon {
  font-size: 64px;
  display: block;
  margin-bottom: 20px;
}

.empty-title {
  font-size: 18px;
  font-weight: bold;
  color: #666;
  margin-bottom: 8px;
  display: block;
}

.empty-desc {
  font-size: 14px;
  margin-bottom: 30px;
  display: block;
}

.go-shopping-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 25px;
  padding: 12px 30px;
  font-size: 14px;
  cursor: pointer;
}
</style>
