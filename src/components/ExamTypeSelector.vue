<template>
  <view class="exam-type-selector">
    <!-- 选择按钮 -->
    <view class="selector-trigger" @click="handleShowSelector" v-if="false">
      <text class="selected-type">{{ currentExamTypeName }}</text>
      <text class="arrow">▼</text>
    </view>

    <!-- 选择弹窗 -->
    <view v-if="showSelector" class="selector-modal" @click="showSelector = false">
      <view class="selector-content" @click.stop>
        <view class="selector-header">
          <text class="header-title">选择准驾车型</text>
          <text class="close-btn" @click="showSelector = false">×</text>
        </view>

        <scroll-view class="selector-body" scroll-y>
          <view v-for="(group, groupName) in examTypeGroups" :key="groupName" class="group">
            <view class="group-header">{{ group.name }}</view>
            <view class="type-grid">
              <view
                v-for="type in group.types"
                :key="type.code"
                class="type-item"
                :class="{ active: type.code === tempSelectedType }"
                @click="selectExamType(type.code)"
              >
                <text class="type-code">{{ type.code }}</text>
                <text class="type-name">{{ type.name.replace(type.code, '').trim() }}</text>
              </view>
            </view>
          </view>
        </scroll-view>

        <view class="selector-footer">
          <button class="confirm-btn" @click="confirmSelection">确定</button>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import { useExamTypeStore } from '@/stores/modules/examType'
import { ExamTypeGroups } from '@/utils/examTypes'

// 使用车型store
const examTypeStore = useExamTypeStore()

// 控制选择器显示
const showSelector = ref(false)

// 当前选择的车型代码
const currentExamTypeCode = computed(() => {
  return examTypeStore.getExamTypeCode()
})

// 当前选择的车型名称
const currentExamTypeName = computed(() => {
  return examTypeStore.getExamTypeName()
})

// 车型分组
const examTypeGroups = ExamTypeGroups

// 临时选择的车型
const tempSelectedType = ref(currentExamTypeCode.value)

// 选择车型
const selectExamType = (code: string) => {
  tempSelectedType.value = code
}

// 确认选择
const confirmSelection = () => {
  examTypeStore.setExamType(tempSelectedType.value)
  showSelector.value = false
  // 选择完成后重置临时状态
  setTimeout(() => {
    tempSelectedType.value = currentExamTypeCode.value
  }, 0)
}

// 处理显示选择器事件
const handleShowSelector = () => {
  // 重置临时选择为当前选择
  tempSelectedType.value = currentExamTypeCode.value
  showSelector.value = true
}

// 组件挂载时监听事件
onMounted(() => {
  window.addEventListener('showExamTypeSelector', handleShowSelector)
})

// 组件卸载时移除事件监听
onUnmounted(() => {
  window.removeEventListener('showExamTypeSelector', handleShowSelector)
})

// 定义组件的defineExpose，允许父组件调用方法
defineExpose({
  showSelector: showSelector,
  handleShowSelector,
})
</script>

<style scoped lang="scss">
.exam-type-selector {
  display: inline-block;
}

.selector-trigger {
  display: flex;
  align-items: center;
  padding: 8px 12px;
  background: #f5f5f5;
  border-radius: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.selector-trigger:hover {
  background: #e0e0e0;
}

.selected-type {
  font-size: 14px;
  color: #333;
  margin-right: 5px;
}

.arrow {
  font-size: 12px;
  color: #999;
  transition: transform 0.3s ease;
}

.selector-trigger:hover .arrow {
  transform: rotate(180deg);
}

.selector-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.selector-content {
  background: white;
  border-radius: 15px;
  width: 100%;
  max-width: 400px;
  max-height: 80vh;
  display: flex;
  flex-direction: column;
}

.selector-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 15px 15px 0 0;
}

.header-title {
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

.selector-body {
  flex: 1;
  padding: 20px;
  max-height: calc(80vh - 140px);
}

.group {
  margin-bottom: 20px;
}

.group-header {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 15px;
  padding-bottom: 8px;
  border-bottom: 1px solid #f0f0f0;
}

.type-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 10px;
}

.type-item {
  padding: 15px 10px;
  background: #f8f9fa;
  border-radius: 10px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 2px solid transparent;
}

.type-item:hover {
  background: #e9ecef;
  transform: translateY(-2px);
}

.type-item.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-color: #667eea;
}

.type-code {
  display: block;
  font-size: 16px;
  font-weight: bold;
  margin-bottom: 5px;
}

.type-name {
  display: block;
  font-size: 12px;
  opacity: 0.9;
}

.selector-footer {
  padding: 20px;
  border-top: 1px solid #f0f0f0;
}

.confirm-btn {
  width: 100%;
  padding: 15px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.confirm-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
}
</style>
