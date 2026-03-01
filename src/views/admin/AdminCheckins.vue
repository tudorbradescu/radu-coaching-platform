<script setup>
import { ref, onMounted, computed } from 'vue'
import { supabase } from '@/supabase.js'
import AppNav from '@/components/layout/AppNav.vue'
import { useRouter } from 'vue-router'
import { ArrowLeft, ChevronDown, ChevronUp, Weight, Zap, Moon, Salad, Dumbbell, Trophy, AlertTriangle, FileText } from 'lucide-vue-next'

const router = useRouter()
const checkins = ref([])
const loading = ref(true)
const expanded = ref(null)
const filterClient = ref('all')

const scoreColors = {
  1: { text: 'text-red-400', bg: 'bg-red-500/10', border: 'border-red-500/20', hex: '#ef4444' },
  2: { text: 'text-orange-400', bg: 'bg-orange-500/10', border: 'border-orange-500/20', hex: '#f97316' },
  3: { text: 'text-yellow-400', bg: 'bg-yellow-500/10', border: 'border-yellow-500/20', hex: '#eab308' },
  4: { text: 'text-lime-400', bg: 'bg-lime-500/10', border: 'border-lime-500/20', hex: '#84cc16' },
  5: { text: 'text-green-400', bg: 'bg-green-500/10', border: 'border-green-500/20', hex: '#22c55e' }
}
const scoreLabels = { 1: 'Slab', 2: 'Acceptabil', 3: 'OK', 4: 'Bine', 5: 'Excelent' }

onMounted(async () => {
  const { data } = await supabase
    .from('checkins')
    .select('*, client:profiles(full_name, email)')
    .order('created_at', { ascending: false })
  checkins.value = data || []
  loading.value = false
})

const clients = computed(() => {
  const map = {}
  checkins.value.forEach(c => {
    const id = c.client_id
    if (!map[id]) map[id] = c.client?.full_name || c.client?.email || 'Client necunoscut'
  })
  return map
})

const filtered = computed(() => {
  if (filterClient.value === 'all') return checkins.value
  return checkins.value.filter(c => c.client_id === filterClient.value)
})

function avgScore(ci) {
  return Math.round((ci.energy_level + ci.sleep_quality + ci.nutrition_adherence + ci.training_adherence) / 4)
}

function formatDate(d) {
  return new Date(d).toLocaleDateString('ro-RO', { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' })
}

function toggleExpand(id) {
  expanded.value = expanded.value === id ? null : id
}
</script>

<template>
  <div class="min-h-screen bg-[#0a0a0a]">
    <AppNav />

    <main class="max-w-4xl mx-auto px-4 pt-6 pb-16">

      <!-- Header -->
      <button @click="router.push('/admin')" class="flex items-center gap-2 text-sm text-gray-500 hover:text-white transition-colors mb-8 group">
        <ArrowLeft :size="16" class="group-hover:-translate-x-1 transition-transform" /> Admin
      </button>

      <div class="flex items-end justify-between mb-8 gap-4 flex-wrap">
        <div>
          <p class="text-xs font-semibold uppercase tracking-[0.3em] text-red-500 mb-2">Rapoarte</p>
          <h1 class="text-4xl font-['Bebas_Neue'] tracking-wide text-white">Check-in-uri</h1>
        </div>
        <div class="flex items-center gap-2 text-xs text-gray-500">
          <span class="bg-[#111] border border-white/5 px-3 py-1.5 rounded-lg">
            Total: <span class="text-white font-semibold">{{ checkins.length }}</span>
          </span>
        </div>
      </div>

      <!-- Filter by client -->
      <div v-if="Object.keys(clients).length > 1" class="mb-6 flex gap-2 flex-wrap">
        <button
          @click="filterClient = 'all'"
          class="px-3 py-1.5 rounded-lg text-xs font-semibold transition-all"
          :class="filterClient === 'all' ? 'bg-red-500/15 text-red-400 border border-red-500/30' : 'bg-[#111] text-gray-400 border border-white/5 hover:border-white/20'"
        >Toți clienții</button>
        <button
          v-for="(name, id) in clients" :key="id"
          @click="filterClient = id"
          class="px-3 py-1.5 rounded-lg text-xs font-semibold transition-all"
          :class="filterClient === id ? 'bg-red-500/15 text-red-400 border border-red-500/30' : 'bg-[#111] text-gray-400 border border-white/5 hover:border-white/20'"
        >{{ name }}</button>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="space-y-3">
        <div v-for="i in 4" :key="i" class="h-20 bg-[#111] rounded-xl animate-pulse"></div>
      </div>

      <!-- Empty -->
      <div v-else-if="filtered.length === 0" class="text-center py-16 text-gray-500 text-sm">
        Niciun check-in trimis încă.
      </div>

      <!-- Check-in list -->
      <div v-else class="space-y-3">
        <div
          v-for="ci in filtered" :key="ci.id"
          class="bg-[#111] border border-white/5 rounded-xl overflow-hidden transition-all"
          :class="expanded === ci.id ? 'border-white/10' : ''"
        >
          <!-- Row header (always visible) -->
          <button
            @click="toggleExpand(ci.id)"
            class="w-full flex items-center gap-3 p-4 text-left hover:bg-white/2 transition-colors"
          >
            <!-- Score badge -->
            <div
              class="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0 text-sm font-bold"
              :style="`background: ${scoreColors[avgScore(ci)].hex}18; border: 1px solid ${scoreColors[avgScore(ci)].hex}35; color: ${scoreColors[avgScore(ci)].hex}`"
            >{{ avgScore(ci) }}</div>

            <!-- Info -->
            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-2 flex-wrap">
                <span class="text-sm font-semibold text-white">{{ ci.client?.full_name || 'Client' }}</span>
                <span v-if="ci.weight" class="text-xs text-gray-500">· {{ ci.weight }} kg</span>
              </div>
              <div class="flex items-center gap-3 mt-1 flex-wrap">
                <span class="text-xs" :style="`color: ${scoreColors[ci.energy_level].hex}`">⚡ {{ scoreLabels[ci.energy_level] }}</span>
                <span class="text-xs" :style="`color: ${scoreColors[ci.sleep_quality].hex}`">🌙 {{ scoreLabels[ci.sleep_quality] }}</span>
                <span class="text-xs" :style="`color: ${scoreColors[ci.nutrition_adherence].hex}`">🥗 {{ scoreLabels[ci.nutrition_adherence] }}</span>
                <span class="text-xs" :style="`color: ${scoreColors[ci.training_adherence].hex}`">💪 {{ scoreLabels[ci.training_adherence] }}</span>
              </div>
            </div>

            <!-- Date + expand -->
            <div class="flex items-center gap-2 flex-shrink-0">
              <span class="text-xs text-gray-600 hidden sm:block">{{ formatDate(ci.created_at) }}</span>
              <ChevronDown v-if="expanded !== ci.id" :size="16" class="text-gray-600" />
              <ChevronUp v-else :size="16" class="text-red-400" />
            </div>
          </button>

          <!-- Expanded details -->
          <div v-if="expanded === ci.id" class="border-t border-white/5 px-4 pb-4 pt-4 space-y-4">

            <!-- Date on mobile -->
            <p class="text-xs text-gray-500 sm:hidden">{{ formatDate(ci.created_at) }}</p>

            <!-- Scores grid -->
            <div class="grid grid-cols-2 sm:grid-cols-4 gap-2">
              <div v-for="(label, key) in { energy_level: '⚡ Energie', sleep_quality: '🌙 Somn', nutrition_adherence: '🥗 Nutriție', training_adherence: '💪 Antrenament' }" :key="key"
                class="rounded-xl p-3 text-center"
                :style="`background: ${scoreColors[ci[key]].hex}10; border: 1px solid ${scoreColors[ci[key]].hex}25`">
                <p class="text-xs text-gray-500 mb-1">{{ label }}</p>
                <p class="text-xl font-bold" :style="`color: ${scoreColors[ci[key]].hex}`">{{ ci[key] }}</p>
                <p class="text-xs" :style="`color: ${scoreColors[ci[key]].hex}`">{{ scoreLabels[ci[key]] }}</p>
              </div>
            </div>

            <!-- Weight -->
            <div v-if="ci.weight" class="flex items-center gap-2 text-sm text-gray-300">
              <span class="text-gray-500 text-xs uppercase tracking-wider">Greutate:</span>
              <span class="font-semibold text-white">{{ ci.weight }} kg</span>
            </div>

            <!-- Wins -->
            <div v-if="ci.wins" class="rounded-xl p-4 bg-green-500/5 border border-green-500/15">
              <p class="text-xs font-semibold uppercase tracking-wider text-green-400 mb-2">🏆 Victorii</p>
              <p class="text-sm text-gray-300 leading-relaxed">{{ ci.wins }}</p>
            </div>

            <!-- Challenges -->
            <div v-if="ci.challenges" class="rounded-xl p-4 bg-orange-500/5 border border-orange-500/15">
              <p class="text-xs font-semibold uppercase tracking-wider text-orange-400 mb-2">🤔 Provocări</p>
              <p class="text-sm text-gray-300 leading-relaxed">{{ ci.challenges }}</p>
            </div>

            <!-- Notes -->
            <div v-if="ci.notes" class="rounded-xl p-4 bg-white/3 border border-white/8">
              <p class="text-xs font-semibold uppercase tracking-wider text-gray-400 mb-2">📝 Note</p>
              <p class="text-sm text-gray-300 leading-relaxed">{{ ci.notes }}</p>
            </div>

          </div>
        </div>
      </div>

    </main>
  </div>
</template>
