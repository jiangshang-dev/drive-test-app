<template>
  <view class="page">
    <!-- 主要内容区域 -->
    <view class="main-content">
      <!-- 成绩卡片 -->
      <view class="score-card">
        <view class="score-header">
          <text class="score-title">您的得分</text>
          <view class="score-badge" :class="{ pass: score >= 90, fail: score < 90 }">
            <text v-if="score >= 90" class="result-text pass">合格</text>
            <text v-else class="result-text fail">不合格</text>
          </view>
        </view>
        <view class="score-display">
          <text class="score-number">{{ score }}</text>
          <text class="score-divider">/</text>
          <text class="total-number">{{ total }}</text>
        </view>
        <view class="score-percentage">
          <text class="percentage-text">{{ Math.round((score / total) * 100) }}%</text>
        </view>
      </view>

      <!-- 答题详情卡片 -->
      <view class="details-card">
        <view class="details-header">
          <text class="details-title">答题详情</text>
          <view class="stats-info">
            <text class="stats-text"
              >第{{ currentPage }}页，共{{ Math.ceil(questions.length / 20) }}页</text
            >
          </view>
        </view>

        <!-- 题目网格 -->
        <view class="questions-grid">
          <view
            v-for="(question, index) in visibleQuestions"
            :key="index"
            class="question-item"
            :class="{
              correct:
                userAnswers[index + (currentPage - 1) * 20] ===
                correctAnswers[index + (currentPage - 1) * 20],
              incorrect:
                userAnswers[index + (currentPage - 1) * 20] !==
                correctAnswers[index + (currentPage - 1) * 20],
            }"
            @click="showQuestionDetail(index + (currentPage - 1) * 20)"
          >
            <text class="question-number">{{ index + 1 + (currentPage - 1) * 20 }}</text>
            <view class="question-status">
              <text
                class="status-icon"
                v-if="
                  userAnswers[index + (currentPage - 1) * 20] ===
                  correctAnswers[index + (currentPage - 1) * 20]
                "
                >✓</text
              >
              <text class="status-icon" v-else>✗</text>
            </view>
          </view>
        </view>

        <!-- 分页器 -->
        <view class="pagination-section">
          <view class="pagination-controls">
            <button
              class="page-btn prev-btn"
              :class="{ disabled: currentPage === 1 }"
              :disabled="currentPage === 1"
              @click="handlePageChange({ current: currentPage - 1 })"
            >
              上一页
            </button>
            <text class="page-info"
              >{{ currentPage }} / {{ Math.ceil(questions.length / 20) }}</text
            >
            <button
              class="page-btn next-btn"
              :class="{ disabled: currentPage === Math.ceil(questions.length / 20) }"
              :disabled="currentPage === Math.ceil(questions.length / 20)"
              @click="handlePageChange({ current: currentPage + 1 })"
            >
              下一页
            </button>
          </view>
        </view>
      </view>
    </view>

    <!-- 题目详情弹窗 -->
    <view v-if="currentDetailIndex > -1" class="modal" @click="closeQuestionDetail">
      <view class="modal-content" @click.stop>
        <view class="modal-header">
          <text class="modal-title">第{{ currentDetailIndex + 1 }}题详情</text>
          <view
            class="modal-status"
            :class="{
              correct: userAnswers[currentDetailIndex] === correctAnswers[currentDetailIndex],
              incorrect: userAnswers[currentDetailIndex] !== correctAnswers[currentDetailIndex],
            }"
          >
            <text
              class="modal-status-icon"
              v-if="userAnswers[currentDetailIndex] === correctAnswers[currentDetailIndex]"
              >✓</text
            >
            <text class="modal-status-icon" v-else>✗</text>
            <text
              class="modal-status-text"
              v-if="userAnswers[currentDetailIndex] === correctAnswers[currentDetailIndex]"
              >答对了</text
            >
            <text class="modal-status-text" v-else>答错了</text>
          </view>
          <text class="close" @click="closeQuestionDetail">&times;</text>
        </view>

        <view class="modal-body">
          <view class="detail-section">
            <text class="detail-label">题目:</text>
            <text class="detail-content">{{ questions[currentDetailIndex].questionContent }}</text>
          </view>

          <!-- 题目选项 -->
          <view class="detail-setion">
            <text lass="detail-label">选项:</text>
            <view class="options-list">
              <view
                class="option-item"
                :class="{
                  'user-selected': getUserAnswerLetter(currentDetailIndex) === 'A',
                  'correct-option': 'A' === getCorrectAnswerLetter(currentDetailIndex),
                }"
              >
                <text class="option-letter">A.</text>
                <text class="optiontext">{{ questions[currentDetailIndex].optionA }}</text>
              </view>
              <view
                class="option-item"
                :class="{
                  'user-selected': getUserAnswerLetter(currentDetailIndex) === 'B',
                  'correct-option': 'B' === getCorrectAnswerLetter(currentDetailIndex),
                }"
              >
                <text class="option-letter">B.</text>
                <text class="option-text">{{ questions[currentDetailIndex].optionB }}</text>
              </view>
              <view
                class="option-item"
                :class="{
                  'user-selected': getUserAnswerLetter(currentDetailIndex) === 'C',
                  'correct-option': 'C' === getCorrectAnswerLetter(currentDetailIndex),
                }"
              >
                <text class="option-letter">C.</text>
                <text class="opton-text">{{ questions[currentDetailIndex].optionC }}</text>
              </view>
              <view
                class="option-item"
                :class="{
                  'user-selected': getUserAnswerLetter(currentDetailIndex) === 'D',
                  'correct-option': 'D' === getCorrectAnswerLetter(currentDetailIndex),
                }"
              >
                <text class="option-letter">D.</text>
                <text class="option-text">{{ questions[currentDetailIndex].optionD }}</text>
              </view>
            </view>
          </view>

          <view class="detail-section">
            <text class="detail-label">你的答案:</text>
            <text
              class="detail-content user-answer"
              :class="{
                correct: userAnswers[currentDetailIndex] === correctAnswers[currentDetailIndex],
              }"
            >
              {{ getUserAnswerWithContent(currentDetailIndex) || '未作答' }}
            </text>
          </view>

          <view class="detail-section">
            <text class="detail-label">正确答案:</text>
            <text class="detail-content correct-answer">
              {{ getCorrectAnswerWithContent(currentDetailIndex) }}
            </text>
          </view>

          <!-- 难度等级 -->
          <view class="detail-section">
            <text class="detail-label">难度等级:</text>
            <text class="detail-content difficulty-level">
              {{ getDifficultyLevelText(questions[currentDetailIndex].difficultyLevel) }}
            </text>
          </view>

          <view class="detail-section explanation">
            <text class="detail-label">题目解析:</text>
            <text class="detail-content explanation-text">{{
              questions[currentDetailIndex].questionExplain
            }}</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 广告区域 -->
    <view class="ad-view">
      <ad adpid="1478175623" @load="onload" @close="onclose" @error="onerror"></ad>
    </view>
  </view>
</template>

<script lang="ts" setup>
import { onLoad } from '@dcloudio/uni-app'
import { ref } from 'vue'
import uniPopup from '@dcloudio/uni-ui/lib/uni-popup/uni-popup.vue'
import { http } from '@/utils/http'

// 定义题目接口
interface Question {
  examType: string
  questionType: string
  questionName: string
  questionContent: string
  questionFormat: number
  optionA: string
  optionB: string
  optionC: string
  optionD: string
  correctAnswer: string
  questionExplain: string
  imageUrl: string
  video: string
  audio: string
  difficultyLevel: number
  isVip: number
  isHot: number
  sequenceOrder: number
  [key: string]: any // 允许其他属性
}

const popup = ref<InstanceType<typeof uniPopup> | null>(null)

const score = ref(0)
const total = ref(0)
const questions = ref<Question[]>([])
const userAnswers = ref<string[]>([])
const correctAnswers = ref<string[]>([])
const currentPage = ref(1)
const visibleQuestions = ref<Question[]>([])

const onload = (e: any) => {
  console.log('onload')
}
const onclose = (ez: any) => {
  // console.log("onclose: " + ez.detail);
}
const onerror = (ex: any) => {
  // console.log("onerror: " + ex.detail.errCode + " message:: " + ex.detail.errMsg);
}

// 计算当前页显示的问题
const updateVisibleQuestions = () => {
  const start = (currentPage.value - 1) * 20
  const end = start + 20
  visibleQuestions.value = questions.value.slice(start, end)
}

const handlePageChange = (e: { current: number }) => {
  currentPage.value = e.current
  updateVisibleQuestions()
}

onLoad((options: any) => {
  if (options) {
    score.value = parseInt(options.score) || 0
    total.value = parseInt(options.total) || 0
  }
  const storedQuestions = uni.getStorageSync('questions') || []
  const storedUserAnswers = uni.getStorageSync('userAnswers') || []

  questions.value = storedQuestions
  userAnswers.value = storedUserAnswers

  correctAnswers.value = storedQuestions.map((question: Question) => {
    const correctOptionIndex = parseInt(question.correctAnswer) - 1
    return [question.optionA, question.optionB, question.optionC, question.optionD][
      correctOptionIndex
    ]
  })
  updateVisibleQuestions()
  http({ url: '/mall/points/grant', method: 'POST', silent: true, data: { scene: 'MOCK_EXAM' } }).catch(() => {})
})

// 跳转到指定题目
const currentDetailIndex = ref(-1)

const showQuestionDetail = (index: number) => {
  currentDetailIndex.value = index
  // popup.value?.open();
}

const closeQuestionDetail = () => {
  currentDetailIndex.value = -1
}

// 返回功能
const goBack = () => {
  uni.navigateBack({
    delta: 1,
  })
}

// 获取用户答案的字母
const getUserAnswerLetter = (index: number): string => {
  const userAnswer = userAnswers.value[index]
  if (!userAnswer) return ''

  const question = questions.value[index]
  if (!question) return ''

  const options = [question.optionA, question.optionB, question.optionC, question.optionD]
  const optionIndex = options.indexOf(userAnswer)
  return optionIndex !== -1 ? String.fromCharCode(65 + optionIndex) : ''
}

// 获取正确答案的字母
const getCorrectAnswerLetter = (index: number): string => {
  const question = questions.value[index]
  if (!question) return ''

  const correctOptionIndex = parseInt(question.correctAnswer) - 1
  return String.fromCharCode(65 + correctOptionIndex)
}

// 获取用户答案带内容
const getUserAnswerWithContent = (index: number): string => {
  const userAnswerLetter = getUserAnswerLetter(index)
  if (!userAnswerLetter) return ''

  const question = questions.value[index]
  if (!question) return userAnswerLetter

  const optionContent = question[`option${userAnswerLetter}` as keyof Question]
  return `${userAnswerLetter}. ${optionContent}`
}

// 获取正确答案带内容
const getCorrectAnswerWithContent = (index: number): string => {
  const correctAnswerLetter = getCorrectAnswerLetter(index)
  if (!correctAnswerLetter) return ''

  const question = questions.value[index]
  if (!question) return correctAnswerLetter

  const optionContent = question[`option${correctAnswerLetter}` as keyof Question]
  return `${correctAnswerLetter}. ${optionContent}`
}

// 获取难度等级文本
const getDifficultyLevelText = (level: number): string => {
  switch (level) {
    case 1:
      return '简单'
    case 2:
      return '中等'
    case 3:
      return '困难'
    default:
      return '未知'
  }
}
</script>

<style lang="scss">
/* 基础样式 */
view,
text,
image,
button {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

.page {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background-color: #f5f5f5;
  color: #333;
  line-height: 1.6;
  min-height: 100vh;
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
  max-width: 960px;
  margin: 0 auto;
}

.logo {
  font-size: 18px;
  font-weight: bold;
}

.back-btn {
  font-size: 14px;
  padding: 6px 12px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 15px;
  cursor: pointer;
}

/* 主要内容区域 */
.main-content {
  margin-top: 80px;
  padding: 20px;
  max-width: 960px;
  margin-left: auto;
  margin-right: auto;
}

/* 成绩卡片 */
.score-card {
  background: white;
  border-radius: 15px;
  padding: 30px;
  margin-bottom: 20px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  text-align: center;
  position: relative;
  overflow: hidden;
}

.score-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(135deg, #0f766e 0%, #115e59 100%);
}

.score-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.score-title {
  font-size: 18px;
  font-weight: 600;
  color: #333;
}

.score-badge {
  padding: 6px 16px;
  border-radius: 20px;
  font-weight: 600;
}

.score-badge.pass {
  background: linear-gradient(135deg, #4caf50 0%, #45a049 100%);
}

.score-badge.fail {
  background: linear-gradient(135deg, #f44336 0%, #d32f2f 100%);
}

.result-text {
  color: white;
  font-size: 14px;
}

.score-display {
  display: flex;
  justify-content: center;
  align-items: baseline;
  margin-bottom: 10px;
}

.score-number {
  font-size: 48px;
  font-weight: bold;
  color: #0f766e;
}

.score-divider {
  font-size: 32px;
  color: #999;
  margin: 0 8px;
}

.total-number {
  font-size: 24px;
  color: #666;
}

.score-percentage {
  margin-top: 10px;
}

.percentage-text {
  font-size: 16px;
  color: #666;
  font-weight: 500;
}

/* 答题详情卡片 */
.details-card {
  background: white;
  border-radius: 15px;
  padding: 20px;
  margin-bottom: 20px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
}

.details-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 1px solid #f0f0f0;
}

.details-title {
  font-size: 18px;
  font-weight: 600;
  color: #333;
}

.stats-info {
  font-size: 14px;
  color: #666;
}

/* 题目网格 */
.questions-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 12px;
  margin-bottom: 25px;
}

.question-item {
  background: #f8f9fa;
  border-radius: 10px;
  padding: 15px 10px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 2px solid transparent;
  position: relative;
}

.question-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
}

.question-item.correct {
  background: linear-gradient(135deg, #e8f5e9 0%, #c8e6c9 100%);
  border-color: #4caf50;
}

.question-item.incorrect {
  background: linear-gradient(135deg, #ffebee 0%, #ffcdd2 100%);
  border-color: #f44336;
}

.question-number {
  font-size: 14px;
  font-weight: 600;
  color: #333;
  display: block;
  margin-bottom: 5px;
}

.question-status {
  display: flex;
  justify-content: center;
}

.status-icon {
  font-size: 18px;
  font-weight: bold;
}

.question-item.correct .status-icon {
  color: #4caf50;
}

.question-item.incorrect .status-icon {
  color: #f44336;
}

/* 分页器 */
.pagination-section {
  border-top: 1px solid #f0f0f0;
  padding-top: 20px;
}

.pagination-controls {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 20px;
}

.page-btn {
  padding: 8px 16px;
  border-radius: 20px;
  border: none;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  background: linear-gradient(135deg, #0f766e 0%, #115e59 100%);
  color: white;
}

.page-btn:hover:not(.disabled) {
  transform: translateY(-1px);
  box-shadow: 0 3px 10px rgba(102, 126, 234, 0.3);
}

.page-btn.disabled {
  background: #e0e0e0;
  color: #999;
  cursor: not-allowed;
  transform: none;
}

.page-info {
  font-size: 14px;
  color: #666;
  font-weight: 500;
  min-width: 60px;
  text-align: center;
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
  max-width: 500px;
  max-height: 80vh;
  overflow: hidden;
}

.modal-header {
  background: linear-gradient(135deg, #0f766e 0%, #115e59 100%);
  color: white;
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-title {
  font-size: 18px;
  font-weight: bold;
  flex: 1;
}

.modal-status {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-right: 15px;
}

.modal-status.correct {
  color: #c8e6c9;
}

.modal-status.incorrect {
  color: #ffcdd2;
}

.modal-status-icon {
  font-size: 16px;
  font-weight: bold;
}

.modal-status-text {
  font-size: 14px;
  font-weight: 500;
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

.detail-section {
  margin-bottom: 20px;
}

.detail-section.explanation {
  background: #f8f9fa;
  padding: 15px;
  border-radius: 8px;
}

.detail-label {
  font-size: 14px;
  font-weight: 600;
  color: #333;
  margin-bottom: 8px;
  display: block;
}

.detail-content {
  font-size: 14px;
  color: #666;
  line-height: 1.5;
  display: block;
}

.user-answer {
  padding: 8px 12px;
  background: #e3f2fd;
  color: #1976d2;
  border-radius: 6px;
  font-weight: 500;
}

.user-answer.correct {
  background: #e8f5e8;
  color: #4caf50;
}

.correct-answer {
  padding: 8px 12px;
  background: #e8f5e8;
  color: #4caf50;
  border-radius: 6px;
  font-weight: 500;
}

.explanation-text {
  color: #555;
  line-height: 1.6;
}

/* 广告区域 */
.ad-view {
  background-color: #ffffff;
  margin: 20px;
  border-radius: 15px;
  overflow: hidden;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
}

/* 题目选项样式 */
.options-list {
  margin-top: 10px;
}

.option-item {
  display: flex;
  align-items: flex-start;
  padding: 10px;
  margin-bottom: 8px;
  background: #f8f9fa;
  border-radius: 8px;
  border: 2px solid transparent;
}

.option-item.user-selected {
  background: #e3f2fd;
  border-color: #2196f3;
}

.option-item.correct-option {
  background: #e8f5e8;
  border-color: #4caf50;
}

.opt ion-letter {
  font-weight: bold;
  margin-right: 10px;
  color: #0f766e;
}

.option-text {
  flex: 1;
  font-size: 14px;
  line-height: 1.5;
}

.detail-content.difficulty-level {
  padding: 6px 12px;
  background: #f8f9fa;
  border-radius: 6px;
  font-weight: 500;
  color: #666;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .header-content {
    padding: 0 15px;
  }

  .main-content {
    padding: 15px;
  }

  .questions-grid {
    grid-template-columns: repeat(4, 1fr);
    gap: 10px;
  }

  .score-card {
    padding: 20px;
  }

  .score-number {
    font-size: 36px;
  }

  .pagination-controls {
    gap: 15px;
  }
}

@media (max-width: 480px) {
  .questions-grid {
    grid-template-columns: repeat(3, 1fr);
  }

  .score-display {
    flex-direction: column;
    gap: 5px;
  }

  .score-divider {
    display: none;
  }
}
</style>
