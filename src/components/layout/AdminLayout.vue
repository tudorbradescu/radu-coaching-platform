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
  <div class="admin-root">

    <!-- Desktop Sidebar -->
    <aside class="admin-sidebar">

      <!-- Logo -->
      <div class="sidebar-logo">
        <RouterLink to="/admin" class="flex items-center gap-2.5">
          <div class="logo-badge">
            <span class="text-white font-bold text-sm">R</span>
          </div>
          <span class="font-semibold text-[15px] text-white tracking-tight">Radu Coaching</span>
        </RouterLink>
      </div>

      <!-- Nav -->
      <nav class="flex-1 px-4 py-5 space-y-1">
        <RouterLink
          v-for="item in navItems" :key="item.path"
          :to="item.path"
          class="group flex items-center gap-3 px-3.5 py-2.5 rounded-lg text-sm font-medium transition-all duration-150"
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
      <div class="sidebar-user">
        <div class="flex items-center gap-3 mb-3">
          <div class="user-avatar">
            {{ (auth.profile?.full_name || 'A')[0].toUpperCase() }}
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-medium text-white truncate">{{ auth.profile?.full_name || 'Admin' }}</p>
            <p class="text-xs text-zinc-500 truncate">{{ auth.user?.email }}</p>
          </div>
        </div>
        <button @click="logout"
          class="w-full flex items-center justify-center gap-2 px-3 py-2 rounded-lg text-xs font-medium text-zinc-400 hover:text-red-400 hover:bg-red-500/[0.08] border border-zinc-800 transition-all duration-150">
          <LogOut :size="14" />
          Deconectare
        </button>
      </div>
    </aside>

    <!-- Mobile Header -->
    <div class="mobile-header">
      <div class="flex items-center gap-2.5">
        <div class="logo-badge logo-badge--sm">
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
      <div v-if="mobileOpen" class="mobile-overlay" @click="mobileOpen = false">
        <div class="mobile-menu" @click.stop>
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
    <main class="admin-main">
      <slot />
    </main>
  </div>
</template>

<style scoped>
.admin-root {
  min-height: 100vh;
  background: #09090b;
  display: flex;
}

/* ── Desktop Sidebar ── */
.admin-sidebar {
  display: none;
  flex-direction: column;
  width: 260px;
  border-right: 1px solid #27272a;
  background: #0c0c0e;
  flex-shrink: 0;
  position: fixed;
  top: 0;
  bottom: 0;
  left: 0;
  z-index: 40;
}

@media (min-width: 1024px) {
  .admin-sidebar {
    display: flex;
  }
}

.sidebar-logo {
  height: 64px;
  display: flex;
  align-items: center;
  padding: 0 1.5rem;
  border-bottom: 1px solid #27272a;
}

.logo-badge {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  background: #ef4444;
  display: flex;
  align-items: center;
  justify-content: center;
}

.logo-badge--sm {
  width: 28px;
  height: 28px;
  border-radius: 6px;
}

.sidebar-user {
  border-top: 1px solid #27272a;
  padding: 1.25rem;
}

.user-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: linear-gradient(135deg, #ef4444, #f97316);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 0.75rem;
  font-weight: 700;
}

/* ── Mobile Header ── */
.mobile-header {
  display: flex;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 50;
  height: 56px;
  background: rgba(12, 12, 14, 0.95);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  border-bottom: 1px solid #27272a;
  align-items: center;
  justify-content: space-between;
  padding: 0 1rem;
}

@media (min-width: 1024px) {
  .mobile-header {
    display: none;
  }
}

/* ── Mobile Overlay ── */
.mobile-overlay {
  position: fixed;
  inset: 0;
  z-index: 40;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(4px);
  -webkit-backdrop-filter: blur(4px);
}

@media (min-width: 1024px) {
  .mobile-overlay {
    display: none !important;
  }
}

.mobile-menu {
  position: absolute;
  top: 56px;
  left: 0;
  right: 0;
  background: #0c0c0e;
  border-bottom: 1px solid #27272a;
  padding: 0.75rem;
}

/* ── Main Content ── */
.admin-main {
  flex: 1;
  min-height: 100vh;
  padding-top: 3.5rem;
}

@media (min-width: 1024px) {
  .admin-main {
    margin-left: 260px;
    padding-top: 0;
  }
}

/* ── Transitions ── */
.slide-enter-active, .slide-leave-active { transition: opacity 0.2s ease; }
.slide-enter-from, .slide-leave-to { opacity: 0; }
</style>
