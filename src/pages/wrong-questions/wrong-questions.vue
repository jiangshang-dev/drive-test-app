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
  const statusMap: { [key: string]: string } = {
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
  // 跳转到题目详情页面，传递题目ID和科目信息
  const subject = question.subject === 'subject1' ? '1' : '4'
  uni.navigateTo({
    url: `/pages/question-detail/question-detail?questionId=${question.id}&subject=${subject}`
  })
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
/* 基础容器样式 */
.page {
  min-height: 100vh;
  background: linear-gradient(180deg, #f8f9fa 0%, #ffffff 100%);
}

/* 顶部导航栏样式 */
.header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 20rpx 0 30rpx;
  position: sticky;
  top: 0;
  z-index: 100;
  box-shadow: 0 4rpx 20rpx rgba(102, 126, 234, 0.3);
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 30rpx;
}

.logo {
  font-size: 36rpx;
  font-weight: bold;
  letter-spacing: 2rpx;
}

.header-right {
  display: flex;
  align-items: center;
}

.clear-icon {
  font-size: 26rpx;
  padding: 12rpx 20rpx;
  background: rgba(255, 255, 255, 0.25);
  border-radius: 25rpx;
  border: 1rpx solid rgba(255, 255, 255, 0.3);
  transition: all 0.3s ease;
  backdrop-filter: blur(10rpx);
}

.clear-icon:active {
  background: rgba(255, 255, 255, 0.4);
  transform: scale(0.95);
}

/* 主要内容区域 */
.main-content {
  padding: 30rpx;
  padding-bottom: 100rpx;
}

/* 统计卡片样式 */
.stats-card {
  background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
  border-radius: 24rpx;
  padding: 40rpx 30rpx;
  margin-bottom: 30rpx;
  box-shadow: 0 8rpx 32rpx rgba(0, 0, 0, 0.08);
  border: 1rpx solid rgba(102, 126, 234, 0.1);
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 30rpx;
}

.stat-item {
  text-align: center;
  padding: 30rpx 20rpx;
  background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
  border-radius: 20rpx;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.05);
  border: 1rpx solid rgba(102, 126, 234, 0.08);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.stat-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4rpx;
  background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
}

.stat-item:active {
  transform: translateY(-4rpx);
  box-shadow: 0 8rpx 24rpx rgba(0, 0, 0, 0.12);
}

.stat-number {
  display: block;
  font-size: 40rpx;
  font-weight: bold;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  margin-bottom: 12rpx;
}

.stat-label {
  font-size: 24rpx;
  color: #666;
  font-weight: 500;
}

/* 科目分类标签样式 */
.subject-tabs {
  display: flex;
  background: white;
  border-radius: 20rpx;
  padding: 8rpx;
  margin-bottom: 30rpx;
  box-shadow: 0 4rpx 20rpx rgba(0, 0, 0, 0.06);
  border: 1rpx solid rgba(102, 126, 234, 0.1);
}

.tab-item {
  flex: 1;
  text-align: center;
  padding: 20rpx 16rpx;
  font-size: 28rpx;
  font-weight: 500;
  color: #666;
  border-radius: 16rpx;
  transition: all 0.3s ease;
  position: relative;
}

.tab-item.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 0 4rpx 16rpx rgba(102, 126, 234, 0.4);
}

.tab-item:not(.active):active {
  background: #f8f9fa;
  color: #667eea;
}

/* 错题列表样式 */
.question-list {
  margin-top: 20rpx;
}

.question-card {
  background: linear-gradient(135deg, #ffffff 0%, #fcfcfc 100%);
  border-radius: 20rpx;
  padding: 32rpx;
  margin-bottom: 24rpx;
  box-shadow: 0 6rpx 28rpx rgba(0, 0, 0, 0.08);
  border: 1rpx solid rgba(102, 126, 234, 0.08);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.question-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 6rpx;
  height: 100%;
  background: linear-gradient(180deg, #667eea 0%, #764ba2 100%);
}

.question-card:active {
  transform: translateY(-6rpx);
  box-shadow: 0 12rpx 40rpx rgba(102, 126, 234, 0.15);
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24rpx;
  padding-left: 12rpx;
}

.question-number {
  font-size: 28rpx;
  font-weight: 600;
  color: #333;
  position: relative;
}

.question-status {
  display: flex;
  align-items: center;
}

.status-badge {
  font-size: 22rpx;
  padding: 8rpx 16rpx;
  border-radius: 16rpx;
  font-weight: 600;
  letter-spacing: 1rpx;
  box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.1);

  &.unreviewed {
    background: linear-gradient(135deg, #fff3cd 0%, #ffeaa7 100%);
    color: #856404;
    border: 1rpx solid #ffd93d;
  }

  &.reviewing {
    background: linear-gradient(135deg, #d1ecf1 0%, #74b9ff 100%);
    color: #0c5460;
    border: 1rpx solid #00b894;
  }

  &.mastered {
    background: linear-gradient(135deg, #d4edda 0%, #00b894 100%);
    color: #155724;
    border: 1rpx solid #00b894;
  }
}

.question-content {
  padding-left: 12rpx;
  margin-bottom: 20rpx;
}

.question-text {
  font-size: 30rpx;
  line-height: 1.7;
  color: #333;
  display: block;
  margin-bottom: 20rpx;
  font-weight: 400;
}

.question-image {
  margin: 20rpx 0;
  text-align: center;
  background: #f8f9fa;
  border-radius: 12rpx;
  padding: 20rpx;

  image {
    width: 300rpx;
    height: 200rpx;
    border-radius: 12rpx;
    box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.1);
  }
}

.question-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 24rpx;
  margin-top: 24rpx;
  padding: 20rpx 12rpx 0;
  border-top: 1rpx solid #f0f0f0;
}

.error-count {
  color: #e74c3c;
  font-weight: 600;
  background: rgba(231, 76, 60, 0.1);
  padding: 6rpx 12rpx;
  border-radius: 12rpx;
  border: 1rpx solid rgba(231, 76, 60, 0.2);
}

.add-time {
  color: #95a5a6;
  font-weight: 500;
}

/* 空状态样式 */
.empty-state {
  text-align: center;
  padding: 120rpx 40rpx;
  background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
  border-radius: 20rpx;
  box-shadow: 0 6rpx 28rpx rgba(0, 0, 0, 0.06);
  border: 1rpx solid rgba(102, 126, 234, 0.08);
}

.empty-icon {
  font-size: 140rpx;
  display: block;
  margin-bottom: 40rpx;
  opacity: 0.4;
  filter: grayscale(0.3);
}

.empty-title {
  font-size: 36rpx;
  font-weight: 600;
  color: #666;
  margin-bottom: 20rpx;
  display: block;
}

.empty-desc {
  font-size: 28rpx;
  color: #95a5a6;
  display: block;
  line-height: 1.5;
}

/* 响应式适配 */
@media screen and (max-width: 750rpx) {
  .stats-grid {
    gap: 20rpx;
  }

  .stat-item {
    padding: 24rpx 16rpx;
  }

  .stat-number {
    font-size: 36rpx;
  }

  .question-card {
    padding: 28rpx;
    margin-bottom: 20rpx;
  }

  .question-text {
    font-size: 28rpx;
  }
}
</style>
