<template>
  <view class="container">
    <!-- 顶部导航栏 -->
    <view class="header">
      <view class="header-content">
        <text class="logo">学习记录</text>
        <view class="header-right">
          <text class="filter-icon" @click="showFilterModal = true">筛选</text>
        </view>
      </view>
    </view>

    <!-- 学习统计卡片 -->
    <view class="stats-card">
      <view class="stats-grid">
        <view class="stat-item">
          <text class="stat-number">{{ totalStudyDays }}</text>
          <text class="stat-label">学习天数</text>
        </view>
        <view class="stat-item">
          <text class="stat-number">{{ totalStudyTime }}</text>
          <text class="stat-label">学习时长(h)</text>
        </view>
        <view class="stat-item">
          <text class="stat-number">{{ totalQuestions }}</text>
          <text class="stat-label">刷题总数</text>
        </view>
        <view class="stat-item">
          <text class="stat-number">{{ averageAccuracy }}%</text>
          <text class="stat-label">平均正确率</text>
        </view>
      </view>
    </view>

    <!-- 时间筛选标签 -->
    <view class="time-tabs">
      <view
        :class="['tab-item', selectedTimeRange === 'week' ? 'active' : '']"
        @click="selectTimeRange('week')"
      >
        本周
      </view>
      <view
        :class="['tab-item', selectedTimeRange === 'month' ? 'active' : '']"
        @click="selectTimeRange('month')"
      >
        本月
      </view>
      <view
        :class="['tab-item', selectedTimeRange === 'all' ? 'active' : '']"
        @click="selectTimeRange('all')"
      >
        全部
      </view>
    </view>

    <!-- 学习记录列表 -->
    <view class="records-list">
      <view v-for="(record, index) in filteredRecords" :key="index" class="record-card">
        <view class="record-header">
          <view class="record-date">
            <text class="date-text">{{ formatDate(record.date) }}</text>
            <text class="weekday">{{ getWeekday(record.date) }}</text>
          </view>
          <view class="record-summary">
            <text class="study-time">{{ record.studyTime }}分钟</text>
          </view>
        </view>

        <view class="record-content">
          <view class="record-details">
            <view class="detail-item">
              <text class="detail-label">题目类型:</text>
              <text class="detail-value">{{ getSubjectName(record.subject) }}</text>
            </view>
            <view class="detail-item">
              <text class="detail-label">答题数量:</text>
              <text class="detail-value">{{ record.questionsCount }}题</text>
            </view>
            <view class="detail-item">
              <text class="detail-label">正确率:</text>
              <text class="detail-value" :class="getAccuracyClass(record.accuracy)">
                {{ record.accuracy }}%
              </text>
            </view>
            <view class="detail-item">
              <text class="detail-label">学习模式:</text>
              <text class="detail-value">{{ getModeText(record.mode) }}</text>
            </view>
          </view>

          <!-- 成就标签 -->
          <view v-if="record.achievements && record.achievements.length > 0" class="achievements">
            <view
              v-for="(achievement, aIndex) in record.achievements"
              :key="aIndex"
              class="achievement-tag"
            >
              <text class="achievement-icon">{{ achievement.icon }}</text>
              <text class="achievement-text">{{ achievement.text }}</text>
            </view>
          </view>
        </view>

        <view class="record-footer">
          <text class="record-time"
            >{{ formatTime(record.startTime) }} - {{ formatTime(record.endTime) }}</text
          >
          <text class="view-detail" @click="viewRecordDetail(record)">查看详情</text>
        </view>
      </view>
    </view>

    <!-- 空状态 -->
    <view v-if="filteredRecords.length === 0" class="empty-state">
      <text class="empty-icon">📚</text>
      <text class="empty-title">暂无学习记录</text>
      <text class="empty-desc">开始刷题练习后会在这里显示学习记录</text>
    </view>

    <!-- 筛选弹窗 -->
    <view v-if="showFilterModal" class="modal" @click="showFilterModal = false">
      <view class="modal-content" @click.stop>
        <view class="modal-header">
          <text class="modal-title">筛选记录</text>
          <text class="close" @click="showFilterModal = false">&times;</text>
        </view>
        <view class="modal-body">
          <view class="filter-section">
            <text class="filter-title">按科目筛选</text>
            <view class="filter-options">
              <view
                v-for="option in subjectFilterOptions"
                :key="option.value"
                class="filter-option"
                :class="{ active: selectedSubjectFilter === option.value }"
                @click="selectSubjectFilter(option.value)"
              >
                {{ option.label }}
              </view>
            </view>
          </view>

          <view class="filter-section">
            <text class="filter-title">按模式筛选</text>
            <view class="filter-options">
              <view
                v-for="option in modeFilterOptions"
                :key="option.value"
                class="filter-option"
                :class="{ active: selectedModeFilter === option.value }"
                @click="selectModeFilter(option.value)"
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
const studyRecords = ref([])
const selectedTimeRange = ref('week')
const showFilterModal = ref(false)
const selectedSubjectFilter = ref('all')
const selectedModeFilter = ref('all')

// 筛选选项
const subjectFilterOptions = ref([
  { label: '全部科目', value: 'all' },
  { label: '科目一', value: 1 },
  { label: '科目四', value: 4 },
])

const modeFilterOptions = ref([
  { label: '全部模式', value: 'all' },
  { label: '顺序刷题', value: 'sequential' },
  { label: '模拟考试', value: 'exam' },
  { label: '专项练习', value: 'special' },
])

// 模拟学习记录数据
const mockStudyRecords = [
  {
    date: Date.now() - 86400000, // 1天前
    subject: 1,
    mode: 'sequential',
    questionsCount: 45,
    accuracy: 85,
    studyTime: 28,
    startTime: '14:30',
    endTime: '14:58',
    achievements: [
      { icon: '🔥', text: '连续学习3天' },
      { icon: '🎯', text: '正确率超过80%' },
    ],
  },
  {
    date: Date.now() - 172800000, // 2天前
    subject: 1,
    mode: 'exam',
    questionsCount: 100,
    accuracy: 92,
    studyTime: 45,
    startTime: '19:15',
    endTime: '20:00',
    achievements: [
      { icon: '👑', text: '模拟考试满分' },
      { icon: '⚡', text: '快速答题' },
    ],
  },
  {
    date: Date.now() - 259200000, // 3天前
    subject: 4,
    mode: 'sequential',
    questionsCount: 30,
    accuracy: 78,
    studyTime: 22,
    startTime: '20:10',
    endTime: '20:32',
    achievements: [],
  },
  {
    date: Date.now() - 345600000, // 4天前
    subject: 1,
    mode: 'special',
    questionsCount: 25,
    accuracy: 88,
    studyTime: 18,
    startTime: '15:45',
    endTime: '16:03',
    achievements: [{ icon: '📈', text: '进步明显' }],
  },
]

// 统计数据
const totalStudyDays = computed(() => {
  const uniqueDates = new Set(
    studyRecords.value.map((record) => new Date(record.date).toDateString()),
  )
  return uniqueDates.size
})

const totalStudyTime = computed(() => {
  const totalMinutes = studyRecords.value.reduce((sum, record) => sum + record.studyTime, 0)
  return Math.round((totalMinutes / 60) * 10) / 10
})

const totalQuestions = computed(() =>
  studyRecords.value.reduce((sum, record) => sum + record.questionsCount, 0),
)

const averageAccuracy = computed(() => {
  if (studyRecords.value.length === 0) return 0
  const sum = studyRecords.value.reduce((sum, record) => sum + record.accuracy, 0)
  return Math.round(sum / studyRecords.value.length)
})

// 筛选后的记录列表
const filteredRecords = computed(() => {
  let filtered = studyRecords.value

  // 按时间范围筛选
  if (selectedTimeRange.value !== 'all') {
    const now = Date.now()
    let timeLimit = 0

    switch (selectedTimeRange.value) {
      case 'week':
        timeLimit = now - 7 * 24 * 60 * 60 * 1000
        break
      case 'month':
        timeLimit = now - 30 * 24 * 60 * 60 * 1000
        break
    }

    if (timeLimit > 0) {
      filtered = filtered.filter((record) => record.date > timeLimit)
    }
  }

  // 按科目筛选
  if (selectedSubjectFilter.value !== 'all') {
    filtered = filtered.filter((record) => record.subject === selectedSubjectFilter.value)
  }

  // 按模式筛选
  if (selectedModeFilter.value !== 'all') {
    filtered = filtered.filter((record) => record.mode === selectedModeFilter.value)
  }

  return filtered.sort((a, b) => b.date - a.date)
})

// 方法
const selectTimeRange = (range) => {
  selectedTimeRange.value = range
}

const selectSubjectFilter = (filter) => {
  selectedSubjectFilter.value = filter
}

const selectModeFilter = (filter) => {
  selectedModeFilter.value = filter
}

const getSubjectName = (subject) => {
  return subject === 1 ? '科目一' : '科目四'
}

const getModeText = (mode) => {
  const modeMap = {
    sequential: '顺序刷题',
    exam: '模拟考试',
    special: '专项练习',
  }
  return modeMap[mode] || mode
}

const getAccuracyClass = (accuracy) => {
  if (accuracy >= 90) return 'excellent'
  if (accuracy >= 80) return 'good'
  if (accuracy >= 70) return 'normal'
  return 'poor'
}

const formatDate = (timestamp) => {
  const date = new Date(timestamp)
  const today = new Date()
  const yesterday = new Date(today.getTime() - 86400000)

  if (date.toDateString() === today.toDateString()) {
    return '今天'
  } else if (date.toDateString() === yesterday.toDateString()) {
    return '昨天'
  } else {
    return `${date.getMonth() + 1}月${date.getDate()}日`
  }
}

const getWeekday = (timestamp) => {
  const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
  const date = new Date(timestamp)
  return weekdays[date.getDay()]
}

const formatTime = (timeStr) => {
  return timeStr
}

const viewRecordDetail = (record) => {
  uni.showToast({
    title: '查看学习详情',
    icon: 'none',
  })
}

onMounted(() => {
  studyRecords.value = mockStudyRecords
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

/* 时间选择标签 */
.time-tabs {
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

/* 记录列表 */
.records-list {
  padding: 0 20px;
}

.record-card {
  background: white;
  border-radius: 15px;
  margin-bottom: 15px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  overflow: hidden;
  transition: all 0.3s ease;
}

.record-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.12);
}

.record-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.record-date {
  display: flex;
  flex-direction: column;
}

.date-text {
  font-size: 16px;
  font-weight: bold;
  margin-bottom: 2px;
}

.weekday {
  font-size: 12px;
  opacity: 0.8;
}

.record-summary {
  text-align: right;
}

.study-time {
  font-size: 18px;
  font-weight: bold;
}

.record-content {
  padding: 20px;
}

.record-details {
  margin-bottom: 15px;
}

.detail-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.detail-item:last-child {
  margin-bottom: 0;
}

.detail-label {
  font-size: 14px;
  color: #666;
}

.detail-value {
  font-size: 14px;
  font-weight: 500;
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

.achievements {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 15px;
}

.achievement-tag {
  display: flex;
  align-items: center;
  gap: 4px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-size: 12px;
  padding: 4px 8px;
  border-radius: 12px;
}

.achievement-icon {
  font-size: 14px;
}

.achievement-text {
  font-weight: 500;
}

.record-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
  background: #f8f9fa;
  border-top: 1px solid #e9ecef;
}

.record-time {
  font-size: 12px;
  color: #666;
}

.view-detail {
  font-size: 12px;
  color: #667eea;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 4px;
  transition: background 0.3s ease;
}

.view-detail:hover {
  background: #e3f2fd;
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
</style>
