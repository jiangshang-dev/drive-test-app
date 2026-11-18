<script setup lang="ts">
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { http } from '@/utils/http'

const status = ref<number | null>(null)
const orders = ref<any[]>([])
const tabs = [
  { name: '全部', value: null },
  { name: '待支付', value: 0 },
  { name: '待发货', value: 1 },
  { name: '已发货', value: 2 },
  { name: '已完成', value: 3 },
]

onShow(() => loadOrders())

const loadOrders = async () => {
  const query = status.value === null ? '' : `?status=${status.value}`
  const res: any = await http({ url: `/mall/order/mine${query}`, method: 'GET', silent: true })
  orders.value = res?.code === 0 ? res.data || [] : []
}

const switchTab = (value: number | null) => {
  status.value = value
  loadOrders()
}

const statusText = (value: number) => ['待支付', '待发货', '已发货', '已完成', '已取消'][value] || '处理中'
const yuan = (order: any) => order.payType === 'POINTS' ? `${order.pointsCost} 积分` : `¥${((order.cashAmount || 0) / 100).toFixed(2)}`
const open = (order: any) => uni.navigateTo({ url: `/pages/order-detail/order-detail?orderNo=${order.orderNo}` })
</script>

<template>
  <view class="page">
    <view class="tabs">
      <text v-for="tab in tabs" :key="tab.name" :class="['tab', status === tab.value ? 'active' : '']" @click="switchTab(tab.value)">{{ tab.name }}</text>
    </view>
    <view v-if="!orders.length" class="empty">还没有订单</view>
    <view v-for="order in orders" :key="order.orderNo" class="card" @click="open(order)">
      <view class="row">
        <text class="no">{{ order.orderNo }}</text>
        <text class="state">{{ statusText(order.status) }}</text>
      </view>
      <text class="name">{{ order.goodsName }}</text>
      <text class="meta">{{ order.goodsType === 'PHYSICAL' ? '实物' : order.goodsType === 'VIP' ? '会员' : '虚拟' }} · {{ order.payType === 'POINTS' ? '积分' : '微信支付' }}</text>
      <text class="price">{{ yuan(order) }}</text>
    </view>
  </view>
</template>

<style lang="scss" scoped>
.page { min-height: 100vh; max-width: 480px; margin: 0 auto; background: #f3f6f4; padding: 24rpx; box-sizing: border-box; }
.tabs { display: flex; gap: 8rpx; margin-bottom: 16rpx; }
.tab { flex: 1; text-align: center; background: #fff; border-radius: 14rpx; padding: 14rpx 0; font-size: 24rpx; color: #4b5563; }
.tab.active { background: #0f766e; color: #fff; }
.card { background: #fff; border-radius: 24rpx; padding: 24rpx; margin-bottom: 16rpx; }
.row { display: flex; justify-content: space-between; }
.no, .meta { color: #6b7280; font-size: 22rpx; }
.name { display: block; margin-top: 10rpx; font-size: 30rpx; font-weight: 700; color: #10221f; }
.meta, .price { display: block; margin-top: 8rpx; }
.state, .price { color: #0f766e; font-weight: 700; }
.empty { text-align: center; color: #6b7280; padding: 40rpx; }
</style>
