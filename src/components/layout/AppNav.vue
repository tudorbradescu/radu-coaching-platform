<script setup>
import { useAuthStore } from '@/stores/auth.js'
import { useRouter } from 'vue-router'
import { LogOut, LayoutDashboard, ClipboardList, Settings, Flame } from 'lucide-vue-next'

const auth = useAuthStore()
const router = useRouter()

async function logout() {
  await auth.logout()
  router.push('/login')
}
</script>

<template>
  <!-- Top spacer -->
  <div class="h-16"></div>

  <!-- Top nav -->
  <nav class="app-nav">
    <div class="app-nav-inner">

      <!-- Logo -->
      <RouterLink to="/" class="flex items-center gap-2.5 shrink-0">
        <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-red-500 to-orange-500 flex items-center justify-center shadow-lg shadow-red-500/20">
          <Flame :size="16" class="text-white" />
        </div>
        <span class="font-['Bebas_Neue'] text-xl tracking-[0.12em] text-white">RADU <span class="text-red-400">COACHING</span></span>
      </RouterLink>

      <!-- Desktop nav links -->
      <div class="hidden sm:flex items-center gap-1">
        <RouterLink
          v-if="auth.isAdmin"
          to="/admin"
          class="nav-link"
          :class="$route.path.startsWith('/admin') ? 'nav-link-active' : 'nav-link-idle'"
        >
          <Settings :size="16" /> Admin
        </RouterLink>
        <RouterLink
          v-else
          to="/"
          class="nav-link"
          :class="$route.path === '/' ? 'nav-link-active' : 'nav-link-idle'"
        >
          <LayoutDashboard :size="16" /> Dashboard
        </RouterLink>
        <RouterLink
          v-if="!auth.isAdmin"
          to="/checkin"
          class="nav-link"
          :class="$route.path === '/checkin' ? 'nav-link-active' : 'nav-link-idle'"
        >
          <ClipboardList :size="16" /> Check-in
        </RouterLink>

        <div class="ml-3 pl-3 border-l border-white/10 flex items-center gap-3">
          <span class="text-sm text-zinc-400 hidden md:block">{{ auth.profile?.full_name || auth.user?.email }}</span>
          <button @click="logout" class="nav-link nav-link-idle hover:!text-red-400 hover:!bg-red-500/10">
            <LogOut :size="16" /> Iesire
          </button>
        </div>
      </div>

      <!-- Mobile: just logout -->
      <button @click="logout" class="sm:hidden flex items-center gap-1.5 text-zinc-400 hover:text-red-400 transition-colors p-2 rounded-lg">
        <LogOut :size="20" />
      </button>
    </div>
  </nav>

  <!-- Mobile bottom tab bar -->
  <div class="mobile-tabs">
    <div class="flex items-center justify-around h-16 px-2 safe-bottom">

      <RouterLink
        v-if="auth.isAdmin"
        to="/admin"
        class="mobile-tab"
        :class="$route.path.startsWith('/admin') ? 'text-red-400' : 'text-zinc-500'"
      >
        <Settings :size="22" />
        <span class="text-[10px] font-bold uppercase tracking-wider">Admin</span>
      </RouterLink>

      <RouterLink
        v-if="!auth.isAdmin"
        to="/"
        class="mobile-tab"
        :class="$route.path === '/' ? 'text-red-400' : 'text-zinc-500'"
      >
        <LayoutDashboard :size="22" />
        <span class="text-[10px] font-bold uppercase tracking-wider">Dashboard</span>
      </RouterLink>

      <RouterLink
        v-if="!auth.isAdmin"
        to="/checkin"
        class="mobile-tab"
        :class="$route.path === '/checkin' ? 'text-red-400' : 'text-zinc-500'"
      >
        <ClipboardList :size="22" />
        <span class="text-[10px] font-bold uppercase tracking-wider">Check-in</span>
      </RouterLink>

    </div>
  </div>
</template>

<style scoped>
.app-nav {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 50;
  height: 64px;
  background: rgba(10, 10, 15, 0.92);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);
}

.app-nav-inner {
  max-width: 1100px;
  margin: 0 auto;
  padding: 0 1.5rem;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.nav-link {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  padding: 0.5rem 0.875rem;
  border-radius: 0.5rem;
  font-size: 0.8125rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  transition: all 0.15s;
}

.nav-link-active {
  color: #f87171;
  background: rgba(239, 68, 68, 0.1);
}

.nav-link-idle {
  color: #a1a1aa;
}

.nav-link-idle:hover {
  color: white;
  background: rgba(255, 255, 255, 0.05);
}

.mobile-tabs {
  display: none;
}

@media (max-width: 639px) {
  .mobile-tabs {
    display: block;
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    z-index: 50;
    background: rgba(10, 10, 15, 0.95);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    border-top: 1px solid rgba(255, 255, 255, 0.06);
  }
}

.mobile-tab {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.25rem;
  flex: 1;
  height: 100%;
  transition: color 0.15s;
}
</style>
