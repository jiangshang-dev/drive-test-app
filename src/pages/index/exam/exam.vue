<template>
  <view class="page">
    <!-- 顶部导航栏 -->
    <view class="header">
      <view class="header-content">
        <text class="logo">
          <text v-if="sub == 1">科目一</text>
          <text v-else-if="sub == 4">科目四</text>
          模拟考试
        </text>
        <view class="header-info">
          <text class="current-question">{{ currentNo }}/{{ count }}</text>
          <text class="timer">{{ formattedTime }}</text>
        </view>
      </view>
    </view>

    <!-- 主要内容区域 -->
    <view class="main-content">
      <!-- 题目卡片 -->
      <view class="question-card">
        <view class="question-header">
          <text class="question-title">{{ questions[currentQuestionIndex]?.question }}</text>
        </view>

        <!-- 题目图片 -->
        <view v-if="questions[currentQuestionIndex]?.url != ''" class="question-image">
          <image
            class="question-img"
            mode="aspectFit"
            :src="questions[currentQuestionIndex]?.url"
            @click="showImagePopup(currentQuestionIndex, questions[currentQuestionIndex]?.url)"
          />
        </view>

        <!-- 选项列表 -->
        <view class="options-list">
          <template v-for="(option, index) in options" :key="index">
            <view
              v-if="option !== ''"
              class="option-item"
              :class="{ active: userAnswers[currentQuestionIndex] === option }"
              @click="selectOption(index)"
            >
              <view class="option-radio">
                <view
                  class="radio-dot"
                  :class="{ checked: userAnswers[currentQuestionIndex] === option }"
                ></view>
              </view>
              <text class="option-text"> {{ String.fromCharCode(65 + index) }}. {{ option }} </text>
            </view>
          </template>
        </view>
      </view>

      <!-- 答案解析卡片 -->
      <view v-if="showAnswer" class="answer-card">
        <view class="answer-header">
          <text class="answer-title">答案解析</text>
          <view class="answer-result">
            <text v-if="isCorrectAnswer" class="result-correct">✓ 答对了</text>
            <text v-else class="result-incorrect">✗ 答错了</text>
          </view>
        </view>

        <view class="answer-content">
          <view class="answer-item">
            <text class="answer-label">你的答案:</text>
            <text class="answer-value user-answer">{{ userAnswerLetter }}</text>
          </view>
          <view class="answer-item">
            <text class="answer-label">正确答案:</text>
            <text class="answer-value correct-answer">{{ correctAnswerLetter }}</text>
          </view>
          <view class="explanation">
            <text class="explanation-title">题目解析:</text>
            <text class="explanation-text">{{ questions[currentQuestionIndex].explains }}</text>
          </view>
        </view>
      </view>

      <!-- 控制按钮 -->
      <view class="control-buttons">
        <button
          class="control-btn prev-btn"
          :class="{ disabled: currentQuestionIndex === 0 }"
          :disabled="currentQuestionIndex === 0"
          @click="prevQuestion"
        >
          上一题
        </button>
        <button
          class="control-btn next-btn"
          :class="{ disabled: currentQuestionIndex === questions.length - 1 }"
          :disabled="currentQuestionIndex === questions.length - 1"
          @click="nextQuestion"
        >
          下一题
        </button>
        <button class="control-btn submit-btn" @click="submitExam">交卷</button>
      </view>

      <!-- 最后一题的提交按钮 -->
      <view v-if="currentQuestionIndex === questions.length - 1 && showAnswer" class="final-submit">
        <button class="final-submit-btn" @click="goToSubmitPage">完成考试</button>
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
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import { http } from '@/utils/http'

const questions = ref([]) // 题目列表
const userAnswers = ref([]) // 用户的答案列表
const currentQuestionIndex = ref(0) // 当前题目索引
const showAnswer = ref(false) // 是否显示答案
const count = ref(0) // 题目总数
const sub = ref(0) // 科目类型

onLoad((options) => {
  sub.value = options.sub
  getData(sub.value)
})

const onload = (e) => {
  console.log('onload')
}
const onclose = (ez) => {
  // console.log("onclose: " + ez.detail);
}
const onerror = (ex) => {
  // console.log("onerror: " + ex.detail.errCode + " message:: " + ex.detail.errMsg);
}

const examDuration = 45 * 60 // 考试时长，单位为秒
const remainingTime = ref(examDuration) // 剩余时间
const isTimerPaused = ref(false) // 计时器是否暂停
let timer: number | null = null // 定时器

// 启动倒计时
const startTimer = () => {
  timer = setInterval(() => {
    if (!isTimerPaused.value && remainingTime.value > 0) {
      remainingTime.value--
    } else {
      clearInterval(timer!)
      submitExam() // 倒计时结束，自动提交
    }
  }, 1000)
}

// 在页面加载时启动倒计时
onMounted(() => {
  startTimer()
})

// 在页面卸载时清除定时器
onUnmounted(() => {
  if (timer) {
    clearInterval(timer)
  }
})

// 格式化时间显示
const formattedTime = computed(() => {
  const minutes = Math.floor(remainingTime.value / 60)
  const seconds = remainingTime.value % 60
  return `${minutes}:${seconds < 10 ? '0' : ''}${seconds}`
})

const isSubmitting = ref(false) // 添加一个标志位，防止多次提交

// 提交考试
const submitExam = () => {
  if (isSubmitting.value) return
  isSubmitting.value = true

  // 暂停计时器
  isTimerPaused.value = true

  // 计算总分
  const totalScore = userAnswers.value.reduce((score, answer, index) => {
    const correctOptionIndex = parseInt(questions.value[index].answer) - 1
    const options = [
      questions.value[index].item1,
      questions.value[index].item2,
      questions.value[index].item3,
      questions.value[index].item4,
    ]
    return answer === options[correctOptionIndex] ? score + 1 : score
  }, 0)

  // 计算未做题目总数
  const unansweredCount = userAnswers.value.filter((answer) => answer === '').length

  // 判断成绩是否合格
  const isPass = totalScore >= 90
  const resultText = isPass ? '成绩合格' : '成绩不合格'
  const resultColor = isPass ? 'green' : 'red'

  // 显示交卷提示
  uni.showModal({
    title: resultText,
    icon: 'none',
    content: `成绩: ${totalScore}/${questions.value.length}\n${resultText}\n未做题目: ${unansweredCount}\n剩余时间: ${formattedTime.value}`,
    confirmText: '现在交卷',
    cancelText: '继续答题',
    success: (res) => {
      if (res.confirm) {
        // 用户选择现在交卷
        clearInterval(timer!) // 清除计时器
        uni.setStorageSync('questions', questions.value)
        uni.setStorageSync('userAnswers', userAnswers.value)
        uni.navigateTo({
          url: `/pages/index/exam/submit?score=${totalScore}&total=${questions.value.length}`,
        })
      } else if (res.cancel) {
        // 用户选择继续答题
        // 什么都不做，继续答题
        // 用户选择继续答题
        clearInterval(timer!) // 清除之前的计时器
        isTimerPaused.value = false // 恢复计时器
        timer = setInterval(() => {
          if (!isTimerPaused.value && remainingTime.value > 0) {
            remainingTime.value--
          } else {
            clearInterval(timer!)
            submitExam() // 倒计时结束，自动提交
          }
        }, 1000)
      }
      isSubmitting.value = false // 重置提交标志位
    },
  })
}

// 获取题目数据
const getData = async (subject: number) => {
  const res = await http({
    url: '/drive/driveTopicList?subject=' + subject + '&testType=random',
    method: 'GET',
  })
  questions.value = res.data
  count.value = res.data.length
  userAnswers.value = new Array(res.data.length).fill('') // 初始化用户答案数组
}

// 切换题目
const prevQuestion = () => {
  if (currentQuestionIndex.value > 0) {
    currentQuestionIndex.value--
    showAnswer.value = false
  }
}
const nextQuestion = () => {
  if (currentQuestionIndex.value < questions.value.length - 1) {
    currentQuestionIndex.value++
    showAnswer.value = false
  }
}

// 选择选项
const selectOption = (optionIndex: number) => {
  const options = [
    questions.value[currentQuestionIndex.value]?.item1,
    questions.value[currentQuestionIndex.value]?.item2,
    questions.value[currentQuestionIndex.value]?.item3,
    questions.value[currentQuestionIndex.value]?.item4,
  ]
  userAnswers.value[currentQuestionIndex.value] = options[optionIndex]
  showAnswer.value = true

  // 自动跳转到下一题
  if (currentQuestionIndex.value < questions.value.length - 1) {
    setTimeout(() => {
      currentQuestionIndex.value++
      showAnswer.value = false
    }, 1000) // 1秒后跳转
  }
}

// 检查答案是否正确
const isCorrectAnswer = computed(() => {
  const correctOptionIndex = parseInt(questions.value[currentQuestionIndex.value].answer) - 1
  const options = [
    questions.value[currentQuestionIndex.value].item1,
    questions.value[currentQuestionIndex.value].item2,
    questions.value[currentQuestionIndex.value].item3,
    questions.value[currentQuestionIndex.value].item4,
  ]
  return userAnswers.value[currentQuestionIndex.value] === options[correctOptionIndex]
})

// 获取当前题目的正确答案
const correctAnswer = computed(() => {
  const correctOptionIndex = parseInt(questions.value[currentQuestionIndex.value].answer) - 1
  const options = [
    questions.value[currentQuestionIndex.value].item1,
    questions.value[currentQuestionIndex.value].item2,
    questions.value[currentQuestionIndex.value].item3,
    questions.value[currentQuestionIndex.value].item4,
  ]
  return options[correctOptionIndex]
})

// 定义 options 计算属性
const options = computed(() => {
  if (questions.value.length > 0) {
    return [
      questions.value[currentQuestionIndex.value].item1,
      questions.value[currentQuestionIndex.value].item2,
      questions.value[currentQuestionIndex.value].item3,
      questions.value[currentQuestionIndex.value].item4,
    ]
  }
  return []
})

// 计算当前题目编号
const currentNo = computed(() => {
  return currentQuestionIndex.value + 1
})

// 定义选项字母
const optionLetters = ['A', 'B', 'C', 'D']

// 计算用户的答案字母
const userAnswerLetter = computed(() => {
  const userAnswer = userAnswers.value[currentQuestionIndex.value]
  const options = [
    questions.value[currentQuestionIndex.value].item1,
    questions.value[currentQuestionIndex.value].item2,
    questions.value[currentQuestionIndex.value].item3,
    questions.value[currentQuestionIndex.value].item4,
  ]
  const userAnswerIndex = options.indexOf(userAnswer)
  return userAnswerIndex !== -1 ? optionLetters[userAnswerIndex] : ''
})

// 计算正确答案字母
const correctAnswerLetter = computed(() => {
  const correctOptionIndex = parseInt(questions.value[currentQuestionIndex.value].answer) - 1
  return optionLetters[correctOptionIndex]
})

// 显示图片弹出层
const showImagePopup = (index, src: string) => {
  uni.previewImage({
    urls: [src],
    current: index,
  })
}

// 跳转到提交页面
const goToSubmitPage = () => {
  // 计算总分
  const totalScore = userAnswers.value.reduce((score, answer, index) => {
    const correctOptionIndex = parseInt(questions.value[index].answer) - 1
    const options = [
      questions.value[index].item1,
      questions.value[index].item2,
      questions.value[index].item3,
      questions.value[index].item4,
    ]
    return answer === options[correctOptionIndex] ? score + 1 : score
  }, 0)

  // 存储数据并跳转
  uni.setStorageSync('questions', questions.value)
  uni.setStorageSync('userAnswers', userAnswers.value)
  uni.navigateTo({
    url: `/pages/index/exam/submit?score=${totalScore}&total=${questions.value.length}`,
  })
}

// 监听题目变化，重置答案显示
watch(currentQuestionIndex, () => {
  showAnswer.value = false
})
</script>

<style lang="scss">
/* 基础样式 - 移除通用选择器，使用具体的元素 */
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

.header-info {
  display: flex;
  gap: 15px;
  align-items: center;
  font-size: 14px;
}

.current-question {
  background: rgba(255, 255, 255, 0.2);
  padding: 4px 12px;
  border-radius: 12px;
  font-weight: 600;
}

.timer {
  background: rgba(255, 255, 255, 0.2);
  padding: 4px 12px;
  border-radius: 12px;
  font-weight: 600;
}

/* 主要内容区域 */
.main-content {
  margin-top: 80px;
  padding: 20px;
  max-width: 960px;
  margin-left: auto;
  margin-right: auto;
}

/* 题目卡片 */
.question-card {
  background: white;
  border-radius: 15px;
  margin-bottom: 20px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.question-header {
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  padding: 20px;
  border-bottom: 1px solid #e9ecef;
}

.question-title {
  font-size: 16px;
  font-weight: 600;
  color: #333;
  line-height: 1.5;
  display: block;
}

.question-image {
  padding: 20px;
  text-align: center;
  background: #f8f9fa;
}

.question-img {
  max-width: 200px;
  max-height: 200px;
  border-radius: 8px;
  cursor: pointer;
  transition: transform 0.3s ease;
}

.question-img:hover {
  transform: scale(1.05);
}

/* 选项列表 */
.options-list {
  padding: 20px;
}

.option-item {
  display: flex;
  align-items: flex-start;
  padding: 15px;
  margin-bottom: 10px;
  border-radius: 12px;
  transition: all 0.3s ease;
  cursor: pointer;
  border: 2px solid transparent;
  background: #f8f9fa;
}

.option-item:hover {
  background: #e9ecef;
  transform: translateY(-1px);
}

.option-item.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

.option-radio {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  border: 2px solid #ddd;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 15px;
  margin-top: 2px;
  flex-shrink: 0;
  transition: all 0.3s ease;
}

.option-item.active .option-radio {
  border-color: white;
}

.radio-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: transparent;
  transition: all 0.3s ease;
}

.radio-dot.checked {
  background: #667eea;
}

.option-item.active .radio-dot.checked {
  background: white;
}

.option-text {
  font-size: 14px;
  line-height: 1.5;
  flex: 1;
}

/* 答案解析卡片 */
.answer-card {
  background: white;
  border-radius: 15px;
  margin-bottom: 20px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.answer-header {
  background: linear-gradient(135deg, #4caf50 0%, #45a049 100%);
  color: white;
  padding: 15px 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.answer-title {
  font-size: 16px;
  font-weight: 600;
}

.answer-result {
  font-size: 14px;
  font-weight: 600;
}

.result-correct {
  color: #c8e6c9;
}

.result-incorrect {
  color: #ffcdd2;
}

.answer-content {
  padding: 20px;
}

.answer-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  padding: 8px 0;
  border-bottom: 1px solid #f0f0f0;
}

.answer-label {
  font-size: 14px;
  color: #666;
  font-weight: 500;
}

.answer-value {
  font-size: 14px;
  font-weight: 600;
  padding: 4px 12px;
  border-radius: 6px;
}

.user-answer {
  background: #e3f2fd;
  color: #1976d2;
}

.correct-answer {
  background: #e8f5e8;
  color: #4caf50;
}

.explanation {
  background: #f8f9fa;
  padding: 15px;
  border-radius: 8px;
  margin-top: 15px;
}

.explanation-title {
  font-size: 14px;
  font-weight: 600;
  color: #333;
  margin-bottom: 8px;
  display: block;
}

.explanation-text {
  font-size: 13px;
  color: #666;
  line-height: 1.5;
  display: block;
}

/* 控制按钮 */
.control-buttons {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 15px;
  margin-bottom: 20px;
}

.control-btn {
  padding: 12px 20px;
  border-radius: 25px;
  border: none;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.prev-btn {
  background: linear-gradient(135deg, #ff9800 0%, #f57c00 100%);
  color: white;
}

.next-btn {
  background: linear-gradient(135deg, #2196f3 0%, #1976d2 100%);
  color: white;
}

.submit-btn {
  background: linear-gradient(135deg, #4caf50 0%, #45a049 100%);
  color: white;
}

.control-btn:hover:not(.disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.15);
}

.control-btn.disabled {
  background: #e0e0e0;
  color: #999;
  cursor: not-allowed;
  transform: none;
}

/* 最终提交按钮 */
.final-submit {
  text-align: center;
  margin: 30px 0;
}

.final-submit-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 15px 40px;
  border-radius: 30px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.3);
}

.final-submit-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 25px rgba(102, 126, 234, 0.4);
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

  .control-buttons {
    grid-template-columns: 1fr;
    gap: 10px;
  }

  .header-info {
    gap: 10px;
    font-size: 12px;
  }
}

/* 旧样式兼容 - 保持原有逻辑功能 */
.icon-correct {
  color: green;
}

.icon-incorrect {
  color: red;
}
</style>
