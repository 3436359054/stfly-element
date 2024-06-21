<script setup lang="ts">
import { ref } from 'vue'
import type { ButtonProps } from './types.ts'
defineOptions({
  name: 'FlyButton',
})
const props = withDefaults(defineProps<ButtonProps>(), {
  tag: 'button',
  nativeType: 'button'
})
const slot = defineSlots();
const _ref = ref<HTMLButtonElement>()
</script>
<template>
  <component 
    :is="props.tag" 
    :ref="_ref"
    class="fly-button"
    :type="tag === 'button' ? nativeType : undefined" 
    :disabled="disabled || loading ? true : undefined"
    :class="{
      [`fly-button--${type}`]: type,
      [`fly-button--${size}`]: size,
      'is-plain': plain,
      'is-round': round,
      'is-circle': circle,
      'is-disabled': disabled,
      'is-loading': loading
    }"
  >
    <slot></slot>
  </component>
</template>
<style scoped>
@import './style.css';
</style>
