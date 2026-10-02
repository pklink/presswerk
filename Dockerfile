FROM hexpm/elixir:1.18.4-erlang-27.3.4.1-debian-bookworm-20250630-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends build-essential git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
ENV MIX_ENV=prod

RUN mix local.hex --force && mix local.rebar --force
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod
COPY config/config.exs config/prod.exs config/
RUN mix deps.compile
RUN mix assets.setup

COPY assets assets
COPY priv priv
COPY lib lib
RUN mix compile
RUN mix assets.deploy
COPY config/runtime.exs config/
RUN mix release

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends libstdc++6 libncurses6 libsqlite3-0 openssl ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /data && chown nobody:nogroup /data

WORKDIR /app
COPY --from=builder --chown=nobody:nogroup /app/_build/prod/rel/presswerk ./

ENV LANG=C.UTF-8 PHX_SERVER=true DATABASE_PATH=/data/presswerk.db
USER nobody
EXPOSE 4000
CMD ["/app/bin/presswerk", "start"]
