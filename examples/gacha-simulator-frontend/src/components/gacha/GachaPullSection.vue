<script setup lang="ts">
import { ref, computed, type PropType } from 'vue'
import { NButton } from 'naive-ui'
import type { GachaPool, PlayerInventoryItem } from '@flow/types.js'
import { revealTxids } from '@components/utils/api.js'
import { useGlobalUsername } from '@components/utils/shared.js'
import ProgressBar from '@components/widgets/ProgressBar.vue'
import InventoryItem from '@components/gacha/InventoryItem.vue'

const emit = defineEmits<{
  (e: 'update:history'): void
}>()

const props = defineProps({
  currentPool: {
    type: Object as PropType<GachaPool>,
    required: false,
  },
})

const userName = useGlobalUsername()

const responseTxid = ref<string>(null);
const isLoading = ref(false)
const isActionAvailable = computed(() => !!props.currentPool && !isLoading.value && !!userName.value)
const pulledInventoryItems = ref<PlayerInventoryItem[]>([])

async function pull(times: number) {
  if (isActionAvailable.value === false) {
    return
  }
  if (!userName.value) {
    alert('Please set your username first!')
    return
  }

  responseTxid.value = null
  isLoading.value = true
  pulledInventoryItems.value = []

  const url = `/api/gacha/${props.currentPool.world}/${props.currentPool.poolId}`
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

  const response = await revealTxids([responseTxid.value])
  if (response?.ok) {
    if (response.batch?.[responseTxid.value] && Array.isArray(response.batch?.[responseTxid.value]?.items)) {
      isLoading.value = false
      pulledInventoryItems.value = response.batch?.[responseTxid.value]?.items
        ?.filter((one: PlayerInventoryItem) => typeof one.thumbnail === 'string')
      // refresh history
      emit('update:history')
      return
    }
  }
  // try again
  setTimeout(tryRevealTx, 500)
}
</script>

<template>
<section v-if="currentPool" class="p-4 flex flex-col items-center gap-4">
  <h2 class="mb-0">Gacha Simulator For {{ currentPool?.poolName }}</h2>
  <div class="relative object-cover h-80">
    <img src="/social-image.png" alt="Hero Image">
    <div class="absolute bottom-0 h-16 w-full" v-if="currentPool">
      <div class="h-full flex items-center justify-around gap-4">
        <NButton round type="primary" strong size="large" :disabled="!isActionAvailable" :loading="isLoading"
          @click="pull(1)">
          <template #icon>
            <div class="i-carbon:ticket w-5 h-5"></div>
          </template>
          Pull &nbsp;<span class="font-bold">x 1</span>
        </NButton>
        <NButton round type="primary" strong size="large" :disabled="!isActionAvailable" :loading="isLoading"
          @click="pull(10)">
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
    <div v-else class="flex flex-wrap items-center justify-start gap-4">
      <InventoryItem v-for="item in pulledInventoryItems" :key="item.id" :item="item" />
    </div>
  </div>
</section>
</template>
