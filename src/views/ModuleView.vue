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
  const [id, hash] = vimeoId.toString().split('/')
  const hashParam = hash ? `&h=${hash}` : ''
  return `https://player.vimeo.com/video/${id}?badge=0&autopause=0&player_id=0&app_id=58479${hashParam}`
}
</script>

<template>
  <div class="min-h-screen bg-[#0a0a0a]">
    <AppNav />

    <main class="max-w-2xl mx-auto px-5 pt-4 pb-8">

      <!-- Back -->
      <button @click="router.back()" class="flex items-center gap-2 text-sm text-gray-500 hover:text-white transition-colors mb-6">
        <ArrowLeft :size="16" /> Înapoi
      </button>

      <!-- Loading -->
      <div v-if="loading" class="space-y-4">
        <div class="h-10 w-3/4 bg-[#111] rounded-xl animate-pulse"></div>
        <div class="h-5 w-1/2 bg-[#111] rounded-xl animate-pulse"></div>
        <div class="h-20 bg-[#111] rounded-2xl animate-pulse mt-6"></div>
      </div>

      <template v-else-if="moduleData">

        <!-- Module header -->
        <div class="mb-8">
          <p class="text-xs font-bold uppercase tracking-[0.3em] text-red-500 mb-1">Modul {{ moduleData.order_index }}</p>
          <h1 class="text-5xl font-['Bebas_Neue'] tracking-wide text-white leading-none mb-3">{{ moduleData.title }}</h1>
          <p class="text-base text-gray-400">{{ moduleData.description }}</p>
        </div>

        <!-- Videos list -->
        <div class="space-y-3">
          <p class="text-xs font-bold uppercase tracking-[0.3em] text-gray-500 mb-4">{{ videos.length }} videouri</p>

          <div v-if="videos.length === 0" class="text-center py-16 text-gray-500">
            <p class="text-base">Niciun videoclip adăugat încă.</p>
          </div>

          <div
            v-for="(video, idx) in videos"
            :key="video.id"
            class="rounded-2xl border overflow-hidden transition-colors"
            :class="openVideo === video.id ? 'border-red-500/25 bg-[#111]' : 'border-white/5 bg-[#0d0d0d]'"
          >
            <!-- Video header -->
            <button
              class="w-full flex items-center gap-4 p-5 text-left active:bg-white/5 transition-colors"
              @click="toggleVideo(video.id)"
            >
              <div
                class="w-12 h-12 rounded-2xl flex items-center justify-center flex-shrink-0 text-sm font-bold transition-colors"
                :class="openVideo === video.id ? 'bg-red-500 text-white' : 'bg-[#1a1a1a] text-gray-500'"
              >
                {{ idx + 1 }}
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-base font-bold text-white truncate">{{ video.title }}</p>
                <p v-if="video.description" class="text-sm text-gray-500 mt-0.5 truncate">{{ video.description }}</p>
              </div>
              <div class="flex-shrink-0">
                <Play v-if="openVideo !== video.id" :size="20" class="text-gray-500" />
                <ChevronUp v-else :size="20" class="text-red-400" />
              </div>
            </button>

            <!-- Vimeo embed -->
            <div v-if="openVideo === video.id" class="px-4 pb-5">
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

      </template>
    </main>
  </div>
</template>
