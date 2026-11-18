<script setup lang="ts">
import { computed, ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { http } from '@/utils/http'
import { buildUrlWithExamType, getCurrentExamType } from '@/utils/examTypeHelper'
import { useMemberStore } from '@/stores'

const subject = ref(1)
const questions = ref<any[]>([])
const index = ref(0)
const picked = ref('')
const revealed = ref(false)
const correctCount = ref(0)
const finished = ref(false)
const loading = ref(true)

const letters = ['A', 'B', 'C', 'D']
const current = computed(() => questions.value[index.value])
const options = computed(() => {
  const question = current.value
  if (!question) return []
  return [question.optionA, question.optionB, question.optionC, question.optionD]
    .map((text, optionIndex) => ({
      letter: letters[optionIndex],
      text,
      value: String(optionIndex + 1),
    }))
    .filter((item) => item.text)
})

const progressText = computed(() => {
  if (!questions.value.length) return '0/0'
  return `${Math.min(index.value + 1, questions.value.length)}/${questions.value.length}`
})

onLoad((options: any) => {
  subject.value = Number(options?.sub || 1)
  loadQuestions()
})

const loadQuestions = async () => {
  loading.value = true
  finished.value = false
  index.value = 0
  picked.value = ''
  revealed.value = false
  correctCount.value = 0
  const examType = getCurrentExamType()
  try {
    const res: any = await http({
      url: `/drive/dailyQuestion?subject=${subject.value}&examType=${examType}&size=10`,
      method: 'GET',
      silent: true,
    })
    if (res?.code === 0 && Array.isArray(res.data) && res.data.length) {
      questions.value = res.data
      loading.value = false
      return
    }
  } catch (error) {
    console.log('每日一练接口暂不可用，改用模拟考试抽题', error)
  }
  try {
    const fallback: any = await http({
      url: buildUrlWithExamType('/drive/examDriveQuestion', subject.value),
      method: 'GET',
    })
    questions.value = (fallback?.data || []).slice(0, 10)
  } catch (error) {
    questions.value = []
    uni.showToast({ title: '题目加载失败', icon: 'none' })
  }
  loading.value = false
}

const choose = (value: string) => {
  if (revealed.value || !current.value) return
  picked.value = value
  revealed.value = true
  if (String(current.value.correctAnswer) === value) {
    correctCount.value += 1
  }
}

const optionClass = (value: string) => {
  if (!revealed.value) return picked.value === value ? 'picked' : ''
  if (value === String(current.value?.correctAnswer)) return 'right'
  if (value === picked.value) return 'wrong'
  return ''
}

const next = async () => {
  if (!revealed.value) {
    uni.showToast({ title: '先选一个答案', icon: 'none' })
    return
  }
  if (index.value < questions.value.length - 1) {
    index.value += 1
    picked.value = ''
    revealed.value = false
    return
  }
  finished.value = true
  const memberStore = useMemberStore()
  if (!memberStore.profile) return
  try {
    await http({
      url: '/study/checkin',
      method: 'POST',
      data: {
        subject: subject.value,
        examType: getCurrentExamType(),
        questionCount: questions.value.length,
        correctCount: correctCount.value,
      },
    })
  } catch (error) {
    console.log('打卡未同步', error)
  }
}
</script>

<template>
  <view class="page">
    <view v-if="loading" class="empty">正在抽题...</view>
    <view v-else-if="!questions.length" class="empty">这个科目暂时没有题目</view>
    <view v-else-if="finished" class="result">
      <text class="result-kicker">今日练习完成</text>
      <text class="result-score">{{ correctCount }}/{{ questions.length }}</text>
      <text class="result-desc">答对 {{ correctCount }} 题，已记入今日打卡</text>
      <button class="primary" @click="loadQuestions">再来一组</button>
    </view>
    <view v-else class="card">
      <view class="meta">
        <text>{{ subject === 4 ? '科目四' : '科目一' }}</text>
        <text>{{ progressText }}</text>
      </view>
      <text class="stem">{{ current.questionContent }}</text>
      <image v-if="current.imageUrl" class="stem-image" :src="current.imageUrl" mode="widthFix" />
      <view
        v-for="item in options"
        :key="item.value"
        :class="['option', optionClass(item.value)]"
        @click="choose(item.value)"
      >
        <text class="letter">{{ item.letter }}</text>
        <text class="option-text">{{ item.text }}</text>
      </view>
      <view v-if="revealed" class="explain">
        <text class="explain-title">解析</text>
        <text class="explain-body">{{ current.questionExplain || '这道题暂无解析' }}</text>
      </view>
      <button class="primary" @click="next">{{ index < questions.length - 1 ? '下一题' : '完成并打卡' }}</button>
    </view>
  </view>
</template>

<style lang="scss" scoped>
.page {
  min-height: 100vh;
  max-width: 480px;
  margin: 0 auto;
  background: #f3f6f4;
  padding: 24rpx;
  box-sizing: border-box;
}

.card,
.result,
.empty {
  background: #fff;
  border-radius: 28rpx;
  padding: 32rpx 28rpx;
}

.empty {
  color: #6b7280;
  text-align: center;
}

.meta {
  display: flex;
  justify-content: space-between;
  color: #0f766e;
  font-size: 24rpx;
  font-weight: 600;
}

.stem {
  display: block;
  margin: 20rpx 0 24rpx;
  font-size: 32rpx;
  line-height: 1.6;
  color: #10221f;
  font-weight: 600;
}

.stem-image {
  width: 100%;
  border-radius: 16rpx;
  margin-bottom: 20rpx;
}

.option {
  display: flex;
  align-items: flex-start;
  gap: 16rpx;
  padding: 22rpx;
  margin-bottom: 16rpx;
  border-radius: 18rpx;
  background: #f4f7f6;
}

.letter {
  width: 44rpx;
  font-weight: 700;
  color: #0f766e;
}

.option-text {
  flex: 1;
  font-size: 28rpx;
  color: #10221f;
  line-height: 1.5;
}

.option.right {
  background: #d1fae5;
}

.option.wrong {
  background: #fee2e2;
}

.explain {
  margin: 8rpx 0 24rpx;
  padding: 20rpx;
  border-radius: 16rpx;
  background: #fff7ed;
}

.explain-title {
  display: block;
  font-size: 24rpx;
  color: #9a3412;
  font-weight: 700;
}

.explain-body {
  display: block;
  margin-top: 8rpx;
  font-size: 26rpx;
  line-height: 1.6;
  color: #7c2d12;
}

.primary {
  margin-top: 12rpx;
  background: #0f766e;
  color: #fff;
  border-radius: 16rpx;
  font-size: 30rpx;
}

.result-kicker {
  display: block;
  color: #0f766e;
  font-size: 26rpx;
}

.result-score {
  display: block;
  margin-top: 12rpx;
  font-size: 72rpx;
  font-weight: 700;
  color: #10221f;
}

.result-desc {
  display: block;
  margin: 12rpx 0 28rpx;
  color: #6b7280;
  font-size: 28rpx;
}
</style>
