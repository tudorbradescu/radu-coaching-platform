<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '@/supabase.js'
import { useAuthStore } from '@/stores/auth.js'
import AppNav from '@/components/layout/AppNav.vue'
import { ArrowLeft, Play, ChevronUp } from 'lucide-vue-next'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()

const moduleData = ref(null)
const videos = ref([])
const loading = ref(true)
const openVideo = ref(null)

onMounted(async () => {
  // Check access
  const { data: access } = await supabase
    .from('client_modules')
    .select('id')
    .eq('client_id', auth.user.id)
    .eq('module_id', route.params.id)
    .single()

  if (!access && !auth.isAdmin) {
    router.push('/')
    return
  }

  const { data: mod } = await supabase
    .from('modules')
    .select('*')
    .eq('id', route.params.id)
    .single()
  moduleData.value = mod

  const { data: vids } = await supabase
    .from('videos')
    .select('*')
    .eq('module_id', route.params.id)
    .order('order_index')
  videos.value = vids || []

  if (videos.value.length > 0) openVideo.value = videos.value[0].id
  loading.value = false
})

function toggleVideo(id) {
  openVideo.value = openVideo.value === id ? null : id
}

function vimeoEmbed(vimeoId) {
  let raw = vimeoId.toString().trim()
  // Handle full URLs: https://vimeo.com/123/hash?params
  const urlMatch = raw.match(/vimeo\.com\/(\d+(?:\/[a-zA-Z0-9]+)?)/)
  if (urlMatch) raw = urlMatch[1]
  const [id, hash] = raw.split('/')
  const hashParam = hash ? `&h=${hash}` : ''
  return `https://player.vimeo.com/video/${id}?badge=0&autopause=0&player_id=0&app_id=58479${hashParam}`
}
</script>

<template>
  <div class="page-wrapper">
    <div class="page-bg"></div>
    <AppNav />

    <main class="page-content">

      <!-- Back -->
      <button @click="router.back()" class="flex items-center gap-2 text-sm text-zinc-500 hover:text-white transition-colors mb-6">
        <ArrowLeft :size="16" /> Inapoi
      </button>

      <!-- Loading -->
      <div v-if="loading" class="space-y-4">
        <div class="h-10 w-3/4 bg-white/[0.03] rounded-xl animate-pulse"></div>
        <div class="h-5 w-1/2 bg-white/[0.03] rounded-xl animate-pulse"></div>
        <div class="h-20 bg-white/[0.03] rounded-2xl animate-pulse mt-6"></div>
      </div>

      <template v-else-if="moduleData">

        <!-- Module header -->
        <div class="mb-10">
          <p class="text-xs font-bold uppercase tracking-[0.3em] text-red-500 mb-1">Modul {{ moduleData.order_index }}</p>
          <h1 class="page-title">{{ moduleData.title }}</h1>
          <p v-if="moduleData.description" class="text-base text-zinc-400 mt-3">{{ moduleData.description }}</p>
        </div>

        <!-- Videos list -->
        <div>
          <p class="text-xs font-bold uppercase tracking-[0.3em] text-zinc-500 mb-5">{{ videos.length }} videouri</p>

          <div v-if="videos.length === 0" class="text-center py-20 text-zinc-500">
            <p class="text-lg">Niciun videoclip adaugat inca.</p>
          </div>

          <div v-else class="space-y-3">
            <div
              v-for="(video, idx) in videos"
              :key="video.id"
              class="video-card"
              :class="openVideo === video.id ? 'video-card--open' : 'video-card--closed'"
            >
              <!-- Video header -->
              <button
                class="w-full flex items-center gap-4 p-5 text-left transition-colors"
                @click="toggleVideo(video.id)"
              >
                <div
                  class="video-index"
                  :class="openVideo === video.id ? 'video-index--active' : 'video-index--idle'"
                >
                  {{ idx + 1 }}
                </div>
                <div class="flex-1 min-w-0">
                  <p class="text-base font-bold text-white truncate">{{ video.title }}</p>
                  <p v-if="video.description" class="text-sm text-zinc-500 mt-0.5 truncate">{{ video.description }}</p>
                </div>
                <div class="flex-shrink-0">
                  <Play v-if="openVideo !== video.id" :size="22" class="text-zinc-500" />
                  <ChevronUp v-else :size="22" class="text-red-400" />
                </div>
              </button>

              <!-- Vimeo embed -->
              <div v-if="openVideo === video.id" class="px-5 pb-5">
                <div class="relative w-full rounded-2xl overflow-hidden" style="padding-top: 56.25%;">
                  <iframe
                    :src="vimeoEmbed(video.vimeo_id)"
                    class="absolute inset-0 w-full h-full"
                    frameborder="0"
                    allow="autoplay; fullscreen; picture-in-picture; clipboard-write; encrypted-media"
                    allowfullscreen
                  ></iframe>
                </div>
              </div>
            </div>
          </div>
        </div>

      </template>
    </main>
  </div>
</template>

<style scoped>
.page-wrapper {
  min-height: 100vh;
  background: #0a0a0f;
  position: relative;
}

.page-bg {
  position: fixed;
  inset: 0;
  background:
    radial-gradient(ellipse 70% 50% at 50% -5%, rgba(239, 68, 68, 0.08), transparent 60%),
    radial-gradient(ellipse 50% 40% at 80% 50%, rgba(249, 115, 22, 0.05), transparent 50%),
    radial-gradient(ellipse 50% 50% at 10% 90%, rgba(139, 92, 246, 0.04), transparent 50%);
  pointer-events: none;
  z-index: 0;
}

.page-content {
  position: relative;
  z-index: 1;
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem 1.5rem 8rem;
}

@media (min-width: 640px) {
  .page-content {
    padding: 2.5rem 2rem 4rem;
  }
}

.page-title {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 3.5rem;
  letter-spacing: 0.05em;
  color: white;
  line-height: 1;
}

@media (min-width: 640px) {
  .page-title {
    font-size: 4.5rem;
  }
}

.video-card {
  border-radius: 20px;
  overflow: hidden;
  transition: all 0.2s;
}

.video-card--open {
  border: 1px solid rgba(239, 68, 68, 0.2);
  background: rgba(17, 17, 19, 0.8);
}

.video-card--closed {
  border: 1px solid rgba(255, 255, 255, 0.05);
  background: rgba(13, 13, 15, 0.7);
}

.video-card--closed:hover {
  border-color: rgba(255, 255, 255, 0.08);
  background: rgba(17, 17, 19, 0.7);
}

.video-index {
  width: 52px;
  height: 52px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  font-size: 0.875rem;
  font-weight: 700;
  transition: all 0.2s;
}

.video-index--active {
  background: #ef4444;
  color: white;
}

.video-index--idle {
  background: rgba(255, 255, 255, 0.05);
  color: #71717a;
}
</style>
