<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth.js'
import { supabase } from '@/supabase.js'
import AppNav from '@/components/layout/AppNav.vue'
import { useRouter } from 'vue-router'
import { Play, ClipboardList, ChevronRight, CheckCircle } from 'lucide-vue-next'

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

const needsCheckin = computed(() => !lastCheckin.value || daysSinceCheckin() >= 7)
</script>

<template>
  <div class="min-h-screen bg-[#0a0a0a]">
    <AppNav />

    <main class="max-w-2xl mx-auto px-5 pt-4 pb-8">

      <!-- Header -->
      <div class="mb-8">
        <p class="text-sm font-semibold uppercase tracking-[0.3em] text-red-500 mb-1">Bun venit înapoi</p>
        <h1 class="text-5xl sm:text-6xl font-['Bebas_Neue'] tracking-wide text-white leading-none">{{ firstName }}</h1>
      </div>

      <!-- Check-in banner -->
      <div
        v-if="needsCheckin"
        class="mb-6 rounded-2xl border border-orange-500/30 bg-gradient-to-r from-orange-500/10 to-transparent overflow-hidden cursor-pointer active:scale-[0.98] transition-transform"
        @click="router.push('/checkin')"
      >
        <div class="flex items-center gap-4 p-5">
          <div class="w-12 h-12 rounded-2xl bg-orange-500/20 border border-orange-500/30 flex items-center justify-center flex-shrink-0">
            <ClipboardList :size="24" class="text-orange-400" />
          </div>
          <div class="flex-1">
            <p class="text-base font-bold text-white">Check-in săptămânal</p>
            <p class="text-sm text-gray-400 mt-0.5">Trimite-ți raportul săptămânal lui Radu</p>
          </div>
          <div class="w-9 h-9 rounded-xl bg-orange-500/20 flex items-center justify-center flex-shrink-0">
            <ChevronRight :size="20" class="text-orange-400" />
          </div>
        </div>
      </div>

      <!-- Check-in done -->
      <div
        v-else
        class="mb-6 flex items-center gap-4 p-5 rounded-2xl border border-green-500/20 bg-green-500/5"
      >
        <div class="w-12 h-12 rounded-2xl bg-green-500/15 border border-green-500/20 flex items-center justify-center flex-shrink-0">
          <CheckCircle :size="24" class="text-green-400" />
        </div>
        <div>
          <p class="text-base font-bold text-white">Check-in trimis ✓</p>
          <p class="text-sm text-gray-400 mt-0.5">
            {{ daysSinceCheckin() === 0 ? 'Azi' : `Acum ${daysSinceCheckin()} zile` }} — continuă tot așa! 💪
          </p>
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="space-y-3">
        <div v-for="i in 3" :key="i" class="h-24 rounded-2xl bg-[#111] animate-pulse"></div>
      </div>

      <!-- Modules -->
      <div v-else>
        <p class="text-xs font-bold uppercase tracking-[0.3em] text-gray-500 mb-4">Modulele tale</p>

        <div v-if="modules.length === 0" class="text-center py-16 text-gray-500">
          <p class="text-base mb-1">Niciun modul atribuit</p>
          <p class="text-sm">Radu îți va da acces în curând!</p>
        </div>

        <div v-else class="space-y-3">
          <RouterLink
            v-for="cm in modules"
            :key="cm.id"
            :to="`/modul/${cm.module.id}`"
            class="group flex items-center gap-4 p-5 rounded-2xl bg-[#111] border border-white/5 hover:border-red-500/25 active:scale-[0.98] transition-all"
          >
            <div class="w-14 h-14 rounded-2xl flex items-center justify-center flex-shrink-0"
                 style="background: rgba(239,68,68,0.12); border: 1px solid rgba(239,68,68,0.25);">
              <Play :size="24" class="text-red-400" />
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-xs font-bold uppercase tracking-widest text-red-500 mb-1">Modul {{ cm.module.order_index }}</p>
              <h3 class="text-lg font-bold text-white truncate leading-tight">{{ cm.module.title }}</h3>
              <p class="text-sm text-gray-500 mt-0.5 truncate">{{ cm.module.description }}</p>
            </div>
            <ChevronRight :size="20" class="text-gray-600 group-hover:text-red-400 flex-shrink-0 transition-colors" />
          </RouterLink>
        </div>
      </div>

    </main>
  </div>
</template>
