<template>
  <view class="container">
    <!-- 顶部导航栏 -->
    <view class="header">
      <view class="header-content">
        <view class="header-left" @click="goBack">
          <text class="back-icon">←</text>
          <text class="back-text">返回</text>
        </view>
        <text class="header-title">题目详情</text>
        <view class="header-right">
          <text class="favorite-btn" :class="{ active: isFavorited }" @click="toggleFavorite">
            {{ isFavorited ? '❤️' : '🤍' }}
          </text>
        </view>
      </view>
    </view>

    <!-- 题目信息 -->
    <view class="question-info">
      <view class="question-header">
        <text class="question-number">第 {{ questionInfo.questionId }} 题</text>
        <view class="question-subject">
          <text
            class="subject-tag"
            :class="questionInfo.subject === 1 ? 'subject-one' : 'subject-four'"
          >
            {{ questionInfo.subject === 1 ? '科目一' : '科目四' }}
          </text>
        </view>
      </view>

      <view class="question-content">
        <text class="question-text">{{ questionInfo.question }}</text>

        <!-- 题目图片 -->
        <view v-if="questionInfo.url" class="question-image">
          <image
            class="question-img"
            :src="questionInfo.url"
            mode="aspectFit"
            @click="previewImage(questionInfo.url)"
          />
        </view>

        <!-- 选项列表 -->
        <view class="options-list">
          <view
            v-for="(option, index) in options"
            :key="index"
            v-if="option !== ''"
            class="option-item"
            :class="{
              correct: index === correctAnswerIndex,
              selected: selectedAnswer === index
            }"
          >
            <view class="option-label">
              <text class="option-letter">{{ String.fromCharCode(65 + index) }}</text>
            </view>
            <text class="option-text">{{ option }}</text>
            <view v-if="index === correctAnswerIndex" class="correct-icon">✓</view>
          </view>
        </view>

        <!-- 答案解析 -->
        <view class="answer-section">
          <view class="answer-header">
            <text class="answer-title">答案解析</text>
          </view>
          <view class="answer-content">
            <view class="correct-answer">
              <text class="answer-label">正确答案：</text>
              <text class="answer-value">{{ String.fromCharCode(65 + correctAnswerIndex) }}</text>
            </view>
            <view class="explanation">
              <text class="explanation-title">详细解析：</text>
              <text class="explanation-text">{{ questionInfo.explains || '暂无解析' }}</text>
            </view>
          </view>
        </view>
      </view>
    </view>

    <!-- 操作按钮 -->
    <view class="action-buttons">
      <button class="action-btn practice-btn" @click="startPractice">
        <text class="btn-icon">📝</text>
        <text class="btn-text">开始练习</text>
      </button>
      <button class="action-btn exam-btn" @click="startExam">
        <text class="btn-icon">📋</text>
        <text class="btn-text">模拟考试</text>
      </button>
    </view>

    <!-- 相关题目推荐 -->
    <view class="related-section">
      <view class="section-header">
        <text class="section-title">相关题目</text>
      </view>
      <view class="related-list">
        <view
          v-for="(item, index) in relatedQuestions"
          :key="index"
          class="related-item"
          @click="viewRelatedQuestion(item)"
        >
          <text class="related-number">第{{ item.questionId }}题</text>
          <text class="related-text">{{ item.question }}</text>
          <text class="related-arrow">→</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'

// 数据状态
const questionInfo = ref<any>({})
const isFavorited = ref(true)
const selectedAnswer = ref(-1)
const relatedQuestions = ref([])

// 计算属性
const options = computed(() => {
  if (!questionInfo.value) return []
  return [
    questionInfo.value.item1,
    questionInfo.value.item2,
    questionInfo.value.item3,
    questionInfo.value.item4
  ].filter(item => item && item.trim() !== '')
})

const correctAnswerIndex = computed(() => {
  if (!questionInfo.value.answer) return -1
  return parseInt(questionInfo.value.answer) - 1
})

// 方法
const goBack = () => {
  uni.navigateBack()
}

const toggleFavorite = () => {
  isFavorited.value = !isFavorited.value
  uni.showToast({
    title: isFavorited.value ? '已收藏' : '已取消收藏',
    icon: 'success',
    duration: 1500
  })
}

const previewImage = (url: string) => {
  uni.previewImage({
    urls: [url],
    current: url
  })
}

const startPractice = () => {
  uni.navigateTo({
    url: `/pages/index/sequential/sequential?sub=${questionInfo.value.subject}&startId=${questionInfo.value.questionId}`
  })
}

const startExam = () => {
  uni.navigateTo({
    url: `/pages/index/exam/exam?sub=${questionInfo.value.subject}`
  })
}

const viewRelatedQuestion = (question: any) => {
  uni.redirectTo({
    url: `/pages/question-detail/question-detail?questionId=${question.questionId}&subject=${question.subject}`
  })
}

// 模拟获取题目数据
const fetchQuestionDetail = (questionId: string, subject: string) => {
  // 这里应该调用实际的API获取题目详情
  // 暂时使用模拟数据
  questionInfo.value = {
    questionId: questionId,
    subject: parseInt(subject),
    question: '机动车驾驶人违法驾驶造成重大交通事故构成犯罪的，依法追究什么责任？',
    item1: '道德责任',
    item2: '经济责任',
    item3: '刑事责任',
    item4: '直接责任',
    answer: '3',
    explains: '根据《道路交通安全法》规定，机动车驾驶人违法驾驶造成重大交通事故构成犯罪的，依法追究刑事责任，并由公安机关交通管理部门吊销机动车驾驶证，且终生不得重新取得机动车驾驶证。',
    url: 'https://via.placeholder.com/300x200/4CAF50/white?text=交通标志'
  }

  // 模拟相关题目
  relatedQuestions.value = [
    {
      questionId: parseInt(questionId) + 1,
      subject: parseInt(subject),
      question: '驾驶机动车在道路上违反道路交通安全法的行为，属于什么行为？'
    },
    {
      questionId: parseInt(questionId) + 2,
      subject: parseInt(subject),
      question: '造成交通事故后逃逸，尚不构成犯罪的，处多少日以下拘留？'
    },
    {
      questionId: parseInt(questionId) + 3,
      subject: parseInt(subject),
      question: '驾驶机动车违反道路交通安全法律法规发生重大事故构成犯罪的，依法追究刑事责任，吊销机动车驾驶证，将多少年内不得申请机动车驾驶证？'
    }
  ]
}

onMounted(() => {
  // 获取页面参数
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.options || {}

  const questionId = options.questionId || '1'
  const subject = options.subject || '1'

  fetchQuestionDetail(questionId, subject)
})
</script>

<style lang="scss" scoped>
.container {
  min-height: 100vh;
  background-color: #f5f5f5;
  padding-bottom: 20px;
}

/* 顶部导航栏 */
.header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 8px 0;
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
  height: 44px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.back-icon {
  font-size: 20px;
  font-weight: bold;
}

.back-text {
  font-size: 16px;
}

.header-title {
  font-size: 18px;
  font-weight: bold;
}

.header-right {
  width: 60px;
  text-align: right;
}

.favorite-btn {
  font-size: 20px;
  cursor: pointer;
  transition: transform 0.3s ease;
}

.favorite-btn:hover {
  transform: scale(1.1);
}

.favorite-btn.active {
  animation: heartbeat 0.6s ease-in-out;
}

@keyframes heartbeat {
  0% { transform: scale(1); }
  50% { transform: scale(1.2); }
  100% { transform: scale(1); }
}

/* 题目信息 */
.question-info {
  margin-top: 70px;
  background: white;
  border-radius: 15px;
  margin: 70px 20px 20px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.question-number {
  font-size: 18px;
  font-weight: bold;
}

.subject-tag {
  font-size: 12px;
  padding: 6px 12px;
  border-radius: 12px;
  font-weight: bold;
}

.subject-tag.subject-one {
  background: rgba(76, 175, 80, 0.3);
  color: #4caf50;
}

.subject-tag.subject-four {
  background: rgba(255, 152, 0, 0.3);
  color: #ff9800;
}

.question-content {
  padding: 25px;
}

.question-text {
  font-size: 16px;
  line-height: 1.6;
  color: #333;
  margin-bottom: 20px;
  display: block;
}

.question-image {
  text-align: center;
  margin: 20px 0;
}

.question-img {
  max-width: 100%;
  height: auto;
  border-radius: 8px;
  cursor: pointer;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

/* 选项列表 */
.options-list {
  margin: 25px 0;
}

.option-item {
  display: flex;
  align-items: center;
  padding: 15px;
  margin-bottom: 12px;
  background: #f8f9fa;
  border-radius: 10px;
  border: 2px solid transparent;
  position: relative;
  transition: all 0.3s ease;
}

.option-item.correct {
  background: #e8f5e8;
  border-color: #4caf50;
}

.option-label {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background: #667eea;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 12px;
  flex-shrink: 0;
}

.option-item.correct .option-label {
  background: #4caf50;
}

.option-letter {
  color: white;
  font-size: 14px;
  font-weight: bold;
}

.option-text {
  flex: 1;
  font-size: 15px;
  line-height: 1.5;
  color: #333;
}

.correct-icon {
  color: #4caf50;
  font-size: 18px;
  font-weight: bold;
  margin-left: 10px;
}

/* 答案解析 */
.answer-section {
  background: #f8f9fa;
  border-radius: 10px;
  padding: 20px;
  margin-top: 20px;
}

.answer-header {
  margin-bottom: 15px;
}

.answer-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
}

.correct-answer {
  display: flex;
  align-items: center;
  margin-bottom: 15px;
}

.answer-label {
  font-size: 14px;
  color: #666;
  margin-right: 8px;
}

.answer-value {
  font-size: 16px;
  font-weight: bold;
  color: #4caf50;
}

.explanation-title {
  font-size: 14px;
  font-weight: bold;
  color: #666;
  display: block;
  margin-bottom: 8px;
}

.explanation-text {
  font-size: 14px;
  line-height: 1.6;
  color: #555;
  display: block;
}

/* 操作按钮 */
.action-buttons {
  display: flex;
  gap: 15px;
  padding: 0 20px;
  margin-bottom: 30px;
}

.action-btn {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 20px;
  border-radius: 15px;
  border: none;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.practice-btn {
  background: linear-gradient(135deg, #4caf50 0%, #81c784 100%);
  color: white;
}

.exam-btn {
  background: linear-gradient(135deg, #2196f3 0%, #64b5f6 100%);
  color: white;
}

.action-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
}

.btn-icon {
  font-size: 24px;
}

.btn-text {
  font-size: 14px;
  font-weight: bold;
}

/* 相关题目 */
.related-section {
  background: white;
  border-radius: 15px;
  margin: 0 20px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.section-header {
  padding: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.section-title {
  font-size: 16px;
  font-weight: bold;
}

.related-list {
  padding: 0;
}

.related-item {
  display: flex;
  align-items: center;
  padding: 15px 20px;
  border-bottom: 1px solid #f0f0f0;
  cursor: pointer;
  transition: background 0.3s ease;
}

.related-item:last-child {
  border-bottom: none;
}

.related-item:hover {
  background: #f8f9fa;
}

.related-number {
  font-size: 12px;
  color: #667eea;
  font-weight: bold;
  margin-right: 10px;
  min-width: 50px;
}

.related-text {
  flex: 1;
  font-size: 14px;
  color: #666;
  line-height: 1.4;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.related-arrow {
  color: #ccc;
  font-size: 16px;
}
</style>
