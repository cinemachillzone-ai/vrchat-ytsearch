FROM elixir:1.18-slim

# Instalar dependencias del sistema + yt-dlp
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    python3 \
    locales \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instalar yt-dlp
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
    -o /usr/local/bin/yt-dlp && chmod a+rx /usr/local/bin/yt-dlp

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV MIX_ENV=prod
ENV PHX_SERVER=true

WORKDIR /app

# Instalar Hex y Rebar
RUN mix local.hex --force && mix local.rebar --force

# Dependencias
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod
RUN mix deps.compile

# Código fuente
COPY config config
COPY lib lib
COPY priv priv

RUN mix compile

# Directorio para SQLite
RUN mkdir -p /data && chmod 777 /data

EXPOSE 4000

CMD ["mix", "phx.server"]
