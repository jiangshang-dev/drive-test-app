<template>
  <view class="container">
    <!-- 顶部导航栏 -->
    <view class="header">
      <view class="header-content">
        <view class="header-title">
          <text class="logo">{{ sub == 1 ? '科目一' : '科目四' }}刷题</text>
          <text class="progress-text">{{ currentNo }} / {{ count }}</text>
        </view>
        <view class="header-right">
          <text class="filter-icon" @click="showFilterModal = true">筛选</text>
        </view>
      </view>
    </view>

    <!-- 题型筛选栏 -->
    <view class="filter-section" v-if="!showFilterModal">
      <scroll-view :scroll-x="true" class="filter-scroll">
        <view class="filter-tabs">
          <view
            class="filter-tab"
            :class="{ active: selectedQuestionType === '' }"
            @click="selectQuestionType('')"
          >
            全部题型
          </view>
          <view
            v-for="(type, index) in questionTypes"
            :key="index"
            class="filter-tab"
            :class="{ active: selectedQuestionType === type.code }"
            @click="selectQuestionType(type.code)"
          >
            {{ type.name }}
          </view>
        </view>
      </scroll-view>
    </view>

    <!-- 题型筛选弹窗 -->
    <view v-if="showFilterModal" class="modal" @click="showFilterModal = false">
      <view class="modal-content" @click.stop>
        <view class="modal-header">
          <text class="modal-title">选择题型</text>
          <text class="close" @click="showFilterModal = false">&times;</text>
        </view>
        <view class="modal-body">
          <view class="question-types-grid">
            <view
              class="type-item"
              :class="{ active: selectedQuestionType === '' }"
              @click="selectQuestionTypeFromModal('')"
            >
              <text class="type-icon">📚</text>
              <text class="type-name">全部题型</text>
            </view>
            <view
              v-for="(type, index) in questionTypes"
              :key="index"
              class="type-item"
              :class="{ active: selectedQuestionType === type.code }"
              @click="selectQuestionTypeFromModal(type.code)"
            >
              <text class="type-icon">{{ type.icon }}</text>
              <text class="type-name">{{ type.name }}</text>
            </view>
          </view>
        </view>
      </view>
    </view>
    <!-- 题目卡片 -->
    <view class="question-card" @touchstart="touchStart" @touchend="touchEnd">
      <view class="question-header">
        <view class="header-left">
          <text class="question-number">第 {{ currentNo }} 题</text>
          <text class="question-type" v-if="currentQuestionTypeName">{{
            currentQuestionTypeName
          }}</text>
        </view>
        <view class="header-actions">
          <text class="favorite-btn" :class="{ active: isFavorited }" @click="toggleFavorite">
            {{ isFavorited ? '❤️' : '🤍' }}
          </text>
        </view>
      </view>

      <view class="question-content">
        <text class="question-text">{{ questions[currentQuestionIndex]?.questionContent }}</text>

        <view v-if="questions[currentQuestionIndex]?.imageUrl != ''" class="question-image">
          <image
            mode="aspectFill"
            class="question-img"
            :src="questions[currentQuestionIndex]?.imageUrl"
            @click="showImagePopup(currentQuestionIndex, questions[currentQuestionIndex]?.imageUrl)"
          />
        </view>

        <view class="options-container">
          <view
            v-for="(option, index) in validOptions"
            :key="index"
            class="option-item"
            :class="{
              selected: userAnswers[currentQuestionIndex] === option.text,
              correct: showAnswer && isCorrectOption(option.index),
              incorrect:
                showAnswer &&
                userAnswers[currentQuestionIndex] === option.text &&
                !isCorrectOption(option.index),
            }"
            @click="selectOption(option.index)"
          >
            <view class="option-letter">{{ String.fromCharCode(65 + option.index) }}</view>
            <text class="option-text">{{ option.text }}</text>
            <view
              v-if="showAnswer && isCorrectOption(option.index)"
              class="option-icon correct-icon"
              >✓</view
            >
            <view
              v-if="
                showAnswer &&
                userAnswers[currentQuestionIndex] === option.text &&
                !isCorrectOption(option.index)
              "
              class="option-icon incorrect-icon"
              >✗</view
            >
          </view>
        </view>
      </view>
    </view>
    <!-- 答案解析卡片 -->
    <view v-if="showAnswer" class="analysis-card">
      <view class="analysis-header">
        <text class="analysis-title">答案解析</text>
        <view
          class="result-icon"
          :class="{ correct: isCorrectAnswer, incorrect: !isCorrectAnswer }"
        >
          <text v-if="isCorrectAnswer">✓</text>
          <text v-else>✗</text>
        </view>
      </view>

      <view class="analysis-content">
        <view class="answer-comparison">
          <view class="answer-item">
            <text class="answer-label">你的答案:</text>
            <text class="answer-value user-answer">{{ userAnswerLetter || '未选择' }}</text>
          </view>
          <view class="answer-item">
            <text class="answer-label">正确答案:</text>
            <text class="answer-value correct-answer">{{ correctAnswerLetter }}</text>
          </view>
        </view>

        <view class="explanation" v-if="questions[currentQuestionIndex]?.questionExplain">
          <text class="explanation-title">题目解析:</text>
          <text class="explanation-text">{{
            questions[currentQuestionIndex].questionExplain
          }}</text>
        </view>
      </view>
    </view>

    <!-- 操作按钮 -->
    <view class="action-buttons">
      <button class="btn btn-directory" @click="showDirectory = true">题号目录</button>
      <button class="btn btn-comment" @click="toggleCommentSection">
        {{ showCommentSection ? '隐藏评论' : '查看评论' }} ({{ commentCount }})
      </button>
      <!-- <button class="btn btn-refresh" @click="getData2(sub)">换一组题</button> -->
    </view>

    <!-- 评论区 -->
    <view v-if="showCommentSection" class="comment-section">
      <view class="comment-header">
        <text class="comment-title">评论区 ({{ comments.length }})</text>
        <text class="sort-btn" @click="toggleSortOrder">
          {{ sortByTime ? '按时间排序' : '按热度排序' }}
        </text>
      </view>

      <!-- 发表评论 -->
      <view class="comment-input-section">
        <view class="input-container">
          <textarea
            v-model="newComment"
            placeholder="发表你的看法..."
            class="comment-input"
            maxlength="500"
          />
          <text class="char-count">{{ newComment.length }}/500</text>
        </view>
        <button class="submit-btn" @click="submitComment" :disabled="!newComment.trim()">
          发表
        </button>
      </view>

      <!-- 评论列表 -->
      <view class="comment-list">
        <view v-for="comment in sortedComments" :key="comment.id" class="comment-item">
          <view class="comment-avatar">
            <image class="avatar-img" :src="comment.avatar" mode="aspectFill" />
          </view>
          <view class="comment-content">
            <view class="comment-header-info">
              <text class="comment-author">{{ comment.author }}</text>
              <text class="comment-time">{{ formatCommentTime(comment.createTime) }}</text>
            </view>
            <text class="comment-text">{{ comment.content }}</text>
            <view class="comment-actions">
              <text
                class="action-btn like-btn"
                :class="{ active: comment.isLiked }"
                @click="toggleLike(comment)"
              >
                👍 {{ comment.likes > 0 ? comment.likes : '' }}
              </text>
              <text class="action-btn reply-btn" @click="replyToComment(comment)"> 回复 </text>
              <text
                v-if="comment.canDelete"
                class="action-btn delete-btn"
                @click="deleteComment(comment.id)"
              >
                删除
              </text>
            </view>

            <!-- 回复列表 -->
            <view v-if="comment.replies && comment.replies.length > 0" class="reply-list">
              <view v-for="reply in comment.replies" :key="reply.id" class="reply-item">
                <text class="reply-author">{{ reply.author }}</text
                >:
                <text class="reply-content">{{ reply.content }}</text>
                <text class="reply-time">{{ formatCommentTime(reply.createTime) }}</text>
              </view>
            </view>
          </view>
        </view>

        <!-- 空状态 -->
        <view v-if="comments.length === 0" class="empty-comments">
          <text class="empty-icon">💬</text>
          <text class="empty-text">还没有评论，来发表第一个吧~</text>
        </view>
      </view>
    </view>

    <!-- 题号目录对话框 -->
    <view class="directory-dialog" :class="{ show: showDirectory }" @click="closeDirectory">
      <view class="directory-content" @click.stop>
        <view class="directory-header">
          <text class="directory-title">题目目录</text>
          <text class="close-btn" @click="closeDirectory">×</text>
        </view>
        <view class="directory-grid">
          <view
            v-for="(question, index) in questions"
            :key="index"
            class="directory-item"
            :class="{
              current: index === currentQuestionIndex,
              answered: userAnswers[index] !== '',
              correct: getUserAnswerStatus(index) === 'correct',
              incorrect: getUserAnswerStatus(index) === 'incorrect',
            }"
            @click="jumpToQuestion(index)"
          >
            {{ index + 1 }}
          </view>
        </view>
      </view>
    </view>

    <!-- 广告位 -->
    <!-- <view class="ad-view">
            <ad adpid="1478175623" @load="onload" @close="onclose" @error="onerror"></ad>
        </view> -->
  </view>
</template>
<script lang="ts" setup>
import { onLoad } from '@dcloudio/uni-app'
import { ref, computed, watch } from 'vue'
import { http } from '@/utils/http'
import { useMemberStore } from '@/stores'

// 定义题型数据接口
interface QuestionType {
  code: string
  name: string
  icon: string
}

// 定义后端返回的字典类型接口
interface DictType {
  id: string
  dictValue: string
  dictLabel: string
  [key: string]: any
}

// 定义评论数据接口
interface Comment {
  id: number
  author: string
  avatar: string
  content: string
  createTime: number
  likes: number
  isLiked: boolean
  canDelete: boolean
  replies: Reply[]
}

interface Reply {
  id: number
  author: string
  content: string
  createTime: number
}

// 获取屏幕边界到安全区域距离
const { safeAreaInsets, statusBarHeight } = uni.getSystemInfoSync()

// 假设问题和用户答案已经加载到questions和userAnswers中
const questionsTotal = ref(0)
const questions = ref<any[]>([]) // 题目列表
const userAnswers = ref<string[]>([]) // 用户的答案列表
const currentQuestionIndex = ref(0) // 当前题目索引
const showAnswer = ref(false) // 是否显示答案
const count = ref(0)
const sub = ref<{ sub: string } | any>({})
const showDirectory = ref(false) // 是否显示题号目录

// 题型筛选相关
const showFilterModal = ref(false) // 是否显示筛选弹窗
const selectedQuestionType = ref('') // 选中的题型代码

// 收藏功能相关
const favoriteQuestions = ref(new Set()) // 收藏的题目ID集合

// 评论功能相关
const showCommentSection = ref(false) // 是否显示评论区
const newComment = ref('') // 新评论内容
const comments = ref<Comment[]>([]) // 评论列表
const sortByTime = ref(true) // 排序方式：true为按时间，false为按热度

// 触摸滑动相关变量
const touchStartX = ref(0)
const touchEndX = ref(0)

// 模拟评论数据
const initComments = () => {
  comments.value = [
    {
      id: 1,
      author: '学车小王',
      avatar: 'https://via.placeholder.com/40x40/667eea/white?text=王',
      content: '这道题容易混淆，需要仔细记忆标志的区别',
      createTime: Date.now() - 3600000, // 1小时前
      likes: 5,
      isLiked: false,
      canDelete: false,
      replies: [
        {
          id: 101,
          author: '驾考达人',
          content: '对的，多练习几遍就记住了',
          createTime: Date.now() - 1800000, // 30分钟前
        },
      ],
    },
    {
      id: 2,
      author: '新手上路',
      avatar: 'https://via.placeholder.com/40x40/4caf50/white?text=新',
      content: '感谢分享，解析很详细！',
      createTime: Date.now() - 7200000, // 2小时前
      likes: 3,
      isLiked: true,
      canDelete: true,
      replies: [],
    },
  ] as Comment[]
}

const questionTypes = ref<QuestionType[]>([
  // 题型列表 (默认值，将在接口返回后更新)
])

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
  console.log('sub.value---', sub.value)
  getData(sub.value)
  getDictType()
  initComments() // 初始化评论数据
})

// 计算当前题型名称
const currentQuestionTypeName = computed(() => {
  if (!selectedQuestionType.value) return '全部题型'
  const type = questionTypes.value.find((t) => t.code === selectedQuestionType.value)
  return type ? type.name : '全部题型'
})

const getData = async (subject: number, questionType: string = '') => {
  let url = '/drive/driveTopicList?subject=' + subject
  if (questionType) {
    url += '&questionType=' + questionType
  }
  const res: any = await http({
    url: url,
    method: 'GET',
  })
  console.log('res-', res.data)
  questions.value = res.data || [] // 假设API返回的数据结构包含题目列表
  // 总数
  questionsTotal.value = res.data.length
  count.value = res.data?.length || 0
  userAnswers.value = new Array(res.data?.length || 0).fill('') // 初始化用户答案数组
  currentQuestionIndex.value = 0 // 重置题目索引
  showAnswer.value = false // 隐藏答案

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
    const isFavorited = await checkFavorite(userId, currentQuestion.id)
    if (isFavorited) {
      favoriteQuestions.value.add(currentQuestion.id)
    } else {
      favoriteQuestions.value.delete(currentQuestion.id)
    }
  } catch (error) {
    console.error('检查题目收藏状态失败:', error)
  }
}

const getDictType = async () => {
  let url = '/dict/type/getByDictName?dictCode=question_tags'
  const res: any = await http({
    url: url,
    method: 'GET',
  })
  console.log('res-', res.data)

  // 将后端返回的数据格式转换为前端需要的格式
  if (res.data && Array.isArray(res.data)) {
    questionTypes.value = res.data.map((item: DictType) => ({
      code: item.dictValue,
      name: item.dictLabel,
      icon: getIconForType(item.dictValue), // 根据类型获取图标
    }))
  }

  console.log('questionTypes-----', questionTypes.value)
}

// 根据题型code返回对应的图标
const getIconForType = (type: string): string => {
  const iconMap: Record<string, string> = {
    traffic_signs: '🚦',
    traffic_rules: '📋',
    safe_driving: '🚗',
    emergency_handling: '🚨',
    vehicle_knowledge: '🔧',
    driving_skills: '🎯',
    weather_driving: '🌧️',
    penalty_regulations: '⚖️',
    civilized_driving: '😊', // 文明驾驶题
    // 可以根据实际需要添加更多类型和图标
  }
  return iconMap[type] || '❓' // 默认图标
}

const getData2 = async (subject: number) => {
  await getData(subject, selectedQuestionType.value)
}

// 题型筛选函数
const selectQuestionType = async (typeCode: string) => {
  selectedQuestionType.value = typeCode
  await getData(sub.value, typeCode)
}

// 从弹窗选择题型
const selectQuestionTypeFromModal = async (typeCode: string) => {
  selectedQuestionType.value = typeCode
  showFilterModal.value = false
  await getData(sub.value, typeCode)
}

// 检查某个选项是否为正确答案
const isCorrectOption = (optionIndex: number) => {
  const correctOptionIndex = parseInt(questions.value[currentQuestionIndex.value].correctAnswer) - 1
  return optionIndex === correctOptionIndex
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

  const options = [
    questions.value[currentQuestionIndex.value].optionA,
    questions.value[currentQuestionIndex.value].optionB,
    questions.value[currentQuestionIndex.value].optionC,
    questions.value[currentQuestionIndex.value].optionD,
  ]
  userAnswers.value[currentQuestionIndex.value] = options[optionIndex]
  showAnswer.value = true
  console.log('userAnswers.value---', userAnswers.value)
}

// 检查答案是否正确
const isCorrectAnswer = computed(() => {
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
  if (questions.value.length > 0) {
    return [
      questions.value[currentQuestionIndex.value].optionA,
      questions.value[currentQuestionIndex.value].optionB,
      questions.value[currentQuestionIndex.value].optionC,
      questions.value[currentQuestionIndex.value].optionD,
    ]
  }
  return []
})

// 定义有效选项计算属性（过滤空选项）
const validOptions = computed(() => {
  if (questions.value.length > 0) {
    const allOptions = [
      questions.value[currentQuestionIndex.value].optionA,
      questions.value[currentQuestionIndex.value].optionB,
      questions.value[currentQuestionIndex.value].optionC,
      questions.value[currentQuestionIndex.value].optionD,
    ]

    return allOptions
      .map((option, index) => ({ text: option, index }))
      .filter((option) => option.text !== '' && option.text != null)
  }
  return []
})

// 计算选项数量
const optionCount = computed(() => {
  if (questions.value.length > 0) {
    const currentQuestion = questions.value[currentQuestionIndex.value]
    return [
      currentQuestion.optionA,
      currentQuestion.optionB,
      currentQuestion.optionC,
      currentQuestion.optionD,
    ].filter((option) => option !== '').length
  }
  return 0
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
  const correctOptionIndex = parseInt(questions.value[currentQuestionIndex.value].correctAnswer) - 1
  return optionLetters[correctOptionIndex]
})

// 显示图片弹出层
const showImagePopup = (index: number, src: string) => {
  //调用预览图片的方法
  uni.previewImage({
    urls: [src],
    current: index,
  })
}

// 监听题目变化，重置答案显示和检查收藏状态
watch(currentQuestionIndex, async () => {
  showAnswer.value = false
  // 切换题目时检查当前题目的收藏状态
  await checkCurrentQuestionFavoriteStatus()
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

// ==== 收藏功能 ====
// 计算当前题目是否已收藏
const isFavorited = computed(() => {
  if (questions.value.length === 0) return false
  const currentQuestionId = questions.value[currentQuestionIndex.value]?.id
  return favoriteQuestions.value.has(currentQuestionId)
})

// 切换收藏状态
const toggleFavorite = async () => {
  // 检查是否已登录
  if (!checkLogin()) return

  if (questions.value.length === 0) return

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
      await saveFavoriteToServer(userId, questionId, false)
      favoriteQuestions.value.delete(questionId)
      uni.showToast({
        title: '已取消收藏',
        icon: 'success',
        duration: 1500,
      })
    } else {
      // 添加收藏
      await saveFavoriteToServer(userId, questionId, true)
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
      return member.profile.id
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

// ==== 评论功能 ====
// 计算评论数量
const commentCount = computed(() => {
  return (
    comments.value.length +
    comments.value.reduce((total, comment) => {
      return total + (comment.replies ? comment.replies.length : 0)
    }, 0)
  )
})

// 排序后的评论列表
const sortedComments = computed(() => {
  const sortedList = [...comments.value]
  if (sortByTime.value) {
    // 按时间排序（最新的在前）
    return sortedList.sort((a, b) => b.createTime - a.createTime)
  } else {
    // 按热度排序（点赞数多的在前）
    return sortedList.sort((a, b) => b.likes - a.likes)
  }
})

// 切换评论区显示状态
const toggleCommentSection = () => {
  showCommentSection.value = !showCommentSection.value
}

// 切换排序方式
const toggleSortOrder = () => {
  sortByTime.value = !sortByTime.value
}

// 发表评论
const submitComment = async () => {
  // 检查是否已登录
  if (!checkLogin()) return

  if (!newComment.value.trim()) return

  const comment: Comment = {
    id: Date.now(), // 使用时间戳作为ID
    author: '我', // 实际应用中从用户信息获取
    avatar: 'https://via.placeholder.com/40x40/667eea/white?text=我',
    content: newComment.value.trim(),
    createTime: Date.now(),
    likes: 0,
    isLiked: false,
    canDelete: true, // 自己的评论可以删除
    replies: [],
  }

  comments.value.unshift(comment) // 添加到列表开头
  newComment.value = '' // 清空输入框

  uni.showToast({
    title: '评论发表成功',
    icon: 'success',
    duration: 1500,
  })

  // 这里可以调用API保存到服务器
  // await saveCommentToServer(comment)
}

// 切换点赞状态
const toggleLike = async (comment: Comment) => {
  // 检查是否已登录
  if (!checkLogin()) return

  comment.isLiked = !comment.isLiked
  comment.likes += comment.isLiked ? 1 : -1

  // 这里可以调用API同步到服务器
  // await toggleLikeOnServer(comment.id, comment.isLiked)
}

// 回复评论
const replyToComment = (comment: Comment) => {
  // 检查是否已登录
  if (!checkLogin()) return

  uni.showModal({
    title: '回复评论',
    editable: true,
    placeholderText: '请输入回复内容...',
    success: (res: any) => {
      if (res.confirm && res.content) {
        const reply: Reply = {
          id: Date.now(),
          author: '我',
          content: res.content.trim(),
          createTime: Date.now(),
        }

        if (!comment.replies) {
          comment.replies = []
        }
        comment.replies.push(reply)

        uni.showToast({
          title: '回复成功',
          icon: 'success',
          duration: 1500,
        })
      }
    },
  })
}

// 删除评论
const deleteComment = async (commentId: number) => {
  // 检查是否已登录
  if (!checkLogin()) return

  uni.showModal({
    title: '确认删除',
    content: '确定要删除这条评论吗？',
    success: (res: any) => {
      if (res.confirm) {
        const index = comments.value.findIndex((c) => c.id === commentId)
        if (index > -1) {
          comments.value.splice(index, 1)
          uni.showToast({
            title: '已删除',
            icon: 'success',
            duration: 1500,
          })
        }
      }
    },
  })
}

// 格式化评论时间
const formatCommentTime = (timestamp: number) => {
  const now = Date.now()
  const diff = now - timestamp
  const minutes = Math.floor(diff / 60000)
  const hours = Math.floor(diff / 3600000)
  const days = Math.floor(diff / 86400000)

  if (minutes < 1) return '刚刚'
  if (minutes < 60) return `${minutes}分钟前`
  if (hours < 24) return `${hours}小时前`
  if (days < 7) return `${days}天前`

  const date = new Date(timestamp)
  return `${date.getMonth() + 1}-${date.getDate()}`
}

// 获取用户答题状态
const getUserAnswerStatus = (index: number) => {
  if (userAnswers.value[index] === '') {
    return 'unanswered' // 未答题
  }

  const question = questions.value[index]
  if (!question) return 'unanswered'

  const correctOptionIndex = parseInt(question.correctAnswer) - 1
  const options = [question.optionA, question.optionB, question.optionC, question.optionD]
  const correctAnswer = options[correctOptionIndex]

  return userAnswers.value[index] === correctAnswer ? 'correct' : 'incorrect'
}

// 跳转到指定题目
const jumpToQuestion = (index: number) => {
  currentQuestionIndex.value = index
  showAnswer.value = false
  showDirectory.value = false // 跳转后隐藏目录
}

// 关闭目录
const closeDirectory = () => {
  showDirectory.value = false
}
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
  padding-top: calc(8px + 14px); /* 加上状态栏高度 */
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;
}

.header-title {
  display: flex;
  flex-direction: column;
}

.logo {
  font-size: 20px;
  font-weight: bold;
  margin-bottom: 2px;
}

.progress-text {
  font-size: 14px;
  opacity: 0.9;
}

.filter-icon {
  font-size: 14px;
  padding: 6px 12px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 15px;
  cursor: pointer;
}

/* 题型筛选栏 */
.filter-section {
  margin-top: 78px; /* 修正为合适的高度，避免被导航栏遮挡 */
  padding: 15px 0;
  background: white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.filter-scroll {
  white-space: nowrap;
}

.filter-tabs {
  display: flex;
  padding: 0 20px;
  gap: 10px;
}

.filter-tab {
  flex-shrink: 0;
  padding: 8px 16px;
  background: #f8f9fa;
  border-radius: 20px;
  font-size: 14px;
  color: #666;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid transparent;
}

.filter-tab.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-color: #667eea;
}

/* 题目卡片 */
.question-card {
  margin: 44px 20px 20px; /* 确保在筛选栏下方 */
  background: white;
  border-radius: 15px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.header-left {
  display: flex;
  flex-direction: column;
  flex: 1;
}

.header-actions {
  display: flex;
  align-items: center;
}

.favorite-btn {
  font-size: 20px;
  padding: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.1);
}

.favorite-btn:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: scale(1.1);
}

.favorite-btn.active {
  transform: scale(1.2);
  animation: heartbeat 0.6s ease-in-out;
}

@keyframes heartbeat {
  0% {
    transform: scale(1.2);
  }
  50% {
    transform: scale(1.4);
  }
  100% {
    transform: scale(1.2);
  }
}

.question-number {
  font-size: 16px;
  font-weight: bold;
}

.question-type {
  font-size: 12px;
  padding: 4px 8px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 10px;
}

.question-content {
  padding: 20px;
}

.question-text {
  font-size: 16px;
  line-height: 1.6;
  color: #333;
  margin-bottom: 15px;
  display: block;
}

.question-image {
  margin: 15px 0;
  text-align: center;
}

.question-img {
  width: 200px;
  height: 150px;
  border-radius: 10px;
  cursor: pointer;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

/* 选项样式 */
.options-container {
  margin-top: 20px;
}

.option-item {
  display: flex;
  align-items: center;
  padding: 15px;
  margin-bottom: 10px;
  background: #f8f9fa;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 2px solid transparent;
  position: relative;
}

.option-item:hover {
  background: #e9ecef;
}

.option-item.selected {
  background: #e3f2fd;
  border-color: #2196f3;
}

.option-item.correct {
  background: #e8f5e8;
  border-color: #4caf50;
}

.option-item.incorrect {
  background: #ffebee;
  border-color: #f44336;
}

.option-letter {
  width: 30px;
  height: 30px;
  background: #667eea;
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: bold;
  margin-right: 15px;
  flex-shrink: 0;
}

.option-item.correct .option-letter {
  background: #4caf50;
}

.option-item.incorrect .option-letter {
  background: #f44336;
}

.option-text {
  flex: 1;
  font-size: 15px;
  line-height: 1.5;
  color: #333;
}

.option-icon {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: bold;
  margin-left: 10px;
}

.correct-icon {
  background: #4caf50;
  color: white;
}

.incorrect-icon {
  background: #f44336;
  color: white;
}

/* 答案解析卡片 */
.analysis-card {
  margin: 20px;
  background: white;
  border-radius: 15px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.analysis-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
  background: #f8f9fa;
  border-bottom: 1px solid #e9ecef;
}

.analysis-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
}

.result-icon {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  font-weight: bold;
  color: white;
}

.result-icon.correct {
  background: #4caf50;
}

.result-icon.incorrect {
  background: #f44336;
}

.analysis-content {
  padding: 20px;
}

.answer-comparison {
  margin-bottom: 20px;
}

.answer-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 0;
  border-bottom: 1px solid #f0f0f0;
}

.answer-item:last-child {
  border-bottom: none;
}

.answer-label {
  font-size: 14px;
  color: #666;
}

.answer-value {
  font-size: 16px;
  font-weight: bold;
}

.user-answer {
  color: #2196f3;
}

.correct-answer {
  color: #4caf50;
}

.explanation {
  padding-top: 15px;
  border-top: 1px solid #f0f0f0;
}

.explanation-title {
  font-size: 14px;
  font-weight: bold;
  color: #333;
  margin-bottom: 8px;
  display: block;
}

.explanation-text {
  font-size: 14px;
  line-height: 1.6;
  color: #666;
  display: block;
}

/* 操作按钮 */
.action-buttons {
  padding: 0 20px 20px;
}

.btn-group {
  display: flex;
  gap: 15px;
  margin-bottom: 15px;
}

.btn {
  flex: 1;
  padding: 15px;
  border-radius: 10px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  border: none;
  text-align: center;
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-outline {
  background: white;
  color: #667eea;
  border: 2px solid #667eea;
}

.btn-outline:hover:not(:disabled) {
  background: #667eea;
  color: white;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
}

.btn-refresh {
  width: 100%;
  background: #4caf50;
  color: white;
}

.btn-refresh:hover {
  background: #45a049;
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(76, 175, 80, 0.4);
}

.btn-comment {
  width: 100%;
  background: #ff9800;
  color: white;
  margin-top: 10px;
}

.btn-comment:hover {
  background: #f57c00;
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(255, 152, 0, 0.4);
}

/* 筛选弹窗 */
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

.question-types-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 15px;
}

.type-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px 15px;
  background: #f8f9fa;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 2px solid transparent;
  text-align: center;
}

.type-item:hover {
  background: #e9ecef;
  transform: translateY(-2px);
}

.type-item.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-color: #667eea;
}

.type-icon {
  font-size: 24px;
  margin-bottom: 8px;
  display: block;
}

.type-name {
  font-size: 12px;
  font-weight: 500;
  display: block;
}

.ad-view {
  background-color: #ffffff;
  margin: 20px;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
}

/* 评论区样式 */
.comment-section {
  margin: 20px;
  background: white;
  border-radius: 15px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.comment-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
  background: #f8f9fa;
  border-bottom: 1px solid #e9ecef;
}

.comment-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
}

.sort-btn {
  font-size: 12px;
  color: #667eea;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 4px;
  transition: background 0.3s ease;
}

.sort-btn:hover {
  background: #e3f2fd;
}

/* 评论输入区 */
.comment-input-section {
  padding: 20px;
  border-bottom: 1px solid #f0f0f0;
  display: flex;
  gap: 15px;
}

.input-container {
  flex: 1;
  position: relative;
}

.comment-input {
  width: 90%;
  min-height: 80px;
  padding: 12px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 14px;
  line-height: 1.5;
  resize: none;
  outline: none;
  transition: border-color 0.3s ease;
}

.comment-input:focus {
  border-color: #667eea;
  box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.1);
}

.char-count {
  position: absolute;
  bottom: 8px;
  right: 12px;
  font-size: 12px;
  color: #999;
}

.submit-btn {
  padding: 12px 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  height: fit-content;
  align-self: flex-end;
}

.submit-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
}

.submit-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* 评论列表 */
.comment-list {
  padding: 20px;
}

.comment-item {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
  padding-bottom: 20px;
  border-bottom: 1px solid #f0f0f0;
}

.comment-item:last-child {
  border-bottom: none;
  margin-bottom: 0;
  padding-bottom: 0;
}

.comment-avatar {
  flex-shrink: 0;
}

.avatar-img {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: #f0f0f0;
}

.comment-content {
  flex: 1;
}

.comment-header-info {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 8px;
}

.comment-author {
  font-size: 14px;
  font-weight: 600;
  color: #333;
}

.comment-time {
  font-size: 12px;
  color: #999;
}

.comment-text {
  font-size: 14px;
  line-height: 1.6;
  color: #333;
  margin-bottom: 12px;
  display: block;
}

.comment-actions {
  display: flex;
  gap: 15px;
}

.action-btn {
  font-size: 12px;
  color: #666;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 4px;
  transition: all 0.3s ease;
  user-select: none;
}

.action-btn:hover {
  background: #f0f0f0;
}

.like-btn.active {
  color: #2196f3;
  background: #e3f2fd;
}

.delete-btn {
  color: #f44336;
}

.delete-btn:hover {
  background: #ffebee;
}

/* 回复列表 */
.reply-list {
  margin-top: 12px;
  padding-left: 15px;
  border-left: 2px solid #f0f0f0;
}

.reply-item {
  padding: 8px 0;
  border-bottom: 1px solid #f8f9fa;
  font-size: 13px;
  line-height: 1.5;
}

.reply-item:last-child {
  border-bottom: none;
}

.reply-author {
  color: #667eea;
  font-weight: 600;
  margin-right: 5px;
}

.reply-content {
  color: #333;
  margin-right: 10px;
}

.reply-time {
  color: #999;
  font-size: 12px;
}

/* 空状态 */
.empty-comments {
  text-align: center;
  padding: 40px 20px;
  color: #999;
}

.empty-icon {
  font-size: 32px;
  margin-bottom: 10px;
  display: block;
}

.empty-text {
  font-size: 14px;
  display: block;
}

/* 题号目录对话框 */
.directory-dialog {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 2000;
  opacity: 0;
  visibility: hidden;
  transition: opacity 0.3s ease, visibility 0.3s ease;
}

.directory-dialog.show {
  opacity: 1;
  visibility: visible;
}

.directory-content {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: white;
  border-radius: 20px 20px 0 0;
  transform: translateY(100%);
  transition: transform 0.3s ease;
  max-height: 70vh;
  overflow: hidden;
}

.directory-dialog.show .directory-content {
  transform: translateY(0);
}

.directory-header {
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  padding: 15px 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #e9ecef;
}

.directory-title {
  font-size: 16px;
  font-weight: 600;
  color: #333;
}

.close-btn {
  font-size: 24px;
  color: #999;
  cursor: pointer;
  padding: 5px;
}

.directory-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 10px;
  padding: 20px;
  max-height: calc(70vh - 70px);
  overflow-y: auto;
}

.directory-item {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 40px;
  border-radius: 8px;
  background: #f8f9fa;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 2px solid transparent;
}

.directory-item:hover {
  background: #e9ecef;
  transform: translateY(-2px);
}

.directory-item.current {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 0 4px 10px rgba(102, 126, 234, 0.3);
  border: 2px solid white;
}

.directory-item.answered {
  background: #e3f2fd;
  color: #1976d2;
}

.directory-item.correct {
  background: #e8f5e8;
  color: #4caf50;
}

.directory-item.incorrect {
  background: #ffebee;
  color: #f44336;
}

/* 按钮样式 */
.btn-directory {
  flex: 1;
  padding: 15px;
  border-radius: 10px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  border: none;
  text-align: center;
  background: #667eea;
  color: white;
  margin-right: 10px;
}

.btn-directory:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
}

.btn-directory:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .directory-grid {
    grid-template-columns: repeat(4, 1fr);
    gap: 8px;
    padding: 15px;
  }

  .directory-item {
    height: 35px;
    font-size: 14px;
  }

  .btn-directory {
    padding: 12px;
    font-size: 14px;
    margin-right: 8px;
  }
}
</style>
