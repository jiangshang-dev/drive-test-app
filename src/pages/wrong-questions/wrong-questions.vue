<template>
  <view class="page">
    <!-- 顶部导航栏 -->
    <view class="header">
      <view class="header-content">
        <text class="logo">错题本</text>
        <view class="header-right">
          <text class="clear-icon" @click="clearWrongQuestions">清空</text>
        </view>
      </view>
    </view>

    <!-- 主要内容区域 -->
    <view class="main-content">
      <!-- 统计卡片 -->
      <view class="stats-card">
        <view class="stats-grid">
          <view class="stat-item">
            <text class="stat-number">{{ wrongStats.totalCount }}</text>
            <text class="stat-label">错题总数</text>
          </view>
          <view class="stat-item">
            <text class="stat-number">{{ wrongStats.reviewedCount }}</text>
            <text class="stat-label">已复习</text>
          </view>
          <view class="stat-item">
            <text class="stat-number">{{ wrongStats.masteredCount }}</text>
            <text class="stat-label">已掌握</text>
          </view>
        </view>
      </view>

      <!-- 科目分类标签 -->
      <view class="subject-tabs">
        <view
          v-for="(tab, index) in subjectTabs"
          :key="index"
          :class="['tab-item', activeTab === index ? 'active' : '']"
          @click="switchTab(index)"
        >
          {{ tab.name }}
        </view>
      </view>

      <!-- 错题列表 -->
      <view class="question-list" v-if="filteredQuestions.length > 0">
        <view
          v-for="(question, index) in filteredQuestions"
          :key="question.id"
          class="question-card"
          @click="reviewQuestion(question)"
        >
          <view class="question-header">
            <text class="question-number">第 {{ index + 1 }} 题</text>
            <view class="question-status">
              <text :class="['status-badge', question.status]">
                {{ getStatusText(question.status) }}
              </text>
            </view>
          </view>

          <view class="question-content">
            <text class="question-text">{{ question.question }}</text>
            <view v-if="question.image" class="question-image">
              <image :src="question.image" mode="aspectFit" />
            </view>
          </view>

          <view class="question-meta">
            <text class="error-count">错误 {{ question.errorCount }} 次</text>
            <text class="add-time">{{ formatDate(question.addTime) }}</text>
          </view>
        </view>
      </view>

      <!-- 空状态 -->
      <view v-else class="empty-state">
        <text class="empty-icon">📝</text>
        <text class="empty-title">暂无错题</text>
        <text class="empty-desc">继续练习，加油学习！</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

// 错题统计数据
const wrongStats = ref({
  totalCount: 23,
  reviewedCount: 15,
  masteredCount: 8,
})

// 科目分类
const subjectTabs = ref([
  { name: '全部', value: 'all' },
  { name: '科目一', value: 'subject1' },
  { name: '科目四', value: 'subject4' },
])

const activeTab = ref(0)

// 错题数据
const wrongQuestions = ref([
  {
    id: 1,
    question:
      '驾驶机动车在高速公路上行驶，遇有雾、雨、雪、沙尘、冰雹等低能见度气象条件时，能见度在50米以下时，以下做法正确的是什么？',
    subject: 'subject1',
    status: 'unreviewed', // unreviewed, reviewing, mastered
    errorCount: 3,
    addTime: new Date('2024-01-15'),
    image: '',
  },
  {
    id: 2,
    question: '车辆在交叉路口绿灯亮后，遇非机动车抢道行驶时，可以不让行。',
    subject: 'subject1',
    status: 'reviewing',
    errorCount: 2,
    addTime: new Date('2024-01-16'),
    image: '',
  },
  {
    id: 3,
    question: '驾驶机动车在道路上违反道路通行规定应当接受相应的处罚。',
    subject: 'subject4',
    status: 'mastered',
    errorCount: 1,
    addTime: new Date('2024-01-17'),
    image: '',
  },
])

// 筛选后的错题
const filteredQuestions = computed(() => {
  const currentTab = subjectTabs.value[activeTab.value]
  if (currentTab.value === 'all') {
    return wrongQuestions.value
  }
  return wrongQuestions.value.filter((q) => q.subject === currentTab.value)
})

// 切换科目
const switchTab = (index: number) => {
  activeTab.value = index
}

// 获取状态文本
const getStatusText = (status: string) => {
  const statusMap = {
    unreviewed: '未复习',
    reviewing: '复习中',
    mastered: '已掌握',
  }
  return statusMap[status] || '未知'
}

// 格式化日期
const formatDate = (date: Date) => {
  return date.toLocaleDateString('zh-CN', {
    month: 'numeric',
    day: 'numeric',
  })
}

// 复习错题
const reviewQuestion = (question: any) => {
  uni.showToast({
    title: '跳转到题目详情',
    icon: 'none',
  })
  // TODO: 跳转到题目详情页面
}

// 清空错题
const clearWrongQuestions = () => {
  uni.showModal({
    title: '确认清空',
    content: '确定要清空所有错题吗？',
    success: (res) => {
      if (res.confirm) {
        wrongQuestions.value = []
        wrongStats.value = {
          totalCount: 0,
          reviewedCount: 0,
          masteredCount: 0,
        }
        uni.showToast({
          title: '清空成功',
          icon: 'success',
        })
      }
    },
  })
}
</script>

<style lang="scss" scoped>

/* 继承首页基础样式，添加特定样式 */
.clear-icon {
  font-size: 28rpx;
  padding: 8rpx 16rpx;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 20rpx;
}

.stats-card {
  background: white;
  border-radius: 30rpx;
  padding: 40rpx;
  margin-bottom: 40rpx;
  box-shadow: 0 4rpx 30rpx rgba(0, 0, 0, 0.08);
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20rpx;
}

.stat-item {
  text-align: center;
  padding: 20rpx;
  background: #f8f9fa;
  border-radius: 20rpx;
}

.stat-number {
  display: block;
  font-size: 36rpx;
  font-weight: bold;
  color: #667eea;
  margin-bottom: 8rpx;
}

.stat-label {
  font-size: 24rpx;
  color: #666;
}

.question-list {
  margin-top: 40rpx;
}

.question-card {
  background: white;
  border-radius: 24rpx;
  padding: 30rpx;
  margin-bottom: 20rpx;
  box-shadow: 0 4rpx 24rpx rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
}

.question-card:active {
  transform: translateY(-4rpx);
  box-shadow: 0 12rpx 40rpx rgba(0, 0, 0, 0.12);
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
}

.question-number {
  font-size: 28rpx;
  font-weight: 600;
  color: #333;
}

.status-badge {
  font-size: 20rpx;
  padding: 4rpx 12rpx;
  border-radius: 12rpx;
  font-weight: bold;

  &.unreviewed {
    background: #fff3cd;
    color: #856404;
  }

  &.reviewing {
    background: #d1ecf1;
    color: #0c5460;
  }

  &.mastered {
    background: #d4edda;
    color: #155724;
  }
}

.question-text {
  font-size: 28rpx;
  line-height: 1.6;
  color: #333;
  display: block;
  margin-bottom: 15rpx;
}

.question-image {
  margin: 15rpx 0;
  text-align: center;

  image {
    width: 200rpx;
    height: 150rpx;
    border-radius: 12rpx;
  }
}

.question-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 24rpx;
  color: #999;
  margin-top: 20rpx;
  padding-top: 20rpx;
  border-top: 1rpx solid #f0f0f0;
}

.error-count {
  color: #f56565;
}

/* 空状态样式 */
.empty-state {
  text-align: center;
  padding: 100rpx 40rpx;
}

.empty-icon {
  font-size: 120rpx;
  display: block;
  margin-bottom: 30rpx;
  opacity: 0.3;
}

.empty-title {
  font-size: 32rpx;
  font-weight: 600;
  color: #666;
  margin-bottom: 16rpx;
  display: block;
}

.empty-desc {
  font-size: 28rpx;
  color: #999;
  display: block;
}
</style>
