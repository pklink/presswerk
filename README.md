# Presswerk

Presswerk is a small web app for tracking vinyl preorders. The UI is in German. It is designed for a single user and has no login.

## Features

- Create, edit, and delete preorders with artist, album, shop, order and release dates, links, and notes
- Track statuses: preordered, shipped, received, or cancelled
- View status counts and upcoming releases grouped by month on the dashboard
- Search by artist or album, filter by status, and sort by release date or artist

Presswerk is built with Elixir, Phoenix LiveView, and SQLite. Data is stored in a local SQLite database; no external services are required.

## Run locally

Install [mise](https://mise.jdx.dev) and Git, then run from the project directory:

```sh
mise install
mise run setup
mise run dev
```

Open <http://localhost:4000>. `mise run setup` installs dependencies, sets up the database, and builds assets. To run tests and checks:

```sh
mise run check
```

## Run with Docker

Generate a secret once with `openssl rand -base64 48` and store it in a `.env` file next to `docker-compose.yml`:

```dotenv
SECRET_KEY_BASE=<generated secret>
```

Start the app with `docker compose up -d --build` and open <http://localhost:4000>. The SQLite database is stored in the `presswerk-data` Docker volume; migrations run when the container starts. Keep the same secret across restarts and do not commit the `.env` file. When deploying behind an HTTPS reverse proxy, set `PHX_HOST` in `.env` to the public hostname.

**Note:** Presswerk has no login. The default Docker configuration publishes port 4000, so do not expose an instance with personal data to the internet without access protection.

## Contributing

Bug reports and suggestions are welcome. To contribute code, fork the repository, create a branch, and open a pull request with a short description. Run `mix precommit` (or `mise run check`) before submitting. Please keep the app simple and single-user, and preserve the German UI.

## License

Presswerk is licensed under the [MIT License](LICENSE).
