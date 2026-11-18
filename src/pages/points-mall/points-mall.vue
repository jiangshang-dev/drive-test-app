<script setup lang="ts">
import { computed, ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { http } from '@/utils/http'
import { useMemberStore } from '@/stores'

const memberStore = useMemberStore()
const goodsType = ref('ALL')
const goods = ref<any[]>([])
const summary = ref({ balance: 0, todayEarned: 0, totalEarned: 0, totalSpent: 0 })
const logs = ref<any[]>([])
const rules = ref<any[]>([])
const showLogs = ref(false)

const filtered = computed(() => goods.value)

onShow(() => {
  loadGoods()
  loadSummary()
  loadRules()
})

const loadGoods = async () => {
  const query = goodsType.value === 'ALL' ? '' : `?goodsType=${goodsType.value}`
  const res: any = await http({ url: `/mall/goods${query}`, method: 'GET', silent: true })
  goods.value = res?.code === 0 ? res.data || [] : []
}

const loadSummary = async () => {
  const res: any = await http({ url: '/mall/points/summary', method: 'GET', silent: true })
  if (res?.code === 0 && res.data) {
    summary.value = res.data
    if (memberStore.profile) {
      ;(memberStore.profile as any).integral = res.data.balance
    }
  }
}

const loadRules = async () => {
  const res: any = await http({ url: '/mall/points/rules', method: 'GET', silent: true })
  rules.value = res?.code === 0 ? res.data || [] : []
}

const openLogs = async () => {
  const res: any = await http({ url: '/mall/points/logs', method: 'GET' })
  if (res?.code === 0) {
    logs.value = res.data || []
    showLogs.value = true
  }
}

const switchType = (type: string) => {
  goodsType.value = type
  loadGoods()
}

const yuan = (fen: number) => ((fen || 0) / 100).toFixed(2)

const buy = (item: any) => {
  uni.navigateTo({ url: `/pages/mall/confirm?goodsId=${item.id}` })
}
</script>

<template>
  <view class="page">
    <view class="hero">
      <text class="kicker">积分可以兑换，也可以用微信支付</text>
      <text class="balance">{{ summary.balance }}</text>
      <view class="stats">
        <text>今日 +{{ summary.todayEarned }}</text>
        <text>累计获得 {{ summary.totalEarned }}</text>
        <text>已使用 {{ summary.totalSpent }}</text>
      </view>
      <view class="hero-actions">
        <text class="chip" @click="openLogs">积分记录</text>
        <text class="chip" @click="showLogs = false">赚积分</text>
      </view>
    </view>

    <view class="rules">
      <text v-for="rule in rules" :key="rule.sceneCode" class="rule">{{ rule.sceneName }} {{ rule.calcType === 'FEN' ? '按实付金额' : '+' + rule.points }}</text>
    </view>

    <view class="tabs">
      <text :class="['tab', goodsType === 'ALL' ? 'active' : '']" @click="switchType('ALL')">全部</text>
      <text :class="['tab', goodsType === 'VIRTUAL' ? 'active' : '']" @click="switchType('VIRTUAL')">虚拟</text>
      <text :class="['tab', goodsType === 'PHYSICAL' ? 'active' : '']" @click="switchType('PHYSICAL')">实物</text>
    </view>

    <view v-if="!filtered.length" class="empty">商品还没准备好，先执行商城 SQL</view>
    <view v-for="item in filtered" :key="item.id" class="card" @click="buy(item)">
      <view class="cover">{{ item.coverText || '品' }}</view>
      <view class="info">
        <text class="name">{{ item.goodsName }}</text>
        <text class="summary">{{ item.summary }}</text>
        <text class="tag">{{ item.goodsType === 'PHYSICAL' ? '实物，需要发货' : '虚拟商品' }}</text>
        <text class="price">{{ item.pointsPrice }} 积分 或 ¥{{ yuan(item.cashPrice) }}</text>
      </view>
    </view>

    <view v-if="showLogs" class="mask" @click="showLogs = false">
      <view class="sheet" @click.stop>
        <text class="sheet-title">积分记录</text>
        <view v-if="!logs.length" class="empty">还没有积分流水</view>
        <view v-for="item in logs" :key="item.id" class="log">
          <text>{{ item.remark || item.sceneCode }}</text>
          <text :class="item.points > 0 ? 'plus' : 'minus'">{{ item.points > 0 ? '+' : '' }}{{ item.points }}</text>
        </view>
      </view>
    </view>
  </view>
</template>

<style lang="scss" scoped>
.page { min-height: 100vh; max-width: 480px; margin: 0 auto; background: #f3f6f4; padding: 24rpx; box-sizing: border-box; }
.hero { background: linear-gradient(160deg, #115e59, #0f766e); color: #fff; border-radius: 28rpx; padding: 32rpx; }
.kicker { display: block; font-size: 24rpx; opacity: .85; }
.balance { display: block; margin: 8rpx 0; font-size: 64rpx; font-weight: 700; }
.stats, .hero-actions { display: flex; gap: 16rpx; font-size: 22rpx; }
.chip { margin-top: 16rpx; padding: 8rpx 18rpx; border-radius: 999rpx; background: rgba(255,255,255,.16); }
.rules { display: flex; flex-wrap: wrap; gap: 10rpx; margin: 16rpx 0; }
.rule { background: #fff; color: #0f766e; border-radius: 999rpx; padding: 8rpx 16rpx; font-size: 22rpx; }
.tabs { display: flex; gap: 12rpx; margin-bottom: 16rpx; }
.tab { flex: 1; text-align: center; background: #fff; border-radius: 16rpx; padding: 16rpx 0; color: #4b5563; }
.tab.active { background: #0f766e; color: #fff; }
.card { display: flex; gap: 20rpx; background: #fff; border-radius: 24rpx; padding: 24rpx; margin-bottom: 16rpx; }
.cover { width: 96rpx; height: 96rpx; border-radius: 20rpx; background: #10221f; color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 700; }
.info { flex: 1; }
.name, .summary, .tag, .price { display: block; }
.name { font-size: 30rpx; font-weight: 700; color: #10221f; }
.summary, .tag { margin-top: 6rpx; font-size: 24rpx; color: #6b7280; }
.price { margin-top: 10rpx; color: #9a3412; font-weight: 700; }
.empty { padding: 28rpx; color: #6b7280; text-align: center; }
.mask { position: fixed; inset: 0; background: rgba(0,0,0,.45); display: flex; align-items: flex-end; }
.sheet { width: 100%; max-width: 480px; margin: 0 auto; background: #fff; border-radius: 28rpx 28rpx 0 0; padding: 28rpx; max-height: 70vh; overflow: auto; }
.sheet-title { display: block; font-size: 32rpx; font-weight: 700; margin-bottom: 16rpx; }
.log { display: flex; justify-content: space-between; padding: 16rpx 0; border-bottom: 1px solid #eef2f0; }
.plus { color: #0f766e; }
.minus { color: #b91c1c; }
</style>
