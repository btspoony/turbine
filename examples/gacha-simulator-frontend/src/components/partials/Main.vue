<script setup lang="ts">
import { ref } from 'vue';
import { darkTheme, NConfigProvider } from 'naive-ui'
import GachaPullSection from '@components/gacha/GachaPullSection.vue';
import TransactionHistorySection from '@components/gacha/TransactionHistorySection.vue'

const history = ref<InstanceType<typeof TransactionHistorySection> | null>(null)

async function onHistoryUpdate() {
  await history.value?.refresh()
}
</script>

<template>
<NConfigProvider :theme="darkTheme">
  <main class="container m-a">
    <GachaPullSection @update:history="onHistoryUpdate" />
    <TransactionHistorySection ref="history" />
  </main>
</NConfigProvider>
</template>
