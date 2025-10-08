import { useMemberStore } from '@/stores'
import { http } from '@/utils/http'

/**
 * 检查会员状态工具类
 */
class VipChecker {
  // 缓存上次检查时间，避免频繁调用接口
  private lastCheckTime: number = 0
  // 缓存检查结果的有效期（毫秒），设置为5分钟
  private cacheValidityPeriod: number = 5 * 60 * 1000

  /**
   * 检查会员状态
   * @param force 是否强制检查，忽略缓存
   * @returns 会员状态检查结果
   */
  async checkVipStatus(force: boolean = false): Promise<boolean> {
    const memberStore = useMemberStore()

    // 如果没有用户信息，直接返回false
    if (!memberStore.profile) {
      return false
    }

    // 如果不是强制检查，且缓存未过期，则直接使用当前状态
    const currentTime = Date.now()
    if (!force && currentTime - this.lastCheckTime < this.cacheValidityPeriod) {
      return memberStore.profile.vipLevel > 0
    }

    try {
      // 调用后端接口检查会员状态
      const res = await http({
        url: '/login/checkVipStatus',
        method: 'GET',
      })

      // 更新本地会员状态
      if (res.data && memberStore.profile) {
        memberStore.profile.vipLevel = res.data.vipLevel
        memberStore.profile.vipExpireTime = res.data.vipExpireTime
      }

      // 更新最后检查时间
      this.lastCheckTime = currentTime

      // 返回最新的会员状态
      return res.data.vipLevel > 0
    } catch (error) {
      console.error('检查会员状态失败:', error)
      // 如果检查失败，默认保持当前状态
      return memberStore.profile.vipLevel > 0
    }
  }

  /**
   * 检查是否需要VIP权限并验证会员状态
   * @param needVip 是否需要VIP权限
   * @returns 如果需要VIP且不是VIP用户，返回false；否则返回true
   */
  async checkVipAccess(needVip: boolean): Promise<boolean> {
    // 如果不需要VIP权限，直接返回true
    if (!needVip) {
      return true
    }

    // 检查会员状态
    const isVip = await this.checkVipStatus()

    if (!isVip) {
      // 显示开通VIP弹窗或跳转到会员页面
      uni.navigateTo({
        url: '/pages/member-center/member-center',
      })
      return false
    }

    return true
  }
}

// 导出单例实例
export const vipChecker = new VipChecker()
