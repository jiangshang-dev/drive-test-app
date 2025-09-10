<script setup lang="ts">
import { ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import {
  postLoginWxMinAPI,
  postLoginWxAppAPI,
  postLoginWxMinSimpleAPI,
  postSendVerifyCodeAPI,
  postVerifyCodeLoginAPI,
} from '@/services/login'
import { useMemberStore } from '@/stores'
import type { LoginResult } from '@/types/member'

const currentType = ref('')
// 获取code登录凭证
let code = ''
onLoad(async () => {
  const res = await wx.login()
  code = res.code
  console.log('uni.getSystemInfoSync().appPlatform==', uni.getSystemInfoSync())
  // 获取设备信息
  uni.getSystemInfo({
    success: function (res) {
      console.log('完整系统信息:', res)
      console.log('完整系统信息 uniPlatform:', res.uniPlatform)
      console.log('完整系统信息:', res.platform)
      console.log('完整系统信息:', res.cpuType)
      console.log('完整系统信息:', res.model)
      console.log('完整系统信息:', res.brand)
      currentType.value = res.uniPlatform
      console.log('currentType===:', currentType)
    },
  })
})

// 短信验证码登录相关状态
const mobile = ref('')
const verifyCode = ref('')
const countdown = ref(0)
let timer: number | null = null

// 获取用户手机号
const onGetPhoneNumber: UniHelper.ButtonOnGetphonenumber = async (ev) => {
  // uni.showToast({
  //   icon: 'none',
  //   title: '功能暂不可用，敬请期待！'
  // })

  // todo 获取用户手机号登录
  const encryptedData = ev.detail!.encryptedData!
  const iv = ev.detail!.iv!
  const codeev = ev.detail!.code!
  const res = await postLoginWxMinAPI({
    code,
    encryptedData,
    iv,
    codeev,
    type: 'drive',
  })
  console.log('res===', res.data?.token)
  loginSuccess(res.data)
}

// 模拟手机号登录
const onGetPhoneNumberSimple = async () => {
  const res = await postLoginWxMinSimpleAPI('13000000000')
  loginSuccess(res.data)
}

// 获取验证码
const handleSendVerifyCode = async () => {
  if (!mobile.value) {
    uni.showToast({
      icon: 'none',
      title: '手机号不能为空',
    })
    return
  }
  if (countdown.value > 0) return

  try {
    await postSendVerifyCodeAPI(mobile.value)
    uni.showToast({
      icon: 'success',
      title: '验证码已发送',
    })
    startCountdown()
  } catch (error) {
    uni.showToast({
      icon: 'error',
      title: '验证码发送失败',
    })
  }
}

// 开始倒计时
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

// 验证码登录
const handleVerifyCodeLogin = async () => {
  if (!mobile.value || !verifyCode.value) {
    uni.showToast({
      icon: 'none',
      title: '请填写手机号和验证码',
    })
    return
  }
  try {
    const res = await postVerifyCodeLoginAPI(mobile.value, verifyCode.value)
    if (res.code == 500) {
      uni.showToast({
        icon: 'error',
        title: res.msg,
      })
      return
    }
    loginSuccess(res.data)
  } catch (error) {
    uni.showToast({
      icon: 'error',
      title: '登录失败',
    })
  }
}

const avatarUrl = ref('')
const nickName = ref('')
const loginSuccess = (profile: LoginResult) => {
  const memberStore = useMemberStore()
  // memberStore.setProfile(profile)

  uni.getUserInfo({
    provider: 'weixin',
    success: function (info) {
      // 获取用户信息成功, info.authResult保存用户信息
      console.log('info====', info.userInfo)
      console.log('info====', info.userInfo.avatarUrl)
      console.log('info====', info.userInfo.nickName)
      profile.avatar = info.userInfo.avatarUrl
      profile.nickname = info.userInfo.nickName
      console.log('profile----', profile)
      memberStore.setProfile(profile)
    },
  })

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
const agreeChecked = ref(false)

const mobileLogin = () => {
  uni.login({
    provider: 'univerify',
    univerifyStyle: {
      fullScreen: true,
    },
  })
}

const wxLogin = async () => {
  let { code, errMsg } = await uni.login({
    provider: 'weixin',
    onlyAuthorize: true, // 微信登录仅请求授权认证
  })

  console.log('code, errMsg:', code, errMsg)
  let res = await postLoginWxAppAPI({
    code,
  })
  console.log('res=======', res)
  loginSuccess(res.data)
}

// 华为账号登录
const huaweiLogin = () => {
  uni.showToast({
    title: '华为账号登录功能开发中',
    icon: 'none',
  })
  // TODO: 集成华为账号登录SDK
}
</script>

<template>
  <view class="login-container">
    <!-- 背景装饰 -->
    <view class="bg-decoration">
      <view class="circle circle-1"></view>
      <view class="circle circle-2"></view>
      <view class="circle circle-3"></view>
    </view>

    <!-- 主要内容 -->
    <view class="content">
      <!-- Logo区域 -->
      <view class="logo-section">
        <image class="app-logo" src="/static/images/logo1.png" mode="aspectFit"></image>
        <text class="app-title">驾考通</text>
        <text class="app-desc">你的驾考学习好帮手</text>
      </view>

      <!-- 登录按钮区域 -->
      <view class="login-section">
        <!-- 微信小程序端：只显示微信登录 -->
        <view v-if="currentType === 'mp-weixin'" class="login-buttons">
          <button
            class="login-btn wechat-btn"
            open-type="getPhoneNumber"
            @getphonenumber="onGetPhoneNumber"
          >
            <text class="btn-icon">🚗</text>
            <view class="btn-content">
              <text class="btn-title">微信一键登录</text>
              <text class="btn-subtitle">快速开始学习之旅</text>
            </view>
          </button>
        </view>

        <!-- App端：显示华为账号和手机号登录 -->
        <view v-else class="login-buttons">
          <button class="login-btn huawei-btn" @click="huaweiLogin">
            <text class="btn-icon">📱</text>
            <view class="btn-content">
              <text class="btn-title">华为账号登录</text>
              <text class="btn-subtitle">安全便捷的登录方式</text>
            </view>
          </button>

          <button class="login-btn phone-btn" @click="mobileLogin">
            <text class="btn-icon">📞</text>
            <view class="btn-content">
              <text class="btn-title">手机号一键登录</text>
              <text class="btn-subtitle">运营商网络安全认证</text>
            </view>
          </button>
        </view>

        <!-- 其他登录方式 -->
        <view class="other-login" v-if="false">
          <view class="divider">
            <text class="divider-text">其他登录方式</text>
          </view>

          <view class="sms-login">
            <view class="input-group">
              <input
                class="phone-input"
                v-model="mobile"
                type="number"
                placeholder="请输入手机号"
                maxlength="11"
              />
            </view>

            <view class="code-group">
              <input
                class="code-input"
                v-model="verifyCode"
                type="number"
                placeholder="验证码"
                maxlength="6"
              />
              <button class="send-code-btn" :disabled="countdown > 0" @tap="handleSendVerifyCode">
                {{ countdown > 0 ? `${countdown}s` : '获取验证码' }}
              </button>
            </view>

            <button class="sms-login-btn" @tap="handleVerifyCodeLogin">登录</button>
          </view>
        </view>
      </view>

      <!-- 底部信息 -->
      <view class="footer">
        <view class="agreement" v-if="false">
          <label class="agreement-check">
            <checkbox :checked="agreeChecked" @tap="agreeChecked = !agreeChecked" />
            <text class="agreement-text">
              我已阅读并同意
              <text class="link">《用户协议》</text>
              和
              <text class="link">《隐私政策》</text>
            </text>
          </label>
        </view>

        <view class="version-info">
          <text class="version-text">Version 1.0.0</text>
        </view>
      </view>
    </view>
  </view>
</template>

<style lang="scss">
page {
  height: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.login-container {
  position: relative;
  height: 100vh;
  overflow: hidden;
}

/* 背景装饰 */
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
  background: rgba(255, 255, 255, 0.1);
  border-radius: 50%;
  animation: float 6s ease-in-out infinite;
}

.circle-1 {
  width: 120px;
  height: 120px;
  top: 10%;
  left: 10%;
  animation-delay: -2s;
}

.circle-2 {
  width: 80px;
  height: 80px;
  top: 20%;
  right: 15%;
  animation-delay: -4s;
}

.circle-3 {
  width: 150px;
  height: 150px;
  bottom: 10%;
  left: 20%;
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

/* 主要内容 */
.content {
  position: relative;
  z-index: 1;
  height: 100%;
  display: flex;
  flex-direction: column;
  padding: 60rpx 40rpx 40rpx;
}

/* Logo区域 */
.logo-section {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  margin-top: -100rpx;
}

.app-logo {
  width: 160rpx;
  height: 160rpx;
  margin-bottom: 30rpx;
  border-radius: 30rpx;
  box-shadow: 0 8rpx 30rpx rgba(0, 0, 0, 0.2);
}

.app-title {
  font-size: 48rpx;
  font-weight: bold;
  color: white;
  margin-bottom: 16rpx;
  text-shadow: 0 2rpx 10rpx rgba(0, 0, 0, 0.3);
}

.app-desc {
  font-size: 28rpx;
  color: rgba(255, 255, 255, 0.9);
  margin-bottom: 60rpx;
}

/* 登录按钮区域 */
.login-section {
  flex-shrink: 0;
}

.login-buttons {
  margin-bottom: 40rpx;
}

.login-btn {
  width: 100%;
  background: rgba(255, 255, 255, 0.95);
  border: none;
  border-radius: 24rpx;
  padding: 32rpx 40rpx;
  margin-bottom: 24rpx;
  display: flex;
  align-items: center;
  box-shadow: 0 8rpx 25rpx rgba(0, 0, 0, 0.15);
  transition: all 0.3s ease;
  backdrop-filter: blur(10px);
}

.login-btn:active {
  transform: translateY(2rpx);
  box-shadow: 0 4rpx 15rpx rgba(0, 0, 0, 0.2);
}

.wechat-btn {
  background: linear-gradient(135deg, #07c160 0%, #06ae56 100%);
}

.wechat-btn .btn-content .btn-title,
.wechat-btn .btn-content .btn-subtitle {
  color: white;
}

.huawei-btn {
  background: linear-gradient(135deg, #ff6b35 0%, #f7931e 100%);
}

.huawei-btn .btn-content .btn-title,
.huawei-btn .btn-content .btn-subtitle {
  color: white;
}

.phone-btn {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.phone-btn .btn-content .btn-title,
.phone-btn .btn-content .btn-subtitle {
  color: white;
}

.btn-icon {
  font-size: 48rpx;
  margin-right: 24rpx;
  filter: drop-shadow(0 2rpx 4rpx rgba(0, 0, 0, 0.2));
}

.btn-content {
  flex: 1;
  text-align: left;
}

.btn-title {
  display: block;
  font-size: 32rpx;
  font-weight: 600;
  color: #333;
  margin-bottom: 4rpx;
}

.btn-subtitle {
  display: block;
  font-size: 22rpx;
  color: #666;
  opacity: 0.8;
}

/* 其他登录方式 */
.other-login {
  margin-top: 40rpx;
}

.divider {
  position: relative;
  text-align: center;
  margin: 40rpx 0;
}

.divider::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 0;
  right: 0;
  height: 1rpx;
  background: rgba(255, 255, 255, 0.3);
}

.divider-text {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: rgba(255, 255, 255, 0.9);
  padding: 0 20rpx;
  font-size: 24rpx;
  position: relative;
}

/* 短信登录 */
.sms-login {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 20rpx;
  padding: 40rpx;
  backdrop-filter: blur(10px);
}

.input-group,
.code-group {
  margin-bottom: 24rpx;
}

.code-group {
  display: flex;
  gap: 16rpx;
}

.phone-input,
.code-input {
  background: rgba(255, 255, 255, 0.9);
  border: none;
  border-radius: 16rpx;
  padding: 24rpx 32rpx;
  font-size: 28rpx;
  color: #333;
}

.phone-input {
  width: 100%;
}

.code-input {
  flex: 1;
}

.send-code-btn {
  background: rgba(255, 255, 255, 0.9);
  border: none;
  border-radius: 16rpx;
  padding: 24rpx 32rpx;
  font-size: 24rpx;
  color: #667eea;
  font-weight: 600;
  white-space: nowrap;
}

.send-code-btn[disabled] {
  background: rgba(255, 255, 255, 0.5);
  color: #999;
}

.sms-login-btn {
  width: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 16rpx;
  padding: 24rpx;
  font-size: 32rpx;
  font-weight: 600;
}

/* 底部信息 */
.footer {
  flex-shrink: 0;
  margin-top: 40rpx;
}

.agreement {
  margin-bottom: 20rpx;
}

.agreement-check {
  display: flex;
  align-items: center;
  justify-content: center;
}

.agreement-text {
  color: rgba(255, 255, 255, 0.8);
  font-size: 22rpx;
  margin-left: 16rpx;
  line-height: 1.5;
}

.link {
  color: rgba(255, 255, 255, 0.9);
  text-decoration: underline;
}

.version-info {
  text-align: center;
}

.version-text {
  color: rgba(255, 255, 255, 0.6);
  font-size: 20rpx;
}

/* 适配小屏幕 */
@media (max-height: 600px) {
  .logo-section {
    margin-top: -50rpx;
  }

  .app-logo {
    width: 120rpx;
    height: 120rpx;
  }

  .app-title {
    font-size: 36rpx;
  }
}
</style>
