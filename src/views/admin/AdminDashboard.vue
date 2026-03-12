<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/supabase.js'
import AdminLayout from '@/components/layout/AdminLayout.vue'
import { Users, BookOpen, ClipboardList, TrendingUp, ArrowUpRight } from 'lucide-vue-next'
import { useRouter } from 'vue-router'

const router = useRouter()
const stats = ref({ clients: 0, modules: 0, checkins: 0 })
const recentCheckins = ref([])
const loading = ref(true)

const labels = { 1: 'Slab', 2: 'Acceptabil', 3: 'OK', 4: 'Bine', 5: 'Excelent' }
const colors = { 1: '#ef4444', 2: '#f97316', 3: '#eab308', 4: '#84cc16', 5: '#22c55e' }

onMounted(async () => {
  try {
    const [statsRes, recentRes] = await Promise.all([
      supabase.rpc('get_admin_stats'),
      supabase.rpc('get_recent_checkins', { lim: 5 })
    ])
    if (statsRes.data) {
      stats.value = {
        clients: Number(statsRes.data.clients) || 0,
        modules: Number(statsRes.data.modules) || 0,
        checkins: Number(statsRes.data.checkins) || 0
      }
    }
    recentCheckins.value = recentRes.data || []
  } catch (e) { /* Supabase may be unavailable */ }
  loading.value = false
})

function formatDate(d) {
  return new Date(d).toLocaleDateString('ro-RO', { day: 'numeric', month: 'short' })
}
</script>

<template>
  <AdminLayout>
    <div class="admin-content">

      <!-- Header -->
      <div class="mb-12">
        <h1 class="text-3xl font-semibold text-white tracking-tight">Dashboard</h1>
        <p class="text-base text-zinc-500 mt-2">Privire de ansamblu asupra platformei</p>
      </div>

      <!-- Stats -->
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-5 mb-12">
        <button @click="router.push('/admin/clienti')"
          class="group relative bg-[#111113] border border-zinc-800 rounded-xl p-8 text-left hover:border-zinc-700 transition-all duration-200">
          <div class="flex items-center justify-between mb-5">
            <div class="stat-icon stat-icon--blue">
              <Users :size="22" class="text-blue-400" />
            </div>
            <ArrowUpRight :size="18" class="text-zinc-600 group-hover:text-zinc-400 transition-colors" />
          </div>
          <p class="text-5xl font-semibold text-white tracking-tight">{{ stats.clients }}</p>
          <p class="text-base text-zinc-500 mt-2">Clienti activi</p>
        </button>

        <button @click="router.push('/admin/module')"
          class="group relative bg-[#111113] border border-zinc-800 rounded-xl p-8 text-left hover:border-zinc-700 transition-all duration-200">
          <div class="flex items-center justify-between mb-5">
            <div class="stat-icon stat-icon--violet">
              <BookOpen :size="22" class="text-violet-400" />
            </div>
            <ArrowUpRight :size="18" class="text-zinc-600 group-hover:text-zinc-400 transition-colors" />
          </div>
          <p class="text-5xl font-semibold text-white tracking-tight">{{ stats.modules }}</p>
          <p class="text-base text-zinc-500 mt-2">Module de training</p>
        </button>

        <button @click="router.push('/admin/checkins')"
          class="group relative bg-[#111113] border border-zinc-800 rounded-xl p-8 text-left hover:border-zinc-700 transition-all duration-200">
          <div class="flex items-center justify-between mb-5">
            <div class="stat-icon stat-icon--emerald">
              <ClipboardList :size="22" class="text-emerald-400" />
            </div>
            <ArrowUpRight :size="18" class="text-zinc-600 group-hover:text-zinc-400 transition-colors" />
          </div>
          <p class="text-5xl font-semibold text-white tracking-tight">{{ stats.checkins }}</p>
          <p class="text-base text-zinc-500 mt-2">Check-in-uri totale</p>
        </button>
      </div>

      <!-- Recent check-ins -->
      <div>
        <div class="flex items-center justify-between mb-5">
          <h2 class="text-xl font-semibold text-white">Check-in-uri recente</h2>
          <button @click="router.push('/admin/checkins')"
            class="text-sm font-medium text-zinc-500 hover:text-white transition-colors flex items-center gap-1.5">
            Vezi toate <ArrowUpRight :size="14" />
          </button>
        </div>

        <div class="bg-[#111113] border border-zinc-800 rounded-xl overflow-hidden">
          <!-- Loading -->
          <div v-if="loading" class="divide-y divide-zinc-800/50">
            <div v-for="i in 4" :key="i" class="h-[88px] animate-pulse bg-zinc-900/50"></div>
          </div>

          <!-- Empty -->
          <div v-else-if="recentCheckins.length === 0" class="py-20 text-center">
            <p class="text-base text-zinc-500">Niciun check-in trimis inca.</p>
          </div>

          <!-- List -->
          <div v-else class="divide-y divide-zinc-800/50">
            <div v-for="ci in recentCheckins" :key="ci.id"
              class="flex items-center gap-5 px-7 py-5 hover:bg-zinc-800/20 transition-colors">

              <!-- Avatar -->
              <div class="checkin-avatar"
                :style="`background: ${colors[ci.energy_level]}20; color: ${colors[ci.energy_level]}`">
                {{ (ci.client_name || 'C')[0].toUpperCase() }}
              </div>

              <!-- Info -->
              <div class="flex-1 min-w-0">
                <p class="text-base font-medium text-white">{{ ci.client_name || 'Client' }}</p>
                <p class="text-sm text-zinc-400 mt-1">
                  Energie: <span class="font-medium" :style="`color: ${colors[ci.energy_level]}`">{{ labels[ci.energy_level] }}</span>
                  <span class="text-zinc-600 mx-2">&middot;</span>
                  Somn: <span class="font-medium" :style="`color: ${colors[ci.sleep_quality]}`">{{ labels[ci.sleep_quality] }}</span>
                  <span v-if="ci.weight" class="text-zinc-600 mx-2">&middot;</span>
                  <span v-if="ci.weight" class="text-zinc-300 font-medium">{{ ci.weight }} kg</span>
                </p>
              </div>

              <!-- Date -->
              <span class="text-sm text-zinc-500 flex-shrink-0">{{ formatDate(ci.created_at) }}</span>
            </div>
          </div>
        </div>
      </div>

    </div>
  </AdminLayout>
</template>

<style scoped>
.stat-icon {
  width: 52px;
  height: 52px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.stat-icon--blue { background: rgba(59, 130, 246, 0.1); }
.stat-icon--violet { background: rgba(139, 92, 246, 0.1); }
.stat-icon--emerald { background: rgba(16, 185, 129, 0.1); }

.checkin-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  font-size: 0.875rem;
  font-weight: 700;
}
</style>
