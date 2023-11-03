<script setup lang="ts">
import { ref, computed } from 'vue'
import { useFetch, useStorage } from '@vueuse/core'
import { NButton } from 'naive-ui'
import type { GachaPool, PlayerInventoryItem } from '@flow/types.js'
import ProgressBar from '@components/widgets/ProgressBar.vue'
import InventoryItem from './InventoryItem.vue'

const userName = useStorage('x-app-username', '')

const { data: listedPools, isFetching } = await useFetch('/api/gacha/pools').get().json<{ list: GachaPool[] }>()
const currentPool = computed<GachaPool>(() => listedPools.value?.list?.[0])

const responseTxid = ref<string>(null);
const isLoading = ref(false)
const isActionAvailable = computed(() => !isLoading.value && !!currentPool.value)
const pulledInventoryItems = ref<PlayerInventoryItem[]>([])

async function pull(times: number) {
  if (isActionAvailable.value === false) {
    return
  }
  if (!userName.value) {
    alert('Please set your username first!')
    return
  }

  isLoading.value = true
  pulledInventoryItems.value = []

  const url = `/api/gacha/${currentPool.value.world}/${currentPool.value.poolId}`
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-app-username': userName.value,
    },
    body: JSON.stringify({
      times,
    })
  }).then(res => res.json())

  if (response?.ok && typeof response?.txid === 'string') {
    responseTxid.value = response.txid
  }
  console.log(`Called ${url} - Response: `, response)
  await tryRevealTx()
}

async function tryRevealTx() {
  if (!responseTxid.value) {
    return
  }

  const url = `/api/gacha/reveal`
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-app-username': userName.value,
    },
    body: JSON.stringify({
      txids: [responseTxid.value],
    })
  }).then(res => res.json())

  if (response?.ok) {
    console.log(`Called ${url} - Response: `, response)
    if (response.batch?.[responseTxid.value] && Array.isArray(response.batch?.[responseTxid.value]?.items)) {
      isLoading.value = false
      pulledInventoryItems.value = response.batch?.[responseTxid.value]?.items
        ?.filter((one: PlayerInventoryItem) => typeof one.thumbnail === 'string')
      return
    }
  }
  // try again
  setTimeout(tryRevealTx, 500)
}
</script>

<template>
<main class="container m-a">
  <section
    v-if="!isFetching"
    class="p-4 flex flex-col items-center gap-4"
  >
    <h2 class="mb-0">Gacha Simulator For {{ currentPool?.poolName }}</h2>
    <div class="relative object-cover h-80">
      <img src="/social-image.png" alt="Hero Image">
      <div class="absolute bottom-0 h-16 w-full" v-if="currentPool">
        <div class="h-full flex items-center justify-around gap-4">
          <NButton round type="primary" strong size="large" :disabled="!isActionAvailable" :loading="isLoading" @click="pull(1)">
            <template #icon>
              <div class="i-carbon:ticket w-5 h-5"></div>
            </template>
            Pull &nbsp;<span class="font-bold">x 1</span>
          </NButton>
          <NButton round type="primary" strong size="large" :disabled="!isActionAvailable" :loading="isLoading" @click="pull(10)">
            <template #icon>
              <div class="i-carbon:ticket w-5 h-5"></div>
            </template>
            Pull &nbsp;<span class="font-bold">x 10</span>
          </NButton>
        </div>
      </div>
    </div>
    <div v-if="responseTxid" class="relative w-3xl">
      <div v-if="isLoading" class="flex flex-col items-center">
        <h5>Response Txid: {{ responseTxid }}</h5>
        <ProgressBar />
      </div>
      <div v-else class="flex items-center justify-start gap-4">
        <InventoryItem v-for="item in pulledInventoryItems" :key="item.id" :item="item" />
      </div>
    </div>
  </section>
  <section class="mx-a mt-4 max-w-4xl flex flex-col items-center gap-2">
    <h3 class="mb-4">Transaction History</h3>
  </section>
</main>
</template>
