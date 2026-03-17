<script setup>
import { ref, onMounted, computed } from 'vue'
import { useAuthStore } from '@/stores/auth.js'
import { supabase } from '@/supabase.js'
import AppNav from '@/components/layout/AppNav.vue'
import { Send, MessageCircle, Trash2, ChevronDown, ChevronUp } from 'lucide-vue-next'

const auth = useAuthStore()
const posts = ref([])
const newPost = ref('')
const loading = ref(true)
const posting = ref(false)
const expandedComments = ref(new Set())
const commentTexts = ref({})

const reactionEmojis = {
  heart: { icon: '❤️', label: 'Heart' },
  clap: { icon: '👏', label: 'Clap' },
  fire: { icon: '🔥', label: 'Fire' },
  muscle: { icon: '💪', label: 'Muscle' }
}

onMounted(async () => {
  await fetchPosts()
  loading.value = false
})

async function fetchPosts() {
  const { data } = await supabase
    .from('posts')
    .select(`
      *,
      profile:profiles(full_name, role),
      reactions:post_reactions(id, user_id, reaction_type),
      comments:post_comments(id, user_id, content, created_at, profile:profiles(full_name, role))
    `)
    .order('created_at', { ascending: false })

  posts.value = (data || []).map(p => ({
    ...p,
    comments: (p.comments || []).sort((a, b) => new Date(a.created_at) - new Date(b.created_at))
  }))
}

async function createPost() {
  if (!newPost.value.trim() || posting.value) return
  posting.value = true
  const { error } = await supabase
    .from('posts')
    .insert({ user_id: auth.user.id, content: newPost.value.trim() })
  if (!error) {
    newPost.value = ''
    await fetchPosts()
  }
  posting.value = false
}

async function deletePost(postId) {
  await supabase.from('posts').delete().eq('id', postId)
  await fetchPosts()
}

async function toggleReaction(postId, reactionType) {
  const post = posts.value.find(p => p.id === postId)
  if (!post) return

  const existing = post.reactions.find(
    r => r.user_id === auth.user.id && r.reaction_type === reactionType
  )

  if (existing) {
    await supabase.from('post_reactions').delete().eq('id', existing.id)
  } else {
    await supabase.from('post_reactions').insert({
      post_id: postId,
      user_id: auth.user.id,
      reaction_type: reactionType
    })
  }
  await fetchPosts()
}

function toggleComments(postId) {
  if (expandedComments.value.has(postId)) {
    expandedComments.value.delete(postId)
  } else {
    expandedComments.value.add(postId)
  }
}

async function addComment(postId) {
  const text = commentTexts.value[postId]?.trim()
  if (!text) return

  await supabase.from('post_comments').insert({
    post_id: postId,
    user_id: auth.user.id,
    content: text
  })
  commentTexts.value[postId] = ''
  await fetchPosts()
}

async function deleteComment(commentId) {
  await supabase.from('post_comments').delete().eq('id', commentId)
  await fetchPosts()
}

function hasReacted(post, type) {
  return post.reactions.some(r => r.user_id === auth.user.id && r.reaction_type === type)
}

function reactionCount(post, type) {
  return post.reactions.filter(r => r.reaction_type === type).length
}

function timeAgo(dateStr) {
  const diff = Date.now() - new Date(dateStr).getTime()
  const mins = Math.floor(diff / 60000)
  if (mins < 1) return 'Acum'
  if (mins < 60) return `${mins}m`
  const hours = Math.floor(mins / 60)
  if (hours < 24) return `${hours}h`
  const days = Math.floor(hours / 24)
  if (days < 7) return `${days}z`
  const weeks = Math.floor(days / 7)
  return `${weeks}s`
}

function escapeHtml(text) {
  const div = document.createElement('div')
  div.textContent = text
  return div.innerHTML
}

function linkify(text) {
  const escaped = escapeHtml(text)
  const urlRegex = /(https?:\/\/[^\s]+)/g
  return escaped.replace(urlRegex, '<a href="$1" target="_blank" rel="noopener" class="text-red-400 hover:text-red-300 underline break-all">$1</a>')
}

function canDelete(post) {
  return post.user_id === auth.user.id || auth.isAdmin
}
</script>

<template>
  <div class="page-wrapper">
    <div class="page-bg"></div>
    <AppNav />

    <main class="page-content">

      <div class="mb-8">
        <p class="text-sm font-semibold uppercase tracking-[0.3em] text-red-500 mb-1">Comunitate</p>
        <h1 class="page-title">Feed</h1>
      </div>

      <!-- New post -->
      <div class="post-composer">
        <div class="flex items-start gap-3">
          <div class="w-10 h-10 rounded-full bg-gradient-to-br from-red-500 to-orange-500 flex items-center justify-center flex-shrink-0 text-white font-bold text-sm">
            {{ (auth.profile?.full_name || 'U')[0].toUpperCase() }}
          </div>
          <div class="flex-1">
            <textarea
              v-model="newPost"
              placeholder="Scrie ceva... (progres, intrebari, motivatie)"
              class="post-textarea"
              rows="3"
              @keydown.meta.enter="createPost"
              @keydown.ctrl.enter="createPost"
            ></textarea>
            <div class="flex justify-end mt-3">
              <button
                @click="createPost"
                :disabled="!newPost.trim() || posting"
                class="post-btn"
              >
                <Send :size="16" />
                {{ posting ? 'Se trimite...' : 'Posteaza' }}
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="space-y-4 mt-6">
        <div v-for="i in 3" :key="i" class="h-40 rounded-2xl bg-white/[0.03] animate-pulse"></div>
      </div>

      <!-- Posts -->
      <div v-else class="space-y-4 mt-6">
        <div v-if="posts.length === 0" class="text-center py-20 text-zinc-500">
          <MessageCircle :size="48" class="mx-auto mb-3 opacity-30" />
          <p class="text-lg">Niciun post inca</p>
          <p class="text-sm text-zinc-600">Fii primul care posteaza!</p>
        </div>

        <div v-for="post in posts" :key="post.id" class="post-card">
          <!-- Header -->
          <div class="flex items-center gap-3 mb-3">
            <div class="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 text-white font-bold text-sm"
                 :class="post.profile?.role === 'admin' ? 'bg-gradient-to-br from-red-500 to-orange-500' : 'bg-zinc-700'">
              {{ (post.profile?.full_name || 'U')[0].toUpperCase() }}
            </div>
            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-2">
                <span class="font-semibold text-white text-sm">{{ post.profile?.full_name || 'Utilizator' }}</span>
                <span v-if="post.profile?.role === 'admin'" class="text-[10px] font-bold uppercase tracking-wider px-1.5 py-0.5 rounded bg-red-500/15 text-red-400">Coach</span>
              </div>
              <span class="text-xs text-zinc-500">{{ timeAgo(post.created_at) }}</span>
            </div>
            <button
              v-if="canDelete(post)"
              @click="deletePost(post.id)"
              class="p-2 rounded-lg text-zinc-600 hover:text-red-400 hover:bg-red-500/10 transition-all"
            >
              <Trash2 :size="16" />
            </button>
          </div>

          <!-- Content -->
          <div class="text-zinc-200 text-sm leading-relaxed whitespace-pre-wrap mb-4" v-html="linkify(post.content)"></div>

          <!-- Reactions -->
          <div class="flex items-center gap-2 flex-wrap">
            <button
              v-for="(emoji, type) in reactionEmojis"
              :key="type"
              @click="toggleReaction(post.id, type)"
              class="reaction-btn"
              :class="hasReacted(post, type) ? 'reaction-btn-active' : 'reaction-btn-idle'"
            >
              <span>{{ emoji.icon }}</span>
              <span v-if="reactionCount(post, type) > 0" class="text-xs">{{ reactionCount(post, type) }}</span>
            </button>

            <div class="flex-1"></div>

            <!-- Comment toggle -->
            <button
              @click="toggleComments(post.id)"
              class="flex items-center gap-1.5 text-zinc-500 hover:text-zinc-300 transition-colors text-sm"
            >
              <MessageCircle :size="16" />
              <span>{{ post.comments.length }}</span>
              <component :is="expandedComments.has(post.id) ? ChevronUp : ChevronDown" :size="14" />
            </button>
          </div>

          <!-- Comments section -->
          <div v-if="expandedComments.has(post.id)" class="mt-4 pt-4 border-t border-white/5">
            <div v-for="comment in post.comments" :key="comment.id" class="flex items-start gap-2.5 mb-3">
              <div class="w-7 h-7 rounded-full flex items-center justify-center flex-shrink-0 text-white font-bold text-[10px]"
                   :class="comment.profile?.role === 'admin' ? 'bg-gradient-to-br from-red-500 to-orange-500' : 'bg-zinc-700'">
                {{ (comment.profile?.full_name || 'U')[0].toUpperCase() }}
              </div>
              <div class="flex-1 min-w-0">
                <div class="flex items-center gap-2">
                  <span class="font-semibold text-white text-xs">{{ comment.profile?.full_name || 'Utilizator' }}</span>
                  <span v-if="comment.profile?.role === 'admin'" class="text-[9px] font-bold uppercase tracking-wider px-1 py-0.5 rounded bg-red-500/15 text-red-400">Coach</span>
                  <span class="text-[10px] text-zinc-600">{{ timeAgo(comment.created_at) }}</span>
                </div>
                <p class="text-sm text-zinc-300 mt-0.5">{{ comment.content }}</p>
              </div>
              <button
                v-if="comment.user_id === auth.user.id || auth.isAdmin"
                @click="deleteComment(comment.id)"
                class="p-1 rounded text-zinc-700 hover:text-red-400 transition-colors"
              >
                <Trash2 :size="12" />
              </button>
            </div>

            <!-- Add comment -->
            <div class="flex items-center gap-2 mt-3">
              <input
                v-model="commentTexts[post.id]"
                @keydown.enter="addComment(post.id)"
                placeholder="Scrie un comentariu..."
                class="comment-input"
              />
              <button
                @click="addComment(post.id)"
                :disabled="!commentTexts[post.id]?.trim()"
                class="p-2 rounded-lg text-zinc-500 hover:text-red-400 hover:bg-red-500/10 transition-all disabled:opacity-30"
              >
                <Send :size="16" />
              </button>
            </div>
          </div>
        </div>
      </div>

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
    radial-gradient(ellipse 50% 40% at 80% 50%, rgba(249, 115, 22, 0.05), transparent 50%);
  pointer-events: none;
  z-index: 0;
}

.page-content {
  position: relative;
  z-index: 1;
  max-width: 700px;
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
  font-size: 3rem;
  letter-spacing: 0.05em;
  color: white;
  line-height: 1;
}

.post-composer {
  background: rgba(17, 17, 19, 0.7);
  border: 1px solid rgba(255, 255, 255, 0.06);
  border-radius: 20px;
  padding: 1.25rem;
}

.post-textarea {
  width: 100%;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.06);
  border-radius: 12px;
  padding: 0.875rem 1rem;
  color: white;
  font-size: 0.875rem;
  resize: none;
  outline: none;
  font-family: 'Inter', sans-serif;
  transition: border-color 0.15s;
}

.post-textarea:focus {
  border-color: rgba(239, 68, 68, 0.3);
}

.post-textarea::placeholder {
  color: #52525b;
}

.post-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.625rem 1.25rem;
  border-radius: 12px;
  background: linear-gradient(135deg, #ef4444, #f97316);
  color: white;
  font-size: 0.8125rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border: none;
  cursor: pointer;
  transition: all 0.15s;
}

.post-btn:hover {
  opacity: 0.9;
  transform: translateY(-1px);
}

.post-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
  transform: none;
}

.post-card {
  background: rgba(17, 17, 19, 0.7);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 20px;
  padding: 1.25rem;
}

.reaction-btn {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  padding: 0.375rem 0.625rem;
  border-radius: 20px;
  border: 1px solid transparent;
  cursor: pointer;
  transition: all 0.15s;
  font-size: 0.875rem;
  background: none;
}

.reaction-btn-idle {
  border-color: rgba(255, 255, 255, 0.06);
  color: #71717a;
}

.reaction-btn-idle:hover {
  border-color: rgba(255, 255, 255, 0.12);
  background: rgba(255, 255, 255, 0.03);
}

.reaction-btn-active {
  border-color: rgba(239, 68, 68, 0.3);
  background: rgba(239, 68, 68, 0.08);
  color: white;
}

.comment-input {
  flex: 1;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.06);
  border-radius: 10px;
  padding: 0.625rem 0.875rem;
  color: white;
  font-size: 0.8125rem;
  outline: none;
  font-family: 'Inter', sans-serif;
}

.comment-input:focus {
  border-color: rgba(239, 68, 68, 0.25);
}

.comment-input::placeholder {
  color: #3f3f46;
}
</style>
