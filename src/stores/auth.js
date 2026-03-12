import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { supabase } from '@/supabase.js'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const profile = ref(null)
  const loading = ref(true)

  const isAdmin = computed(() =>
    profile.value?.role === 'admin' ||
    user.value?.app_metadata?.role === 'admin'
  )
  const isClient = computed(() => !isAdmin.value)

  async function init() {
    loading.value = true
    const { data: { session } } = await supabase.auth.getSession()
    if (session?.user) {
      user.value = session.user
      await fetchProfile()
    }
    loading.value = false

    supabase.auth.onAuthStateChange(async (event, session) => {
      if (session?.user) {
        user.value = session.user
        await fetchProfile()
      } else {
        user.value = null
        profile.value = null
      }
    })
  }

  async function fetchProfile() {
    if (!user.value) return

    // Fallback from JWT metadata (no DB needed)
    const meta = user.value.user_metadata || {}
    const appMeta = user.value.app_metadata || {}
    const jwtProfile = {
      id: user.value.id,
      email: user.value.email,
      full_name: meta.full_name || user.value.email,
      role: appMeta.role || 'client'
    }

    // Try to load from DB (may fail silently due to RLS)
    const { data } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', user.value.id)
      .maybeSingle()

    profile.value = data || jwtProfile
  }

  async function login(email, password) {
    const { error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) throw error
  }

  async function logout() {
    user.value = null
    profile.value = null
    try { await supabase.auth.signOut() } catch (e) { /* ignore */ }
  }

  return { user, profile, loading, isAdmin, isClient, init, login, logout, fetchProfile }
})
