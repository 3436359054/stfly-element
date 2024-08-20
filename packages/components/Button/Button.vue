<script setup lang="ts">
import { computed, ref, inject } from 'vue'

import type { ButtonProps, ButtonEmits, ButtonInstance } from "./types";
import { BUTTON_GROUP_CTX_KEY } from "./constants";
import { throttle } from 'lodash-es';
import FlyIcon from "../Icon/Icon.vue";

defineOptions({
  name: 'FlyButton',
})
const props = withDefaults(defineProps<ButtonProps>(), {
  tag: 'button',
  nativeType: 'button',
  useThrottle: true,
  throttleDuration: 500,
})
const emits = defineEmits<ButtonEmits>();

const slots = defineSlots();
const buttonGroupCtx = inject(BUTTON_GROUP_CTX_KEY, void 0);

const _ref = ref<HTMLButtonElement>();
const size = computed(() => buttonGroupCtx?.size ?? props.size ?? "");
const type = computed(() => buttonGroupCtx?.type ?? props.type ?? "");
const disabled = computed(
  () => props.disabled || buttonGroupCtx?.disabled || false
);
 
defineExpose<ButtonInstance>({
  ref: _ref,
  disabled,
  size,
  type,
});

const iconStyle = computed(() => ({
  marginRight: slots.default ? "6px" : "0px"
}))

const handleBtnClick = (e: MouseEvent) => {
  emits("click", e);
}

const handlBtneCLickThrottle = throttle(
  handleBtnClick, 
  props.throttleDuration,
  { trailing: false }
);

</script>
<template>
  <component 
    :is="tag" 
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
    :autofocus="autofocus"
    @click="
      (e: MouseEvent) => 
        useThrottle ? handlBtneCLickThrottle(e) : handleBtnClick(e)
    "
  >
  <template v-if="loading">
      <slot name="loading">
        <fly-icon
          class="loading-icon"
          :icon="loadingIcon ?? 'spinner'"
          :style="iconStyle"
          size="1x"
          spin
        />
      </slot>
    </template>
    <fly-icon
      :icon="icon"
      size="1x"
      :style="iconStyle"
      v-if="icon && !loading"
    />
    <slot></slot>
  </component>
</template>
<style scoped>
@import './style.css';
</style>
