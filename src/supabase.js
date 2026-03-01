import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://erfcmpccobjwtjutwmba.supabase.co'
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVyZmNtcGNjb2Jqd3RqdXR3bWJhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIzNjY1MjksImV4cCI6MjA4Nzk0MjUyOX0.wVzBU77Z-oCRKT_Hksgoxp1A4CR8bRcGbSrkwVRAiUs'

export const supabase = createClient(supabaseUrl, supabaseKey)
