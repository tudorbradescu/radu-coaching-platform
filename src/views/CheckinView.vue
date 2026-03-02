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
  // Antrenament
  training_adherence: null,
  exercise_difficulties: '',
  // Nutriție
  nutrition_adherence: null,
  nutrition_notes: '',
  alcohol: '',
  // Bunăstare
  energy_level: null,
  appetite: '',
  sleep_quality: null,
  digestion: '',
  stress_level: '',
  daily_steps: '',
  // Câștiguri
  wins: '',
  // Perspectivă
  next_period_focus: '',
  group_call_topics: '',
  checkin_format: '',
  coach_support: '',
})

// Adherence options (stored as 5/4/3/2/1)
const adherenceOptions = [
  { label: 'Foarte bun', value: 5 },
  { label: 'Bun', value: 4 },
  { label: 'Mediu', value: 3 },
  { label: 'Slab', value: 2 },
  { label: 'Foarte slab', value: 1 },
]

// Energy (stored as 5/3/1)
const energyOptions = [
  { label: '⬆️ Crescut', value: 5 },
  { label: '➡️ Moderat', value: 3 },
  { label: '⬇️ Scăzut', value: 1 },
]

// Appetite (text)
const appetiteOptions = [
  { label: '🍽️ Mare / foame constantă', value: 'mare' },
  { label: '😐 Moderat', value: 'moderat' },
  { label: '🙅 Scăzut / rar foame', value: 'scazut' },
]

// Sleep / Digestion (stored as 5/4/3/2/1)
const qualityOptions = [
  { label: 'Foarte bun', value: 5 },
  { label: 'Bun', value: 4 },
  { label: 'Mediu', value: 3 },
  { label: 'Destul de slab', value: 2 },
  { label: 'Slab', value: 1 },
]

// Stress (text)
const stressOptions = [
  { label: '🔴 Foarte mare', value: 'foarte_mare' },
  { label: '🟠 Mare', value: 'mare' },
  { label: '🟡 Mediu', value: 'mediu' },
  { label: '🟢 Scăzut/minimal', value: 'scazut' },
]

// Check-in format (text)
const formatOptions = [
  { label: '🎙️ Mesaj vocal', value: 'voice' },
  { label: '🎥 Înregistrare video', value: 'vimeo' },
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
    error.value = 'Eroare la trimitere. Încearcă din nou.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen bg-[#0a0a0a]">
    <AppNav />

    <main class="max-w-2xl mx-auto px-5 pt-4 pb-28 sm:pb-10">

      <!-- Success -->
      <div v-if="submitted" class="flex flex-col items-center justify-center py-20 text-center">
        <div class="w-24 h-24 rounded-full mx-auto mb-6 flex items-center justify-center"
             style="background: rgba(34,197,94,0.12); border: 2px solid rgba(34,197,94,0.3);">
          <CheckCircle :size="48" class="text-green-400" />
        </div>
        <h2 class="text-5xl font-['Bebas_Neue'] tracking-wide text-white mb-3">Check-in trimis!</h2>
        <p class="text-gray-400 text-base mb-10 max-w-xs">Radu va analiza raportul tău. Continuă tot așa! 💪</p>
        <button @click="router.push('/')"
                class="w-full max-w-xs py-4 rounded-2xl text-base font-bold text-white active:scale-[0.98] transition-transform"
                style="background: linear-gradient(135deg, #ef4444, #f97316)">
          Înapoi la Dashboard
        </button>
      </div>

      <!-- Form -->
      <form v-else @submit.prevent="submit" class="space-y-5">

        <button type="button" @click="router.back()" class="flex items-center gap-2 text-sm text-gray-500 hover:text-white transition-colors mb-2">
          <ArrowLeft :size="16" /> Înapoi
        </button>

        <div>
          <p class="text-xs font-bold uppercase tracking-[0.3em] text-red-500 mb-1">Raport săptămânal</p>
          <h1 class="text-5xl font-['Bebas_Neue'] tracking-wide text-white mb-1">Check-in</h1>
          <p class="text-sm text-gray-500">Completează toate secțiunile cu sinceritate.</p>
        </div>

        <!-- ── GREUTATE ── -->
        <section class="card">
          <p class="section-label">📊 Date de bază</p>
          <label class="field-label">Greutate (kg)</label>
          <input v-model="form.weight" type="number" step="0.1" inputmode="decimal"
            placeholder="ex: 75.5" class="field-input" />
        </section>

        <!-- ── CEL MAI MARE CÂȘTIG ── -->
        <section class="card">
          <p class="section-label">🏆 Câștigul săptămânii</p>
          <label class="field-label">Care a fost cea mai mare victorie / satisfacție din săptămâna trecută?</label>
          <textarea v-model="form.wins" rows="3" placeholder="Descrie victoria ta..." class="field-input resize-none"></textarea>
        </section>

        <!-- ── ANTRENAMENT ── -->
        <section class="card space-y-5">
          <p class="section-label">💪 Antrenament</p>

          <div>
            <label class="field-label">Aderența la planul de antrenament această săptămână?</label>
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
            <label class="field-label">Dificultăți întâmpinate la exerciții?</label>
            <textarea v-model="form.exercise_difficulties" rows="3"
              placeholder="Ex: durere la genunchi, oboseală excesivă..." class="field-input resize-none"></textarea>
          </div>
        </section>

        <!-- ── NUTRIȚIE ── -->
        <section class="card space-y-5">
          <p class="section-label">🥗 Nutriție</p>

          <div>
            <label class="field-label">Aderența la planul de nutriție această săptămână?</label>
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
            <label class="field-label">Ce a mers bine cu nutriția? Ce nu? Ce poate fi îmbunătățit?</label>
            <textarea v-model="form.nutrition_notes" rows="3"
              placeholder="Fii specific — mese, porții, momente ale zilei..." class="field-input resize-none"></textarea>
          </div>

          <div>
            <label class="field-label">Ai consumat alcool această săptămână? Dacă da, ce și cât?</label>
            <textarea v-model="form.alcohol" rows="2"
              placeholder="Ex: 2 beri vineri seară, sau Nu" class="field-input resize-none"></textarea>
          </div>
        </section>

        <!-- ── BUNĂSTARE ── -->
        <section class="card space-y-5">
          <p class="section-label">⚡ Bunăstare</p>

          <!-- Energy -->
          <div>
            <label class="field-label">Nivel de energie această săptămână?</label>
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
            <label class="field-label">Nivel de apetit această săptămână?</label>
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
            <label class="field-label">Calitatea somnului această săptămână?</label>
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
            <label class="field-label">Calitatea digestiei această săptămână?</label>
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
            <label class="field-label">Nivel de stres zilnic această săptămână?</label>
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
            <label class="field-label">Realizarea obiectivului de pași zilnici?</label>
            <input v-model="form.daily_steps" type="text"
              placeholder="Ex: 8.000 pași / zi, sau 70% din obiectiv" class="field-input" />
          </div>
        </section>

        <!-- ── PERSPECTIVĂ ── -->
        <section class="card space-y-5">
          <p class="section-label">🎯 Perspectivă & Planificare</p>

          <div>
            <label class="field-label">Principalul focus pentru perioada următoare cu 2-3 acțiuni concrete?</label>
            <textarea v-model="form.next_period_focus" rows="3"
              placeholder="Ex: 1. Mese pregătite duminică  2. Antrenament luni, joi, sâmbătă  3..." class="field-input resize-none"></textarea>
          </div>

          <div>
            <label class="field-label">Subiecte de discutat la apelurile de grup?</label>
            <textarea v-model="form.group_call_topics" rows="2"
              placeholder="Orice întrebări sau teme pe care vrei să le abordăm..." class="field-input resize-none"></textarea>
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
        <div v-if="error" class="text-sm text-red-400 bg-red-500/10 border border-red-500/20 rounded-2xl px-4 py-4">
          ⚠ {{ error }}
        </div>

        <!-- Submit -->
        <button type="submit" :disabled="loading"
          class="w-full flex items-center justify-center gap-3 py-4 rounded-2xl font-bold text-white text-base tracking-wide transition-all disabled:opacity-50 active:scale-[0.98]"
          style="background: linear-gradient(135deg, #ef4444, #f97316);">
          <Send :size="18" />
          {{ loading ? 'Se trimite...' : 'Trimite Check-in' }}
        </button>

      </form>
    </main>
  </div>
</template>

<style scoped>
.card {
  background: #111;
  border: 1px solid rgba(255,255,255,0.05);
  border-radius: 20px;
  padding: 20px;
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
  background: #1a1a1a;
  border: 1.5px solid rgba(255,255,255,0.08);
  color: white;
  font-size: 16px;
  outline: none;
  transition: border-color 0.2s;
  -webkit-appearance: none;
}

.field-input::placeholder {
  color: rgba(156,163,175,0.45);
}

.field-input:focus {
  border-color: rgba(239,68,68,0.45);
  box-shadow: 0 0 0 3px rgba(239,68,68,0.06);
}

.field-input:-webkit-autofill {
  -webkit-box-shadow: 0 0 0 1000px #1a1a1a inset !important;
  -webkit-text-fill-color: white !important;
}

/* Vertical option list */
.options-grid-v {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

/* Horizontal option list (3 items) */
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
  transition: all 0.15s;
  border: 1.5px solid transparent;
  cursor: pointer;
  flex: 1;
  -webkit-tap-highlight-color: transparent;
}

.option-btn-idle {
  background: #1a1a1a;
  border-color: rgba(255,255,255,0.08);
  color: rgba(156,163,175,1);
}

.option-btn-idle:active {
  background: #222;
}

.option-btn-active {
  font-weight: 700;
}
</style>
