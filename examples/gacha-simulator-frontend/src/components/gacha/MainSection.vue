<script setup lang="ts">
// import { ref, computed } from 'vue'
import { useStorage } from '@vueuse/core'

const userName = useStorage('x-app-username', '')
</script>

<template>
<main class="container m-a">
  <div class="flex items-center justify-center">
    USER
  </div>
</main>
</template>
