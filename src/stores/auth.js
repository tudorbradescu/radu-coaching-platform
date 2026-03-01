import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { supabase } from '@/supabase.js'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const profile = ref(null)
  const loading = ref(true)

  const isAdmin = computed(() => profile.value?.role === 'admin')
  const isClient = computed(() => profile.value?.role === 'client')

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
    const { data } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', user.value.id)
      .single()
    profile.value = data
  }

  async function login(email, password) {
    const { error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) throw error
  }

  async function logout() {
    await supabase.auth.signOut()
    user.value = null
    profile.value = null
  }

  return { user, profile, loading, isAdmin, isClient, init, login, logout, fetchProfile }
})
