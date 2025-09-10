<template>
  <view class="page">
    <!-- 顶部导航栏 -->
    <view class="header">
      <view class="header-content">
        <text class="logo">考试结果</text>
        <view class="header-right">
          <text class="back-btn" @click="goBack">返回</text>
        </view>
      </view>
    </view>

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
            <text class="detail-content">{{ questions[currentDetailIndex].question }}</text>
          </view>

          <view class="detail-section">
            <text class="detail-label">你的答案:</text>
            <text
              class="detail-content user-answer"
              :class="{
                correct: userAnswers[currentDetailIndex] === correctAnswers[currentDetailIndex],
              }"
            >
              {{ userAnswers[currentDetailIndex] || '未作答' }}
            </text>
          </view>

          <view class="detail-section">
            <text class="detail-label">正确答案:</text>
            <text class="detail-content correct-answer">{{
              correctAnswers[currentDetailIndex]
            }}</text>
          </view>

          <view class="detail-section explanation">
            <text class="detail-label">题目解析:</text>
            <text class="detail-content explanation-text">{{
              questions[currentDetailIndex].explains
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

const popup = ref<InstanceType<typeof uniPopup>>()

const score = ref(0)
const total = ref(0)
const questions = ref([])
const userAnswers = ref([])
const correctAnswers = ref([])
const currentPage = ref(1)
const visibleQuestions = ref([])

const onload = (e) => {
  console.log('onload')
}
const onclose = (ez) => {
  // console.log("onclose: " + ez.detail);
}
const onerror = (ex) => {
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

onLoad((options) => {
  score.value = options.score
  total.value = options.total
  questions.value = uni.getStorageSync('questions')
  userAnswers.value = uni.getStorageSync('userAnswers')
  correctAnswers.value = questions.value.map((question) => {
    const correctOptionIndex = parseInt(question.answer) - 1
    return [question.item1, question.item2, question.item3, question.item4][correctOptionIndex]
  })
  updateVisibleQuestions()
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
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
  color: #667eea;
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
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
