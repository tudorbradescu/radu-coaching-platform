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
  training_adherence: null,
  exercise_difficulties: '',
  nutrition_adherence: null,
  nutrition_notes: '',
  alcohol: '',
  energy_level: null,
  appetite: '',
  sleep_quality: null,
  digestion: '',
  stress_level: '',
  daily_steps: '',
  wins: '',
  next_period_focus: '',
  group_call_topics: '',
  checkin_format: '',
  coach_support: '',
})

const adherenceOptions = [
  { label: 'Foarte bun', value: 5 },
  { label: 'Bun', value: 4 },
  { label: 'Mediu', value: 3 },
  { label: 'Slab', value: 2 },
  { label: 'Foarte slab', value: 1 },
]

const energyOptions = [
  { label: '⬆️ Crescut', value: 5 },
  { label: '➡️ Moderat', value: 3 },
  { label: '⬇️ Scazut', value: 1 },
]

const appetiteOptions = [
  { label: '🍽️ Mare / foame constanta', value: 'mare' },
  { label: '😐 Moderat', value: 'moderat' },
  { label: '🙅 Scazut / rar foame', value: 'scazut' },
]

const qualityOptions = [
  { label: 'Foarte bun', value: 5 },
  { label: 'Bun', value: 4 },
  { label: 'Mediu', value: 3 },
  { label: 'Destul de slab', value: 2 },
  { label: 'Slab', value: 1 },
]

const stressOptions = [
  { label: '🔴 Foarte mare', value: 'foarte_mare' },
  { label: '🟠 Mare', value: 'mare' },
  { label: '🟡 Mediu', value: 'mediu' },
  { label: '🟢 Scazut/minimal', value: 'scazut' },
]

const formatOptions = [
  { label: '🎙️ Mesaj vocal', value: 'voice' },
  { label: '🎥 Inregistrare video', value: 'vimeo' },
  { label: '📞 Apel 1-la-1', value: 'call' },
]

const adherenceColor = { 5: '#22c55e', 4: '#84cc16', 3: '#eab308', 2: '#f97316', 1: '#ef4444' }

async function submit() {
  loading.value = true
  error.value = ''
  try {
    const { error: err } = await supabase.from('checkins').insert({
      client_id: auth.user.id,
      weight: form.value.weight ? parseFloat(form.value.weight) : null,
      training_adherence: form.value.training_adherence,
      exercise_difficulties: form.value.exercise_difficulties,
      nutrition_adherence: form.value.nutrition_adherence,
      nutrition_notes: form.value.nutrition_notes,
      alcohol: form.value.alcohol,
      energy_level: form.value.energy_level,
      appetite: form.value.appetite,
      sleep_quality: form.value.sleep_quality,
      digestion: form.value.digestion,
      stress_level: form.value.stress_level,
      daily_steps: form.value.daily_steps,
      wins: form.value.wins,
      next_period_focus: form.value.next_period_focus,
      group_call_topics: form.value.group_call_topics,
      checkin_format: form.value.checkin_format,
      coach_support: form.value.coach_support,
    })
    if (err) throw err
    submitted.value = true
    window.scrollTo({ top: 0, behavior: 'smooth' })
  } catch (e) {
    error.value = 'Eroare la trimitere. Incearca din nou.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="page-wrapper">
    <div class="page-bg"></div>
    <AppNav />

    <main class="page-content">

      <!-- Success -->
      <div v-if="submitted" class="flex flex-col items-center justify-center py-20 text-center">
        <div class="success-icon">
          <CheckCircle :size="52" class="text-green-400" />
        </div>
        <h2 class="page-title mt-6 mb-3">Check-in trimis!</h2>
        <p class="text-zinc-400 text-base mb-10 max-w-sm">Radu va analiza raportul tau. Continua tot asa! 💪</p>
        <button @click="router.push('/')" class="submit-btn" style="max-width: 320px;">
          Inapoi la Dashboard
        </button>
      </div>

      <!-- Form -->
      <form v-else @submit.prevent="submit" class="space-y-5">

        <button type="button" @click="router.back()" class="flex items-center gap-2 text-sm text-zinc-500 hover:text-white transition-colors mb-2">
          <ArrowLeft :size="16" /> Inapoi
        </button>

        <div>
          <p class="text-xs font-bold uppercase tracking-[0.3em] text-red-500 mb-1">Raport saptamanal</p>
          <h1 class="page-title">Check-in</h1>
          <p class="text-sm text-zinc-500 mt-2">Completeaza toate sectiunile cu sinceritate.</p>
        </div>

        <!-- GREUTATE -->
        <section class="card">
          <p class="section-label">📊 Date de baza</p>
          <label class="field-label">Greutate (kg)</label>
          <input v-model="form.weight" type="number" step="0.1" inputmode="decimal"
            placeholder="ex: 75.5" class="field-input" />
        </section>

        <!-- CEL MAI MARE CASTIG -->
        <section class="card">
          <p class="section-label">🏆 Castigul saptamanii</p>
          <label class="field-label">Care a fost cea mai mare victorie / satisfactie din saptamana trecuta?</label>
          <textarea v-model="form.wins" rows="3" placeholder="Descrie victoria ta..." class="field-input resize-none"></textarea>
        </section>

        <!-- ANTRENAMENT -->
        <section class="card space-y-5">
          <p class="section-label">💪 Antrenament</p>

          <div>
            <label class="field-label">Aderenta la planul de antrenament aceasta saptamana?</label>
            <div class="options-grid-v">
              <button v-for="opt in adherenceOptions" :key="opt.value" type="button"
                class="option-btn"
                :style="form.training_adherence === opt.value
                  ? `background: ${adherenceColor[opt.value]}18; border-color: ${adherenceColor[opt.value]}60; color: ${adherenceColor[opt.value]}`
                  : ''"
                :class="form.training_adherence === opt.value ? 'option-btn-active' : 'option-btn-idle'"
                @click="form.training_adherence = opt.value">
                {{ opt.label }}
              </button>
            </div>
          </div>

          <div>
            <label class="field-label">Dificultati intampinate la exercitii?</label>
            <textarea v-model="form.exercise_difficulties" rows="3"
              placeholder="Ex: durere la genunchi, oboseala excesiva..." class="field-input resize-none"></textarea>
          </div>
        </section>

        <!-- NUTRITIE -->
        <section class="card space-y-5">
          <p class="section-label">🥗 Nutritie</p>

          <div>
            <label class="field-label">Aderenta la planul de nutritie aceasta saptamana?</label>
            <div class="options-grid-v">
              <button v-for="opt in adherenceOptions" :key="opt.value" type="button"
                class="option-btn"
                :style="form.nutrition_adherence === opt.value
                  ? `background: ${adherenceColor[opt.value]}18; border-color: ${adherenceColor[opt.value]}60; color: ${adherenceColor[opt.value]}`
                  : ''"
                :class="form.nutrition_adherence === opt.value ? 'option-btn-active' : 'option-btn-idle'"
                @click="form.nutrition_adherence = opt.value">
                {{ opt.label }}
              </button>
            </div>
          </div>

          <div>
            <label class="field-label">Ce a mers bine cu nutritia? Ce nu? Ce poate fi imbunatatit?</label>
            <textarea v-model="form.nutrition_notes" rows="3"
              placeholder="Fii specific — mese, portii, momente ale zilei..." class="field-input resize-none"></textarea>
          </div>

          <div>
            <label class="field-label">Ai consumat alcool aceasta saptamana? Daca da, ce si cat?</label>
            <textarea v-model="form.alcohol" rows="2"
              placeholder="Ex: 2 beri vineri seara, sau Nu" class="field-input resize-none"></textarea>
          </div>
        </section>

        <!-- BUNASTARE -->
        <section class="card space-y-5">
          <p class="section-label">⚡ Bunastare</p>

          <!-- Energy -->
          <div>
            <label class="field-label">Nivel de energie aceasta saptamana?</label>
            <div class="options-grid-h">
              <button v-for="opt in energyOptions" :key="opt.value" type="button"
                class="option-btn"
                :class="form.energy_level === opt.value ? 'option-btn-active' : 'option-btn-idle'"
                :style="form.energy_level === opt.value ? 'background: rgba(239,68,68,0.15); border-color: rgba(239,68,68,0.5); color: #ef4444' : ''"
                @click="form.energy_level = opt.value">
                {{ opt.label }}
              </button>
            </div>
          </div>

          <!-- Appetite -->
          <div>
            <label class="field-label">Nivel de apetit aceasta saptamana?</label>
            <div class="options-grid-v">
              <button v-for="opt in appetiteOptions" :key="opt.value" type="button"
                class="option-btn"
                :class="form.appetite === opt.value ? 'option-btn-active' : 'option-btn-idle'"
                :style="form.appetite === opt.value ? 'background: rgba(239,68,68,0.15); border-color: rgba(239,68,68,0.5); color: #ef4444' : ''"
                @click="form.appetite = opt.value">
                {{ opt.label }}
              </button>
            </div>
          </div>

          <!-- Sleep -->
          <div>
            <label class="field-label">Calitatea somnului aceasta saptamana?</label>
            <div class="options-grid-v">
              <button v-for="opt in qualityOptions" :key="opt.value" type="button"
                class="option-btn"
                :style="form.sleep_quality === opt.value
                  ? `background: ${adherenceColor[opt.value]}18; border-color: ${adherenceColor[opt.value]}60; color: ${adherenceColor[opt.value]}`
                  : ''"
                :class="form.sleep_quality === opt.value ? 'option-btn-active' : 'option-btn-idle'"
                @click="form.sleep_quality = opt.value">
                {{ opt.label }}
              </button>
            </div>
          </div>

          <!-- Digestion -->
          <div>
            <label class="field-label">Calitatea digestiei aceasta saptamana?</label>
            <div class="options-grid-v">
              <button v-for="opt in qualityOptions" :key="opt.value" type="button"
                class="option-btn"
                :style="form.digestion === opt.value
                  ? `background: ${adherenceColor[opt.value]}18; border-color: ${adherenceColor[opt.value]}60; color: ${adherenceColor[opt.value]}`
                  : ''"
                :class="form.digestion === opt.value ? 'option-btn-active' : 'option-btn-idle'"
                @click="form.digestion = opt.value">
                {{ opt.label }}
              </button>
            </div>
          </div>

          <!-- Stress -->
          <div>
            <label class="field-label">Nivel de stres zilnic aceasta saptamana?</label>
            <div class="options-grid-v">
              <button v-for="opt in stressOptions" :key="opt.value" type="button"
                class="option-btn"
                :class="form.stress_level === opt.value ? 'option-btn-active' : 'option-btn-idle'"
                :style="form.stress_level === opt.value ? 'background: rgba(239,68,68,0.15); border-color: rgba(239,68,68,0.5); color: #ef4444' : ''"
                @click="form.stress_level = opt.value">
                {{ opt.label }}
              </button>
            </div>
          </div>

          <!-- Steps -->
          <div>
            <label class="field-label">Realizarea obiectivului de pasi zilnici?</label>
            <input v-model="form.daily_steps" type="text"
              placeholder="Ex: 8.000 pasi / zi, sau 70% din obiectiv" class="field-input" />
          </div>
        </section>

        <!-- PERSPECTIVA -->
        <section class="card space-y-5">
          <p class="section-label">🎯 Perspectiva & Planificare</p>

          <div>
            <label class="field-label">Principalul focus pentru perioada urmatoare cu 2-3 actiuni concrete?</label>
            <textarea v-model="form.next_period_focus" rows="3"
              placeholder="Ex: 1. Mese pregatite duminica  2. Antrenament luni, joi, sambata  3..." class="field-input resize-none"></textarea>
          </div>

          <div>
            <label class="field-label">Subiecte de discutat la apelurile de grup?</label>
            <textarea v-model="form.group_call_topics" rows="2"
              placeholder="Orice intrebari sau teme pe care vrei sa le abordam..." class="field-input resize-none"></textarea>
          </div>

          <div>
            <label class="field-label">Format preferat pentru check-in?</label>
            <div class="options-grid-v">
              <button v-for="opt in formatOptions" :key="opt.value" type="button"
                class="option-btn"
                :class="form.checkin_format === opt.value ? 'option-btn-active' : 'option-btn-idle'"
                :style="form.checkin_format === opt.value ? 'background: rgba(239,68,68,0.15); border-color: rgba(239,68,68,0.5); color: #ef4444' : ''"
                @click="form.checkin_format = opt.value">
                {{ opt.label }}
              </button>
            </div>
          </div>

          <div>
            <label class="field-label">Ce suport ai nevoie de la Radu pentru obiectivele tale?</label>
            <textarea v-model="form.coach_support" rows="3"
              placeholder="Spune-i lui Radu cum te poate ajuta cel mai bine..." class="field-input resize-none"></textarea>
          </div>
        </section>

        <!-- Error -->
        <div v-if="error" class="text-sm text-red-400 bg-red-500/[0.08] border border-red-500/20 rounded-2xl px-4 py-4">
          ⚠ {{ error }}
        </div>

        <!-- Submit -->
        <button type="submit" :disabled="loading" class="submit-btn">
          <Send :size="18" />
          {{ loading ? 'Se trimite...' : 'Trimite Check-in' }}
        </button>

      </form>
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

.success-icon {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(34, 197, 94, 0.1);
  border: 2px solid rgba(34, 197, 94, 0.25);
}

.card {
  background: rgba(17, 17, 19, 0.7);
  border: 1px solid rgba(255, 255, 255, 0.06);
  border-radius: 20px;
  padding: 1.5rem;
  isolation: isolate;
}

@media (min-width: 640px) {
  .card {
    padding: 1.75rem;
  }
}

.section-label {
  font-size: 11px;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 0.25em;
  color: #ef4444;
  margin-bottom: 16px;
}

.field-label {
  display: block;
  font-size: 15px;
  font-weight: 600;
  color: white;
  margin-bottom: 10px;
  line-height: 1.4;
}

.field-input {
  width: 100%;
  padding: 14px 16px;
  border-radius: 14px;
  background: rgba(9, 9, 11, 0.6);
  border: 1.5px solid rgba(255, 255, 255, 0.08);
  color: white;
  font-size: 16px;
  outline: none;
  transition: border-color 0.2s, box-shadow 0.2s;
  -webkit-appearance: none;
}

.field-input::placeholder {
  color: rgba(156, 163, 175, 0.4);
}

.field-input:focus {
  border-color: rgba(239, 68, 68, 0.4);
  box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.08);
}

.field-input:-webkit-autofill {
  -webkit-box-shadow: 0 0 0 1000px #111113 inset !important;
  -webkit-text-fill-color: white !important;
}

.options-grid-v {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.options-grid-h {
  display: flex;
  gap: 8px;
}

.option-btn {
  padding: 12px 16px;
  border-radius: 12px;
  font-size: 14px;
  font-weight: 600;
  text-align: left;
  transition: background-color 0.15s, border-color 0.15s, color 0.15s;
  border: 1.5px solid transparent;
  cursor: pointer;
  flex: 1;
  -webkit-tap-highlight-color: transparent;
  position: relative;
  z-index: 0;
}

.option-btn-idle {
  background: rgba(26, 26, 26, 0.8);
  border-color: rgba(255, 255, 255, 0.08);
  color: rgba(156, 163, 175, 1);
}

.option-btn-idle:hover {
  background: rgba(34, 34, 34, 0.8);
}

.option-btn-active {
  font-weight: 700;
}

.submit-btn {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.75rem;
  padding: 1rem 1.5rem;
  border-radius: 16px;
  font-weight: 700;
  font-size: 1rem;
  color: white;
  background: linear-gradient(135deg, #ef4444, #f97316);
  border: none;
  cursor: pointer;
  transition: all 0.2s;
  letter-spacing: 0.02em;
  box-shadow: 0 4px 20px rgba(239, 68, 68, 0.25);
}

.submit-btn:hover {
  box-shadow: 0 6px 28px rgba(239, 68, 68, 0.35);
  transform: translateY(-1px);
}

.submit-btn:active {
  transform: scale(0.98);
}

.submit-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}
</style>
