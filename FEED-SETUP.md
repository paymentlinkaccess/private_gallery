# Gallery Feed setup (development branch only)

1. Run `supabase-setup.sql` in the Supabase SQL Editor. Review policies first.
2. Supabase Authentication > URL Configuration: add the production `https://paymentlinkaccess.github.io/private_gallery/daily.html` and `.../admin.html` to Redirect URLs, and the GitHub Pages site URL as Site URL.
3. Sign in to `admin.html` once; find the account UUID in Authentication > Users; grant admin role via SQL example at bottom of setup SQL.
4. Do not launch billing yet: Stripe webhooks must securely grant/extend/revoke membership using a server-side function and secret credentials. Existing package buyers must be verified against Stripe and granted access through a trusted process. Never let clients self-grant membership.
5. The Supabase private storage bucket protects objects with RLS and one-hour signed URLs; signed links may be shared during their lifetime. No DRM or screen-recording prevention.
6. Video uploads have a 250MB client-side cap, but actual Supabase plan/bucket upload limits may be lower. For large daily videos, use dedicated private video hosting.
7. The $15.99 payment link is present on `daily.html`; payment alone will NOT unlock access until the webhook is configured.
8. Do not merge to main until Stripe verification, account mapping, storage limits and end-to-end testing are complete.
