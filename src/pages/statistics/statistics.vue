<template>
  <view class="container">
    <view class="page-toolbar">
      <text class="toolbar-action" @click="refreshData">刷新</text>
    </view>

    <!-- 总体统计卡片 -->
    <view class="overview-card">
      <view class="overview-header">
        <text class="card-title">学习概览</text>
        <text class="update-time">更新于 {{ formatTime(lastUpdateTime) }}</text>
      </view>
      <view class="overview-grid">
        <view class="overview-item">
          <text class="overview-icon">📚</text>
          <text class="overview-number">{{ totalStudyDays }}</text>
          <text class="overview-label">学习天数</text>
        </view>
        <view class="overview-item">
          <text class="overview-icon">⏰</text>
          <text class="overview-number">{{ totalStudyHours }}h</text>
          <text class="overview-label">学习时长</text>
        </view>
        <view class="overview-item">
          <text class="overview-icon">✏️</text>
          <text class="overview-number">{{ totalQuestions }}</text>
          <text class="overview-label">刷题总数</text>
        </view>
        <view class="overview-item">
          <text class="overview-icon">🎯</text>
          <text class="overview-number">{{ totalExams }}</text>
          <text class="overview-label">考试次数</text>
        </view>
      </view>
    </view>

    <!-- 时间范围选择 -->
    <view class="time-selector">
      <view
        v-for="period in timePeriods"
        :key="period.value"
        class="time-option"
        :class="{ active: selectedPeriod === period.value }"
        @click="selectPeriod(period.value)"
      >
        {{ period.label }}
      </view>
    </view>

    <!-- 科目统计卡片 -->
    <view class="subject-stats-card">
      <view class="card-header">
        <text class="card-title">科目统计</text>
      </view>
      <view class="subjects-grid">
        <view v-for="(subject, index) in subjectStats" :key="index" class="subject-item">
          <view class="subject-header">
            <text class="subject-name">{{ subject.name }}</text>
            <text class="subject-progress">{{ subject.progress }}%</text>
          </view>
          <view class="progress-bar">
            <view class="progress-fill" :style="{ width: subject.progress + '%' }"></view>
          </view>
          <view class="subject-details">
            <view class="detail-row">
              <text class="detail-label">已练习:</text>
              <text class="detail-value">{{ subject.practiced }}题</text>
            </view>
            <view class="detail-row">
              <text class="detail-label">正确率:</text>
              <text class="detail-value" :class="getAccuracyClass(subject.accuracy)">
                {{ subject.accuracy }}%
              </text>
            </view>
            <view class="detail-row">
              <text class="detail-label">错题数:</text>
              <text class="detail-value error">{{ subject.wrongQuestions }}题</text>
            </view>
          </view>
        </view>
      </view>
    </view>

    <!-- 学习趋势卡片 -->
    <view class="trend-card">
      <view class="card-header">
        <text class="card-title">学习趋势</text>
      </view>
      <view class="trend-chart">
        <!-- 简单的条形图模拟 -->
        <view class="chart-container">
          <view v-for="(day, index) in studyTrend" :key="index" class="chart-bar">
            <view class="bar-fill" :style="{ height: (day.minutes / 60) * 100 + '%' }"></view>
            <text class="bar-label">{{ day.label }}</text>
            <text class="bar-value">{{ day.minutes }}min</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 成就徽章卡片 -->
    <view class="achievements-card">
      <view class="card-header">
        <text class="card-title">成就徽章</text>
      </view>
      <view class="achievements-grid">
        <view
          v-for="(achievement, index) in achievements"
          :key="index"
          class="achievement-item"
          :class="{ unlocked: achievement.unlocked }"
        >
          <text class="achievement-icon">{{ achievement.icon }}</text>
          <text class="achievement-name">{{ achievement.name }}</text>
          <text class="achievement-desc">{{ achievement.description }}</text>
          <view v-if="achievement.unlocked" class="unlock-date">
            {{ formatDate(achievement.unlockDate) }}
          </view>
          <view v-else class="achievement-progress">
            {{ achievement.current }}/{{ achievement.target }}
          </view>
        </view>
      </view>
    </view>

    <!-- 知识点掌握度卡片 -->
    <view class="knowledge-card" v-if="false">
      <view class="card-header">
        <text class="card-title">知识点掌握度</text>
      </view>
      <view class="knowledge-list">
        <view v-for="(topic, index) in knowledgeTopics" :key="index" class="knowledge-item">
          <view class="knowledge-header">
            <text class="topic-name">{{ topic.name }}</text>
            <text class="mastery-level" :class="getMasteryClass(topic.mastery)">
              {{ getMasteryText(topic.mastery) }}
            </text>
          </view>
          <view class="knowledge-progress">
            <view class="progress-bar">
              <view class="progress-fill" :style="{ width: topic.mastery + '%' }"></view>
            </view>
            <text class="progress-text">{{ topic.mastery }}%</text>
          </view>
          <view class="knowledge-stats">
            <text class="stat-text">练习 {{ topic.practiced }}题</text>
            <text class="stat-text">错误 {{ topic.errors }}题</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'

// 数据状态
const selectedPeriod = ref('week')
const lastUpdateTime = ref(Date.now())

// 时间周期选项
const timePeriods = ref([
  { label: '本周', value: 'week' },
  { label: '本月', value: 'month' },
  { label: '本年', value: 'year' },
])

// 总体统计数据
const overallStats = ref({
  totalStudyDays: 15,
  totalStudyHours: 32.5,
  totalQuestions: 2580,
  totalExams: 8,
})

// 科目统计数据
const subjectStats = ref([
  {
    name: '科目一',
    progress: 75,
    practiced: 1325,
    accuracy: 85,
    wrongQuestions: 198,
    total: 1765,
  },
  {
    name: '科目四',
    progress: 45,
    practiced: 565,
    accuracy: 78,
    wrongQuestions: 124,
    total: 1255,
  },
])

// 学习趋势数据（最近7天）
const studyTrend = ref([
  { label: '周一', minutes: 45 },
  { label: '周二', minutes: 32 },
  { label: '周三', minutes: 28 },
  { label: '周四', minutes: 52 },
  { label: '周五', minutes: 38 },
  { label: '周六', minutes: 65 },
  { label: '周日', minutes: 42 },
])

// 成就徽章数据
const achievements = ref([
  {
    icon: '🔥',
    name: '坚持学习',
    description: '连续学习7天',
    unlocked: true,
    unlockDate: Date.now() - 86400000,
    current: 7,
    target: 7,
  },
  {
    icon: '🎯',
    name: '神射手',
    description: '单次考试正确率达到95%',
    unlocked: true,
    unlockDate: Date.now() - 172800000,
    current: 95,
    target: 95,
  },
  {
    icon: '💯',
    name: '完美主义',
    description: '模拟考试满分',
    unlocked: false,
    current: 95,
    target: 100,
  },
  {
    icon: '📚',
    name: '学霸',
    description: '累计刷题3000题',
    unlocked: false,
    current: 2580,
    target: 3000,
  },
  {
    icon: '⚡',
    name: '闪电侠',
    description: '30分钟内完成模拟考试',
    unlocked: false,
    current: 35,
    target: 30,
  },
  {
    icon: '🏆',
    name: '冠军',
    description: '连续5次模拟考试通过',
    unlocked: false,
    current: 3,
    target: 5,
  },
])

// 知识点掌握度数据
const knowledgeTopics = ref([
  {
    name: '交通标志',
    mastery: 92,
    practiced: 145,
    errors: 12,
  },
  {
    name: '交通法规',
    mastery: 88,
    practiced: 168,
    errors: 20,
  },
  {
    name: '安全行车',
    mastery: 85,
    practiced: 132,
    errors: 20,
  },
  {
    name: '紧急处置',
    mastery: 78,
    practiced: 95,
    errors: 21,
  },
  {
    name: '机动车构造',
    mastery: 75,
    practiced: 85,
    errors: 21,
  },
  {
    name: '违法处罚',
    mastery: 82,
    practiced: 112,
    errors: 20,
  },
])

// 计算属性
const totalStudyDays = computed(() => overallStats.value.totalStudyDays)
const totalStudyHours = computed(() => overallStats.value.totalStudyHours)
const totalQuestions = computed(() => overallStats.value.totalQuestions)
const totalExams = computed(() => overallStats.value.totalExams)

// 方法
const selectPeriod = (period) => {
  selectedPeriod.value = period
  // 这里可以根据时间周期重新获取数据
}

const refreshData = () => {
  lastUpdateTime.value = Date.now()
  uni.showToast({
    title: '数据已刷新',
    icon: 'success',
  })
}

const getAccuracyClass = (accuracy) => {
  if (accuracy >= 90) return 'excellent'
  if (accuracy >= 80) return 'good'
  if (accuracy >= 70) return 'normal'
  return 'poor'
}

const getMasteryClass = (mastery) => {
  if (mastery >= 90) return 'excellent'
  if (mastery >= 80) return 'good'
  if (mastery >= 70) return 'normal'
  return 'poor'
}

const getMasteryText = (mastery) => {
  if (mastery >= 90) return '精通'
  if (mastery >= 80) return '熟练'
  if (mastery >= 70) return '一般'
  return '待提高'
}

const formatTime = (timestamp) => {
  const date = new Date(timestamp)
  return `${date.getHours()}:${date.getMinutes().toString().padStart(2, '0')}`
}

const formatDate = (timestamp) => {
  const date = new Date(timestamp)
  return `${date.getMonth() + 1}月${date.getDate()}日`
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
  background: linear-gradient(135deg, #0f766e 0%, #115e59 100%);
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

.refresh-icon {
  font-size: 14px;
  padding: 6px 12px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 15px;
  cursor: pointer;
}

/* 总体统计卡片 */
.overview-card {
  margin: 80px 20px 20px;
  background: white;
  border-radius: 15px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  padding: 20px;
}

.overview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.card-title {
  font-size: 18px;
  font-weight: bold;
  color: #333;
}

.update-time {
  font-size: 12px;
  color: #999;
}

.overview-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 15px;
}

.overview-item {
  text-align: center;
  padding: 20px 10px;
  background: #f8f9fa;
  border-radius: 12px;
}

.overview-icon {
  font-size: 24px;
  margin-bottom: 8px;
  display: block;
}

.overview-number {
  display: block;
  font-size: 20px;
  font-weight: bold;
  color: #0f766e;
  margin-bottom: 4px;
}

.overview-label {
  font-size: 12px;
  color: #666;
}

/* 时间选择器 */
.time-selector {
  display: flex;
  background: white;
  border-radius: 24px;
  padding: 10px;
  margin: 0 20px 20px;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.08);
}

.time-option {
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

.time-option.active {
  background: linear-gradient(135deg, #0f766e 0%, #115e59 100%);
  color: white;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.3);
}

/* 科目统计卡片 */
.subject-stats-card {
  margin: 0 20px 20px;
  background: white;
  border-radius: 15px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.card-header {
  padding: 20px;
  border-bottom: 1px solid #f0f0f0;
}

.subjects-grid {
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.subject-item {
  padding: 20px;
  background: #f8f9fa;
  border-radius: 12px;
}

.subject-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.subject-name {
  font-size: 16px;
  font-weight: bold;
  color: #333;
}

.subject-progress {
  font-size: 18px;
  font-weight: bold;
  color: #0f766e;
}

.progress-bar {
  height: 8px;
  background: #e9ecef;
  border-radius: 4px;
  overflow: hidden;
  margin-bottom: 15px;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #0f766e 0%, #115e59 100%);
  border-radius: 4px;
  transition: width 0.5s ease;
}

.subject-details {
  display: flex;
  justify-content: space-between;
}

.detail-row {
  display: flex;
  flex-direction: column;
  align-items: center;
  flex: 1;
}

.detail-label {
  font-size: 12px;
  color: #666;
  margin-bottom: 4px;
}

.detail-value {
  font-size: 14px;
  font-weight: bold;
  color: #333;
}

.detail-value.excellent {
  color: #4caf50;
}

.detail-value.good {
  color: #2196f3;
}

.detail-value.normal {
  color: #ff9800;
}

.detail-value.poor {
  color: #f44336;
}

.detail-value.error {
  color: #f44336;
}

/* 学习趋势卡片 */
.trend-card {
  margin: 0 20px 20px;
  background: white;
  border-radius: 15px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.trend-chart {
  padding: 20px;
}

.chart-container {
  display: flex;
  justify-content: space-between;
  align-items: end;
  height: 120px;
  padding: 20px 0;
}

.chart-bar {
  display: flex;
  flex-direction: column;
  align-items: center;
  height: 100%;
  flex: 1;
  position: relative;
}

.bar-fill {
  width: 20px;
  min-height: 4px;
  background: linear-gradient(135deg, #0f766e 0%, #115e59 100%);
  border-radius: 2px;
  margin-bottom: 8px;
  transition: height 0.5s ease;
}

.bar-label {
  font-size: 12px;
  color: #666;
  margin-bottom: 4px;
}

.bar-value {
  font-size: 10px;
  color: #999;
}

/* 成就徽章卡片 */
.achievements-card {
  margin: 0 20px 20px;
  background: white;
  border-radius: 15px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.achievements-grid {
  padding: 20px;
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 15px;
}

.achievement-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  padding: 20px;
  border-radius: 12px;
  transition: all 0.3s ease;
}

.achievement-item.unlocked {
  background: linear-gradient(135deg, #0f766e 0%, #115e59 100%);
  color: white;
}

.achievement-item:not(.unlocked) {
  background: #f8f9fa;
  color: #999;
}

.achievement-icon {
  font-size: 32px;
  margin-bottom: 8px;
  opacity: 0.7;
}

.achievement-item.unlocked .achievement-icon {
  opacity: 1;
}

.achievement-name {
  font-size: 14px;
  font-weight: bold;
  margin-bottom: 4px;
  display: block;
}

.achievement-desc {
  font-size: 12px;
  margin-bottom: 8px;
  display: block;
  opacity: 0.8;
}

.unlock-date {
  font-size: 10px;
  opacity: 0.7;
}

.achievement-progress {
  font-size: 10px;
  opacity: 0.7;
}

/* 知识点掌握度卡片 */
.knowledge-card {
  margin: 0 20px 20px;
  background: white;
  border-radius: 15px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.knowledge-list {
  padding: 20px;
}

.knowledge-item {
  padding: 15px 0;
  border-bottom: 1px solid #f0f0f0;
}

.knowledge-item:last-child {
  border-bottom: none;
}

.knowledge-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.topic-name {
  font-size: 14px;
  font-weight: 600;
  color: #333;
}

.mastery-level {
  font-size: 12px;
  font-weight: bold;
  padding: 2px 8px;
  border-radius: 8px;
}

.mastery-level.excellent {
  background: #e8f5e8;
  color: #4caf50;
}

.mastery-level.good {
  background: #e3f2fd;
  color: #2196f3;
}

.mastery-level.normal {
  background: #fff3e0;
  color: #ff9800;
}

.mastery-level.poor {
  background: #ffebee;
  color: #f44336;
}

.knowledge-progress {
  display: flex;
  align-items: center;
  margin-bottom: 8px;
  gap: 10px;
}

.knowledge-progress .progress-bar {
  flex: 1;
  height: 6px;
  margin-bottom: 0;
}

.progress-text {
  font-size: 12px;
  font-weight: bold;
  color: #0f766e;
  min-width: 35px;
}

.knowledge-stats {
  display: flex;
  gap: 15px;
}

.stat-text {
  font-size: 12px;
  color: #666;
}
</style>
