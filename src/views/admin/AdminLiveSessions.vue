<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/supabase.js'
import AdminLayout from '@/components/layout/AdminLayout.vue'
import { Plus, Trash2, Video, ExternalLink, Users } from 'lucide-vue-next'

const sessions = ref([])
const loading = ref(true)
const showForm = ref(false)
const saving = ref(false)
const saveError = ref('')

const form = ref({
  title: '',
  description: '',
  meet_link: '',
  scheduled_at: ''
})

onMounted(async () => {
  await fetchSessions()
  loading.value = false
})

async function fetchSessions() {
  const { data } = await supabase
    .from('live_sessions')
    .select(`*, rsvps:live_session_rsvps(id, user_id, profile:profiles(full_name))`)
    .order('scheduled_at', { ascending: false })
  sessions.value = data || []
}

async function createSession() {
  if (!form.value.title || !form.value.meet_link || !form.value.scheduled_at) return
  saving.value = true
  saveError.value = ''

  const { error } = await supabase.from('live_sessions').insert({
    title: form.value.title,
    description: form.value.description || null,
    meet_link: form.value.meet_link,
    scheduled_at: new Date(form.value.scheduled_at).toISOString()
  })

  if (!error) {
    form.value = { title: '', description: '', meet_link: '', scheduled_at: '' }
    showForm.value = false
    await fetchSessions()
  } else {
    saveError.value = error.message
    console.error('Save error:', error)
  }
  saving.value = false
}

async function deleteSession(id) {
  await supabase.from('live_sessions').delete().eq('id', id)
  await fetchSessions()
}

function formatDate(dateStr) {
  return new Date(dateStr).toLocaleDateString('ro-RO', {
    weekday: 'short',
    day: 'numeric',
    month: 'short',
    hour: '2-digit',
    minute: '2-digit'
  })
}

function isPast(dateStr) {
  return new Date(dateStr) < new Date()
}
</script>

<template>
  <AdminLayout>
    <div class="admin-content">
      <div class="flex items-center justify-between mb-8">
        <div>
          <p class="text-xs font-bold uppercase tracking-[0.3em] text-green-500">Administrare</p>
          <h1 class="text-3xl font-['Bebas_Neue'] tracking-wider text-white mt-1">Suport LIVE</h1>
        </div>
        <button @click="showForm = !showForm" class="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-green-500/15 text-green-400 font-semibold text-sm hover:bg-green-500/25 transition-all border border-green-500/25">
          <Plus :size="18" />
          Sesiune noua
        </button>
      </div>

      <!-- Create form -->
      <div v-if="showForm" class="bg-white/[0.03] border border-white/5 rounded-2xl p-6 mb-6">
        <h3 class="text-lg font-bold text-white mb-4">Sesiune noua</h3>
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div class="sm:col-span-2">
            <label class="block text-xs font-bold uppercase tracking-wider text-zinc-500 mb-1.5">Titlu</label>
            <input v-model="form.title" placeholder="Ex: Training business 5k - Content" class="admin-input" />
          </div>
          <div class="sm:col-span-2">
            <label class="block text-xs font-bold uppercase tracking-wider text-zinc-500 mb-1.5">Descriere (optional)</label>
            <input v-model="form.description" placeholder="Descriere scurta..." class="admin-input" />
          </div>
          <div>
            <label class="block text-xs font-bold uppercase tracking-wider text-zinc-500 mb-1.5">Link Google Meet</label>
            <input v-model="form.meet_link" placeholder="https://meet.google.com/..." class="admin-input" />
          </div>
          <div>
            <label class="block text-xs font-bold uppercase tracking-wider text-zinc-500 mb-1.5">Data si ora</label>
            <input v-model="form.scheduled_at" type="datetime-local" class="admin-input" />
          </div>
        </div>
        <div class="flex items-center gap-3 mt-5 flex-wrap">
          <button @click="createSession" :disabled="saving" class="px-5 py-2.5 rounded-xl bg-green-500 text-white font-bold text-sm hover:bg-green-600 transition-all disabled:opacity-40">
            {{ saving ? 'Se salveaza...' : 'Creeaza sesiune' }}
          </button>
          <button @click="showForm = false" class="px-5 py-2.5 rounded-xl bg-white/5 text-zinc-400 font-semibold text-sm hover:bg-white/10 transition-all">
            Anuleaza
          </button>
          <p v-if="saveError" class="text-sm text-red-400">{{ saveError }}</p>
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="space-y-3">
        <div v-for="i in 3" :key="i" class="h-20 rounded-xl bg-white/[0.03] animate-pulse"></div>
      </div>

      <!-- Sessions list -->
      <div v-else class="space-y-3">
        <div v-if="sessions.length === 0" class="text-center py-16 text-zinc-500">
          <Video :size="48" class="mx-auto mb-3 opacity-30" />
          <p>Nicio sesiune creata</p>
        </div>

        <div v-for="session in sessions" :key="session.id"
             class="flex items-center gap-4 p-4 rounded-xl bg-white/[0.03] border border-white/5"
             :class="isPast(session.scheduled_at) ? 'opacity-50' : ''">
          <div class="w-12 h-12 rounded-xl flex items-center justify-center flex-shrink-0"
               :class="isPast(session.scheduled_at) ? 'bg-zinc-800 text-zinc-600' : 'bg-green-500/12 text-green-400 border border-green-500/20'">
            <Video :size="20" />
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-xs font-bold uppercase tracking-wider" :class="isPast(session.scheduled_at) ? 'text-zinc-600' : 'text-green-400'">
              {{ formatDate(session.scheduled_at) }}
            </p>
            <p class="text-sm font-bold text-white truncate">{{ session.title }}</p>
            <div class="flex items-center gap-3 mt-1">
              <a :href="session.meet_link" target="_blank" class="text-xs text-zinc-500 hover:text-green-400 flex items-center gap-1">
                <ExternalLink :size="12" /> Link
              </a>
              <span v-if="session.rsvps?.length" class="text-xs text-zinc-500 flex items-center gap-1">
                <Users :size="12" /> {{ session.rsvps.length }} participanti
              </span>
            </div>
          </div>
          <button @click="deleteSession(session.id)" class="p-2 rounded-lg text-zinc-600 hover:text-red-400 hover:bg-red-500/10 transition-all">
            <Trash2 :size="16" />
          </button>
        </div>
      </div>
    </div>
  </AdminLayout>
</template>

<style scoped>
.admin-input {
  width: 100%;
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 10px;
  padding: 0.625rem 0.875rem;
  color: white;
  font-size: 0.875rem;
  outline: none;
  font-family: 'Inter', sans-serif;
}

.admin-input:focus {
  border-color: rgba(34, 197, 94, 0.4);
}

.admin-input::placeholder {
  color: #3f3f46;
}
</style>
