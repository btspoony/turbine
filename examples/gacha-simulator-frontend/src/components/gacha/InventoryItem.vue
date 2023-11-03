<script setup lang="ts">
import type { PlayerInventoryItem } from '@flow/types';
import type { PropType } from 'vue';

defineProps({
  item: {
    type: Object as PropType<PlayerInventoryItem>,
    required: true,
  },
})
</script>

<template>
<div>
  {{ item.name }}
</div>
</template>
