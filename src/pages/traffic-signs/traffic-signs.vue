<template>
  <view class="container">
    <!-- 顶部导航栏 -->
    <view class="header">
      <view class="header-content">
        <text class="logo">交通标志图示详解</text>
        <view class="header-right">
          <text class="search-icon" @click="showSearchModal = true">🔍</text>
        </view>
      </view>
    </view>

    <!-- 分类标签 -->
    <scroll-view class="category-tabs" scroll-x>
      <view class="tabs-container">
        <view
          :class="['tab-item', selectedCategory === 'all' ? 'active' : '']"
          @click="selectCategory('all')"
        >
          全部
        </view>
        <view
          :class="['tab-item', selectedCategory === item.code ? 'active' : '']"
          v-for="item in questionTypes"
          :key="item.code"
          @click="selectCategory(item.code)"
        >
          {{ item.name }}
        </view>
      </view>
    </scroll-view>

    <!-- 标志统计 -->
    <view class="stats-section">
      <view class="stats-card">
        <view class="stat-item">
          <text class="stat-number">{{ totalSigns }}</text>
          <text class="stat-label">全部标志</text>
        </view>
        <view class="stat-item">
          <text class="stat-number">{{ filteredSigns.length }}</text>
          <text class="stat-label">当前分类</text>
        </view>
        <view class="stat-item">
          <text class="stat-number">{{ favoriteCount }}</text>
          <text class="stat-label">我的收藏</text>
        </view>
      </view>
    </view>

    <!-- 交通标志列表 -->
    <scroll-view class="signs-scroll" @scrolltolower="loadMore" scroll-y>
      <view class="signs-list">
        <view
          v-for="(sign, index) in filteredSigns"
          :key="index"
          class="sign-card"
          @click="showSignDetail(sign)"
        >
          <view class="sign-image">
            <image class="sign-img" :src="sign.signImage" mode="aspectFit" />
            <view class="category-badge" :class="sign.signCategory">
              {{ getCategoryName(sign.signCategory) }}
            </view>
          </view>

          <view class="sign-content">
            <text class="sign-name">{{ sign.signName }}</text>
            <text class="sign-description">{{ sign.signDesc }}</text>

            <view class="sign-footer">
              <text class="sign-code">查看次数: {{ sign.viewCount }}</text>
              <text
                class="favorite-btn"
                :class="{ active: sign.isFavorite }"
                @click.stop="toggleFavorite(sign)"
              >
                {{ sign.isFavorite ? '❤️' : '🤍' }}
              </text>
            </view>
          </view>
        </view>

        <!-- 加载更多提示 -->
        <view class="load-more" v-if="loading">
          <text class="load-more-icon">⏳</text>
          <text>正在加载更多数据...</text>
        </view>
        <view class="load-more no-more" v-else-if="noMore && filteredSigns.length > 0">
          <text class="load-more-icon">✅</text>
          <text>所有数据加载完毕</text>
        </view>
        <view class="load-more" v-else-if="filteredSigns.length === 0 && !loading">
          <text class="load-more-icon">📭</text>
          <text>暂无交通标志数据</text>
        </view>
      </view>
    </scroll-view>

    <!-- 空状态 -->
    <view v-if="filteredSigns.length === 0 && !loading" class="empty-state">
      <text class="empty-icon">🚦</text>
      <text class="empty-title">暂无标志</text>
      <text class="empty-desc">该分类下暂时没有交通标志</text>
    </view>

    <!-- 搜索弹窗 -->
    <view v-if="showSearchModal" class="modal" @click="showSearchModal = false">
      <view class="modal-content" @click.stop>
        <view class="modal-header">
          <text class="modal-title">搜索交通标志</text>
          <text class="close" @click="showSearchModal = false">&times;</text>
        </view>
        <view class="modal-body">
          <view class="search-input">
            <input
              v-model="searchKeyword"
              placeholder="请输入标志名称或描述"
              @input="handleSearch"
            />
          </view>
          <view v-if="searchResults.length > 0" class="search-results">
            <view
              v-for="(result, index) in searchResults"
              :key="index"
              class="search-item"
              @click="selectSearchResult(result)"
            >
              <image class="search-img" :src="result.signImage" mode="aspectFit" />
              <view class="search-info">
                <text class="search-name">{{ result.signName }}</text>
                <text class="search-desc">{{ result.signDesc }}</text>
              </view>
            </view>
          </view>
        </view>
      </view>
    </view>

    <!-- 标志详情弹窗 -->
    <view v-if="showDetailModal" class="modal" @click="showDetailModal = false">
      <view class="modal-content detail-modal" @click.stop>
        <view class="modal-header">
          <text class="modal-title">{{ selectedSign?.signName }}</text>
          <text class="close" @click="showDetailModal = false">&times;</text>
        </view>
        <view class="modal-body">
          <view v-if="selectedSign" class="sign-detail">
            <view class="detail-image">
              <image class="detail-img" :src="selectedSign.signImage" mode="aspectFit" />
            </view>

            <view class="detail-info">
              <view class="info-row">
                <text class="info-label">标志名称:</text>
                <text class="info-value">{{ selectedSign.signName }}</text>
              </view>
              <view class="info-row">
                <text class="info-label">标志分类:</text>
                <text class="info-value">{{ getCategoryName(selectedSign.signCategory) }}</text>
              </view>
              <view class="info-row">
                <text class="info-label">标志类型:</text>
                <text class="info-value">{{ selectedSign.signType }}</text>
              </view>
              <view class="info-row">
                <text class="info-label">使用场景:</text>
                <text class="info-value">{{ selectedSign.usageScene }}</text>
              </view>
              <view class="info-row">
                <text class="info-label">相关法规:</text>
                <text class="info-value">{{ selectedSign.relatedRegulations }}</text>
              </view>
            </view>

            <view class="detail-description">
              <text class="desc-title">详细说明</text>
              <text class="desc-content">{{ selectedSign.signDesc }}</text>
            </view>
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

interface SignCategory {
  code: string
  name: string
  icon: string
}

interface TrafficSign {
  id: string
  signName: string
  signDesc: string
  signImage: string
  signCategory: string
  signType: string
  usageScene: string
  relatedRegulations: string
  sortOrder: number
  viewCount: string
  isDeleted: number
  gmtCreate: string
  gmtModified: string
  isFavorite?: boolean
}

// 数据状态
const selectedCategory = ref('all')
const showSearchModal = ref(false)
const showDetailModal = ref(false)
const selectedSign = ref<TrafficSign | null>(null)
const searchKeyword = ref('')
const searchResults = ref<TrafficSign[]>([])
const questionTypes = ref<SignCategory[]>([{ code: 'all', name: '全部', icon: '' }])
const trafficSigns = ref<TrafficSign[]>([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const loading = ref(false)
const noMore = ref(false)

// 计算属性
const totalSigns = computed(() => total.value)
const favoriteCount = computed(() => trafficSigns.value.filter((sign) => sign.isFavorite).length)

const filteredSigns = computed(() => {
  return trafficSigns.value
})

// 方法
const selectCategory = (category: string) => {
  selectedCategory.value = category
  // 重置分页参数
  currentPage.value = 1
  trafficSigns.value = []
  noMore.value = false
  // 获取该分类下的数据
  loadTrafficSigns()
}

const getCategoryName = (category: string) => {
  // 先从接口获取的分类数据中查找
  const categoryItem = questionTypes.value.find((item) => item.code === category)
  if (categoryItem) {
    return categoryItem.name
  }

  // 如果没找到，使用默认映射
  const categoryMap: Record<string, string> = {
    warning: '警告标志',
    prohibition: '禁令标志',
    indication: '指示标志',
    guide: '指路标志',
  }
  return categoryMap[category] || '未知分类'
}

// 根据类型获取图标
const getIconForType = (type: string) => {
  const iconMap: Record<string, string> = {
    warning: '⚠️',
    prohibition: '🚫',
    indication: 'ℹ️',
    guide: '🛣️',
  }
  return iconMap[type] || '📁'
}

const showSignDetail = (sign: TrafficSign) => {
  selectedSign.value = sign
  showDetailModal.value = true
}

const toggleFavorite = (sign: TrafficSign) => {
  sign.isFavorite = !sign.isFavorite
  uni.showToast({
    title: sign.isFavorite ? '已收藏' : '已取消收藏',
    icon: 'success',
  })
}

const handleSearch = () => {
  if (searchKeyword.value.trim() === '') {
    searchResults.value = []
    return
  }

  const keyword = searchKeyword.value.toLowerCase()
  searchResults.value = trafficSigns.value.filter(
    (sign) =>
      sign.signName.toLowerCase().includes(keyword) ||
      sign.signDesc.toLowerCase().includes(keyword),
  )
}

const selectSearchResult = (sign: TrafficSign) => {
  showSearchModal.value = false
  searchKeyword.value = ''
  searchResults.value = []
  showSignDetail(sign)
}

onMounted(() => {
  // 初始化数据
  // 获取分类数据
  getDictType()
  // 加载默认数据
  loadTrafficSigns()
})

// 获取标志分类列表
const getDictType = async () => {
  try {
    let url = '/dict/type/getByDictName?dictCode=traffic_logo'
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
    } else {
      // 如果没有获取到数据，使用默认分类
      questionTypes.value = [
        { code: 'all', name: '全部', icon: '📁' },
        { code: 'warning', name: '警告标志', icon: '⚠️' },
        { code: 'prohibition', name: '禁令标志', icon: '🚫' },
        { code: 'indication', name: '指示标志', icon: 'ℹ️' },
        { code: 'guide', name: '指路标志', icon: '🛣️' },
      ]
    }

    console.log('questionTypes-----', questionTypes.value)
  } catch (error) {
    console.error('获取标志分类失败:', error)
    // 出错时使用默认分类
    questionTypes.value = [
      { code: 'all', name: '全部', icon: '📁' },
      { code: 'warning', name: '警告标志', icon: '⚠️' },
      { code: 'prohibition', name: '禁令标志', icon: '🚫' },
      { code: 'indication', name: '指示标志', icon: 'ℹ️' },
      { code: 'guide', name: '指路标志', icon: '🛣️' },
    ]
  }
}

// 加载交通标志数据
const loadTrafficSigns = async () => {
  if (loading.value || noMore.value) return

  loading.value = true

  try {
    // 构造查询参数
    const params: Record<string, any> = {
      page: currentPage.value,
      limit: pageSize.value,
    }

    // 如果不是"全部"分类，添加分类筛选条件
    if (selectedCategory.value !== 'all') {
      params.signCategory = selectedCategory.value
    }

    const url = '/aptrafficsign/page'
    console.log('请求URL:', url)
    console.log('请求参数:', params)

    const res: any = await http({
      url: url,
      method: 'GET',
      data: params,
    })

    console.log('交通标志列表响应:', res)

    // 检查响应数据结构
    if (res && res.data) {
      // 如果是第一页，清空现有数据
      if (currentPage.value === 1) {
        trafficSigns.value = res.data.list || []
      } else {
        // 否则追加数据
        trafficSigns.value = [...trafficSigns.value, ...(res.data.list || [])]
      }

      total.value = res.data.total || 0

      // 检查是否还有更多数据
      if (trafficSigns.value.length >= (res.data.total || 0)) {
        noMore.value = true
      }

      console.log('当前交通标志列表:', trafficSigns.value)
      console.log('总交通标志数:', total.value)
      console.log('是否还有更多:', !noMore.value)
    } else {
      console.error('响应数据格式不正确:', res)
      uni.showToast({
        title: '数据格式错误',
        icon: 'error',
      })
    }
  } catch (error) {
    console.error('获取交通标志列表失败:', error)
    uni.showToast({
      title: '获取数据失败',
      icon: 'error',
    })
  } finally {
    loading.value = false
  }
}

// 加载更多数据（分页）
const loadMore = () => {
  if (!loading.value && !noMore.value) {
    currentPage.value++
    loadTrafficSigns()
  }
}
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
  font-size: 18px;
  font-weight: bold;
}

.search-icon {
  font-size: 16px;
  padding: 6px 12px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 15px;
  cursor: pointer;
}

/* 分类标签 */
.category-tabs {
  white-space: nowrap;
  background: white;
  padding: 8px 0;
  margin: 80px 20px 20px;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.08);
  border-radius: 24px;
}

.tabs-container {
  display: inline-flex;
  padding: 0 10px;
}

.tab-item {
  text-align: center;
  padding: 8px 16px;
  border-radius: 16px;
  font-weight: 500;
  transition: all 0.3s ease;
  color: #666;
  font-size: 12px;
  cursor: pointer;
  margin-right: 10px;
  white-space: nowrap;
  flex: 0 0 auto; /* 不放大，不缩小，自动宽度 */
}

.tab-item.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.3);
}

/* 统计区域 */
.stats-section {
  margin: 0 20px 20px;
}

.stats-card {
  background: white;
  border-radius: 15px;
  padding: 20px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 15px;
}

.stat-item {
  text-align: center;
  padding: 15px 10px;
  background: #f8f9fa;
  border-radius: 10px;
}

.stat-number {
  display: block;
  font-size: 24px;
  font-weight: bold;
  color: #667eea;
  margin-bottom: 5px;
}

.stat-label {
  font-size: 12px;
  color: #666;
}

/* 交通标志滚动区域 */
.signs-scroll {
  height: calc(100vh - 300px);
}

/* 交通标志列表 */
.signs-list {
  padding: 0 20px 20px;
}

.sign-card {
  background: white;
  border-radius: 15px;
  margin-bottom: 15px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s ease;
}

.sign-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.12);
}

.sign-image {
  position: relative;
  height: 120px;
  background: #f8f9fa;
  display: flex;
  align-items: center;
  justify-content: center;
}

.sign-img {
  width: 80px;
  height: 80px;
}

.category-badge {
  position: absolute;
  top: 10px;
  right: 10px;
  font-size: 10px;
  padding: 4px 8px;
  border-radius: 8px;
  font-weight: bold;
  color: white;
}

.category-badge.warning {
  background: #ff9800;
}

.category-badge.prohibition {
  background: #f44336;
}

.category-badge.indication {
  background: #2196f3;
}

.category-badge.guide {
  background: #4caf50;
}

.sign-content {
  padding: 15px;
}

.sign-name {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 8px;
  display: block;
}

.sign-description {
  font-size: 14px;
  color: #666;
  line-height: 1.4;
  margin-bottom: 12px;
  display: block;
}

.sign-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.sign-code {
  font-size: 12px;
  color: #999;
}

.favorite-btn {
  font-size: 18px;
  cursor: pointer;
  transition: transform 0.3s ease;
}

.favorite-btn.active {
  transform: scale(1.2);
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

.load-more.no-more {
  color: #667eea;
  font-weight: 500;
}

.load-more-icon {
  display: inline-block;
  margin-right: 8px;
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

.detail-modal {
  max-height: 90vh;
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

/* 搜索样式 */
.search-input {
  margin-bottom: 20px;
}

.search-input input {
  width: 100%;
  padding: 12px 15px; /* 调整内边距 */
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 14px;
  height: 55px; /* 增加高度 */
  box-sizing: border-box; /* 确保高度包含内边距和边框 */
  line-height: 1.4; /* 行高调整 */
  vertical-align: middle; /* 垂直居中 */
}

.search-results {
  max-height: 300px;
  overflow-y: auto;
}

.search-item {
  display: flex;
  align-items: center;
  padding: 10px;
  border-bottom: 1px solid #f0f0f0;
  cursor: pointer;
  transition: background 0.3s ease;
}

.search-item:hover {
  background: #f8f9fa;
}

.search-img {
  width: 40px;
  height: 40px;
  margin-right: 15px;
}

.search-info {
  flex: 1;
}

.search-name {
  font-size: 14px;
  font-weight: bold;
  color: #333;
  margin-bottom: 4px;
  display: block;
}

.search-desc {
  font-size: 12px;
  color: #666;
}

/* 详情样式 */
.sign-detail {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.detail-image {
  text-align: center;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 10px;
}

.detail-img {
  width: 120px;
  height: 120px;
}

.detail-info {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.info-row {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px solid #f0f0f0;
}

.info-label {
  font-size: 14px;
  color: #666;
  font-weight: 500;
}

.info-value {
  font-size: 14px;
  color: #333;
  font-weight: 600;
}

.detail-description {
  background: #f8f9fa;
  padding: 15px;
  border-radius: 8px;
}

.desc-title {
  font-size: 14px;
  font-weight: bold;
  color: #333;
  margin-bottom: 8px;
  display: block;
}

.desc-content {
  font-size: 13px;
  color: #666;
  line-height: 1.5;
  display: block;
}
</style>
