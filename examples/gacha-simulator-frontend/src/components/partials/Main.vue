<script setup lang="ts">
import { computed, h, ref } from 'vue';
import { darkTheme, NConfigProvider, NMenu } from 'naive-ui'
import type { MenuOption } from 'naive-ui'
import GachaPullSection from '@components/gacha/GachaPullSection.vue';
import TransactionHistorySection from '@components/gacha/TransactionHistorySection.vue'
import InventorySection from '@components/gacha/InventorySection.vue';
import { useFetch } from '@vueuse/core';
import type { GachaPool } from '@flow/types';

const { data: listedPools, isFetching } = useFetch('/api/gacha/pools').get().json<{ list: GachaPool[] }>()
const currentPool = computed<GachaPool>(() => listedPools.value?.list?.[0])

const history = ref<InstanceType<typeof TransactionHistorySection> | null>(null)

async function onHistoryUpdate() {
  await history.value?.refresh()
}

const menus: MenuOption[] = [
  {
    label: 'Gacha Simulator',
    key: 'gacha',
    icon: () => h('div', {
      class: 'w-5 h-5 i-carbon:stacked-scrolling-1'
    })
  },
  {
    label: 'Player Inventory',
    key: 'inventory',
    icon: () => h('div', {
      class: 'w-5 h-5 i-carbon:document'
    })
  },
]
const activeKey = ref<'gacha' | 'inventory'>('gacha')
</script>

<template>
<NConfigProvider :theme="darkTheme">
  <NMenu v-model:value="activeKey" mode="horizontal" :options="menus" />
  <template v-if="activeKey === 'gacha'">
    <GachaPullSection :current-pool="currentPool" @update:history="onHistoryUpdate" />
    <TransactionHistorySection ref="history" />
  </template>
  <template v-else>
    <InventorySection :current-pool="currentPool"/>
  </template>
</NConfigProvider>
</template>
