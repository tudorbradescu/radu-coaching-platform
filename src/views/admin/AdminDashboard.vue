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

    <main class="max-w-2xl mx-auto px-5 pt-4 pb-24 sm:pb-8">

      <!-- Header -->
      <div class="mb-8">
        <p class="text-xs font-bold uppercase tracking-[0.3em] text-red-500 mb-1">Panou de control</p>
        <h1 class="text-5xl font-['Bebas_Neue'] tracking-wide text-white">Admin</h1>
      </div>

      <!-- Stats: 2 col on mobile, 3 on desktop -->
      <div class="grid grid-cols-2 sm:grid-cols-3 gap-3 mb-8">
        <div class="bg-[#111] border border-white/5 rounded-2xl p-5">
          <div class="flex items-center gap-2 mb-3">
            <Users :size="18" class="text-red-400" />
            <span class="text-xs font-bold uppercase tracking-widest text-gray-500">Clienți</span>
          </div>
          <p class="text-4xl font-['Bebas_Neue'] text-white">{{ stats.clients }}</p>
        </div>
        <div class="bg-[#111] border border-white/5 rounded-2xl p-5">
          <div class="flex items-center gap-2 mb-3">
            <BookOpen :size="18" class="text-orange-400" />
            <span class="text-xs font-bold uppercase tracking-widest text-gray-500">Module</span>
          </div>
          <p class="text-4xl font-['Bebas_Neue'] text-white">{{ stats.modules }}</p>
        </div>
        <div class="bg-[#111] border border-white/5 rounded-2xl p-5 col-span-2 sm:col-span-1">
          <div class="flex items-center gap-2 mb-3">
            <ClipboardList :size="18" class="text-green-400" />
            <span class="text-xs font-bold uppercase tracking-widest text-gray-500">Check-ins</span>
          </div>
          <p class="text-4xl font-['Bebas_Neue'] text-white">{{ stats.checkins }}</p>
        </div>
      </div>

      <!-- Quick links -->
      <div class="space-y-3 mb-8">
        <button @click="router.push('/admin/clienti')"
          class="w-full flex items-center gap-4 p-5 bg-[#111] border border-white/5 rounded-2xl active:scale-[0.98] transition-all text-left">
          <div class="w-14 h-14 rounded-2xl bg-red-500/10 border border-red-500/20 flex items-center justify-center flex-shrink-0">
            <Users :size="24" class="text-red-400" />
          </div>
          <div class="flex-1">
            <p class="text-base font-bold text-white">Clienți</p>
            <p class="text-sm text-gray-500">Atribuie module, adaugă clienți</p>
          </div>
          <ChevronRight :size="20" class="text-gray-600" />
        </button>

        <button @click="router.push('/admin/module')"
          class="w-full flex items-center gap-4 p-5 bg-[#111] border border-white/5 rounded-2xl active:scale-[0.98] transition-all text-left">
          <div class="w-14 h-14 rounded-2xl bg-orange-500/10 border border-orange-500/20 flex items-center justify-center flex-shrink-0">
            <BookOpen :size="24" class="text-orange-400" />
          </div>
          <div class="flex-1">
            <p class="text-base font-bold text-white">Module & Videouri</p>
            <p class="text-sm text-gray-500">Adaugă videouri, organizează conținut</p>
          </div>
          <ChevronRight :size="20" class="text-gray-600" />
        </button>

        <button @click="router.push('/admin/checkins')"
          class="w-full flex items-center gap-4 p-5 bg-[#111] border border-white/5 rounded-2xl active:scale-[0.98] transition-all text-left">
          <div class="w-14 h-14 rounded-2xl bg-green-500/10 border border-green-500/20 flex items-center justify-center flex-shrink-0">
            <ClipboardList :size="24" class="text-green-400" />
          </div>
          <div class="flex-1">
            <p class="text-base font-bold text-white">Check-in-uri</p>
            <p class="text-sm text-gray-500">Rapoarte săptămânale ale clienților</p>
          </div>
          <ChevronRight :size="20" class="text-gray-600" />
        </button>
      </div>

      <!-- Recent check-ins -->
      <div>
        <p class="text-xs font-bold uppercase tracking-[0.3em] text-gray-500 mb-4">Check-in-uri recente</p>

        <div v-if="loading" class="space-y-3">
          <div v-for="i in 3" :key="i" class="h-20 bg-[#111] rounded-2xl animate-pulse"></div>
        </div>

        <div v-else-if="recentCheckins.length === 0" class="text-center py-10 text-gray-500 text-sm">
          Niciun check-in trimis încă.
        </div>

        <div v-else class="space-y-3">
          <div v-for="ci in recentCheckins" :key="ci.id"
               class="flex items-center gap-4 p-5 bg-[#111] border border-white/5 rounded-2xl">
            <div class="w-12 h-12 rounded-2xl flex items-center justify-center flex-shrink-0"
                 :style="`background: ${colors[ci.energy_level]}20; border: 1px solid ${colors[ci.energy_level]}40`">
              <TrendingUp :size="20" :style="`color: ${colors[ci.energy_level]}`" />
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-base font-bold text-white">{{ ci.client_name || 'Client' }}</p>
              <p class="text-sm text-gray-500">
                Energie: <span :style="`color: ${colors[ci.energy_level]}`">{{ labels[ci.energy_level] }}</span>
                · Somn: <span :style="`color: ${colors[ci.sleep_quality]}`">{{ labels[ci.sleep_quality] }}</span>
                <span v-if="ci.weight"> · {{ ci.weight }} kg</span>
              </p>
            </div>
            <span class="text-sm text-gray-600 flex-shrink-0">{{ formatDate(ci.created_at) }}</span>
          </div>
        </div>
      </div>

    </main>
  </div>
</template>
