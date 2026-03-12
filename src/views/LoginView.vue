<script setup>
import { ref } from 'vue'
import { useAuthStore } from '@/stores/auth.js'
import { useRouter } from 'vue-router'
import { ArrowRight, Lock, Flame } from 'lucide-vue-next'

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

    <!-- Animated gradient background -->
    <div class="login-bg"></div>
    <div class="login-glow login-glow--1"></div>
    <div class="login-glow login-glow--2"></div>
    <div class="login-glow login-glow--3"></div>

    <!-- Noise overlay for texture -->
    <div class="login-noise"></div>

    <!-- Centered content -->
    <div class="login-container">

      <!-- Logo & branding -->
      <div class="text-center mb-10">
        <div class="login-logo">
          <Flame :size="28" class="text-white" />
        </div>
        <h1 class="login-title">RADU COACHING</h1>
        <p class="login-subtitle">Transforma-ti corpul. Transforma-ti viata.</p>
      </div>

      <!-- Form card -->
      <div class="login-card">

        <div class="text-center mb-8">
          <h2 class="text-xl font-semibold text-white">Bun venit!</h2>
          <p class="text-sm text-zinc-400 mt-1.5">Intra in contul tau pentru a continua.</p>
        </div>

        <form @submit.prevent="handleLogin" class="space-y-5">

          <!-- Email -->
          <div>
            <label class="login-label">Email</label>
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
            <label class="login-label">Parola</label>
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
          <div v-if="error" class="text-sm text-red-400 bg-red-500/[0.08] border border-red-500/20 rounded-xl px-4 py-3">
            {{ error }}
          </div>

          <!-- Submit -->
          <button
            type="submit"
            :disabled="loading"
            class="login-button"
          >
            <Lock v-if="!loading" :size="18" />
            <span class="text-base">{{ loading ? 'Se conecteaza...' : 'Intra in cont' }}</span>
            <ArrowRight v-if="!loading" :size="18" />
          </button>

        </form>
      </div>

      <!-- Footer -->
      <p class="text-xs text-zinc-500 text-center mt-8">Probleme cu accesul? Contacteaza-l pe Radu pe WhatsApp.</p>

    </div>
  </div>
</template>

<style scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #0a0a0f;
  padding: 1.5rem;
  position: relative;
  overflow: hidden;
}

/* Main gradient background — warm red/orange to deep purple */
.login-bg {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(ellipse 80% 60% at 50% -10%, rgba(239, 68, 68, 0.25), transparent 70%),
    radial-gradient(ellipse 60% 50% at 80% 20%, rgba(249, 115, 22, 0.15), transparent 60%),
    radial-gradient(ellipse 70% 60% at 20% 80%, rgba(139, 92, 246, 0.12), transparent 60%),
    radial-gradient(ellipse 50% 40% at 60% 100%, rgba(236, 72, 153, 0.10), transparent 50%);
  pointer-events: none;
}

/* Floating glow orbs for depth */
.login-glow {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  pointer-events: none;
  opacity: 0.6;
}

.login-glow--1 {
  width: 500px;
  height: 500px;
  background: rgba(239, 68, 68, 0.15);
  top: -15%;
  left: 50%;
  transform: translateX(-50%);
  animation: float1 8s ease-in-out infinite;
}

.login-glow--2 {
  width: 350px;
  height: 350px;
  background: rgba(249, 115, 22, 0.12);
  bottom: -10%;
  right: -5%;
  animation: float2 10s ease-in-out infinite;
}

.login-glow--3 {
  width: 300px;
  height: 300px;
  background: rgba(139, 92, 246, 0.10);
  bottom: 10%;
  left: -8%;
  animation: float3 12s ease-in-out infinite;
}

@keyframes float1 {
  0%, 100% { transform: translateX(-50%) translateY(0); }
  50% { transform: translateX(-50%) translateY(20px); }
}

@keyframes float2 {
  0%, 100% { transform: translateY(0) translateX(0); }
  50% { transform: translateY(-15px) translateX(-10px); }
}

@keyframes float3 {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(15px); }
}

/* Subtle noise texture */
.login-noise {
  position: absolute;
  inset: 0;
  opacity: 0.03;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)'/%3E%3C/svg%3E");
  pointer-events: none;
}

.login-container {
  width: 100%;
  max-width: 480px;
  position: relative;
  z-index: 1;
}

/* Logo */
.login-logo {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 64px;
  height: 64px;
  border-radius: 20px;
  background: linear-gradient(135deg, #ef4444, #f97316);
  margin-bottom: 1.25rem;
  box-shadow: 0 8px 32px rgba(239, 68, 68, 0.3);
}

.login-title {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 2rem;
  letter-spacing: 0.15em;
  color: white;
  line-height: 1;
}

.login-subtitle {
  font-size: 0.9rem;
  color: #a1a1aa;
  margin-top: 0.5rem;
  letter-spacing: 0.02em;
}

/* Card */
.login-card {
  background: rgba(17, 17, 19, 0.85);
  backdrop-filter: blur(24px);
  -webkit-backdrop-filter: blur(24px);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 20px;
  padding: 2.5rem;
  box-shadow:
    0 0 0 1px rgba(255, 255, 255, 0.03),
    0 8px 40px rgba(0, 0, 0, 0.5),
    0 2px 8px rgba(0, 0, 0, 0.3);
}

.login-label {
  display: block;
  font-size: 0.875rem;
  font-weight: 500;
  color: #a1a1aa;
  margin-bottom: 0.5rem;
}

.login-input {
  width: 100%;
  padding: 0.8rem 1rem;
  border-radius: 12px;
  background: rgba(9, 9, 11, 0.8);
  border: 1px solid rgba(255, 255, 255, 0.08);
  color: white;
  font-size: 15px;
  outline: none;
  transition: border-color 0.2s, box-shadow 0.2s;
  -webkit-appearance: none;
}

.login-input::placeholder {
  color: #52525b;
}

.login-input:focus {
  border-color: #ef4444;
  box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.15), 0 0 20px rgba(239, 68, 68, 0.05);
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
  gap: 0.625rem;
  padding: 0.85rem 1.25rem;
  border-radius: 12px;
  font-weight: 600;
  color: white;
  background: linear-gradient(135deg, #ef4444, #dc2626);
  border: none;
  cursor: pointer;
  transition: all 0.2s;
  margin-top: 0.75rem;
  box-shadow: 0 4px 16px rgba(239, 68, 68, 0.25);
}

.login-button:hover {
  background: linear-gradient(135deg, #dc2626, #b91c1c);
  box-shadow: 0 6px 24px rgba(239, 68, 68, 0.35);
  transform: translateY(-1px);
}

.login-button:active {
  transform: translateY(0) scale(0.99);
}

.login-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}
</style>
