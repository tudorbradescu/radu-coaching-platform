<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/supabase.js'
import AppNav from '@/components/layout/AppNav.vue'
import { ArrowLeft, Plus, Trash2, ChevronDown, ChevronUp, Video, Save } from 'lucide-vue-next'
import { useRouter } from 'vue-router'

const router = useRouter()
const modules = ref([])
const expandedModule = ref(null)
const moduleVideos = ref({})
const loading = ref(true)
const saving = ref(false)

const newModule = ref({ title: '', description: '' })
const showNewModule = ref(false)
const newVideo = ref({})

onMounted(async () => {
  await fetchModules()
  loading.value = false
})

async function fetchModules() {
  const { data } = await supabase.from('modules').select('*').order('order_index')
  modules.value = data || []
}

async function addModule() {
  if (!newModule.value.title.trim()) return
  saving.value = true
  const { data } = await supabase.from('modules').insert({
    title: newModule.value.title,
    description: newModule.value.description,
    order_index: modules.value.length + 1
  }).select().single()
  if (data) modules.value.push(data)
  newModule.value = { title: '', description: '' }
  showNewModule.value = false
  saving.value = false
}

async function deleteModule(id) {
  if (!confirm('Ștergi modulul? Se șterg și videoclipurile.')) return
  await supabase.from('modules').delete().eq('id', id)
  modules.value = modules.value.filter(m => m.id !== id)
  delete moduleVideos.value[id]
}

async function toggleModule(mod) {
  if (expandedModule.value === mod.id) { expandedModule.value = null; return }
  expandedModule.value = mod.id
  if (!moduleVideos.value[mod.id]) {
    const { data } = await supabase.from('videos').select('*').eq('module_id', mod.id).order('order_index')
    moduleVideos.value[mod.id] = data || []
    newVideo.value[mod.id] = { title: '', vimeo_id: '', description: '' }
  }
}

async function addVideo(moduleId) {
  const v = newVideo.value[moduleId]
  if (!v.title.trim() || !v.vimeo_id.trim()) return
  const { data } = await supabase.from('videos').insert({
    module_id: moduleId,
    title: v.title,
    vimeo_id: v.vimeo_id,
    description: v.description,
    order_index: (moduleVideos.value[moduleId]?.length || 0) + 1
  }).select().single()
  if (data) moduleVideos.value[moduleId].push(data)
  newVideo.value[moduleId] = { title: '', vimeo_id: '', description: '' }
}

async function deleteVideo(moduleId, videoId) {
  await supabase.from('videos').delete().eq('id', videoId)
  moduleVideos.value[moduleId] = moduleVideos.value[moduleId].filter(v => v.id !== videoId)
}
</script>

<template>
  <div class="min-h-screen bg-[#0a0a0a]">
    <AppNav />

    <main class="max-w-4xl mx-auto px-5 pt-4 pb-8">

      <button @click="router.push('/admin')" class="flex items-center gap-2 text-sm text-gray-500 hover:text-white transition-colors mb-6">
        <ArrowLeft :size="16" /> Înapoi la Admin
      </button>

      <!-- Header -->
      <div class="mb-8">
        <p class="text-xs font-bold uppercase tracking-[0.3em] text-red-500 mb-1">Conținut</p>
        <h1 class="text-5xl font-['Bebas_Neue'] tracking-wide text-white mb-5">Module & Videouri</h1>
        <button
          @click="showNewModule = !showNewModule"
          class="flex items-center justify-center gap-2 w-full sm:w-auto sm:px-6 py-4 rounded-2xl text-base font-bold text-white transition-all active:scale-[0.98]"
          style="background: linear-gradient(135deg, #ef4444, #f97316);"
        >
          <Plus :size="20" /> + Modul nou
        </button>
      </div>

      <!-- New module form -->
      <div v-if="showNewModule" class="mb-6 bg-[#111] border border-red-500/20 rounded-2xl p-5">
        <p class="text-sm font-bold uppercase tracking-widest text-red-400 mb-4">Modul nou</p>
        <div class="space-y-3">
          <input v-model="newModule.title" type="text" placeholder="Titlu modul (ex: Mindset)"
            class="w-full px-4 py-4 rounded-xl bg-[#1a1a1a] border border-white/8 text-white placeholder-gray-600 text-base outline-none focus:border-red-500/50 transition-all" />
          <input v-model="newModule.description" type="text" placeholder="Descriere scurtă (opțional)"
            class="w-full px-4 py-4 rounded-xl bg-[#1a1a1a] border border-white/8 text-white placeholder-gray-600 text-base outline-none focus:border-red-500/50 transition-all" />
          <div class="flex gap-3">
            <button @click="addModule" :disabled="saving"
              class="flex-1 flex items-center justify-center gap-2 py-4 rounded-xl text-base font-bold text-white active:scale-[0.98] transition-all"
              style="background: linear-gradient(135deg, #ef4444, #f97316);">
              <Save :size="18" /> Salvează
            </button>
            <button @click="showNewModule = false"
              class="flex-1 py-4 rounded-xl text-base font-bold text-gray-400 bg-white/5 hover:bg-white/10 transition-colors">
              Anulează
            </button>
          </div>
        </div>
      </div>

      <!-- Modules list -->
      <div v-if="loading" class="space-y-3">
        <div v-for="i in 3" :key="i" class="h-20 bg-[#111] rounded-2xl animate-pulse"></div>
      </div>

      <div v-else class="space-y-3">
        <div v-if="modules.length === 0" class="text-center py-16 text-gray-500">
          <p class="text-base mb-1">Niciun modul creat.</p>
          <p class="text-sm">Apasă „+ Modul nou" pentru a începe.</p>
        </div>

        <div v-for="mod in modules" :key="mod.id"
             class="rounded-2xl border overflow-hidden"
             :class="expandedModule === mod.id ? 'border-red-500/30 bg-[#111]' : 'border-white/5 bg-[#0d0d0d]'">

          <!-- Module header -->
          <div class="flex items-center gap-3 p-4">
            <button class="flex-1 flex items-center gap-4 text-left" @click="toggleModule(mod)">
              <div class="w-12 h-12 rounded-2xl flex items-center justify-center flex-shrink-0 text-base font-bold"
                   :class="expandedModule === mod.id ? 'bg-red-500 text-white' : 'bg-[#1a1a1a] text-gray-500'">
                {{ mod.order_index }}
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-base font-bold text-white">{{ mod.title }}</p>
                <p class="text-sm text-gray-500 truncate">{{ mod.description || 'Fără descriere' }}</p>
              </div>
            </button>
            <button @click="toggleModule(mod)" class="p-2">
              <ChevronDown v-if="expandedModule !== mod.id" :size="20" class="text-gray-600" />
              <ChevronUp v-else :size="20" class="text-red-400" />
            </button>
            <button @click="deleteModule(mod.id)" class="p-2 rounded-xl text-gray-600 hover:text-red-400 hover:bg-red-500/10 transition-colors">
              <Trash2 :size="18" />
            </button>
          </div>

          <!-- Videos -->
          <div v-if="expandedModule === mod.id" class="px-4 pb-5 space-y-3">
            <p class="text-xs font-bold uppercase tracking-widest text-gray-500">Videouri</p>

            <div v-for="video in moduleVideos[mod.id]" :key="video.id"
                 class="flex items-center gap-3 p-4 bg-[#1a1a1a] rounded-xl border border-white/5">
              <Video :size="18" class="text-red-400 flex-shrink-0" />
              <div class="flex-1 min-w-0">
                <p class="text-sm font-bold text-white truncate">{{ video.title }}</p>
                <p class="text-xs text-gray-500">Vimeo ID: {{ video.vimeo_id }}</p>
              </div>
              <button @click="deleteVideo(mod.id, video.id)" class="p-2 rounded-xl text-gray-600 hover:text-red-400 hover:bg-red-500/10 transition-colors">
                <Trash2 :size="16" />
              </button>
            </div>

            <!-- Add video form -->
            <div class="p-4 bg-[#141414] rounded-xl border border-dashed border-white/10 space-y-3">
              <p class="text-xs font-bold text-gray-500 uppercase tracking-widest">+ Videoclip nou</p>
              <input v-model="newVideo[mod.id].title" type="text" placeholder="Titlu videoclip"
                class="w-full px-4 py-3.5 rounded-xl bg-[#1a1a1a] border border-white/8 text-white placeholder-gray-600 text-base outline-none focus:border-red-500/50 transition-all" />
              <input v-model="newVideo[mod.id].vimeo_id" type="text" placeholder="Vimeo ID (ex: 123456789 sau 123456789/hashPrivat)"
                class="w-full px-4 py-3.5 rounded-xl bg-[#1a1a1a] border border-white/8 text-white placeholder-gray-600 text-base outline-none focus:border-red-500/50 transition-all" />
              <input v-model="newVideo[mod.id].description" type="text" placeholder="Descriere (opțional)"
                class="w-full px-4 py-3.5 rounded-xl bg-[#1a1a1a] border border-white/8 text-white placeholder-gray-600 text-base outline-none focus:border-red-500/50 transition-all" />
              <button @click="addVideo(mod.id)"
                class="w-full flex items-center justify-center gap-2 py-4 rounded-xl text-base font-bold text-white active:scale-[0.98] transition-all"
                style="background: linear-gradient(135deg, #ef4444, #f97316);">
                <Plus :size="18" /> Adaugă videoclip
              </button>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>
