import { http } from "@/utils/http"

export const poAPI = (data: any) => {
    return http({
        method: 'GET',
        url: '/chatai/deepseek',
        data
    })
}
