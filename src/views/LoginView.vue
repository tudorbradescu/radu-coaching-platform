<script setup>
import { ref } from 'vue'
import { useAuthStore } from '@/stores/auth.js'
import { useRouter } from 'vue-router'
import { ArrowRight } from 'lucide-vue-next'

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
  <div class="min-h-screen flex flex-col bg-[#0a0a0a]">

    <!-- Top: Logo area -->
    <div class="flex-1 flex flex-col justify-center px-6 pt-16 pb-8 max-w-lg mx-auto w-full">

      <!-- Logo -->
      <div class="mb-12">
        <h1 class="text-6xl font-['Bebas_Neue'] tracking-widest text-white leading-none">
          RADU<br/><span class="text-red-500">MOCUȚA</span>
        </h1>
        <p class="text-xs font-bold tracking-[0.4em] uppercase text-red-500/70 mt-3">Coaching Platform</p>
      </div>

      <!-- Heading -->
      <div class="mb-10">
        <h2 class="text-3xl font-bold text-white mb-2">Bun venit!</h2>
        <p class="text-base text-gray-400">Intră în contul tău de coaching.</p>
      </div>

      <!-- Form -->
      <form @submit.prevent="handleLogin" class="flex flex-col gap-5">

        <div>
          <label class="block text-sm font-semibold text-gray-300 mb-2">Email</label>
          <input
            v-model="email"
            type="email"
            required
            placeholder="email@exemplu.ro"
            class="w-full px-5 py-4 rounded-2xl bg-[#161616] border border-white/10 text-white placeholder-gray-600 text-base outline-none focus:border-red-500/60 focus:ring-2 focus:ring-red-500/20 transition-all"
          />
        </div>

        <div>
          <label class="block text-sm font-semibold text-gray-300 mb-2">Parolă</label>
          <input
            v-model="password"
            type="password"
            required
            placeholder="••••••••"
            class="w-full px-5 py-4 rounded-2xl bg-[#161616] border border-white/10 text-white placeholder-gray-600 text-base outline-none focus:border-red-500/60 focus:ring-2 focus:ring-red-500/20 transition-all"
          />
        </div>

        <div v-if="error" class="flex items-center gap-2 text-sm text-red-400 bg-red-500/10 border border-red-500/20 rounded-2xl px-4 py-3.5">
          ⚠ {{ error }}
        </div>

        <!-- Mobile: spacer to push button to bottom -->
        <div class="hidden sm:block"></div>

        <button
          type="submit"
          :disabled="loading"
          class="w-full flex items-center justify-center gap-3 py-4 rounded-2xl font-bold text-base tracking-wide text-white transition-all disabled:opacity-50 active:scale-[0.98]"
          style="background: linear-gradient(135deg, #ef4444 0%, #f97316 100%);"
        >
          {{ loading ? 'Se conectează...' : 'Intră în cont' }}
          <ArrowRight v-if="!loading" :size="20" />
        </button>

      </form>

    </div>

    <!-- Bottom note -->
    <div class="px-6 pb-10 text-center max-w-lg mx-auto w-full">
      <p class="text-sm text-gray-600">Probleme? Contactează-l pe Radu pe WhatsApp.</p>
    </div>

  </div>
</template>
