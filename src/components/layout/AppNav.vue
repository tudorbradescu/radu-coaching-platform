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
  <!-- Top spacer -->
  <div class="h-14"></div>

  <!-- Top nav -->
  <nav class="fixed top-0 left-0 right-0 z-50 bg-[#0a0a0a]/98 backdrop-blur-md border-b border-white/5">
    <div class="max-w-5xl mx-auto px-5 h-14 flex items-center justify-between">

      <!-- Logo -->
      <RouterLink to="/" class="font-['Bebas_Neue'] text-xl tracking-widest text-white shrink-0">
        RADU <span class="text-red-500">MOCUȚA</span>
      </RouterLink>

      <!-- Desktop nav links -->
      <div class="hidden sm:flex items-center gap-1">
        <RouterLink
          v-if="auth.isAdmin"
          to="/admin"
          class="flex items-center gap-1.5 px-3 py-2 rounded-lg text-xs font-semibold uppercase tracking-wider transition-colors"
          :class="$route.path.startsWith('/admin') ? 'text-red-400 bg-red-500/10' : 'text-gray-400 hover:text-white hover:bg-white/5'"
        >
          <Settings :size="16" /> Admin
        </RouterLink>
        <RouterLink
          v-else
          to="/"
          class="flex items-center gap-1.5 px-3 py-2 rounded-lg text-xs font-semibold uppercase tracking-wider transition-colors"
          :class="$route.path === '/' ? 'text-red-400 bg-red-500/10' : 'text-gray-400 hover:text-white hover:bg-white/5'"
        >
          <LayoutDashboard :size="16" /> Dashboard
        </RouterLink>
        <RouterLink
          v-if="!auth.isAdmin"
          to="/checkin"
          class="flex items-center gap-1.5 px-3 py-2 rounded-lg text-xs font-semibold uppercase tracking-wider transition-colors"
          :class="$route.path === '/checkin' ? 'text-red-400 bg-red-500/10' : 'text-gray-400 hover:text-white hover:bg-white/5'"
        >
          <ClipboardList :size="16" /> Check-in
        </RouterLink>

        <div class="ml-2 pl-2 border-l border-white/10 flex items-center gap-2">
          <span class="text-xs text-gray-500 hidden md:block">{{ auth.profile?.full_name || auth.user?.email }}</span>
          <button @click="logout" class="flex items-center gap-1.5 px-3 py-2 rounded-lg text-xs font-semibold text-gray-400 hover:text-red-400 hover:bg-red-500/10 transition-colors uppercase tracking-wider">
            <LogOut :size="16" /> Ieșire
          </button>
        </div>
      </div>

      <!-- Mobile: just logout -->
      <button @click="logout" class="sm:hidden flex items-center gap-1.5 text-gray-400 hover:text-red-400 transition-colors p-2 rounded-lg">
        <LogOut :size="20" />
      </button>
    </div>
  </nav>

  <!-- Mobile bottom tab bar -->
  <div class="sm:hidden fixed bottom-0 left-0 right-0 z-50 bg-[#0a0a0a]/98 backdrop-blur-md border-t border-white/8">
    <div class="flex items-center justify-around h-16 px-2 safe-bottom">

      <RouterLink
        v-if="auth.isAdmin"
        to="/admin"
        class="flex flex-col items-center justify-center gap-1 flex-1 h-full transition-colors"
        :class="$route.path.startsWith('/admin') ? 'text-red-400' : 'text-gray-500'"
      >
        <Settings :size="24" />
        <span class="text-[10px] font-bold uppercase tracking-wider">Admin</span>
      </RouterLink>

      <RouterLink
        v-if="!auth.isAdmin"
        to="/"
        class="flex flex-col items-center justify-center gap-1 flex-1 h-full transition-colors"
        :class="$route.path === '/' ? 'text-red-400' : 'text-gray-500'"
      >
        <LayoutDashboard :size="24" />
        <span class="text-[10px] font-bold uppercase tracking-wider">Dashboard</span>
      </RouterLink>

      <RouterLink
        v-if="!auth.isAdmin"
        to="/checkin"
        class="flex flex-col items-center justify-center gap-1 flex-1 h-full transition-colors"
        :class="$route.path === '/checkin' ? 'text-red-400' : 'text-gray-500'"
      >
        <ClipboardList :size="24" />
        <span class="text-[10px] font-bold uppercase tracking-wider">Check-in</span>
      </RouterLink>

    </div>
  </div>
</template>
