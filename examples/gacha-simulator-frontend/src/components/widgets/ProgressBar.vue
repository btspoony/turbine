<template>
<div class="progress">
  <div class="indeterminate"></div>
</div>
</template>

<style scoped>
.progress {
  @apply w-full h-4 rounded-full overflow-hidden relative;
  @apply bg-[var(--theme-bg)];
}

.progress .indeterminate {
  @apply w-[50%] h-full bg-[var(--theme-bg-accent)];
  animation: progress 1.5s infinite linear;
}

@keyframes progress {
  0% {
    transform: translateX(-100%);
  }

  100% {
    transform: translateX(200%);
  }
}
</style>
