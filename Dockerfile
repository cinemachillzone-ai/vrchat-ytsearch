# ---- Build Stage ----
FROM hexpm/elixir:1.20.0-erlang-28.0-debian-bookworm-20250407-slim AS build

RUN apt-get update && apt-get install -y build-essential git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Instalar dependencias Hex
RUN mix local.hex --force && mix local.rebar --force

ENV MIX_ENV=prod

COPY mix.exs mix.lock ./
RUN mix deps.get --only prod
RUN mix deps.compile

COPY config config
COPY lib lib
COPY priv priv

RUN mix compile
RUN mix release

# ---- Runtime Stage ----
FROM debian:bookworm-slim AS runtime

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    libstdc++6 \
    openssl \
    libncurses5 \
    locales \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instalar yt-dlp
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp && \
    chmod a+rx /usr/local/bin/yt-dlp

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV PHX_SERVER=true

WORKDIR /app

# Directorio persistente para SQLite
RUN mkdir -p /data && chmod 777 /data

COPY --from=build /app/_build/prod/rel/vrchat_ytsearch ./

EXPOSE 4000

CMD ["bin/vrchat_ytsearch", "start"]
