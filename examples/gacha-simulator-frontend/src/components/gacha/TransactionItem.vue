<script setup lang="ts">
import { computed, type PropType } from 'vue';
import type { GachaResult } from '@flow/types';
import { NTag } from 'naive-ui';

const props = defineProps({
  txid: String,
  result: {
    type: Object as PropType<GachaResult | null>,
    required: false,
  },
})

const simpleTxid = computed(() => {
  return props.txid.substring(0, 10) + '...' + props.txid.substring(props.txid.length - 10)
})
const rarityCounts = computed<Record<string, number>>(() => {
  const counts = {}
  if (!props.result?.items) {
    return counts
  }
  props.result?.items.forEach(item => {
    if (!counts[item.rarity]) {
      counts[item.rarity] = 0
    }
    counts[item.rarity]++
  })
  return counts
})
</script>

<template>
<div class="w-full flex items-center justify-between p-2 rounded border border-[var(--theme-bg-hover)]">
  <div class="text-sm">
    {{ simpleTxid }} -
    <template v-if="result">
      {{ result?.username }}
      <NTag round size="small" :type="result?.items.length === 1 ? 'warning' : 'success'" :bordered="false">
        x{{ result?.items.length }}
      </NTag>
    </template>
  </div>
  <div class="flex gap-2">
    <div v-for="amt, r in rarityCounts" :key="r"
      :class="[r === '5' ? 'text-[var(--theme-text-accent)]' : r === '3' ? 'text-[var(--theme-text-lighter)]' : '']">
      {{ r }}★ x {{ amt }}
    </div>
  </div>
</div>
</template>
