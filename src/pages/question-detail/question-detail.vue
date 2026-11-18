<template>
  <view class="container">
    <view class="page-toolbar">
      <text class="favorite-icon" :class="{ favorited: isFavorited }" @click="toggleFavorite">
        {{ isFavorited ? '❤️' : '🤍' }}
      </text>
    </view>

    <!-- 主要内容区域 -->
    <view class="main-content">
      <view class="question-card">
        <!-- 题目内容 -->
        <view class="question-content">
          <!--          <text class="question-number">第{{ questionInfo.questionId || questionId }}题</text>-->
          <text class="question-text">{{ questionInfo.questionContent }}</text>

          <!-- 题目图片 -->
          <view v-if="questionInfo.imageUrl" class="question-image">
            <image
              :src="questionInfo.imageUrl"
              mode="widthFix"
              class="question-img"
              @click="previewImage(questionInfo.imageUrl)"
            />
          </view>
        </view>

        <!-- 选项列表 -->
        <view class="options-list">
          <view
            v-for="(option, index) in filteredOptions"
            :key="index"
            class="option-item"
            :class="{
              correct: index === correctAnswerIndex,
              selected: selectedAnswer === index,
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
              <text class="explanation-text">{{ questionInfo.questionExplain || '暂无解析' }}</text>
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
    <view class="related-section" v-if="false">
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
          <text class="related-text">{{ item.questionContent }}</text>
          <text class="related-arrow">→</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { http } from '@/utils/http'
import { useMemberStore } from '@/stores'
import { onLoad } from '@dcloudio/uni-app'

// 数据状态
const questionInfo = ref<any>({})
const isFavorited = ref(false)
const selectedAnswer = ref(-1)
const relatedQuestions = ref([])
const questionId = ref('')
const subject = ref('')

// 计算属性
const options = computed(() => {
  if (!questionInfo.value) return []
  return [
    questionInfo.value.optionA,
    questionInfo.value.optionB,
    questionInfo.value.optionC,
    questionInfo.value.optionD,
  ]
})

// 过滤非空选项的计算属性
const filteredOptions = computed(() => {
  return options.value.filter((option) => option && option.trim() !== '')
})

const correctAnswerIndex = computed(() => {
  if (!questionInfo.value.correctAnswer) return -1
  return parseInt(questionInfo.value.correctAnswer) - 1
})

// 获取用户ID
const getUserId = () => {
  try {
    const memberStore = useMemberStore()
    if (!memberStore.profile) {
      return ''
    }
    return memberStore.profile.id
  } catch (error) {
    console.error('获取用户ID失败:', error)
    return ''
  }
}

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

// 方法
const goBack = () => {
  uni.navigateBack()
}

// 切换收藏状态
const toggleFavorite = async () => {
  if (!checkLogin()) return

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
    await http({
      url: '/userWrongCollectionQuestion/collect',
      method: 'POST',
      data: {
        userId: userId,
        subject: subject.value,
        questionId: questionId.value,
      },
    })

    isFavorited.value = !isFavorited.value
    uni.showToast({
      title: isFavorited.value ? '已收藏' : '已取消收藏',
      icon: 'success',
      duration: 1500,
    })
  } catch (error) {
    console.error('收藏操作失败:', error)
    uni.showToast({
      title: '操作失败，请重试',
      icon: 'none',
      duration: 1500,
    })
  }
}

// 检查题目是否已收藏
const checkFavoriteStatus = async () => {
  if (!checkLogin()) return

  const userId = getUserId()
  if (!userId) return

  try {
    const res: any = await http({
      url: '/userWrongCollectionQuestion/isCollected',
      method: 'GET',
      data: {
        userId: userId,
        questionId: questionId.value,
      },
    })

    isFavorited.value = res.data === true
  } catch (error) {
    console.error('检查收藏状态失败:', error)
  }
}

// 获取题目详情
const fetchQuestionDetail = async (id: string, sub: string) => {
  try {
    const res: any = await http({
      url: '/drive/getDriveQuestionById',
      method: 'GET',
      data: {
        id: id,
        subject: sub,
      },
    })

    questionInfo.value = res.data
    questionId.value = id
    subject.value = sub

    // 检查收藏状态
    await checkFavoriteStatus()
  } catch (error) {
    console.error('获取题目详情失败:', error)
    uni.showToast({
      title: '获取题目详情失败',
      icon: 'none',
      duration: 1500,
    })
  }
}

// 获取相关题目
const fetchRelatedQuestions = async (sub: string) => {
  try {
    const res: any = await http({
      url: '/drive/getRelatedQuestions',
      method: 'GET',
      data: {
        subject: sub,
        count: 5,
      },
    })

    relatedQuestions.value = res.data || []
  } catch (error) {
    console.error('获取相关题目失败:', error)
  }
}

// 预览图片
const previewImage = (url: string) => {
  uni.previewImage({
    urls: [url],
  })
}

// 开始练习
const startPractice = () => {
  uni.navigateTo({
    url: `/pages/index/sequential/sequential?sub=${subject.value}`,
  })
}

// 开始考试
const startExam = () => {
  uni.navigateTo({
    url: `/pages/index/exam/exam?sub=${subject.value}`,
  })
}

// 查看相关题目
const viewRelatedQuestion = (item: any) => {
  // 重新加载当前页面，传递新题目的ID
  questionId.value = item.questionId
  fetchQuestionDetail(item.questionId, subject.value)
}

// 页面加载时获取参数
onLoad((options: any) => {
  // 监听数据传递事件
  uni.$on('questionData', (data: any) => {
    if (data) {
      questionInfo.value = data
      questionId.value = data.questionId || data.id
      subject.value = data.subject || '1'

      // 获取相关题目（这里仍然需要调用接口）
      fetchRelatedQuestions(data.subject)

      // 检查收藏状态
      checkFavoriteStatus()
    }
  })

  // 如果没有通过事件传递数据，检查URL参数
  if (options.questionId && !questionInfo.value.questionId) {
    questionId.value = options.questionId
    subject.value = options.subject || '1'
    fetchQuestionDetail(questionId.value, subject.value)
  }
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
  background: linear-gradient(135deg, #0f766e 0%, #115e59 100%);
  color: white;
  padding: 8px 15px;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 44px;
  box-sizing: border-box;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  min-width: 60px;
}

.back-icon {
  font-size: 20px;
  font-weight: bold;
}

.back-text {
  font-size: 16px;
}

.header-center {
  flex: 1;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 0 10px;
  min-width: 0; /* 允许标题在空间不足时收缩 */
}

.title {
  font-size: 18px;
  font-weight: bold;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  text-align: center;
}

.header-right {
  min-width: 60px;
  text-align: right;
  display: flex;
  justify-content: flex-end;
  align-items: center;
}

.favorite-icon {
  font-size: 20px;
  cursor: pointer;
  transition: transform 0.3s ease;
}

.favorite-icon:hover {
  transform: scale(1.1);
}

.favorite-icon.favorited {
  animation: heartbeat 0.6s ease-in-out;
}

@keyframes heartbeat {
  0% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.2);
  }
  100% {
    transform: scale(1);
  }
}

/* 主要内容区域 */
.main-content {
  margin-top: 60px;
  padding: 0 20px;
}

.question-card {
  background: white;
  border-radius: 15px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.question-content {
  padding: 25px;
}

.question-number {
  font-size: 18px;
  font-weight: bold;
  margin-bottom: 10px;
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
  width: 100%;
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
  background: #0f766e;
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
  background: linear-gradient(135deg, #0f766e 0%, #115e59 100%);
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
  color: #0f766e;
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
