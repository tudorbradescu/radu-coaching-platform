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
  try { await loadClients() } catch (e) { /* ignore */ }
  loading.value = false
})

async function loadClients() {
  const [cl, md] = await Promise.all([
    supabase.rpc('get_clients'),
    supabase.from('modules').select('*').order('order_index')
  ])
  clients.value = cl.data || []
  allModules.value = md.data || []
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
    <div class="admin-content">

      <!-- Header -->
      <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-10">
        <div>
          <h1 class="text-3xl font-semibold text-white tracking-tight">Clienti</h1>
          <p class="text-base text-zinc-500 mt-2">Gestioneaza clientii si atribuie module</p>
        </div>
        <button @click="openModal" class="action-btn">
          <Plus :size="18" /> Client nou
        </button>
      </div>

      <!-- Credentials card -->
      <div v-if="createdClient" class="mb-8 rounded-xl border border-emerald-500/20 bg-emerald-500/[0.04] p-6">
        <div class="flex items-start justify-between mb-5">
          <div>
            <p class="text-xs font-semibold uppercase tracking-wider text-emerald-400 mb-1">Client creat cu succes</p>
            <p class="text-lg font-semibold text-white">{{ createdClient.full_name }}</p>
          </div>
          <button @click="createdClient = null" class="text-zinc-500 hover:text-white p-1.5 rounded-md hover:bg-white/[0.06]">
            <X :size="20" />
          </button>
        </div>
        <div class="space-y-3 mb-5">
          <div class="flex items-center gap-4 bg-[#09090b] border border-zinc-800 rounded-lg px-5 py-4">
            <span class="text-sm text-zinc-500 w-16 shrink-0">Email</span>
            <span class="text-base text-white font-mono flex-1 break-all">{{ createdClient.email }}</span>
          </div>
          <div class="flex items-center gap-4 bg-[#09090b] border border-zinc-800 rounded-lg px-5 py-4">
            <span class="text-sm text-zinc-500 w-16 shrink-0">Parola</span>
            <span class="text-base font-mono flex-1" :class="showPassword ? 'text-white' : 'text-zinc-600 tracking-widest'">
              {{ showPassword ? createdClient.password : '••••••••••' }}
            </span>
            <button @click="showPassword = !showPassword" class="text-zinc-500 hover:text-white p-1.5">
              <Eye v-if="!showPassword" :size="18" />
              <EyeOff v-else :size="18" />
            </button>
          </div>
        </div>
        <button @click="copyCredentials"
          class="w-full flex items-center justify-center gap-2 py-3 rounded-lg text-base font-medium transition-all"
          :class="copied ? 'bg-emerald-500/15 text-emerald-400 border border-emerald-500/20' : 'bg-white/[0.04] text-zinc-300 border border-zinc-800 hover:bg-white/[0.08]'">
          <Copy :size="16" />
          {{ copied ? 'Copiat!' : 'Copiaza credentialele' }}
        </button>
        <p class="text-sm text-zinc-600 text-center mt-3">Trimite aceste credentiale clientului. Nu vor mai fi afisate.</p>
      </div>

      <!-- Client list -->
      <div class="bg-[#111113] border border-zinc-800 rounded-xl overflow-hidden">
        <div v-if="loading" class="divide-y divide-white/[0.04]">
          <div v-for="i in 3" :key="i" class="h-[88px] animate-pulse bg-white/[0.02]"></div>
        </div>

        <div v-else-if="clients.length === 0" class="py-20 text-center">
          <UserPlus :size="40" class="text-zinc-600 mx-auto mb-4" />
          <p class="text-base text-zinc-500">Niciun client in sistem.</p>
          <p class="text-sm text-zinc-600 mt-1">Apasa „Client nou" pentru a adauga.</p>
        </div>

        <div v-else class="divide-y divide-white/[0.04]">
          <div v-for="client in clients" :key="client.id">
            <!-- Client row -->
            <button class="w-full flex items-center gap-5 px-7 py-5 text-left hover:bg-white/[0.02] transition-colors" @click="toggleClient(client)">
              <div class="client-avatar">
                {{ (client.full_name || 'C')[0].toUpperCase() }}
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-base font-medium text-white">{{ client.full_name || 'Client' }}</p>
                <p class="text-sm text-zinc-500 truncate">{{ client.email }}</p>
              </div>
              <div class="flex items-center gap-4 flex-shrink-0">
                <span class="text-sm text-zinc-600 hidden sm:block px-3 py-1.5 rounded-md bg-white/[0.04]">
                  {{ (clientModules[client.id] || []).length }} module
                </span>
                <ChevronDown v-if="expandedClient !== client.id" :size="18" class="text-zinc-600" />
                <ChevronUp v-else :size="18" class="text-zinc-400" />
              </div>
            </button>

            <!-- Expanded modules -->
            <div v-if="expandedClient === client.id" class="px-7 pb-6 bg-white/[0.01]">
              <p class="text-xs font-semibold uppercase tracking-wider text-zinc-500 mb-4 pl-1">Atribuie module</p>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <button
                  v-for="mod in allModules" :key="mod.id"
                  class="flex items-center gap-4 px-5 py-4 rounded-lg border transition-all text-left"
                  :class="(clientModules[client.id] || []).includes(mod.id)
                    ? 'border-red-500/30 bg-red-500/[0.06]'
                    : 'border-zinc-800 bg-white/[0.02] hover:bg-white/[0.04]'"
                  :disabled="saving === `${client.id}-${mod.id}`"
                  @click="toggleModule(client.id, mod.id)">
                  <div class="module-check"
                    :class="(clientModules[client.id] || []).includes(mod.id) ? 'module-check--on' : 'module-check--off'">
                    <Check v-if="(clientModules[client.id] || []).includes(mod.id)" :size="14" class="text-white" />
                  </div>
                  <div class="min-w-0 flex-1">
                    <p class="text-base font-medium text-white">{{ mod.title }}</p>
                    <p class="text-sm text-zinc-500">Modul {{ mod.order_index }}</p>
                  </div>
                </button>
              </div>
              <p v-if="allModules.length === 0" class="text-base text-zinc-500 py-3">Niciun modul creat inca.</p>
            </div>
          </div>
        </div>
      </div>

    </div>

    <!-- Modal -->
    <Transition name="fade">
      <div v-if="showModal" class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
        <div class="modal-card">
          <div class="flex items-center justify-between mb-7">
            <h2 class="text-xl font-semibold text-white">Client nou</h2>
            <button @click="showModal = false" class="text-zinc-500 hover:text-white p-1.5 rounded-md hover:bg-white/[0.06]">
              <X :size="20" />
            </button>
          </div>
          <div class="space-y-5">
            <div>
              <label class="block text-base font-medium text-zinc-400 mb-2">Nume complet</label>
              <input v-model="newName" type="text" placeholder="ex: Andrei Ionescu"
                class="form-input" />
            </div>
            <div>
              <label class="block text-base font-medium text-zinc-400 mb-2">Email</label>
              <input v-model="newEmail" type="email" placeholder="client@email.com"
                class="form-input"
                @keyup.enter="addClient" />
            </div>
            <p class="text-sm text-zinc-500">Parola va fi generata automat si afisata o singura data.</p>
            <div v-if="addError" class="text-base text-red-400 bg-red-500/[0.06] border border-red-500/15 rounded-lg px-5 py-4">
              {{ addError }}
            </div>
            <div class="flex gap-3 pt-2">
              <button @click="showModal = false" class="cancel-btn">
                Anuleaza
              </button>
              <button @click="addClient" :disabled="adding" class="save-btn">
                <UserPlus :size="18" />
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
.action-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.75rem 1.25rem;
  border-radius: 0.5rem;
  font-size: 1rem;
  font-weight: 500;
  color: white;
  background: #ef4444;
  border: none;
  cursor: pointer;
  transition: background 0.15s;
}
.action-btn:hover { background: #dc2626; }

.form-input {
  width: 100%;
  padding: 0.75rem 1rem;
  border-radius: 0.5rem;
  background: #09090b;
  border: 1px solid rgba(255,255,255,0.08);
  font-size: 1rem;
  color: white;
  outline: none;
  transition: border-color 0.15s;
}
.form-input::placeholder { color: #52525b; }
.form-input:focus { border-color: rgba(239,68,68,0.5); }

.cancel-btn {
  flex: 1;
  padding: 0.75rem 1rem;
  border-radius: 0.5rem;
  font-size: 1rem;
  font-weight: 500;
  color: #a1a1aa;
  background: rgba(255,255,255,0.04);
  border: 1px solid #27272a;
  cursor: pointer;
  transition: background 0.15s;
}
.cancel-btn:hover { background: rgba(255,255,255,0.08); }

.save-btn {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  border-radius: 0.5rem;
  font-size: 1rem;
  font-weight: 500;
  color: white;
  background: #ef4444;
  border: none;
  cursor: pointer;
  transition: background 0.15s;
}
.save-btn:hover { background: #dc2626; }
.save-btn:disabled { opacity: 0.5; cursor: default; }

.client-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: linear-gradient(135deg, rgba(239,68,68,0.2), rgba(249,115,22,0.2));
  border: 1px solid rgba(239,68,68,0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  font-size: 0.875rem;
  font-weight: 700;
  color: #f87171;
}

.module-check {
  width: 28px;
  height: 28px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.module-check--on { background: #ef4444; }
.module-check--off { background: rgba(255,255,255,0.06); border: 1px solid rgba(255,255,255,0.08); }

.modal-card {
  width: 100%;
  max-width: 520px;
  background: #111113;
  border: 1px solid rgba(255,255,255,0.08);
  border-radius: 1rem;
  padding: 2rem;
  box-shadow: 0 25px 50px -12px rgba(0,0,0,0.6);
}

.fade-enter-active, .fade-leave-active { transition: opacity 0.2s; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>
