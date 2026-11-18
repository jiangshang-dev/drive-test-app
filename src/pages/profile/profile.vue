<script setup lang="ts">
import { computed } from 'vue'
import { useMemberStore } from '@/stores'

const memberStore = useMemberStore()

const profile = computed(() => memberStore.profile)

const isVip = computed(() => {
  return !!profile.value && profile.value.vipLevel !== undefined && profile.value.vipLevel > 0
})

const formatDate = (date: any) => {
  if (!date) return '-'
  const d = new Date(date)
  if (isNaN(d.getTime())) return String(date)
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(
    d.getDate()
  ).padStart(2, '0')}`
}

const handleLogout = () => {
  uni.showModal({
    title: '提示',
    content: '确定退出登录吗？',
    success: (res) => {
      if (!res.confirm) return
      memberStore.clearProfile()
      uni.showToast({ title: '已退出登录', icon: 'none' })
      setTimeout(() => {
        uni.navigateBack()
      }, 500)
    }
  })
}
</script>

<template>
  <view class="profile-page">
    <view v-if="profile" class="profile-card">
      <image
        class="avatar"
        mode="aspectFill"
        :src="profile.avatar || 'https://via.placeholder.com/160x160/667eea/white?text=头像'"
      />
      <text class="nickname">{{ profile.nickname || profile.account || '驾考学员' }}</text>
      <view class="badges">
        <text v-if="isVip" class="vip-badge">VIP会员</text>
        <text v-else class="normal-badge">普通用户</text>
        <text class="level-badge">Lv.{{ profile.level || 1 }}</text>
      </view>
      <text class="integral">积分 {{ profile.integral || 0 }}</text>
    </view>

    <view class="info-card">
      <view class="info-row">
        <text class="info-label">用户名</text>
        <text class="info-value">{{ profile?.account || '-' }}</text>
      </view>
      <view class="info-row">
        <text class="info-label">昵称</text>
        <text class="info-value">{{ profile?.nickname || '-' }}</text>
      </view>
      <view class="info-row">
        <text class="info-label">手机号</text>
        <text class="info-value">{{ profile?.mobile || '未绑定' }}</text>
      </view>
      <view class="info-row">
        <text class="info-label">积分</text>
        <text class="info-value">{{ profile?.integral || 0 }}</text>
      </view>
      <view class="info-row">
        <text class="info-label">会员状态</text>
        <text class="info-value">{{ isVip ? 'VIP会员' : '普通用户' }}</text>
      </view>
      <view v-if="isVip" class="info-row">
        <text class="info-label">会员到期</text>
        <text class="info-value">{{ formatDate(profile?.vipExpireTime) }}</text>
      </view>
    </view>

    <view class="logout-wrap" v-if="profile">
      <view class="logout-btn" @tap="handleLogout">退出登录</view>
    </view>
  </view>
</template>

<style lang="scss">
page {
  background: #f3f6f4;
}

.profile-page {
  padding: 24rpx;
}

.profile-card {
  background: linear-gradient(135deg, #0f766e 0%, #14b8a6 100%);
  border-radius: 24rpx;
  padding: 48rpx 30rpx 36rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  color: #ffffff;
  box-shadow: 0 12rpx 30rpx rgba(15, 118, 110, 0.2);
}

.avatar {
  width: 150rpx;
  height: 150rpx;
  border-radius: 50%;
  border: 4rpx solid rgba(255, 255, 255, 0.6);
  background: #d9e2e8;
}

.nickname {
  margin-top: 20rpx;
  font-size: 38rpx;
  font-weight: 600;
}

.badges {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin-top: 14rpx;
}

.vip-badge,
.normal-badge,
.level-badge {
  font-size: 22rpx;
  padding: 4rpx 16rpx;
  border-radius: 20rpx;
  background: rgba(255, 255, 255, 0.22);
}

.vip-badge {
  background: #f6c344;
  color: #7a4a00;
  font-weight: 600;
}

.integral {
  margin-top: 16rpx;
  font-size: 26rpx;
  opacity: 0.9;
}

.info-card {
  margin-top: 24rpx;
  background: #ffffff;
  border-radius: 20rpx;
  padding: 0 30rpx;
}

.info-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 98rpx;
  border-bottom: 1rpx solid #f0f2f3;
}

.info-row:last-child {
  border-bottom: none;
}

.info-label {
  font-size: 28rpx;
  color: #6b7280;
}

.info-value {
  font-size: 28rpx;
  color: #1f2937;
}

.logout-wrap {
  margin-top: 48rpx;
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
}
</style>
