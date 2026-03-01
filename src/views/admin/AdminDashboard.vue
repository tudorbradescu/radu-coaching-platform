<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/supabase.js'
import AppNav from '@/components/layout/AppNav.vue'
import { Users, BookOpen, ClipboardList, ChevronRight, TrendingUp } from 'lucide-vue-next'
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
  <div class="min-h-screen bg-[#0a0a0a]">
    <AppNav />

    <main class="max-w-5xl mx-auto px-4 pt-6 pb-16">

      <div class="mb-10">
        <p class="text-xs font-semibold uppercase tracking-[0.3em] text-red-500 mb-2">Panou de control</p>
        <h1 class="text-4xl sm:text-5xl font-['Bebas_Neue'] tracking-wide text-white">Admin</h1>
      </div>

      <!-- Stats -->
      <div class="grid grid-cols-3 gap-3 mb-10">
        <div class="bg-[#111] border border-white/5 rounded-xl p-5">
          <div class="flex items-center gap-2 mb-3">
            <Users :size="16" class="text-red-400" />
            <span class="text-xs font-semibold uppercase tracking-widest text-gray-500">Clienți</span>
          </div>
          <p class="text-3xl font-['Bebas_Neue'] text-white">{{ stats.clients }}</p>
        </div>
        <div class="bg-[#111] border border-white/5 rounded-xl p-5">
          <div class="flex items-center gap-2 mb-3">
            <BookOpen :size="16" class="text-orange-400" />
            <span class="text-xs font-semibold uppercase tracking-widest text-gray-500">Module</span>
          </div>
          <p class="text-3xl font-['Bebas_Neue'] text-white">{{ stats.modules }}</p>
        </div>
        <div class="bg-[#111] border border-white/5 rounded-xl p-5">
          <div class="flex items-center gap-2 mb-3">
            <ClipboardList :size="16" class="text-green-400" />
            <span class="text-xs font-semibold uppercase tracking-widest text-gray-500">Check-ins</span>
          </div>
          <p class="text-3xl font-['Bebas_Neue'] text-white">{{ stats.checkins }}</p>
        </div>
      </div>

      <!-- Quick links -->
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 mb-10">
        <button @click="router.push('/admin/clienti')"
          class="group flex items-center justify-between p-5 bg-[#111] border border-white/5 rounded-xl hover:border-red-500/30 transition-all text-left">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-red-500/10 border border-red-500/20 flex items-center justify-center">
              <Users :size="18" class="text-red-400" />
            </div>
            <div>
              <p class="text-sm font-semibold text-white">Gestionează clienții</p>
              <p class="text-xs text-gray-500">Atribuie module, vezi progres</p>
            </div>
          </div>
          <ChevronRight :size="16" class="text-gray-600 group-hover:text-red-400 transition-colors" />
        </button>

        <button @click="router.push('/admin/module')"
          class="group flex items-center justify-between p-5 bg-[#111] border border-white/5 rounded-xl hover:border-orange-500/30 transition-all text-left">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-orange-500/10 border border-orange-500/20 flex items-center justify-center">
              <BookOpen :size="18" class="text-orange-400" />
            </div>
            <div>
              <p class="text-sm font-semibold text-white">Gestionează module</p>
              <p class="text-xs text-gray-500">Adaugă videouri, organizează conținut</p>
            </div>
          </div>
          <ChevronRight :size="16" class="text-gray-600 group-hover:text-orange-400 transition-colors" />
        </button>

        <button @click="router.push('/admin/checkins')"
          class="group flex items-center justify-between p-5 bg-[#111] border border-white/5 rounded-xl hover:border-green-500/30 transition-all text-left">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-green-500/10 border border-green-500/20 flex items-center justify-center">
              <ClipboardList :size="18" class="text-green-400" />
            </div>
            <div>
              <p class="text-sm font-semibold text-white">Vezi check-in-uri</p>
              <p class="text-xs text-gray-500">Rapoarte săptămânale ale clienților</p>
            </div>
          </div>
          <ChevronRight :size="16" class="text-gray-600 group-hover:text-green-400 transition-colors" />
        </button>
      </div>

      <!-- Recent check-ins -->
      <div>
        <p class="text-xs font-semibold uppercase tracking-[0.3em] text-gray-500 mb-4">Check-in-uri recente</p>

        <div v-if="loading" class="space-y-2">
          <div v-for="i in 3" :key="i" class="h-16 bg-[#111] rounded-xl animate-pulse"></div>
        </div>

        <div v-else-if="recentCheckins.length === 0" class="text-center py-10 text-gray-500 text-sm">
          Niciun check-in trimis încă.
        </div>

        <div v-else class="space-y-2">
          <div v-for="ci in recentCheckins" :key="ci.id"
               class="flex items-center gap-4 p-4 bg-[#111] border border-white/5 rounded-xl">
            <div class="w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0"
                 :style="`background: ${colors[ci.energy_level]}20; border: 1px solid ${colors[ci.energy_level]}40`">
              <TrendingUp :size="16" :style="`color: ${colors[ci.energy_level]}`" />
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-sm font-semibold text-white">{{ ci.client_name || 'Client' }}</p>
              <p class="text-xs text-gray-500">
                Energie: <span :style="`color: ${colors[ci.energy_level]}`">{{ labels[ci.energy_level] }}</span>
                · Somn: <span :style="`color: ${colors[ci.sleep_quality]}`">{{ labels[ci.sleep_quality] }}</span>
                <span v-if="ci.weight"> · {{ ci.weight }} kg</span>
              </p>
            </div>
            <span class="text-xs text-gray-600 flex-shrink-0">{{ formatDate(ci.created_at) }}</span>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>
