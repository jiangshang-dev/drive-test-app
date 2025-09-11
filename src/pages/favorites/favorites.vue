<template>
  <view class="container">
    <!-- 顶部导航栏 -->
    <view class="header">
      <view class="header-content">
        <text class="logo">我的收藏</text>
        <view class="header-right">
          <text class="filter-icon" @click="showFilterModal = true">筛选</text>
        </view>
      </view>
    </view>

    <!-- 统计卡片 -->
    <view class="stats-card">
      <view class="stats-grid">
        <view class="stat-item">
          <text class="stat-number">{{ totalFavorites }}</text>
          <text class="stat-label">总收藏</text>
        </view>
        <view class="stat-item">
          <text class="stat-number">{{ subjectOneFavorites }}</text>
          <text class="stat-label">科目一</text>
        </view>
        <view class="stat-item">
          <text class="stat-number">{{ subjectFourFavorites }}</text>
          <text class="stat-label">科目四</text>
        </view>
        <view class="stat-item">
          <text class="stat-number">{{ recentFavorites }}</text>
          <text class="stat-label">本周新增</text>
        </view>
      </view>
    </view>

    <!-- 科目筛选标签 -->
    <view class="subject-tabs">
      <view
        :class="['tab-item', selectedSubject === 'all' ? 'active' : '']"
        @click="selectSubject('all')"
      >
        全部
      </view>
      <view :class="['tab-item', selectedSubject === 1 ? 'active' : '']" @click="selectSubject(1)">
        科目一
      </view>
      <view :class="['tab-item', selectedSubject === 4 ? 'active' : '']" @click="selectSubject(4)">
        科目四
      </view>
    </view>

    <!-- 收藏题目列表 -->
    <view class="questions-list">
      <view
        v-for="(question, index) in filteredQuestions"
        :key="index"
        class="question-card"
        @click="viewQuestion(question)"
      >
        <view class="question-header">
          <text class="question-number">第 {{ question.questionId }} 题</text>
          <view class="question-subject">
            <text
              class="subject-tag"
              :class="question.subject === 1 ? 'subject-one' : 'subject-four'"
            >
              {{ question.subject === 1 ? '科目一' : '科目四' }}
            </text>
          </view>
        </view>

        <view class="question-content">
          <text class="question-text">{{ question.question }}</text>

          <view v-if="question.url" class="question-image">
            <image
              class="question-img"
              :src="question.url"
              mode="aspectFit"
              @click.stop="previewImage(question.url)"
            />
          </view>
        </view>

        <view class="question-footer">
          <text class="favorite-time">收藏于 {{ formatTime(question.favoriteTime) }}</text>
          <text class="remove-favorite" @click.stop="removeFavorite(question)">取消收藏</text>
        </view>
      </view>
    </view>

    <!-- 空状态 -->
    <view v-if="filteredQuestions.length === 0" class="empty-state">
      <text class="empty-icon">❤️</text>
      <text class="empty-title">暂无收藏题目</text>
      <text class="empty-desc">在刷题时点击❤️即可收藏题目</text>
    </view>

    <!-- 筛选弹窗 -->
    <view v-if="showFilterModal" class="modal" @click="showFilterModal = false">
      <view class="modal-content" @click.stop>
        <view class="modal-header">
          <text class="modal-title">筛选收藏</text>
          <text class="close" @click="showFilterModal = false">&times;</text>
        </view>
        <view class="modal-body">
          <view class="filter-section">
            <text class="filter-title">按时间筛选</text>
            <view class="filter-options">
              <view
                v-for="option in timeFilterOptions"
                :key="option.value"
                class="filter-option"
                :class="{ active: selectedTimeFilter === option.value }"
                @click="selectTimeFilter(option.value)"
              >
                {{ option.label }}
              </view>
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
const favoriteQuestions = ref([])
const selectedSubject = ref('all')
const showFilterModal = ref(false)
const selectedTimeFilter = ref('all')

// 时间筛选选项
const timeFilterOptions = ref([
  { label: '全部时间', value: 'all' },
  { label: '最近一周', value: 'week' },
  { label: '最近一月', value: 'month' },
  { label: '最近三月', value: 'quarter' },
])

// 模拟收藏数据
const mockFavoriteQuestions = [
  {
    questionId: 1,
    subject: 1,
    question: '机动车驾驶人违法驾驶造成重大交通事故构成犯罪的，依法追究什么责任？',
    url: '',
    favoriteTime: Date.now() - 86400000, // 1天前
  },
  {
    questionId: 15,
    subject: 1,
    question: '驾驶机动车在道路上违反道路交通安全法的行为，属于什么行为？',
    url: 'https://via.placeholder.com/200x150/2196F3/white?text=题目图片',
    favoriteTime: Date.now() - 172800000, // 2天前
  },
  {
    questionId: 203,
    subject: 4,
    question: '夜间驾驶机动车在窄路、窄桥会车时正确的做法是什么？',
    url: '',
    favoriteTime: Date.now() - 259200000, // 3天前
  },
]

// 统计数据
const totalFavorites = computed(() => favoriteQuestions.value.length)
const subjectOneFavorites = computed(
  () => favoriteQuestions.value.filter((q) => q.subject === 1).length,
)
const subjectFourFavorites = computed(
  () => favoriteQuestions.value.filter((q) => q.subject === 4).length,
)
const recentFavorites = computed(() => {
  const oneWeekAgo = Date.now() - 7 * 24 * 60 * 60 * 1000
  return favoriteQuestions.value.filter((q) => q.favoriteTime > oneWeekAgo).length
})

// 筛选后的题目列表
const filteredQuestions = computed(() => {
  let filtered = favoriteQuestions.value

  // 按科目筛选
  if (selectedSubject.value !== 'all') {
    filtered = filtered.filter((q) => q.subject === selectedSubject.value)
  }

  // 按时间筛选
  if (selectedTimeFilter.value !== 'all') {
    const now = Date.now()
    let timeLimit = 0

    switch (selectedTimeFilter.value) {
      case 'week':
        timeLimit = now - 7 * 24 * 60 * 60 * 1000
        break
      case 'month':
        timeLimit = now - 30 * 24 * 60 * 60 * 1000
        break
      case 'quarter':
        timeLimit = now - 90 * 24 * 60 * 60 * 1000
        break
    }

    if (timeLimit > 0) {
      filtered = filtered.filter((q) => q.favoriteTime > timeLimit)
    }
  }

  return filtered.sort((a, b) => b.favoriteTime - a.favoriteTime)
})

// 方法
const selectSubject = (subject) => {
  selectedSubject.value = subject
}

const selectTimeFilter = (filter) => {
  selectedTimeFilter.value = filter
  showFilterModal.value = false
}

const viewQuestion = (question) => {
  uni.navigateTo({
    url: `/pages/question-detail/question-detail?questionId=${question.questionId}&subject=${question.subject}`
  })
}

const removeFavorite = (question) => {
  uni.showModal({
    title: '确认操作',
    content: '确定要取消收藏这道题目吗？',
    success: (res) => {
      if (res.confirm) {
        const index = favoriteQuestions.value.findIndex((q) => q.questionId === question.questionId)
        if (index > -1) {
          favoriteQuestions.value.splice(index, 1)
          uni.showToast({
            title: '已取消收藏',
            icon: 'success',
          })
        }
      }
    },
  })
}

const previewImage = (url) => {
  uni.previewImage({
    urls: [url],
    current: url,
  })
}

const formatTime = (timestamp) => {
  const date = new Date(timestamp)
  const now = new Date()
  const diffTime = now.getTime() - date.getTime()
  const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24))

  if (diffDays === 0) {
    return '今天'
  } else if (diffDays === 1) {
    return '昨天'
  } else if (diffDays < 7) {
    return `${diffDays}天前`
  } else {
    return date.toLocaleDateString()
  }
}

onMounted(() => {
  favoriteQuestions.value = mockFavoriteQuestions
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

/* 统计卡片 */
.stats-card {
  margin: 80px 20px 20px;
  background: white;
  border-radius: 15px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  padding: 20px;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
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

/* 科目选择标签 */
.subject-tabs {
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
  padding: 12px;
  border-radius: 16px;
  font-weight: 500;
  transition: all 0.3s ease;
  color: #666;
  font-size: 14px;
  cursor: pointer;
}

.tab-item.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.3);
}

/* 题目列表 */
.questions-list {
  padding: 0 20px;
}

.question-card {
  background: white;
  border-radius: 15px;
  margin-bottom: 15px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s ease;
}

.question-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.12);
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.question-number {
  font-size: 16px;
  font-weight: bold;
}

.subject-tag {
  font-size: 12px;
  padding: 4px 8px;
  border-radius: 10px;
  font-weight: bold;
}

.subject-tag.subject-one {
  background: rgba(76, 175, 80, 0.2);
  color: #4caf50;
}

.subject-tag.subject-four {
  background: rgba(255, 152, 0, 0.2);
  color: #ff9800;
}

.question-content {
  padding: 20px;
}

.question-text {
  font-size: 16px;
  line-height: 1.6;
  color: #333;
  margin-bottom: 15px;
  display: block;
}

.question-image {
  text-align: center;
  margin: 15px 0;
}

.question-img {
  width: 200px;
  height: 150px;
  border-radius: 10px;
  cursor: pointer;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.question-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
  background: #f8f9fa;
  border-top: 1px solid #e9ecef;
}

.favorite-time {
  font-size: 12px;
  color: #666;
}

.remove-favorite {
  font-size: 12px;
  color: #f44336;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 4px;
  transition: background 0.3s ease;
}

.remove-favorite:hover {
  background: #ffebee;
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
</style>
