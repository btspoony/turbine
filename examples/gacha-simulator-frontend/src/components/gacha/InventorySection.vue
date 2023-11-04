<script setup lang="ts">
import { ref, type PropType, onMounted, watch, computed } from 'vue';
import { NPagination } from 'naive-ui'
import { useGlobalUsername } from '@components/utils/shared';
import { getInventroy } from '@components/utils/api';
import type { GachaPool, PlayerInventoryItem } from '@flow/types';
import InventoryItem from './InventoryItem.vue'

const props = defineProps({
  currentPool: {
    type: Object as PropType<GachaPool>,
    required: false,
  },
})

const userName = useGlobalUsername()
const inventoryItems = ref<PlayerInventoryItem[]>([])
const pageSize = ref<number>(20)
const currPage = ref<number>(1)
const total = computed(() => inventoryItems.value.length)
const currentPageItems = computed(() => {
  const start = (currPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return inventoryItems.value.slice(start, end)
})

watch(userName, async (newVal, oldVal) => {
  if (newVal === oldVal) {
    return
  } else if (!newVal) {
    inventoryItems.value = []
    currPage.value = 1
    return
  }
  await fetchInventory()
})

async function fetchInventory() {
  if (!props.currentPool || !userName.value) {
    return
  }
  const response = await getInventroy(props.currentPool.world, userName.value)
  if (response.ok && Array.isArray(response.list)) {
    const list = response.list as PlayerInventoryItem[]
    list.sort((a, b) => b.rarity - a.rarity)
    inventoryItems.value = list
    currPage.value = 1
  }
  return response
}

onMounted(async () => {
  await fetchInventory()
})
</script>

<template>
<section class="mx-a mt-4 flex flex-col gap-2">
  <h3 v-if="!!userName">Inventory of <span class="text-[var(--theme-text-accent)]">{{ userName }}</span></h3>
  <h3 v-else> No User </h3>
  <NPagination
    v-model:page="currPage"
    v-model:page-size="pageSize"
    :item-count="total"
    :page-sizes="[10, 20, 50]"
    show-size-picker
  />
  <div class="mt-2 flex flex-wrap items-center justify-start gap-4">
    <InventoryItem v-for="item in currentPageItems" :key="item.id" :item="item" />
  </div>
</section>
</template>
