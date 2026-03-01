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

const labels = { 1: 'Slab', 2: 'Acceptabil', 3: 'OK', 4: 'Bine', 5: 'Excelent' }
const colors = { 1: 'text-red-400', 2: 'text-orange-400', 3: 'text-yellow-400', 4: 'text-lime-400', 5: 'text-green-400' }

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

    <main class="max-w-2xl mx-auto px-4 pt-24 pb-16">

      <button @click="router.back()" class="flex items-center gap-2 text-sm text-gray-500 hover:text-white transition-colors mb-8 group">
        <ArrowLeft :size="16" class="group-hover:-translate-x-1 transition-transform" /> Înapoi
      </button>

      <!-- Success -->
      <div v-if="submitted" class="text-center py-16">
        <div class="w-16 h-16 rounded-full mx-auto mb-6 flex items-center justify-center"
             style="background: rgba(239,68,68,0.1); border: 1px solid rgba(239,68,68,0.3);">
          <CheckCircle :size="32" class="text-red-400" />
        </div>
        <h2 class="text-3xl font-['Bebas_Neue'] tracking-wide text-white mb-2">Check-in trimis!</h2>
        <p class="text-gray-400 text-sm mb-8">Radu va analiza raportul tău. Continuă tot așa! 💪</p>
        <button @click="router.push('/')" class="px-6 py-3 rounded-xl text-sm font-semibold text-white"
                style="background: linear-gradient(135deg, #ef4444, #f97316)">
          Înapoi la Dashboard
        </button>
      </div>

      <!-- Form -->
      <div v-else>
        <p class="text-xs font-semibold uppercase tracking-[0.3em] text-red-500 mb-2">Raport săptămânal</p>
        <h1 class="text-4xl font-['Bebas_Neue'] tracking-wide text-white mb-8">Check-in</h1>

        <form @submit.prevent="submit" class="space-y-6">

          <!-- Weight -->
          <div class="bg-[#111] border border-white/5 rounded-xl p-5">
            <label class="block text-xs font-semibold uppercase tracking-widest text-gray-400 mb-3">Greutate (kg)</label>
            <input
              v-model="form.weight"
              type="number"
              step="0.1"
              placeholder="ex: 75.5"
              class="w-full px-4 py-3 rounded-xl bg-[#1a1a1a] border border-white/8 text-white placeholder-gray-600 text-sm outline-none focus:border-red-500/50 transition-all"
            />
          </div>

          <!-- Sliders -->
          <div class="bg-[#111] border border-white/5 rounded-xl p-5 space-y-6">
            <p class="text-xs font-semibold uppercase tracking-widest text-gray-400">Evaluare săptămână</p>

            <div v-for="(field, key) in { energy: 'Nivel energie', sleep: 'Calitate somn', nutrition: 'Aderență nutriție', training: 'Aderență antrenament' }" :key="key">
              <div class="flex items-center justify-between mb-2">
                <label class="text-sm font-medium text-white">{{ field }}</label>
                <span class="text-sm font-bold" :class="colors[form[key]]">{{ labels[form[key]] }}</span>
              </div>
              <div class="flex gap-2">
                <button
                  v-for="n in 5"
                  :key="n"
                  type="button"
                  class="flex-1 py-2.5 rounded-lg text-sm font-bold transition-all border"
                  :class="form[key] === n
                    ? 'border-transparent text-white'
                    : 'border-white/8 text-gray-600 hover:border-white/20 hover:text-gray-400'"
                  :style="form[key] === n ? 'background: linear-gradient(135deg, #ef4444, #f97316)' : ''"
                  @click="form[key] = n"
                >{{ n }}</button>
              </div>
            </div>
          </div>

          <!-- Text fields -->
          <div class="bg-[#111] border border-white/5 rounded-xl p-5 space-y-5">
            <p class="text-xs font-semibold uppercase tracking-widest text-gray-400">Reflecții</p>

            <div>
              <label class="block text-sm font-medium text-white mb-2">Victoriile săptămânii 🏆</label>
              <textarea
                v-model="form.wins"
                rows="2"
                placeholder="Ce a mers bine săptămâna asta?"
                class="w-full px-4 py-3 rounded-xl bg-[#1a1a1a] border border-white/8 text-white placeholder-gray-600 text-sm outline-none focus:border-red-500/50 transition-all resize-none"
              ></textarea>
            </div>

            <div>
              <label class="block text-sm font-medium text-white mb-2">Provocări 🤔</label>
              <textarea
                v-model="form.challenges"
                rows="2"
                placeholder="Ce a fost dificil sau ce poți îmbunătăți?"
                class="w-full px-4 py-3 rounded-xl bg-[#1a1a1a] border border-white/8 text-white placeholder-gray-600 text-sm outline-none focus:border-red-500/50 transition-all resize-none"
              ></textarea>
            </div>

            <div>
              <label class="block text-sm font-medium text-white mb-2">Note suplimentare</label>
              <textarea
                v-model="form.notes"
                rows="3"
                placeholder="Orice altceva vrei să îi spui lui Radu..."
                class="w-full px-4 py-3 rounded-xl bg-[#1a1a1a] border border-white/8 text-white placeholder-gray-600 text-sm outline-none focus:border-red-500/50 transition-all resize-none"
              ></textarea>
            </div>
          </div>

          <div v-if="error" class="text-sm text-red-400 bg-red-500/10 border border-red-500/20 rounded-xl px-4 py-3">
            ⚠ {{ error }}
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="w-full flex items-center justify-center gap-2 py-4 rounded-xl font-bold text-white text-sm tracking-wide transition-all disabled:opacity-50"
            style="background: linear-gradient(135deg, #ef4444, #f97316);"
          >
            <Send :size="16" />
            {{ loading ? 'Se trimite...' : 'Trimite Check-in' }}
          </button>
        </form>
      </div>
    </main>
  </div>
</template>
