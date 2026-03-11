<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/supabase.js'
import AdminLayout from '@/components/layout/AdminLayout.vue'
import { Plus, X, ChevronDown, ChevronUp, Check, Copy, UserPlus, Eye, EyeOff } from 'lucide-vue-next'

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
  if (!newName.value.trim() || !newEmail.value.trim()) { addError.value = 'Completeaza numele si emailul.'; return }
  adding.value = true
  addError.value = ''
  try {
    const { data: { session } } = await supabase.auth.getSession()
    const token = session?.access_token
    if (!token) throw new Error('Sesiune invalida')
    const res = await fetch('https://erfcmpccobjwtjutwmba.supabase.co/functions/v1/create-client', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
      body: JSON.stringify({ full_name: newName.value.trim(), email: newEmail.value.trim() })
    })
    const result = await res.json()
    if (!res.ok || result.error) throw new Error(result.error || 'Eroare necunoscuta')
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
  navigator.clipboard.writeText(`Email: ${createdClient.value.email}\nParola: ${createdClient.value.password}`)
  copied.value = true
  setTimeout(() => copied.value = false, 2000)
}
</script>

<template>
  <AdminLayout>
    <div class="px-6 lg:px-10 py-8 max-w-[1100px]">

      <!-- Header -->
      <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-8">
        <div>
          <h1 class="text-2xl font-semibold text-white tracking-tight">Clienti</h1>
          <p class="text-sm text-zinc-500 mt-1">Gestioneaza clientii si atribuie module</p>
        </div>
        <button @click="openModal"
          class="flex items-center justify-center gap-2 px-4 py-2.5 rounded-lg text-sm font-medium text-white bg-red-500 hover:bg-red-600 transition-colors">
          <Plus :size="16" /> Client nou
        </button>
      </div>

      <!-- Credentials card -->
      <div v-if="createdClient" class="mb-6 rounded-xl border border-emerald-500/20 bg-emerald-500/[0.04] p-5">
        <div class="flex items-start justify-between mb-4">
          <div>
            <p class="text-xs font-semibold uppercase tracking-wider text-emerald-400 mb-1">Client creat cu succes</p>
            <p class="text-base font-semibold text-white">{{ createdClient.full_name }}</p>
          </div>
          <button @click="createdClient = null" class="text-zinc-500 hover:text-white p-1 rounded-md hover:bg-white/[0.06]">
            <X :size="18" />
          </button>
        </div>
        <div class="space-y-2 mb-4">
          <div class="flex items-center gap-3 bg-[#09090b] border border-white/[0.06] rounded-lg px-4 py-3">
            <span class="text-xs text-zinc-500 w-14 shrink-0">Email</span>
            <span class="text-sm text-white font-mono flex-1 break-all">{{ createdClient.email }}</span>
          </div>
          <div class="flex items-center gap-3 bg-[#09090b] border border-white/[0.06] rounded-lg px-4 py-3">
            <span class="text-xs text-zinc-500 w-14 shrink-0">Parola</span>
            <span class="text-sm font-mono flex-1" :class="showPassword ? 'text-white' : 'text-zinc-600 tracking-widest'">
              {{ showPassword ? createdClient.password : '••••••••••' }}
            </span>
            <button @click="showPassword = !showPassword" class="text-zinc-500 hover:text-white p-1">
              <Eye v-if="!showPassword" :size="16" />
              <EyeOff v-else :size="16" />
            </button>
          </div>
        </div>
        <button @click="copyCredentials"
          class="w-full flex items-center justify-center gap-2 py-2.5 rounded-lg text-sm font-medium transition-all"
          :class="copied ? 'bg-emerald-500/15 text-emerald-400 border border-emerald-500/20' : 'bg-white/[0.04] text-zinc-300 border border-white/[0.06] hover:bg-white/[0.08]'">
          <Copy :size="14" />
          {{ copied ? 'Copiat!' : 'Copiaza credentialele' }}
        </button>
        <p class="text-xs text-zinc-600 text-center mt-2">Trimite aceste credentiale clientului. Nu vor mai fi afisate.</p>
      </div>

      <!-- Client list -->
      <div class="bg-[#111113] border border-white/[0.06] rounded-xl overflow-hidden">
        <div v-if="loading" class="divide-y divide-white/[0.04]">
          <div v-for="i in 3" :key="i" class="h-[72px] animate-pulse bg-white/[0.02]"></div>
        </div>

        <div v-else-if="clients.length === 0" class="py-16 text-center">
          <UserPlus :size="32" class="text-zinc-600 mx-auto mb-3" />
          <p class="text-sm text-zinc-500">Niciun client in sistem.</p>
          <p class="text-xs text-zinc-600 mt-1">Apasa „Client nou" pentru a adauga.</p>
        </div>

        <div v-else class="divide-y divide-white/[0.04]">
          <div v-for="client in clients" :key="client.id">
            <!-- Client row -->
            <button class="w-full flex items-center gap-4 px-5 py-4 text-left hover:bg-white/[0.02] transition-colors" @click="toggleClient(client)">
              <div class="w-9 h-9 rounded-full bg-gradient-to-br from-red-500/20 to-orange-500/20 border border-red-500/20 flex items-center justify-center flex-shrink-0 text-xs font-bold text-red-400">
                {{ (client.full_name || 'C')[0].toUpperCase() }}
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-sm font-medium text-white">{{ client.full_name || 'Client' }}</p>
                <p class="text-xs text-zinc-500 truncate">{{ client.email }}</p>
              </div>
              <div class="flex items-center gap-3 flex-shrink-0">
                <span class="text-xs text-zinc-600 hidden sm:block px-2 py-1 rounded-md bg-white/[0.04]">
                  {{ (clientModules[client.id] || []).length }} module
                </span>
                <ChevronDown v-if="expandedClient !== client.id" :size="16" class="text-zinc-600" />
                <ChevronUp v-else :size="16" class="text-zinc-400" />
              </div>
            </button>

            <!-- Expanded modules -->
            <div v-if="expandedClient === client.id" class="px-5 pb-5 bg-white/[0.01]">
              <p class="text-xs font-medium uppercase tracking-wider text-zinc-500 mb-3 pl-1">Atribuie module</p>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-2">
                <button
                  v-for="mod in allModules" :key="mod.id"
                  class="flex items-center gap-3 px-4 py-3 rounded-lg border transition-all text-left"
                  :class="(clientModules[client.id] || []).includes(mod.id)
                    ? 'border-red-500/30 bg-red-500/[0.06]'
                    : 'border-white/[0.06] bg-white/[0.02] hover:bg-white/[0.04]'"
                  :disabled="saving === `${client.id}-${mod.id}`"
                  @click="toggleModule(client.id, mod.id)">
                  <div class="w-6 h-6 rounded-md flex items-center justify-center flex-shrink-0"
                    :class="(clientModules[client.id] || []).includes(mod.id) ? 'bg-red-500' : 'bg-white/[0.06] border border-white/[0.08]'">
                    <Check v-if="(clientModules[client.id] || []).includes(mod.id)" :size="12" class="text-white" />
                  </div>
                  <div class="min-w-0 flex-1">
                    <p class="text-sm font-medium text-white">{{ mod.title }}</p>
                    <p class="text-xs text-zinc-500">Modul {{ mod.order_index }}</p>
                  </div>
                </button>
              </div>
              <p v-if="allModules.length === 0" class="text-sm text-zinc-500 py-2">Niciun modul creat inca.</p>
            </div>
          </div>
        </div>
      </div>

    </div>

    <!-- Modal -->
    <Transition name="fade">
      <div v-if="showModal" class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
        <div class="w-full max-w-md bg-[#111113] border border-white/[0.08] rounded-2xl p-6 shadow-2xl">
          <div class="flex items-center justify-between mb-6">
            <h2 class="text-lg font-semibold text-white">Client nou</h2>
            <button @click="showModal = false" class="text-zinc-500 hover:text-white p-1 rounded-md hover:bg-white/[0.06]">
              <X :size="18" />
            </button>
          </div>
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-zinc-400 mb-1.5">Nume complet</label>
              <input v-model="newName" type="text" placeholder="ex: Andrei Ionescu"
                class="w-full px-3.5 py-2.5 rounded-lg bg-[#09090b] border border-white/[0.08] text-sm text-white placeholder-zinc-600 outline-none focus:border-red-500/50 transition-all" />
            </div>
            <div>
              <label class="block text-sm font-medium text-zinc-400 mb-1.5">Email</label>
              <input v-model="newEmail" type="email" placeholder="client@email.com"
                class="w-full px-3.5 py-2.5 rounded-lg bg-[#09090b] border border-white/[0.08] text-sm text-white placeholder-zinc-600 outline-none focus:border-red-500/50 transition-all"
                @keyup.enter="addClient" />
            </div>
            <p class="text-xs text-zinc-500">Parola va fi generata automat si afisata o singura data.</p>
            <div v-if="addError" class="text-sm text-red-400 bg-red-500/[0.06] border border-red-500/15 rounded-lg px-4 py-3">
              {{ addError }}
            </div>
            <div class="flex gap-3 pt-2">
              <button @click="showModal = false"
                class="flex-1 py-2.5 rounded-lg text-sm font-medium text-zinc-400 bg-white/[0.04] hover:bg-white/[0.08] border border-white/[0.06] transition-colors">
                Anuleaza
              </button>
              <button @click="addClient" :disabled="adding"
                class="flex-1 flex items-center justify-center gap-2 py-2.5 rounded-lg text-sm font-medium text-white bg-red-500 hover:bg-red-600 disabled:opacity-50 transition-colors">
                <UserPlus :size="16" />
                {{ adding ? 'Se creaza...' : 'Creaza cont' }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </AdminLayout>
</template>

<style scoped>
.fade-enter-active, .fade-leave-active { transition: opacity 0.2s; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>
