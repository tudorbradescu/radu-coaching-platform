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
  <!-- Spacer care ține locul navului fix în document flow -->
  <div class="h-16"></div>
  <nav class="fixed top-0 left-0 right-0 z-50 bg-[#0a0a0a]/95 backdrop-blur-md border-b border-white/5">
    <div class="max-w-5xl mx-auto px-4 pr-4 h-16 flex items-center justify-between">
      <!-- Logo -->
      <RouterLink to="/" class="font-['Bebas_Neue'] text-lg sm:text-xl tracking-widest text-white hover:text-red-400 transition-colors shrink-0">
        RADU <span class="text-red-500">MOCUȚA</span>
      </RouterLink>

      <!-- Nav links -->
      <div class="flex items-center gap-1">
        <RouterLink
          v-if="auth.isAdmin"
          to="/admin"
          class="flex items-center gap-1.5 px-3 py-2.5 rounded-lg text-xs font-semibold uppercase tracking-wider transition-colors min-w-[44px] justify-center"
          :class="$route.path.startsWith('/admin') ? 'text-red-400 bg-red-500/10' : 'text-gray-400 hover:text-white hover:bg-white/5'"
        >
          <Settings :size="18" /> <span class="hidden sm:inline">Admin</span>
        </RouterLink>
        <RouterLink
          v-else
          to="/"
          class="flex items-center gap-1.5 px-3 py-2.5 rounded-lg text-xs font-semibold uppercase tracking-wider transition-colors min-w-[44px] justify-center"
          :class="$route.path === '/' ? 'text-red-400 bg-red-500/10' : 'text-gray-400 hover:text-white hover:bg-white/5'"
        >
          <LayoutDashboard :size="18" /> <span class="hidden sm:inline">Dashboard</span>
        </RouterLink>
        <RouterLink
          to="/checkin"
          class="flex items-center gap-1.5 px-3 py-2.5 rounded-lg text-xs font-semibold uppercase tracking-wider transition-colors min-w-[44px] justify-center"
          :class="$route.path === '/checkin' ? 'text-red-400 bg-red-500/10' : 'text-gray-400 hover:text-white hover:bg-white/5'"
        >
          <ClipboardList :size="18" /> <span class="hidden sm:inline">Check-in</span>
        </RouterLink>

        <!-- User + logout -->
        <div class="flex items-center gap-1 ml-1 pl-2 border-l border-white/10">
          <span class="text-xs text-gray-500 hidden md:block mr-1">{{ auth.profile?.full_name || auth.user?.email }}</span>
          <button @click="logout" class="p-2.5 rounded-lg text-gray-400 hover:text-red-400 hover:bg-red-500/10 transition-colors min-w-[44px] flex items-center justify-center" title="Ieși din cont">
            <LogOut :size="20" />
          </button>
        </div>
      </div>
    </div>
  </nav>
</template>
