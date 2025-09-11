<template>
  <view class="container">

    <!-- 会员状态卡片 -->
    <view class="member-status-card">
      <view class="status-header">
        <view class="member-info">
          <text class="member-icon">👑</text>
          <view class="member-details">
            <text class="member-title">{{ memberStatus.isVip ? 'VIP会员' : '普通用户' }}</text>
            <text class="member-desc">{{ memberStatus.description }}</text>
          </view>
        </view>
        <view v-if="memberStatus.isVip" class="member-badge">
          <text class="badge-text">VIP</text>
        </view>
      </view>

      <!-- VIP到期时间 -->
      <view v-if="memberStatus.isVip" class="member-expiry">
        <text class="expiry-label">有效期至：</text>
        <text class="expiry-date">{{ memberStatus.expiryDate }}</text>
        <text class="remaining-days">（剩余{{ memberStatus.remainingDays }}天）</text>
      </view>

      <!-- 会员权益进度 -->
      <view class="member-progress">
        <view class="progress-item">
          <text class="progress-label">本月已享受VIP权益</text>
          <view class="progress-bar">
            <view class="progress-fill" :style="{ width: memberProgress.percentage + '%' }"></view>
          </view>
          <text class="progress-text">{{ memberProgress.used }}/{{ memberProgress.total }}</text>
        </view>
      </view>
    </view>

    <!-- VIP特权展示 -->
    <view class="privileges-section">
      <text class="section-title">VIP专享特权</text>
      <view class="privileges-grid">
        <view
          v-for="(privilege, index) in vipPrivileges"
          :key="index"
          class="privilege-item"
          :class="{ unlocked: memberStatus.isVip }"
        >
          <text class="privilege-icon">{{ privilege.icon }}</text>
          <text class="privilege-title">{{ privilege.title }}</text>
          <text class="privilege-desc">{{ privilege.description }}</text>
          <view class="privilege-status">
            <text v-if="memberStatus.isVip" class="status-unlocked">已解锁</text>
            <text v-else class="status-locked">🔒</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 会员套餐推荐 -->
    <view v-if="!memberStatus.isVip" class="plans-section">
      <text class="section-title">开通VIP会员</text>
      <view class="plans-list">
        <view
          v-for="(plan, index) in memberPlans"
          :key="index"
          class="plan-card"
          :class="{ recommended: plan.recommended }"
          @click="selectPlan(plan)"
        >
          <view v-if="plan.recommended" class="plan-badge">推荐</view>
          <text class="plan-title">{{ plan.title }}</text>
          <view class="plan-price">
            <text class="price-symbol">¥</text>
            <text class="price-amount">{{ plan.price }}</text>
            <text class="price-unit">{{ plan.unit }}</text>
          </view>
          <view v-if="plan.originalPrice" class="plan-original">
            <text class="original-price">原价¥{{ plan.originalPrice }}</text>
            <text class="discount">省¥{{ plan.originalPrice - plan.price }}</text>
          </view>
        </view>
      </view>
      <button class="upgrade-btn" @click="goToVipPage">
        立即开通VIP
      </button>
    </view>

    <!-- 会员续费 -->
    <view v-else-if="memberStatus.remainingDays <= 7" class="renewal-section">
      <text class="section-title">会员即将到期</text>
      <view class="renewal-card">
        <text class="renewal-icon">⏰</text>
        <view class="renewal-content">
          <text class="renewal-title">您的VIP会员即将到期</text>
          <text class="renewal-desc">续费享受不间断的VIP特权</text>
        </view>
        <button class="renewal-btn" @click="goToVipPage">
          立即续费
        </button>
      </view>
    </view>

    <!-- 会员记录 -->
    <view class="records-section">
      <text class="section-title">会员记录</text>
      <view class="records-list">
        <view
          v-for="(record, index) in memberRecords"
          :key="index"
          class="record-item"
        >
          <view class="record-icon">
            <text class="icon">{{ record.icon }}</text>
          </view>
          <view class="record-content">
            <text class="record-title">{{ record.title }}</text>
            <text class="record-desc">{{ record.description }}</text>
            <text class="record-time">{{ formatDate(record.time) }}</text>
          </view>
          <text class="record-status" :class="record.status">
            {{ record.statusText }}
          </text>
        </view>
      </view>

      <!-- 空状态 -->
      <view v-if="memberRecords.length === 0" class="empty-records">
        <text class="empty-icon">📋</text>
        <text class="empty-text">暂无会员记录</text>
      </view>
    </view>

    <!-- 客服联系 -->
    <view class="contact-section">
      <view class="contact-item" @click="contactService">
        <text class="contact-icon">💬</text>
        <text class="contact-text">遇到问题？联系客服</text>
        <text class="contact-arrow">›</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'

// 会员状态
const memberStatus = ref({
  isVip: false,
  description: '开通VIP享受更多特权',
  expiryDate: '',
  remainingDays: 0
})

// 会员进度
const memberProgress = ref({
  used: 25,
  total: 100,
  percentage: 25
})

// VIP特权列表
const vipPrivileges = ref([
  {
    icon: '🎬',
    title: '全部视频解锁',
    description: '观看所有交规视频教程'
  },
  {
    icon: '📚',
    title: '题库完整开放',
    description: '刷遍所有驾考题目'
  },
  {
    icon: '🚫',
    title: '无广告体验',
    description: '享受纯净学习环境'
  },
  {
    icon: '📊',
    title: '学习数据分析',
    description: '详细掌握学习进度'
  },
  {
    icon: '💾',
    title: '离线下载',
    description: '支持视频离线缓存'
  },
  {
    icon: '🎯',
    title: '专属学习计划',
    description: '个性化学习路径'
  }
])

// 会员套餐
const memberPlans = ref([
  {
    title: '月度会员',
    price: 39,
    unit: '/月',
    originalPrice: null,
    recommended: false
  },
  {
    title: '季度会员',
    price: 89,
    unit: '/3个月',
    originalPrice: 117,
    recommended: true
  },
  {
    title: '年度会员',
    price: 299,
    unit: '/年',
    originalPrice: 468,
    recommended: false
  }
])

// 会员记录
const memberRecords = ref([
  {
    icon: '👑',
    title: 'VIP会员开通',
    description: '季度会员 - 3个月',
    time: new Date('2024-01-15'),
    status: 'success',
    statusText: '已生效'
  },
  {
    icon: '💰',
    title: '支付成功',
    description: '微信支付 ¥89.00',
    time: new Date('2024-01-15'),
    status: 'success',
    statusText: '已完成'
  }
])

// 计算属性
const isVipActive = computed(() => {
  return memberStatus.value.isVip && memberStatus.value.remainingDays > 0
})

// 方法
const goBack = () => {
  uni.navigateBack()
}

const selectPlan = (plan: any) => {
  console.log('选择套餐:', plan)
}

const goToVipPage = () => {
  uni.navigateTo({
    url: '/pages/vip/vip'
  })
}

const contactService = () => {
  uni.showModal({
    title: '联系客服',
    content: '客服工作时间：9:00-18:00\n我们会尽快为您解答问题',
    confirmText: '我知道了',
    showCancel: false
  })
}

const formatDate = (date: Date) => {
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// 模拟检查会员状态
const checkMemberStatus = () => {
  // 这里应该从服务器获取真实的会员状态
  const hasVip = false // 可以根据实际情况修改

  if (hasVip) {
    memberStatus.value = {
      isVip: true,
      description: '感谢您成为VIP会员',
      expiryDate: '2024-04-15',
      remainingDays: 30
    }

    memberProgress.value = {
      used: 75,
      total: 100,
      percentage: 75
    }
  }
}

onMounted(() => {
  checkMemberStatus()
  console.log('会员中心页面加载完成')
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
}

.back-btn {
  font-size: 24px;
  font-weight: bold;
  cursor: pointer;
  width: 30px;
}

.logo {
  font-size: 18px;
  font-weight: bold;
  flex: 1;
  text-align: center;
}

.header-right {
  width: 30px;
}

/* 会员状态卡片 */
.member-status-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  margin: 20px 20px 20px;
  border-radius: 20px;
  padding: 25px;
  color: white;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.status-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.member-info {
  display: flex;
  align-items: center;
  gap: 15px;
}

.member-icon {
  font-size: 40px;
}

.member-details {
  display: flex;
  flex-direction: column;
}

.member-title {
  font-size: 20px;
  font-weight: bold;
  margin-bottom: 4px;
}

.member-desc {
  font-size: 14px;
  opacity: 0.9;
}

.member-badge {
  background: rgba(255, 255, 255, 0.2);
  padding: 8px 16px;
  border-radius: 20px;
}

.badge-text {
  font-size: 14px;
  font-weight: bold;
}

.member-expiry {
  background: rgba(255, 255, 255, 0.1);
  padding: 15px;
  border-radius: 12px;
  margin-bottom: 20px;
}

.expiry-label {
  font-size: 14px;
  opacity: 0.9;
}

.expiry-date {
  font-size: 16px;
  font-weight: bold;
  margin-left: 5px;
}

.remaining-days {
  font-size: 12px;
  opacity: 0.8;
  margin-left: 5px;
}

.member-progress {
  background: rgba(255, 255, 255, 0.1);
  padding: 15px;
  border-radius: 12px;
}

.progress-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.progress-label {
  font-size: 14px;
  opacity: 0.9;
}

.progress-bar {
  height: 8px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: rgba(255, 255, 255, 0.8);
  border-radius: 4px;
  transition: width 0.5s ease;
}

.progress-text {
  font-size: 12px;
  opacity: 0.8;
  text-align: right;
}

/* 特权展示 */
.privileges-section {
  background: white;
  margin: 0 20px 20px;
  border-radius: 20px;
  padding: 25px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.section-title {
  font-size: 18px;
  font-weight: bold;
  color: #333;
  margin-bottom: 20px;
  display: block;
}

.privileges-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 15px;
}

.privilege-item {
  background: #f8f9fa;
  padding: 20px 15px;
  border-radius: 12px;
  text-align: center;
  position: relative;
  transition: all 0.3s ease;
}

.privilege-item.unlocked {
  background: linear-gradient(135deg, #f8f9ff 0%, #fff 100%);
  border: 2px solid #667eea;
}

.privilege-icon {
  font-size: 28px;
  display: block;
  margin-bottom: 10px;
}

.privilege-title {
  font-size: 14px;
  font-weight: bold;
  color: #333;
  margin-bottom: 4px;
  display: block;
}

.privilege-desc {
  font-size: 12px;
  color: #666;
  line-height: 1.4;
  display: block;
  margin-bottom: 10px;
}

.privilege-status {
  position: absolute;
  top: 8px;
  right: 8px;
}

.status-unlocked {
  background: #4caf50;
  color: white;
  font-size: 10px;
  padding: 3px 6px;
  border-radius: 8px;
  font-weight: bold;
}

.status-locked {
  font-size: 14px;
  opacity: 0.5;
}

/* 套餐推荐 */
.plans-section {
  background: white;
  margin: 0 20px 20px;
  border-radius: 20px;
  padding: 25px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.plans-list {
  display: flex;
  gap: 15px;
  margin-bottom: 25px;
}

.plan-card {
  flex: 1;
  background: #f8f9fa;
  border-radius: 15px;
  padding: 20px 15px;
  text-align: center;
  position: relative;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 2px solid transparent;
}

.plan-card.recommended {
  background: linear-gradient(135deg, #f8f9ff 0%, #fff 100%);
  border-color: #667eea;
  transform: translateY(-5px);
}

.plan-badge {
  position: absolute;
  top: -8px;
  right: 10px;
  background: #ff4444;
  color: white;
  font-size: 10px;
  padding: 4px 8px;
  border-radius: 8px;
  font-weight: bold;
}

.plan-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 10px;
  display: block;
}

.plan-price {
  display: flex;
  align-items: baseline;
  justify-content: center;
  margin-bottom: 8px;
}

.price-symbol {
  font-size: 14px;
  color: #667eea;
  font-weight: bold;
}

.price-amount {
  font-size: 24px;
  font-weight: bold;
  color: #667eea;
  margin: 0 2px;
}

.price-unit {
  font-size: 12px;
  color: #999;
}

.plan-original {
  display: flex;
  justify-content: center;
  gap: 8px;
}

.original-price {
  font-size: 11px;
  color: #999;
  text-decoration: line-through;
}

.discount {
  font-size: 11px;
  color: #ff6b6b;
  font-weight: bold;
}

.upgrade-btn {
  width: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 25px;
  padding: 16px;
  font-size: 16px;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
}

.upgrade-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.4);
}

/* 续费提醒 */
.renewal-section {
  background: white;
  margin: 0 20px 20px;
  border-radius: 20px;
  padding: 25px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.renewal-card {
  display: flex;
  align-items: center;
  gap: 15px;
  background: linear-gradient(135deg, #fff3cd 0%, #ffeaa7 100%);
  padding: 20px;
  border-radius: 12px;
  border-left: 4px solid #ffa500;
}

.renewal-icon {
  font-size: 28px;
}

.renewal-content {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.renewal-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 4px;
}

.renewal-desc {
  font-size: 13px;
  color: #666;
}

.renewal-btn {
  background: #ffa500;
  color: white;
  border: none;
  border-radius: 20px;
  padding: 10px 20px;
  font-size: 14px;
  font-weight: bold;
  cursor: pointer;
}

/* 会员记录 */
.records-section {
  background: white;
  margin: 0 20px 20px;
  border-radius: 20px;
  padding: 25px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.records-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.record-item {
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 12px;
}

.record-icon {
  width: 50px;
  height: 50px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 25px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.icon {
  font-size: 24px;
  color: white;
}

.record-content {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.record-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 4px;
}

.record-desc {
  font-size: 13px;
  color: #666;
  margin-bottom: 2px;
}

.record-time {
  font-size: 12px;
  color: #999;
}

.record-status {
  font-size: 12px;
  padding: 4px 8px;
  border-radius: 8px;
  font-weight: bold;
}

.record-status.success {
  background: #e8f5e8;
  color: #4caf50;
}

.record-status.pending {
  background: #fff3cd;
  color: #ffa500;
}

.record-status.failed {
  background: #f8d7da;
  color: #dc3545;
}

/* 空状态 */
.empty-records {
  text-align: center;
  padding: 40px 20px;
  color: #999;
}

.empty-icon {
  font-size: 48px;
  display: block;
  margin-bottom: 15px;
}

.empty-text {
  font-size: 14px;
}

/* 客服联系 */
.contact-section {
  background: white;
  margin: 0 20px 20px;
  border-radius: 20px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.contact-item {
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 20px 25px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.contact-item:hover {
  background: #f8f9fa;
}

.contact-icon {
  font-size: 24px;
  color: #667eea;
}

.contact-text {
  flex: 1;
  font-size: 16px;
  color: #333;
}

.contact-arrow {
  font-size: 20px;
  color: #999;
  font-weight: bold;
}
</style>
