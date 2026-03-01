<script setup>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth.js'
import { supabase } from '@/supabase.js'
import AppNav from '@/components/layout/AppNav.vue'
import { useRouter } from 'vue-router'
import { Play, ClipboardList, ChevronRight, CheckCircle, Lock } from 'lucide-vue-next'

const auth = useAuthStore()
const router = useRouter()
const modules = ref([])
const lastCheckin = ref(null)
const loading = ref(true)

onMounted(async () => {
  await fetchModules()
  await fetchLastCheckin()
  loading.value = false
})

async function fetchModules() {
  const { data } = await supabase
    .from('client_modules')
    .select('*, module:modules(*)')
    .eq('client_id', auth.user.id)
    .order('module(order_index)')

  modules.value = data || []
}

async function fetchLastCheckin() {
  const { data } = await supabase
    .from('checkins')
    .select('*')
    .eq('client_id', auth.user.id)
    .order('created_at', { ascending: false })
    .limit(1)
    .single()
  lastCheckin.value = data
}

function daysSinceCheckin() {
  if (!lastCheckin.value) return null
  const diff = Date.now() - new Date(lastCheckin.value.created_at).getTime()
  return Math.floor(diff / (1000 * 60 * 60 * 24))
}

const firstName = computed(() => {
  const name = auth.profile?.full_name || ''
  return name.split(' ')[0] || 'Client'
})

import { computed } from 'vue'
</script>

<template>
  <div class="min-h-screen bg-[#0a0a0a]">
    <AppNav />

    <main class="max-w-5xl mx-auto px-4 pt-6 pb-16">

      <!-- Header -->
      <div class="mb-10">
        <p class="text-xs font-semibold uppercase tracking-[0.3em] text-red-500 mb-2">Bun venit înapoi</p>
        <h1 class="text-4xl sm:text-5xl font-['Bebas_Neue'] tracking-wide text-white">{{ firstName }}</h1>
      </div>

      <!-- Check-in banner (if no check-in this week) -->
      <div
        v-if="!lastCheckin || daysSinceCheckin() >= 7"
        class="mb-8 flex items-center justify-between gap-4 p-5 rounded-xl border border-orange-500/30 bg-orange-500/5 cursor-pointer hover:bg-orange-500/10 transition-colors"
        @click="router.push('/checkin')"
      >
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-xl bg-orange-500/15 flex items-center justify-center flex-shrink-0">
            <ClipboardList :size="20" class="text-orange-400" />
          </div>
          <div>
            <p class="text-sm font-semibold text-white">Check-in săptămânal în așteptare</p>
            <p class="text-xs text-gray-500 mt-0.5">Trimite-ți raportul săptămânal lui Radu</p>
          </div>
        </div>
        <ChevronRight :size="18" class="text-orange-400 flex-shrink-0" />
      </div>

      <!-- Check-in done banner -->
      <div
        v-else
        class="mb-8 flex items-center gap-3 p-5 rounded-xl border border-green-500/20 bg-green-500/5"
      >
        <CheckCircle :size="20" class="text-green-400 flex-shrink-0" />
        <p class="text-sm text-gray-300">Check-in trimis acum <strong class="text-white">{{ daysSinceCheckin() === 0 ? 'azi' : `${daysSinceCheckin()} zile` }}</strong> — continuă tot așa! 💪</p>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div v-for="i in 4" :key="i" class="h-32 rounded-xl bg-[#111] animate-pulse"></div>
      </div>

      <!-- Modules -->
      <div v-else>
        <p class="text-xs font-semibold uppercase tracking-[0.3em] text-gray-500 mb-4">Modulele tale</p>

        <div v-if="modules.length === 0" class="text-center py-16 text-gray-500 text-sm">
          Radu nu ți-a atribuit module încă. Verifică mai târziu!
        </div>

        <div v-else class="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <RouterLink
            v-for="cm in modules"
            :key="cm.id"
            :to="`/modul/${cm.module.id}`"
            class="group relative flex items-center gap-4 p-5 rounded-xl bg-[#111] border border-white/5 hover:border-red-500/30 hover:bg-[#161616] transition-all"
          >
            <!-- Gradient bar -->
            <div class="absolute top-0 left-0 right-0 h-0.5 rounded-t-xl opacity-0 group-hover:opacity-100 transition-opacity"
                 style="background: linear-gradient(135deg, #ef4444, #f97316)"></div>

            <div class="w-12 h-12 rounded-xl flex items-center justify-center flex-shrink-0"
                 style="background: rgba(239,68,68,0.1); border: 1px solid rgba(239,68,68,0.2);">
              <Play :size="20" class="text-red-400" />
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-xs font-semibold uppercase tracking-widest text-red-500 mb-0.5">Modul {{ cm.module.order_index }}</p>
              <h3 class="text-base font-semibold text-white truncate">{{ cm.module.title }}</h3>
              <p class="text-xs text-gray-500 mt-0.5 truncate">{{ cm.module.description }}</p>
            </div>
            <ChevronRight :size="16" class="text-gray-600 group-hover:text-red-400 flex-shrink-0 transition-colors" />
          </RouterLink>
        </div>
      </div>
    </main>
  </div>
</template>
