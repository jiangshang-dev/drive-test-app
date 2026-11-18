/** 小程序登录 登录用户信息 */
export type LoginResult = {
  /** 用户ID */
  id: number
  /** 头像  */
  avatar: string
  /** 账户名  */
  account: string
  /** 昵称 */
  nickname?: string
  /** 手机号 */
  mobile: string
  /** 登录凭证 */
  token: string
  /** VIP等级 */
  vipLevel?: number
  /** VIP到期时间 */
  vipExpireTime?: string
  /** 积分 */
  integral?: number
  /** 用户等级 */
  level?: number
}
