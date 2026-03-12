<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/supabase.js'
import AdminLayout from '@/components/layout/AdminLayout.vue'
import { Plus, Trash2, ChevronDown, ChevronUp, Video, Save, X } from 'lucide-vue-next'

const modules = ref([])
const expandedModule = ref(null)
const moduleVideos = ref({})
const loading = ref(true)
const saving = ref(false)

const newModule = ref({ title: '', description: '' })
const showNewModule = ref(false)
const newVideo = ref({})

onMounted(async () => {
  try { await fetchModules() } catch (e) { /* ignore */ }
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
  if (!confirm('Stergi modulul? Se sterg si videoclipurile.')) return
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
  <AdminLayout>
    <div class="admin-content">

      <!-- Header -->
      <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-8">
        <div>
          <h1 class="text-2xl font-semibold text-white tracking-tight">Module & Videouri</h1>
          <p class="text-sm text-zinc-500 mt-1">Organizeaza continutul de training</p>
        </div>
        <button @click="showNewModule = !showNewModule"
          class="flex items-center justify-center gap-2 px-4 py-2.5 rounded-lg text-sm font-medium text-white bg-red-500 hover:bg-red-600 transition-colors">
          <Plus :size="16" /> Modul nou
        </button>
      </div>

      <!-- New module form -->
      <Transition name="fade">
        <div v-if="showNewModule" class="mb-6 bg-[#111113] border border-white/[0.08] rounded-xl p-5">
          <div class="flex items-center justify-between mb-4">
            <p class="text-sm font-semibold text-white">Modul nou</p>
            <button @click="showNewModule = false" class="text-zinc-500 hover:text-white p-1 rounded-md hover:bg-white/[0.06]">
              <X :size="16" />
            </button>
          </div>
          <div class="space-y-3">
            <input v-model="newModule.title" type="text" placeholder="Titlu modul (ex: Mindset)"
              class="w-full px-3.5 py-2.5 rounded-lg bg-[#09090b] border border-white/[0.08] text-sm text-white placeholder-zinc-600 outline-none focus:border-red-500/50 transition-all" />
            <input v-model="newModule.description" type="text" placeholder="Descriere scurta (optional)"
              class="w-full px-3.5 py-2.5 rounded-lg bg-[#09090b] border border-white/[0.08] text-sm text-white placeholder-zinc-600 outline-none focus:border-red-500/50 transition-all" />
            <div class="flex gap-3">
              <button @click="showNewModule = false"
                class="flex-1 py-2.5 rounded-lg text-sm font-medium text-zinc-400 bg-white/[0.04] hover:bg-white/[0.08] border border-zinc-800 transition-colors">
                Anuleaza
              </button>
              <button @click="addModule" :disabled="saving"
                class="flex-1 flex items-center justify-center gap-2 py-2.5 rounded-lg text-sm font-medium text-white bg-red-500 hover:bg-red-600 transition-colors">
                <Save :size="14" /> Salveaza
              </button>
            </div>
          </div>
        </div>
      </Transition>

      <!-- Modules list -->
      <div class="bg-[#111113] border border-zinc-800 rounded-xl overflow-hidden">
        <div v-if="loading" class="divide-y divide-white/[0.04]">
          <div v-for="i in 3" :key="i" class="h-[72px] animate-pulse bg-white/[0.02]"></div>
        </div>

        <div v-else-if="modules.length === 0" class="py-16 text-center">
          <p class="text-sm text-zinc-500 mb-1">Niciun modul creat.</p>
          <p class="text-xs text-zinc-600">Apasa „Modul nou" pentru a incepe.</p>
        </div>

        <div v-else class="divide-y divide-white/[0.04]">
          <div v-for="mod in modules" :key="mod.id">
            <!-- Module header -->
            <div class="flex items-center gap-3 px-5 py-4 hover:bg-white/[0.02] transition-colors">
              <button class="flex-1 flex items-center gap-4 text-left" @click="toggleModule(mod)">
                <div class="w-9 h-9 rounded-lg flex items-center justify-center flex-shrink-0 text-sm font-semibold"
                  :class="expandedModule === mod.id ? 'bg-red-500 text-white' : 'bg-white/[0.06] text-zinc-400'">
                  {{ mod.order_index }}
                </div>
                <div class="flex-1 min-w-0">
                  <p class="text-sm font-medium text-white">{{ mod.title }}</p>
                  <p class="text-xs text-zinc-500 truncate">{{ mod.description || 'Fara descriere' }}</p>
                </div>
              </button>
              <button @click="toggleModule(mod)" class="p-1.5">
                <ChevronDown v-if="expandedModule !== mod.id" :size="16" class="text-zinc-600" />
                <ChevronUp v-else :size="16" class="text-zinc-400" />
              </button>
              <button @click="deleteModule(mod.id)" class="p-1.5 rounded-md text-zinc-600 hover:text-red-400 hover:bg-red-500/[0.08] transition-colors">
                <Trash2 :size="15" />
              </button>
            </div>

            <!-- Videos -->
            <div v-if="expandedModule === mod.id" class="px-5 pb-5 bg-white/[0.01] space-y-2">
              <p class="text-xs font-medium uppercase tracking-wider text-zinc-500 mb-2 pl-1">Videouri</p>

              <div v-for="video in moduleVideos[mod.id]" :key="video.id"
                class="flex items-center gap-3 px-4 py-3 bg-white/[0.02] rounded-lg border border-white/[0.04]">
                <Video :size="16" class="text-red-400 flex-shrink-0" />
                <div class="flex-1 min-w-0">
                  <p class="text-sm font-medium text-white truncate">{{ video.title }}</p>
                  <p class="text-xs text-zinc-600 font-mono">{{ video.vimeo_id }}</p>
                </div>
                <button @click="deleteVideo(mod.id, video.id)" class="p-1.5 rounded-md text-zinc-600 hover:text-red-400 hover:bg-red-500/[0.08] transition-colors">
                  <Trash2 :size="14" />
                </button>
              </div>

              <!-- Add video form -->
              <div class="p-4 rounded-lg border border-dashed border-white/[0.08] bg-white/[0.01] space-y-2.5 mt-3">
                <p class="text-xs font-medium text-zinc-500 uppercase tracking-wider">Videoclip nou</p>
                <input v-model="newVideo[mod.id].title" type="text" placeholder="Titlu videoclip"
                  class="w-full px-3.5 py-2.5 rounded-lg bg-[#09090b] border border-white/[0.08] text-sm text-white placeholder-zinc-600 outline-none focus:border-red-500/50 transition-all" />
                <input v-model="newVideo[mod.id].vimeo_id" type="text" placeholder="Vimeo ID (ex: 123456789 sau 123456789/hash)"
                  class="w-full px-3.5 py-2.5 rounded-lg bg-[#09090b] border border-white/[0.08] text-sm text-white placeholder-zinc-600 outline-none focus:border-red-500/50 transition-all" />
                <input v-model="newVideo[mod.id].description" type="text" placeholder="Descriere (optional)"
                  class="w-full px-3.5 py-2.5 rounded-lg bg-[#09090b] border border-white/[0.08] text-sm text-white placeholder-zinc-600 outline-none focus:border-red-500/50 transition-all" />
                <button @click="addVideo(mod.id)"
                  class="w-full flex items-center justify-center gap-2 py-2.5 rounded-lg text-sm font-medium text-white bg-red-500 hover:bg-red-600 transition-colors">
                  <Plus :size="14" /> Adauga videoclip
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

    </div>
  </AdminLayout>
</template>

<style scoped>
.fade-enter-active, .fade-leave-active { transition: opacity 0.15s, transform 0.15s; }
.fade-enter-from, .fade-leave-to { opacity: 0; transform: translateY(-4px); }
</style>
