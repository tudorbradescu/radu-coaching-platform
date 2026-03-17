<script setup>
import { useAuthStore } from '@/stores/auth.js'
import AppNav from '@/components/layout/AppNav.vue'
import { computed } from 'vue'
import { Flame, BookOpen, Users, MessageSquare, Video } from 'lucide-vue-next'

const auth = useAuthStore()

const firstName = computed(() => {
  const name = auth.profile?.full_name || ''
  return name.split(' ')[0] || 'Client'
})
</script>

<template>
  <div class="page-wrapper">
    <div class="page-bg"></div>
    <AppNav />

    <main class="page-content">

      <!-- Hero -->
      <div class="text-center mb-12">
        <div class="w-20 h-20 rounded-2xl bg-gradient-to-br from-red-500 to-orange-500 flex items-center justify-center mx-auto mb-6 shadow-lg shadow-red-500/20">
          <Flame :size="36" class="text-white" />
        </div>
        <p class="text-sm font-semibold uppercase tracking-[0.3em] text-red-500 mb-2">Bine ai venit</p>
        <h1 class="page-title">{{ firstName }}</h1>
        <p class="text-zinc-400 mt-3 max-w-md mx-auto leading-relaxed">
          Platforma ta de coaching cu Radu. Aici gasesti tot ce ai nevoie pentru transformarea ta.
        </p>
      </div>

      <!-- Quick links -->
      <div class="grid grid-cols-2 gap-3 mb-10">
        <RouterLink to="/dashboard" class="quick-card">
          <BookOpen :size="24" class="text-red-400" />
          <span class="quick-label">Module</span>
        </RouterLink>
        <RouterLink to="/feed" class="quick-card">
          <MessageSquare :size="24" class="text-orange-400" />
          <span class="quick-label">Feed</span>
        </RouterLink>
        <RouterLink to="/live" class="quick-card">
          <Video :size="24" class="text-green-400" />
          <span class="quick-label">Suport LIVE</span>
        </RouterLink>
        <RouterLink to="/checkin" class="quick-card">
          <Users :size="24" class="text-purple-400" />
          <span class="quick-label">Check-in</span>
        </RouterLink>
      </div>

      <!-- Rules section -->
      <div class="rules-section">
        <h2 class="section-title">Regulile comunitatii</h2>

        <div class="space-y-4">
          <div class="rule-card">
            <div class="rule-number">1</div>
            <div>
              <p class="text-white font-semibold">Respecta procesul</p>
              <p class="text-sm text-zinc-400 mt-0.5">Ai incredere in program si urmeaza pasii. Rezultatele vin cu consistenta.</p>
            </div>
          </div>

          <div class="rule-card">
            <div class="rule-number">2</div>
            <div>
              <p class="text-white font-semibold">Trimite check-in saptamanal</p>
              <p class="text-sm text-zinc-400 mt-0.5">Check-in-ul este obligatoriu in fiecare saptamana pentru a-ti monitoriza progresul.</p>
            </div>
          </div>

          <div class="rule-card">
            <div class="rule-number">3</div>
            <div>
              <p class="text-white font-semibold">Fii activ in comunitate</p>
              <p class="text-sm text-zinc-400 mt-0.5">Posteaza in feed, participa la sesiunile live si ajuta-ti colegii.</p>
            </div>
          </div>

          <div class="rule-card">
            <div class="rule-number">4</div>
            <div>
              <p class="text-white font-semibold">Comunicare deschisa</p>
              <p class="text-sm text-zinc-400 mt-0.5">Daca ai probleme sau intrebari, scrie in feed sau la check-in. Nu ramane cu ele.</p>
            </div>
          </div>
        </div>
      </div>

    </main>
  </div>
</template>

<style scoped>
.page-wrapper {
  min-height: 100vh;
  background: #0a0a0f;
  position: relative;
}

.page-bg {
  position: fixed;
  inset: 0;
  background:
    radial-gradient(ellipse 70% 50% at 50% -5%, rgba(239, 68, 68, 0.08), transparent 60%),
    radial-gradient(ellipse 50% 40% at 80% 50%, rgba(249, 115, 22, 0.05), transparent 50%),
    radial-gradient(ellipse 50% 50% at 10% 90%, rgba(139, 92, 246, 0.04), transparent 50%);
  pointer-events: none;
  z-index: 0;
}

.page-content {
  position: relative;
  z-index: 1;
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem 1.5rem 8rem;
}

@media (min-width: 640px) {
  .page-content {
    padding: 2.5rem 2rem 4rem;
  }
}

.page-title {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 3.5rem;
  letter-spacing: 0.05em;
  color: white;
  line-height: 1;
}

@media (min-width: 640px) {
  .page-title {
    font-size: 4.5rem;
  }
}

.quick-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.75rem;
  padding: 1.5rem 1rem;
  border-radius: 20px;
  background: rgba(17, 17, 19, 0.7);
  border: 1px solid rgba(255, 255, 255, 0.05);
  transition: all 0.2s;
  text-decoration: none;
}

.quick-card:hover {
  border-color: rgba(255, 255, 255, 0.1);
  background: rgba(17, 17, 19, 0.9);
  transform: translateY(-2px);
}

.quick-card:active {
  transform: scale(0.97);
}

.quick-label {
  font-size: 0.8125rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: #a1a1aa;
}

.rules-section {
  margin-top: 1rem;
}

.section-title {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 1.75rem;
  letter-spacing: 0.08em;
  color: white;
  margin-bottom: 1.25rem;
}

.rule-card {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
  padding: 1.25rem;
  border-radius: 16px;
  background: rgba(17, 17, 19, 0.5);
  border: 1px solid rgba(255, 255, 255, 0.04);
}

.rule-number {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  background: rgba(239, 68, 68, 0.1);
  border: 1px solid rgba(239, 68, 68, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'Bebas Neue', sans-serif;
  font-size: 1.125rem;
  color: #f87171;
  flex-shrink: 0;
}
</style>
