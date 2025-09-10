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
    <view class="category-tabs">
      <view
        :class="['tab-item', selectedCategory === 'all' ? 'active' : '']"
        @click="selectCategory('all')"
      >
        全部
      </view>
      <view
        :class="['tab-item', selectedCategory === 'warning' ? 'active' : '']"
        @click="selectCategory('warning')"
      >
        警告标志
      </view>
      <view
        :class="['tab-item', selectedCategory === 'prohibition' ? 'active' : '']"
        @click="selectCategory('prohibition')"
      >
        禁令标志
      </view>
      <view
        :class="['tab-item', selectedCategory === 'indication' ? 'active' : '']"
        @click="selectCategory('indication')"
      >
        指示标志
      </view>
      <view
        :class="['tab-item', selectedCategory === 'guide' ? 'active' : '']"
        @click="selectCategory('guide')"
      >
        指路标志
      </view>
    </view>

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
    <view class="signs-list">
      <view
        v-for="(sign, index) in filteredSigns"
        :key="index"
        class="sign-card"
        @click="showSignDetail(sign)"
      >
        <view class="sign-image">
          <image class="sign-img" :src="sign.image" mode="aspectFit" />
          <view class="category-badge" :class="sign.category">
            {{ getCategoryName(sign.category) }}
          </view>
        </view>

        <view class="sign-content">
          <text class="sign-name">{{ sign.name }}</text>
          <text class="sign-description">{{ sign.description }}</text>

          <view class="sign-details">
            <view class="detail-item">
              <text class="detail-label">形状:</text>
              <text class="detail-value">{{ sign.shape }}</text>
            </view>
            <view class="detail-item">
              <text class="detail-label">颜色:</text>
              <text class="detail-value">{{ sign.color }}</text>
            </view>
          </view>

          <view class="sign-footer">
            <text class="sign-code">标志代码: {{ sign.code }}</text>
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
    </view>

    <!-- 空状态 -->
    <view v-if="filteredSigns.length === 0" class="empty-state">
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
              <image class="search-img" :src="result.image" mode="aspectFit" />
              <view class="search-info">
                <text class="search-name">{{ result.name }}</text>
                <text class="search-desc">{{ result.description }}</text>
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
          <text class="modal-title">{{ selectedSign?.name }}</text>
          <text class="close" @click="showDetailModal = false">&times;</text>
        </view>
        <view class="modal-body">
          <view v-if="selectedSign" class="sign-detail">
            <view class="detail-image">
              <image class="detail-img" :src="selectedSign.image" mode="aspectFit" />
            </view>

            <view class="detail-info">
              <view class="info-row">
                <text class="info-label">标志名称:</text>
                <text class="info-value">{{ selectedSign.name }}</text>
              </view>
              <view class="info-row">
                <text class="info-label">标志代码:</text>
                <text class="info-value">{{ selectedSign.code }}</text>
              </view>
              <view class="info-row">
                <text class="info-label">标志分类:</text>
                <text class="info-value">{{ getCategoryName(selectedSign.category) }}</text>
              </view>
              <view class="info-row">
                <text class="info-label">形状特征:</text>
                <text class="info-value">{{ selectedSign.shape }}</text>
              </view>
              <view class="info-row">
                <text class="info-label">颜色特征:</text>
                <text class="info-value">{{ selectedSign.color }}</text>
              </view>
            </view>

            <view class="detail-description">
              <text class="desc-title">详细说明</text>
              <text class="desc-content">{{ selectedSign.detailDescription }}</text>
            </view>

            <view v-if="selectedSign.usage" class="detail-usage">
              <text class="usage-title">使用场景</text>
              <text class="usage-content">{{ selectedSign.usage }}</text>
            </view>

            <view v-if="selectedSign.notes" class="detail-notes">
              <text class="notes-title">注意事项</text>
              <text class="notes-content">{{ selectedSign.notes }}</text>
            </view>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'

// 数据状态
const selectedCategory = ref('all')
const showSearchModal = ref(false)
const showDetailModal = ref(false)
const selectedSign = ref(null)
const searchKeyword = ref('')
const searchResults = ref([])

// 交通标志数据
const trafficSigns = ref([
  {
    id: 1,
    name: '注意危险',
    code: 'W001',
    category: 'warning',
    shape: '等边三角形',
    color: '黄底、黑边、黑图案',
    description: '用以警告车辆、行人注意危险地点的标志',
    detailDescription:
      '注意危险标志是警告标志中最重要的一种，用于提醒驾驶员和行人前方存在危险，需要格外小心。这类标志通常设置在危险路段前方适当距离处。',
    usage: '通常设置在急弯、陡坡、窄桥、隧道、学校、医院等危险或需要特别注意的路段前方',
    notes: '看到此标志应立即减速慢行，提高警惕，做好应急准备',
    image: 'https://via.placeholder.com/100x100/FFFF00/000000?text=⚠️',
    isFavorite: false,
  },
  {
    id: 2,
    name: '注意儿童',
    code: 'W002',
    category: 'warning',
    shape: '等边三角形',
    color: '黄底、黑边、黑图案',
    description: '用以警告车辆驾驶人注意前方有儿童活动',
    detailDescription:
      '此标志设置在小学、幼儿园、少年宫、儿童游乐场等儿童经常出入的场所前方道路上，提醒驾驶员注意儿童安全。',
    usage: '学校区域、幼儿园附近、居民区内儿童活动频繁的道路',
    notes: '遇到此标志应减速慢行，注意观察，随时准备避让儿童',
    image: 'https://via.placeholder.com/100x100/FFFF00/000000?text=👶',
    isFavorite: false,
  },
  {
    id: 3,
    name: '禁止通行',
    code: 'P001',
    category: 'prohibition',
    shape: '圆形',
    color: '白底、红圈、红斜杠',
    description: '表示禁止一切车辆和行人通行',
    detailDescription: '禁止通行标志表示禁止一切车辆和行人通行。此标志设在禁止通行的道路入口处。',
    usage: '道路施工区域、危险路段、私人道路等禁止通行的区域入口',
    notes: '此标志具有强制性，违反者将面临法律责任',
    image: 'https://via.placeholder.com/100x100/FFFFFF/FF0000?text=⊘',
    isFavorite: false,
  },
  {
    id: 4,
    name: '禁止机动车通行',
    code: 'P002',
    category: 'prohibition',
    shape: '圆形',
    color: '白底、红圈、黑图案',
    description: '表示禁止各类机动车通行',
    detailDescription:
      '禁止机动车通行标志表示禁止各类机动车通行，但不包括非机动车。此标志设在禁止机动车通行的道路入口处。',
    usage: '步行街、非机动车道、特定时段的道路等',
    notes: '机动车包括汽车、摩托车等，但允许非机动车和行人通行',
    image: 'https://via.placeholder.com/100x100/FFFFFF/FF0000?text=🚗',
    isFavorite: true,
  },
  {
    id: 5,
    name: '直行',
    code: 'I001',
    category: 'indication',
    shape: '圆形',
    color: '蓝底、白图案',
    description: '表示只准一切车辆直行',
    detailDescription: '直行标志表示只准一切车辆直行。此标志设在直行的道路上。',
    usage: '单行道、特定路段需要强制直行的道路',
    notes: '车辆必须直行，不得左转或右转',
    image: 'https://via.placeholder.com/100x100/0066FF/FFFFFF?text=↑',
    isFavorite: false,
  },
  {
    id: 6,
    name: '向左转弯',
    code: 'I002',
    category: 'indication',
    shape: '圆形',
    color: '蓝底、白图案',
    description: '表示只准一切车辆向左转弯',
    detailDescription:
      '向左转弯标志表示只准一切车辆向左转弯。此标志设在车辆必须向左转弯的路口以前适当位置。',
    usage: '单行道路口、特定的转弯要求路段',
    notes: '车辆只能向左转弯，不得直行或右转',
    image: 'https://via.placeholder.com/100x100/0066FF/FFFFFF?text=←',
    isFavorite: false,
  },
  {
    id: 7,
    name: '地名',
    code: 'G001',
    category: 'guide',
    shape: '矩形',
    color: '蓝底、白字',
    description: '用以指示前方所到达的地点',
    detailDescription:
      '地名标志用以指示前方所到达的地点，包括城市、县城、乡镇等地名信息，帮助驾驶员确定行驶方向。',
    usage: '高速公路、国道、省道等主要道路上',
    notes: '注意观察地名信息，提前选择正确的行驶路线',
    image: 'https://via.placeholder.com/120x60/0066FF/FFFFFF?text=北京',
    isFavorite: false,
  },
  {
    id: 8,
    name: '注意信号灯',
    code: 'W003',
    category: 'warning',
    shape: '等边三角形',
    color: '黄底、黑边、黑图案',
    description: '用以警告车辆驾驶人注意前方路段设有信号灯',
    detailDescription: '此标志用于警告驾驶员前方设有交通信号灯，需要根据信号灯指示通行。',
    usage: '接近交通信号灯控制的交叉路口前方',
    notes: '提前减速，观察信号灯，按照信号灯指示通行',
    image: 'https://via.placeholder.com/100x100/FFFF00/000000?text=🚦',
    isFavorite: false,
  },
])

// 计算属性
const totalSigns = computed(() => trafficSigns.value.length)
const favoriteCount = computed(() => trafficSigns.value.filter((sign) => sign.isFavorite).length)

const filteredSigns = computed(() => {
  if (selectedCategory.value === 'all') {
    return trafficSigns.value
  }
  return trafficSigns.value.filter((sign) => sign.category === selectedCategory.value)
})

// 方法
const selectCategory = (category) => {
  selectedCategory.value = category
}

const getCategoryName = (category) => {
  const categoryMap = {
    warning: '警告标志',
    prohibition: '禁令标志',
    indication: '指示标志',
    guide: '指路标志',
  }
  return categoryMap[category] || '未知分类'
}

const showSignDetail = (sign) => {
  selectedSign.value = sign
  showDetailModal.value = true
}

const toggleFavorite = (sign) => {
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
      sign.name.toLowerCase().includes(keyword) ||
      sign.description.toLowerCase().includes(keyword) ||
      sign.code.toLowerCase().includes(keyword),
  )
}

const selectSearchResult = (sign) => {
  showSearchModal.value = false
  searchKeyword.value = ''
  searchResults.value = []
  showSignDetail(sign)
}

onMounted(() => {
  // 初始化数据
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
  display: flex;
  background: white;
  border-radius: 24px;
  padding: 8px;
  margin: 80px 20px 20px;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.08);
}

.tab-item {
  flex: 1;
  text-align: center;
  padding: 8px 6px;
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

/* 标志列表 */
.signs-list {
  padding: 0 20px;
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

.sign-details {
  display: flex;
  gap: 15px;
  margin-bottom: 12px;
}

.detail-item {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.detail-label {
  font-size: 12px;
  color: #999;
  margin-bottom: 4px;
}

.detail-value {
  font-size: 12px;
  color: #333;
  font-weight: 500;
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
  padding: 12px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 14px;
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

.detail-description,
.detail-usage,
.detail-notes {
  background: #f8f9fa;
  padding: 15px;
  border-radius: 8px;
}

.desc-title,
.usage-title,
.notes-title {
  font-size: 14px;
  font-weight: bold;
  color: #333;
  margin-bottom: 8px;
  display: block;
}

.desc-content,
.usage-content,
.notes-content {
  font-size: 13px;
  color: #666;
  line-height: 1.5;
  display: block;
}
</style>
