<script setup>
import { ref, computed } from 'vue'
import { darkTheme, NConfigProvider, NAvatar, NInput, NButton, NDropdown } from 'naive-ui'
import { useStorage } from '@vueuse/core'
import md5 from 'js-md5'

const userName = useStorage('x-app-username', '')
const editModeName = ref('')

const gravatarUrl = computed(() => {
  if (typeof userName.value === 'string') {
    const hash = md5(userName.value)
    return `https://www.gravatar.com/avatar/${hash}?d=identicon`
  } else {
    return null
  }
})

const dropdownOptions = ref([
  {
    label: 'Logout',
    key: 'logout',
  },
])

function handleDropdownCommand(command) {
  if (command === 'logout') {
    userName.value = null
  }
}

function handleConfirmName() {
  userName.value = editModeName.value;
}
</script>

<template>
<NConfigProvider :theme="darkTheme">
  <div class="flex items-center justify-between gap-2">
    <template v-if="!userName">
      <NInput v-model:value="editModeName" placeholder="Enter your name" round @keyup.enter="handleConfirmName" />
      <NButton type="primary" strong round @click="handleConfirmName">Confirm</NButton>
    </template>
    <NDropdown v-else trigger="click" :options="dropdownOptions" show-arrow @select="handleDropdownCommand">
      <div class="cursor-pointer flex items-center gap-2">
        <n-avatar round size="medium" :src="gravatarUrl" />
        <strong>{{ userName }}</strong>
      </div>
    </NDropdown>
  </div>
</NConfigProvider>
</template>
