<script setup lang="ts">
import { ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { http } from '@/utils/http'

const goods = ref<any>(null)
const payType = ref('WECHAT')
const receiverName = ref('')
const receiverPhone = ref('')
const receiverAddress = ref('')

onLoad(async (options: any) => {
  const res: any = await http({ url: '/mall/goods', method: 'GET', silent: true })
  const list = res?.code === 0 ? res.data || [] : []
  goods.value = list.find((item: any) => String(item.id) === String(options?.goodsId))
  if (goods.value && !goods.value.cashPrice) payType.value = 'POINTS'
})

const yuan = (fen: number) => ((fen || 0) / 100).toFixed(2)

const submit = async () => {
  if (!goods.value) return
  const res: any = await http({
    url: '/mall/order',
    method: 'POST',
    data: {
      goodsId: goods.value.id,
      payType: payType.value,
      receiverName: receiverName.value,
      receiverPhone: receiverPhone.value,
      receiverAddress: receiverAddress.value,
    },
  })
  if (res?.code !== 0) {
    uni.showToast({ title: res?.msg || '下单失败', icon: 'none' })
    return
  }
  if (res.data.payType === 'POINTS') {
    uni.redirectTo({ url: `/pages/payment-success/payment-success?orderNo=${res.data.orderNo}` })
    return
  }
  uni.redirectTo({ url: `/pages/payment/payment?orderNo=${res.data.orderNo}` })
}
</script>

<template>
  <view class="page">
    <view v-if="!goods" class="empty">没有找到这个商品</view>
    <template v-else>
      <view class="card">
        <text class="name">{{ goods.goodsName }}</text>
        <text class="desc">{{ goods.summary }}</text>
        <text class="tag">{{ goods.goodsType === 'PHYSICAL' ? '实物，支付后等待发货' : '虚拟商品，支付后立即完成' }}</text>
      </view>
      <view v-if="goods.goodsType === 'PHYSICAL'" class="card">
        <text class="label">收货人</text>
        <input class="field" v-model="receiverName" placeholder="姓名" />
        <text class="label">手机号</text>
        <input class="field" v-model="receiverPhone" placeholder="手机号" />
        <text class="label">地址</text>
        <input class="field" v-model="receiverAddress" placeholder="省市区和详细地址" />
      </view>
      <view class="card">
        <view :class="['pay', payType === 'POINTS' ? 'active' : '']" @click="payType = 'POINTS'">积分支付 {{ goods.pointsPrice }} 积分</view>
        <view :class="['pay', payType === 'WECHAT' ? 'active' : '']" @click="payType = 'WECHAT'">微信支付 ¥{{ yuan(goods.cashPrice) }}</view>
      </view>
      <button class="primary" @click="submit">提交订单</button>
    </template>
  </view>
</template>

<style lang="scss" scoped>
.page { min-height: 100vh; max-width: 480px; margin: 0 auto; background: #f3f6f4; padding: 24rpx; box-sizing: border-box; }
.card { background: #fff; border-radius: 24rpx; padding: 28rpx; margin-bottom: 16rpx; }
.name { display: block; font-size: 34rpx; font-weight: 700; color: #10221f; }
.desc, .tag, .label { display: block; margin-top: 10rpx; color: #6b7280; font-size: 24rpx; }
.field { margin-top: 8rpx; background: #f4f7f6; border-radius: 14rpx; padding: 18rpx; }
.pay { margin-top: 12rpx; padding: 22rpx; border-radius: 16rpx; background: #f4f7f6; }
.pay.active { background: #0f766e; color: #fff; }
.primary { margin-top: 12rpx; background: #0f766e; color: #fff; border-radius: 16rpx; }
.empty { text-align: center; color: #6b7280; padding: 40rpx; }
</style>
