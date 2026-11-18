<script setup lang="ts">
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { http } from '@/utils/http'

const summary = ref<any>({})
const plans = ref<any[]>([])

onShow(async () => {
  const [userRes, planRes]: any = await Promise.all([
    http({ url: '/mall/points/summary', method: 'GET', silent: true }),
    http({ url: '/mall/plan', method: 'GET', silent: true }),
  ])
  if (userRes?.code === 0) summary.value = userRes.data || {}
  if (planRes?.code === 0) plans.value = planRes.data || []
})

const yuan = (fen: number) => ((fen || 0) / 100).toFixed(2)
const vipText = () => {
  if (!summary.value.vipLevel) return '普通用户'
  const time = summary.value.vipExpireTime ? String(summary.value.vipExpireTime).replace('T', ' ').slice(0, 16) : ''
  return time ? `VIP 至 ${time}` : 'VIP会员'
}

const openPlan = async (plan: any) => {
  const res: any = await http({ url: '/mall/order', method: 'POST', data: { planId: plan.id } })
  if (res?.code !== 0) {
    uni.showToast({ title: res?.msg || '下单失败', icon: 'none' })
    return
  }
  uni.navigateTo({ url: `/pages/payment/payment?orderNo=${res.data.orderNo}` })
}
</script>

<template>
  <view class="page">
    <view class="hero">
      <text class="kicker">会员中心</text>
      <text class="title">{{ vipText() }}</text>
      <text class="sub">当前积分 {{ summary.balance || 0 }}，开通会员后额外赠送积分</text>
    </view>
    <view class="card">
      <text class="section">会员权益</text>
      <text class="line">交规视频、错题解析和模拟考试不限次数</text>
      <text class="line">开通成功按规则赠送积分</text>
      <text class="line">会员订单支持微信支付</text>
    </view>
    <view v-for="plan in plans" :key="plan.id" class="plan" @click="openPlan(plan)">
      <view>
        <text class="plan-name">{{ plan.planName }} · {{ plan.days }}天</text>
        <text class="origin" v-if="plan.originPrice">原价 ¥{{ yuan(plan.originPrice) }}</text>
      </view>
      <text class="amount">¥{{ yuan(plan.price) }}</text>
      <text v-if="plan.recommended === 1" class="badge">推荐</text>
    </view>
    <view v-if="!plans.length" class="empty">还没有会员套餐，请先执行商城 SQL</view>
  </view>
</template>

<style lang="scss" scoped>
.page { min-height: 100vh; max-width: 480px; margin: 0 auto; background: #f3f6f4; padding: 24rpx; box-sizing: border-box; }
.hero { background: #10221f; color: #fff; border-radius: 28rpx; padding: 32rpx; }
.kicker, .sub, .line, .origin, .plan-name { display: block; }
.title { display: block; margin: 8rpx 0; font-size: 40rpx; font-weight: 700; }
.sub, .kicker { font-size: 24rpx; opacity: .8; }
.card, .plan { background: #fff; border-radius: 24rpx; padding: 28rpx; margin-top: 16rpx; }
.section { display: block; font-weight: 700; margin-bottom: 8rpx; }
.line { color: #4b5563; font-size: 26rpx; margin-top: 8rpx; }
.plan { display: flex; justify-content: space-between; align-items: center; position: relative; }
.plan-name { font-size: 30rpx; font-weight: 700; color: #10221f; }
.origin { color: #9ca3af; font-size: 22rpx; text-decoration: line-through; }
.amount { color: #9a3412; font-size: 36rpx; font-weight: 700; }
.badge { position: absolute; top: 12rpx; right: 140rpx; background: #f59e0b; color: #fff; font-size: 20rpx; padding: 2rpx 10rpx; border-radius: 999rpx; }
.empty { text-align: center; color: #6b7280; padding: 30rpx; }
</style>
