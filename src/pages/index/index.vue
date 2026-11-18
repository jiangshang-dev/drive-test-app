<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { vipChecker } from '@/utils/vipChecker'
import { http } from '@/utils/http'
import { useExamTypeStore } from '@/stores'
import ExamTypeSelector from '@/components/ExamTypeSelector.vue'

const activeTab = ref(0)
const rewardedAd = ref(null)
const pendingSub = ref<number | null>(null)
const examClickCount = ref(0)

const urlCallback = ref<{ userId?: number; extra?: number }>({})
const examTypeStore = useExamTypeStore()
const examTypeSelectorRef = ref()
const studySummary = ref({
  streak: 0,
  checkedToday: false,
  todayCount: 0,
  plan: null as null | { daysLeft?: number; dailyGoal?: number; examDate?: string; targetScore?: number },
})

const examTypeName = computed(() => examTypeStore.getExamTypeName())
const continueIndex = ref(0)
const refreshContinue = () => {
  const subject = activeTab.value === 0 ? 1 : 4
  const key = `practice_progress_${subject}_${examTypeStore.getExamTypeCode()}_all`
  continueIndex.value = Number(uni.getStorageSync(key) || 0)
}

const openExamType = () => {
  examTypeSelectorRef.value?.handleShowSelector?.()
}

const loadSummary = async () => {
  try {
    const res: any = await http({ url: '/study/summary', method: 'GET', silent: true })
    if (res && res.code === 0 && res.data) {
      studySummary.value = res.data
    }
  } catch (error) {
    console.log('学习概览暂不可用', error)
  }
}

const goToDaily = () => {
  uni.navigateTo({ url: `/pages/daily/daily?sub=${activeTab.value === 0 ? 1 : 4}` })
}

const goToKnowledge = () => {
  uni.navigateTo({ url: `/pages/knowledge/knowledge?sub=${activeTab.value === 0 ? 1 : 4}` })
}

const goToPlan = () => {
  uni.navigateTo({ url: '/pages/plan/plan' })
}

const goToSpecial = (questionType: string) => {
  uni.navigateTo({
    url: `/pages/index/sequential/sequential?sub=${activeTab.value === 0 ? 1 : 4}&questionType=${questionType}`,
  })
}

const getDailyClickCount = () => {
  const today = new Date().toDateString()
  const stored = uni.getStorageSync('examClickCount') || { date: '', count: 0 }
  if (stored.date !== today) {
    stored.date = today
    stored.count = 3
    uni.setStorageSync('examClickCount', stored)
  }
  return stored.count
}

const switchTab = (index: number) => {
  activeTab.value = index
  refreshContinue()
}

const navigateTo = (type: string, sub: number) => {
  uni.navigateTo({
    url: `/pages/index/${type}/${type}?sub=${sub}`,
  })
}

// 功能页面跳转方法
const goToVideos = async () => {
  console.log('跳转到交规视频页面')

  // 检查是否有VIP权限要求
  /* const hasAccess = await vipChecker.checkVipAccess(true) // 假设视频页面需要VIP权限
  if (!hasAccess) {
    return // 如果没有权限，直接返回
  } */

  uni.navigateTo({
    url: '/pages/videos/videos',
    success: () => {
      console.log('交规视频页面跳转成功')
    },
    fail: (err) => {
      console.error('交规视频页面跳转失败:', err)
      uni.showToast({
        title: '跳转失败',
        icon: 'error',
      })
    },
  })
}

const goToWrongQuestions = async () => {
  console.log('跳转到错题本页面')

  // 检查是否有VIP权限要求
  const hasAccess = await vipChecker.checkVipAccess(false) // 假设错题本不需要VIP权限
  if (!hasAccess) {
    return // 如果没有权限，直接返回
  }

  uni.navigateTo({
    url: '/pages/wrong-questions/wrong-questions',
    success: () => {
      console.log('错题本页面跳转成功')
    },
    fail: (err) => {
      console.error('错题本页面跳转失败:', err)
      uni.showToast({
        title: '跳转失败',
        icon: 'error',
      })
    },
  })
}

const goToFavorites = async () => {
  console.log('跳转到我的收藏页面')

  // 检查是否有VIP权限要求
  const hasAccess = await vipChecker.checkVipAccess(false) // 假设收藏不需要VIP权限
  if (!hasAccess) {
    return // 如果没有权限，直接返回
  }

  uni.navigateTo({
    url: '/pages/favorites/favorites',
    success: () => {
      console.log('我的收藏页面跳转成功')
    },
    fail: (err) => {
      console.error('我的收藏页面跳转失败:', err)
      uni.showToast({
        title: '跳转失败',
        icon: 'error',
      })
    },
  })
}

const goToAI = async () => {
  // 检查是否有VIP权限要求
  const hasAccess = await vipChecker.checkVipAccess(false) // 假设积分商城不需要VIP权限
  if (!hasAccess) {
    return // 如果没有权限，直接返回
  }

  uni.navigateTo({
    url: '/pages/aichat/aichat',
    success: () => {
      console.log('AI页面跳转成功')
    },
    fail: (err) => {
      console.error('AI页面跳转失败:', err)
      uni.showToast({
        title: '跳转失败',
        icon: 'error',
      })
    },
  })
}

const goToPoints = async () => {
  console.log('跳转到积分商城页面')

  // 检查是否有VIP权限要求
  const hasAccess = await vipChecker.checkVipAccess(false) // 假设积分商城不需要VIP权限
  if (!hasAccess) {
    return // 如果没有权限，直接返回
  }

  uni.navigateTo({
    url: '/pages/points-mall/points-mall',
    success: () => {
      console.log('积分商城页面跳转成功')
    },
    fail: (err) => {
      console.error('积分商城页面跳转失败:', err)
      uni.showToast({
        title: '跳转失败',
        icon: 'error',
      })
    },
  })
}

const goToProfile = () => {
  uni.showToast({
    title: '个人中心',
    icon: 'none',
  })
}

const playVideo = (id: number) => {
  uni.showToast({
    title: `播放视频${id}`,
    icon: 'none',
  })
}

const handleExamClick = async (sub: number) => {
  // 检查是否有VIP权限要求
  const hasAccess = await vipChecker.checkVipAccess(false) // 假设模拟考试不需要VIP权限
  if (!hasAccess) {
    return // 如果没有权限，直接返回
  }

  navigateTo('exam', sub)

  /* const clickCount = getDailyClickCount()
  if (clickCount == 0) {
    navigateTo('exam', sub)
    return
  }

  uni.showModal({
    title: '解锁确认',
    content: '看视频要解锁模拟考试？还剩'+clickCount+'次免广告',
    success: (res) => {
      if (res.confirm) {
        const stored = uni.getStorageSync('examClickCount')
        stored.count -= 1
        uni.setStorageSync('examClickCount', stored)

        pendingSub.value = sub
        rewardedAd.value.show()
      }
    }
  }) */
}

const handleAdClose = (e: any) => {
  if (e.detail && e.detail.isEnded) {
    if (pendingSub.value !== null) {
      navigateTo('exam', pendingSub.value)
    }
    pendingSub.value = null

    let getTime = new Date().getTime()
    urlCallback.value.userId = getTime
    urlCallback.value.extra = getTime
    console.log('urlCallback.value===', urlCallback.value)
  }
}

const onload = (e: any) => {
  console.log('onload')
}
const onclose = (ez: any) => {
  // console.log("onclose: " + ez.detail)
}
const onerror = (ex: any) => {
  // console.log("onerror: " + ex.detail.errCode + " message:: " + ex.detail.errMsg)
}

onMounted(async () => {
  // App启动时检查会员状态
  await vipChecker.checkVipStatus(true)
  await loadSummary()
})

onShow(() => {
  refreshContinue()
  loadSummary()
})

watch(
  () => examTypeStore.examTypeCode,
  () => refreshContinue(),
)

const onadload = (e: any) => {
  console.log('广告数据加载成功')
}
const onadclose = (e: any) => {
  console.log('onadclose')
}
const onaderror = (e: any) => {
  // 广告加载失败
  console.log('onaderror: ')
}

const isLoading = ref(false)
const showAd = () => {
  isLoading.value = true
}

const goToTrafficSigns = async () => {
  console.log('跳转到交通标志图示详解页面')

  // 检查是否有VIP权限要求
  const hasAccess = await vipChecker.checkVipAccess(false) // 假设交通标志不需要VIP权限
  if (!hasAccess) {
    return // 如果没有权限，直接返回
  }

  uni.navigateTo({
    url: '/pages/traffic-signs/traffic-signs',
    success: () => {
      console.log('交通标志页面跳转成功')
    },
    fail: (err) => {
      console.error('交通标志页面跳转失败:', err)
      uni.showToast({
        title: '跳转失败',
        icon: 'error',
      })
    },
  })
}
</script>
<template>
  <view class="page">
    <view class="hero">
      <view class="hero-top">
        <view>
          <text class="hero-kicker">今天也把题做透</text>
          <text class="hero-title">{{ activeTab === 0 ? '科目一' : '科目四' }} · {{ examTypeName }}</text>
        </view>
        <view class="type-chip" @click="openExamType">更换车型</view>
      </view>
      <view class="subject-tabs">
        <view :class="['tab-item', activeTab === 0 ? 'active' : '']" @click="switchTab(0)">科目一</view>
        <view :class="['tab-item', activeTab === 1 ? 'active' : '']" @click="switchTab(1)">科目四</view>
      </view>
      <view class="stat-row">
        <view class="stat">
          <text class="stat-num">{{ studySummary.streak || 0 }}</text>
          <text class="stat-label">连续打卡</text>
        </view>
        <view class="stat">
          <text class="stat-num">{{ studySummary.todayCount || 0 }}</text>
          <text class="stat-label">今日题量</text>
        </view>
        <view class="stat">
          <text class="stat-num">{{ studySummary.plan ? studySummary.plan.daysLeft : '--' }}</text>
          <text class="stat-label">距考试</text>
        </view>
      </view>
    </view>

    <view class="action-row">
      <view class="action primary" @click="navigateTo('sequential', activeTab === 0 ? 1 : 4)">
        <text class="action-title">顺序刷题</text>
        <text class="action-desc">{{ continueIndex > 0 ? '继续第 ' + (continueIndex + 1) + ' 题' : '从第一题开始' }}</text>
      </view>
      <view class="action exam" @click="handleExamClick(activeTab === 0 ? 1 : 4)">
        <text class="action-title">模拟考试</text>
        <text class="action-desc">100 题限时练</text>
      </view>
    </view>

    <view class="panel">
      <text class="panel-title">今日安排</text>
      <view class="feature-list">
        <view class="feature" @click="goToDaily">
          <view class="feature-mark teal">练</view>
          <view class="feature-copy">
            <text class="feature-name">每日一练</text>
            <text class="feature-sub">10 道精选题，做完自动打卡</text>
          </view>
        </view>
        <view class="feature" @click="goToKnowledge">
          <view class="feature-mark amber">记</view>
          <view class="feature-copy">
            <text class="feature-name">考点速记</text>
            <text class="feature-sub">标志、速度、应急一口诀</text>
          </view>
        </view>
        <view class="feature" @click="goToPlan">
          <view class="feature-mark ink">期</view>
          <view class="feature-copy">
            <text class="feature-name">考试计划</text>
            <text class="feature-sub">{{ studySummary.checkedToday ? '今天已经打卡' : '设定日期，按天推进' }}</text>
          </view>
        </view>
      </view>
    </view>

    <view class="panel">
      <text class="panel-title">专项练习</text>
      <view class="topic-grid">
        <view class="topic" @click="goToSpecial('traffic_signs')">交通标志</view>
        <view class="topic" @click="goToSpecial('traffic_rules')">交通法规</view>
        <view class="topic" @click="goToSpecial('safe_driving')">安全驾驶</view>
        <view class="topic" @click="goToSpecial('emergency_handling')">应急处理</view>
      </view>
    </view>

    <view class="panel">
      <text class="panel-title">常用工具</text>
      <view class="tool-grid">
        <view class="tool" @click="goToWrongQuestions">
          <text class="tool-name">错题本</text>
        </view>
        <view class="tool" @click="goToFavorites">
          <text class="tool-name">我的收藏</text>
        </view>
        <view class="tool" @click="goToVideos">
          <text class="tool-name">交规视频</text>
        </view>
        <view class="tool" @click="goToTrafficSigns">
          <text class="tool-name">标志图解</text>
        </view>
        <view class="tool" @click="goToAI">
          <text class="tool-name">AI 助手</text>
        </view>
        <view class="tool" @click="goToPlan">
          <text class="tool-name">学习打卡</text>
        </view>
      </view>
    </view>

    <ExamTypeSelector ref="examTypeSelectorRef" />
  </view>
</template>

<style lang="scss" scoped>
.page {
  min-height: 100vh;
  max-width: 480px;
  margin: 0 auto;
  background: #f3f6f4;
  padding: 24rpx 24rpx 48rpx;
  box-sizing: border-box;
}

.hero {
  background: linear-gradient(160deg, #115e59 0%, #0f766e 58%, #14b8a6 100%);
  border-radius: 32rpx;
  padding: 36rpx 32rpx 28rpx;
  color: #fff;
}

.hero-top {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 20rpx;
}

.hero-kicker {
  display: block;
  font-size: 24rpx;
  opacity: 0.82;
}

.hero-title {
  display: block;
  margin-top: 8rpx;
  font-size: 40rpx;
  font-weight: 700;
  line-height: 1.3;
}

.type-chip {
  flex-shrink: 0;
  padding: 12rpx 22rpx;
  border-radius: 999rpx;
  background: rgba(255, 255, 255, 0.16);
  font-size: 24rpx;
}

.subject-tabs {
  display: flex;
  margin-top: 28rpx;
  padding: 6rpx;
  border-radius: 18rpx;
  background: rgba(255, 255, 255, 0.2);
}

.tab-item {
  flex: 1;
  text-align: center;
  padding: 16rpx 0;
  border-radius: 14rpx;
  font-size: 28rpx;
  color: rgba(255, 255, 255, 0.8);
}

.tab-item.active {
  background: #fff;
  color: #0f766e;
  font-weight: 600;
}

.stat-row {
  display: flex;
  margin-top: 28rpx;
}

.stat {
  flex: 1;
}

.stat-num {
  display: block;
  font-size: 40rpx;
  font-weight: 700;
}

.stat-label {
  display: block;
  margin-top: 4rpx;
  font-size: 22rpx;
  opacity: 0.8;
}

.action-row {
  display: flex;
  gap: 20rpx;
  margin-top: 24rpx;
}

.action {
  flex: 1;
  border-radius: 28rpx;
  padding: 28rpx 24rpx;
  background: #fff;
}

.action.primary {
  background: #10221f;
}

.action.exam {
  background: #fff7ed;
}

.action-title {
  display: block;
  font-size: 32rpx;
  font-weight: 700;
  color: #10221f;
}

.action.primary .action-title,
.action.primary .action-desc {
  color: #fff;
}

.action-desc {
  display: block;
  margin-top: 8rpx;
  font-size: 24rpx;
  color: #9a3412;
}

.panel {
  margin-top: 24rpx;
  padding: 28rpx 24rpx;
  background: #fff;
  border-radius: 28rpx;
}

.panel-title {
  display: block;
  margin-bottom: 20rpx;
  font-size: 30rpx;
  font-weight: 700;
  color: #10221f;
}

.feature {
  display: flex;
  align-items: center;
  padding: 18rpx 0;
}

.feature + .feature {
  border-top: 1px solid #eef2f0;
}

.feature-mark {
  width: 72rpx;
  height: 72rpx;
  border-radius: 20rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 28rpx;
  font-weight: 700;
  margin-right: 20rpx;
}

.feature-mark.teal {
  background: #0f766e;
}

.feature-mark.amber {
  background: #d97706;
}

.feature-mark.ink {
  background: #1f2937;
}

.feature-name {
  display: block;
  font-size: 30rpx;
  font-weight: 600;
  color: #10221f;
}

.feature-sub {
  display: block;
  margin-top: 4rpx;
  font-size: 24rpx;
  color: #6b7280;
}

.topic-grid,
.tool-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
}

.topic,
.tool {
  width: calc(50% - 8rpx);
  box-sizing: border-box;
  padding: 24rpx 20rpx;
  border-radius: 20rpx;
  background: #f4f7f6;
  font-size: 28rpx;
  color: #10221f;
  font-weight: 600;
}

.tool {
  width: calc(33.33% - 12rpx);
  text-align: center;
  font-weight: 500;
}
</style>
