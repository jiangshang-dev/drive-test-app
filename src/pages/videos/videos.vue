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
        :class="selectedCategory === item.code ? 'tab-item active' : 'tab-item'"
        v-for="item in questionTypes"
        :key="item.code"
        @click="selectCategory(item.code)"
      >
        {{ item.name }}
      </view>
    </view>

    <!-- 视频列表 -->
    <scroll-view class="videos-scroll" @scrolltolower="loadMoreVideos" scroll-y>
      <view class="videos-list">
        <view
          v-for="(video, index) in filteredVideos"
          :key="index"
          class="video-card"
          @click="playVideo(video)"
        >
          <view class="video-thumbnail">
            <image class="thumbnail-img" :src="video.coverImage" mode="aspectFill" />
            <view class="play-overlay">
              <text class="play-icon">▶️</text>
            </view>
            <text class="video-duration">{{ formatDuration(video.videoDuration) }}</text>
            <view v-if="video.isVip === 1 && !isVipUser" class="vip-badge">VIP</view>
          </view>

          <view class="video-info">
            <text class="video-title">{{ video.videoTitle }}</text>
            <text class="video-desc">{{ video.videoDesc }}</text>

            <view class="video-meta">
              <view class="meta-item">
                <text class="meta-icon">👁</text>
                <text class="meta-text">{{ video.viewCount }}</text>
              </view>
              <view class="meta-item">
                <text class="meta-icon">👍</text>
                <text class="meta-text">{{ video.likeCount }}</text>
              </view>
              <view class="meta-item">
                <text class="meta-icon">⭐</text>
                <text class="meta-text">{{ video.rating }}</text>
              </view>
            </view>
          </view>
        </view>

        <!-- 加载更多提示 -->
        <view class="load-more" v-if="loading">
          <text>加载中...</text>
        </view>
        <view class="load-more" v-else-if="noMore && filteredVideos.length > 0">
          <text>没有更多数据了</text>
        </view>
        <view class="load-more" v-else-if="filteredVideos.length === 0 && !loading">
          <text>暂无视频数据</text>
        </view>
      </view>
    </scroll-view>

    <!-- 空状态 -->
    <view v-if="filteredVideos.length === 0 && !loading" class="empty-state">
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
                :class="
                  selectedDifficulty === option.value ? 'filter-option active' : 'filter-option'
                "
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
                :class="
                  selectedDuration === option.value ? 'filter-option active' : 'filter-option'
                "
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

    <!-- 登录提示弹窗 -->
    <view v-if="showLoginModal" class="modal" @click="showLoginModal = false">
      <view class="modal-content" @click.stop>
        <view class="modal-header">
          <text class="modal-title">提示</text>
          <text class="close" @click="showLoginModal = false">&times;</text>
        </view>
        <view class="modal-body">
          <view class="login-prompt">
            <text class="prompt-text">请先登录后查看视频内容</text>
            <button class="login-btn" @click="goToLogin">立即登录</button>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { http } from '@/utils/http'
import { useMemberStore } from '@/stores'

// 类型定义
interface DictType {
  id: string
  dictValue: string
  dictLabel: string
}

interface VideoCategory {
  code: string
  name: string
  icon: string
}

interface VideoItem {
  id: string
  videoTitle: string
  videoDesc: string
  coverImage: string
  videoUrl: string
  aliyunVideoId: string
  playAuth: string
  videoDuration: number
  videoSize: string
  videoFormat: string
  resolution: string
  category: string
  tags: string
  instructor: string
  difficultyLevel: number
  isVip: number
  isHot: number
  isDownloadable: number
  viewCount: string
  likeCount: string
  shareCount: string
  commentCount: string
  downloadCount: string
  rating: number
  ratingCount: number
  sortOrder: number
  status: number
  uploadUserId: string | null
  auditUserId: string | null
  auditTime: string | null
  publishTime: string | null
  isDeleted: number
  gmtCreate: string
  gmtModified: string
}

interface VideoResponse {
  total: number
  list: VideoItem[]
}

// 数据状态
const isVipUser = ref(false) // 模拟VIP状态
const selectedCategory = ref('all')
const showFilterModal = ref(false)
const showVipModal = ref(false)
const showLoginModal = ref(false)
const selectedDifficulty = ref('all')
const selectedDuration = ref('all')
const questionTypes = ref<VideoCategory[]>([])
const videos = ref<VideoItem[]>([])
const currentPage = ref(1)
const pageSize = ref(10)
const totalVideos = ref(0)
const loading = ref(false)
const noMore = ref(false)

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

// 筛选后的视频列表
const filteredVideos = computed(() => {
  // 这里我们不再使用前端筛选，而是通过接口获取数据
  return videos.value
})

// 根据类型获取图标
const getIconForType = (type: string) => {
  const iconMap: Record<string, string> = {
    'traffic-signs': '🚦',
    'traffic-rules': '📜',
    'driving-skills': '🚗',
    // 可以根据实际需求添加更多类型和图标
  }
  return iconMap[type] || '📁'
}

// 格式化视频时长
const formatDuration = (seconds: number) => {
  const minutes = Math.floor(seconds / 60)
  const remainingSeconds = seconds % 60
  return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`
}

// 方法
const selectCategory = (category: string) => {
  console.log('category----', category)
  selectedCategory.value = category
  // 重置分页参数
  currentPage.value = 1
  videos.value = []
  noMore.value = false
  // 获取该分类下的视频
  loadVideos()
}

const selectDifficulty = (difficulty: string) => {
  selectedDifficulty.value = difficulty
}

const selectDuration = (duration: string) => {
  selectedDuration.value = duration
}

// 检查用户是否已登录
const checkLogin = () => {
  const memberStore = useMemberStore()
  return !!memberStore.profile
}

// 播放视频
const playVideo = (video: VideoItem) => {
  // 检查用户是否登录
  if (!checkLogin()) {
    showLoginModal.value = true
    return
  }

  // 检查是否为VIP视频且用户不是VIP
  if (video.isVip === 1 && !isVipUser.value) {
    showVipModal.value = true
    return
  }

  // 跳转到视频播放页面，对视频对象进行序列化处理
  console.log('跳转到视频播放页面', video)
  const serializedVideo = JSON.stringify(video)
  console.log('serializedVideo-', serializedVideo)
  uni.navigateTo({
    url: `/pages/video-player/video-player?video=${serializedVideo}`,
    success: () => {
      console.log('视频播放页面跳转成功')
    },
    fail: (err) => {
      console.error('视频播放页面跳转失败:', err)
      uni.showToast({
        title: '跳转失败',
        icon: 'error',
      })
    },
  })
}

// 获取视频分类列表
const getDictType = async () => {
  try {
    let url = '/dict/type/getByDictName?dictCode=traffic_video_category'
    const res: any = await http({
      url: url,
      method: 'GET',
    })
    console.log('res-', res.data)

    // 将后端返回的数据格式转换为前端需要的格式
    if (res.data && Array.isArray(res.data)) {
      questionTypes.value = res.data.map((item: DictType) => ({
        code: item.id,
        name: item.dictLabel,
        icon: getIconForType(item.dictValue), // 根据类型获取图标
      }))
    }

    console.log('questionTypes-----', questionTypes.value)
  } catch (error) {
    console.error('获取视频分类失败:', error)
    // 如果获取失败，使用默认分类
    questionTypes.value = [
      { code: 'all', name: '全部', icon: '📁' },
      { code: 'traffic-signs', name: '交通标志', icon: '🚦' },
      { code: 'traffic-rules', name: '交通法规', icon: '📜' },
      { code: 'driving-skills', name: '驾驶技巧', icon: '🚗' },
    ]
  }
}

// 加载视频列表
const loadVideos = async () => {
  if (loading.value || noMore.value) return

  loading.value = true

  console.log('selectedCategory.value--', selectedCategory.value)

  try {
    // 构造查询参数
    const params: Record<string, any> = {
      category: selectedCategory.value === 'all' ? '' : selectedCategory.value,
      page: currentPage.value,
      limit: pageSize.value,
    }

    // 移除空值参数
    Object.keys(params).forEach((key) => {
      if (params[key] === '' || params[key] === undefined || params[key] === null) {
        delete params[key]
      }
    })

    const url = '/aptrafficvideo/page'
    console.log('请求URL:', url)
    console.log('请求参数:', params)

    const res: any = await http({
      url: url,
      method: 'GET',
      data: params, // 直接使用data传递参数
    })

    console.log('视频列表响应:', res)

    // 检查响应数据结构
    if (res && res.data) {
      // 如果是第一页，清空现有数据
      if (currentPage.value === 1) {
        videos.value = res.data.list || []
      } else {
        // 否则追加数据
        videos.value = [...videos.value, ...(res.data.list || [])]
      }

      totalVideos.value = res.data.total || 0

      // 检查是否还有更多数据
      if (videos.value.length >= (res.data.total || 0)) {
        noMore.value = true
      }
      console.log('当前视频列表:', videos.value)
      console.log('总视频数:', totalVideos.value)
      console.log('是否还有更多:', !noMore.value)
    } else {
      console.error('响应数据格式不正确:', res)
      uni.showToast({
        title: '数据格式错误',
        icon: 'error',
      })
    }
  } catch (error) {
    console.error('获取视频列表失败:', error)
    uni.showToast({
      title: '获取视频失败',
      icon: 'error',
    })
  } finally {
    loading.value = false
  }
}

// 加载更多视频（分页）
const loadMoreVideos = () => {
  if (!loading.value && !noMore.value) {
    currentPage.value++
    loadVideos()
  }
}

// 升级到VIP
const upgradeToVip = () => {
  // 跳转到VIP页面
  console.log('跳转到VIP会员页面')
  uni.navigateTo({
    url: '/pages/vip/vip',
    success: () => {
      console.log('VIP页面跳转成功')
    },
    fail: (err) => {
      console.error('VIP页面跳转失败:', err)
      uni.showToast({
        title: '跳转失败',
        icon: 'error',
      })
    },
  })
  showVipModal.value = false
}

// 去登录
const goToLogin = () => {
  console.log('跳转到登录页面')
  uni.navigateTo({
    url: '/pages/login/login',
    success: () => {
      console.log('登录页面跳转成功')
    },
    fail: (err) => {
      console.error('登录页面跳转失败:', err)
      uni.showToast({
        title: '跳转失败',
        icon: 'error',
      })
    },
  })
  showLoginModal.value = false
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

  // 获取视频分类数据
  getDictType()

  // 加载默认分类的视频
  loadVideos()
})

// 监听页面滚动到底部事件
onLoad(() => {
  uni.$on('scrollToLower', loadMoreVideos)
})

// 页面卸载时移除事件监听
// onUnmounted(() => {
//   uni.$off('scrollToLower', loadMoreVideos)
// })
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
  position: sticky;
  top: 60px;
  z-index: 999;
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

/* 视频滚动区域 */
.videos-scroll {
  height: calc(100vh - 200px);
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

/* 加载更多提示 */
.load-more {
  text-align: center;
  padding: 20px;
  color: #999;
  font-size: 14px;
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

/* 登录弹窗样式 */
.login-prompt {
  text-align: center;
}

.prompt-text {
  display: block;
  margin-bottom: 20px;
  font-size: 16px;
  color: #333;
}

.login-btn {
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

.login-btn:hover {
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
