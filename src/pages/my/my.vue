<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useMemberStore } from '@/stores'
import { useExamTypeStore } from '@/stores/modules/examType'
import { vipChecker } from '@/utils/vipChecker'
import { http } from '@/utils/http'
import ExamTypeSelector from '@/components/ExamTypeSelector.vue'

// 获取屏幕边界到安全区域距离
const { safeAreaInsets } = uni.getSystemInfoSync()

// 获取会员信息
const memberStore = useMemberStore()

// 获取车型信息
const examTypeStore = useExamTypeStore()

// 车型选择器引用
const examTypeSelectorRef = ref()

// 新增状态管理
const showVipModal = ref(false)
const showSettingsModal = ref(false)
const studyStats = ref({
  totalQuestions: 2580,
  correctRate: 85,
  studyDays: 15,
  examsPassed: 3,
})

// 计算VIP状态
const isVipUser = computed(() => {
  return (
    memberStore.profile &&
    memberStore.profile.vipLevel !== undefined &&
    memberStore.profile.vipLevel > 0
  )
})

// 学习统计数据
const studyProgress = ref([
  { subject: '科目一', progress: 75, total: 1325 },
  { subject: '科目四', progress: 45, total: 1255 },
])

// 功能菜单项
const menuItems = ref([
  { icon: '📝', title: '错题本', count: 23, path: '/pages/wrong-questions/wrong-questions' },
  { icon: '❤️', title: '我的收藏', count: 156, path: '/pages/favorites/favorites' },
  { icon: '🏆', title: '学习记录', count: 15, path: '/pages/study-record/study-record' },
  { icon: '🎯', title: '考试记录', count: 8, path: '/pages/exam-record/exam-record' },
  { icon: '📊', title: '学习统计', count: 0, path: '/pages/statistics/statistics' },
  { icon: '🎁', title: '积分商城', count: 0, path: '/pages/points-mall/points-mall' },
  { icon: '👑', title: '会员中心', count: 0, path: '/pages/member-center/member-center' },
  { icon: '📋', title: '我的订单', count: 0, path: '/pages/order-list/order-list' },
])

// 更换车型
const changeExamType = () => {
  // 显示车型选择器
  if (examTypeSelectorRef.value) {
    // 直接修改子组件的showSelector属性
    examTypeSelectorRef.value.showSelector = true
  }
}

// 跳转到错题本页面
const goToWrongQuestions = async () => {
  console.log('跳转到错题本')

  // 检查是否有VIP权限要求
  const hasAccess = await vipChecker.checkVipAccess(false) // 假设错题本不需要VIP权限
  if (!hasAccess) {
    return // 如果没有权限，直接返回
  }

  uni.navigateTo({
    url: '/pages/wrong-questions/wrong-questions',
    success: () => {
      console.log('错题本页面跳转成功')
    },
    fail: (err) => {
      console.error('错题本页面跳转失败:', err)
      uni.showToast({
        title: '错题本跳转失败',
        icon: 'error',
      })
    },
  })
}

const goToDaily = () => {
  uni.navigateTo({ url: '/pages/daily/daily?sub=1' })
}

const goToKnowledge = () => {
  uni.navigateTo({ url: '/pages/knowledge/knowledge?sub=1' })
}

const goToPlan = () => {
  uni.navigateTo({ url: '/pages/plan/plan' })
}

// 跳转到我的收藏页面
const goToFavorites = async () => {
  console.log('跳转到我的收藏')

  // 检查是否有VIP权限要求
  const hasAccess = await vipChecker.checkVipAccess(false) // 假设收藏不需要VIP权限
  if (!hasAccess) {
    return // 如果没有权限，直接返回
  }

  uni.navigateTo({
    url: '/pages/favorites/favorites',
    success: () => {
      console.log('我的收藏页面跳转成功')
    },
    fail: (err) => {
      console.error('我的收藏页面跳转失败:', err)
      uni.showToast({
        title: '我的收藏跳转失败',
        icon: 'error',
      })
    },
  })
}

// 跳转到学习记录页面
const goToStudyRecord = async () => {
  console.log('跳转到学习记录')

  // 检查是否有VIP权限要求
  const hasAccess = await vipChecker.checkVipAccess(false) // 假设学习记录不需要VIP权限
  if (!hasAccess) {
    return // 如果没有权限，直接返回
  }

  uni.navigateTo({
    url: '/pages/study-record/study-record',
    success: () => {
      console.log('学习记录页面跳转成功')
    },
    fail: (err) => {
      console.error('学习记录页面跳转失败:', err)
      uni.showToast({
        title: '学习记录跳转失败',
        icon: 'error',
      })
    },
  })
}

// 跳转到考试记录页面
const goToExamRecord = async () => {
  console.log('跳转到考试记录')

  // 检查是否有VIP权限要求
  const hasAccess = await vipChecker.checkVipAccess(false) // 假设考试记录不需要VIP权限
  if (!hasAccess) {
    return // 如果没有权限，直接返回
  }

  uni.navigateTo({
    url: '/pages/exam-record/exam-record',
    success: () => {
      console.log('考试记录页面跳转成功')
    },
    fail: (err) => {
      console.error('考试记录页面跳转失败:', err)
      uni.showToast({
        title: '考试记录跳转失败',
        icon: 'error',
      })
    },
  })
}

// 跳转到学习统计页面
const goToStatistics = async () => {
  console.log('跳转到学习统计')

  // 检查是否有VIP权限要求
  const hasAccess = await vipChecker.checkVipAccess(false) // 假设学习统计不需要VIP权限
  if (!hasAccess) {
    return // 如果没有权限，直接返回
  }

  uni.navigateTo({
    url: '/pages/statistics/statistics',
    success: () => {
      console.log('学习统计页面跳转成功')
    },
    fail: (err) => {
      console.error('学习统计页面跳转失败:', err)
      uni.showToast({
        title: '学习统计跳转失败',
        icon: 'error',
      })
    },
  })
}

// 跳转到积分商城页面
const goToPointsMall = async () => {
  console.log('跳转到积分商城')

  // 检查是否有VIP权限要求
  const hasAccess = await vipChecker.checkVipAccess(false) // 假设积分商城不需要VIP权限
  if (!hasAccess) {
    return // 如果没有权限，直接返回
  }

  uni.navigateTo({
    url: '/pages/points-mall/points-mall',
    success: () => {
      console.log('积分商城页面跳转成功')
    },
    fail: (err) => {
      console.error('积分商城页面跳转失败:', err)
      uni.showToast({
        title: '积分商城跳转失败',
        icon: 'error',
      })
    },
  })
}

// 跳转到会员中心页面
const goToMemberCenter = async () => {
  console.log('跳转到会员中心')

  // 检查是否有VIP权限要求
  const hasAccess = await vipChecker.checkVipAccess(false) // 会员中心不需要VIP权限检查
  if (!hasAccess) {
    return // 如果没有权限，直接返回
  }

  uni.navigateTo({
    url: '/pages/member-center/member-center',
    success: () => {
      console.log('会员中心页面跳转成功')
    },
    fail: (err) => {
      console.error('会员中心页面跳转失败:', err)
      uni.showToast({
        title: '会员中心跳转失败',
        icon: 'error',
      })
    },
  })
}

// 跳转到我的订单页面
const goToOrderList = async () => {
  console.log('跳转到我的订单')

  // 检查是否有VIP权限要求
  const hasAccess = await vipChecker.checkVipAccess(false) // 假设订单列表不需要VIP权限
  if (!hasAccess) {
    return // 如果没有权限，直接返回
  }

  uni.navigateTo({
    url: '/pages/order-list/order-list',
    success: () => {
      console.log('我的订单页面跳转成功')
    },
    fail: (err) => {
      console.error('我的订单页面跳转失败:', err)
      uni.showToast({
        title: '我的订单跳转失败',
        icon: 'error',
      })
    },
  })
}

// 处理菜单点击 - 根据菜单项调用对应的跳转函数
const handleMenuClick = async (item: any) => {
  console.log('点击菜单:', item.title)

  // 检查是否有VIP权限要求（根据实际业务需求）
  const needVip = item.title === '交规视频' // 假设只有视频需要VIP权限
  const hasAccess = await vipChecker.checkVipAccess(needVip)
  if (!hasAccess) {
    return // 如果没有权限，直接返回
  }

  switch (item.title) {
    case '错题本':
      goToWrongQuestions()
      break
    case '我的收藏':
      goToFavorites()
      break
    case '学习记录':
      goToStudyRecord()
      break
    case '考试记录':
      goToExamRecord()
      break
    case '学习统计':
      goToStatistics()
      break
    case '积分商城':
      goToPointsMall()
      break
    case '会员中心':
      goToMemberCenter()
      break
    case '我的订单':
      goToOrderList()
      break
    default:
      uni.showToast({
        title: '功能开发中',
        icon: 'none',
      })
  }
}

// 处理登录
const handleLogin = () => {
  uni.navigateTo({
    url: '/pages/login/login',
  })
}

// 处理个人信息编辑
const handleProfileEdit = () => {
  if (!memberStore.profile) {
    handleLogin()
    return
  }
  uni.navigateTo({
    url: '/pages/profile/profile',
  })
}

// 退出登录
const handleLogout = () => {
  uni.showModal({
    title: '提示',
    content: '确定退出登录吗？',
    success: (res) => {
      if (!res.confirm) return
      memberStore.clearProfile()
      uni.showToast({ title: '已退出登录', icon: 'none' })
    },
  })
}

// 显示VIP弹窗
const showVipDialog = () => {
  showVipModal.value = true
}

// 关闭VIP弹窗
const closeVipModal = () => {
  showVipModal.value = false
}

// 显示设置弹窗
const showSettings = () => {
  showSettingsModal.value = true
}

// 关闭设置弹窗
const closeSettingsModal = () => {
  showSettingsModal.value = false
}

// 页面加载时检查会员状态
onMounted(async () => {
  // 页面加载时检查会员状态
  await vipChecker.checkVipStatus(true)
})

// 视频广告部分
const urlCallback = ref({})
const rewardedAd = ref(null)
const handleAdClose = async (e: any) => {
  if (e.detail && e.detail.isEnded) {
    let getTime = new Date().getTime()
    urlCallback.value.userId = getTime
    urlCallback.value.extra = getTime
    console.log('urlCallback.value===', urlCallback.value)
    // 获取会员
    const res: any = await http({
      url: '/apadwatchrecord/adWatchRecord',
      method: 'GET',
    })
    if (res.data && memberStore.profile) {
      showVipModal.value = false
      // @ts-ignore
      memberStore.profile.vipLevel = res.data.vipLevel
      // @ts-ignore
      memberStore.profile.vipExpireTime = res.data.vipExpireTime
      // @ts-ignore
      memberStore.profile.integral = res.data.integral
      // 提示框：升级VIP成功
      uni.showToast({
        title: '升级VIP成功',
        icon: 'success',
      })
    }
  }
}
const watchAdForVip = () => {
  if (rewardedAd.value) {
    // @ts-ignore
    rewardedAd.value.show()
  }
}

const formatDate = (dateString: any) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate()
  return `${year}年${month}月${day}日`
}
</script>

<template>
  <view class="container">
    <!-- 个人资料卡片 -->
    <view class="profile-card">
      <!-- 已登录状态 -->
      <view v-if="memberStore.profile" class="profile-content">
        <view class="user-info" @click="handleProfileEdit">
          <image
            class="avatar"
            mode="aspectFill"
            :src="
              (memberStore.profile && memberStore.profile.avatar) ||
              'https://via.placeholder.com/80x80/667eea/white?text=头像'
            "
          />
          <view class="user-details">
            <text class="nickname">{{
              (memberStore.profile && memberStore.profile.nickname) ||
              (memberStore.profile && memberStore.profile.account) ||
              '驾考学员'
            }}</text>
            <view class="user-level">
              <text v-if="isVipUser" class="vip-badge">VIP会员</text>
              <text v-if="isVipUser" class="level-text"
                >到期时间：{{
                  memberStore.profile && formatDate(memberStore.profile.vipExpireTime)
                }}</text
              >
              <text v-else class="normal-badge">普通用户</text>
              <text class="level-text"
                >等级 Lv.{{ (memberStore.profile && memberStore.profile.level) || 1 }}
              </text>
            </view>
            <text class="phone"
              >积分 {{ (memberStore.profile && memberStore.profile.integral) || 1 }}
            </text>
            <text class="phone">{{
              (memberStore.profile && memberStore.profile.mobile) || '未绑定手机'
            }}</text>
          </view>
        </view>
        <!-- VIP升级按钮 -->
        <view v-if="!isVipUser" class="upgrade-vip" @click="showVipDialog">
          <text class="upgrade-text">升级VIP</text>
          <text class="upgrade-icon">👑</text>
        </view>
      </view>
      <!-- 未登录状态 -->
      <view v-else class="profile-content guest">
        <view class="user-info" @click="handleLogin">
          <image
            class="avatar guest-avatar"
            mode="aspectFill"
            src="https://via.placeholder.com/80x80/cccccc/white?text=登录"
          />
          <view class="user-details">
            <text class="nickname">点击登录</text>
            <text class="login-tip">登录后享受更多功能</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 车型选择卡片 -->
    <view class="exam-type-card">
      <view class="card-header">
        <text class="card-title">准驾车型</text>
      </view>
      <view class="card-content">
        <view class="exam-type-info">
          <text class="exam-type-text">当前选择：</text>
          <text class="exam-type-value">{{ examTypeStore.getExamTypeName() }}</text>
        </view>
        <button class="change-type-btn" @click="changeExamType">更换车型</button>
      </view>
    </view>

    <!-- 学习统计卡片 -->
    <view class="stats-card" v-if="false">
      <view class="card-header">
        <text class="card-title">学习统计</text>
      </view>
      <view class="stats-grid">
        <view class="stat-item">
          <text class="stat-number">{{ studyStats.totalQuestions }}</text>
          <text class="stat-label">累计刷题</text>
        </view>
        <view class="stat-item">
          <text class="stat-number">{{ studyStats.correctRate }}%</text>
          <text class="stat-label">正确率</text>
        </view>
        <view class="stat-item">
          <text class="stat-number">{{ studyStats.studyDays }}</text>
          <text class="stat-label">学习天数</text>
        </view>
        <view class="stat-item">
          <text class="stat-number">{{ studyStats.examsPassed }}</text>
          <text class="stat-label">通过考试</text>
        </view>
      </view>
    </view>

    <!-- 学习进度卡片 -->
    <view class="progress-card" v-if="false">
      <view class="card-header">
        <text class="card-title">学习进度</text>
      </view>
      <view class="progress-list">
        <view v-for="(item, index) in studyProgress" :key="index" class="progress-item">
          <view class="progress-info">
            <text class="subject-name">{{ item.subject }}</text>
            <text class="progress-text"
              >{{ item.progress }}% ({{ Math.round((item.total * item.progress) / 100) }}/{{
                item.total
              }})</text
            >
          </view>
          <view class="progress-bar">
            <view class="progress-fill" :style="{ width: item.progress + '%' }"></view>
          </view>
        </view>
      </view>
    </view>

    <!-- 功能菜单卡片 -->
    <view class="menu-card">
      <view class="card-header">
        <text class="card-title">我的工具</text>
      </view>
      <view class="menu-grid">
        <!-- 错题本 -->
        <view class="menu-item" @click="goToWrongQuestions">
          <text class="menu-icon">📝</text>
          <text class="menu-title">错题本</text>
        </view>
        <!-- 我的收藏 -->
        <view class="menu-item" @click="goToFavorites">
          <text class="menu-icon">❤️</text>
          <text class="menu-title">我的收藏</text>
        </view>
        <view class="menu-item" @click="goToDaily">
          <text class="menu-icon">练</text>
          <text class="menu-title">每日一练</text>
        </view>
        <view class="menu-item" @click="goToKnowledge">
          <text class="menu-icon">记</text>
          <text class="menu-title">考点速记</text>
        </view>
        <view class="menu-item" @click="goToPlan">
          <text class="menu-icon">期</text>
          <text class="menu-title">考试计划</text>
        </view>
        <!-- 学习记录 -->
        <view class="menu-item" @click="goToStudyRecord">
          <text class="menu-icon">🏆</text>
          <text class="menu-title">学习记录</text>
        </view>
        <!-- 考试记录 -->
        <view class="menu-item" @click="goToExamRecord">
          <text class="menu-icon">🎯</text>
          <text class="menu-title">考试记录</text>
        </view>
        <!-- 学习统计 -->
        <view class="menu-item" @click="goToStatistics">
          <text class="menu-icon">📊</text>
          <text class="menu-title">学习统计</text>
        </view>
        <!-- 积分商城 -->
        <view class="menu-item" @click="goToPointsMall">
          <text class="menu-icon">🎁</text>
          <text class="menu-title">积分商城</text>
        </view>
        <!-- 会员中心 -->
        <view class="menu-item" @click="goToMemberCenter">
          <text class="menu-icon">👑</text>
          <text class="menu-title">会员中心</text>
        </view>
        <!-- 我的订单 -->
        <view class="menu-item" @click="goToOrderList">
          <text class="menu-icon">📋</text>
          <text class="menu-title">我的订单</text>
        </view>
      </view>
    </view>

    <!-- 退出登录 -->
    <view v-if="memberStore.profile" class="logout-card">
      <view class="logout-btn" @click="handleLogout">退出登录</view>
    </view>

    <!-- VIP升级弹窗 -->
    <view v-if="showVipModal" class="modal" @click="closeVipModal">
      <view class="modal-content" @click.stop>
        <view class="modal-header">
          <text class="modal-title">升级VIP会员</text>
          <text class="close" @click="closeVipModal">&times;</text>
        </view>
        <view class="modal-body">
          <view class="vip-benefits">
            <text class="benefits-title">VIP专享特权</text>
            <view class="benefit-item">
              <text class="benefit-icon">✓</text>
              <text class="benefit-text">解锁全部交规视频</text>
            </view>
            <view class="benefit-item">
              <text class="benefit-icon">✓</text>
              <text class="benefit-text">无限制刷题练习</text>
            </view>
            <view class="benefit-item">
              <text class="benefit-icon">✓</text>
              <text class="benefit-text">专业错题分析</text>
            </view>
            <view class="benefit-item">
              <text class="benefit-icon">✓</text>
              <text class="benefit-text">优先客服支持</text>
            </view>
          </view>
          <view class="vip-plans" v-if="false">
            <view class="plan-item">
              <text class="plan-title">月卡</text>
              <text class="plan-price">￥29.9</text>
            </view>
            <view class="plan-item recommended">
              <text class="plan-title">年卡</text>
              <text class="plan-price">￥199.9</text>
              <view class="discount-badge">的6折</view>
            </view>
          </view>
          <button class="vip-btn" v-show="false">立即开通</button>

          <!-- 视频广告按钮和组件  :disabled="isLoading" -->
          <button class="vip-btn" @click="watchAdForVip">立即看视频得会员</button>
        </view>
      </view>
    </view>

    <!-- 设置弹窗 -->
    <view v-if="showSettingsModal" class="modal" @click="closeSettingsModal">
      <view class="modal-content" @click.stop>
        <view class="modal-header">
          <text class="modal-title">设置</text>
          <text class="close" @click="closeSettingsModal">&times;</text>
        </view>
        <view class="modal-body">
          <view class="setting-item">
            <text class="setting-label">清除缓存</text>
            <text class="setting-action">清除</text>
          </view>
          <view class="setting-item">
            <text class="setting-label">关于我们</text>
            <text class="setting-action">></text>
          </view>
          <view class="setting-item">
            <text class="setting-label">版本信息</text>
            <text class="setting-value">v1.0.0</text>
          </view>
          <view v-if="memberStore.profile" class="setting-item logout" @click="handleLogout">
            <text class="setting-label">退出登录</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 视频广告组件 -->
    <view class="video-ad-section">
      <!-- 视频激励广告组件（默认隐藏，通过 ref 控制播放） -->
      <ad-rewarded-video
        :url-callback="urlCallback"
        class="ad-video"
        ref="rewardedAd"
        adpid="1315895981"
        :loadnext="true"
        @close="handleAdClose"
        v-slot:default="{ loading, error }"
      >
        <button :disabled="loading" :loading="loading" style="display: none"></button>
        <view v-if="error">{{ error }}</view>
      </ad-rewarded-video>
    </view>

    <!-- 车型选择弹窗 -->
    <ExamTypeSelector ref="examTypeSelectorRef" />
  </view>
</template>

<style lang="scss" scoped>
/* 基础样式 */
.container {
  min-height: 100vh;
  max-width: 480px;
  margin: 0 auto;
  background-color: #f3f6f4;
  padding: 16px 0 70px;
}

/* 顶部导航栏 */
.header {
  background: linear-gradient(135deg, #0f766e 0%, #115e59 100%);
  color: white;
  padding: 20px 0 15px;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
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

.settings-icon {
  font-size: 14px;
  padding: 6px 12px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 15px;
  cursor: pointer;
}

/* 个人资料卡片 */
.profile-card {
  margin: 0px 20px 20px;
  background: linear-gradient(160deg, #115e59 0%, #0f766e 70%);
  border-radius: 18px;
  box-shadow: 0 8px 24px rgba(15, 118, 110, 0.18);
  overflow: hidden;
}

.profile-content {
  padding: 25px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.profile-content.guest {
  justify-content: flex-start;
}

.user-info {
  display: flex;
  align-items: center;
  flex: 1;
  cursor: pointer;
  width: 90%;
}

.avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  margin-right: 20px;
  border: 3px solid #f0f0f0;
}

.guest-avatar {
  opacity: 0.6;
}

.user-details {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.nickname {
  font-size: 20px;
  font-weight: bold;
  color: #fff;
}

.user-level {
  display: flex;
  align-items: center;
  gap: 10px;
}

.vip-badge {
  background: linear-gradient(45deg, #ffd700, #ffa500);
  color: white;
  font-size: 12px;
  padding: 4px 8px;
  border-radius: 10px;
  font-weight: bold;
}

.normal-badge {
  background: #e9ecef;
  color: #666;
  font-size: 12px;
  padding: 4px 8px;
  border-radius: 10px;
}

.level-text {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.82);
}

.phone {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.82);
}

.login-tip {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.82);
}

.upgrade-vip {
  display: flex;
  align-items: center;
  gap: 8px;
  background: #f59e0b;
  color: white;
  padding: 8px 10px;
  border-radius: 25px;
  cursor: pointer;
  transition: transform 0.3s ease;
}

.upgrade-vip:hover {
  transform: translateY(-2px);
}

.upgrade-text {
  font-size: 14px;
  font-weight: 600;
}

.upgrade-icon {
  font-size: 16px;
}

/* 车型选择卡片 */
.exam-type-card {
  margin: 0 20px 20px;
  background: white;
  border-radius: 15px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.exam-type-card .card-header {
  padding: 20px 20px 10px;
  border-bottom: 1px solid #f0f0f0;
}

.exam-type-card .card-content {
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.exam-type-info {
  display: flex;
  align-items: center;
  flex: 1;
}

.exam-type-text {
  font-size: 14px;
  color: #666;
  margin-right: 10px;
}

.exam-type-value {
  font-size: 16px;
  font-weight: bold;
  color: #333;
}

.change-type-btn {
  background: #0f766e;
  color: white;
  border: none;
  padding: 8px 15px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.change-type-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
}

/* 统计卡片 */
.stats-card {
  margin: 0 20px 20px;
  background: white;
  border-radius: 15px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.card-header {
  padding: 20px 20px 10px;
  border-bottom: 1px solid #f0f0f0;
}

.card-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  padding: 20px;
  gap: 10px;
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
  color: #0f766e;
  margin-bottom: 5px;
}

.stat-label {
  font-size: 12px;
  color: #666;
}

/* 进度卡片 */
.progress-card {
  margin: 0 20px 20px;
  background: white;
  border-radius: 15px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.progress-list {
  padding: 20px;
}

.progress-item {
  margin-bottom: 20px;
}

.progress-item:last-child {
  margin-bottom: 0;
}

.progress-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.subject-name {
  font-size: 16px;
  font-weight: 600;
  color: #333;
}

.progress-text {
  font-size: 12px;
  color: #666;
}

.progress-bar {
  height: 8px;
  background: #f0f0f0;
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #0f766e 0%, #115e59 100%);
  border-radius: 4px;
  transition: width 0.5s ease;
}

/* 菜单卡片 */
.menu-card {
  margin: 0 20px 20px;
  background: white;
  border-radius: 15px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.menu-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  padding: 20px;
  gap: 15px;
}

.menu-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px 15px;
  background: #f8f9fa;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
}

.menu-item:hover {
  background: #e9ecef;
  transform: translateY(-2px);
}

.menu-icon {
  font-size: 28px;
  margin-bottom: 8px;
}

.menu-title {
  font-size: 14px;
  color: #333;
  font-weight: 500;
}

.menu-count {
  position: absolute;
  top: 8px;
  right: 8px;
  background: #ff4444;
  color: white;
  font-size: 10px;
  padding: 2px 6px;
  border-radius: 10px;
  min-width: 16px;
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
  max-width: 400px;
  max-height: 80vh;
  overflow: hidden;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  background: linear-gradient(135deg, #0f766e 0%, #115e59 100%);
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

/* VIP弹窗样式 */
.vip-benefits {
  margin-bottom: 25px;
}

.benefits-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 15px;
  display: block;
}

.benefit-item {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
}

.benefit-icon {
  color: #4caf50;
  font-size: 16px;
  font-weight: bold;
  margin-right: 10px;
  width: 20px;
}

.benefit-text {
  font-size: 14px;
  color: #666;
}

.vip-plans {
  display: flex;
  gap: 15px;
  margin-bottom: 25px;
}

.plan-item {
  flex: 1;
  background: #f8f9fa;
  border-radius: 10px;
  padding: 20px 15px;
  text-align: center;
  position: relative;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 2px solid transparent;
}

.plan-item.recommended {
  background: linear-gradient(135deg, #0f766e 0%, #115e59 100%);
  color: white;
  border-color: #0f766e;
}

.plan-title {
  font-size: 16px;
  font-weight: 600;
  margin-bottom: 10px;
  display: block;
}

.plan-price {
  font-size: 20px;
  font-weight: bold;
  display: block;
}

.discount-badge {
  position: absolute;
  top: -8px;
  right: -8px;
  background: #ff4444;
  color: white;
  font-size: 10px;
  padding: 2px 6px;
  border-radius: 10px;
  font-weight: bold;
}

.vip-btn {
  width: 100%;
  background: linear-gradient(135deg, #0f766e 0%, #115e59 100%);
  color: white;
  border: none;
  padding: 15px;
  border-radius: 10px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.vip-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

/* 设置弹窗样式 */
.setting-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 0;
  border-bottom: 1px solid #f0f0f0;
  cursor: pointer;
}

.setting-item:last-child {
  border-bottom: none;
}

.setting-item.logout {
  color: #ff4444;
  justify-content: center;
  margin-top: 20px;
  border-top: 1px solid #f0f0f0;
  padding-top: 20px;
}

.setting-label {
  font-size: 16px;
  color: #333;
}

.setting-action {
  font-size: 14px;
  color: #0f766e;
  cursor: pointer;
}

.setting-value {
  font-size: 14px;
  color: #666;
}

.logout-card {
  margin: 24rpx 0 40rpx;
}

.logout-btn {
  height: 92rpx;
  line-height: 92rpx;
  text-align: center;
  background: #ffffff;
  color: #e54d42;
  font-size: 30rpx;
  font-weight: 500;
  border-radius: 20rpx;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.04);
}
</style>
