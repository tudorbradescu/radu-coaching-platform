<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '@/supabase.js'
import { useAuthStore } from '@/stores/auth.js'
import AppNav from '@/components/layout/AppNav.vue'
import { ArrowLeft, Play, Lock, ChevronDown, ChevronUp } from 'lucide-vue-next'

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
  return `https://player.vimeo.com/video/${vimeoId}?badge=0&autopause=0&player_id=0&app_id=58479`
}
</script>

<template>
  <div class="min-h-screen bg-[#0a0a0a]">
    <AppNav />

    <main class="max-w-4xl mx-auto px-4 pt-28 pb-16">

      <!-- Back -->
      <button @click="router.back()" class="flex items-center gap-2 text-sm text-gray-500 hover:text-white transition-colors mb-8 group">
        <ArrowLeft :size="16" class="group-hover:-translate-x-1 transition-transform" /> Înapoi la Dashboard
      </button>

      <!-- Loading -->
      <div v-if="loading" class="space-y-4">
        <div class="h-8 w-48 bg-[#111] rounded animate-pulse"></div>
        <div class="h-4 w-72 bg-[#111] rounded animate-pulse"></div>
      </div>

      <template v-else-if="moduleData">
        <!-- Module header -->
        <div class="mb-10">
          <p class="text-xs font-semibold uppercase tracking-[0.3em] text-red-500 mb-2">Modul {{ moduleData.order_index }}</p>
          <h1 class="text-4xl sm:text-5xl font-['Bebas_Neue'] tracking-wide text-white mb-3">{{ moduleData.title }}</h1>
          <p class="text-gray-400 text-sm max-w-2xl">{{ moduleData.description }}</p>
        </div>

        <!-- Videos accordion -->
        <div class="space-y-2">
          <p class="text-xs font-semibold uppercase tracking-[0.3em] text-gray-500 mb-4">{{ videos.length }} videouri</p>

          <div v-if="videos.length === 0" class="text-center py-12 text-gray-500 text-sm">
            Niciun videoclip adăugat încă în acest modul.
          </div>

          <div
            v-for="(video, idx) in videos"
            :key="video.id"
            class="rounded-xl border overflow-hidden transition-colors"
            :class="openVideo === video.id ? 'border-red-500/30 bg-[#111]' : 'border-white/5 bg-[#0d0d0d] hover:border-white/10'"
          >
            <!-- Video header -->
            <button
              class="w-full flex items-center gap-4 p-4 text-left"
              @click="toggleVideo(video.id)"
            >
              <div class="w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0 text-xs font-bold"
                   :class="openVideo === video.id ? 'bg-red-500 text-white' : 'bg-[#1a1a1a] text-gray-500'">
                {{ idx + 1 }}
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-sm font-semibold text-white truncate">{{ video.title }}</p>
                <p v-if="video.description" class="text-xs text-gray-500 mt-0.5 truncate">{{ video.description }}</p>
              </div>
              <Play v-if="openVideo !== video.id" :size="14" class="text-gray-500 flex-shrink-0" />
              <ChevronUp v-else :size="14" class="text-red-400 flex-shrink-0" />
            </button>

            <!-- Vimeo embed -->
            <div v-if="openVideo === video.id" class="px-4 pb-4">
              <div class="relative w-full rounded-xl overflow-hidden" style="padding-top: 56.25%;">
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
