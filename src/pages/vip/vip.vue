<template>
  <view class="container">
    <!-- VIP特权展示 -->
    <view class="vip-hero">
      <view class="hero-content">
        <text class="hero-icon">👑</text>
        <text class="hero-title">尊享VIP特权</text>
        <text class="hero-subtitle">解锁全部驾考学习资源</text>
      </view>
    </view>

    <!-- 特权列表 -->
    <view class="privileges-section">
      <text class="section-title">VIP专享特权</text>
      <view class="privileges-list">
        <view v-for="(privilege, index) in vipPrivileges" :key="index" class="privilege-item">
          <view class="privilege-icon">
            <text class="icon">{{ privilege.icon }}</text>
          </view>
          <view class="privilege-content">
            <text class="privilege-title">{{ privilege.title }}</text>
            <text class="privilege-desc">{{ privilege.description }}</text>
          </view>
          <text class="privilege-tag">VIP</text>
        </view>
      </view>
    </view>

    <!-- 套餐选择 -->
    <view class="plans-section" v-if="false">
      <text class="section-title">选择套餐</text>
      <view class="plans-list">
        <view
          v-for="(plan, index) in vipPlans"
          :key="index"
          class="plan-card"
          :class="{ active: selectedPlan === index }"
          @click="selectPlan(index)"
        >
          <view v-if="plan.recommended" class="plan-badge">推荐</view>
          <view class="plan-header">
            <text class="plan-title">{{ plan.title }}</text>
            <text class="plan-subtitle">{{ plan.subtitle }}</text>
          </view>
          <view class="plan-price">
            <text class="price-symbol">¥</text>
            <text class="price-amount">{{ plan.price }}</text>
            <text class="price-unit">{{ plan.unit }}</text>
          </view>
          <view v-if="plan.originalPrice" class="plan-original">
            <text class="original-price">原价¥{{ plan.originalPrice }}</text>
            <text class="discount">省¥{{ plan.originalPrice - plan.price }}</text>
          </view>
          <view class="plan-features">
            <view v-for="(feature, fIndex) in plan.features" :key="fIndex" class="feature-item">
              <text class="feature-icon">✓</text>
              <text class="feature-text">{{ feature }}</text>
            </view>
          </view>
        </view>
      </view>
    </view>

    <!-- 用户协议 -->
    <view class="agreement-section">
      <view class="agreement-item" @click="toggleAgreement">
        <text class="checkbox" :class="{ checked: agreedToTerms }">
          {{ agreedToTerms ? '☑' : '☐' }}
        </text>
        <text class="agreement-text">
          我已阅读并同意
          <text class="link" @click.stop="showUserAgreement">《用户协议》</text>
          和
          <text class="link" @click.stop="showPrivacyPolicy">《隐私政策》</text>
        </text>
      </view>
    </view>

    <!-- 立即开通按钮 -->
    <view class="action-section">
      <!-- <button
        class="purchase-btn"
        :disabled="!agreedToTerms"
        @click="proceedToPurchase"
      >
        立即开通 ¥{{ selectedPlanInfo.price }}
      </button> -->

      <button class="purchase-btn" :disabled="!agreedToTerms" @click="watchAdForVip">
        立即看视频开通会员
      </button>
      <text class="purchase-note">开通后立即生效，支持7天无理由退款</text>
    </view>

    <!-- 用户协议弹窗 -->
    <view v-if="showAgreementModal" class="modal" @click="closeAgreementModal">
      <view class="modal-content" @click.stop>
        <view class="modal-header">
          <text class="modal-title">{{ agreementTitle }}</text>
          <text class="close-btn" @click="closeAgreementModal">&times;</text>
        </view>
        <view class="modal-body">
          <text class="agreement-content">{{ agreementContent }}</text>
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
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useMemberStore } from '@/stores'
import { http } from '@/utils/http'

// 获取会员信息
const memberStore = useMemberStore()

// 数据状态
const selectedPlan = ref(1) // 默认选择中等套餐
const agreedToTerms = ref(false)
const showAgreementModal = ref(false)
const agreementTitle = ref('')
const agreementContent = ref('')

// VIP特权数据
const vipPrivileges = ref([
  {
    icon: '🎬',
    title: '全部视频解锁',
    description: '观看所有交规视频教程，无限制学习',
  },
  {
    icon: '📚',
    title: '题库全开放',
    description: '刷遍所有题目，包含最新题库更新',
  },
  {
    icon: '🏆',
    title: '专属学习计划',
    description: '个性化学习路径，提高通过率',
  },
  {
    icon: '📊',
    title: '详细学习报告',
    description: '深度数据分析，了解学习进度',
  },
  {
    icon: '🚫',
    title: '无广告体验',
    description: '享受纯净学习环境，专注备考',
  },
  {
    icon: '💾',
    title: '离线下载',
    description: '支持视频离线缓存，随时随地学习',
  },
])

// VIP套餐数据
const vipPlans = ref([
  {
    title: '月度会员',
    subtitle: '体验VIP特权',
    price: 39,
    unit: '/月',
    originalPrice: null,
    recommended: false,
    features: ['30天VIP特权', '全部视频解锁', '题库完整开放', '无广告体验'],
  },
  {
    title: '季度会员',
    subtitle: '最受欢迎',
    price: 89,
    unit: '/3个月',
    originalPrice: 117,
    recommended: true,
    features: ['90天VIP特权', '全部功能解锁', '专属学习计划', '优先客服支持', '学习报告分析'],
  },
  {
    title: '年度会员',
    subtitle: '超值划算',
    price: 299,
    unit: '/年',
    originalPrice: 468,
    recommended: false,
    features: ['365天VIP特权', '所有功能无限制', '离线下载功能', '一对一指导', '终身更新保障'],
  },
])

const rewardedAd = ref(null)
const watchAdForVip = () => {
  if (!checkLogin()) return

  if (rewardedAd.value) {
    // @ts-ignore
    rewardedAd.value.show()
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

// 计算属性
const selectedPlanInfo = computed(() => {
  return vipPlans.value[selectedPlan.value] || vipPlans.value[0]
})

// 方法
const selectPlan = (index: number) => {
  selectedPlan.value = index
}

const toggleAgreement = () => {
  agreedToTerms.value = !agreedToTerms.value
}

const showUserAgreement = () => {
  agreementTitle.value = '用户协议'
  agreementContent.value = `
1. 服务说明
本服务为驾考学习辅助服务，用户通过购买VIP会员可享受更多学习资源和功能。

2. 用户权利
- 使用VIP期间享受所有特权功能
- 7天无理由退款保障
- 技术支持和客服服务

3. 用户义务
- 遵守平台使用规范
- 不得恶意刷题或作弊
- 保护账号安全

4. 服务期限
VIP会员自开通之日起生效，到期后自动失效，不自动续费。

5. 退款政策
开通后7天内如不满意可申请全额退款。

6. 免责声明
本服务仅为学习辅助工具，不保证考试通过率。
  `
  showAgreementModal.value = true
}

const showPrivacyPolicy = () => {
  agreementTitle.value = '隐私政策'
  agreementContent.value = `
1. 信息收集
我们收集您提供的基本信息，如手机号、学习记录等，用于提供更好的服务。

2. 信息使用
- 提供个性化学习服务
- 统计分析和产品改进
- 客服支持和问题解决

3. 信息保护
- 采用加密技术保护用户数据
- 严格控制数据访问权限
- 不会向第三方出售用户信息

4. 信息共享
除法律要求外，不会与第三方分享您的个人信息。

5. 用户权利
您有权查看、修改或删除个人信息。

6. 联系我们
如有隐私相关问题，请联系客服。
  `
  showAgreementModal.value = true
}

const closeAgreementModal = () => {
  showAgreementModal.value = false
}

const proceedToPurchase = () => {
  if (!agreedToTerms.value) {
    uni.showToast({
      title: '请先同意用户协议',
      icon: 'none',
    })
    return
  }

  // 获取平台信息
  const systemInfo = uni.getSystemInfoSync()
  const platform = systemInfo.platform

  // 根据平台显示不同的支付方式
  if (platform === 'devtools' || platform === 'mp-weixin') {
    // 小程序端：只显示微信支付
    handleWeChatPay()
  } else {
    // App端：显示微信支付和支付宝支付选项
    uni.showActionSheet({
      itemList: ['微信支付', '支付宝支付'],
      success: (res) => {
        if (res.tapIndex === 0) {
          handleWeChatPay()
        } else {
          handleAliPay()
        }
      },
      fail: () => {
        console.log('用户取消支付')
      },
    })
  }
}

// 微信支付处理函数
const handleWeChatPay = () => {
  const planData = selectedPlanInfo.value

  // 显示支付加载
  uni.showLoading({
    title: '正在启动微信支付...',
    mask: true,
  })

  // 模拟微信支付处理
  setTimeout(() => {
    uni.hideLoading()

    // 小程序端调用微信支付API
    const systemInfo = uni.getSystemInfoSync()
    if (systemInfo.platform === 'devtools' || systemInfo.platform === 'mp-weixin') {
      // 小程序微信支付
      // @ts-ignore - 小程序支付参数格式
      uni.requestPayment({
        timeStamp: String(Date.now()),
        nonceStr: 'randomString' + Date.now(),
        package: 'prepay_id=mock_prepay_id_' + Date.now(),
        signType: 'MD5',
        paySign: 'mockPaySign' + Date.now(),
        success: (res) => {
          console.log('微信支付成功:', res)
          jumpToSuccessPage(planData, '微信支付')
        },
        fail: (err) => {
          console.error('微信支付失败:', err)
          // 模拟支付成功（演示用）
          uni.showModal({
            title: '支付模拟',
            content: '这是演示环境，模拟支付成功',
            showCancel: false,
            success: () => {
              jumpToSuccessPage(planData, '微信支付')
            },
          })
        },
      })
    } else {
      // App端微信支付
      jumpToSuccessPage(planData, '微信支付')
    }
  }, 1500)
}

// 支付宝支付处理函数
const handleAliPay = () => {
  const planData = selectedPlanInfo.value

  // 显示支付加载
  uni.showLoading({
    title: '正在启动支付宝支付...',
    mask: true,
  })

  // 模拟支付宝支付处理
  setTimeout(() => {
    uni.hideLoading()

    // App端支付宝支付
    uni.requestPayment({
      provider: 'alipay',
      orderInfo: 'mock_order_info_' + Date.now(),
      success: (res) => {
        console.log('支付宝支付成功:', res)
        jumpToSuccessPage(planData, '支付宝支付')
      },
      fail: (err) => {
        console.error('支付宝支付失败:', err)
        // 模拟支付成功（演示用）
        uni.showModal({
          title: '支付模拟',
          content: '这是演示环境，模拟支付成功',
          showCancel: false,
          success: () => {
            jumpToSuccessPage(planData, '支付宝支付')
          },
        })
      },
    })
  }, 1500)
}

// 跳转到支付成功页面
const jumpToSuccessPage = (planData: any, paymentMethod: string) => {
  const successParams = new URLSearchParams({
    planTitle: planData.title,
    planPrice: planData.price.toString(),
    paymentMethod: paymentMethod,
    orderId: `VIP${Date.now()}`,
    discount: '0',
  }).toString()

  uni.redirectTo({
    url: `/pages/payment-success/payment-success?${successParams}`,
    success: () => {
      console.log('支付成功，跳转到成功页面')
    },
    fail: (err) => {
      console.error('跳转支付成功页面失败:', err)
      uni.showToast({
        title: '跳转失败',
        icon: 'error',
      })
    },
  })
}

onMounted(() => {
  // 可以在这里获取最新的VIP套餐信息
  console.log('VIP页面加载完成')
})

// 视频广告部分
const urlCallback = ref({})
const showVipModal = ref(false)
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
</script>

<style lang="scss" scoped>
.container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding-bottom: 20px;
}

/* 顶部导航栏 */
.header {
  color: white;
  padding: 8px 0;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  backdrop-filter: blur(10px);
  background: rgba(102, 126, 234, 0.9);
  padding-top: calc(8px + 14px);
}

.header-content {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 0 20px;
}

.logo {
  font-size: 18px;
  font-weight: bold;
}

/* VIP英雄区域 */
.vip-hero {
  padding: 80px 20px 40px;
  text-align: center;
}

.hero-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
}

.hero-icon {
  font-size: 60px;
  margin-bottom: 10px;
}

.hero-title {
  font-size: 28px;
  font-weight: bold;
  color: white;
  margin-bottom: 8px;
}

.hero-subtitle {
  font-size: 16px;
  color: rgba(255, 255, 255, 0.9);
}

/* 特权部分 */
.privileges-section {
  background: white;
  margin: 20px;
  border-radius: 20px;
  padding: 25px 20px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.section-title {
  font-size: 20px;
  font-weight: bold;
  color: #333;
  margin-bottom: 20px;
  display: block;
}

.privileges-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.privilege-item {
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 15px;
  background: #f8f9ff;
  border-radius: 12px;
  border-left: 4px solid #667eea;
}

.privilege-icon {
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

.privilege-content {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.privilege-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 4px;
}

.privilege-desc {
  font-size: 13px;
  color: #666;
  line-height: 1.4;
}

.privilege-tag {
  background: linear-gradient(45deg, #ffd700, #ffa500);
  color: white;
  font-size: 10px;
  padding: 4px 8px;
  border-radius: 8px;
  font-weight: bold;
}

/* 套餐选择 */
.plans-section {
  background: white;
  margin: 20px;
  border-radius: 20px;
  padding: 25px 20px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.plans-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.plan-card {
  position: relative;
  background: #f8f9fa;
  border: 2px solid #eee;
  border-radius: 15px;
  padding: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.plan-card.active {
  border-color: #667eea;
  background: linear-gradient(135deg, #f8f9ff 0%, #fff 100%);
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.2);
}

.plan-badge {
  position: absolute;
  top: -8px;
  right: 20px;
  background: linear-gradient(45deg, #ff6b6b, #ee5a24);
  color: white;
  font-size: 12px;
  padding: 6px 12px;
  border-radius: 12px;
  font-weight: bold;
}

.plan-header {
  margin-bottom: 15px;
}

.plan-title {
  font-size: 18px;
  font-weight: bold;
  color: #333;
  margin-bottom: 4px;
  display: block;
}

.plan-subtitle {
  font-size: 13px;
  color: #666;
}

.plan-price {
  display: flex;
  align-items: baseline;
  margin-bottom: 10px;
}

.price-symbol {
  font-size: 16px;
  color: #667eea;
  font-weight: bold;
}

.price-amount {
  font-size: 32px;
  font-weight: bold;
  color: #667eea;
  margin: 0 4px;
}

.price-unit {
  font-size: 14px;
  color: #999;
}

.plan-original {
  display: flex;
  gap: 8px;
  margin-bottom: 15px;
}

.original-price {
  font-size: 13px;
  color: #999;
  text-decoration: line-through;
}

.discount {
  font-size: 13px;
  color: #ff6b6b;
  font-weight: bold;
}

.plan-features {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.feature-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.feature-icon {
  color: #4caf50;
  font-weight: bold;
  font-size: 14px;
}

.feature-text {
  font-size: 14px;
  color: #666;
}

/* 用户协议 */
.agreement-section {
  margin: 20px;
  padding: 0 5px;
}

.agreement-item {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  cursor: pointer;
}

.checkbox {
  font-size: 18px;
  color: #ccc;
  transition: color 0.3s ease;
  margin-top: 2px;
}

.checkbox.checked {
  color: #667eea;
}

.agreement-text {
  font-size: 13px;
  color: rgba(255, 255, 255, 0.9);
  line-height: 1.6;
}

.link {
  color: #ffd700;
  text-decoration: underline;
}

/* 立即开通按钮 */
.action-section {
  padding: 20px;
  text-align: center;
}

.purchase-btn {
  width: 100%;
  background: linear-gradient(135deg, #ffd700 0%, #ffa500 100%);
  color: white;
  border: none;
  border-radius: 25px;
  padding: 16px;
  font-size: 18px;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
  margin-bottom: 12px;
}

.purchase-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
}

.purchase-btn:not(:disabled):hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(255, 215, 0, 0.4);
}

.purchase-note {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.8);
}

/* 模态框 */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  z-index: 2000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.modal-content {
  background: white;
  border-radius: 20px;
  width: 100%;
  max-width: 500px;
  max-height: 70vh;
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

.close-btn {
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
  max-height: 50vh;
  overflow-y: auto;
}

.agreement-content {
  font-size: 14px;
  line-height: 1.8;
  color: #666;
  white-space: pre-line;
}
</style>
