# Presswerk

> Behalte deine Vinyl-Vorbestellungen im Blick. *(Keep track of your vinyl preorders.)*

Presswerk is a personal web app for managing vinyl preorders: what is ordered, what is on its way, what has already arrived – and which record is released when.

Built for a single user: no login, no user management, no external APIs. The UI is in German.

## Features

- **Dashboard** (`/`): key figures (open / received / cancelled) and upcoming releases grouped by release month. "Open" means the statuses *preordered* and *shipped*.
- **Preorders** (`/preorders`): table with search (artist/album), status filter and sorting (release date / artist). The filter state is kept in the URL.
- **New / edit / detail / delete** (`/preorders/new`, `/preorders/:id`, `/preorders/:id/edit`).
- Duplicate protection on artist + album ("Diese Platte wurde bereits erfasst.") via validation and a unique database index.

### Statuses

| Status | Meaning | Counts as |
| --- | --- | --- |
| Preordered | ordered, not shipped yet | open |
| Shipped | on its way | open |
| Received | arrived | received |
| Cancelled | cancelled | cancelled |

## Stack

Elixir, Phoenix 1.8, Phoenix LiveView, Ecto with SQLite (`ecto_sqlite3`), Tailwind CSS.

## Requirements

- Elixir ≥ 1.17 and Erlang/OTP (e.g. via [mise](https://mise.jdx.dev) or Homebrew: `brew install elixir`)
- Nothing else – SQLite is embedded, Tailwind/esbuild are downloaded by `mix`.

## Installation & database setup

```sh
git clone <repo-url> presswerk
cd presswerk
mise install
mise run setup
```

`mise run setup` fetches the dependencies, creates the SQLite database (`presswerk_dev.db` in the project folder), runs the migrations, builds the assets and activates the local pre-commit hook. Without mise, run `mix setup` and `git config core.hooksPath .githooks` manually.

## Running

```sh
mix phx.server
```

The app is then available at <http://localhost:4000>.

## Tests

```sh
mix test
```

The pre-commit hook runs `mix precommit` before each commit (compilation, dependency lock check, formatting check and tests). You can also run `mix precommit` manually.

## Project structure

```
lib/presswerk/preorders.ex            Context (queries, CRUD, key figures)
lib/presswerk/preorders/preorder.ex   Schema and validations
lib/presswerk_web/live/               LiveViews (Dashboard, Index, Show, Form)
lib/presswerk_web/components/         Layout and presentation helpers
test/                                 Context and LiveView tests
```

## Production (optional)

A release (`MIX_ENV=prod`) needs these environment variables:

| Variable | Description |
| --- | --- |
| `DATABASE_PATH` | Path to the SQLite file, e.g. `/var/lib/presswerk/presswerk.db` |
| `SECRET_KEY_BASE` | Secret key, generate with `mix phx.gen.secret` |
| `PHX_HOST` | Hostname the app is served under |

Presswerk deliberately has no login. Run it only locally or behind protected access (e.g. a VPN or a reverse proxy with auth).

## Notes

- The database is a single file (`presswerk_dev.db`) – copying it is enough for a backup.
- The development database path is set in `config/dev.exs`.
