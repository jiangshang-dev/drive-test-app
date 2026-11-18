<script setup lang="ts">
import { onUnmounted, ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import {
  postLoginWxMinAPI,
  postRegisterAPI,
  postSendVerifyCodeAPI,
  postVerifyCodeLoginAPI,
  postUsernameLoginAPI,
} from '@/services/login'
import { useMemberStore } from '@/stores'
import type { LoginResult } from '@/types/member'

const currentType = ref('')
let wxCode = ''

onLoad(() => {
  uni.getSystemInfo({
    success: (res) => {
      currentType.value = res.uniPlatform
      // 仅微信小程序端才调用 wx.login，H5/App 不支持该方法
      if (res.uniPlatform === 'mp-weixin') {
        wx.login({
          success: (loginRes) => {
            wxCode = loginRes.code
          },
        })
      }
    },
  })
})

// 登录方式：account-账号密码，sms-手机号验证码
const loginTab = ref('account')

// 账号密码登录
const username = ref('')
const password = ref('')
const passwordVisible = ref(false)

// 注册
const showRegister = ref(false)
const regUsername = ref('')
const regMobile = ref('')
const regPassword = ref('')
const regConfirmPassword = ref('')

// 手机验证码登录
const mobile = ref('')
const verifyCode = ref('')
const countdown = ref(0)
let timer: ReturnType<typeof setInterval> | null = null

const agreeChecked = ref(false)

const ensureAgreement = () => {
  if (!agreeChecked.value) {
    uni.showToast({ icon: 'none', title: '请先阅读并同意用户协议和隐私政策' })
    return false
  }
  return true
}

const handleUsernameLogin = async () => {
  if (!username.value.trim() || !password.value) {
    uni.showToast({ icon: 'none', title: '请输入用户名和密码' })
    return
  }
  if (!ensureAgreement()) return
  try {
    const res: any = await postUsernameLoginAPI(username.value.trim(), password.value)
    if (res.code !== 0) {
      uni.showToast({ icon: 'none', title: res.msg || '登录失败' })
      return
    }
    loginSuccess(res.data)
  } catch (e) {
    uni.showToast({ icon: 'none', title: '登录失败，请稍后重试' })
  }
}

const handleRegister = async () => {
  const name = regUsername.value.trim()
  if (name.length < 3 || name.length > 20) {
    uni.showToast({ icon: 'none', title: '用户名长度需在 3-20 个字符之间' })
    return
  }
  if (!regPassword.value || regPassword.value.length < 6) {
    uni.showToast({ icon: 'none', title: '密码长度不能少于 6 位' })
    return
  }
  if (regPassword.value !== regConfirmPassword.value) {
    uni.showToast({ icon: 'none', title: '两次输入的密码不一致' })
    return
  }
  if (regMobile.value && !/^1[3-9]\d{9}$/.test(regMobile.value)) {
    uni.showToast({ icon: 'none', title: '手机号格式不正确' })
    return
  }
  if (!ensureAgreement()) return
  try {
    const res: any = await postRegisterAPI({
      username: name,
      password: regPassword.value,
      confirmPassword: regConfirmPassword.value,
      mobile: regMobile.value || undefined,
    })
    if (res.code !== 0) {
      uni.showToast({ icon: 'none', title: res.msg || '注册失败' })
      return
    }
    uni.showToast({ icon: 'success', title: '注册成功' })
    loginSuccess(res.data)
  } catch (e) {
    uni.showToast({ icon: 'none', title: '注册失败，请稍后重试' })
  }
}

const handleSendVerifyCode = async () => {
  if (!mobile.value) {
    uni.showToast({ icon: 'none', title: '手机号不能为空' })
    return
  }
  if (!/^1[3-9]\d{9}$/.test(mobile.value)) {
    uni.showToast({ icon: 'none', title: '手机号格式不正确' })
    return
  }
  if (countdown.value > 0) return
  try {
    const res: any = await postSendVerifyCodeAPI(mobile.value)
    if (res.code !== 0) {
      uni.showToast({ icon: 'none', title: res.msg || '验证码发送失败' })
      return
    }
    uni.showToast({ icon: 'success', title: '验证码已发送' })
    startCountdown()
  } catch (e) {
    uni.showToast({ icon: 'none', title: '验证码发送失败' })
  }
}

const startCountdown = () => {
  countdown.value = 60
  timer = setInterval(() => {
    countdown.value--
    if (countdown.value <= 0 && timer) {
      clearInterval(timer)
      timer = null
    }
  }, 1000)
}

const handleVerifyCodeLogin = async () => {
  if (!mobile.value || !verifyCode.value) {
    uni.showToast({ icon: 'none', title: '请填写手机号和验证码' })
    return
  }
  if (!ensureAgreement()) return
  try {
    const res: any = await postVerifyCodeLoginAPI(mobile.value, verifyCode.value)
    if (res.code !== 0) {
      uni.showToast({ icon: 'none', title: res.msg || '登录失败' })
      return
    }
    loginSuccess(res.data)
  } catch (e) {
    uni.showToast({ icon: 'none', title: '登录失败，请稍后重试' })
  }
}

// 微信小程序一键登录
const onGetPhoneNumber: UniHelper.ButtonOnGetphonenumber = async (ev) => {
  if (!ensureAgreement()) return
  const encryptedData = ev.detail!.encryptedData!
  const iv = ev.detail!.iv!
  const codeev = ev.detail!.code!
  try {
    const res: any = await postLoginWxMinAPI({
      code: wxCode,
      encryptedData,
      iv,
      codeev,
      type: 'drive',
    })
    if (res.code !== 0) {
      uni.showToast({ icon: 'none', title: res.msg || '登录失败' })
      return
    }
    loginSuccess(res.data)
  } catch (e) {
    uni.showToast({ icon: 'none', title: '登录失败' })
  }
}

const loginSuccess = (profile: LoginResult) => {
  const memberStore = useMemberStore()
  if (!profile.nickname) {
    profile.nickname = profile.account || '驾考用户'
  }
  memberStore.setProfile(profile)
  uni.showToast({
    icon: 'success',
    title: '登录成功',
  })
  setTimeout(() => {
    uni.switchTab({
      url: '/pages/my/my',
    })
  }, 500)
}

onUnmounted(() => {
  if (timer) {
    clearInterval(timer)
    timer = null
  }
})
</script>

<template>
  <view class="login-container">
    <view class="bg-decoration">
      <view class="circle circle-1"></view>
      <view class="circle circle-2"></view>
      <view class="circle circle-3"></view>
    </view>

    <view class="content">
      <view class="logo-section">
        <image class="app-logo" src="/static/images/logo1.png" mode="aspectFit"></image>
        <text class="app-title">驾考通</text>
        <text class="app-desc">你的驾考学习好帮手</text>
      </view>

      <view class="login-card">
        <!-- 注册 -->
        <template v-if="showRegister">
          <view class="register-header">
            <text class="register-title">创建账号</text>
            <text class="register-sub">注册后可使用账号密码登录</text>
          </view>
          <view class="login-form">
            <view class="input-item">
              <text class="input-icon">👤</text>
              <input
                class="input-control"
                v-model="regUsername"
                :maxlength="20"
                placeholder="用户名（3-20个字符）"
                placeholder-class="input-placeholder"
              />
            </view>
            <view class="input-item">
              <text class="input-icon">📱</text>
              <input
                class="input-control"
                v-model="regMobile"
                type="number"
                :maxlength="11"
                placeholder="手机号（选填）"
                placeholder-class="input-placeholder"
              />
            </view>
            <view class="input-item">
              <text class="input-icon">🔒</text>
              <input
                class="input-control"
                v-model="regPassword"
                :password="!passwordVisible"
                placeholder="密码（至少6位）"
                placeholder-class="input-placeholder"
              />
              <text class="eye-icon" @tap="passwordVisible = !passwordVisible">
                {{ passwordVisible ? '🙈' : '👁️' }}
              </text>
            </view>
            <view class="input-item">
              <text class="input-icon">🔒</text>
              <input
                class="input-control"
                v-model="regConfirmPassword"
                :password="!passwordVisible"
                placeholder="确认密码"
                placeholder-class="input-placeholder"
                @confirm="handleRegister"
              />
            </view>
            <button class="login-submit" :disabled="!regUsername || !regPassword" @tap="handleRegister">
              注 册
            </button>
            <view class="register-back" @tap="showRegister = false">已有账号？返回登录</view>
          </view>

          <view class="agreement">
            <label class="agreement-check" @tap="agreeChecked = !agreeChecked">
              <view class="checkbox" :class="{ checked: agreeChecked }">
                <text v-if="agreeChecked" class="checkbox-mark">✓</text>
              </view>
              <text class="agreement-text">
                我已阅读并同意
                <text class="link">《用户协议》</text>
                和
                <text class="link">《隐私政策》</text>
              </text>
            </label>
          </view>
        </template>

        <template v-else>
        <view class="login-tabs">
          <view
            class="login-tab"
            :class="{ active: loginTab === 'account' }"
            @tap="loginTab = 'account'"
          >
            账号密码登录
          </view>
          <view
            class="login-tab"
            :class="{ active: loginTab === 'sms' }"
            @tap="loginTab = 'sms'"
          >
            手机号验证码登录
          </view>
        </view>

        <!-- 账号密码登录 -->
        <view v-if="loginTab === 'account'" class="login-form">
          <view class="input-item">
            <text class="input-icon">👤</text>
            <input
              class="input-control"
              v-model="username"
              placeholder="请输入用户名或手机号"
              placeholder-class="input-placeholder"
            />
          </view>
          <view class="input-item">
            <text class="input-icon">🔒</text>
            <input
              class="input-control"
              v-model="password"
              :password="!passwordVisible"
              placeholder="请输入密码"
              placeholder-class="input-placeholder"
              @confirm="handleUsernameLogin"
            />
            <text class="eye-icon" @tap="passwordVisible = !passwordVisible">
              {{ passwordVisible ? '🙈' : '👁️' }}
            </text>
          </view>
          <button class="login-submit" :disabled="!username || !password" @tap="handleUsernameLogin">
            登 录
          </button>
          <view class="register-entry" @tap="showRegister = true">
            <text>还没有账号？</text>
            <text class="link">立即注册</text>
          </view>
        </view>

        <!-- 手机号验证码登录 -->
        <view v-else class="login-form">
          <view class="input-item">
            <text class="input-icon">📱</text>
            <input
              class="input-control"
              v-model="mobile"
              type="number"
              :maxlength="11"
              placeholder="请输入手机号"
              placeholder-class="input-placeholder"
            />
          </view>
          <view class="input-item">
            <text class="input-icon">🔑</text>
            <input
              class="input-control"
              v-model="verifyCode"
              type="number"
              :maxlength="6"
              placeholder="请输入验证码"
              placeholder-class="input-placeholder"
              @confirm="handleVerifyCodeLogin"
            />
            <view class="send-code" :class="{ disabled: countdown > 0 }" @tap="handleSendVerifyCode">
              {{ countdown > 0 ? `${countdown}s` : '获取验证码' }}
            </view>
          </view>
          <button class="login-submit" :disabled="!mobile || !verifyCode" @tap="handleVerifyCodeLogin">
            登 录
          </button>
          <text class="login-tip">未注册的手机号验证后将自动创建账号</text>
        </view>

        <!-- 微信小程序一键登录 -->
        <view v-if="currentType === 'mp-weixin'" class="other-login">
          <view class="divider">
            <view class="divider-line"></view>
            <text class="divider-text">其他登录方式</text>
            <view class="divider-line"></view>
          </view>
          <button
            class="wechat-login-btn"
            open-type="getPhoneNumber"
            @getphonenumber="onGetPhoneNumber"
          >
            <text class="wechat-icon">🚗</text>
            <text>微信一键登录</text>
          </button>
        </view>

        <view class="agreement">
          <label class="agreement-check" @tap="agreeChecked = !agreeChecked">
            <view class="checkbox" :class="{ checked: agreeChecked }">
              <text v-if="agreeChecked" class="checkbox-mark">✓</text>
            </view>
            <text class="agreement-text">
              我已阅读并同意
              <text class="link">《用户协议》</text>
              和
              <text class="link">《隐私政策》</text>
            </text>
          </label>
        </view>
        </template>
      </view>

      <view class="footer">
        <text class="version-text">Version 1.0.0</text>
      </view>
    </view>
  </view>
</template>

<style lang="scss">
page {
  height: 100%;
  background: linear-gradient(160deg, #0f766e 0%, #0b4f4a 100%);
}

.login-container {
  position: relative;
  height: 100vh;
  overflow: hidden;
}

.bg-decoration {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 0;
}

.circle {
  position: absolute;
  background: rgba(255, 255, 255, 0.08);
  border-radius: 50%;
  animation: float 8s ease-in-out infinite;
}

.circle-1 {
  width: 260rpx;
  height: 260rpx;
  top: -60rpx;
  right: -60rpx;
  animation-delay: -2s;
}

.circle-2 {
  width: 160rpx;
  height: 160rpx;
  top: 26%;
  left: -50rpx;
  animation-delay: -4s;
}

.circle-3 {
  width: 220rpx;
  height: 220rpx;
  bottom: -80rpx;
  left: 30%;
  animation-delay: -1s;
}

@keyframes float {
  0%,
  100% {
    transform: translateY(0px) rotate(0deg);
    opacity: 0.7;
  }
  50% {
    transform: translateY(-20px) rotate(180deg);
    opacity: 0.3;
  }
}

.content {
  position: relative;
  z-index: 1;
  height: 100%;
  display: flex;
  flex-direction: column;
  padding: 70rpx 44rpx 40rpx;
  box-sizing: border-box;
}

.logo-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  padding: 20rpx 0 40rpx;
}

.app-logo {
  width: 150rpx;
  height: 150rpx;
  margin-bottom: 24rpx;
  border-radius: 32rpx;
  box-shadow: 0 10rpx 40rpx rgba(0, 0, 0, 0.25);
}

.app-title {
  font-size: 46rpx;
  font-weight: bold;
  color: #ffffff;
  margin-bottom: 10rpx;
  letter-spacing: 2rpx;
}

.app-desc {
  font-size: 26rpx;
  color: rgba(255, 255, 255, 0.85);
}

.login-card {
  background: rgba(255, 255, 255, 0.98);
  border-radius: 32rpx;
  padding: 36rpx 34rpx 28rpx;
  box-shadow: 0 20rpx 60rpx rgba(0, 0, 0, 0.25);
}

.login-tabs {
  display: flex;
  background: #f2f4f5;
  border-radius: 20rpx;
  padding: 6rpx;
  margin-bottom: 34rpx;
}

.login-tab {
  flex: 1;
  text-align: center;
  font-size: 26rpx;
  color: #6b7280;
  padding: 16rpx 0;
  border-radius: 16rpx;
  transition: all 0.2s ease;
}

.login-tab.active {
  background: #ffffff;
  color: #0f766e;
  font-weight: 600;
  box-shadow: 0 4rpx 12rpx rgba(15, 118, 110, 0.15);
}

.login-form {
  display: flex;
  flex-direction: column;
}

.input-item {
  display: flex;
  align-items: center;
  background: #f7f9fa;
  border: 1rpx solid #e8edf0;
  border-radius: 18rpx;
  padding: 0 24rpx;
  height: 96rpx;
  margin-bottom: 24rpx;
}

.input-icon {
  font-size: 30rpx;
  margin-right: 16rpx;
}

.input-control {
  flex: 1;
  font-size: 28rpx;
  color: #1f2937;
  height: 96rpx;
}

.input-placeholder {
  color: #9aa4af;
}

.eye-icon {
  font-size: 30rpx;
  padding-left: 12rpx;
}

.send-code {
  font-size: 25rpx;
  color: #0f766e;
  font-weight: 600;
  padding-left: 16rpx;
  white-space: nowrap;
}

.send-code.disabled {
  color: #9aa4af;
}

.login-submit {
  width: 100%;
  height: 96rpx;
  line-height: 96rpx;
  margin-top: 8rpx;
  background: linear-gradient(135deg, #0f766e 0%, #14b8a6 100%);
  color: #ffffff;
  font-size: 32rpx;
  font-weight: 600;
  border-radius: 18rpx;
  border: none;
  box-shadow: 0 10rpx 24rpx rgba(15, 118, 110, 0.25);
}

.login-submit[disabled] {
  opacity: 0.55;
  box-shadow: none;
}

.login-tip {
  margin-top: 18rpx;
  font-size: 22rpx;
  color: #9aa4af;
  text-align: center;
}

.register-entry {
  margin-top: 22rpx;
  text-align: center;
  font-size: 24rpx;
  color: #7b858f;
}

.register-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 30rpx;
}

.register-title {
  font-size: 36rpx;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 8rpx;
}

.register-sub {
  font-size: 24rpx;
  color: #9aa4af;
}

.register-back {
  margin-top: 24rpx;
  text-align: center;
  font-size: 24rpx;
  color: #0f766e;
}

.other-login {
  margin-top: 30rpx;
}

.divider {
  display: flex;
  align-items: center;
  margin-bottom: 24rpx;
}

.divider-line {
  flex: 1;
  height: 1rpx;
  background: #eceff1;
}

.divider-text {
  font-size: 22rpx;
  color: #9aa4af;
  padding: 0 18rpx;
}

.wechat-login-btn {
  width: 100%;
  height: 88rpx;
  line-height: 88rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #07c160;
  color: #ffffff;
  font-size: 28rpx;
  font-weight: 600;
  border-radius: 18rpx;
  border: none;
}

.wechat-icon {
  margin-right: 12rpx;
  font-size: 32rpx;
}

.agreement {
  margin-top: 28rpx;
}

.agreement-check {
  display: flex;
  align-items: flex-start;
  justify-content: center;
}

.checkbox {
  width: 30rpx;
  height: 30rpx;
  border: 2rpx solid #c4ccd3;
  border-radius: 8rpx;
  margin-right: 12rpx;
  margin-top: 2rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.checkbox.checked {
  background: #0f766e;
  border-color: #0f766e;
}

.checkbox-mark {
  color: #ffffff;
  font-size: 20rpx;
  line-height: 1;
}

.agreement-text {
  color: #7b858f;
  font-size: 22rpx;
  line-height: 1.5;
}

.link {
  color: #0f766e;
}

.footer {
  margin-top: auto;
  text-align: center;
  padding-top: 30rpx;
}

.version-text {
  color: rgba(255, 255, 255, 0.6);
  font-size: 20rpx;
}
</style>
