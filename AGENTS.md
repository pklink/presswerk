# Presswerk

Personal web app for tracking vinyl preorders (single user, no login). UI copy is German; code and identifiers are English.

## Project-specific

- **Stack:** Elixir, Phoenix 1.8, LiveView, Ecto + SQLite (`ecto_sqlite3`), Tailwind. No background jobs, no external APIs, no auth/roles/multi-tenancy. No overengineering: use the simplest idiomatic Phoenix solution, no extra service layers.
- **Structure:** Domain logic: `lib/presswerk/preorders.ex` (context), `lib/presswerk/preorders/preorder.ex` (schema). LiveViews: `lib/presswerk_web/live/`. Presentation helpers: `lib/presswerk_web/components/preorder_components.ex`.
- **Status:** Define statuses in `Preorder`, labels in `status_label/1`. "Open" = `:preordered` or `:shipped`; use `Preorder.open_statuses/0`.
- **Duplicates:** `artist + album` is unique (unique index, case-sensitive). The error message "Diese Platte wurde bereits erfasst." is attached to the `unique_constraint` in the changeset – don't duplicate it in the UI.
- **Index page:** Search, status filter and sorting live in the URL (`q`, `status`, `sort`), are read in `handle_params/3` and changed via `push_patch`. The list is deliberately a plain assign (no stream): the data set is small.
- **Layout:** `<Layouts.app flash={@flash} active={...}>` with `active` for the navigation (`:dashboard | :preorders | :new`). There is no `current_scope`.
- **UI:** No modal dialogs; deleting uses `data-confirm`. Must stay usable on mobile and desktop. daisyUI for basic components (`btn`, `badge`, `table`, `input`), Tailwind for the rest. Amber accent color, subtle vinyl motif (`.vinyl` in `assets/css/app.css`), no kitschy retro look.
- **Tests:** Context tests in `test/presswerk/`, LiveView tests in `test/presswerk_web/live/`, test data via `Presswerk.PreordersFixtures`. New templates get unique DOM IDs for `has_element?/2`.
- **Workflow:** `mix setup`, `mix phx.server`; run `mix precommit` before finishing.

## Phoenix/Elixir pitfalls

- Router: declare `new` before `:id`; `scope` already sets the module alias.
- Navigation: use `<.link navigate/patch>` and `push_navigate/push_patch`, never `live_redirect`/`live_patch`.
- Icons via `<.icon name="hero-...">`, form fields via `<.input>` from `core_components.ex`. Overriding `class` on `<.input>` drops all default classes.
- Forms: always `to_form/2` in the LiveView and `<.form for={@form} id="...">` with `@form[:field]`; never use the changeset in the template.
- HEEx: always write classes as a list: `class={["a", @flag && "b", if(@x, do: "c", else: "d")]}`.
- Tailwind v4: keep the import syntax in `app.css` (`@import "tailwindcss" source(none);` plus `@source`), no `@apply`. Only the `app.js`/`app.css` bundles; no external scripts and no inline `<script>` in templates.
- Elixir: no `String.to_atom/1` on user input. Predicates end in `?`. One module per file.
- Ecto: `:text` columns are declared as `:string` in the schema. Read changeset fields with `get_field/2`. Generate migrations with `mix ecto.gen.migration`.
