import { useMemberStore } from "@/stores";

// const baseURL = 'http://localhost:8089'
// const baseURL = 'http://8.152.154.153:8089'
const baseURL = 'http://localhost:8081/api'
// const baseURL = 'https://www.codevateai.cn/prod-api'

// 添加拦截器
const httpInterceptor = {
    // 拦截前触发
    invoke(options: UniApp.RequestOptions) {
        // 1 非http开头需拼接地址
        if (!options.url.startsWith('http')) {
            options.url = baseURL + options.url
        }
        // 2 请求超时，默认60秒
        options.timeout = 10000
        console.log('options:', options);
        // 3 添加小程序端请求头标识
        options.header = {
            ...options.header,
            "source-client": "miniapp"
        }
        // 4 添加token请求头标识
        const memberStore = useMemberStore()
        console.log('memberStore:', memberStore);
        const token = memberStore.profile?.token
        if (token) {
            options.header.Authorization = token
        }
        console.log('token:', token);
    },
}

uni.addInterceptor('request', httpInterceptor)
uni.addInterceptor('uploadFile', httpInterceptor)

/**
 * 请求函数
 */
export const http = <T>(options: UniApp.RequestOptions) => {
    // 1 返回 Promise 对象
    return new Promise<Data<T>>((resolve, reject) => {
        uni.request({
            ...options,
            // 2 请求成功
            success(result) {
                console.log('result:', result);

                // 状态码 2xx
                if (result.statusCode >= 200 && result.statusCode < 300) {
                    // 提取核心数据
                    resolve(result.data as Data<T>)
                } else if (result.statusCode == 401) {
                    // 401 未登录
                    const memberStore = useMemberStore()
                    memberStore.clearProfile()
                    uni.navigateTo({ url: '/pages/login/login' })
                    reject(result)
                } else {
                    uni.showToast({
                        icon: 'none',
                        title: (result.data as Data<T>).msg || '请求失败'
                    })
                    reject(result)
                }
            },
            // 响应失败
            fail(error) {
                uni.showToast({
                    icon: 'none',
                    title: '网络错误，换个网络试试'
                })
                reject(error)
            }
        })
    })
}

interface Data<T> {
    code: number
    msg: string
    data: T
}
