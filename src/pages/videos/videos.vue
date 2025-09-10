<template>
  <view class="container">
    <!-- 顶部导航栏 -->
    <view class="header">
      <view class="header-content">
        <text class="logo">交规视频</text>
        <view class="header-right">
          <text class="filter-icon" @click="showFilterModal = true">筛选</text>
        </view>
      </view>
    </view>

    <!-- VIP状态提示 -->
    <view class="vip-notice" v-if="!isVipUser">
      <view class="notice-content">
        <text class="notice-icon">👑</text>
        <view class="notice-text">
          <text class="notice-title">开通VIP会员</text>
          <text class="notice-desc">解锁全部交规视频教程</text>
        </view>
        <text class="upgrade-btn" @click="showVipModal = true">立即开通</text>
      </view>
    </view>

    <!-- 快速入口卡片 -->
    <view class="quick-access-card">
      <view class="access-content" @click="goToTrafficSigns">
        <view class="access-icon">
          <text class="icon-text">🚦</text>
        </view>
        <view class="access-info">
          <text class="access-title">交通标志图示详解</text>
          <text class="access-desc">查看各种交通标志的详细说明和使用场景</text>
        </view>
        <text class="access-arrow">›</text>
      </view>
    </view>

    <!-- 视频分类标签 -->
    <view class="category-tabs">
      <view
        :class="['tab-item', selectedCategory === 'all' ? 'active' : '']"
        @click="selectCategory('all')"
      >
        全部
      </view>
      <view
        :class="['tab-item', selectedCategory === 'traffic-signs' ? 'active' : '']"
        @click="selectCategory('traffic-signs')"
      >
        交通标志
      </view>
      <view
        :class="['tab-item', selectedCategory === 'traffic-rules' ? 'active' : '']"
        @click="selectCategory('traffic-rules')"
      >
        交通法规
      </view>
      <view
        :class="['tab-item', selectedCategory === 'driving-skills' ? 'active' : '']"
        @click="selectCategory('driving-skills')"
      >
        驾驶技巧
      </view>
    </view>

    <!-- 视频列表 -->
    <view class="videos-list">
      <view
        v-for="(video, index) in filteredVideos"
        :key="index"
        class="video-card"
        @click="playVideo(video)"
      >
        <view class="video-thumbnail">
          <image class="thumbnail-img" :src="video.thumbnail" mode="aspectFill" />
          <view class="play-overlay">
            <text class="play-icon">▶️</text>
          </view>
          <text class="video-duration">{{ video.duration }}</text>
          <view v-if="video.isVip && !isVipUser" class="vip-badge">VIP</view>
        </view>

        <view class="video-info">
          <text class="video-title">{{ video.title }}</text>
          <text class="video-desc">{{ video.description }}</text>

          <view class="video-meta">
            <view class="meta-item">
              <text class="meta-icon">👁</text>
              <text class="meta-text">{{ video.views }}</text>
            </view>
            <view class="meta-item">
              <text class="meta-icon">👍</text>
              <text class="meta-text">{{ video.likes }}</text>
            </view>
            <view class="meta-item">
              <text class="meta-icon">⭐</text>
              <text class="meta-text">{{ video.rating }}</text>
            </view>
          </view>
        </view>
      </view>
    </view>

    <!-- 空状态 -->
    <view v-if="filteredVideos.length === 0" class="empty-state">
      <text class="empty-icon">📹</text>
      <text class="empty-title">暂无视频</text>
      <text class="empty-desc">该分类下暂时没有视频内容</text>
    </view>

    <!-- 筛选弹窗 -->
    <view v-if="showFilterModal" class="modal" @click="showFilterModal = false">
      <view class="modal-content" @click.stop>
        <view class="modal-header">
          <text class="modal-title">筛选视频</text>
          <text class="close" @click="showFilterModal = false">&times;</text>
        </view>
        <view class="modal-body">
          <view class="filter-section">
            <text class="filter-title">按难度筛选</text>
            <view class="filter-options">
              <view
                v-for="option in difficultyOptions"
                :key="option.value"
                class="filter-option"
                :class="{ active: selectedDifficulty === option.value }"
                @click="selectDifficulty(option.value)"
              >
                {{ option.label }}
              </view>
            </view>
          </view>

          <view class="filter-section">
            <text class="filter-title">按时长筛选</text>
            <view class="filter-options">
              <view
                v-for="option in durationOptions"
                :key="option.value"
                class="filter-option"
                :class="{ active: selectedDuration === option.value }"
                @click="selectDuration(option.value)"
              >
                {{ option.label }}
              </view>
            </view>
          </view>
        </view>
      </view>
    </view>

    <!-- VIP开通弹窗 -->
    <view v-if="showVipModal" class="modal" @click="showVipModal = false">
      <view class="modal-content" @click.stop>
        <view class="modal-header">
          <text class="modal-title">开通VIP会员</text>
          <text class="close" @click="showVipModal = false">&times;</text>
        </view>
        <view class="modal-body">
          <view class="vip-benefits">
            <text class="benefits-title">VIP专享特权</text>
            <view class="benefit-item">
              <text class="benefit-icon">✓</text>
              <text class="benefit-text">解锁全部交规视频</text>
            </view>
            <view class="benefit-item">
              <text class="benefit-icon">✓</text>
              <text class="benefit-text">高清无广告播放</text>
            </view>
            <view class="benefit-item">
              <text class="benefit-icon">✓</text>
              <text class="benefit-text">支持离线下载</text>
            </view>
            <view class="benefit-item">
              <text class="benefit-icon">✓</text>
              <text class="benefit-text">专属学习计划</text>
            </view>
          </view>
          <button class="vip-btn" @click="upgradeToVip">立即开通</button>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'

// 数据状态
const isVipUser = ref(false) // 模拟VIP状态
const selectedCategory = ref('all')
const showFilterModal = ref(false)
const showVipModal = ref(false)
const selectedDifficulty = ref('all')
const selectedDuration = ref('all')

// 筛选选项
const difficultyOptions = ref([
  { label: '全部难度', value: 'all' },
  { label: '基础', value: 'basic' },
  { label: '进阶', value: 'intermediate' },
  { label: '高级', value: 'advanced' },
])

const durationOptions = ref([
  { label: '全部时长', value: 'all' },
  { label: '5分钟以内', value: 'short' },
  { label: '5-15分钟', value: 'medium' },
  { label: '15分钟以上', value: 'long' },
])

// 模拟视频数据
const videos = ref([
  {
    id: 1,
    title: '交通标志完全指南',
    description: '详细讲解各种交通标志的含义和应用场景',
    thumbnail: 'https://via.placeholder.com/300x180/667eea/white?text=交通标志',
    duration: '15:30',
    views: '12.5k',
    likes: '856',
    rating: '4.8',
    category: 'traffic-signs',
    difficulty: 'basic',
    isVip: false,
  },
  {
    id: 2,
    title: '科目一理论精讲',
    description: '科目一考试重点理论知识详细解析',
    thumbnail: 'https://via.placeholder.com/300x180/4caf50/white?text=理论精讲',
    duration: '25:42',
    views: '8.9k',
    likes: '642',
    rating: '4.9',
    category: 'traffic-rules',
    difficulty: 'intermediate',
    isVip: true,
  },
  {
    id: 3,
    title: '安全驾驶技巧',
    description: '实用的安全驾驶技巧和注意事项',
    thumbnail: 'https://via.placeholder.com/300x180/ff9800/white?text=安全驾驶',
    duration: '18:15',
    views: '15.2k',
    likes: '1.2k',
    rating: '4.7',
    category: 'driving-skills',
    difficulty: 'basic',
    isVip: false,
  },
  {
    id: 4,
    title: '道路标线识别',
    description: '各种道路标线的识别方法和通行规则',
    thumbnail: 'https://via.placeholder.com/300x180/e91e63/white?text=道路标线',
    duration: '12:08',
    views: '6.7k',
    likes: '428',
    rating: '4.6',
    category: 'traffic-signs',
    difficulty: 'intermediate',
    isVip: true,
  },
  {
    id: 5,
    title: '违法行为及处罚',
    description: '常见违法行为分析及相应处罚标准',
    thumbnail: 'https://via.placeholder.com/300x180/9c27b0/white?text=违法处罚',
    duration: '22:36',
    views: '9.3k',
    likes: '567',
    rating: '4.5',
    category: 'traffic-rules',
    difficulty: 'advanced',
    isVip: true,
  },
  {
    id: 6,
    title: '复杂路况应对',
    description: '恶劣天气和复杂路况的驾驶技巧',
    thumbnail: 'https://via.placeholder.com/300x180/607d8b/white?text=复杂路况',
    duration: '19:24',
    views: '4.1k',
    likes: '312',
    rating: '4.8',
    category: 'driving-skills',
    difficulty: 'advanced',
    isVip: true,
  },
])

// 筛选后的视频列表
const filteredVideos = computed(() => {
  let filtered = videos.value

  // 按分类筛选
  if (selectedCategory.value !== 'all') {
    filtered = filtered.filter((video) => video.category === selectedCategory.value)
  }

  // 按难度筛选
  if (selectedDifficulty.value !== 'all') {
    filtered = filtered.filter((video) => video.difficulty === selectedDifficulty.value)
  }

  // 按时长筛选
  if (selectedDuration.value !== 'all') {
    filtered = filtered.filter((video) => {
      const duration = parseInt(video.duration.split(':')[0])
      switch (selectedDuration.value) {
        case 'short':
          return duration < 5
        case 'medium':
          return duration >= 5 && duration <= 15
        case 'long':
          return duration > 15
        default:
          return true
      }
    })
  }

  return filtered
})

// 方法
const selectCategory = (category) => {
  selectedCategory.value = category
}

const selectDifficulty = (difficulty) => {
  selectedDifficulty.value = difficulty
}

const selectDuration = (duration) => {
  selectedDuration.value = duration
}

const playVideo = (video) => {
  if (video.isVip && !isVipUser.value) {
    showVipModal.value = true
    return
  }

  // 这里可以实现实际的视频播放逻辑
  uni.showModal({
    title: '播放视频',
    content: `正在播放: ${video.title}`,
    showCancel: false,
    confirmText: '确定',
  })
}

const upgradeToVip = () => {
  // 跳转到VIP购买页面或调用支付接口
  uni.showToast({
    title: 'VIP开通功能开发中',
    icon: 'none',
  })
  showVipModal.value = false
}

const goToTrafficSigns = () => {
  console.log('从交规视频页面跳转到交通标志详解页面')
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

onMounted(() => {
  // 初始化时可以从服务器获取用户VIP状态
  // isVipUser.value = checkUserVipStatus()
})
</script>

<style lang="scss" scoped>
/* 基础样式 */
.container {
  min-height: 100vh;
  background-color: #f5f5f5;
  padding-bottom: 120px;
}

/* 顶部导航栏 */
.header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 8px 0 8px;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  padding-top: calc(8px + 14px);
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;
}

.logo {
  font-size: 20px;
  font-weight: bold;
}

.filter-icon {
  font-size: 14px;
  padding: 6px 12px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 15px;
  cursor: pointer;
}

/* VIP提示 */
.vip-notice {
  margin: 80px 20px 20px;
  background: linear-gradient(135deg, #ffd700 0%, #ffa500 100%);
  border-radius: 15px;
  padding: 15px 20px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
}

.notice-content {
  display: flex;
  align-items: center;
  gap: 15px;
}

.notice-icon {
  font-size: 24px;
}

.notice-text {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.notice-title {
  font-size: 16px;
  font-weight: bold;
  color: white;
  margin-bottom: 4px;
}

.notice-desc {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.9);
}

.upgrade-btn {
  background: white;
  color: #ffa500;
  font-size: 12px;
  font-weight: bold;
  padding: 8px 16px;
  border-radius: 20px;
  cursor: pointer;
}

/* 分类标签 */
.category-tabs {
  display: flex;
  background: white;
  border-radius: 24px;
  padding: 10px;
  margin: 0 20px 20px;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.08);
}

.tab-item {
  flex: 1;
  text-align: center;
  padding: 10px 8px;
  border-radius: 16px;
  font-weight: 500;
  transition: all 0.3s ease;
  color: #666;
  font-size: 12px;
  cursor: pointer;
}

.tab-item.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.3);
}

/* 视频列表 */
.videos-list {
  padding: 0 20px;
}

.video-card {
  background: white;
  border-radius: 15px;
  margin-bottom: 20px;
  overflow: hidden;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  cursor: pointer;
}

.video-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.12);
}

.video-thumbnail {
  position: relative;
  height: 180px;
  overflow: hidden;
}

.thumbnail-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.play-overlay {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background: rgba(0, 0, 0, 0.7);
  width: 60px;
  height: 60px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
}

.play-icon {
  font-size: 20px;
  color: white;
  margin-left: 4px;
}

.video-duration {
  position: absolute;
  bottom: 10px;
  right: 10px;
  background: rgba(0, 0, 0, 0.8);
  color: white;
  font-size: 12px;
  padding: 4px 8px;
  border-radius: 4px;
}

.vip-badge {
  position: absolute;
  top: 10px;
  right: 10px;
  background: linear-gradient(45deg, #ffd700, #ffa500);
  color: white;
  font-size: 10px;
  padding: 4px 8px;
  border-radius: 8px;
  font-weight: bold;
}

.video-info {
  padding: 15px;
}

.video-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 8px;
  display: block;
  line-height: 1.4;
}

.video-desc {
  font-size: 14px;
  color: #666;
  line-height: 1.4;
  margin-bottom: 12px;
  display: block;
}

.video-meta {
  display: flex;
  gap: 15px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 4px;
}

.meta-icon {
  font-size: 12px;
}

.meta-text {
  font-size: 12px;
  color: #999;
}

/* 空状态 */
.empty-state {
  text-align: center;
  padding: 60px 20px;
  color: #999;
}

.empty-icon {
  font-size: 48px;
  margin-bottom: 20px;
  display: block;
}

.empty-title {
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 10px;
  display: block;
  color: #666;
}

.empty-desc {
  font-size: 14px;
  display: block;
}

/* 模态框样式 */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 2000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.modal-content {
  background: white;
  border-radius: 15px;
  width: 100%;
  max-width: 400px;
  max-height: 80vh;
  overflow: hidden;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.modal-title {
  font-size: 18px;
  font-weight: bold;
}

.close {
  font-size: 24px;
  cursor: pointer;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.2);
}

.modal-body {
  padding: 20px;
  max-height: 60vh;
  overflow-y: auto;
}

.filter-section {
  margin-bottom: 20px;
}

.filter-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 15px;
  display: block;
}

.filter-options {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 10px;
}

.filter-option {
  padding: 12px;
  background: #f8f9fa;
  border-radius: 8px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 2px solid transparent;
  font-size: 14px;
}

.filter-option.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-color: #667eea;
}

/* VIP弹窗样式 */
.vip-benefits {
  margin-bottom: 25px;
}

.benefits-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 15px;
  display: block;
}

.benefit-item {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
}

.benefit-icon {
  color: #4caf50;
  font-size: 16px;
  font-weight: bold;
  margin-right: 10px;
  width: 20px;
}

.benefit-text {
  font-size: 14px;
  color: #666;
}

.vip-btn {
  width: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 15px;
  border-radius: 10px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.vip-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

/* 快速入口卡片 */
.quick-access-card {
  margin: 0 20px 20px;
  background: white;
  border-radius: 15px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.access-content {
  display: flex;
  align-items: center;
  padding: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.access-content:hover {
  background: #f8f9fa;
}

.access-icon {
  width: 50px;
  height: 50px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 25px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 15px;
}

.icon-text {
  font-size: 24px;
  color: white;
}

.access-info {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.access-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 4px;
}

.access-desc {
  font-size: 13px;
  color: #666;
  line-height: 1.4;
}

.access-arrow {
  font-size: 20px;
  color: #999;
  font-weight: bold;
}
</style>
