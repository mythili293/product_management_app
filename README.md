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
2. In the Supabase SQL editor, run [`supabase/migrations/20260423_initial_schema.sql`](supabase/migrations/20260423_initial_schema.sql).
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

## Notes

- Admin users are routed to the inventory dashboard.
- Regular users are routed to the store and personal purchases flow.
- If you change the mobile redirect scheme, update the native platform files too.
- Android, iOS, and macOS callback wiring is included in this repo. If you ship Windows or Linux desktop OAuth callbacks, add OS-level custom protocol registration for `productmanagementapp://`.
