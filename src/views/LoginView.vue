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
  <div class="min-h-screen flex flex-col bg-[#0a0a0a] px-5">

    <!-- Logo -->
    <div class="pt-16 pb-8 max-w-lg mx-auto w-full">
      <h1 class="text-6xl font-['Bebas_Neue'] tracking-widest text-white leading-none">
        RADU<br/><span class="text-red-500">MOCUȚA</span>
      </h1>
      <p class="text-xs font-bold tracking-[0.4em] uppercase text-red-500/70 mt-3">Coaching Platform</p>
    </div>

    <!-- Form card -->
    <div class="max-w-lg mx-auto w-full flex-1 flex flex-col">
      <div class="bg-[#111] border border-white/8 rounded-3xl p-6">

        <h2 class="text-2xl font-bold text-white mb-1">Bun venit!</h2>
        <p class="text-sm text-gray-400 mb-7">Intră în contul tău de coaching.</p>

        <form @submit.prevent="handleLogin" class="flex flex-col gap-4">

          <!-- Email -->
          <div>
            <label class="block text-xs font-bold uppercase tracking-widest text-gray-500 mb-2">Email</label>
            <input
              v-model="email"
              type="email"
              required
              placeholder="email@exemplu.ro"
              class="input-field"
            />
          </div>

          <!-- Parolă -->
          <div>
            <label class="block text-xs font-bold uppercase tracking-widest text-gray-500 mb-2">Parolă</label>
            <input
              v-model="password"
              type="password"
              required
              placeholder="••••••••"
              class="input-field"
            />
          </div>

          <!-- Error -->
          <div v-if="error" class="flex items-center gap-2 text-sm text-red-400 bg-red-500/10 border border-red-500/20 rounded-2xl px-4 py-3.5">
            ⚠ {{ error }}
          </div>

          <!-- Submit -->
          <button
            type="submit"
            :disabled="loading"
            class="w-full flex items-center justify-center gap-3 py-4 rounded-2xl font-bold text-base tracking-wide text-white transition-all disabled:opacity-50 active:scale-[0.98] mt-2"
            style="background: linear-gradient(135deg, #ef4444 0%, #f97316 100%);"
          >
            {{ loading ? 'Se conectează...' : 'Intră în cont' }}
            <ArrowRight v-if="!loading" :size="20" />
          </button>

        </form>
      </div>

      <!-- Bottom note -->
      <p class="text-sm text-gray-600 text-center py-8">Probleme? Contactează-l pe Radu pe WhatsApp.</p>
    </div>

  </div>
</template>

<style scoped>
.input-field {
  width: 100%;
  padding: 16px 18px;
  border-radius: 14px;
  background: #1a1a1a;
  border: 1.5px solid rgba(255,255,255,0.1);
  color: white;
  font-size: 16px;
  outline: none;
  transition: border-color 0.2s;
  -webkit-appearance: none;
}

.input-field::placeholder {
  color: rgba(156,163,175,0.5);
}

.input-field:focus {
  border-color: rgba(239,68,68,0.5);
  box-shadow: 0 0 0 3px rgba(239,68,68,0.08);
}

/* Fix browser autofill white background */
.input-field:-webkit-autofill,
.input-field:-webkit-autofill:hover,
.input-field:-webkit-autofill:focus {
  -webkit-box-shadow: 0 0 0 1000px #1a1a1a inset !important;
  -webkit-text-fill-color: white !important;
  caret-color: white;
  border-color: rgba(239,68,68,0.4) !important;
  transition: background-color 5000s ease-in-out 0s;
}
</style>
