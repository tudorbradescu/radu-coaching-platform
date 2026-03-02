<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/supabase.js'
import AppNav from '@/components/layout/AppNav.vue'
import { ArrowLeft, Plus, X, ChevronDown, ChevronUp, Check, Copy, UserPlus, Eye, EyeOff } from 'lucide-vue-next'
import { useRouter } from 'vue-router'

const router = useRouter()
const clients = ref([])
const allModules = ref([])
const expandedClient = ref(null)
const clientModules = ref({})
const loading = ref(true)
const saving = ref(null)

const showModal = ref(false)
const newName = ref('')
const newEmail = ref('')
const adding = ref(false)
const addError = ref('')

const createdClient = ref(null)
const showPassword = ref(false)
const copied = ref(false)

onMounted(async () => {
  await loadClients()
})

async function loadClients() {
  const [cl, md] = await Promise.all([
    supabase.rpc('get_clients'),
    supabase.from('modules').select('*').order('order_index')
  ])
  clients.value = cl.data || []
  allModules.value = md.data || []
  loading.value = false
}

async function toggleClient(client) {
  if (expandedClient.value === client.id) { expandedClient.value = null; return }
  expandedClient.value = client.id
  if (!clientModules.value[client.id]) {
    const { data } = await supabase.from('client_modules').select('module_id').eq('client_id', client.id)
    clientModules.value[client.id] = (data || []).map(r => r.module_id)
  }
}

async function toggleModule(clientId, moduleId) {
  saving.value = `${clientId}-${moduleId}`
  const current = clientModules.value[clientId] || []
  const has = current.includes(moduleId)
  if (has) {
    await supabase.from('client_modules').delete().eq('client_id', clientId).eq('module_id', moduleId)
    clientModules.value[clientId] = current.filter(id => id !== moduleId)
  } else {
    await supabase.from('client_modules').insert({ client_id: clientId, module_id: moduleId })
    clientModules.value[clientId] = [...current, moduleId]
  }
  saving.value = null
}

function openModal() {
  newName.value = ''
  newEmail.value = ''
  addError.value = ''
  showModal.value = true
}

async function addClient() {
  if (!newName.value.trim() || !newEmail.value.trim()) { addError.value = 'Completează numele și emailul.'; return }
  adding.value = true
  addError.value = ''
  try {
    const { data: { session } } = await supabase.auth.getSession()
    const token = session?.access_token
    if (!token) throw new Error('Sesiune invalidă')
    const res = await fetch('https://erfcmpccobjwtjutwmba.supabase.co/functions/v1/create-client', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
      body: JSON.stringify({ full_name: newName.value.trim(), email: newEmail.value.trim() })
    })
    const result = await res.json()
    if (!res.ok || result.error) throw new Error(result.error || 'Eroare necunoscută')
    createdClient.value = { ...result.user, password: result.password }
    showModal.value = false
    showPassword.value = false
    copied.value = false
    await loadClients()
  } catch (e) {
    addError.value = e.message
  } finally {
    adding.value = false
  }
}

function copyCredentials() {
  navigator.clipboard.writeText(`Email: ${createdClient.value.email}\nParolă: ${createdClient.value.password}`)
  copied.value = true
  setTimeout(() => copied.value = false, 2000)
}
</script>

<template>
  <div class="min-h-screen bg-[#0a0a0a]">
    <AppNav />

    <main class="max-w-4xl mx-auto px-5 pt-4 pb-8">

      <button @click="router.push('/admin')" class="flex items-center gap-2 text-sm text-gray-500 hover:text-white transition-colors mb-6">
        <ArrowLeft :size="16" /> Înapoi la Admin
      </button>

      <!-- Header + button: stacked on mobile, side-by-side on desktop -->
      <div class="mb-8">
        <p class="text-xs font-bold uppercase tracking-[0.3em] text-red-500 mb-1">Gestionare</p>
        <h1 class="text-5xl font-['Bebas_Neue'] tracking-wide text-white mb-5">Clienți</h1>
        <button
          @click="openModal"
          class="flex items-center justify-center gap-2 w-full sm:w-auto sm:px-6 py-4 rounded-2xl text-base font-bold text-white transition-all active:scale-[0.98]"
          style="background: linear-gradient(135deg, #ef4444, #f97316)"
        >
          <UserPlus :size="20" /> + Client nou
        </button>
      </div>

      <!-- Credentials card -->
      <div v-if="createdClient" class="mb-6 rounded-2xl border border-green-500/30 bg-green-500/5 p-5">
        <div class="flex items-start justify-between mb-4">
          <div>
            <p class="text-sm font-bold uppercase tracking-wider text-green-400 mb-1">✅ Client creat!</p>
            <p class="text-lg font-bold text-white">{{ createdClient.full_name }}</p>
          </div>
          <button @click="createdClient = null" class="text-gray-500 hover:text-white p-1">
            <X :size="20" />
          </button>
        </div>
        <div class="space-y-2 mb-4">
          <div class="flex items-center gap-3 bg-[#0a0a0a] border border-white/8 rounded-xl px-4 py-3.5">
            <span class="text-xs text-gray-500 w-14 shrink-0">Email</span>
            <span class="text-sm text-white font-mono flex-1 break-all">{{ createdClient.email }}</span>
          </div>
          <div class="flex items-center gap-3 bg-[#0a0a0a] border border-white/8 rounded-xl px-4 py-3.5">
            <span class="text-xs text-gray-500 w-14 shrink-0">Parolă</span>
            <span class="text-sm font-mono flex-1" :class="showPassword ? 'text-white' : 'text-gray-600 tracking-widest'">
              {{ showPassword ? createdClient.password : '••••••••••' }}
            </span>
            <button @click="showPassword = !showPassword" class="text-gray-500 hover:text-white p-1">
              <Eye v-if="!showPassword" :size="18" />
              <EyeOff v-else :size="18" />
            </button>
          </div>
        </div>
        <button
          @click="copyCredentials"
          class="w-full flex items-center justify-center gap-2 py-3.5 rounded-xl text-sm font-bold transition-all"
          :class="copied ? 'bg-green-500/20 text-green-400 border border-green-500/30' : 'bg-white/5 text-gray-300 border border-white/10 hover:bg-white/10'"
        >
          <Copy :size="16" />
          {{ copied ? 'Copiat!' : 'Copiază credențialele' }}
        </button>
        <p class="text-xs text-gray-600 text-center mt-2">Trimite aceste credențiale clientului. Nu vor mai fi afișate!</p>
      </div>

      <!-- Client list -->
      <div v-if="loading" class="space-y-3">
        <div v-for="i in 3" :key="i" class="h-20 bg-[#111] rounded-2xl animate-pulse"></div>
      </div>

      <div v-else class="space-y-3">
        <div v-if="clients.length === 0" class="text-center py-16 text-gray-500">
          <p class="text-base mb-1">Niciun client în sistem.</p>
          <p class="text-sm">Apasă „+ Client nou" pentru a adăuga.</p>
        </div>

        <div v-for="client in clients" :key="client.id"
             class="rounded-2xl border overflow-hidden transition-colors"
             :class="expandedClient === client.id ? 'border-red-500/30 bg-[#111]' : 'border-white/5 bg-[#0d0d0d]'">

          <button class="w-full flex items-center gap-4 p-5 text-left" @click="toggleClient(client)">
            <div class="w-12 h-12 rounded-2xl flex items-center justify-center flex-shrink-0 font-['Bebas_Neue'] text-xl"
                 style="background: rgba(239,68,68,0.12); border: 1px solid rgba(239,68,68,0.25); color: #ef4444;">
              {{ (client.full_name || 'C')[0].toUpperCase() }}
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-base font-bold text-white">{{ client.full_name || 'Client' }}</p>
              <p class="text-sm text-gray-500 truncate">{{ client.email }}</p>
            </div>
            <div class="flex items-center gap-2 flex-shrink-0">
              <span class="text-xs text-gray-600 hidden sm:block">{{ (clientModules[client.id] || []).length }} module</span>
              <ChevronDown v-if="expandedClient !== client.id" :size="20" class="text-gray-600" />
              <ChevronUp v-else :size="20" class="text-red-400" />
            </div>
          </button>

          <div v-if="expandedClient === client.id" class="px-5 pb-5">
            <p class="text-xs font-bold uppercase tracking-widest text-gray-500 mb-3">Atribuie module</p>
            <div class="space-y-2">
              <button
                v-for="mod in allModules" :key="mod.id"
                class="w-full flex items-center gap-4 p-4 rounded-xl border transition-all text-left active:scale-[0.98]"
                :class="(clientModules[client.id] || []).includes(mod.id)
                  ? 'border-red-500/40 bg-red-500/10'
                  : 'border-white/8 bg-[#1a1a1a]'"
                :disabled="saving === `${client.id}-${mod.id}`"
                @click="toggleModule(client.id, mod.id)"
              >
                <div class="w-8 h-8 rounded-xl flex items-center justify-center flex-shrink-0"
                     :class="(clientModules[client.id] || []).includes(mod.id) ? 'bg-red-500' : 'bg-[#222] border border-white/10'">
                  <Check v-if="(clientModules[client.id] || []).includes(mod.id)" :size="14" class="text-white" />
                </div>
                <div class="min-w-0 flex-1">
                  <p class="text-sm font-bold text-white">{{ mod.title }}</p>
                  <p class="text-xs text-gray-500">Modul {{ mod.order_index }}</p>
                </div>
              </button>
            </div>
            <div v-if="allModules.length === 0" class="text-sm text-gray-500 py-2">Niciun modul creat încă.</div>
          </div>
        </div>
      </div>
    </main>

    <!-- Modal -->
    <Transition name="fade">
      <div v-if="showModal" class="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/70 backdrop-blur-sm">
        <div class="w-full sm:max-w-sm bg-[#111] border border-white/10 rounded-t-3xl sm:rounded-3xl p-6 pb-8">
          <div class="flex items-center justify-between mb-6">
            <h2 class="text-2xl font-['Bebas_Neue'] tracking-wide text-white">Client Nou</h2>
            <button @click="showModal = false" class="text-gray-500 hover:text-white p-1">
              <X :size="22" />
            </button>
          </div>
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-semibold text-gray-300 mb-2">Nume complet</label>
              <input v-model="newName" type="text" placeholder="ex: Andrei Ionescu"
                class="w-full px-4 py-4 rounded-xl bg-[#1a1a1a] border border-white/8 text-white placeholder-gray-600 text-base outline-none focus:border-red-500/50 transition-all"
                @keyup.enter="addClient" />
            </div>
            <div>
              <label class="block text-sm font-semibold text-gray-300 mb-2">Email</label>
              <input v-model="newEmail" type="email" placeholder="client@email.com"
                class="w-full px-4 py-4 rounded-xl bg-[#1a1a1a] border border-white/8 text-white placeholder-gray-600 text-base outline-none focus:border-red-500/50 transition-all"
                @keyup.enter="addClient" />
            </div>
            <p class="text-sm text-gray-500">Parola va fi generată automat și afișată o singură dată.</p>
            <div v-if="addError" class="text-sm text-red-400 bg-red-500/10 border border-red-500/20 rounded-xl px-4 py-3">
              ⚠ {{ addError }}
            </div>
            <button @click="addClient" :disabled="adding"
              class="w-full flex items-center justify-center gap-2 py-4 rounded-xl font-bold text-white text-base transition-all disabled:opacity-50 active:scale-[0.98]"
              style="background: linear-gradient(135deg, #ef4444, #f97316)">
              <UserPlus :size="20" />
              {{ adding ? 'Se creează...' : 'Creează cont' }}
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.fade-enter-active, .fade-leave-active { transition: opacity 0.2s; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>
