<template>
  <view class="container">

    <!-- 考试统计卡片 -->
    <view class="stats-card">
      <view class="stats-grid">
        <view class="stat-item">
          <text class="stat-number">{{ totalExams }}</text>
          <text class="stat-label">考试次数</text>
        </view>
        <view class="stat-item">
          <text class="stat-number">{{ passedExams }}</text>
          <text class="stat-label">通过次数</text>
        </view>
        <view class="stat-item">
          <text class="stat-number">{{ passRate }}%</text>
          <text class="stat-label">通过率</text>
        </view>
        <view class="stat-item">
          <text class="stat-number">{{ highestScore }}</text>
          <text class="stat-label">最高分</text>
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

    <!-- 考试记录列表 -->
    <view class="exams-list">
      <view
        v-for="(exam, index) in filteredExams"
        :key="index"
        class="exam-card"
        @click="viewExamDetail(exam)"
      >
        <view class="exam-header">
          <view class="exam-info">
            <text class="exam-title">{{ getSubjectName(exam.subject) }}模拟考试</text>
            <text class="exam-date">{{ formatDate(exam.date) }}</text>
          </view>
          <view class="exam-result" :class="getResultClass(exam.score)">
            <text class="score-text">{{ exam.score }}分</text>
            <text class="result-text">{{ exam.score >= 90 ? '通过' : '未通过' }}</text>
          </view>
        </view>

        <view class="exam-content">
          <view class="exam-details">
            <view class="detail-row">
              <view class="detail-item">
                <text class="detail-label">答题数量:</text>
                <text class="detail-value">{{ exam.totalQuestions }}题</text>
              </view>
              <view class="detail-item">
                <text class="detail-label">正确数量:</text>
                <text class="detail-value">{{ exam.correctAnswers }}题</text>
              </view>
            </view>
            <view class="detail-row">
              <view class="detail-item">
                <text class="detail-label">用时:</text>
                <text class="detail-value">{{ exam.duration }}分钟</text>
              </view>
              <view class="detail-item">
                <text class="detail-label">正确率:</text>
                <text class="detail-value" :class="getAccuracyClass(exam.accuracy)">
                  {{ exam.accuracy }}%
                </text>
              </view>
            </view>
          </view>

          <!-- 错题统计 -->
          <view v-if="exam.wrongQuestions > 0" class="wrong-questions">
            <text class="wrong-title">错题分布</text>
            <view class="wrong-categories">
              <view
                v-for="(category, cIndex) in exam.wrongCategories"
                :key="cIndex"
                class="wrong-category"
              >
                <text class="category-name">{{ category.name }}</text>
                <text class="category-count">{{ category.count }}题</text>
              </view>
            </view>
          </view>
        </view>

        <view class="exam-footer">
          <view class="exam-time">
            <text class="time-text"
              >{{ formatTime(exam.startTime) }} - {{ formatTime(exam.endTime) }}</text
            >
          </view>
          <view class="exam-actions">
            <text class="action-btn" @click.stop="retakeExam(exam)">重新考试</text>
            <text class="action-btn" @click.stop="reviewExam(exam)">查看详情</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 空状态 -->
    <view v-if="filteredExams.length === 0" class="empty-state">
      <text class="empty-icon">📋</text>
      <text class="empty-title">暂无考试记录</text>
      <text class="empty-desc">完成模拟考试后会在这里显示记录</text>
    </view>

    <!-- 筛选弹窗 -->
    <view v-if="showFilterModal" class="modal" @click="showFilterModal = false">
      <view class="modal-content" @click.stop>
        <view class="modal-header">
          <text class="modal-title">筛选考试</text>
          <text class="close" @click="showFilterModal = false">&times;</text>
        </view>
        <view class="modal-body">
          <view class="filter-section">
            <text class="filter-title">按结果筛选</text>
            <view class="filter-options">
              <view
                v-for="option in resultFilterOptions"
                :key="option.value"
                class="filter-option"
                :class="{ active: selectedResultFilter === option.value }"
                @click="selectResultFilter(option.value)"
              >
                {{ option.label }}
              </view>
            </view>
          </view>

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
const examRecords = ref([])
const selectedSubject = ref('all')
const showFilterModal = ref(false)
const selectedResultFilter = ref('all')
const selectedTimeFilter = ref('all')

// 筛选选项
const resultFilterOptions = ref([
  { label: '全部结果', value: 'all' },
  { label: '通过', value: 'passed' },
  { label: '未通过', value: 'failed' },
])

const timeFilterOptions = ref([
  { label: '全部时间', value: 'all' },
  { label: '最近一周', value: 'week' },
  { label: '最近一月', value: 'month' },
  { label: '最近三月', value: 'quarter' },
])

// 模拟考试记录数据
const mockExamRecords = [
  {
    date: Date.now() - 86400000, // 1天前
    subject: 1,
    score: 95,
    totalQuestions: 100,
    correctAnswers: 95,
    accuracy: 95,
    duration: 42,
    startTime: '14:30',
    endTime: '15:12',
    wrongQuestions: 5,
    wrongCategories: [
      { name: '交通标志', count: 2 },
      { name: '安全行车', count: 3 },
    ],
  },
  {
    date: Date.now() - 172800000, // 2天前
    subject: 1,
    score: 88,
    totalQuestions: 100,
    correctAnswers: 88,
    accuracy: 88,
    duration: 45,
    startTime: '19:15',
    endTime: '20:00',
    wrongQuestions: 12,
    wrongCategories: [
      { name: '交通法规', count: 5 },
      { name: '违法处罚', count: 4 },
      { name: '安全行车', count: 3 },
    ],
  },
  {
    date: Date.now() - 259200000, // 3天前
    subject: 4,
    score: 82,
    totalQuestions: 50,
    correctAnswers: 41,
    accuracy: 82,
    duration: 28,
    startTime: '20:10',
    endTime: '20:38',
    wrongQuestions: 9,
    wrongCategories: [
      { name: '紧急处置', count: 4 },
      { name: '恶劣天气', count: 3 },
      { name: '违法处罚', count: 2 },
    ],
  },
  {
    date: Date.now() - 518400000, // 6天前
    subject: 1,
    score: 76,
    totalQuestions: 100,
    correctAnswers: 76,
    accuracy: 76,
    duration: 45,
    startTime: '15:45',
    endTime: '16:30',
    wrongQuestions: 24,
    wrongCategories: [
      { name: '交通标志', count: 8 },
      { name: '机动车构造', count: 7 },
      { name: '安全行车', count: 5 },
      { name: '交通法规', count: 4 },
    ],
  },
]

// 统计数据
const totalExams = computed(() => examRecords.value.length)
const passedExams = computed(() => examRecords.value.filter((exam) => exam.score >= 90).length)
const passRate = computed(() => {
  if (totalExams.value === 0) return 0
  return Math.round((passedExams.value / totalExams.value) * 100)
})
const highestScore = computed(() => {
  if (examRecords.value.length === 0) return 0
  return Math.max(...examRecords.value.map((exam) => exam.score))
})

// 筛选后的考试列表
const filteredExams = computed(() => {
  let filtered = examRecords.value

  // 按科目筛选
  if (selectedSubject.value !== 'all') {
    filtered = filtered.filter((exam) => exam.subject === selectedSubject.value)
  }

  // 按结果筛选
  if (selectedResultFilter.value !== 'all') {
    if (selectedResultFilter.value === 'passed') {
      filtered = filtered.filter((exam) => exam.score >= 90)
    } else if (selectedResultFilter.value === 'failed') {
      filtered = filtered.filter((exam) => exam.score < 90)
    }
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
      filtered = filtered.filter((exam) => exam.date > timeLimit)
    }
  }

  return filtered.sort((a, b) => b.date - a.date)
})

// 方法
const selectSubject = (subject) => {
  selectedSubject.value = subject
}

const selectResultFilter = (filter) => {
  selectedResultFilter.value = filter
}

const selectTimeFilter = (filter) => {
  selectedTimeFilter.value = filter
}

const getSubjectName = (subject) => {
  return subject === 1 ? '科目一' : '科目四'
}

const getResultClass = (score) => {
  return score >= 90 ? 'passed' : 'failed'
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

const formatTime = (timeStr) => {
  return timeStr
}

const viewExamDetail = (exam) => {
  uni.showToast({
    title: '查看考试详情',
    icon: 'none',
  })
}

const retakeExam = (exam) => {
  uni.showModal({
    title: '重新考试',
    content: `确定要重新进行${getSubjectName(exam.subject)}模拟考试吗？`,
    success: (res) => {
      if (res.confirm) {
        uni.navigateTo({
          url: `/pages/index/exam/exam?sub=${exam.subject}`,
        })
      }
    },
  })
}

const reviewExam = (exam) => {
  uni.showToast({
    title: '查看考试答题详情',
    icon: 'none',
  })
}

onMounted(() => {
  examRecords.value = mockExamRecords
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
  margin: 0px 20px 20px;
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

/* 考试列表 */
.exams-list {
  padding: 0 20px;
}

.exam-card {
  background: white;
  border-radius: 15px;
  margin-bottom: 15px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s ease;
}

.exam-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.12);
}

.exam-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.exam-info {
  display: flex;
  flex-direction: column;
}

.exam-title {
  font-size: 16px;
  font-weight: bold;
  margin-bottom: 4px;
}

.exam-date {
  font-size: 12px;
  opacity: 0.8;
}

.exam-result {
  text-align: right;
}

.score-text {
  font-size: 24px;
  font-weight: bold;
  display: block;
  margin-bottom: 2px;
}

.result-text {
  font-size: 12px;
  padding: 2px 8px;
  border-radius: 8px;
  font-weight: 500;
}

.exam-result.passed .result-text {
  background: rgba(76, 175, 80, 0.2);
  color: #4caf50;
}

.exam-result.failed .result-text {
  background: rgba(244, 67, 54, 0.2);
  color: #f44336;
}

.exam-content {
  padding: 20px;
}

.exam-details {
  margin-bottom: 15px;
}

.detail-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
}

.detail-row:last-child {
  margin-bottom: 0;
}

.detail-item {
  flex: 1;
  display: flex;
  justify-content: space-between;
  align-items: center;
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

.wrong-questions {
  border-top: 1px solid #f0f0f0;
  padding-top: 15px;
}

.wrong-title {
  font-size: 14px;
  font-weight: bold;
  color: #333;
  margin-bottom: 10px;
  display: block;
}

.wrong-categories {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.wrong-category {
  display: flex;
  align-items: center;
  gap: 4px;
  background: #ffebee;
  color: #f44336;
  font-size: 12px;
  padding: 4px 8px;
  border-radius: 8px;
}

.category-name {
  font-weight: 500;
}

.category-count {
  font-weight: bold;
}

.exam-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
  background: #f8f9fa;
  border-top: 1px solid #e9ecef;
}

.exam-time {
  flex: 1;
}

.time-text {
  font-size: 12px;
  color: #666;
}

.exam-actions {
  display: flex;
  gap: 15px;
}

.action-btn {
  font-size: 12px;
  color: #667eea;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 4px;
  transition: background 0.3s ease;
}

.action-btn:hover {
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
