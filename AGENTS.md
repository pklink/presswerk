# Presswerk

Personal web app for tracking vinyl preorders (single user, no login). UI supports English (default) and German via Gettext; everything written to files is English, except localizations.

## Project-specific

- **Scope:** Keep the single-user app simple: no auth, roles, multi-tenancy, background jobs, external APIs or extra service layers.
- **Status:** Define statuses in `Preorder`, labels in `status_label/1`. "Open" = `:preordered` or `:shipped`; use `Preorder.open_statuses/0`.
- **Duplicates:** `artist + album` is unique and case-sensitive. Keep the duplicate error in the changeset, not in the UI.
- **Index page:** Keep search, status and sorting in the URL (`q`, `status`, `sort`). Use a plain list assign, not a stream; the data set is small.
- **UI:** No modal dialogs; deleting uses `data-confirm`. Must stay usable on mobile and desktop. daisyUI for basic components (`btn`, `badge`, `table`, `input`), Tailwind for the rest. Amber accent color, subtle vinyl motif (`.vinyl` in `assets/css/app.css`), no kitschy retro look.
- **Tests:** Reuse `Presswerk.PreordersFixtures`; give new templates unique DOM IDs for LiveView tests.
- **Workflow:** `mise run setup` for local developer setup; run `mix precommit` before finishing.
- **Commits & PRs:** Conventional Commits. No commit body; concise PR descriptions.
- **Renovate branches:** When working on a Renovate branch, add the `stop-updating` label to its pull request.
- **Templates:** Use class lists in HEEx and the existing icon/input components. Keep Tailwind v4 imports; no `@apply`, external scripts or inline `<script>` tags.
