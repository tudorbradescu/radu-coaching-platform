<script setup>
import { ref, onMounted, computed } from 'vue'
import { supabase } from '@/supabase.js'
import AppNav from '@/components/layout/AppNav.vue'
import { useRouter } from 'vue-router'
import { ArrowLeft, ChevronDown, ChevronUp } from 'lucide-vue-next'

const router = useRouter()
const checkins = ref([])
const loading = ref(true)
const expanded = ref(null)
const filterClient = ref('all')

const scoreColors = {
  1: '#ef4444', 2: '#f97316', 3: '#eab308', 4: '#84cc16', 5: '#22c55e'
}
const scoreLabels = { 1: 'Foarte slab', 2: 'Slab', 3: 'Mediu', 4: 'Bun', 5: 'Foarte bun' }

const appetiteLabels = { mare: 'Mare / foame constantă', moderat: 'Moderat', scazut: 'Scăzut / rar' }
const stressLabels = { foarte_mare: 'Foarte mare', mare: 'Mare', mediu: 'Mediu', scazut: 'Scăzut/minimal' }
const formatLabels = { voice: 'Mesaj vocal', vimeo: 'Înregistrare video', call: 'Apel 1-la-1' }

onMounted(async () => {
  const { data } = await supabase.rpc('get_all_checkins')
  checkins.value = data || []
  loading.value = false
})

const clients = computed(() => {
  const map = {}
  checkins.value.forEach(c => {
    if (!map[c.client_id]) map[c.client_id] = c.client_name || c.client_email || 'Client'
  })
  return map
})

const filtered = computed(() =>
  filterClient.value === 'all' ? checkins.value : checkins.value.filter(c => c.client_id === filterClient.value)
)

function avgScore(ci) {
  const vals = [ci.energy_level, ci.sleep_quality, ci.nutrition_adherence, ci.training_adherence].filter(Boolean)
  if (!vals.length) return 3
  return Math.round(vals.reduce((a, b) => a + b, 0) / vals.length)
}

function formatDate(d) {
  return new Date(d).toLocaleDateString('ro-RO', { day: 'numeric', month: 'short', year: 'numeric' })
}

function toggleExpand(id) {
  expanded.value = expanded.value === id ? null : id
}
</script>

<template>
  <div class="min-h-screen bg-[#0a0a0a]">
    <AppNav />

    <main class="max-w-4xl mx-auto px-5 pt-4 pb-24 sm:pb-8">

      <button @click="router.push('/admin')" class="flex items-center gap-2 text-sm text-gray-500 hover:text-white transition-colors mb-6">
        <ArrowLeft :size="16" /> Admin
      </button>

      <div class="mb-8">
        <p class="text-xs font-bold uppercase tracking-[0.3em] text-red-500 mb-1">Rapoarte</p>
        <div class="flex items-end justify-between gap-4">
          <h1 class="text-5xl font-['Bebas_Neue'] tracking-wide text-white">Check-in-uri</h1>
          <span class="bg-[#111] border border-white/5 px-4 py-2 rounded-xl text-sm font-bold text-white shrink-0">{{ checkins.length }}</span>
        </div>
      </div>

      <!-- Client filter -->
      <div v-if="Object.keys(clients).length > 1" class="mb-6 flex gap-2 flex-wrap">
        <button @click="filterClient = 'all'"
          class="px-4 py-2.5 rounded-xl text-sm font-bold transition-all"
          :class="filterClient === 'all' ? 'bg-red-500/15 text-red-400 border border-red-500/30' : 'bg-[#111] text-gray-400 border border-white/5'">
          Toți
        </button>
        <button v-for="(name, id) in clients" :key="id" @click="filterClient = id"
          class="px-4 py-2.5 rounded-xl text-sm font-bold transition-all"
          :class="filterClient === id ? 'bg-red-500/15 text-red-400 border border-red-500/30' : 'bg-[#111] text-gray-400 border border-white/5'">
          {{ name }}
        </button>
      </div>

      <div v-if="loading" class="space-y-3">
        <div v-for="i in 4" :key="i" class="h-24 bg-[#111] rounded-2xl animate-pulse"></div>
      </div>

      <div v-else-if="filtered.length === 0" class="text-center py-16 text-gray-500">
        <p class="text-base">Niciun check-in trimis încă.</p>
      </div>

      <div v-else class="space-y-3">
        <div v-for="ci in filtered" :key="ci.id"
          class="bg-[#111] border border-white/5 rounded-2xl overflow-hidden"
          :class="expanded === ci.id ? 'border-white/10' : ''">

          <!-- Header -->
          <button @click="toggleExpand(ci.id)" class="w-full flex items-center gap-4 p-5 text-left">
            <div class="w-14 h-14 rounded-2xl flex items-center justify-center flex-shrink-0 text-xl font-['Bebas_Neue']"
              :style="`background: ${scoreColors[avgScore(ci)]}18; border: 1px solid ${scoreColors[avgScore(ci)]}35; color: ${scoreColors[avgScore(ci)]}`">
              {{ avgScore(ci) }}
            </div>
            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-2 mb-1">
                <span class="text-base font-bold text-white">{{ ci.client_name || 'Client' }}</span>
                <span v-if="ci.weight" class="text-sm text-gray-500">· {{ ci.weight }} kg</span>
              </div>
              <div class="flex items-center gap-3 flex-wrap">
                <span v-if="ci.training_adherence" class="text-xs font-semibold" :style="`color: ${scoreColors[ci.training_adherence]}`">
                  💪 {{ scoreLabels[ci.training_adherence] }}
                </span>
                <span v-if="ci.nutrition_adherence" class="text-xs font-semibold" :style="`color: ${scoreColors[ci.nutrition_adherence]}`">
                  🥗 {{ scoreLabels[ci.nutrition_adherence] }}
                </span>
                <span v-if="ci.sleep_quality" class="text-xs font-semibold" :style="`color: ${scoreColors[ci.sleep_quality]}`">
                  🌙 {{ scoreLabels[ci.sleep_quality] }}
                </span>
              </div>
              <p class="text-xs text-gray-600 mt-1">{{ formatDate(ci.created_at) }}</p>
            </div>
            <ChevronDown v-if="expanded !== ci.id" :size="20" class="text-gray-600 flex-shrink-0" />
            <ChevronUp v-else :size="20" class="text-red-400 flex-shrink-0" />
          </button>

          <!-- Expanded details -->
          <div v-if="expanded === ci.id" class="border-t border-white/5 px-5 pb-5 pt-4 space-y-4">

            <!-- Scores grid -->
            <div class="grid grid-cols-2 gap-2">
              <div v-for="(label, key) in {
                training_adherence: '💪 Antrenament',
                nutrition_adherence: '🥗 Nutriție',
                energy_level: '⚡ Energie',
                sleep_quality: '🌙 Somn'
              }" :key="key">
                <div v-if="ci[key]" class="rounded-xl p-3 text-center"
                  :style="`background: ${scoreColors[ci[key]]}10; border: 1px solid ${scoreColors[ci[key]]}25`">
                  <p class="text-xs text-gray-500 mb-1">{{ label }}</p>
                  <p class="text-2xl font-['Bebas_Neue']" :style="`color: ${scoreColors[ci[key]]}`">{{ ci[key] }}</p>
                  <p class="text-xs font-bold" :style="`color: ${scoreColors[ci[key]]}`">{{ scoreLabels[ci[key]] }}</p>
                </div>
              </div>
            </div>

            <!-- Additional scores -->
            <div v-if="ci.digestion || ci.stress_level || ci.appetite" class="grid grid-cols-2 gap-2">
              <div v-if="ci.digestion" class="rounded-xl p-3"
                :style="`background: ${scoreColors[ci.digestion]}10; border: 1px solid ${scoreColors[ci.digestion]}25`">
                <p class="text-xs text-gray-500 mb-1">🫶 Digestie</p>
                <p class="text-sm font-bold" :style="`color: ${scoreColors[ci.digestion]}`">{{ scoreLabels[ci.digestion] }}</p>
              </div>
              <div v-if="ci.stress_level" class="rounded-xl p-3 bg-white/3 border border-white/8">
                <p class="text-xs text-gray-500 mb-1">😤 Stres</p>
                <p class="text-sm font-bold text-white">{{ stressLabels[ci.stress_level] || ci.stress_level }}</p>
              </div>
              <div v-if="ci.appetite" class="rounded-xl p-3 bg-white/3 border border-white/8">
                <p class="text-xs text-gray-500 mb-1">🍽️ Apetit</p>
                <p class="text-sm font-bold text-white">{{ appetiteLabels[ci.appetite] || ci.appetite }}</p>
              </div>
              <div v-if="ci.daily_steps" class="rounded-xl p-3 bg-white/3 border border-white/8">
                <p class="text-xs text-gray-500 mb-1">👟 Pași zilnici</p>
                <p class="text-sm font-bold text-white">{{ ci.daily_steps }}</p>
              </div>
            </div>

            <!-- Text fields -->
            <div v-if="ci.wins" class="rounded-xl p-4 bg-green-500/5 border border-green-500/15">
              <p class="text-xs font-bold uppercase tracking-wider text-green-400 mb-2">🏆 Cel mai mare câștig</p>
              <p class="text-sm text-gray-300 leading-relaxed">{{ ci.wins }}</p>
            </div>

            <div v-if="ci.exercise_difficulties" class="rounded-xl p-4 bg-orange-500/5 border border-orange-500/15">
              <p class="text-xs font-bold uppercase tracking-wider text-orange-400 mb-2">💪 Dificultăți antrenament</p>
              <p class="text-sm text-gray-300 leading-relaxed">{{ ci.exercise_difficulties }}</p>
            </div>

            <div v-if="ci.nutrition_notes" class="rounded-xl p-4 bg-blue-500/5 border border-blue-500/15">
              <p class="text-xs font-bold uppercase tracking-wider text-blue-400 mb-2">🥗 Note nutriție</p>
              <p class="text-sm text-gray-300 leading-relaxed">{{ ci.nutrition_notes }}</p>
            </div>

            <div v-if="ci.alcohol" class="rounded-xl p-4 bg-purple-500/5 border border-purple-500/15">
              <p class="text-xs font-bold uppercase tracking-wider text-purple-400 mb-2">🍷 Alcool</p>
              <p class="text-sm text-gray-300 leading-relaxed">{{ ci.alcohol }}</p>
            </div>

            <div v-if="ci.next_period_focus" class="rounded-xl p-4 bg-yellow-500/5 border border-yellow-500/15">
              <p class="text-xs font-bold uppercase tracking-wider text-yellow-400 mb-2">🎯 Focus perioada următoare</p>
              <p class="text-sm text-gray-300 leading-relaxed">{{ ci.next_period_focus }}</p>
            </div>

            <div v-if="ci.group_call_topics" class="rounded-xl p-4 bg-white/3 border border-white/8">
              <p class="text-xs font-bold uppercase tracking-wider text-gray-400 mb-2">🗣️ Subiecte apel grup</p>
              <p class="text-sm text-gray-300 leading-relaxed">{{ ci.group_call_topics }}</p>
            </div>

            <div v-if="ci.coach_support" class="rounded-xl p-4 bg-white/3 border border-white/8">
              <p class="text-xs font-bold uppercase tracking-wider text-gray-400 mb-2">🤝 Suport solicitat</p>
              <p class="text-sm text-gray-300 leading-relaxed">{{ ci.coach_support }}</p>
            </div>

            <div v-if="ci.checkin_format" class="flex items-center gap-3 text-sm">
              <span class="text-gray-500 text-xs uppercase tracking-wider">Format preferat:</span>
              <span class="font-bold text-white">{{ formatLabels[ci.checkin_format] || ci.checkin_format }}</span>
            </div>

          </div>
        </div>
      </div>
    </main>
  </div>
</template>
