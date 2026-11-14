# Dover Invitational

Scorekeeping site for the Dover Invitational, Nov 20 to 22, 2026: Sandpiper, Soule Park and Olivas Links.

- Static site served by GitHub Pages. No sign-in.
- Live shared scores through Supabase (its own project), in the `dover_scores` and `dover_config` tables. Settings live in `supabase-config.js`.
- `dover-supabase.sql` creates those tables and their rules. Run it once in Supabase > SQL Editor.
- `robots.txt` and a `noindex` tag keep it out of search results. Anyone with the link can still open it.
