<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth.js'
import { supabase } from '@/supabase.js'
import AppNav from '@/components/layout/AppNav.vue'
import { Video, ExternalLink, Check, Users } from 'lucide-vue-next'

const auth = useAuthStore()
const sessions = ref([])
const loading = ref(true)
const filter = ref('upcoming')

onMounted(async () => {
  await fetchSessions()
  loading.value = false
})

async function fetchSessions() {
  const { data } = await supabase
    .from('live_sessions')
    .select(`
      *,
      rsvps:live_session_rsvps(id, user_id)
    `)
    .order('scheduled_at', { ascending: true })

  sessions.value = data || []
}

const filteredSessions = computed(() => {
  const now = new Date()
  if (filter.value === 'upcoming') {
    return sessions.value.filter(s => new Date(s.scheduled_at) >= now)
  }
  return sessions.value.filter(s => new Date(s.scheduled_at) < now)
})

function hasRsvp(session) {
  return session.rsvps?.some(r => r.user_id === auth.user.id)
}

function rsvpCount(session) {
  return session.rsvps?.length || 0
}

async function toggleRsvp(session) {
  const existing = session.rsvps?.find(r => r.user_id === auth.user.id)
  if (existing) {
    await supabase.from('live_session_rsvps').delete().eq('id', existing.id)
  } else {
    await supabase.from('live_session_rsvps').insert({
      session_id: session.id,
      user_id: auth.user.id
    })
  }
  await fetchSessions()
}

function formatDate(dateStr) {
  const date = new Date(dateStr)
  const now = new Date()
  const tomorrow = new Date(now)
  tomorrow.setDate(tomorrow.getDate() + 1)

  const isToday = date.toDateString() === now.toDateString()
  const isTomorrow = date.toDateString() === tomorrow.toDateString()

  const time = date.toLocaleTimeString('ro-RO', { hour: '2-digit', minute: '2-digit' })

  if (isToday) return `AZI • ${time}`
  if (isTomorrow) return `MAINE • ${time}`

  const dayNames = ['DUM', 'LUN', 'MAR', 'MIE', 'JOI', 'VIN', 'SAM']
  const day = date.getDate()
  const monthNames = ['IAN', 'FEB', 'MAR', 'APR', 'MAI', 'IUN', 'IUL', 'AUG', 'SEP', 'OCT', 'NOI', 'DEC']

  return `${dayNames[date.getDay()]}, ${day} ${monthNames[date.getMonth()]} • ${time}`
}

function isToday(dateStr) {
  return new Date(dateStr).toDateString() === new Date().toDateString()
}

function isTomorrow(dateStr) {
  const tomorrow = new Date()
  tomorrow.setDate(tomorrow.getDate() + 1)
  return new Date(dateStr).toDateString() === tomorrow.toDateString()
}
</script>

<template>
  <div class="page-wrapper">
    <div class="page-bg"></div>
    <AppNav />

    <main class="page-content">

      <div class="mb-8">
        <p class="text-sm font-semibold uppercase tracking-[0.3em] text-green-500 mb-1">Sesiuni live</p>
        <h1 class="page-title">Suport LIVE</h1>
      </div>

      <!-- Filter -->
      <div class="flex gap-2 mb-6">
        <button
          @click="filter = 'upcoming'"
          class="filter-btn"
          :class="filter === 'upcoming' ? 'filter-btn-active' : 'filter-btn-idle'"
        >
          Urmatoare
        </button>
        <button
          @click="filter = 'past'"
          class="filter-btn"
          :class="filter === 'past' ? 'filter-btn-active' : 'filter-btn-idle'"
        >
          Trecute
        </button>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="space-y-4">
        <div v-for="i in 3" :key="i" class="h-28 rounded-2xl bg-white/[0.03] animate-pulse"></div>
      </div>

      <!-- Sessions -->
      <div v-else class="space-y-3">
        <div v-if="filteredSessions.length === 0" class="text-center py-20 text-zinc-500">
          <Video :size="48" class="mx-auto mb-3 opacity-30" />
          <p class="text-lg">{{ filter === 'upcoming' ? 'Nicio sesiune programata' : 'Nicio sesiune trecuta' }}</p>
          <p class="text-sm text-zinc-600">{{ filter === 'upcoming' ? 'Radu va programa sesiuni in curand!' : '' }}</p>
        </div>

        <div v-for="session in filteredSessions" :key="session.id" class="session-card">
          <div class="flex items-start gap-4">
            <!-- Icon -->
            <div class="session-icon" :class="isToday(session.scheduled_at) ? 'session-icon-today' : 'session-icon-default'">
              <Video :size="24" />
            </div>

            <div class="flex-1 min-w-0">
              <!-- Date -->
              <p class="text-xs font-bold uppercase tracking-wider mb-1"
                 :class="isToday(session.scheduled_at) ? 'text-green-400' : isTomorrow(session.scheduled_at) ? 'text-orange-400' : 'text-zinc-500'">
                {{ formatDate(session.scheduled_at) }}
              </p>

              <!-- Title -->
              <h3 class="text-base font-bold text-white leading-tight">{{ session.title }}</h3>

              <!-- Description -->
              <p v-if="session.description" class="text-sm text-zinc-400 mt-1">{{ session.description }}</p>

              <!-- Google Meet badge -->
              <div class="flex items-center gap-1.5 mt-2">
                <div class="w-4 h-4 rounded-full bg-green-500/20 flex items-center justify-center">
                  <div class="w-2 h-2 rounded-full bg-green-400"></div>
                </div>
                <span class="text-xs text-zinc-500">Google Meet</span>
              </div>

              <!-- Actions -->
              <div class="flex items-center gap-3 mt-3">
                <a
                  :href="session.meet_link"
                  target="_blank"
                  rel="noopener"
                  class="join-btn"
                  :class="filter === 'past' ? 'opacity-50' : ''"
                >
                  <ExternalLink :size="14" />
                  Intra in sesiune
                </a>

                <button
                  v-if="filter === 'upcoming'"
                  @click="toggleRsvp(session)"
                  class="rsvp-btn"
                  :class="hasRsvp(session) ? 'rsvp-btn-active' : 'rsvp-btn-idle'"
                >
                  <Check :size="14" />
                  {{ hasRsvp(session) ? 'Going' : 'Particip' }}
                </button>

                <div v-if="rsvpCount(session) > 0" class="flex items-center gap-1 text-xs text-zinc-500 ml-auto">
                  <Users :size="14" />
                  {{ rsvpCount(session) }}
                </div>
              </div>
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
    radial-gradient(ellipse 70% 50% at 50% -5%, rgba(34, 197, 94, 0.06), transparent 60%),
    radial-gradient(ellipse 50% 40% at 80% 50%, rgba(249, 115, 22, 0.04), transparent 50%);
  pointer-events: none;
  z-index: 0;
}

.page-content {
  position: relative;
  z-index: 1;
  max-width: 700px;
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
  font-size: 3rem;
  letter-spacing: 0.05em;
  color: white;
  line-height: 1;
}

.filter-btn {
  padding: 0.5rem 1rem;
  border-radius: 10px;
  font-size: 0.8125rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border: none;
  cursor: pointer;
  transition: all 0.15s;
}

.filter-btn-active {
  background: rgba(34, 197, 94, 0.12);
  color: #4ade80;
  border: 1px solid rgba(34, 197, 94, 0.25);
}

.filter-btn-idle {
  background: rgba(255, 255, 255, 0.03);
  color: #71717a;
  border: 1px solid rgba(255, 255, 255, 0.06);
}

.filter-btn-idle:hover {
  color: #a1a1aa;
  border-color: rgba(255, 255, 255, 0.1);
}

.session-card {
  background: rgba(17, 17, 19, 0.7);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 20px;
  padding: 1.25rem;
}

.session-icon {
  width: 56px;
  height: 56px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.session-icon-today {
  background: rgba(34, 197, 94, 0.12);
  border: 1px solid rgba(34, 197, 94, 0.25);
  color: #4ade80;
}

.session-icon-default {
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.08);
  color: #71717a;
}

.join-btn {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  padding: 0.5rem 0.875rem;
  border-radius: 10px;
  background: rgba(34, 197, 94, 0.12);
  border: 1px solid rgba(34, 197, 94, 0.25);
  color: #4ade80;
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  text-decoration: none;
  transition: all 0.15s;
}

.join-btn:hover {
  background: rgba(34, 197, 94, 0.2);
}

.rsvp-btn {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  padding: 0.5rem 0.875rem;
  border-radius: 10px;
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border: none;
  cursor: pointer;
  transition: all 0.15s;
}

.rsvp-btn-idle {
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.08);
  color: #71717a;
}

.rsvp-btn-idle:hover {
  border-color: rgba(255, 255, 255, 0.15);
  color: #a1a1aa;
}

.rsvp-btn-active {
  background: rgba(239, 68, 68, 0.1);
  border: 1px solid rgba(239, 68, 68, 0.25);
  color: #f87171;
}
</style>
