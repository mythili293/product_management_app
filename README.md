# Product Management App

Flutter inventory and purchasing app wired for Supabase authentication and data.

## What is in place

- Supabase auth with email/password
- Google OAuth sign-in flow
- Persistent user profiles with `user` and `admin` roles
- Product inventory stored in Supabase
- Purchase history stored in Supabase
- Admin inventory activity/history stored in Supabase
- Mobile redirect URL setup for Supabase auth callbacks

## Supabase setup

1. Create a Supabase project.
2. In the Supabase SQL editor, run the migration files in order:
   [`supabase/migrations/20260423_initial_schema.sql`](supabase/migrations/20260423_initial_schema.sql)
   [`supabase/migrations/20260424_add_is_available.sql`](supabase/migrations/20260424_add_is_available.sql)
3. In `Authentication -> Sign In / Providers`, enable:
   - Email
   - Google
4. In `Authentication -> URL Configuration`, add this redirect URL:

```text
productmanagementapp://login-callback/
```

5. Promote at least one user to admin after signup:

```sql
update public.profiles
set role = 'admin'
where email = 'your-admin@email.com';
```

## Run the app

Preferred:

```bash
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=your_publishable_key
```

Legacy key name also works:

```bash
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your_publishable_key
```

## Deploy to Vercel

This repo is ready for Vercel Flutter web deployment.

1. Push the repository to GitHub, GitLab, or Bitbucket.
2. Import the project in Vercel.
3. Keep the framework preset as `Other`.
4. Vercel will use [`vercel.json`](vercel.json):
   - Build command: `bash scripts/vercel-build.sh`
   - Output directory: `build/web`
5. Add these Vercel environment variables:

```text
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_PUBLISHABLE_KEY=your_publishable_key
```

`SUPABASE_ANON_KEY` is also supported for older Supabase projects, but prefer
`SUPABASE_PUBLISHABLE_KEY` for new deployments.

Optional:

```text
FLUTTER_VERSION=stable
```

After Vercel gives you a production URL, add it in Supabase under
`Authentication -> URL Configuration`:

```text
Site URL: https://your-vercel-domain.vercel.app
Redirect URLs:
https://your-vercel-domain.vercel.app/**
```

## Notes

- Admin users are routed to the inventory dashboard.
- Regular users are routed to the store and personal purchases flow.
- The app now treats `is_available` as part of the required product schema.
- If you change the mobile redirect scheme, update the native platform files too.
- Android, iOS, and macOS callback wiring is included in this repo. If you ship Windows or Linux desktop OAuth callbacks, add OS-level custom protocol registration for `productmanagementapp://`.



admin quey:

UPDATE public.profiles
SET role = 'admin'
WHERE email = 'your-email@example.com';
