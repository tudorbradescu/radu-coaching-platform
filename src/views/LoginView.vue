<script setup>
import { ref } from 'vue'
import { useAuthStore } from '@/stores/auth.js'
import { useRouter } from 'vue-router'

const auth = useAuthStore()
const router = useRouter()

const email = ref('')
const password = ref('')
const error = ref('')
const loading = ref(false)

async function handleLogin() {
  error.value = ''
  loading.value = true
  try {
    await auth.login(email.value, password.value)
    router.push(auth.isAdmin ? '/admin' : '/')
  } catch (e) {
    error.value = 'Email sau parolă incorectă. Încearcă din nou.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen flex items-center justify-center px-4"
       style="background: radial-gradient(ellipse 70% 70% at 50% 50%, rgba(239,68,68,0.08) 0%, transparent 70%), #0a0a0a;">

    <!-- Grid overlay -->
    <div class="fixed inset-0 pointer-events-none opacity-[0.03]"
         style="background-image: linear-gradient(rgba(239,68,68,1) 1px, transparent 1px), linear-gradient(90deg, rgba(239,68,68,1) 1px, transparent 1px); background-size: 50px 50px;"></div>

    <div class="relative w-full max-w-md">
      <!-- Logo -->
      <div class="text-center mb-10">
        <h1 class="text-5xl font-['Bebas_Neue'] tracking-widest text-white">
          RADU <span class="text-red-500">MOCUȚA</span>
        </h1>
        <p class="text-xs font-semibold tracking-[0.4em] uppercase text-red-500 mt-1">Coaching Platform</p>
      </div>

      <!-- Card -->
      <div class="bg-[#111] border border-white/5 rounded-2xl p-8">
        <h2 class="text-xl font-semibold text-white mb-1">Bun venit!</h2>
        <p class="text-sm text-gray-500 mb-8">Intră în contul tău de coaching.</p>

        <form @submit.prevent="handleLogin" class="flex flex-col gap-5">
          <div>
            <label class="block text-xs font-semibold uppercase tracking-widest text-gray-400 mb-2">Email</label>
            <input
              v-model="email"
              type="email"
              required
              placeholder="email@exemplu.ro"
              class="w-full px-4 py-3 rounded-xl bg-[#1a1a1a] border border-white/8 text-white placeholder-gray-600 text-sm outline-none focus:border-red-500/50 focus:ring-1 focus:ring-red-500/30 transition-all"
            />
          </div>
          <div>
            <label class="block text-xs font-semibold uppercase tracking-widest text-gray-400 mb-2">Parolă</label>
            <input
              v-model="password"
              type="password"
              required
              placeholder="••••••••"
              class="w-full px-4 py-3 rounded-xl bg-[#1a1a1a] border border-white/8 text-white placeholder-gray-600 text-sm outline-none focus:border-red-500/50 focus:ring-1 focus:ring-red-500/30 transition-all"
            />
          </div>

          <div v-if="error" class="flex items-center gap-2 text-sm text-red-400 bg-red-500/10 border border-red-500/20 rounded-xl px-4 py-3">
            <span>⚠</span> {{ error }}
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="w-full py-3.5 rounded-xl font-bold text-sm tracking-wide text-white transition-all disabled:opacity-50"
            style="background: linear-gradient(135deg, #ef4444 0%, #f97316 100%);"
          >
            {{ loading ? 'Se conectează...' : 'Intră în cont' }}
          </button>
        </form>
      </div>

      <p class="text-center text-xs text-gray-600 mt-6">
        Probleme? Contactează-l pe Radu pe WhatsApp.
      </p>
    </div>
  </div>
</template>
