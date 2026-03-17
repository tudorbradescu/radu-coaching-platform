<script setup>
import { useAuthStore } from '@/stores/auth.js'
import { useRouter, useRoute } from 'vue-router'
import {
  LayoutDashboard, Users, BookOpen, ClipboardList, Video, MessageSquare,
  LogOut, ChevronRight, Menu, X
} from 'lucide-vue-next'
import { ref } from 'vue'

const auth = useAuthStore()
const router = useRouter()
const route = useRoute()
const mobileOpen = ref(false)

const navItems = [
  { path: '/admin', label: 'Dashboard', icon: LayoutDashboard, exact: true },
  { path: '/feed', label: 'Feed', icon: MessageSquare },
  { path: '/admin/clienti', label: 'Clienti', icon: Users },
  { path: '/admin/module', label: 'Module', icon: BookOpen },
  { path: '/admin/checkins', label: 'Check-in-uri', icon: ClipboardList },
  { path: '/admin/live', label: 'Suport LIVE', icon: Video },
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
        <RouterLink to="/admin" class="flex items-center gap-3">
          <div class="logo-badge">
            <span class="text-white font-bold text-base">R</span>
          </div>
          <span class="font-semibold text-lg text-white tracking-tight">Radu Coaching</span>
        </RouterLink>
      </div>

      <!-- Nav -->
      <nav class="sidebar-nav">
        <RouterLink
          v-for="item in navItems" :key="item.path"
          :to="item.path"
          class="nav-item"
          :class="isActive(item) ? 'nav-item--active' : 'nav-item--idle'"
        >
          <component :is="item.icon" :size="22" :class="isActive(item) ? 'text-red-400' : 'text-zinc-500'" />
          {{ item.label }}
          <ChevronRight v-if="isActive(item)" :size="16" class="ml-auto text-zinc-500" />
        </RouterLink>
      </nav>

      <!-- User -->
      <div class="sidebar-user">
        <div class="flex items-center gap-3 mb-4">
          <div class="user-avatar">
            {{ (auth.profile?.full_name || 'A')[0].toUpperCase() }}
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-base font-medium text-white truncate">{{ auth.profile?.full_name || 'Admin' }}</p>
            <p class="text-sm text-zinc-500 truncate">{{ auth.user?.email }}</p>
          </div>
        </div>
        <button @click="logout"
          class="logout-btn">
          <LogOut :size="16" />
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
  width: 300px;
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
  height: 80px;
  display: flex;
  align-items: center;
  padding: 0 1.75rem;
  border-bottom: 1px solid #27272a;
}

.logo-badge {
  width: 40px;
  height: 40px;
  border-radius: 10px;
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

.sidebar-nav {
  flex: 1;
  padding: 1.25rem;
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 0.875rem;
  padding: 0.75rem 1rem;
  border-radius: 10px;
  font-size: 1rem;
  font-weight: 500;
  transition: all 0.15s;
}

.nav-item--active {
  background: rgba(255, 255, 255, 0.08);
  color: white;
}

.nav-item--idle {
  color: #a1a1aa;
}

.nav-item--idle:hover {
  color: white;
  background: rgba(255, 255, 255, 0.04);
}

.sidebar-user {
  border-top: 1px solid #27272a;
  padding: 1.5rem 1.75rem;
}

.user-avatar {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: linear-gradient(135deg, #ef4444, #f97316);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 0.875rem;
  font-weight: 700;
}

.logout-btn {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.625rem 1rem;
  border-radius: 10px;
  font-size: 0.875rem;
  font-weight: 500;
  color: #a1a1aa;
  border: 1px solid #27272a;
  background: none;
  cursor: pointer;
  transition: all 0.15s;
}

.logout-btn:hover {
  color: #f87171;
  background: rgba(239, 68, 68, 0.08);
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
    margin-left: 300px;
    padding-top: 0;
  }
}

/* ── Transitions ── */
.slide-enter-active, .slide-leave-active { transition: opacity 0.2s ease; }
.slide-enter-from, .slide-leave-to { opacity: 0; }
</style>
