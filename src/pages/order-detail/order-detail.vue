<script setup lang="ts">
import { ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { http } from '@/utils/http'

const order = ref<any>(null)
const orderNo = ref('')

onLoad((options: any) => {
  orderNo.value = options?.orderNo || ''
  loadOrder()
})

const loadOrder = async () => {
  const res: any = await http({ url: `/mall/order/${orderNo.value}`, method: 'GET' })
  if (res?.code === 0) order.value = res.data
}

const statusText = (value: number) => ['待支付', '待发货', '已发货', '已完成', '已取消'][value] || '处理中'
const yuan = (orderItem: any) => orderItem.payType === 'POINTS' ? `${orderItem.pointsCost} 积分` : `¥${((orderItem.cashAmount || 0) / 100).toFixed(2)}`

const pay = () => uni.navigateTo({ url: `/pages/payment/payment?orderNo=${orderNo.value}` })

const cancel = async () => {
  const res: any = await http({ url: '/mall/order/cancel', method: 'POST', data: { orderNo: orderNo.value } })
  if (res?.code === 0) order.value = res.data
  else uni.showToast({ title: res?.msg || '取消失败', icon: 'none' })
}

const receive = async () => {
  const res: any = await http({ url: '/mall/order/receive', method: 'POST', data: { orderNo: orderNo.value } })
  if (res?.code === 0) order.value = res.data
  else uni.showToast({ title: res?.msg || '确认失败', icon: 'none' })
}
</script>

<template>
  <view class="page">
    <view v-if="!order" class="empty">正在读取订单</view>
    <view v-else class="card">
      <text class="state">{{ statusText(order.status) }}</text>
      <text class="name">{{ order.goodsName }}</text>
      <text class="meta">订单号 {{ order.orderNo }}</text>
      <text class="meta">金额 {{ yuan(order) }}</text>
      <text class="meta">支付 {{ order.payType === 'POINTS' ? '积分' : '微信支付' }}</text>
      <template v-if="order.goodsType === 'PHYSICAL'">
        <text class="meta">收货人 {{ order.receiverName }} {{ order.receiverPhone }}</text>
        <text class="meta">地址 {{ order.receiverAddress }}</text>
        <text v-if="order.expressNo" class="meta">物流 {{ order.expressCompany || '快递' }} {{ order.expressNo }}</text>
        <text v-else-if="order.status === 1" class="meta">实物订单已支付，等待商家发货</text>
      </template>
      <button v-if="order.status === 0" class="primary" @click="pay">去支付</button>
      <button v-if="order.status === 0" class="ghost" @click="cancel">取消订单</button>
      <button v-if="order.status === 2" class="primary" @click="receive">确认收货</button>
    </view>
  </view>
</template>

<style lang="scss" scoped>
.page { min-height: 100vh; max-width: 480px; margin: 0 auto; background: #f3f6f4; padding: 24rpx; box-sizing: border-box; }
.card { background: #fff; border-radius: 28rpx; padding: 32rpx; }
.state { display: block; color: #0f766e; font-size: 36rpx; font-weight: 700; }
.name { display: block; margin-top: 12rpx; font-size: 32rpx; font-weight: 700; color: #10221f; }
.meta { display: block; margin-top: 10rpx; color: #4b5563; font-size: 26rpx; }
.primary, .ghost { margin-top: 20rpx; border-radius: 16rpx; }
.primary { background: #0f766e; color: #fff; }
.ghost { background: #f4f7f6; color: #10221f; }
.empty { text-align: center; color: #6b7280; padding: 40rpx; }
</style>
