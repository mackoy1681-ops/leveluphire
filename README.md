# LevelUpHire

> Your career, leveled up. — Practice interviews, take assessments, and build stunning resumes.

## Tech Stack
- **Flutter** (latest stable) + Dart
- **Supabase** — Auth, PostgreSQL, Storage
- **Google Gemini 1.5 Flash** — AI question generation & feedback
- **Riverpod** — State management
- **pdf + printing** — PDF resume export

## Setup

### 1. Add API keys to `.env`

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
GEMINI_API_KEY=your-gemini-api-key-here
```

### 2. Place logo

Copy your logo to:
```
assets/images/logo1.png
```

### 3. Install dependencies
```bash
flutter pub get
```

### 4. Run
```bash
flutter run
```

## Supabase Database Setup

Run these SQL statements in your Supabase SQL editor:

```sql
-- profiles
create table profiles (
  id uuid references auth.users primary key,
  display_name text,
  username text unique,
  bio text,
  location text,
  website text,
  avatar_url text,
  is_profile_complete boolean default false,
  assessments_taken int default 0,
  interviews_completed int default 0,
  resumes_created int default 0,
  created_at timestamptz default now()
);

-- resumes
create table resumes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id),
  title text,
  template_id text,
  data jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- assessment_results
create table assessment_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id),
  topic text,
  score int,
  total int,
  taken_at timestamptz default now()
);

-- interview_sessions
create table interview_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id),
  field text,
  history jsonb,
  completed_at timestamptz default now()
);

-- notifications
create table notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id),
  message text,
  is_read boolean default false,
  created_at timestamptz default now()
);
```

### Enable RLS
```sql
alter table profiles enable row level security;
alter table resumes enable row level security;
alter table assessment_results enable row level security;
alter table interview_sessions enable row level security;
alter table notifications enable row level security;

-- Example RLS policy (repeat for all tables)
create policy "Users can manage own data" on profiles
  for all using (auth.uid() = id);
```

**Important:** A single `FOR ALL USING (...)` policy on `profiles` often fails for **inserts/upserts** in subtle ways. If saving the profile never creates a row, run the SQL in [`supabase/profiles_rls_and_trigger.sql`](supabase/profiles_rls_and_trigger.sql) in the Supabase SQL editor. It adds explicit INSERT/UPDATE policies and a trigger so every `auth.users` row gets a matching `profiles` row (plus a one-time backfill for existing users).

### Storage Bucket
Create a **public** bucket named `resume_photos` in Supabase Storage (the app uploads avatars there). You can use another bucket name, but then update the `from('…')` calls in the Flutter code to match.

## Features
- ✅ Email + Google Sign-In
- ✅ Profile setup & editing
- ✅ Resume builder with **5 templates** (Classic, Modern Blue, Two Column, Minimalist, Dark Accent)
- ✅ PDF export + share sheet
- ✅ AI-powered assessment (10 MCQ questions via Gemini)
- ✅ AI-powered interview practice with real-time feedback
- ✅ Notification center
- ✅ Twitter/X-style dark UI with floating bottom nav

## Notes
- Google Sign-In requires `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- Voice input is scaffolded with a placeholder button (coming soon)
- All API keys are loaded from `.env` — never commit `.env` to git
