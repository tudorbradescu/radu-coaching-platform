import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth.js'

const routes = [
  { path: '/login', name: 'login', component: () => import('@/views/LoginView.vue'), meta: { public: true } },
  { path: '/', name: 'dashboard', component: () => import('@/views/DashboardView.vue') },
  { path: '/modul/:id', name: 'modul', component: () => import('@/views/ModuleView.vue') },
  { path: '/checkin', name: 'checkin', component: () => import('@/views/CheckinView.vue') },
  { path: '/admin', name: 'admin', component: () => import('@/views/admin/AdminDashboard.vue'), meta: { admin: true } },
  { path: '/admin/clienti', name: 'admin-clienti', component: () => import('@/views/admin/AdminClients.vue'), meta: { admin: true } },
  { path: '/admin/module', name: 'admin-module', component: () => import('@/views/admin/AdminModules.vue'), meta: { admin: true } },
  { path: '/:pathMatch(.*)*', redirect: '/' }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach(async (to) => {
  const auth = useAuthStore()
  if (auth.loading) await new Promise(r => setTimeout(r, 100))

  if (!to.meta.public && !auth.user) return { name: 'login' }
  if (to.meta.admin && !auth.isAdmin) return { name: 'dashboard' }
  if (to.name === 'login' && auth.user) {
    return auth.isAdmin ? { name: 'admin' } : { name: 'dashboard' }
  }
})

export default router
