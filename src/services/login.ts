import { http } from "@/utils/http"
import type { LoginResult } from '@/types/member'

type LoginParams = {
    code: string,
    encryptedData: string,
    iv: string,
    codeev: string,
	type: string
}

type LoginAppParams = {
    code: string
}

export const postLoginWxMinAPI = (data: LoginParams) => {
    return http<LoginResult>({
        method: 'POST',
        url: '/login/wxMin',
        data
    })
}

export const postLoginWxAppAPI = (data: LoginAppParams) => {
    console.log('data====', data)
    return http<LoginResult>({
        method: 'POST',
        url: '/login/loginWxApp',
        data
    })
}

// 发送验证码
export const postSendVerifyCodeAPI = (mobile: string) => {
    return http<LoginResult>({
        method: 'GET',
        url: '/login/sendCode?mobile='+mobile
    })
}

// 验证码登录
export const postVerifyCodeLoginAPI = (mobile: string, code: string) => {
    return http<LoginResult>({
        method: 'POST',
        url: '/login/verifyCodeLogin?mobile='+mobile+'&code='+code
    })
}

/**
 * 小程序登录内测
 * @param phoneNumber 模拟手机号
 * @returns
 */
export const postLoginWxMinSimpleAPI = (phoneNumber: string) => {
    return http<LoginResult>({
        method: 'POST',
        url: '/login/wxMin/simple?phoneNumber='+phoneNumber,
    })
}
