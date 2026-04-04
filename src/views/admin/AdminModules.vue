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
const moduleError = ref('')
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
  moduleError.value = ''
  try {
    const { data, error } = await supabase.from('modules').insert({
      title: newModule.value.title,
      description: newModule.value.description,
      order_index: modules.value.length + 1
    }).select().single()
    if (error) throw new Error(error.message)
    if (data) modules.value.push(data)
    newModule.value = { title: '', description: '' }
    showNewModule.value = false
  } catch (e) {
    moduleError.value = e.message
  } finally {
    saving.value = false
  }
}

async function deleteModule(id) {
  if (!confirm('Stergi modulul? Se sterg si videoclipurile.')) return
  await supabase.from('modules').delete().eq('id', id)
  modules.value = modules.value.filter(m => m.id !== id)
  delete moduleVideos.value[id]
}

async function toggleModule(mod) {
  if (expandedModule.value === mod.id) { expandedModule.value = null; return }
  if (!moduleVideos.value[mod.id]) {
    moduleVideos.value[mod.id] = []
    newVideo.value[mod.id] = { title: '', vimeo_id: '', description: '' }
    expandedModule.value = mod.id
    const { data } = await supabase.from('videos').select('*').eq('module_id', mod.id).order('order_index')
    moduleVideos.value[mod.id] = data || []
  } else {
    expandedModule.value = mod.id
  }
}

function parseVimeoId(input) {
  if (!input) return input
  const s = input.trim()
  // Full URL: https://vimeo.com/1173928278/5b462498c8?fl=pl&fe=sh
  const urlMatch = s.match(/vimeo\.com\/(\d+(?:\/[a-zA-Z0-9]+)?)/)
  if (urlMatch) return urlMatch[1]
  // Already an ID like 1173928278 or 1173928278/hash
  return s
}

const videoError = ref('')

async function addVideo(moduleId) {
  const v = newVideo.value[moduleId]
  if (!v || !v.title.trim() || !v.vimeo_id.trim()) return
  if (saving.value) return
  saving.value = true
  videoError.value = ''
  try {
    const vimeoId = parseVimeoId(v.vimeo_id)
    const { data, error } = await supabase.from('videos').insert({
      module_id: moduleId,
      title: v.title,
      vimeo_id: vimeoId,
      description: v.description,
      order_index: (moduleVideos.value[moduleId]?.length || 0) + 1
    }).select().single()
    if (error) throw new Error(error.message)
    if (data) moduleVideos.value[moduleId] = [...moduleVideos.value[moduleId], data]
    newVideo.value[moduleId] = { title: '', vimeo_id: '', description: '' }
  } catch (e) {
    videoError.value = e.message
  } finally {
    saving.value = false
  }
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
      <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-10">
        <div>
          <h1 class="text-3xl font-semibold text-white tracking-tight">Module & Videouri</h1>
          <p class="text-base text-zinc-500 mt-2">Organizeaza continutul de training</p>
        </div>
        <button @click="showNewModule = !showNewModule"
          class="action-btn">
          <Plus :size="18" /> Modul nou
        </button>
      </div>

      <!-- New module form -->
      <Transition name="fade">
        <div v-if="showNewModule" class="mb-8 bg-[#111113] border border-white/[0.08] rounded-xl p-6">
          <div class="flex items-center justify-between mb-5">
            <p class="text-base font-semibold text-white">Modul nou</p>
            <button @click="showNewModule = false" class="text-zinc-500 hover:text-white p-1.5 rounded-md hover:bg-white/[0.06]">
              <X :size="18" />
            </button>
          </div>
          <div class="space-y-4">
            <input v-model="newModule.title" type="text" placeholder="Titlu modul (ex: Mindset)"
              class="form-input" />
            <input v-model="newModule.description" type="text" placeholder="Descriere scurta (optional)"
              class="form-input" />
            <div v-if="moduleError" class="text-base text-red-400 bg-red-500/[0.06] border border-red-500/15 rounded-lg px-5 py-4">
              {{ moduleError }}
            </div>
            <div class="flex gap-3 pt-1">
              <button @click="showNewModule = false"
                class="cancel-btn">
                Anuleaza
              </button>
              <button @click="addModule" :disabled="saving"
                class="save-btn">
                <Save :size="16" /> {{ saving ? 'Se salveaza...' : 'Salveaza' }}
              </button>
            </div>
          </div>
        </div>
      </Transition>

      <!-- Modules list -->
      <div class="bg-[#111113] border border-zinc-800 rounded-xl overflow-hidden">
        <div v-if="loading" class="divide-y divide-white/[0.04]">
          <div v-for="i in 3" :key="i" class="h-[88px] animate-pulse bg-white/[0.02]"></div>
        </div>

        <div v-else-if="modules.length === 0" class="py-20 text-center">
          <p class="text-base text-zinc-500 mb-1">Niciun modul creat.</p>
          <p class="text-sm text-zinc-600">Apasa „Modul nou" pentru a incepe.</p>
        </div>

        <div v-else class="divide-y divide-white/[0.04]">
          <div v-for="mod in modules" :key="mod.id">
            <!-- Module header -->
            <div class="flex items-center gap-4 px-7 py-5 hover:bg-white/[0.02] transition-colors">
              <button class="flex-1 flex items-center gap-5 text-left" @click="toggleModule(mod)">
                <div class="module-index"
                  :class="expandedModule === mod.id ? 'module-index--active' : 'module-index--idle'">
                  {{ mod.order_index }}
                </div>
                <div class="flex-1 min-w-0">
                  <p class="text-base font-medium text-white">{{ mod.title }}</p>
                  <p class="text-sm text-zinc-500 truncate">{{ mod.description || 'Fara descriere' }}</p>
                </div>
              </button>
              <button @click="toggleModule(mod)" class="p-2">
                <ChevronDown v-if="expandedModule !== mod.id" :size="18" class="text-zinc-600" />
                <ChevronUp v-else :size="18" class="text-zinc-400" />
              </button>
              <button @click="deleteModule(mod.id)" class="p-2 rounded-md text-zinc-600 hover:text-red-400 hover:bg-red-500/[0.08] transition-colors">
                <Trash2 :size="17" />
              </button>
            </div>

            <!-- Videos -->
            <div v-if="expandedModule === mod.id" class="px-7 pb-6 bg-white/[0.01] space-y-3">
              <p class="text-xs font-semibold uppercase tracking-wider text-zinc-500 mb-3 pl-1">Videouri</p>

              <div v-for="video in moduleVideos[mod.id]" :key="video.id"
                class="flex items-center gap-4 px-5 py-4 bg-white/[0.02] rounded-lg border border-white/[0.04]">
                <Video :size="18" class="text-red-400 flex-shrink-0" />
                <div class="flex-1 min-w-0">
                  <p class="text-base font-medium text-white truncate">{{ video.title }}</p>
                  <p class="text-sm text-zinc-600 font-mono">{{ video.vimeo_id }}</p>
                </div>
                <button @click="deleteVideo(mod.id, video.id)" class="p-2 rounded-md text-zinc-600 hover:text-red-400 hover:bg-red-500/[0.08] transition-colors">
                  <Trash2 :size="16" />
                </button>
              </div>

              <!-- Add video form -->
              <div class="p-5 rounded-lg border border-dashed border-white/[0.08] bg-white/[0.01] space-y-3 mt-4">
                <p class="text-xs font-semibold text-zinc-500 uppercase tracking-wider">Videoclip nou</p>
                <input v-model="newVideo[mod.id].title" type="text" placeholder="Titlu videoclip"
                  class="form-input" />
                <input v-model="newVideo[mod.id].vimeo_id" type="text" placeholder="Vimeo ID (ex: 123456789 sau 123456789/hash)"
                  class="form-input" />
                <input v-model="newVideo[mod.id].description" type="text" placeholder="Descriere (optional)"
                  class="form-input" />
                <div v-if="videoError" class="text-base text-red-400 bg-red-500/[0.06] border border-red-500/15 rounded-lg px-5 py-4">
                  {{ videoError }}
                </div>
                <button @click="addVideo(mod.id)" :disabled="saving"
                  class="w-full flex items-center justify-center gap-2 py-3 rounded-lg text-base font-medium text-white bg-red-500 hover:bg-red-600 disabled:opacity-50 disabled:cursor-default transition-colors">
                  <Plus :size="16" /> {{ saving ? 'Se adauga...' : 'Adauga videoclip' }}
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

.module-index {
  width: 48px;
  height: 48px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  font-size: 1rem;
  font-weight: 600;
}
.module-index--active { background: #ef4444; color: white; }
.module-index--idle { background: rgba(255,255,255,0.06); color: #a1a1aa; }

.fade-enter-active, .fade-leave-active { transition: opacity 0.15s, transform 0.15s; }
.fade-enter-from, .fade-leave-to { opacity: 0; transform: translateY(-4px); }
</style>
