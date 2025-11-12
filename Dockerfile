# Dockerfile
FROM hexpm/elixir:1.18.0-erlang-27.2-alpine-3.21.0 AS build

RUN apk add --no-cache build-base git

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV=prod

COPY mix.exs mix.lock ./
RUN mix deps.get --only prod

COPY config ./config
COPY lib ./lib
# Ensure video/image assets are included
COPY assets ./assets

# Create a release candidate
RUN mix release

# Minimal runtime
FROM alpine:3.21.0

RUN apk add --no-cache openssl ncurses-libs libstdc++ libgcc

WORKDIR /app

# Copy only the release
COPY --from=build /app/_build/prod/rel/albo ./

ENV MIX_ENV=prod

# Run the release
CMD ["/app/bin/albo", "start"]