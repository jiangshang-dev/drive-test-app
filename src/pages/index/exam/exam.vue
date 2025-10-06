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
    <view class="main-content" @touchstart="touchStart" @touchend="touchEnd">
      <!-- 题目卡片 -->
      <view class="question-card">
        <view class="question-header">
          <text class="question-title">{{ questions[currentQuestionIndex]?.questionContent }}</text>
        </view>

        <!-- 题目图片 -->
        <!--        <view v-if="questions[currentQuestionIndex]?.imageUrl != ''" class="question-image">

          <image
            class="question-img"
            mode="aspectFit"
            :src="questions[currentQuestionIndex].imageUrl"
            @click="showImagePopup(currentQuestionIndex, questions[currentQuestionIndex]?.imageUrl)"
          />
        </view>-->

        <view v-if="questions[currentQuestionIndex]?.imageUrl != ''" class="question-image">
          {{ questions[currentQuestionIndex].imageUrl }}
          <image
            mode="aspectFill"
            class="question-img"
            :src="questions[currentQuestionIndex].imageUrl"
            @click="showImagePopup(currentQuestionIndex, questions[currentQuestionIndex]?.imageUrl)"
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
            <text class="explanation-text">{{
              questions[currentQuestionIndex].questionExplain
            }}</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 底部固定行 -->
    <view class="bottom-fixed-bar">
      <!-- 左侧：收藏按钮和交卷按钮 -->
      <view class="left-buttons">
        <!-- 收藏图标 -->
        <view class="bottom-icon favorite-icon" @click="toggleFavorite">
          <text class="icon-text">{{ isFavorited ? '❤️' : '🤍' }}</text>
          <text class="icon-label">收藏</text>
        </view>

        <!-- 交卷按钮 -->
        <view class="bottom-button submit-button" @click="submitExam">
          <text class="button-text">交卷</text>
        </view>
      </view>

      <!-- 右侧：对错数和题目进度 -->
      <view class="right-info">
        <view class="stats-container">
          <view class="correct-count">
            <text class="count-text">✓{{ correctCount }}</text>
          </view>
          <view class="incorrect-count">
            <text class="count-text">✗{{ incorrectCount }}</text>
          </view>
          <view class="question-progress">
            <text class="progress-text">{{ currentNo }}/{{ count }}</text>
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
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import { http } from '@/utils/http'
import { useMemberStore } from '@/stores'

// 定义题目接口
interface Question {
  id: string | number
  questionContent: string
  imageUrl: string
  optionA: string
  optionB: string
  optionC: string
  optionD: string
  correctAnswer: string
  questionExplain: string
  isFavorite?: boolean
}

const questions = ref<Question[]>([]) // 题目列表
const userAnswers = ref<string[]>([]) // 用户的答案列表
const currentQuestionIndex = ref(0) // 当前题目索引
const showAnswer = ref(false) // 是否显示答案
const count = ref(0) // 题目总数
const sub = ref(0) // 科目类型
const favoriteQuestions = ref<Set<string | number>>(new Set()) // 收藏的题目ID集合

// 触摸滑动相关变量
const touchStartX = ref(0)
const touchEndX = ref(0)

// 检查用户是否已登录
const checkLogin = () => {
  const memberStore = useMemberStore()
  if (!memberStore.profile) {
    // 未登录，显示提示框
    uni.showModal({
      title: '提示',
      content: '您还未登录，请先登录后再进行操作',
      confirmText: '去登录',
      cancelText: '取消',
      success: (res) => {
        if (res.confirm) {
          // 跳转到登录页面
          uni.navigateTo({
            url: '/pages/login/login',
          })
        }
      },
    })
    return false
  }
  return true
}

onLoad((options: any) => {
  sub.value = options?.sub || 0
  getData(sub.value)
})

const onload = (e: any) => {
  console.log('onload')
}
const onclose = (ez: any) => {
  // console.log("onclose: " + ez.detail);
}
const onerror = (ex: any) => {
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
  // 检查是否已登录
  if (!checkLogin()) return

  if (isSubmitting.value) return
  isSubmitting.value = true

  // 暂停计时器
  isTimerPaused.value = true

  // 计算总分
  const totalScore = userAnswers.value.reduce((score, correctAnswer, index) => {
    if (!questions.value[index] || !correctAnswer) return score
    const correctOptionIndex = parseInt(questions.value[index].correctAnswer) - 1
    const options = [
      questions.value[index].optionA,
      questions.value[index].optionB,
      questions.value[index].optionC,
      questions.value[index].optionD,
    ]
    return correctAnswer === options[correctOptionIndex] ? score + 1 : score
  }, 0)

  // 计算未做题目总数
  const unansweredCount = userAnswers.value.filter((correctAnswer) => correctAnswer === '').length

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
    success: (res: any) => {
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
  const res: any = await http({
    url: '/drive/examDriveQuestion?subject=' + subject,
    method: 'GET',
  })
  questions.value = res.data || []
  count.value = res.data?.length || 0
  userAnswers.value = new Array(res.data?.length || 0).fill('') // 初始化用户答案数组

  // 清空收藏状态
  favoriteQuestions.value.clear()

  // 初始化第一题的收藏状态
  if (questions.value.length > 0) {
    await checkCurrentQuestionFavoriteStatus()
  }
}

// 检查当前题目的收藏状态
const checkCurrentQuestionFavoriteStatus = async () => {
  // 获取用户ID
  const userId = getUserId()
  if (!userId) return

  const currentQuestion = questions.value[currentQuestionIndex.value]
  if (!currentQuestion) return

  try {
    const isFavorited = await checkFavorite(userId, String(currentQuestion.id))
    if (isFavorited) {
      favoriteQuestions.value.add(currentQuestion.id)
    } else {
      favoriteQuestions.value.delete(currentQuestion.id)
    }
  } catch (error) {
    console.error('检查题目收藏状态失败:', error)
  }
}

// 监听题目变化，重置答案显示和检查收藏状态
watch(currentQuestionIndex, async () => {
  showAnswer.value = false
  // 切换题目时检查当前题目的收藏状态
  await checkCurrentQuestionFavoriteStatus()
})

// 切换收藏状态
const toggleFavorite = async () => {
  // 检查是否已登录
  if (!checkLogin()) return

  if (!questions.value[currentQuestionIndex.value]) return

  const currentQuestion = questions.value[currentQuestionIndex.value]
  const questionId = currentQuestion.id
  const userId = getUserId()

  if (!userId) {
    uni.showToast({
      title: '获取用户信息失败',
      icon: 'none',
      duration: 1500,
    })
    return
  }

  try {
    // 切换收藏状态
    if (favoriteQuestions.value.has(questionId)) {
      // 取消收藏
      await saveFavoriteToServer(userId, String(questionId), false)
      favoriteQuestions.value.delete(questionId)
      uni.showToast({
        title: '已取消收藏',
        icon: 'success',
        duration: 1500,
      })
    } else {
      // 添加收藏
      await saveFavoriteToServer(userId, String(questionId), true)
      favoriteQuestions.value.add(questionId)
      uni.showToast({
        title: '收藏成功',
        icon: 'success',
        duration: 1500,
      })
    }
  } catch (error) {
    console.error('收藏操作失败:', error)
    uni.showToast({
      title: '操作失败，请重试',
      icon: 'none',
      duration: 1500,
    })
  }
}

const checkFavorite = async (userId: string, questionId: string): Promise<boolean> => {
  try {
    let url =
      '/userWrongCollectionQuestion/isCollected?userId=' + userId + '&questionId=' + questionId
    const res: any = await http({
      url: url,
      method: 'GET',
    })
    return res.data === true
  } catch (error) {
    console.error('检查收藏状态失败:', error)
    return false
  }
}

// 保存收藏状态到服务器
const saveFavoriteToServer = async (userId: string, questionId: string, isFavorite: boolean) => {
  try {
    const url = isFavorite
      ? '/userWrongCollectionQuestion/collect'
      : '/userWrongCollectionQuestion/collect'

    await http({
      url: url,
      method: 'POST',
      data: {
        userId: userId,
        questionId: questionId,
        subject: sub.value,
      },
    })
  } catch (error) {
    console.error('保存收藏状态失败:', error)
    throw error
  }
}

const getUserId = () => {
  try {
    let member = uni.getStorageSync('member')
    // 检查 member 是否存在且不为空
    if (!member) {
      console.log('member is null or undefined')
      return ''
    }

    // 如果 member 是字符串，尝试解析它
    if (typeof member === 'string') {
      member = member.trim()
      if (member === '') {
        console.log('member string is empty')
        return ''
      }
      try {
        member = JSON.parse(member)
      } catch (e) {
        console.error('Failed to parse member string:', e)
        return ''
      }
    }

    // 检查 member 对象是否包含 profile 并且 profile 有 id
    if (member && member.profile && member.profile.id) {
      console.log('member::', member)
      console.log('member type::', typeof member)
      return String(member.profile.id)
    } else {
      console.log('member or member.profile or member.profile.id is missing')
      console.log('member::', member)
      return ''
    }
  } catch (error) {
    console.error('Error in getUserId:', error)
    return ''
  }
}

// 触摸开始
const touchStart = (e: any) => {
  touchStartX.value = e.changedTouches[0].clientX
}

// 触摸结束
const touchEnd = (e: any) => {
  touchEndX.value = e.changedTouches[0].clientX
  handleSwipe()
}

// 处理滑动
const handleSwipe = () => {
  const deltaX = touchEndX.value - touchStartX.value
  const MIN_SWIPE_DISTANCE = 50 // 最小滑动距离

  if (Math.abs(deltaX) >= MIN_SWIPE_DISTANCE) {
    if (deltaX > 0) {
      // 右滑，上一题
      prevQuestion()
    } else {
      // 左滑，下一题
      nextQuestion()
    }
  }
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
  // 检查是否已登录
  if (!checkLogin()) return

  if (!questions.value[currentQuestionIndex.value]) return

  const options = [
    questions.value[currentQuestionIndex.value].optionA,
    questions.value[currentQuestionIndex.value].optionB,
    questions.value[currentQuestionIndex.value].optionC,
    questions.value[currentQuestionIndex.value].optionD,
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
  if (!questions.value[currentQuestionIndex.value]) return false
  const correctOptionIndex = parseInt(questions.value[currentQuestionIndex.value].correctAnswer) - 1
  const options = [
    questions.value[currentQuestionIndex.value].optionA,
    questions.value[currentQuestionIndex.value].optionB,
    questions.value[currentQuestionIndex.value].optionC,
    questions.value[currentQuestionIndex.value].optionD,
  ]
  return userAnswers.value[currentQuestionIndex.value] === options[correctOptionIndex]
})

// 获取当前题目的正确答案
const correctAnswer = computed(() => {
  if (!questions.value[currentQuestionIndex.value]) return ''
  const correctOptionIndex = parseInt(questions.value[currentQuestionIndex.value].correctAnswer) - 1
  const options = [
    questions.value[currentQuestionIndex.value].optionA,
    questions.value[currentQuestionIndex.value].optionB,
    questions.value[currentQuestionIndex.value].optionC,
    questions.value[currentQuestionIndex.value].optionD,
  ]
  return options[correctOptionIndex]
})

// 定义 options 计算属性
const options = computed(() => {
  if (questions.value.length > 0 && questions.value[currentQuestionIndex.value]) {
    return [
      questions.value[currentQuestionIndex.value].optionA,
      questions.value[currentQuestionIndex.value].optionB,
      questions.value[currentQuestionIndex.value].optionC,
      questions.value[currentQuestionIndex.value].optionD,
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
  if (!questions.value[currentQuestionIndex.value]) return ''
  const options = [
    questions.value[currentQuestionIndex.value].optionA,
    questions.value[currentQuestionIndex.value].optionB,
    questions.value[currentQuestionIndex.value].optionC,
    questions.value[currentQuestionIndex.value].optionD,
  ]
  const userAnswerIndex = options.indexOf(userAnswer)
  return userAnswerIndex !== -1 ? optionLetters[userAnswerIndex] : ''
})

// 计算正确答案字母
const correctAnswerLetter = computed(() => {
  if (!questions.value[currentQuestionIndex.value]) return ''
  const correctOptionIndex = parseInt(questions.value[currentQuestionIndex.value].correctAnswer) - 1
  return optionLetters[correctOptionIndex]
})

// 显示图片弹出层
const showImagePopup = (index: number, src: string) => {
  uni.previewImage({
    urls: [src],
    current: index,
  })
}

// 跳转到提交页面
const goToSubmitPage = () => {
  // 计算总分
  const totalScore = userAnswers.value.reduce((score, correctAnswer, index) => {
    if (!questions.value[index] || !correctAnswer) return score
    const correctOptionIndex = parseInt(questions.value[index].correctAnswer) - 1
    const options = [
      questions.value[index].optionA,
      questions.value[index].optionB,
      questions.value[index].optionC,
      questions.value[index].optionD,
    ]
    return correctAnswer === options[correctOptionIndex] ? score + 1 : score
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

// 计算正确题数
const correctCount = computed(() => {
  return userAnswers.value.reduce((count, correctAnswer, index) => {
    if (!questions.value[index] || !correctAnswer) return count
    const correctOptionIndex = parseInt(questions.value[index].correctAnswer) - 1
    const options = [
      questions.value[index].optionA,
      questions.value[index].optionB,
      questions.value[index].optionC,
      questions.value[index].optionD,
    ]
    return correctAnswer === options[correctOptionIndex] ? count + 1 : count
  }, 0)
})

// 计算错误题数
const incorrectCount = computed(() => {
  return userAnswers.value.reduce((count, correctAnswer, index) => {
    if (!questions.value[index] || !correctAnswer) return count
    const correctOptionIndex = parseInt(questions.value[index].correctAnswer) - 1
    const options = [
      questions.value[index].optionA,
      questions.value[index].optionB,
      questions.value[index].optionC,
      questions.value[index].optionD,
    ]
    return correctAnswer !== '' && correctAnswer !== options[correctOptionIndex] ? count + 1 : count
  }, 0)
})

// 计算当前题目是否已收藏
const isFavorited = computed(() => {
  if (questions.value.length === 0 || !questions.value[currentQuestionIndex.value]) return false
  const currentQuestionId = questions.value[currentQuestionIndex.value].id
  return favoriteQuestions.value.has(currentQuestionId)
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
  min-height: calc(100vh - 160px);
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

/* 底部固定行 */
.bottom-fixed-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: white;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 20px;
  box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.1);
  z-index: 1000;
}

.left-buttons {
  display: flex;
  align-items: center;
  gap: 15px;
}

.bottom-icon {
  display: flex;
  flex-direction: column;
  align-items: center;
  cursor: pointer;
}

.icon-text {
  font-size: 24px;
}

.icon-label {
  font-size: 12px;
  color: #666;
  margin-top: 2px;
}

.bottom-button {
  background: linear-gradient(135deg, #4caf50 0%, #45a049 100%);
  color: white;
  border: none;
  padding: 8px 20px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 10px rgba(76, 175, 80, 0.3);
}

.bottom-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(76, 175, 80, 0.4);
}

.right-info {
  display: flex;
  align-items: center;
}

.stats-container {
  display: flex;
  align-items: center;
  gap: 15px;
}

.correct-count .count-text {
  color: #4caf50;
  font-weight: 600;
}

.incorrect-count .count-text {
  color: #f44336;
  font-weight: 600;
}

.question-progress .progress-text {
  color: #667eea;
  font-weight: 600;
}

/* 广告区域 */
.ad-view {
  background-color: #ffffff;
  margin: 20px;
  border-radius: 15px;
  overflow: hidden;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
  margin-bottom: 70px; /* 为底部固定行留出空间 */
}

/* 响应式设计 */
@media (max-width: 768px) {
  .header-content {
    padding: 0 15px;
  }

  .main-content {
    padding: 15px;
  }

  .header-info {
    gap: 10px;
    font-size: 12px;
  }

  .bottom-fixed-bar {
    padding: 8px 15px;
  }

  .left-buttons {
    gap: 10px;
  }

  .bottom-button {
    padding: 6px 15px;
    font-size: 12px;
  }

  .stats-container {
    gap: 10px;
  }

  .icon-label {
    font-size: 10px;
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
