<script setup>
import { useAuthStore } from '@/stores/auth.js'
import { useRouter, useRoute } from 'vue-router'
import {
  LayoutDashboard, Users, BookOpen, ClipboardList,
  LogOut, ChevronRight, Menu, X
} from 'lucide-vue-next'
import { ref } from 'vue'

const auth = useAuthStore()
const router = useRouter()
const route = useRoute()
const mobileOpen = ref(false)

const navItems = [
  { path: '/admin', label: 'Dashboard', icon: LayoutDashboard, exact: true },
  { path: '/admin/clienti', label: 'Clienti', icon: Users },
  { path: '/admin/module', label: 'Module', icon: BookOpen },
  { path: '/admin/checkins', label: 'Check-in-uri', icon: ClipboardList },
]

function isActive(item) {
  if (item.exact) return route.path === item.path
  return route.path.startsWith(item.path)
}

async function logout() {
  await auth.logout()
  router.push('/login')
}
</script>

<template>
  <div class="min-h-screen bg-[#09090b] flex">

    <!-- Desktop Sidebar -->
    <aside class="hidden lg:flex flex-col w-[260px] border-r border-white/[0.06] bg-[#0c0c0e] flex-shrink-0 fixed inset-y-0 left-0 z-40">

      <!-- Logo -->
      <div class="h-16 flex items-center px-6 border-b border-white/[0.06]">
        <RouterLink to="/admin" class="flex items-center gap-2.5">
          <div class="w-8 h-8 rounded-lg bg-red-500 flex items-center justify-center">
            <span class="text-white font-bold text-sm">R</span>
          </div>
          <span class="font-semibold text-[15px] text-white tracking-tight">Radu Coaching</span>
        </RouterLink>
      </div>

      <!-- Nav -->
      <nav class="flex-1 px-3 py-4 space-y-1">
        <RouterLink
          v-for="item in navItems" :key="item.path"
          :to="item.path"
          class="group flex items-center gap-3 px-3 py-2.5 rounded-lg text-[13px] font-medium transition-all duration-150"
          :class="isActive(item)
            ? 'bg-white/[0.08] text-white'
            : 'text-zinc-400 hover:text-white hover:bg-white/[0.04]'"
        >
          <component :is="item.icon" :size="18" :class="isActive(item) ? 'text-red-400' : 'text-zinc-500 group-hover:text-zinc-300'" />
          {{ item.label }}
          <ChevronRight v-if="isActive(item)" :size="14" class="ml-auto text-zinc-500" />
        </RouterLink>
      </nav>

      <!-- User -->
      <div class="border-t border-white/[0.06] p-4">
        <div class="flex items-center gap-3 mb-3">
          <div class="w-9 h-9 rounded-full bg-gradient-to-br from-red-500 to-orange-500 flex items-center justify-center text-white text-xs font-bold">
            {{ (auth.profile?.full_name || 'A')[0].toUpperCase() }}
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-medium text-white truncate">{{ auth.profile?.full_name || 'Admin' }}</p>
            <p class="text-xs text-zinc-500 truncate">{{ auth.user?.email }}</p>
          </div>
        </div>
        <button @click="logout"
          class="w-full flex items-center justify-center gap-2 px-3 py-2 rounded-lg text-xs font-medium text-zinc-400 hover:text-red-400 hover:bg-red-500/[0.08] border border-white/[0.06] transition-all duration-150">
          <LogOut :size="14" />
          Deconectare
        </button>
      </div>
    </aside>

    <!-- Mobile Header -->
    <div class="lg:hidden fixed top-0 left-0 right-0 z-50 h-14 bg-[#0c0c0e]/95 backdrop-blur-xl border-b border-white/[0.06] flex items-center justify-between px-4">
      <div class="flex items-center gap-2.5">
        <div class="w-7 h-7 rounded-md bg-red-500 flex items-center justify-center">
          <span class="text-white font-bold text-xs">R</span>
        </div>
        <span class="font-semibold text-sm text-white">Radu Coaching</span>
      </div>
      <button @click="mobileOpen = !mobileOpen" class="p-2 rounded-lg text-zinc-400 hover:text-white hover:bg-white/[0.06]">
        <Menu v-if="!mobileOpen" :size="20" />
        <X v-else :size="20" />
      </button>
    </div>

    <!-- Mobile Menu Overlay -->
    <Transition name="slide">
      <div v-if="mobileOpen" class="lg:hidden fixed inset-0 z-40 bg-black/60 backdrop-blur-sm" @click="mobileOpen = false">
        <div class="absolute top-14 left-0 right-0 bg-[#0c0c0e] border-b border-white/[0.06] p-3 space-y-1" @click.stop>
          <RouterLink
            v-for="item in navItems" :key="item.path"
            :to="item.path"
            @click="mobileOpen = false"
            class="flex items-center gap-3 px-4 py-3 rounded-lg text-sm font-medium transition-all"
            :class="isActive(item) ? 'bg-white/[0.08] text-white' : 'text-zinc-400'"
          >
            <component :is="item.icon" :size="18" :class="isActive(item) ? 'text-red-400' : 'text-zinc-500'" />
            {{ item.label }}
          </RouterLink>
          <button @click="logout(); mobileOpen = false"
            class="w-full flex items-center gap-3 px-4 py-3 rounded-lg text-sm font-medium text-zinc-400 hover:text-red-400">
            <LogOut :size="18" class="text-zinc-500" />
            Deconectare
          </button>
        </div>
      </div>
    </Transition>

    <!-- Main content -->
    <main class="flex-1 lg:ml-[260px] min-h-screen">
      <div class="pt-14 lg:pt-0">
        <slot />
      </div>
    </main>
  </div>
</template>

<style scoped>
.slide-enter-active, .slide-leave-active { transition: opacity 0.2s ease; }
.slide-enter-from, .slide-leave-to { opacity: 0; }
</style>
