# Presswerk

Single-user app for tracking vinyl preorders (German UI, no login).

Install [mise](https://mise.jdx.dev), then:

```sh
mise install
mise run setup
mise run dev
```

Open <http://localhost:4000>. Run checks with:

```sh
mise run check
```

## Docker

Generate a secret once and store it in a `.env` file next to `docker-compose.yml`:

```dotenv
SECRET_KEY_BASE=<output of openssl rand -base64 48>
```

Start the app with `docker compose up -d --build` and open <http://localhost:4000>. SQLite data is stored in a Docker volume. Keep the same secret across restarts. For deployment behind an HTTPS reverse proxy, set `PHX_HOST` to its public hostname in `.env`.
