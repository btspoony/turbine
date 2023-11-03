<script setup lang="ts">
import type { PlayerInventoryItem } from '@flow/types';
import type { PropType } from 'vue';
import { NCard, NTag } from 'naive-ui'

defineProps({
  item: {
    type: Object as PropType<PlayerInventoryItem>,
    required: true,
  },
})
</script>

<template>
<Transition name="slide-fade">
  <NCard :hoverable="true" size="small">
    <template #cover>
      <div class="w-35 h-35 object-cover object-top-center">
        <img :src="item.thumbnail" alt="item cover" />
      </div>
    </template>
    <span class="mt-1 text-sm line-clamp-2">{{ item.description }}</span>
    <div class="absolute top-0 left-0 p-1 w-full">
      <NTag
        :type="item.rarity === 5 ? 'warning' : item.rarity === 4 ? 'info' : undefined"
        :bordered="false"
        size="small"
        round
      >
        <div class="flex items-center gap-1">
          <span>{{ item.rarity }}</span>
          <div class="i-carbon:star-filled text-lg" />
          <div :class="['text-lg', item.category === 0 ? (item.rarity === 5 ? 'i-carbon:face-cool' : 'i-carbon:face-wink-filled') : 'i-carbon:cube']" />
        </div>
      </NTag>
    </div>
  </NCard>
</Transition>
</template>

<style scoped>
.n-card {
  @apply w-35 min-h-50 relative;
}
</style>
