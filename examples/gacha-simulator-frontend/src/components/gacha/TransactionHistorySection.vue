<script setup lang="ts">
import { onMounted, reactive } from 'vue';
import { useFetch } from '@vueuse/core';
import type { GachaResult } from '@flow/types';
import { revealTxids } from '@components/utils/api.js'
import TransactionItem from './TransactionItem.vue';

defineExpose({
  refresh: async () => {
    await revealHistory()
  },
})

const { data, execute } = useFetch('/api/history/transactions', { immediate: false }).get().json<{ list: string[] }>()

const dataBatch = reactive<Record<string, GachaResult>>({})

async function revealHistory() {
  await execute()
  if (!data.value?.list) return

  const response = await revealTxids(data.value.list)
  if (response?.ok && typeof response?.batch === 'object') {
    for (const key in response.batch) {
      dataBatch[key] = response.batch[key]
    }
  }
}

onMounted(async () => {
  await revealHistory()
})

</script>

<template>
<section class="mx-a mt-4 max-w-4xl flex flex-col items-center gap-2">
  <h3 class="mb-4">Transaction History</h3>
  <div v-for="txid in data?.list" :key="txid" class="w-3xl">
    <TransactionItem :txid="txid" :result="dataBatch[txid]" />
  </div>
</section>
</template>
