<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth.js'
import { supabase } from '@/supabase.js'
import AppNav from '@/components/layout/AppNav.vue'
import { useRouter } from 'vue-router'
import { Play, ClipboardList, ChevronRight, CheckCircle } from 'lucide-vue-next'

const auth = useAuthStore()
const router = useRouter()
const modules = ref([])
const lastCheckin = ref(null)
const loading = ref(true)

onMounted(async () => {
  await fetchModules()
  await fetchLastCheckin()
  loading.value = false
})

async function fetchModules() {
  const { data } = await supabase
    .from('client_modules')
    .select('*, module:modules(*)')
    .eq('client_id', auth.user.id)
    .order('module(order_index)')
  modules.value = data || []
}

async function fetchLastCheckin() {
  const { data } = await supabase
    .from('checkins')
    .select('*')
    .eq('client_id', auth.user.id)
    .order('created_at', { ascending: false })
    .limit(1)
    .single()
  lastCheckin.value = data
}

function daysSinceCheckin() {
  if (!lastCheckin.value) return null
  const diff = Date.now() - new Date(lastCheckin.value.created_at).getTime()
  return Math.floor(diff / (1000 * 60 * 60 * 24))
}

const firstName = computed(() => {
  const name = auth.profile?.full_name || ''
  return name.split(' ')[0] || 'Client'
})

const needsCheckin = computed(() => !lastCheckin.value || daysSinceCheckin() >= 7)
</script>

<template>
  <div class="page-wrapper">
    <div class="page-bg"></div>
    <AppNav />

    <main class="page-content">

      <!-- Header -->
      <div class="mb-10">
        <p class="text-sm font-semibold uppercase tracking-[0.3em] text-red-500 mb-1">Bun venit inapoi</p>
        <h1 class="page-title">{{ firstName }}</h1>
      </div>

      <!-- Check-in banner -->
      <div
        v-if="needsCheckin"
        class="checkin-banner checkin-banner--needed"
        @click="router.push('/checkin')"
      >
        <div class="flex items-center gap-4 p-5">
          <div class="w-14 h-14 rounded-2xl bg-orange-500/15 border border-orange-500/25 flex items-center justify-center flex-shrink-0">
            <ClipboardList :size="26" class="text-orange-400" />
          </div>
          <div class="flex-1">
            <p class="text-lg font-bold text-white">Check-in saptamanal</p>
            <p class="text-sm text-zinc-400 mt-0.5">Trimite-ti raportul saptamanal lui Radu</p>
          </div>
          <div class="w-10 h-10 rounded-xl bg-orange-500/15 flex items-center justify-center flex-shrink-0">
            <ChevronRight :size="22" class="text-orange-400" />
          </div>
        </div>
      </div>

      <!-- Check-in done -->
      <div
        v-else
        class="checkin-banner checkin-banner--done"
      >
        <div class="flex items-center gap-4 p-5">
          <div class="w-14 h-14 rounded-2xl bg-green-500/12 border border-green-500/20 flex items-center justify-center flex-shrink-0">
            <CheckCircle :size="26" class="text-green-400" />
          </div>
          <div>
            <p class="text-lg font-bold text-white">Check-in trimis ✓</p>
            <p class="text-sm text-zinc-400 mt-0.5">
              {{ daysSinceCheckin() === 0 ? 'Azi' : `Acum ${daysSinceCheckin()} zile` }} — continua tot asa! 💪
            </p>
          </div>
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="space-y-4 mt-8">
        <div v-for="i in 3" :key="i" class="h-24 rounded-2xl bg-white/[0.03] animate-pulse"></div>
      </div>

      <!-- Modules -->
      <div v-else class="mt-8">
        <p class="text-xs font-bold uppercase tracking-[0.3em] text-zinc-500 mb-5">Modulele tale</p>

        <div v-if="modules.length === 0" class="text-center py-20 text-zinc-500">
          <p class="text-lg mb-1">Niciun modul atribuit</p>
          <p class="text-sm text-zinc-600">Radu iti va da acces in curand!</p>
        </div>

        <div v-else class="space-y-3">
          <RouterLink
            v-for="cm in modules"
            :key="cm.id"
            :to="`/modul/${cm.module.id}`"
            class="module-card"
          >
            <div class="module-icon">
              <Play :size="26" class="text-red-400" />
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-xs font-bold uppercase tracking-widest text-red-500 mb-1">Modul {{ cm.module.order_index }}</p>
              <h3 class="text-lg font-bold text-white truncate leading-tight">{{ cm.module.title }}</h3>
              <p v-if="cm.module.description" class="text-sm text-zinc-500 mt-0.5 truncate">{{ cm.module.description }}</p>
            </div>
            <ChevronRight :size="22" class="text-zinc-600 group-hover:text-red-400 flex-shrink-0 transition-colors" />
          </RouterLink>
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

.checkin-banner {
  border-radius: 20px;
  overflow: hidden;
  transition: transform 0.15s;
}

.checkin-banner:active {
  transform: scale(0.98);
}

.checkin-banner--needed {
  border: 1px solid rgba(249, 115, 22, 0.25);
  background: linear-gradient(135deg, rgba(249, 115, 22, 0.08), transparent 60%);
  cursor: pointer;
}

.checkin-banner--done {
  border: 1px solid rgba(34, 197, 94, 0.15);
  background: rgba(34, 197, 94, 0.04);
}

.module-card {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1.25rem 1.5rem;
  border-radius: 20px;
  background: rgba(17, 17, 19, 0.7);
  border: 1px solid rgba(255, 255, 255, 0.05);
  transition: all 0.2s;
  text-decoration: none;
}

.module-card:hover {
  border-color: rgba(239, 68, 68, 0.2);
  background: rgba(17, 17, 19, 0.9);
}

.module-card:active {
  transform: scale(0.98);
}

.module-icon {
  width: 60px;
  height: 60px;
  border-radius: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  background: rgba(239, 68, 68, 0.1);
  border: 1px solid rgba(239, 68, 68, 0.2);
}
</style>
