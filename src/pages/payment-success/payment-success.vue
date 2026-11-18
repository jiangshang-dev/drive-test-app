<script setup lang="ts">
import { ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { http } from '@/utils/http'

const order = ref<any>(null)

onLoad(async (options: any) => {
  const res: any = await http({ url: `/mall/order/${options?.orderNo || ''}`, method: 'GET', silent: true })
  if (res?.code === 0) order.value = res.data
})

const yuan = (fen: number) => ((fen || 0) / 100).toFixed(2)
const statusText = (orderItem: any) => {
  if (!orderItem) return ''
  if (orderItem.goodsType === 'PHYSICAL' && orderItem.status === 1) return '已支付，等待发货'
  if (orderItem.status === 3) return '已完成'
  return '已支付'
}

const goOrders = () => uni.redirectTo({ url: '/pages/order-list/order-list' })
</script>

<template>
  <view class="page">
    <view class="card">
      <text class="title">支付成功</text>
      <text class="desc">{{ order ? statusText(order) : '订单处理中' }}</text>
      <text v-if="order" class="meta">{{ order.goodsName }}</text>
      <text v-if="order" class="meta">{{ order.payType === 'POINTS' ? order.pointsCost + ' 积分' : '¥' + yuan(order.cashAmount) }}</text>
      <button class="primary" @click="goOrders">查看订单</button>
    </view>
  </view>
</template>

<style lang="scss" scoped>
.page { min-height: 100vh; max-width: 480px; margin: 0 auto; background: #f3f6f4; padding: 24rpx; box-sizing: border-box; }
.card { background: #fff; border-radius: 28rpx; padding: 40rpx 32rpx; }
.title { display: block; font-size: 44rpx; font-weight: 700; color: #0f766e; }
.desc, .meta { display: block; margin-top: 12rpx; color: #4b5563; }
.primary { margin-top: 28rpx; background: #0f766e; color: #fff; border-radius: 16rpx; }
</style>
