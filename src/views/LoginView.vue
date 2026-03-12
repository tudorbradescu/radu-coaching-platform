<script setup>
import { ref } from 'vue'
import { useAuthStore } from '@/stores/auth.js'
import { useRouter } from 'vue-router'
import { ArrowRight, Lock } from 'lucide-vue-next'

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
    error.value = 'Email sau parola incorecta. Incearca din nou.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login-page">

    <!-- Subtle background pattern -->
    <div class="login-bg"></div>

    <!-- Centered content -->
    <div class="login-container">

      <!-- Logo -->
      <div class="text-center mb-10">
        <div class="inline-flex items-center justify-center w-14 h-14 rounded-2xl bg-red-500 mb-5">
          <span class="text-white font-bold text-xl">R</span>
        </div>
        <h1 class="text-2xl font-semibold text-white tracking-tight">Radu Coaching</h1>
        <p class="text-sm text-zinc-500 mt-1.5">Platforma ta de coaching fitness</p>
      </div>

      <!-- Form card -->
      <div class="login-card">

        <div class="text-center mb-8">
          <h2 class="text-lg font-semibold text-white">Bun venit!</h2>
          <p class="text-sm text-zinc-500 mt-1">Intra in contul tau pentru a continua.</p>
        </div>

        <form @submit.prevent="handleLogin" class="space-y-4">

          <!-- Email -->
          <div>
            <label class="block text-sm font-medium text-zinc-400 mb-1.5">Email</label>
            <input
              v-model="email"
              type="email"
              required
              autocomplete="email"
              placeholder="email@exemplu.ro"
              class="login-input"
            />
          </div>

          <!-- Password -->
          <div>
            <label class="block text-sm font-medium text-zinc-400 mb-1.5">Parola</label>
            <input
              v-model="password"
              type="password"
              required
              autocomplete="current-password"
              placeholder="Introdu parola"
              class="login-input"
            />
          </div>

          <!-- Error -->
          <div v-if="error" class="text-sm text-red-400 bg-red-500/[0.06] border border-red-500/15 rounded-lg px-4 py-3">
            {{ error }}
          </div>

          <!-- Submit -->
          <button
            type="submit"
            :disabled="loading"
            class="login-button"
          >
            <Lock v-if="!loading" :size="16" />
            {{ loading ? 'Se conecteaza...' : 'Intra in cont' }}
            <ArrowRight v-if="!loading" :size="16" />
          </button>

        </form>
      </div>

      <!-- Footer -->
      <p class="text-xs text-zinc-600 text-center mt-8">Probleme cu accesul? Contacteaza-l pe Radu pe WhatsApp.</p>

    </div>
  </div>
</template>

<style scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #09090b;
  padding: 1.5rem;
  position: relative;
  overflow: hidden;
}

.login-bg {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(ellipse 600px 400px at 50% 0%, rgba(239, 68, 68, 0.06), transparent),
    radial-gradient(ellipse 400px 300px at 50% 100%, rgba(249, 115, 22, 0.04), transparent);
  pointer-events: none;
}

.login-container {
  width: 100%;
  max-width: 400px;
  position: relative;
  z-index: 1;
}

.login-card {
  background: #111113;
  border: 1px solid #27272a;
  border-radius: 16px;
  padding: 2rem;
  box-shadow:
    0 0 0 1px rgba(255, 255, 255, 0.02),
    0 4px 24px rgba(0, 0, 0, 0.4),
    0 1px 3px rgba(0, 0, 0, 0.3);
}

.login-input {
  width: 100%;
  padding: 0.625rem 0.875rem;
  border-radius: 8px;
  background: #09090b;
  border: 1px solid #27272a;
  color: white;
  font-size: 14px;
  outline: none;
  transition: border-color 0.15s, box-shadow 0.15s;
  -webkit-appearance: none;
}

.login-input::placeholder {
  color: #52525b;
}

.login-input:focus {
  border-color: #ef4444;
  box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1);
}

.login-input:-webkit-autofill,
.login-input:-webkit-autofill:hover,
.login-input:-webkit-autofill:focus {
  -webkit-box-shadow: 0 0 0 1000px #09090b inset !important;
  -webkit-text-fill-color: white !important;
  caret-color: white;
  border-color: #ef4444 !important;
  transition: background-color 5000s ease-in-out 0s;
}

.login-button {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.625rem 1rem;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
  color: white;
  background: #ef4444;
  border: none;
  cursor: pointer;
  transition: background-color 0.15s, transform 0.1s;
  margin-top: 0.5rem;
}

.login-button:hover {
  background: #dc2626;
}

.login-button:active {
  transform: scale(0.98);
}

.login-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
