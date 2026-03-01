<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/supabase.js'
import AppNav from '@/components/layout/AppNav.vue'
import { ArrowLeft, Plus, X, ChevronDown, ChevronUp, Check } from 'lucide-vue-next'
import { useRouter } from 'vue-router'

const router = useRouter()
const clients = ref([])
const allModules = ref([])
const expandedClient = ref(null)
const clientModules = ref({})
const loading = ref(true)
const saving = ref(null)

onMounted(async () => {
  const [cl, md] = await Promise.all([
    supabase.from('profiles').select('*').eq('role', 'client').order('full_name'),
    supabase.from('modules').select('*').order('order_index')
  ])
  clients.value = cl.data || []
  allModules.value = md.data || []
  loading.value = false
})

async function toggleClient(client) {
  if (expandedClient.value === client.id) {
    expandedClient.value = null
    return
  }
  expandedClient.value = client.id
  if (!clientModules.value[client.id]) {
    const { data } = await supabase
      .from('client_modules')
      .select('module_id')
      .eq('client_id', client.id)
    clientModules.value[client.id] = (data || []).map(r => r.module_id)
  }
}

async function toggleModule(clientId, moduleId) {
  saving.value = `${clientId}-${moduleId}`
  const current = clientModules.value[clientId] || []
  const has = current.includes(moduleId)

  if (has) {
    await supabase.from('client_modules')
      .delete()
      .eq('client_id', clientId)
      .eq('module_id', moduleId)
    clientModules.value[clientId] = current.filter(id => id !== moduleId)
  } else {
    await supabase.from('client_modules')
      .insert({ client_id: clientId, module_id: moduleId })
    clientModules.value[clientId] = [...current, moduleId]
  }
  saving.value = null
}
</script>

<template>
  <div class="min-h-screen bg-[#0a0a0a]">
    <AppNav />

    <main class="max-w-4xl mx-auto px-4 pt-24 pb-16">

      <button @click="router.push('/admin')" class="flex items-center gap-2 text-sm text-gray-500 hover:text-white transition-colors mb-8 group">
        <ArrowLeft :size="16" class="group-hover:-translate-x-1 transition-transform" /> Înapoi la Admin
      </button>

      <div class="mb-8">
        <p class="text-xs font-semibold uppercase tracking-[0.3em] text-red-500 mb-2">Gestionare</p>
        <h1 class="text-4xl font-['Bebas_Neue'] tracking-wide text-white">Clienți</h1>
      </div>

      <div v-if="loading" class="space-y-2">
        <div v-for="i in 3" :key="i" class="h-16 bg-[#111] rounded-xl animate-pulse"></div>
      </div>

      <div v-else class="space-y-2">
        <div v-for="client in clients" :key="client.id"
             class="rounded-xl border overflow-hidden transition-colors"
             :class="expandedClient === client.id ? 'border-red-500/30 bg-[#111]' : 'border-white/5 bg-[#0d0d0d]'">

          <!-- Client row -->
          <button class="w-full flex items-center gap-4 p-4 text-left" @click="toggleClient(client)">
            <div class="w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0 font-['Bebas_Neue'] text-lg"
                 style="background: rgba(239,68,68,0.1); border: 1px solid rgba(239,68,68,0.2); color: #ef4444;">
              {{ (client.full_name || 'C')[0].toUpperCase() }}
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-sm font-semibold text-white">{{ client.full_name || 'Client' }}</p>
              <p class="text-xs text-gray-500">{{ client.email }}</p>
            </div>
            <span class="text-xs text-gray-600 mr-2">
              {{ (clientModules[client.id] || []).length }} module
            </span>
            <ChevronDown v-if="expandedClient !== client.id" :size="16" class="text-gray-600" />
            <ChevronUp v-else :size="16" class="text-red-400" />
          </button>

          <!-- Modules assignment -->
          <div v-if="expandedClient === client.id" class="px-4 pb-4">
            <p class="text-xs font-semibold uppercase tracking-widest text-gray-500 mb-3">Atribuie module</p>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-2">
              <button
                v-for="mod in allModules"
                :key="mod.id"
                class="flex items-center gap-3 p-3 rounded-xl border transition-all text-left"
                :class="(clientModules[client.id] || []).includes(mod.id)
                  ? 'border-red-500/40 bg-red-500/10'
                  : 'border-white/8 bg-[#1a1a1a] hover:border-white/20'"
                :disabled="saving === `${client.id}-${mod.id}`"
                @click="toggleModule(client.id, mod.id)"
              >
                <div class="w-6 h-6 rounded-lg flex items-center justify-center flex-shrink-0"
                     :class="(clientModules[client.id] || []).includes(mod.id) ? 'bg-red-500' : 'bg-[#222] border border-white/10'">
                  <Check v-if="(clientModules[client.id] || []).includes(mod.id)" :size="12" class="text-white" />
                </div>
                <div class="min-w-0">
                  <p class="text-xs font-semibold text-white truncate">{{ mod.title }}</p>
                  <p class="text-xs text-gray-500">Modul {{ mod.order_index }}</p>
                </div>
              </button>
            </div>
          </div>
        </div>

        <div v-if="clients.length === 0" class="text-center py-12 text-gray-500 text-sm">
          Niciun client în sistem. Adaugă-i din Supabase Auth.
        </div>
      </div>
    </main>
  </div>
</template>
