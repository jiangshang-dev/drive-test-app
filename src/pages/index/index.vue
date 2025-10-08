<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { vipChecker } from '@/utils/vipChecker'

const activeTab = ref(0)
const rewardedAd = ref(null)
const pendingSub = ref<number | null>(null)
const examClickCount = ref(0)

const urlCallback = ref<{ userId?: number; extra?: number }>({})

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
  const hasAccess = await vipChecker.checkVipAccess(true) // 假设视频页面需要VIP权限
  if (!hasAccess) {
    return // 如果没有权限，直接返回
  }

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
})

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
    <!-- 顶部导航栏 -->
    <view class="header">
      <view class="header-content">
        <text class="logo">驾考通</text>
        <!-- <view class="header-right">
          <text class="search-icon">🔍</text>
          <text class="profile-icon" @click="goToProfile()">👤</text>
        </view> -->
      </view>
    </view>

    <!-- 主要内容区域 -->
    <view class="main-content">
      <!-- 轮播图区域 -->
      <view class="banner-section">
        <view class="banner">
          <view class="banner-item active">
            <image
              class="banner-img"
              src="https://via.placeholder.com/350x150/4CAF50/white?text=VIP会员特惠"
              mode="aspectFit"
            ></image>
            <view class="banner-text">
              <text class="banner-title">VIP会员限时特惠</text>
              <text class="banner-desc">解锁全部视频教程</text>
            </view>
          </view>
        </view>
      </view>

      <!-- 科目选择标签 -->
      <view class="subject-tabs">
        <view :class="['tab-item', activeTab === 0 ? 'active' : '']" @click="switchTab(0)">
          科目一
        </view>
        <view :class="['tab-item', activeTab === 1 ? 'active' : '']" @click="switchTab(1)">
          科目四
        </view>
      </view>

      <!-- 功能模块网格 -->
      <view class="function-grid">
        <view class="grid-item" @click="goToVideos()">
          <text class="grid-icon">▶️</text>
          <text class="grid-text">交规视频</text>
          <view class="vip-badge">VIP</view>
        </view>
        <view class="grid-item" @click="navigateTo('sequential', activeTab === 0 ? 1 : 4)">
          <text class="grid-icon">✏️</text>
          <text class="grid-text">驾考刷题</text>
        </view>
        <view class="grid-item" @click="handleExamClick(activeTab === 0 ? 1 : 4)">
          <text class="grid-icon">📋</text>
          <text class="grid-text">模拟考试</text>
        </view>
        <view class="grid-item" @click="goToWrongQuestions()">
          <text class="grid-icon">⚠️</text>
          <text class="grid-text">错题本</text>
        </view>
        <view class="grid-item" @click="goToFavorites()">
          <text class="grid-icon">❤️</text>
          <text class="grid-text">我的收藏</text>
        </view>
        <view class="grid-item" @click="goToPoints()">
          <text class="grid-icon">🪙</text>
          <text class="grid-text">我的积分</text>
        </view>
      </view>

      <!-- 推荐内容 -->
      <view class="recommended-section">
        <text class="section-title">热门推荐</text>
        <view class="video-list">
          <view class="video-item" @click="goToTrafficSigns()">
            <image
              src="https://driver-exam-plus.oss-cn-beijing.aliyuncs.com/j1833b72a69341f242e90fe16d017c61d.jpg"
              mode="aspectFit"
            ></image>
            <view class="video-info">
              <text class="video-title">交通标志图示详解</text>
              <!--              <text class="video-duration">学习时长: 15分钟</text>
              <view class="video-stats">
                <text>👍 1.2k</text>
                <text>❤️ 856</text>
              </view>-->
            </view>
            <!-- <view class="vip-overlay">
              <text class="vip-lock">🔒</text>
              <text>VIP专享</text>
            </view> -->
          </view>
          <view v-if="false" class="video-item" @click="playVideo(2)">
            <image
              src="https://via.placeholder.com/120x80/FF9800/white?text=视频2"
              mode="aspectFit"
            ></image>
            <view class="video-info">
              <text class="video-title">科目一技巧总结</text>
              <text class="video-duration">学习时长: 20分钟</text>
              <view class="video-stats">
                <text>👍 2.1k</text>
                <text>❤️ 1.3k</text>
              </view>
            </view>
            <view class="vip-overlay">
              <text class="vip-lock">🔒</text>
              <text>VIP专享</text>
            </view>
          </view>
        </view>
      </view>

      <!-- 学习进度 -->
      <view class="progress-section">
        <text class="section-title">学习进度</text>
        <view class="progress-card">
          <view class="progress-item">
            <text class="progress-label">科目一</text>
            <view class="progress-bar">
              <view class="progress-fill" style="width: 75%"></view>
            </view>
            <text class="progress-percent">75%</text>
          </view>
          <view class="progress-item">
            <text class="progress-label">科目四</text>
            <view class="progress-bar">
              <view class="progress-fill" style="width: 45%"></view>
            </view>
            <text class="progress-percent">45%</text>
          </view>
        </view>
      </view>
    </view>

    <!-- <ad-rewarded-video
		  :url-callback="urlCallback"
		  class='ad-video'
		  ref="rewardedAd"
		  adpid="1315895981"
		  :loadnext="true"
		  @close="handleAdClose"
		  v-slot:default="{loading, error}">
			<button :disabled="loading" :loading="loading" style="display: none;"></button>
			<view v-if="error">{{error}}</view>
		</ad-rewarded-video> -->

    <!-- 信息流广告移动到最下方 -->
    <!-- <view class="ad-view">
		      <ad adpid="1478175623" @load="onload" @close="onclose" @error="onerror"></ad>
		</view> -->

    <!-- <view class="content">
		    <ad-interstitial adpid="1939256856" :loadnext="true" v-slot:default="{loading, error}" @load="onadload" @close="onadclose" @error="onaderror">
		      <button :disabled="loading" :loading="loading">显示广告</button>
		      <view v-if="error">{{error}}</view>
		    </ad-interstitial>
		  </view> -->
  </view>
</template>

<style lang="scss">
/* 通用样式 - 移除通用选择器，使用具体的元素 */
view,
text,
image,
button {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

.page {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background-color: #f5f5f5;
  color: #333;
  line-height: 1.6;
  padding-bottom: 140rpx;
}

/* 顶部导航栏 */
.header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 20rpx 0;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.1);
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 40rpx;
  max-width: 960rpx;
  margin: 0 auto;
}

.logo {
  font-size: 48rpx;
  font-weight: bold;
}

.header-right {
  display: flex;
  gap: 30rpx;
  align-items: center;
}

.search-icon,
.profile-icon {
  font-size: 40rpx;
  transition: opacity 0.3s ease;
}

/* 主要内容区域 */
.main-content {
  margin-top: 120rpx;
  padding: 40rpx;
  max-width: 960rpx;
  margin-left: auto;
  margin-right: auto;
}

/* 轮播图区域 */
.banner-section {
  margin-bottom: 50rpx;
}

.banner {
  position: relative;
  border-radius: 30rpx;
  overflow: hidden;
  box-shadow: 0 8rpx 40rpx rgba(0, 0, 0, 0.1);
}

.banner-item {
  position: relative;
  height: 320rpx;
  background: linear-gradient(135deg, #4caf50 0%, #45a049 100%);
  display: flex;
  align-items: center;
  padding: 40rpx;
  color: white;
}

.banner-img {
  width: 100%;
  height: 100%;
  position: absolute;
  top: 0;
  left: 0;
  z-index: 1;
}

.banner-text {
  position: relative;
  z-index: 2;
}

.banner-title {
  font-size: 44rpx;
  font-weight: bold;
  margin-bottom: 16rpx;
  display: block;
}

.banner-desc {
  font-size: 28rpx;
  opacity: 0.9;
  display: block;
}

/* 科目选择标签 */
.subject-tabs {
  display: flex;
  background: white;
  border-radius: 24rpx;
  padding: 10rpx;
  margin-bottom: 50rpx;
  box-shadow: 0 4rpx 24rpx rgba(0, 0, 0, 0.08);
}

.tab-item {
  flex: 1;
  text-align: center;
  padding: 24rpx;
  border-radius: 16rpx;
  font-weight: 500;
  transition: all 0.3s ease;
  color: #666;
  font-size: 28rpx;
}

.tab-item.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 0 4rpx 16rpx rgba(102, 126, 234, 0.3);
}

/* 功能模块网格 */
.function-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 30rpx;
  margin-bottom: 60rpx;
}

.grid-item {
  background: white;
  border-radius: 30rpx;
  padding: 40rpx 30rpx;
  text-align: center;
  box-shadow: 0 4rpx 30rpx rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.grid-icon {
  font-size: 56rpx;
  margin-bottom: 20rpx;
  display: block;
  transition: transform 0.3s ease;
}

.grid-text {
  font-size: 28rpx;
  font-weight: 500;
  color: #333;
  display: block;
}

.vip-badge {
  position: absolute;
  top: 10rpx;
  right: 10rpx;
  background: linear-gradient(45deg, #ffd700, #ffa500);
  color: white;
  font-size: 20rpx;
  padding: 4rpx 12rpx;
  border-radius: 16rpx;
  font-weight: bold;
}

/* 节标题 */
.section-title {
  font-size: 36rpx;
  font-weight: 600;
  margin-bottom: 30rpx;
  color: #333;
  display: block;
}

/* 推荐内容 */
.recommended-section {
  margin-bottom: 60rpx;
}

.video-list {
  display: flex;
  flex-direction: column;
  gap: 30rpx;
}

.video-item {
  display: flex;
  background: white;
  border-radius: 24rpx;
  padding: 30rpx;
  box-shadow: 0 4rpx 24rpx rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.video-item image {
  width: 240rpx;
  height: 160rpx;
  border-radius: 16rpx;
  margin-right: 30rpx;
}

.video-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.video-title {
  font-size: 32rpx;
  font-weight: 600;
  margin-bottom: 10rpx;
  color: #333;
  display: block;
}

.video-duration {
  font-size: 24rpx;
  color: #666;
  margin-bottom: 20rpx;
  display: block;
}

.video-stats {
  display: flex;
  gap: 30rpx;
  font-size: 24rpx;
  color: #999;
}

.vip-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  color: white;
  font-size: 28rpx;
  gap: 10rpx;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.vip-overlay .vip-lock {
  font-size: 48rpx;
  color: #ffd700;
}

.video-item:active .vip-overlay {
  opacity: 1;
}

/* 学习进度 */
.progress-section {
  margin-bottom: 60rpx;
}

.progress-card {
  background: white;
  border-radius: 30rpx;
  padding: 40rpx;
  box-shadow: 0 4rpx 30rpx rgba(0, 0, 0, 0.08);
}

.progress-item {
  display: flex;
  align-items: center;
  margin-bottom: 50rpx;
}

.progress-item:last-child {
  margin-bottom: 0;
}

.progress-label {
  width: 120rpx;
  font-size: 28rpx;
  font-weight: 500;
  color: #333;
}

.progress-bar {
  flex: 1;
  height: 16rpx;
  background: #f0f0f0;
  border-radius: 8rpx;
  margin: 0 30rpx;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
  border-radius: 8rpx;
  transition: width 0.5s ease;
}

.progress-percent {
  font-size: 28rpx;
  font-weight: 600;
  color: #667eea;
  min-width: 80rpx;
  text-align: right;
}

/* 底部导航栏 */
.bottom-nav {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: white;
  display: flex;
  border-top: 1px solid #e0e0e0;
  box-shadow: 0 -4rpx 20rpx rgba(0, 0, 0, 0.1);
  z-index: 1000;
}

.nav-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 16rpx 0;
  transition: color 0.3s ease;
  color: #999;
}

.nav-item.active {
  color: #667eea;
}

.nav-icon {
  font-size: 40rpx;
  margin-bottom: 8rpx;
}

.nav-text {
  font-size: 24rpx;
}

// 保留原有的广告样式
.ad-view {
  background-color: #ffffff;
  margin-bottom: 10px;
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
}

.ad-video {
  width: 100%;
}
</style>
