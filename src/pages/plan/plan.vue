<script setup lang="ts">
import { computed, ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { http } from '@/utils/http'
import { getCurrentExamType } from '@/utils/examTypeHelper'
import { useExamTypeStore, useMemberStore } from '@/stores'

const examTypeStore = useExamTypeStore()
const memberStore = useMemberStore()
const subject = ref(1)
const examDate = ref('')
const targetScore = ref('90')
const dailyGoal = ref('20')
const streak = ref(0)
const checkedToday = ref(false)
const todayCount = ref(0)

const daysLeft = computed(() => {
  if (!examDate.value) return null
  const target = new Date(examDate.value.replace(/-/g, '/'))
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  target.setHours(0, 0, 0, 0)
  return Math.max(Math.round((target.getTime() - today.getTime()) / 86400000), 0)
})

const cacheKey = 'exam_plan_local'

const formatPlanDate = (value: any) => {
  if (!value) return ''
  if (Array.isArray(value) && value.length >= 3) {
    const [year, month, day] = value
    return `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`
  }
  return String(value).slice(0, 10)
}

onShow(() => {
  const cached = uni.getStorageSync(cacheKey)
  if (cached) {
    subject.value = cached.subject || 1
    examDate.value = cached.examDate || ''
    targetScore.value = String(cached.targetScore || 90)
    dailyGoal.value = String(cached.dailyGoal || 20)
  }
  loadSummary()
})

const loadSummary = async () => {
  try {
    const res: any = await http({ url: '/study/summary', method: 'GET', silent: true })
    if (res?.code !== 0 || !res.data) return
    streak.value = res.data.streak || 0
    checkedToday.value = !!res.data.checkedToday
    todayCount.value = res.data.todayCount || 0
    if (res.data.plan) {
      subject.value = res.data.plan.subject || subject.value
      examDate.value = formatPlanDate(res.data.plan.examDate) || examDate.value
      targetScore.value = String(res.data.plan.targetScore || targetScore.value)
      dailyGoal.value = String(res.data.plan.dailyGoal || dailyGoal.value)
    }
  } catch (error) {
    console.log('考试计划暂不可用', error)
  }
}

const onDateChange = (event: any) => {
  examDate.value = event.detail.value
}

const savePlan = async () => {
  if (!examDate.value) {
    uni.showToast({ title: '先选考试日期', icon: 'none' })
    return
  }
  const payload = {
    subject: subject.value,
    examType: getCurrentExamType(),
    examDate: examDate.value,
    targetScore: Number(targetScore.value) || 90,
    dailyGoal: Number(dailyGoal.value) || 20,
  }
  uni.setStorageSync(cacheKey, payload)
  if (!memberStore.profile) {
    uni.showToast({ title: '已保存在本机，登录后可同步', icon: 'none' })
    return
  }
  try {
    const res: any = await http({ url: '/study/plan', method: 'POST', data: payload })
    if (res?.code === 0) {
      uni.showToast({ title: '计划已保存', icon: 'success' })
      return
    }
    uni.showToast({ title: res?.msg || '保存失败', icon: 'none' })
  } catch (error) {
    uni.showToast({ title: '已保存在本机', icon: 'none' })
  }
}

const checkin = async () => {
  if (!memberStore.profile) {
    uni.navigateTo({ url: '/pages/login/login' })
    return
  }
  try {
    const res: any = await http({
      url: '/study/checkin',
      method: 'POST',
      data: {
        subject: subject.value,
        examType: examTypeStore.getExamTypeCode(),
        questionCount: 0,
        correctCount: 0,
      },
    })
    if (res?.code === 0 && res.data) {
      streak.value = res.data.streak || streak.value
      checkedToday.value = true
      uni.showToast({ title: '今日已打卡', icon: 'success' })
      return
    }
    uni.showToast({ title: res?.msg || '打卡失败', icon: 'none' })
  } catch (error) {
    uni.showToast({ title: '打卡失败', icon: 'none' })
  }
}

const goDaily = () => {
  uni.navigateTo({ url: `/pages/daily/daily?sub=${subject.value}` })
}
</script>

<template>
  <view class="page">
    <view class="hero">
      <text class="kicker">{{ examTypeStore.getExamTypeName() }}</text>
      <text class="days">{{ daysLeft === null ? '未设定' : daysLeft + ' 天' }}</text>
      <text class="desc">{{ examDate ? examDate + ' 考试' : '选一个考试日期' }}</text>
      <view class="mini">
        <text>连续 {{ streak }} 天</text>
        <text>今日 {{ todayCount }} 题</text>
        <text>{{ checkedToday ? '已打卡' : '未打卡' }}</text>
      </view>
    </view>

    <view class="card">
      <text class="label">科目</text>
      <view class="tabs">
        <view :class="['tab', subject === 1 ? 'active' : '']" @click="subject = 1">科目一</view>
        <view :class="['tab', subject === 4 ? 'active' : '']" @click="subject = 4">科目四</view>
      </view>
      <text class="label">考试日期</text>
      <picker mode="date" :value="examDate" @change="onDateChange">
        <view class="field">{{ examDate || '选择日期' }}</view>
      </picker>
      <text class="label">目标分数</text>
      <input class="field" type="number" v-model="targetScore" />
      <text class="label">每日题量</text>
      <input class="field" type="number" v-model="dailyGoal" />
      <button class="primary" @click="savePlan">保存计划</button>
    </view>

    <view class="actions">
      <button class="ghost" @click="checkin">今日打卡</button>
      <button class="primary slim" @click="goDaily">去做每日一练</button>
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

.hero,
.card {
  background: #fff;
  border-radius: 28rpx;
  padding: 32rpx 28rpx;
}

.hero {
  background: #10221f;
  color: #fff;
}

.kicker,
.desc {
  display: block;
  font-size: 24rpx;
  opacity: 0.8;
}

.days {
  display: block;
  margin: 12rpx 0;
  font-size: 64rpx;
  font-weight: 700;
}

.mini {
  display: flex;
  gap: 20rpx;
  margin-top: 20rpx;
  font-size: 24rpx;
}

.card {
  margin-top: 20rpx;
}

.label {
  display: block;
  margin: 18rpx 0 10rpx;
  font-size: 24rpx;
  color: #6b7280;
}

.tabs {
  display: flex;
  gap: 12rpx;
}

.tab,
.field {
  background: #f4f7f6;
  border-radius: 16rpx;
  padding: 20rpx;
  color: #10221f;
}

.tab {
  flex: 1;
  text-align: center;
}

.tab.active {
  background: #0f766e;
  color: #fff;
}

.actions {
  display: flex;
  gap: 16rpx;
  margin-top: 20rpx;
}

.primary,
.ghost,
.slim {
  border-radius: 16rpx;
  font-size: 28rpx;
}

.primary {
  margin-top: 28rpx;
  background: #0f766e;
  color: #fff;
}

.slim {
  flex: 1;
  margin-top: 0;
}

.ghost {
  flex: 1;
  background: #fff;
  color: #0f766e;
}
</style>
