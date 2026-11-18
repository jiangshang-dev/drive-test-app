<script setup lang="ts">
import { computed, ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { http } from '@/utils/http'

type Card = {
  id: number
  subject: number
  category: string
  title: string
  content: string
}

const subject = ref(0)
const cards = ref<Card[]>([])
const opened = ref<number | null>(null)
const loading = ref(true)

const localCards: Card[] = [
  {
    id: 1,
    subject: 1,
    category: '标志颜色',
    title: '三种标志一眼分开',
    content: '警告标志黄底黑边，禁令标志白底红圈，指示标志蓝底白图案。黄的减速，红的禁止，蓝的按箭头走。',
  },
  {
    id: 2,
    subject: 1,
    category: '速度',
    title: '没有限速标志时的默认速度',
    content: '城市道路没有中心线最高 30，有中心线最高 50。公路没有中心线最高 40，有中心线最高 70。',
  },
  {
    id: 3,
    subject: 4,
    category: '应急',
    title: '爆胎时不要猛踩刹车',
    content: '握稳方向盘，松油门，轻点刹车，等车速降下来再靠边。高速爆胎不能急刹、急打方向。',
  },
  {
    id: 4,
    subject: 4,
    category: '高速',
    title: '高速故障停车顺序',
    content: '开危险报警闪光灯，人员从右侧下车撤到护栏外，警告标志放在来车方向 150 米以外。',
  },
]

const visibleCards = computed(() => {
  if (!subject.value) return cards.value
  return cards.value.filter((item) => item.subject === subject.value)
})

onLoad(async (options: any) => {
  subject.value = Number(options?.sub || 0)
  await loadCards()
})

const loadCards = async () => {
  loading.value = true
  try {
    const query = subject.value ? `?subject=${subject.value}` : ''
    const res: any = await http({ url: `/study/knowledge${query}`, method: 'GET', silent: true })
    if (res?.code === 0 && Array.isArray(res.data) && res.data.length) {
      cards.value = res.data
      loading.value = false
      return
    }
  } catch (error) {
    console.log('考点接口暂不可用，使用本地速记', error)
  }
  cards.value = localCards
  loading.value = false
}

const switchSubject = (value: number) => {
  subject.value = value
  opened.value = null
  loadCards()
}

const toggle = (id: number) => {
  opened.value = opened.value === id ? null : id
}
</script>

<template>
  <view class="page">
    <view class="tabs">
      <view :class="['tab', subject === 1 ? 'active' : '']" @click="switchSubject(1)">科目一</view>
      <view :class="['tab', subject === 4 ? 'active' : '']" @click="switchSubject(4)">科目四</view>
    </view>
    <view v-if="loading" class="empty">正在整理考点...</view>
    <view v-else-if="!visibleCards.length" class="empty">这个科目还没有速记卡片</view>
    <view v-for="card in visibleCards" :key="card.id" class="card" @click="toggle(card.id)">
      <text class="category">{{ card.category }}</text>
      <text class="title">{{ card.title }}</text>
      <text v-if="opened === card.id" class="content">{{ card.content }}</text>
      <text v-else class="hint">点开查看口诀</text>
    </view>
  </view>
</template>

<style lang="scss" scoped>
.page {
  min-height: 100vh;
  max-width: 480px;
  margin: 0 auto;
  background: #f3f6f4;
  padding: 24rpx;
  box-sizing: border-box;
}

.tabs {
  display: flex;
  gap: 16rpx;
  margin-bottom: 20rpx;
}

.tab {
  flex: 1;
  text-align: center;
  padding: 18rpx 0;
  border-radius: 16rpx;
  background: #fff;
  color: #4b5563;
}

.tab.active {
  background: #0f766e;
  color: #fff;
  font-weight: 600;
}

.card {
  background: #fff;
  border-radius: 24rpx;
  padding: 28rpx;
  margin-bottom: 16rpx;
}

.category {
  display: block;
  color: #0f766e;
  font-size: 22rpx;
  font-weight: 700;
}

.title {
  display: block;
  margin-top: 8rpx;
  font-size: 32rpx;
  font-weight: 700;
  color: #10221f;
}

.content,
.hint {
  display: block;
  margin-top: 14rpx;
  font-size: 26rpx;
  line-height: 1.7;
  color: #374151;
}

.hint {
  color: #9ca3af;
}

.empty {
  padding: 40rpx;
  text-align: center;
  color: #6b7280;
}
</style>
