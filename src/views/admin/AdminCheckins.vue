<script setup>
import { ref, onMounted, computed } from 'vue'
import { supabase } from '@/supabase.js'
import AdminLayout from '@/components/layout/AdminLayout.vue'
import { ChevronDown, ChevronUp } from 'lucide-vue-next'

const checkins = ref([])
const loading = ref(true)
const expanded = ref(null)
const filterClient = ref('all')

const scoreColors = {
  1: '#ef4444', 2: '#f97316', 3: '#eab308', 4: '#84cc16', 5: '#22c55e'
}
const scoreLabels = { 1: 'Foarte slab', 2: 'Slab', 3: 'Mediu', 4: 'Bun', 5: 'Foarte bun' }

const appetiteLabels = { mare: 'Mare / foame constanta', moderat: 'Moderat', scazut: 'Scazut / rar' }
const stressLabels = { foarte_mare: 'Foarte mare', mare: 'Mare', mediu: 'Mediu', scazut: 'Scazut/minimal' }
const formatLabels = { voice: 'Mesaj vocal', vimeo: 'Inregistrare video', call: 'Apel 1-la-1' }

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
  <AdminLayout>
    <div class="admin-content">

      <!-- Header -->
      <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <div>
          <h1 class="text-2xl font-semibold text-white tracking-tight">Check-in-uri</h1>
          <p class="text-sm text-zinc-500 mt-1">Rapoarte saptamanale ale clientilor</p>
        </div>
        <span class="inline-flex items-center px-3 py-1.5 rounded-lg text-sm font-medium text-zinc-300 bg-white/[0.04] border border-zinc-800">
          {{ checkins.length }} total
        </span>
      </div>

      <!-- Client filter -->
      <div v-if="Object.keys(clients).length > 1" class="mb-6 flex gap-2 flex-wrap">
        <button @click="filterClient = 'all'"
          class="px-3.5 py-2 rounded-lg text-xs font-medium transition-all"
          :class="filterClient === 'all' ? 'bg-white/[0.1] text-white border border-white/[0.1]' : 'bg-white/[0.03] text-zinc-500 border border-zinc-800 hover:text-zinc-300'">
          Toti
        </button>
        <button v-for="(name, id) in clients" :key="id" @click="filterClient = id"
          class="px-3.5 py-2 rounded-lg text-xs font-medium transition-all"
          :class="filterClient === id ? 'bg-white/[0.1] text-white border border-white/[0.1]' : 'bg-white/[0.03] text-zinc-500 border border-zinc-800 hover:text-zinc-300'">
          {{ name }}
        </button>
      </div>

      <!-- List -->
      <div class="bg-[#111113] border border-zinc-800 rounded-xl overflow-hidden">
        <div v-if="loading" class="divide-y divide-white/[0.04]">
          <div v-for="i in 4" :key="i" class="h-[80px] animate-pulse bg-white/[0.02]"></div>
        </div>

        <div v-else-if="filtered.length === 0" class="py-16 text-center">
          <p class="text-sm text-zinc-500">Niciun check-in trimis inca.</p>
        </div>

        <div v-else class="divide-y divide-white/[0.04]">
          <div v-for="ci in filtered" :key="ci.id">

            <!-- Row -->
            <button @click="toggleExpand(ci.id)" class="w-full flex items-center gap-4 px-5 py-4 text-left hover:bg-white/[0.02] transition-colors">
              <!-- Score badge -->
              <div class="w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0 text-sm font-bold"
                :style="`background: ${scoreColors[avgScore(ci)]}12; border: 1px solid ${scoreColors[avgScore(ci)]}25; color: ${scoreColors[avgScore(ci)]}`">
                {{ avgScore(ci) }}
              </div>

              <!-- Info -->
              <div class="flex-1 min-w-0">
                <div class="flex items-center gap-2 mb-1">
                  <span class="text-sm font-medium text-white">{{ ci.client_name || 'Client' }}</span>
                  <span v-if="ci.weight" class="text-xs text-zinc-500">{{ ci.weight }} kg</span>
                </div>
                <div class="flex items-center gap-2 flex-wrap">
                  <span v-if="ci.training_adherence" class="inline-flex items-center gap-1 text-[11px] font-medium px-2 py-0.5 rounded-md"
                    :style="`background: ${scoreColors[ci.training_adherence]}10; color: ${scoreColors[ci.training_adherence]}`">
                    Antrenament {{ ci.training_adherence }}/5
                  </span>
                  <span v-if="ci.nutrition_adherence" class="inline-flex items-center gap-1 text-[11px] font-medium px-2 py-0.5 rounded-md"
                    :style="`background: ${scoreColors[ci.nutrition_adherence]}10; color: ${scoreColors[ci.nutrition_adherence]}`">
                    Nutritie {{ ci.nutrition_adherence }}/5
                  </span>
                  <span v-if="ci.sleep_quality" class="inline-flex items-center gap-1 text-[11px] font-medium px-2 py-0.5 rounded-md"
                    :style="`background: ${scoreColors[ci.sleep_quality]}10; color: ${scoreColors[ci.sleep_quality]}`">
                    Somn {{ ci.sleep_quality }}/5
                  </span>
                </div>
              </div>

              <!-- Date & chevron -->
              <div class="flex items-center gap-3 flex-shrink-0">
                <span class="text-xs text-zinc-600 hidden sm:block">{{ formatDate(ci.created_at) }}</span>
                <ChevronDown v-if="expanded !== ci.id" :size="16" class="text-zinc-600" />
                <ChevronUp v-else :size="16" class="text-zinc-400" />
              </div>
            </button>

            <!-- Expanded details -->
            <div v-if="expanded === ci.id" class="px-5 pb-5 bg-white/[0.01] space-y-4">

              <!-- Date on mobile -->
              <p class="text-xs text-zinc-500 sm:hidden">{{ formatDate(ci.created_at) }}</p>

              <!-- Scores grid -->
              <div class="grid grid-cols-2 sm:grid-cols-4 gap-2">
                <div v-for="(label, key) in {
                  training_adherence: 'Antrenament',
                  nutrition_adherence: 'Nutritie',
                  energy_level: 'Energie',
                  sleep_quality: 'Somn'
                }" :key="key">
                  <div v-if="ci[key]" class="rounded-lg p-3 text-center border"
                    :style="`background: ${scoreColors[ci[key]]}08; border-color: ${scoreColors[ci[key]]}18`">
                    <p class="text-xs text-zinc-500 mb-1">{{ label }}</p>
                    <p class="text-xl font-semibold" :style="`color: ${scoreColors[ci[key]]}`">{{ ci[key] }}/5</p>
                    <p class="text-[11px] font-medium mt-0.5" :style="`color: ${scoreColors[ci[key]]}`">{{ scoreLabels[ci[key]] }}</p>
                  </div>
                </div>
              </div>

              <!-- Additional scores -->
              <div v-if="ci.digestion || ci.stress_level || ci.appetite || ci.daily_steps" class="grid grid-cols-2 sm:grid-cols-4 gap-2">
                <div v-if="ci.digestion" class="rounded-lg p-3 border"
                  :style="`background: ${scoreColors[ci.digestion]}08; border-color: ${scoreColors[ci.digestion]}18`">
                  <p class="text-xs text-zinc-500 mb-1">Digestie</p>
                  <p class="text-sm font-semibold" :style="`color: ${scoreColors[ci.digestion]}`">{{ scoreLabels[ci.digestion] }}</p>
                </div>
                <div v-if="ci.stress_level" class="rounded-lg p-3 bg-white/[0.02] border border-zinc-800">
                  <p class="text-xs text-zinc-500 mb-1">Stres</p>
                  <p class="text-sm font-semibold text-white">{{ stressLabels[ci.stress_level] || ci.stress_level }}</p>
                </div>
                <div v-if="ci.appetite" class="rounded-lg p-3 bg-white/[0.02] border border-zinc-800">
                  <p class="text-xs text-zinc-500 mb-1">Apetit</p>
                  <p class="text-sm font-semibold text-white">{{ appetiteLabels[ci.appetite] || ci.appetite }}</p>
                </div>
                <div v-if="ci.daily_steps" class="rounded-lg p-3 bg-white/[0.02] border border-zinc-800">
                  <p class="text-xs text-zinc-500 mb-1">Pasi zilnici</p>
                  <p class="text-sm font-semibold text-white">{{ ci.daily_steps }}</p>
                </div>
              </div>

              <!-- Text fields -->
              <div v-if="ci.wins" class="rounded-lg p-4 bg-emerald-500/[0.04] border border-emerald-500/10">
                <p class="text-xs font-semibold uppercase tracking-wider text-emerald-400 mb-2">Cel mai mare castig</p>
                <p class="text-sm text-zinc-300 leading-relaxed">{{ ci.wins }}</p>
              </div>

              <div v-if="ci.exercise_difficulties" class="rounded-lg p-4 bg-orange-500/[0.04] border border-orange-500/10">
                <p class="text-xs font-semibold uppercase tracking-wider text-orange-400 mb-2">Dificultati antrenament</p>
                <p class="text-sm text-zinc-300 leading-relaxed">{{ ci.exercise_difficulties }}</p>
              </div>

              <div v-if="ci.nutrition_notes" class="rounded-lg p-4 bg-blue-500/[0.04] border border-blue-500/10">
                <p class="text-xs font-semibold uppercase tracking-wider text-blue-400 mb-2">Note nutritie</p>
                <p class="text-sm text-zinc-300 leading-relaxed">{{ ci.nutrition_notes }}</p>
              </div>

              <div v-if="ci.alcohol" class="rounded-lg p-4 bg-violet-500/[0.04] border border-violet-500/10">
                <p class="text-xs font-semibold uppercase tracking-wider text-violet-400 mb-2">Alcool</p>
                <p class="text-sm text-zinc-300 leading-relaxed">{{ ci.alcohol }}</p>
              </div>

              <div v-if="ci.next_period_focus" class="rounded-lg p-4 bg-amber-500/[0.04] border border-amber-500/10">
                <p class="text-xs font-semibold uppercase tracking-wider text-amber-400 mb-2">Focus perioada urmatoare</p>
                <p class="text-sm text-zinc-300 leading-relaxed">{{ ci.next_period_focus }}</p>
              </div>

              <div v-if="ci.group_call_topics" class="rounded-lg p-4 bg-white/[0.02] border border-zinc-800">
                <p class="text-xs font-semibold uppercase tracking-wider text-zinc-400 mb-2">Subiecte apel grup</p>
                <p class="text-sm text-zinc-300 leading-relaxed">{{ ci.group_call_topics }}</p>
              </div>

              <div v-if="ci.coach_support" class="rounded-lg p-4 bg-white/[0.02] border border-zinc-800">
                <p class="text-xs font-semibold uppercase tracking-wider text-zinc-400 mb-2">Suport solicitat</p>
                <p class="text-sm text-zinc-300 leading-relaxed">{{ ci.coach_support }}</p>
              </div>

              <div v-if="ci.checkin_format" class="flex items-center gap-3 text-sm pt-1">
                <span class="text-zinc-500 text-xs uppercase tracking-wider">Format preferat:</span>
                <span class="text-sm font-medium text-white px-2.5 py-1 rounded-md bg-white/[0.04] border border-zinc-800">
                  {{ formatLabels[ci.checkin_format] || ci.checkin_format }}
                </span>
              </div>

            </div>
          </div>
        </div>
      </div>

    </div>
  </AdminLayout>
</template>
