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

const yuan = (fen: number) => ((fen || 0) / 100).toFixed(2)

const pay = async () => {
  const res: any = await http({ url: '/mall/pay/wechat', method: 'POST', data: { orderNo: orderNo.value } })
  if (res?.code !== 0) {
    uni.showToast({ title: res?.msg || '支付发起失败', icon: 'none' })
    return
  }
  if (res.data.mode === 'dev') {
    uni.showModal({
      title: '微信支付',
      content: '当前没有配置微信商户号。确认后会按支付成功处理这笔订单，正式环境会拉起微信支付。',
      success: async (result) => {
        if (!result.confirm) return
        const paid: any = await http({ url: '/mall/pay/dev-confirm', method: 'POST', data: { orderNo: orderNo.value } })
        if (paid?.code === 0) {
          uni.redirectTo({ url: `/pages/payment-success/payment-success?orderNo=${orderNo.value}` })
        } else {
          uni.showToast({ title: paid?.msg || '支付失败', icon: 'none' })
        }
      },
    })
    return
  }
  const payData = res.data.pay
  uni.requestPayment({
    provider: 'wxpay',
    timeStamp: payData.timeStamp,
    nonceStr: payData.nonceStr,
    package: payData.package,
    signType: payData.signType,
    paySign: payData.paySign,
    success: () => {
      uni.redirectTo({ url: `/pages/payment-success/payment-success?orderNo=${orderNo.value}` })
    },
    fail: () => {
      uni.showToast({ title: '支付未完成', icon: 'none' })
    },
  } as any)
}
</script>

<template>
  <view class="page">
    <view v-if="!order" class="empty">正在读取订单</view>
    <view v-else class="card">
      <text class="name">{{ order.goodsName }}</text>
      <text class="meta">订单号 {{ order.orderNo }}</text>
      <text class="amount">¥{{ yuan(order.cashAmount) }}</text>
      <text class="meta">支付方式：微信支付</text>
      <button class="primary" @click="pay">微信支付</button>
    </view>
  </view>
</template>

<style lang="scss" scoped>
.page { min-height: 100vh; max-width: 480px; margin: 0 auto; background: #f3f6f4; padding: 24rpx; box-sizing: border-box; }
.card { background: #fff; border-radius: 28rpx; padding: 32rpx; }
.name, .meta { display: block; }
.name { font-size: 34rpx; font-weight: 700; color: #10221f; }
.meta { margin-top: 10rpx; color: #6b7280; font-size: 24rpx; }
.amount { display: block; margin: 20rpx 0; font-size: 56rpx; font-weight: 700; color: #9a3412; }
.primary { margin-top: 20rpx; background: #0f766e; color: #fff; border-radius: 16rpx; }
.empty { text-align: center; color: #6b7280; padding: 40rpx; }
</style>
