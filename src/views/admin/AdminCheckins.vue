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
  try {
    const { data } = await supabase.rpc('get_all_checkins')
    checkins.value = data || []
  } catch (e) { /* ignore */ }
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
      <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-8">
        <div>
          <h1 class="text-3xl font-semibold text-white tracking-tight">Check-in-uri</h1>
          <p class="text-base text-zinc-500 mt-2">Rapoarte saptamanale ale clientilor</p>
        </div>
        <span class="inline-flex items-center px-4 py-2 rounded-lg text-base font-medium text-zinc-300 bg-white/[0.04] border border-zinc-800">
          {{ checkins.length }} total
        </span>
      </div>

      <!-- Client filter -->
      <div v-if="Object.keys(clients).length > 1" class="mb-8 flex gap-2.5 flex-wrap">
        <button @click="filterClient = 'all'"
          class="filter-btn"
          :class="filterClient === 'all' ? 'filter-btn--active' : 'filter-btn--idle'">
          Toti
        </button>
        <button v-for="(name, id) in clients" :key="id" @click="filterClient = id"
          class="filter-btn"
          :class="filterClient === id ? 'filter-btn--active' : 'filter-btn--idle'">
          {{ name }}
        </button>
      </div>

      <!-- List -->
      <div class="bg-[#111113] border border-zinc-800 rounded-xl overflow-hidden">
        <div v-if="loading" class="divide-y divide-white/[0.04]">
          <div v-for="i in 4" :key="i" class="h-[96px] animate-pulse bg-white/[0.02]"></div>
        </div>

        <div v-else-if="filtered.length === 0" class="py-20 text-center">
          <p class="text-base text-zinc-500">Niciun check-in trimis inca.</p>
        </div>

        <div v-else class="divide-y divide-white/[0.04]">
          <div v-for="ci in filtered" :key="ci.id">

            <!-- Row -->
            <button @click="toggleExpand(ci.id)" class="w-full flex items-center gap-5 px-7 py-5 text-left hover:bg-white/[0.02] transition-colors">
              <!-- Score badge -->
              <div class="score-badge"
                :style="`background: ${scoreColors[avgScore(ci)]}12; border: 1px solid ${scoreColors[avgScore(ci)]}25; color: ${scoreColors[avgScore(ci)]}`">
                {{ avgScore(ci) }}
              </div>

              <!-- Info -->
              <div class="flex-1 min-w-0">
                <div class="flex items-center gap-3 mb-1.5">
                  <span class="text-base font-medium text-white">{{ ci.client_name || 'Client' }}</span>
                  <span v-if="ci.weight" class="text-sm text-zinc-500">{{ ci.weight }} kg</span>
                </div>
                <div class="flex items-center gap-2.5 flex-wrap">
                  <span v-if="ci.training_adherence" class="score-pill"
                    :style="`background: ${scoreColors[ci.training_adherence]}10; color: ${scoreColors[ci.training_adherence]}`">
                    Antrenament {{ ci.training_adherence }}/5
                  </span>
                  <span v-if="ci.nutrition_adherence" class="score-pill"
                    :style="`background: ${scoreColors[ci.nutrition_adherence]}10; color: ${scoreColors[ci.nutrition_adherence]}`">
                    Nutritie {{ ci.nutrition_adherence }}/5
                  </span>
                  <span v-if="ci.sleep_quality" class="score-pill"
                    :style="`background: ${scoreColors[ci.sleep_quality]}10; color: ${scoreColors[ci.sleep_quality]}`">
                    Somn {{ ci.sleep_quality }}/5
                  </span>
                </div>
              </div>

              <!-- Date & chevron -->
              <div class="flex items-center gap-4 flex-shrink-0">
                <span class="text-sm text-zinc-600 hidden sm:block">{{ formatDate(ci.created_at) }}</span>
                <ChevronDown v-if="expanded !== ci.id" :size="18" class="text-zinc-600" />
                <ChevronUp v-else :size="18" class="text-zinc-400" />
              </div>
            </button>

            <!-- Expanded details -->
            <div v-if="expanded === ci.id" class="px-7 pb-6 bg-white/[0.01] space-y-5">

              <!-- Date on mobile -->
              <p class="text-sm text-zinc-500 sm:hidden">{{ formatDate(ci.created_at) }}</p>

              <!-- Scores grid -->
              <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
                <div v-for="(label, key) in {
                  training_adherence: 'Antrenament',
                  nutrition_adherence: 'Nutritie',
                  energy_level: 'Energie',
                  sleep_quality: 'Somn'
                }" :key="key">
                  <div v-if="ci[key]" class="rounded-lg p-4 text-center border"
                    :style="`background: ${scoreColors[ci[key]]}08; border-color: ${scoreColors[ci[key]]}18`">
                    <p class="text-sm text-zinc-500 mb-1">{{ label }}</p>
                    <p class="text-2xl font-semibold" :style="`color: ${scoreColors[ci[key]]}`">{{ ci[key] }}/5</p>
                    <p class="text-xs font-medium mt-1" :style="`color: ${scoreColors[ci[key]]}`">{{ scoreLabels[ci[key]] }}</p>
                  </div>
                </div>
              </div>

              <!-- Additional scores -->
              <div v-if="ci.digestion || ci.stress_level || ci.appetite || ci.daily_steps" class="grid grid-cols-2 sm:grid-cols-4 gap-3">
                <div v-if="ci.digestion" class="rounded-lg p-4 border"
                  :style="`background: ${scoreColors[ci.digestion]}08; border-color: ${scoreColors[ci.digestion]}18`">
                  <p class="text-sm text-zinc-500 mb-1">Digestie</p>
                  <p class="text-base font-semibold" :style="`color: ${scoreColors[ci.digestion]}`">{{ scoreLabels[ci.digestion] }}</p>
                </div>
                <div v-if="ci.stress_level" class="rounded-lg p-4 bg-white/[0.02] border border-zinc-800">
                  <p class="text-sm text-zinc-500 mb-1">Stres</p>
                  <p class="text-base font-semibold text-white">{{ stressLabels[ci.stress_level] || ci.stress_level }}</p>
                </div>
                <div v-if="ci.appetite" class="rounded-lg p-4 bg-white/[0.02] border border-zinc-800">
                  <p class="text-sm text-zinc-500 mb-1">Apetit</p>
                  <p class="text-base font-semibold text-white">{{ appetiteLabels[ci.appetite] || ci.appetite }}</p>
                </div>
                <div v-if="ci.daily_steps" class="rounded-lg p-4 bg-white/[0.02] border border-zinc-800">
                  <p class="text-sm text-zinc-500 mb-1">Pasi zilnici</p>
                  <p class="text-base font-semibold text-white">{{ ci.daily_steps }}</p>
                </div>
              </div>

              <!-- Text fields -->
              <div v-if="ci.wins" class="detail-card detail-card--emerald">
                <p class="detail-label text-emerald-400">Cel mai mare castig</p>
                <p class="detail-text">{{ ci.wins }}</p>
              </div>

              <div v-if="ci.exercise_difficulties" class="detail-card detail-card--orange">
                <p class="detail-label text-orange-400">Dificultati antrenament</p>
                <p class="detail-text">{{ ci.exercise_difficulties }}</p>
              </div>

              <div v-if="ci.nutrition_notes" class="detail-card detail-card--blue">
                <p class="detail-label text-blue-400">Note nutritie</p>
                <p class="detail-text">{{ ci.nutrition_notes }}</p>
              </div>

              <div v-if="ci.alcohol" class="detail-card detail-card--violet">
                <p class="detail-label text-violet-400">Alcool</p>
                <p class="detail-text">{{ ci.alcohol }}</p>
              </div>

              <div v-if="ci.next_period_focus" class="detail-card detail-card--amber">
                <p class="detail-label text-amber-400">Focus perioada urmatoare</p>
                <p class="detail-text">{{ ci.next_period_focus }}</p>
              </div>

              <div v-if="ci.group_call_topics" class="detail-card detail-card--neutral">
                <p class="detail-label text-zinc-400">Subiecte apel grup</p>
                <p class="detail-text">{{ ci.group_call_topics }}</p>
              </div>

              <div v-if="ci.coach_support" class="detail-card detail-card--neutral">
                <p class="detail-label text-zinc-400">Suport solicitat</p>
                <p class="detail-text">{{ ci.coach_support }}</p>
              </div>

              <div v-if="ci.checkin_format" class="flex items-center gap-4 text-base pt-1">
                <span class="text-zinc-500 text-xs uppercase tracking-wider">Format preferat:</span>
                <span class="text-base font-medium text-white px-3 py-1.5 rounded-md bg-white/[0.04] border border-zinc-800">
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

<style scoped>
.filter-btn {
  padding: 0.625rem 1rem;
  border-radius: 0.5rem;
  font-size: 0.875rem;
  font-weight: 500;
  transition: all 0.15s;
  cursor: pointer;
  border: 1px solid;
}
.filter-btn--active {
  background: rgba(255,255,255,0.1);
  color: white;
  border-color: rgba(255,255,255,0.1);
}
.filter-btn--idle {
  background: rgba(255,255,255,0.03);
  color: #71717a;
  border-color: #27272a;
}
.filter-btn--idle:hover { color: #d4d4d8; }

.score-badge {
  width: 52px;
  height: 52px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  font-size: 1rem;
  font-weight: 700;
}

.score-pill {
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
  font-size: 0.8125rem;
  font-weight: 500;
  padding: 0.25rem 0.625rem;
  border-radius: 0.375rem;
}

.detail-card {
  border-radius: 0.75rem;
  padding: 1.25rem;
  border: 1px solid;
}
.detail-card--emerald { background: rgba(16,185,129,0.04); border-color: rgba(16,185,129,0.1); }
.detail-card--orange { background: rgba(249,115,22,0.04); border-color: rgba(249,115,22,0.1); }
.detail-card--blue { background: rgba(59,130,246,0.04); border-color: rgba(59,130,246,0.1); }
.detail-card--violet { background: rgba(139,92,246,0.04); border-color: rgba(139,92,246,0.1); }
.detail-card--amber { background: rgba(245,158,11,0.04); border-color: rgba(245,158,11,0.1); }
.detail-card--neutral { background: rgba(255,255,255,0.02); border-color: #27272a; }

.detail-label {
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 0.625rem;
}

.detail-text {
  font-size: 1rem;
  color: #d4d4d8;
  line-height: 1.625;
}
</style>
