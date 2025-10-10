import { useExamTypeStore } from '@/stores/modules/examType'

// 获取当前选择的车型
export const getCurrentExamType = () => {
  const examTypeStore = useExamTypeStore()
  return examTypeStore.getExamTypeCode()
}

// 获取车型参数字符串，用于API请求
export const getExamTypeParam = () => {
  const examType = getCurrentExamType()
  return examType ? `&examType=${examType}` : ''
}

// 构造带车型参数的URL
export const buildUrlWithExamType = (
  baseUrl: string,
  subject: number,
  questionType: string = '',
) => {
  const examType = getCurrentExamType()
  let url = `${baseUrl}?subject=${subject}`

  if (examType) {
    url += `&examType=${examType}`
  }

  if (questionType) {
    url += `&questionType=${questionType}`
  }

  return url
}
