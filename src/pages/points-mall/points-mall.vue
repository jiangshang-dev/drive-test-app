<template>
  <view class="container">
    <!-- 顶部导航栏 -->
    <view class="header">
      <view class="header-content">
        <text class="logo">积分商城</text>
        <view class="header-right">
          <view class="points-display">
            <text class="points-icon">🪙</text>
            <text class="points-text">{{ userPoints }}</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 积分概览卡片 -->
    <view class="points-overview">
      <view class="overview-content">
        <view class="points-info">
          <text class="current-points">{{ userPoints }}</text>
          <text class="points-label">当前积分</text>
        </view>
        <view class="points-actions">
          <text class="action-btn" @click="showEarnModal = true">赚取积分</text>
          <text class="action-btn" @click="showHistoryModal = true">积分记录</text>
        </view>
      </view>
      <view class="points-stats">
        <view class="stat-item">
          <text class="stat-number">{{ totalEarned }}</text>
          <text class="stat-label">总获得</text>
        </view>
        <view class="stat-item">
          <text class="stat-number">{{ totalSpent }}</text>
          <text class="stat-label">总消费</text>
        </view>
        <view class="stat-item">
          <text class="stat-number">{{ todayEarned }}</text>
          <text class="stat-label">今日获得</text>
        </view>
      </view>
    </view>

    <!-- 商品分类标签 -->
    <view class="category-tabs">
      <view
        :class="['tab-item', selectedCategory === 'all' ? 'active' : '']"
        @click="selectCategory('all')"
      >
        全部
      </view>
      <view
        :class="['tab-item', selectedCategory === 'learning' ? 'active' : '']"
        @click="selectCategory('learning')"
      >
        学习工具
      </view>
      <view
        :class="['tab-item', selectedCategory === 'digital' ? 'active' : '']"
        @click="selectCategory('digital')"
      >
        数字商品
      </view>
      <view
        :class="['tab-item', selectedCategory === 'physical' ? 'active' : '']"
        @click="selectCategory('physical')"
      >
        实物商品
      </view>
    </view>

    <!-- 商品列表 -->
    <view class="products-list">
      <view
        v-for="(product, index) in filteredProducts"
        :key="index"
        class="product-card"
        @click="viewProduct(product)"
      >
        <view class="product-image">
          <image class="product-img" :src="product.image" mode="aspectFill" />
          <view v-if="product.discount" class="discount-badge"> {{ product.discount }}折 </view>
          <view v-if="product.hot" class="hot-badge">热门</view>
        </view>

        <view class="product-content">
          <text class="product-title">{{ product.title }}</text>
          <text class="product-desc">{{ product.description }}</text>

          <view class="product-footer">
            <view class="price-info">
              <text class="points-price">{{ product.points }}积分</text>
              <text v-if="product.originalPoints" class="original-price">
                {{ product.originalPoints }}积分
              </text>
            </view>
            <view class="product-actions">
              <text
                class="exchange-btn"
                :class="{ disabled: userPoints < product.points }"
                @click.stop="exchangeProduct(product)"
              >
                {{ userPoints < product.points ? '积分不足' : '立即兑换' }}
              </text>
            </view>
          </view>
        </view>
      </view>
    </view>

    <!-- 空状态 -->
    <view v-if="filteredProducts.length === 0" class="empty-state">
      <text class="empty-icon">🛍️</text>
      <text class="empty-title">暂无商品</text>
      <text class="empty-desc">更多精彩商品正在准备中</text>
    </view>

    <!-- 赚取积分弹窗 -->
    <view v-if="showEarnModal" class="modal" @click="showEarnModal = false">
      <view class="modal-content" @click.stop>
        <view class="modal-header">
          <text class="modal-title">赚取积分</text>
          <text class="close" @click="showEarnModal = false">&times;</text>
        </view>
        <view class="modal-body">
          <view class="earn-methods">
            <view
              v-for="(method, index) in earnMethods"
              :key="index"
              class="earn-item"
              @click="executeEarnMethod(method)"
            >
              <text class="earn-icon">{{ method.icon }}</text>
              <view class="earn-info">
                <text class="earn-title">{{ method.title }}</text>
                <text class="earn-desc">{{ method.description }}</text>
              </view>
              <view class="earn-reward">
                <text class="reward-points">+{{ method.points }}</text>
                <text class="reward-status" :class="method.completed ? 'completed' : ''">
                  {{ method.completed ? '已完成' : '去完成' }}
                </text>
              </view>
            </view>
          </view>
        </view>
      </view>
    </view>

    <!-- 积分记录弹窗 -->
    <view v-if="showHistoryModal" class="modal" @click="showHistoryModal = false">
      <view class="modal-content" @click.stop>
        <view class="modal-header">
          <text class="modal-title">积分记录</text>
          <text class="close" @click="showHistoryModal = false">&times;</text>
        </view>
        <view class="modal-body">
          <view class="history-list">
            <view v-for="(record, index) in pointsHistory" :key="index" class="history-item">
              <view class="history-info">
                <text class="history-title">{{ record.title }}</text>
                <text class="history-time">{{ formatTime(record.time) }}</text>
              </view>
              <text class="history-points" :class="record.type">
                {{ record.type === 'earn' ? '+' : '-' }}{{ record.points }}
              </text>
            </view>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'

// 数据状态
const userPoints = ref(1250)
const selectedCategory = ref('all')
const showEarnModal = ref(false)
const showHistoryModal = ref(false)

// 积分统计
const pointsStats = ref({
  totalEarned: 2800,
  totalSpent: 1550,
  todayEarned: 45,
})

// 获取积分方式
const earnMethods = ref([
  {
    icon: '✏️',
    title: '完成每日刷题',
    description: '每天刷题20题',
    points: 10,
    completed: true,
  },
  {
    icon: '📋',
    title: '参加模拟考试',
    description: '完成一次模拟考试',
    points: 50,
    completed: false,
  },
  {
    icon: '🎯',
    title: '考试通过',
    description: '模拟考试成绩≥90分',
    points: 100,
    completed: false,
  },
  {
    icon: '🔥',
    title: '连续学习',
    description: '连续学习7天',
    points: 200,
    completed: false,
  },
  {
    icon: '👥',
    title: '邀请好友',
    description: '邀请好友注册使用',
    points: 300,
    completed: false,
  },
  {
    icon: '📱',
    title: '分享应用',
    description: '分享应用到朋友圈',
    points: 20,
    completed: false,
  },
])

// 商品列表
const products = ref([
  {
    id: 1,
    title: 'VIP会员7天',
    description: '解锁全部视频课程，无限刷题',
    image: 'https://via.placeholder.com/150x120/667eea/white?text=VIP',
    points: 500,
    originalPoints: 600,
    discount: 8.3,
    category: 'learning',
    hot: true,
  },
  {
    id: 2,
    title: 'VIP会员30天',
    description: '一个月畅享所有学习功能',
    image: 'https://via.placeholder.com/150x120/764ba2/white?text=VIP+',
    points: 1800,
    originalPoints: 2200,
    discount: 8.2,
    category: 'learning',
    hot: true,
  },
  {
    id: 3,
    title: '错题解析大全',
    description: '包含所有科目错题详细解析',
    image: 'https://via.placeholder.com/150x120/4caf50/white?text=解析',
    points: 300,
    category: 'digital',
  },
  {
    id: 4,
    title: '学习计划定制',
    description: '专业老师为您定制学习计划',
    image: 'https://via.placeholder.com/150x120/ff9800/white?text=计划',
    points: 800,
    category: 'learning',
  },
  {
    id: 5,
    title: '10元话费',
    description: '手机话费充值',
    image: 'https://via.placeholder.com/150x120/2196f3/white?text=话费',
    points: 1000,
    category: 'physical',
  },
  {
    id: 6,
    title: '20元京东卡',
    description: '京东购物卡电子码',
    image: 'https://via.placeholder.com/150x120/f44336/white?text=京东',
    points: 2000,
    category: 'physical',
  },
  {
    id: 7,
    title: '专属学习勋章',
    description: '限量版学习成就勋章',
    image: 'https://via.placeholder.com/150x120/9c27b0/white?text=勋章',
    points: 150,
    category: 'digital',
  },
  {
    id: 8,
    title: '驾考秘籍电子书',
    description: '包含通关技巧和经验分享',
    image: 'https://via.placeholder.com/150x120/795548/white?text=秘籍',
    points: 400,
    category: 'digital',
  },
])

// 积分记录
const pointsHistory = ref([
  {
    title: '完成每日刷题',
    points: 10,
    type: 'earn',
    time: Date.now() - 3600000, // 1小时前
  },
  {
    title: '兑换VIP会员7天',
    points: 500,
    type: 'spend',
    time: Date.now() - 86400000, // 1天前
  },
  {
    title: '模拟考试通过',
    points: 100,
    type: 'earn',
    time: Date.now() - 172800000, // 2天前
  },
  {
    title: '完成每日刷题',
    points: 10,
    type: 'earn',
    time: Date.now() - 259200000, // 3天前
  },
])

// 计算属性
const totalEarned = computed(() => pointsStats.value.totalEarned)
const totalSpent = computed(() => pointsStats.value.totalSpent)
const todayEarned = computed(() => pointsStats.value.todayEarned)

const filteredProducts = computed(() => {
  if (selectedCategory.value === 'all') {
    return products.value
  }
  return products.value.filter((product) => product.category === selectedCategory.value)
})

// 方法
const selectCategory = (category) => {
  selectedCategory.value = category
}

const viewProduct = (product) => {
  uni.showModal({
    title: product.title,
    content: `${product.description}\n需要积分: ${product.points}`,
    confirmText: '立即兑换',
    cancelText: '稍后再说',
    success: (res) => {
      if (res.confirm) {
        exchangeProduct(product)
      }
    },
  })
}

const exchangeProduct = (product) => {
  if (userPoints.value < product.points) {
    uni.showToast({
      title: '积分不足',
      icon: 'error',
    })
    return
  }

  uni.showModal({
    title: '确认兑换',
    content: `确定要用${product.points}积分兑换"${product.title}"吗？`,
    success: (res) => {
      if (res.confirm) {
        userPoints.value -= product.points

        // 添加兑换记录
        pointsHistory.value.unshift({
          title: `兑换${product.title}`,
          points: product.points,
          type: 'spend',
          time: Date.now(),
        })

        uni.showToast({
          title: '兑换成功',
          icon: 'success',
        })
      }
    },
  })
}

const executeEarnMethod = (method) => {
  if (method.completed) {
    uni.showToast({
      title: '今日已完成',
      icon: 'none',
    })
    return
  }

  // 模拟完成任务
  uni.showToast({
    title: '正在跳转...',
    icon: 'loading',
  })

  setTimeout(() => {
    uni.showToast({
      title: `获得${method.points}积分`,
      icon: 'success',
    })

    userPoints.value += method.points
    method.completed = true

    // 添加获得记录
    pointsHistory.value.unshift({
      title: method.title,
      points: method.points,
      type: 'earn',
      time: Date.now(),
    })
  }, 1500)
}

const formatTime = (timestamp) => {
  const date = new Date(timestamp)
  const now = new Date()
  const diffTime = now.getTime() - date.getTime()
  const diffHours = Math.floor(diffTime / (1000 * 60 * 60))
  const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24))

  if (diffHours < 1) {
    return '刚刚'
  } else if (diffHours < 24) {
    return `${diffHours}小时前`
  } else if (diffDays < 7) {
    return `${diffDays}天前`
  } else {
    return date.toLocaleDateString()
  }
}

onMounted(() => {
  // 初始化数据
})
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
  padding-top: calc(8px + 14px);
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

.points-display {
  display: flex;
  align-items: center;
  gap: 6px;
  background: rgba(255, 255, 255, 0.2);
  padding: 6px 12px;
  border-radius: 15px;
}

.points-icon {
  font-size: 16px;
}

.points-text {
  font-size: 14px;
  font-weight: bold;
}

/* 积分概览卡片 */
.points-overview {
  margin: 80px 20px 20px;
  background: white;
  border-radius: 15px;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  padding: 20px;
}

.overview-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  gap: 15px;
}

.points-info {
  display: flex;
  flex-direction: column;
  flex: 1;
}

.current-points {
  font-size: 28px;
  font-weight: bold;
  color: #667eea;
  margin-bottom: 4px;
  line-height: 1;
}

.points-label {
  font-size: 14px;
  color: #666;
}

.points-actions {
  display: flex;
  gap: 8px;
  flex-shrink: 0;
}

.action-btn {
  font-size: 11px;
  color: #667eea;
  padding: 6px 12px;
  border: 1px solid #667eea;
  border-radius: 15px;
  cursor: pointer;
  transition: all 0.3s ease;
  white-space: nowrap;
  text-align: center;
  line-height: 1.2;
}

.action-btn:hover {
  background: #667eea;
  color: white;
}

.points-stats {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
}

.stat-item {
  text-align: center;
  padding: 12px 8px;
  background: #f8f9fa;
  border-radius: 10px;
}

.stat-number {
  display: block;
  font-size: 18px;
  font-weight: bold;
  color: #333;
  margin-bottom: 4px;
  line-height: 1;
}

.stat-label {
  font-size: 11px;
  color: #666;
  line-height: 1;
}

/* 分类标签 */
.category-tabs {
  display: flex;
  background: white;
  border-radius: 24px;
  padding: 10px;
  margin: 0 20px 20px;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.08);
}

.tab-item {
  flex: 1;
  text-align: center;
  padding: 10px 8px;
  border-radius: 16px;
  font-weight: 500;
  transition: all 0.3s ease;
  color: #666;
  font-size: 12px;
  cursor: pointer;
}

.tab-item.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.3);
}

/* 商品列表 */
.products-list {
  padding: 0 20px;
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 15px;
}

.product-card {
  background: white;
  border-radius: 15px;
  overflow: hidden;
  box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
  cursor: pointer;
  transition: all 0.3s ease;
  min-height: 240px;
  display: flex;
  flex-direction: column;
}

.product-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.12);
}

.product-image {
  position: relative;
  height: 120px;
  overflow: hidden;
  flex-shrink: 0;
}

.product-img {
  width: 100%;
  height: 100%;
}

.discount-badge {
  position: absolute;
  top: 8px;
  left: 8px;
  background: #f44336;
  color: white;
  font-size: 10px;
  padding: 2px 6px;
  border-radius: 8px;
  font-weight: bold;
}

.hot-badge {
  position: absolute;
  top: 8px;
  right: 8px;
  background: #ff9800;
  color: white;
  font-size: 10px;
  padding: 2px 6px;
  border-radius: 8px;
  font-weight: bold;
}

.product-content {
  padding: 12px;
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.product-title {
  font-size: 14px;
  font-weight: bold;
  color: #333;
  margin-bottom: 6px;
  display: block;
  line-height: 1.3;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.product-desc {
  font-size: 12px;
  color: #666;
  line-height: 1.4;
  margin-bottom: 12px;
  display: block;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  flex: 1;
}

.product-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 8px;
  margin-top: auto;
}

.price-info {
  display: flex;
  flex-direction: column;
  flex: 1;
  min-width: 0;
}

.points-price {
  font-size: 14px;
  font-weight: bold;
  color: #667eea;
  margin-bottom: 2px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.original-price {
  font-size: 11px;
  color: #999;
  text-decoration: line-through;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.exchange-btn {
  font-size: 11px;
  color: white;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 6px 8px;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.3s ease;
  white-space: nowrap;
  flex-shrink: 0;
  min-width: 60px;
  text-align: center;
  line-height: 1.2;
}

.exchange-btn.disabled {
  background: #ccc;
  cursor: not-allowed;
}

.exchange-btn:hover:not(.disabled) {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.4);
}

/* 空状态 */
.empty-state {
  text-align: center;
  padding: 60px 20px;
  color: #999;
  grid-column: 1 / -1;
}

.empty-icon {
  font-size: 48px;
  margin-bottom: 20px;
  display: block;
}

.empty-title {
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 10px;
  display: block;
  color: #666;
}

.empty-desc {
  font-size: 14px;
  display: block;
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

/* 赚取积分模态框 */
.earn-methods {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.earn-item {
  display: flex;
  align-items: center;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.earn-item:hover {
  background: #e9ecef;
}

.earn-icon {
  font-size: 24px;
  margin-right: 15px;
}

.earn-info {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.earn-title {
  font-size: 14px;
  font-weight: bold;
  color: #333;
  margin-bottom: 4px;
}

.earn-desc {
  font-size: 12px;
  color: #666;
}

.earn-reward {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

.reward-points {
  font-size: 14px;
  font-weight: bold;
  color: #667eea;
  margin-bottom: 4px;
}

.reward-status {
  font-size: 10px;
  color: #667eea;
  padding: 2px 8px;
  border: 1px solid #667eea;
  border-radius: 8px;
  cursor: pointer;
}

.reward-status.completed {
  color: #999;
  border-color: #999;
  cursor: not-allowed;
}

/* 积分记录模态框 */
.history-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.history-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
  border-bottom: 1px solid #f0f0f0;
}

.history-item:last-child {
  border-bottom: none;
}

.history-info {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.history-title {
  font-size: 14px;
  color: #333;
  margin-bottom: 4px;
}

.history-time {
  font-size: 12px;
  color: #999;
}

.history-points {
  font-size: 16px;
  font-weight: bold;
}

.history-points.earn {
  color: #4caf50;
}

.history-points.spend {
  color: #f44336;
}

/* 响应式设计 */
/* 大屏幕优化 */
@media (min-width: 768px) {
  .products-list {
    grid-template-columns: repeat(3, 1fr);
    gap: 20px;
  }

  .product-card {
    min-height: 280px;
  }

  .product-content {
    padding: 16px;
  }

  .points-price {
    font-size: 16px;
  }

  .exchange-btn {
    font-size: 12px;
    padding: 8px 12px;
    min-width: 70px;
  }

  .current-points {
    font-size: 36px;
  }

  .stat-number {
    font-size: 22px;
  }

  .action-btn {
    font-size: 12px;
    padding: 8px 16px;
  }
}

/* 中等屏幕优化 */
@media (max-width: 767px) and (min-width: 480px) {
  .header-content {
    padding: 0 16px;
  }

  .products-list {
    padding: 0 16px;
    gap: 12px;
  }

  .product-card {
    min-height: 220px;
  }

  .points-overview {
    margin: 80px 16px 16px;
    padding: 18px;
  }

  .overview-content {
    gap: 12px;
  }

  .current-points {
    font-size: 26px;
  }

  .action-btn {
    font-size: 10px;
    padding: 5px 10px;
  }

  .points-stats {
    gap: 10px;
  }

  .stat-item {
    padding: 10px 6px;
  }

  .stat-number {
    font-size: 16px;
  }

  .stat-label {
    font-size: 10px;
  }
}

/* 小屏幕优化 */
@media (max-width: 479px) {
  .header-content {
    padding: 0 12px;
  }

  .logo {
    font-size: 18px;
  }

  .points-display {
    padding: 4px 8px;
  }

  .points-text {
    font-size: 12px;
  }

  .products-list {
    padding: 0 12px;
    gap: 10px;
    grid-template-columns: repeat(2, 1fr);
  }

  .product-card {
    min-height: 200px;
  }

  .product-image {
    height: 100px;
  }

  .product-content {
    padding: 10px;
  }

  .product-title {
    font-size: 13px;
    margin-bottom: 4px;
  }

  .product-desc {
    font-size: 11px;
    margin-bottom: 8px;
  }

  .product-footer {
    gap: 6px;
  }

  .points-price {
    font-size: 13px;
  }

  .original-price {
    font-size: 10px;
  }

  .exchange-btn {
    font-size: 10px;
    padding: 4px 6px;
    min-width: 50px;
    border-radius: 8px;
  }

  .points-overview {
    margin: 80px 12px 12px;
    padding: 15px;
  }

  .overview-content {
    flex-direction: column;
    align-items: flex-start;
    gap: 15px;
  }

  .points-info {
    width: 100%;
    text-align: center;
  }

  .current-points {
    font-size: 24px;
  }

  .points-actions {
    width: 100%;
    justify-content: center;
    gap: 10px;
  }

  .action-btn {
    font-size: 10px;
    padding: 4px 8px;
    flex: 1;
    max-width: 80px;
  }

  .points-stats {
    gap: 8px;
  }

  .stat-item {
    padding: 8px 4px;
  }

  .stat-number {
    font-size: 14px;
  }

  .stat-label {
    font-size: 9px;
  }

  .category-tabs {
    margin: 0 12px 12px;
    padding: 6px;
  }

  .tab-item {
    padding: 6px 4px;
    font-size: 10px;
  }

  .empty-state {
    padding: 40px 12px;
  }

  .empty-icon {
    font-size: 36px;
  }

  .empty-title {
    font-size: 16px;
  }

  .empty-desc {
    font-size: 12px;
  }
}

/* 超小屏幕优化 */
@media (max-width: 360px) {
  .products-list {
    gap: 8px;
  }

  .product-card {
    min-height: 180px;
  }

  .product-image {
    height: 80px;
  }

  .product-content {
    padding: 8px;
  }

  .product-title {
    font-size: 12px;
    -webkit-line-clamp: 1;
  }

  .product-desc {
    font-size: 10px;
    -webkit-line-clamp: 1;
    margin-bottom: 6px;
  }

  .points-price {
    font-size: 12px;
  }

  .exchange-btn {
    font-size: 9px;
    padding: 3px 5px;
    min-width: 45px;
  }

  .current-points {
    font-size: 20px;
  }

  .action-btn {
    font-size: 9px;
    padding: 3px 6px;
  }

  .stat-number {
    font-size: 12px;
  }

  .stat-label {
    font-size: 8px;
  }
}
</style>
