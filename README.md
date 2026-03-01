# Radu Coaching Platform

Platformă privată de online coaching pentru Radu Mocuța.

## Setup în 5 pași

### 1. Creează proiect Supabase
- Intră pe [supabase.com](https://supabase.com) → New project
- Copiază `Project URL` și `anon public key` din Settings → API

### 2. Configurează variabilele de mediu
```bash
cp .env.example .env
```
Editează `.env`:
```
VITE_SUPABASE_URL=https://xxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...
```

### 3. Rulează schema SQL
- În Supabase → SQL Editor → copiază conținutul din `supabase_schema.sql` → Run

### 4. Creează contul de admin
- Supabase → Authentication → Users → Invite user (email Radu)
- Supabase → Table Editor → profiles → editează row-ul lui Radu → role = `admin`

### 5. Rulează local
```bash
npm install
npm run dev
```

## Deploy pe Vercel (gratuit)
1. Push repo pe GitHub
2. vercel.com → Import repo
3. Adaugă variabilele de mediu din `.env`
4. Deploy!

## Structura platformei

| Pagină | URL | Acces |
|--------|-----|-------|
| Login | `/login` | Public |
| Dashboard client | `/` | Client |
| Modul + videouri | `/modul/:id` | Client (dacă e atribuit) |
| Check-in săptămânal | `/checkin` | Client |
| Admin dashboard | `/admin` | Radu |
| Admin clienți | `/admin/clienti` | Radu |
| Admin module | `/admin/module` | Radu |

## Costuri lunare
- Supabase: GRATUIT (free tier)
- Vercel: GRATUIT (free tier)
- Domeniu: ~20 RON/lună
- Vimeo: deja plătit
- **Total: ~20 RON/lună**
