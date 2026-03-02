<script setup>
import { ref } from 'vue'
import { supabase } from '@/supabase.js'
import { useAuthStore } from '@/stores/auth.js'
import { useRouter } from 'vue-router'
import AppNav from '@/components/layout/AppNav.vue'
import { ArrowLeft, Send, CheckCircle } from 'lucide-vue-next'

const auth = useAuthStore()
const router = useRouter()
const submitted = ref(false)
const loading = ref(false)
const error = ref('')

const form = ref({
  weight: '',
  energy: 3,
  sleep: 3,
  nutrition: 3,
  training: 3,
  notes: '',
  wins: '',
  challenges: ''
})

const scoreLabels = { 1: 'Slab', 2: 'Acceptabil', 3: 'OK', 4: 'Bine', 5: 'Excelent' }
const scoreColors = {
  1: { active: '#ef4444', bg: 'rgba(239,68,68,0.15)', border: 'rgba(239,68,68,0.4)' },
  2: { active: '#f97316', bg: 'rgba(249,115,22,0.15)', border: 'rgba(249,115,22,0.4)' },
  3: { active: '#eab308', bg: 'rgba(234,179,8,0.15)', border: 'rgba(234,179,8,0.4)' },
  4: { active: '#84cc16', bg: 'rgba(132,204,22,0.15)', border: 'rgba(132,204,22,0.4)' },
  5: { active: '#22c55e', bg: 'rgba(34,197,94,0.15)', border: 'rgba(34,197,94,0.4)' },
}

async function submit() {
  loading.value = true
  error.value = ''
  try {
    const { error: err } = await supabase.from('checkins').insert({
      client_id: auth.user.id,
      weight: form.value.weight ? parseFloat(form.value.weight) : null,
      energy_level: form.value.energy,
      sleep_quality: form.value.sleep,
      nutrition_adherence: form.value.nutrition,
      training_adherence: form.value.training,
      notes: form.value.notes,
      wins: form.value.wins,
      challenges: form.value.challenges
    })
    if (err) throw err
    submitted.value = true
  } catch (e) {
    error.value = 'Eroare la trimitere. Încearcă din nou.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen bg-[#0a0a0a]">
    <AppNav />

    <main class="max-w-2xl mx-auto px-5 pt-4 pb-8">

      <!-- Success -->
      <div v-if="submitted" class="flex flex-col items-center justify-center py-20 text-center">
        <div class="w-20 h-20 rounded-full mx-auto mb-6 flex items-center justify-center"
             style="background: rgba(34,197,94,0.12); border: 2px solid rgba(34,197,94,0.3);">
          <CheckCircle :size="40" class="text-green-400" />
        </div>
        <h2 class="text-4xl font-['Bebas_Neue'] tracking-wide text-white mb-3">Check-in trimis!</h2>
        <p class="text-gray-400 text-base mb-10 max-w-xs">Radu va analiza raportul tău. Continuă tot așa! 💪</p>
        <button @click="router.push('/')"
                class="w-full max-w-xs py-4 rounded-2xl text-base font-bold text-white active:scale-[0.98] transition-transform"
                style="background: linear-gradient(135deg, #ef4444, #f97316)">
          Înapoi la Dashboard
        </button>
      </div>

      <!-- Form -->
      <div v-else>

        <!-- Header -->
        <button @click="router.back()" class="flex items-center gap-2 text-sm text-gray-500 hover:text-white transition-colors mb-6">
          <ArrowLeft :size="16" /> Înapoi
        </button>

        <p class="text-xs font-bold uppercase tracking-[0.3em] text-red-500 mb-1">Raport săptămânal</p>
        <h1 class="text-5xl font-['Bebas_Neue'] tracking-wide text-white mb-8">Check-in</h1>

        <form @submit.prevent="submit" class="space-y-5">

          <!-- Weight -->
          <div class="bg-[#111] border border-white/5 rounded-2xl p-5">
            <label class="block text-sm font-bold text-gray-300 mb-3">Greutate (kg)</label>
            <input
              v-model="form.weight"
              type="number"
              step="0.1"
              inputmode="decimal"
              placeholder="ex: 75.5"
              class="w-full px-5 py-4 rounded-xl bg-[#1a1a1a] border border-white/8 text-white placeholder-gray-600 text-lg outline-none focus:border-red-500/50 transition-all"
            />
          </div>

          <!-- Score sections -->
          <div class="bg-[#111] border border-white/5 rounded-2xl p-5 space-y-7">
            <p class="text-xs font-bold uppercase tracking-widest text-gray-400">Evaluare săptămână</p>

            <div
              v-for="(label, key) in {
                energy: '⚡ Energie',
                sleep: '🌙 Somn',
                nutrition: '🥗 Nutriție',
                training: '💪 Antrenament'
              }"
              :key="key"
            >
              <div class="flex items-center justify-between mb-3">
                <span class="text-base font-semibold text-white">{{ label }}</span>
                <span class="text-sm font-bold" :style="`color: ${scoreColors[form[key]].active}`">
                  {{ scoreLabels[form[key]] }}
                </span>
              </div>
              <div class="flex gap-2">
                <button
                  v-for="n in 5"
                  :key="n"
                  type="button"
                  class="flex-1 py-3.5 rounded-xl text-base font-bold transition-all border"
                  :style="form[key] === n
                    ? `background: ${scoreColors[n].bg}; border-color: ${scoreColors[n].border}; color: ${scoreColors[n].active}`
                    : 'background: transparent; border-color: rgba(255,255,255,0.08); color: rgba(156,163,175,1)'"
                  @click="form[key] = n"
                >{{ n }}</button>
              </div>
            </div>
          </div>

          <!-- Reflections -->
          <div class="bg-[#111] border border-white/5 rounded-2xl p-5 space-y-5">
            <p class="text-xs font-bold uppercase tracking-widest text-gray-400">Reflecții</p>

            <div>
              <label class="block text-base font-semibold text-white mb-2">Victoriile săptămânii 🏆</label>
              <textarea
                v-model="form.wins"
                rows="3"
                placeholder="Ce a mers bine săptămâna asta?"
                class="w-full px-4 py-3.5 rounded-xl bg-[#1a1a1a] border border-white/8 text-white placeholder-gray-600 text-base outline-none focus:border-red-500/50 transition-all resize-none"
              ></textarea>
            </div>

            <div>
              <label class="block text-base font-semibold text-white mb-2">Provocări 🤔</label>
              <textarea
                v-model="form.challenges"
                rows="3"
                placeholder="Ce a fost dificil sau ce poți îmbunătăți?"
                class="w-full px-4 py-3.5 rounded-xl bg-[#1a1a1a] border border-white/8 text-white placeholder-gray-600 text-base outline-none focus:border-red-500/50 transition-all resize-none"
              ></textarea>
            </div>

            <div>
              <label class="block text-base font-semibold text-white mb-2">Note pentru Radu</label>
              <textarea
                v-model="form.notes"
                rows="3"
                placeholder="Orice altceva vrei să îi spui lui Radu..."
                class="w-full px-4 py-3.5 rounded-xl bg-[#1a1a1a] border border-white/8 text-white placeholder-gray-600 text-base outline-none focus:border-red-500/50 transition-all resize-none"
              ></textarea>
            </div>
          </div>

          <div v-if="error" class="text-sm text-red-400 bg-red-500/10 border border-red-500/20 rounded-2xl px-4 py-4">
            ⚠ {{ error }}
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="w-full flex items-center justify-center gap-3 py-4 rounded-2xl font-bold text-white text-base tracking-wide transition-all disabled:opacity-50 active:scale-[0.98]"
            style="background: linear-gradient(135deg, #ef4444, #f97316);"
          >
            <Send :size="18" />
            {{ loading ? 'Se trimite...' : 'Trimite Check-in' }}
          </button>

        </form>
      </div>
    </main>
  </div>
</template>
