<script setup>
import { useAuthStore } from '@/stores/auth.js'
import { useRouter } from 'vue-router'
import { LogOut, LayoutDashboard, ClipboardList, Settings } from 'lucide-vue-next'

const auth = useAuthStore()
const router = useRouter()

async function logout() {
  await auth.logout()
  router.push('/login')
}
</script>

<template>
  <nav class="fixed top-0 left-0 right-0 z-50 bg-[#0a0a0a]/95 backdrop-blur-md border-b border-white/5">
    <div class="max-w-5xl mx-auto px-4 h-16 flex items-center justify-between">
      <!-- Logo -->
      <RouterLink to="/" class="font-['Bebas_Neue'] text-xl tracking-widest text-white hover:text-red-400 transition-colors">
        RADU <span class="text-red-500">MOCUȚA</span>
      </RouterLink>

      <!-- Nav links -->
      <div class="flex items-center gap-1">
        <RouterLink
          v-if="auth.isAdmin"
          to="/admin"
          class="flex items-center gap-1.5 px-3 py-2 rounded-lg text-xs font-semibold uppercase tracking-wider transition-colors"
          :class="$route.path.startsWith('/admin') ? 'text-red-400 bg-red-500/10' : 'text-gray-400 hover:text-white'"
        >
          <Settings :size="14" /> Admin
        </RouterLink>
        <RouterLink
          v-else
          to="/"
          class="flex items-center gap-1.5 px-3 py-2 rounded-lg text-xs font-semibold uppercase tracking-wider transition-colors"
          :class="$route.path === '/' ? 'text-red-400 bg-red-500/10' : 'text-gray-400 hover:text-white'"
        >
          <LayoutDashboard :size="14" /> Dashboard
        </RouterLink>
        <RouterLink
          to="/checkin"
          class="flex items-center gap-1.5 px-3 py-2 rounded-lg text-xs font-semibold uppercase tracking-wider transition-colors"
          :class="$route.path === '/checkin' ? 'text-red-400 bg-red-500/10' : 'text-gray-400 hover:text-white'"
        >
          <ClipboardList :size="14" /> Check-in
        </RouterLink>

        <!-- User + logout -->
        <div class="flex items-center gap-2 ml-2 pl-2 border-l border-white/10">
          <span class="text-xs text-gray-500 hidden sm:block">{{ auth.profile?.full_name || auth.user?.email }}</span>
          <button @click="logout" class="p-2 rounded-lg text-gray-500 hover:text-red-400 hover:bg-red-500/10 transition-colors" title="Ieși din cont">
            <LogOut :size="16" />
          </button>
        </div>
      </div>
    </div>
  </nav>
</template>
