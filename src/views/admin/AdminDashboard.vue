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
  loading.value = false
})

function formatDate(d) {
  return new Date(d).toLocaleDateString('ro-RO', { day: 'numeric', month: 'short' })
}
</script>

<template>
  <AdminLayout>
    <div class="px-6 lg:px-10 py-8 max-w-[1100px]">

      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-2xl font-semibold text-white tracking-tight">Dashboard</h1>
        <p class="text-sm text-zinc-500 mt-1">Privire de ansamblu asupra platformei</p>
      </div>

      <!-- Stats -->
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-10">
        <button @click="router.push('/admin/clienti')"
          class="group relative bg-[#111113] border border-white/[0.06] rounded-xl p-5 text-left hover:border-white/[0.12] transition-all duration-200">
          <div class="flex items-center justify-between mb-4">
            <div class="w-10 h-10 rounded-lg bg-blue-500/10 flex items-center justify-center">
              <Users :size="18" class="text-blue-400" />
            </div>
            <ArrowUpRight :size="16" class="text-zinc-600 group-hover:text-zinc-400 transition-colors" />
          </div>
          <p class="text-3xl font-semibold text-white tracking-tight">{{ stats.clients }}</p>
          <p class="text-sm text-zinc-500 mt-1">Clienti activi</p>
        </button>

        <button @click="router.push('/admin/module')"
          class="group relative bg-[#111113] border border-white/[0.06] rounded-xl p-5 text-left hover:border-white/[0.12] transition-all duration-200">
          <div class="flex items-center justify-between mb-4">
            <div class="w-10 h-10 rounded-lg bg-violet-500/10 flex items-center justify-center">
              <BookOpen :size="18" class="text-violet-400" />
            </div>
            <ArrowUpRight :size="16" class="text-zinc-600 group-hover:text-zinc-400 transition-colors" />
          </div>
          <p class="text-3xl font-semibold text-white tracking-tight">{{ stats.modules }}</p>
          <p class="text-sm text-zinc-500 mt-1">Module de training</p>
        </button>

        <button @click="router.push('/admin/checkins')"
          class="group relative bg-[#111113] border border-white/[0.06] rounded-xl p-5 text-left hover:border-white/[0.12] transition-all duration-200">
          <div class="flex items-center justify-between mb-4">
            <div class="w-10 h-10 rounded-lg bg-emerald-500/10 flex items-center justify-center">
              <ClipboardList :size="18" class="text-emerald-400" />
            </div>
            <ArrowUpRight :size="16" class="text-zinc-600 group-hover:text-zinc-400 transition-colors" />
          </div>
          <p class="text-3xl font-semibold text-white tracking-tight">{{ stats.checkins }}</p>
          <p class="text-sm text-zinc-500 mt-1">Check-in-uri totale</p>
        </button>
      </div>

      <!-- Recent check-ins -->
      <div>
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-base font-semibold text-white">Check-in-uri recente</h2>
          <button @click="router.push('/admin/checkins')"
            class="text-xs font-medium text-zinc-500 hover:text-white transition-colors flex items-center gap-1">
            Vezi toate <ArrowUpRight :size="12" />
          </button>
        </div>

        <div class="bg-[#111113] border border-white/[0.06] rounded-xl overflow-hidden">
          <!-- Loading -->
          <div v-if="loading" class="divide-y divide-white/[0.04]">
            <div v-for="i in 4" :key="i" class="h-[72px] animate-pulse bg-white/[0.02]"></div>
          </div>

          <!-- Empty -->
          <div v-else-if="recentCheckins.length === 0" class="py-16 text-center">
            <p class="text-sm text-zinc-500">Niciun check-in trimis inca.</p>
          </div>

          <!-- List -->
          <div v-else class="divide-y divide-white/[0.04]">
            <div v-for="ci in recentCheckins" :key="ci.id"
              class="flex items-center gap-4 px-5 py-4 hover:bg-white/[0.02] transition-colors">

              <!-- Avatar -->
              <div class="w-9 h-9 rounded-full flex items-center justify-center flex-shrink-0 text-xs font-bold"
                :style="`background: ${colors[ci.energy_level]}15; color: ${colors[ci.energy_level]}`">
                {{ (ci.client_name || 'C')[0].toUpperCase() }}
              </div>

              <!-- Info -->
              <div class="flex-1 min-w-0">
                <p class="text-sm font-medium text-white">{{ ci.client_name || 'Client' }}</p>
                <p class="text-xs text-zinc-500 mt-0.5">
                  Energie: <span :style="`color: ${colors[ci.energy_level]}`">{{ labels[ci.energy_level] }}</span>
                  <span class="text-zinc-600 mx-1.5">&middot;</span>
                  Somn: <span :style="`color: ${colors[ci.sleep_quality]}`">{{ labels[ci.sleep_quality] }}</span>
                  <span v-if="ci.weight" class="text-zinc-600 mx-1.5">&middot;</span>
                  <span v-if="ci.weight" class="text-zinc-400">{{ ci.weight }} kg</span>
                </p>
              </div>

              <!-- Date -->
              <span class="text-xs text-zinc-600 flex-shrink-0">{{ formatDate(ci.created_at) }}</span>
            </div>
          </div>
        </div>
      </div>

    </div>
  </AdminLayout>
</template>
