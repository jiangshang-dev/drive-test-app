<template>
  <view class="container">
    <!-- 视频播放器 -->
    <view class="video-player-wrapper">
      <video
        :src="videoInfo.videoUrl"
        :poster="videoInfo.thumbnail"
        controls
        show-center-play-btn
        show-fullscreen-btn
        show-play-btn
        autoplay
        class="video-player"
        @play="onVideoPlay"
        @pause="onVideoPause"
        @ended="onVideoEnded"
        @timeupdate="onTimeUpdate"
      ></video>
      <!-- VIP标识 -->
      <view v-if="videoInfo.isVip === 1" class="vip-badge">VIP</view>
    </view>

    <!-- 视频信息区域 -->
    <view class="video-info-section">
      <view class="video-header">
        <text class="video-title">{{ videoInfo.title }}</text>
        <view class="video-stats">
          <text class="stat-item">{{ videoInfo.views }} 观看</text>
          <text class="stat-item">{{ formatDate(videoInfo.publishTime) }}</text>
        </view>
      </view>

      <!-- 操作按钮区域 -->
      <view class="action-buttons">
        <view class="action-btn" :class="{ active: isLiked }" @click="toggleLike">
          <text class="action-icon">{{ isLiked ? '❤️' : '🤍' }}</text>
          <text class="action-text">{{ likeCount }}</text>
        </view>

        <view
          v-if="false"
          class="action-btn"
          :class="{ active: isFavorited }"
          @click="toggleFavorite"
        >
          <text class="action-icon">{{ isFavorited ? '⭐' : '☆' }}</text>
          <text class="action-text">收藏</text>
        </view>

        <view class="action-btn" @click="shareVideo" v-if="false">
          <text class="action-icon">📤</text>
          <text class="action-text">分享</text>
        </view>

        <view v-if="false" class="action-btn" @click="downloadVideo">
          <text class="action-icon">📥</text>
          <text class="action-text">下载</text>
        </view>
      </view>

      <!-- 视频描述 -->
      <view class="video-description">
        <text class="description-text">{{ videoInfo.description }}</text>
        <view class="video-tags" v-if="videoInfo.tags && videoInfo.tags.length > 0">
          <text v-for="tag in videoInfo.tags" :key="tag" class="tag-item"> #{{ tag }} </text>
        </view>
      </view>
    </view>

    <!-- 评论区域 -->
    <view class="comments-section">
      <view class="comments-header">
        <text class="comments-title">评论 ({{ comments.length }})</text>
        <view class="sort-options">
          <text
            :class="['sort-btn', sortType === 'time' ? 'active' : '']"
            @click="setSortType('time')"
          >
            最新
          </text>
          <text
            :class="['sort-btn', sortType === 'hot' ? 'active' : '']"
            @click="setSortType('hot')"
          >
            最热
          </text>
        </view>
      </view>

      <!-- 评论输入框 -->
      <view class="comment-input-section">
        <view class="comment-input-wrapper">
          <input
            v-model="commentText"
            class="comment-input"
            placeholder="说点什么..."
            @focus="onCommentFocus"
            @blur="onCommentBlur"
          />
          <button class="send-btn" :disabled="!commentText.trim()" @click="sendComment">
            发送
          </button>
        </view>
      </view>

      <!-- 评论列表 -->
      <view class="comments-list">
        <view v-for="comment in sortedComments" :key="comment.id" class="comment-item">
          <view class="comment-avatar">
            <image :src="comment.avatar" class="avatar-img" />
          </view>

          <view class="comment-content">
            <view class="comment-header">
              <text class="comment-author">{{ comment.username }}</text>
              <text class="comment-time">{{ formatCommentTime(comment.createTime) }}</text>
            </view>

            <text class="comment-text">{{ comment.content }}</text>

            <view class="comment-actions">
              <view
                class="comment-action"
                :class="{ active: comment.isLikeComment }"
                @click="toggleCommentLike(comment)"
              >
                <text class="action-icon">{{ comment.isLikeComment ? '❤️' : '🤍' }}</text>
                <text class="action-count">{{ comment.likeCount || '' }}</text>
              </view>

              <view class="comment-action" @click="replyToComment(comment)">
                <text class="action-icon">💬</text>
                <text class="action-text">回复</text>
              </view>
            </view>

            <!-- 回复列表 -->
            <view v-if="comment.replies && comment.replies.length > 0" class="replies-list">
              <view v-for="reply in comment.replies" :key="reply.id" class="reply-item">
                <text class="reply-author">{{ reply.username }}</text>
                <text class="reply-text">: {{ reply.content }}</text>
                <text class="reply-time">{{ formatCommentTime(reply.createTime) }}</text>
              </view>
            </view>
          </view>
        </view>
      </view>

      <!-- 暂无评论 -->
      <view v-if="comments.length === 0" class="empty-comments">
        <text class="empty-icon">💬</text>
        <text class="empty-text">暂无评论，快来抢沙发吧！</text>
      </view>
    </view>

    <!-- 回复弹窗 -->
    <view v-if="showReplyModal" class="modal" @click="closeReplyModal">
      <view class="modal-content" @click.stop>
        <view class="modal-header">
          <text class="modal-title">回复评论</text>
          <text class="close-btn" @click="closeReplyModal">&times;</text>
        </view>
        <view class="modal-body">
          <view class="reply-target">
            <text class="reply-label">回复给：</text>
            <text class="reply-username">{{ replyTarget.username }}</text>
          </view>
          <textarea
            v-model="replyText"
            class="reply-textarea"
            placeholder="输入回复内容..."
            auto-height
          ></textarea>
          <view class="modal-actions">
            <button class="cancel-btn" @click="closeReplyModal">取消</button>
            <button class="confirm-btn" :disabled="!replyText.trim()" @click="sendReply">
              发送
            </button>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { http } from '@/utils/http'
import { useMemberStore } from '@/stores'
import { vipChecker } from '@/utils/vipChecker'

// 数据状态
const videoInfo = ref({
  id: '',
  title: '',
  description: '',
  thumbnail: '',
  videoUrl: '',
  aliyunVideoId: '', // 添加阿里云视频ID字段
  isVip: 0, // 添加VIP字段
  duration: '',
  views: '',
  likes: 0,
  isLiked: false, // 添加点赞状态字段
  publishTime: '',
  tags: [] as string[],
})

const isLiked = ref(false)
const isFavorited = ref(false)
const likeCount = ref(0)
const commentText = ref('')
const sortType = ref('time') // 'time' | 'hot'
const showReplyModal = ref(false)
const replyTarget = ref<any>({})
const replyText = ref('')
const id = ref('')
const isVipUser = ref(false) // 添加VIP用户状态

// 评论数据
const comments = ref<any[]>([])

// 计算属性
const sortedComments = computed(() => {
  const sorted = [...comments.value]
  if (sortType.value === 'hot') {
    return sorted.sort((a, b) => (b.likeCount || 0) - (a.likeCount || 0))
  } else {
    return sorted.sort(
      (a, b) => new Date(b.createTime).getTime() - new Date(a.createTime).getTime(),
    )
  }
})

// 方法
const onVideoPlay = () => {
  console.log('视频开始播放')
}

const onVideoPause = () => {
  console.log('视频暂停')
}

const onVideoEnded = () => {
  console.log('视频播放结束')
  // 可以在这里推荐下一个视频
}

const onTimeUpdate = (e: any) => {
  // 记录播放进度
  const currentTime = e.detail.currentTime
  // console.log('当前播放时间:', currentTime)
}

// 点赞/取消点赞
const toggleLike = () => {
  isLikedApi(id.value).then((res) => {
    console.log('res--like---', res)
    isLiked.value = !isLiked.value
    if (isLiked.value) {
      likeCount.value++
      uni.showToast({
        title: '点赞成功',
        icon: 'success',
        duration: 1000,
      })
    } else {
      likeCount.value--
    }
  })
}

const toggleFavorite = () => {
  isFavorited.value = !isFavorited.value
  uni.showToast({
    title: isFavorited.value ? '收藏成功' : '取消收藏',
    icon: 'success',
    duration: 1000,
  })
}

// 分享
const shareVideo = () => {
  uni.showActionSheet({
    itemList: ['分享到微信', '分享到朋友圈', '复制链接'],
    success: (res) => {
      const actions = ['微信', '朋友圈', '复制链接']
      uni.showToast({
        title: `分享到${actions[res.tapIndex]}`,
        icon: 'success',
      })
    },
  })
}

// 下载
const downloadVideo = () => {
  if (!videoInfo.value.isVip) {
    uni.showModal({
      title: '下载提示',
      content: '视频下载功能开发中，敬请期待！',
      showCancel: false,
    })
  } else {
    uni.showModal({
      title: 'VIP功能',
      content: '请先开通VIP会员才能下载视频',
      showCancel: false,
    })
  }
}

const setSortType = (type: string) => {
  sortType.value = type
}

// 评论
const onCommentFocus = () => {
  console.log('评论输入框获得焦点')
}

const onCommentBlur = () => {
  console.log('评论输入框失去焦点')
}

// 发送评论
const sendComment = async () => {
  if (!commentText.value.trim()) return

  // 获取用户信息
  const memberStore = useMemberStore()
  // 修复用户信息访问问题
  const userInfo: any = memberStore.profile
  const userId = userInfo?.id

  if (!userId) {
    uni.showToast({
      title: '请先登录',
      icon: 'none',
    })
    return
  }

  try {
    console.log('videoInfo.value-----', videoInfo.value)
    // 发布评论，设置默认状态为待审核
    const res: any = await http({
      url: '/apvideocomment',
      method: 'POST',
      data: {
        videoId: videoInfo.value.id,
        userId: userId,
        commentContent: commentText.value.trim(),
      },
    })

    if (res?.code === 0) {
      // 清空输入框
      commentText.value = ''

      // 提示用户评论已提交，正在审核中
      uni.showToast({
        title: '评论正在审核中',
        icon: 'success',
        duration: 2000,
      })
    } else {
      uni.showToast({
        title: res.msg,
        icon: 'error',
      })
    }
  } catch (error) {
    uni.showToast({
      title: '评论发布失败',
      icon: 'error',
    })
    console.error('评论发布失败:', error)
  }
}

// 获取视频评论
const getVideoComments = async (videoId: string) => {
  try {
    const res: any = await http({
      url: `/apvideocomment/byVideo/${videoId}`,
      method: 'GET',
    })

    if (res?.code === 0 && res.data) {
      // 先转换所有评论数据
      const allComments = res.data.map((comment: any) => ({
        id: comment.id,
        username: comment.phone || '匿名用户',
        avatar: comment.userAvatar || 'https://via.placeholder.com/40x40/667eea/white?text=用',
        content: comment.commentContent,
        createTime: comment.gmtCreate,
        likeCount: comment.likeCount || 0,
        isLikeComment: comment.isLikeComment || 0, // 修复：正确映射点赞状态字段
        replies: [],
        parentCommentId: comment.parentCommentId || null, // 保留父评论ID，确保为null或具体值
      }))

      // 分离父评论和子评论
      const parentComments = allComments.filter((comment: any) => !comment.parentCommentId)
      const childComments = allComments.filter((comment: any) => comment.parentCommentId)

      // 将子评论添加到对应的父评论下
      childComments.forEach((child: any) => {
        const parent = parentComments.find((p: any) => p.id === child.parentCommentId)
        if (parent) {
          if (!parent.replies) {
            parent.replies = []
          }
          parent.replies.push(child)
        }
      })

      // 设置评论数据
      comments.value = parentComments
    }
  } catch (error) {
    console.error('获取评论失败:', error)
    uni.showToast({
      title: '获取评论失败',
      icon: 'error',
    })
  }
}

const toggleCommentLike = (comment: any) => {
  isLikedCommentApi(comment.id).then((res) => {
    console.log('res--like---', res)
    comment.isLikeComment = !comment.isLikeComment
    if (comment.isLikeComment) {
      comment.likeCount = (comment.likeCount || 0) + 1
      uni.showToast({
        title: '点赞成功',
        icon: 'success',
        duration: 1000,
      })
    } else {
      comment.likeCount = Math.max((comment.likeCount || 0) - 1, 0)
    }
  })
}

const replyToComment = (comment: any) => {
  replyTarget.value = comment
  showReplyModal.value = true
}

const closeReplyModal = () => {
  showReplyModal.value = false
  replyTarget.value = {}
  replyText.value = ''
}

// 发送回复
const sendReply = async () => {
  if (!replyText.value.trim()) return

  // 获取用户信息
  const memberStore = useMemberStore()
  const userInfo: any = memberStore.profile
  const userId = userInfo?.id

  if (!userId) {
    uni.showToast({
      title: '请先登录',
      icon: 'none',
    })
    return
  }

  try {
    // 发送回复请求
    const res: any = await http({
      url: '/apvideocomment/reply',
      method: 'POST',
      data: {
        parentId: replyTarget.value.id,
        replyContent: replyText.value.trim(),
      },
    })

    if (res?.code === 0) {
      // 添加回复到本地列表
      const newReply = {
        id: res.data.id,
        username: res.data.phone || '匿名用户',
        content: res.data.commentContent,
        createTime: res.data.gmtCreate,
      }

      if (!replyTarget.value.replies) {
        replyTarget.value.replies = []
      }
      replyTarget.value.replies.push(newReply)

      // 清空回复输入框
      replyText.value = ''

      // 关闭弹窗
      closeReplyModal()

      uni.showToast({
        title: '正在审核中',
        icon: 'success',
      })
    } else {
      uni.showToast({
        title: res.msg,
        icon: 'error',
      })
    }
  } catch (error) {
    uni.showToast({
      title: '回复失败',
      icon: 'error',
    })
    console.error('回复失败:', error)
  }
}

const isLikedApi = async (id: string) => {
  const url = `/aptrafficvideo/liked/${id}`
  const res: any = await http({
    url: url,
    method: 'GET',
  })
  console.log('res*********', res)
}

const isLikedCommentApi = async (id: string) => {
  const url = `/apvideocomment/liked/${id}`
  const res: any = await http({
    url: url,
    method: 'GET',
  })
  console.log('res*********', res)
}

// 查询视频信息
const getVideoInfo = async (id: string) => {
  const url = `/aptrafficvideo/${id}`
  const res: any = await http({
    url: url,
    method: 'GET',
  })

  console.log('res.data.value---', res)
  // 根据接口返回的数据格式，映射到页面需要的数据结构
  if (res && res.data) {
    videoInfo.value = {
      id: res.data.id || '',
      title: res.data.videoTitle || '',
      description: res.data.videoDesc || '',
      thumbnail: res.data.coverImage || '',
      videoUrl: res.data.videoUrl || '',
      aliyunVideoId: res.data.aliyunVideoId || '',
      isVip: res.data.isVip || 0,
      duration: res.data.videoDuration || '',
      views: res.data.viewCount || '',
      isLiked: res.data.isLike || false, // 点赞 isLike: true
      likes: parseInt(res.data.likeCount) || 0,
      publishTime: res.data.gmtCreate || '',
      tags: res.data.tags ? (Array.isArray(res.data.tags) ? res.data.tags : [res.data.tags]) : [],
    }

    console.log('videoInfo.value---', videoInfo.value)
    // 更新点赞状态和点赞数
    isLiked.value = videoInfo.value.isLiked
    likeCount.value = videoInfo.value.likes

    // 如果有阿里云视频ID，获取播放地址
    if (videoInfo.value.aliyunVideoId) {
      getPlayerUrl(videoInfo.value.aliyunVideoId).then((url) => {
        if (url) {
          videoInfo.value.videoUrl = url
        }
      })
    }

    // 获取视频评论
    if (videoInfo.value.id) {
      getVideoComments(videoInfo.value.id)
    }
  }

  return res
}

// 根据阿里云视频ID获取播放地址
const getPlayerUrl = async (aliyunVideoId: string) => {
  try {
    const url = `/vod/play/info?videoId=${aliyunVideoId}`
    const res: any = await http({
      url: url,
      method: 'GET',
    })

    console.log('获取播放地址响应:', res)

    if (res && res.data) {
      return res.data.playUrl
    }
    return ''
  } catch (error) {
    console.error('获取播放地址失败:', error)
    uni.showToast({
      title: '获取播放地址失败',
      icon: 'error',
    })
    return ''
  }
}

const formatDate = (date: string | Date) => {
  const d = new Date(date)
  return `${d.getFullYear()}-${(d.getMonth() + 1).toString().padStart(2, '0')}-${d
    .getDate()
    .toString()
    .padStart(2, '0')}`
}

const formatCommentTime = (date: string | Date) => {
  const now = new Date()
  const commentDate = new Date(date)
  const diff = now.getTime() - commentDate.getTime()

  const minutes = Math.floor(diff / 60000)
  const hours = Math.floor(diff / 3600000)
  const days = Math.floor(diff / 86400000)

  if (minutes < 60) {
    return `${minutes}分钟前`
  } else if (hours < 24) {
    return `${hours}小时前`
  } else if (days < 7) {
    return `${days}天前`
  } else {
    return formatDate(date)
  }
}

onMounted(() => {
  // 获取页面参数（从视频列表页通过 URL 传递的参数）
  // 在视频列表页中通过 uni.navigateTo 跳转时传递了 id 参数:
  // url: `/pages/video-player/video-player?id=${videoId}`
  const pages = getCurrentPages()
  const currentPage: any = pages[pages.length - 1]
  const options = currentPage.options || {}

  console.log('currentPage.value---', currentPage)
  console.log('options.value---', options)
  console.log('options.id---', options.id)

  id.value = options.id

  // 获取视频ID
  let videoId = ''

  // 从id参数中获取视频ID
  if (options.id) {
    videoId = options.id
  }

  // 如果获取到视频ID，则调用接口获取视频详情
  if (videoId) {
    getVideoInfo(videoId)
  } else {
    // 兼容之前的通过ID获取的方式
    videoId = '1'

    // 模拟视频数据
    videoInfo.value = {
      id: videoId,
      title: '',
      description: '',
      thumbnail: '',
      videoUrl: '',
      aliyunVideoId: '',
      isVip: 0,
      duration: '',
      views: '',
      likes: 0,
      isLiked: false,
      publishTime: '',
      tags: [],
    }

    likeCount.value = videoInfo.value.likes

    // 获取播放地址
    getPlayerUrl(videoInfo.value.aliyunVideoId).then((url) => {
      console.log('url-', url)

      if (url) {
        videoInfo.value.videoUrl = url
      }
    })
  }

  // 检查用户VIP状态
  checkUserVipStatus()
})

// 检查用户VIP状态
const checkUserVipStatus = async () => {
  const memberStore = useMemberStore()
  // 如果没有登录，直接返回false
  if (!memberStore.profile) {
    isVipUser.value = false
    return
  }

  // 使用vipChecker工具检查会员状态
  try {
    const isVip = await vipChecker.checkVipStatus(true) // 强制检查，不使用缓存
    console.log('用户VIP状态:', isVip)
    isVipUser.value = isVip
  } catch (error) {
    console.error('检查VIP状态失败:', error)
    // 如果检查失败，回退到使用本地存储的状态
    isVipUser.value = (memberStore.profile.vipLevel || 0) > 0
  }
}

onUnmounted(() => {
  // 页面销毁时可以保存播放进度等信息
})
</script>

<style lang="scss" scoped>
.container {
  min-height: 100vh;
  background-color: #f5f5f5;
}

/* 视频播放器样式 */
.video-player-wrapper {
  position: relative;
  width: 100%;
  background: #000;
}

.video-player {
  width: 100%;
  height: 56.25vw; /* 16:9 比例 */
  max-height: 300px;
}

/* 视频信息区域 */
.video-info-section {
  background: white;
  padding: 20px;
  margin-bottom: 10px;
}

.video-header {
  margin-bottom: 15px;
}

.video-title {
  font-size: 18px;
  font-weight: bold;
  color: #333;
  line-height: 1.4;
  display: block;
  margin-bottom: 8px;
}

.video-stats {
  display: flex;
  align-items: center;
  gap: 15px;
}

.stat-item {
  font-size: 13px;
  color: #666;
}

/* 操作按钮 */
.action-buttons {
  display: flex;
  justify-content: space-around;
  padding: 15px 0;
  border-top: 1px solid #eee;
  border-bottom: 1px solid #eee;
  margin: 15px 0;
}

.action-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 5px;
  padding: 8px 12px;
  border-radius: 8px;
  transition: all 0.3s ease;
  cursor: pointer;
}

.action-btn:hover {
  background: #f8f9fa;
}

.action-btn.active {
  background: linear-gradient(135deg, #0f766e 0%, #115e59 100%);
  color: white;
}

.action-btn.active .action-icon {
  transform: scale(1.1);
}

.action-icon {
  font-size: 20px;
  transition: transform 0.3s ease;
}

.action-text {
  font-size: 12px;
  color: #666;
}

.action-btn.active .action-text {
  color: white;
}

/* 视频描述 */
.video-description {
  line-height: 1.6;
}

.description-text {
  font-size: 14px;
  color: #666;
  display: block;
  margin-bottom: 10px;
}

.video-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.tag-item {
  background: #f0f0f0;
  color: #0f766e;
  font-size: 12px;
  padding: 4px 8px;
  border-radius: 12px;
}

/* 评论区域 */
.comments-section {
  background: white;
  padding: 20px;
}

.comments-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.comments-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
}

.sort-options {
  display: flex;
  gap: 15px;
}

.sort-btn {
  font-size: 14px;
  color: #999;
  cursor: pointer;
  transition: color 0.3s ease;
}

.sort-btn.active {
  color: #0f766e;
  font-weight: bold;
}

/* 评论输入 */
.comment-input-section {
  margin-bottom: 25px;
}

.comment-input-wrapper {
  display: flex;
  gap: 10px;
  align-items: center;
}

.comment-input {
  flex: 1;
  background: #f8f9fa;
  border: 1px solid #eee;
  border-radius: 20px;
  padding: 10px 15px;
  font-size: 14px;
  height: 40px;
  box-sizing: border-box;
  transition: border-color 0.3s ease;
}

.comment-input:focus {
  border-color: #0f766e;
  outline: none;
}

.send-btn {
  background: linear-gradient(135deg, #0f766e 0%, #115e59 100%);
  color: white;
  border: none;
  border-radius: 20px;
  padding: 10px 20px;
  font-size: 14px;
  height: 40px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.send-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
}

/* 评论列表 */
.comments-list {
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
}

.comment-avatar {
  flex-shrink: 0;
}

.avatar-img {
  width: 40px;
  height: 40px;
  border-radius: 50%;
}

.comment-content {
  flex: 1;
}

.comment-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.comment-author {
  font-size: 14px;
  font-weight: bold;
  color: #333;
}

.comment-time {
  font-size: 12px;
  color: #999;
}

.comment-text {
  font-size: 14px;
  color: #666;
  line-height: 1.5;
  display: block;
  margin-bottom: 10px;
}

.comment-actions {
  display: flex;
  gap: 20px;
}

.comment-action {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 4px 8px;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 12px;
  color: #999;
}

.comment-action:hover {
  background: #f8f9fa;
}

.comment-action.active {
  color: #0f766e;
}

.action-count,
.action-text {
  font-size: 12px;
}

/* 回复列表 */
.replies-list {
  margin-top: 12px;
  padding-left: 20px;
  border-left: 2px solid #f0f0f0;
}

.reply-item {
  padding: 8px 0;
  border-bottom: 1px solid #f8f9fa;
  font-size: 13px;
  line-height: 1.4;
}

.reply-item:last-child {
  border-bottom: none;
}

.reply-author {
  color: #0f766e;
  font-weight: bold;
}

.reply-text {
  color: #666;
}

.reply-time {
  color: #999;
  margin-left: 8px;
}

/* 空状态 */
.empty-comments {
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

/* 回复弹窗 */
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
  font-size: 16px;
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
}

.reply-target {
  margin-bottom: 15px;
  padding: 10px;
  background: #f8f9fa;
  border-radius: 8px;
}

.reply-label {
  color: #999;
  font-size: 13px;
}

.reply-username {
  color: #0f766e;
  font-weight: bold;
  margin-left: 5px;
}

.reply-textarea {
  width: 100%;
  min-height: 80px;
  border: 1px solid #eee;
  border-radius: 8px;
  padding: 12px;
  font-size: 14px;
  resize: none;
  margin-bottom: 15px;
  box-sizing: border-box;
}

.reply-textarea:focus {
  border-color: #0f766e;
  outline: none;
}

.modal-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
}

.cancel-btn,
.confirm-btn {
  padding: 8px 20px;
  border-radius: 20px;
  border: none;
  font-size: 14px;
  cursor: pointer;
}

.cancel-btn {
  background: #f8f9fa;
  color: #666;
}

.confirm-btn {
  background: linear-gradient(135deg, #0f766e 0%, #115e59 100%);
  color: white;
}

.confirm-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
}

/* VIP标识样式 */
.vip-badge {
  position: absolute;
  top: 10px;
  right: 10px;
  background: linear-gradient(45deg, #ffd700, #ffa500);
  color: white;
  font-size: 12px;
  padding: 4px 8px;
  border-radius: 8px;
  font-weight: bold;
  z-index: 10;
}
</style>
