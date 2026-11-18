import { defineStore } from 'pinia'
import { ref } from 'vue'
import { getDefaultExamType, getExamTypeByCode } from '@/utils/examTypes'

// 当前准驾车型，刷题和模拟考试都从这里取车型参数
export const useExamTypeStore = defineStore(
  'examType',
  () => {
    const examTypeCode = ref<string>(getDefaultExamType().code)

    const setExamType = (code: string) => {
      const type = getExamTypeByCode(code)
      if (type) {
        examTypeCode.value = type.code
      }
    }

    const getExamTypeCode = () => {
      return examTypeCode.value || getDefaultExamType().code
    }

    const getExamTypeName = () => {
      const type = getExamTypeByCode(getExamTypeCode())
      return type ? type.name : getDefaultExamType().name
    }

    return {
      examTypeCode,
      setExamType,
      getExamTypeCode,
      getExamTypeName,
    }
  },
  {
    persist: {
      storage: {
        getItem(key) {
          return uni.getStorageSync(key)
        },
        setItem(key, value) {
          uni.setStorageSync(key, value)
        },
      },
    },
  },
)
