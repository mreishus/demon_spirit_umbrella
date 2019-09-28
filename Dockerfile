FROM elixir:1.9.1-alpine as build

# install build dependencies
RUN apk add --update git build-base nodejs yarn python npm

# prepare build dir
RUN mkdir /app
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# XXX TODO FIXME Hardcoded Secret key set a compile time -
# should be fixed to runtime and secret
ENV SECRET_KEY_BASE bv+H/Q06nr5psmLXAOWQwORe/brRsMHNhGvS7HgjetFrdcn84XJWolIgjNoM12gb

# install mix dependencies
COPY mix.exs mix.lock ./
## Umbrella Version
COPY ./apps/demon_spirit_web/mix.exs ./apps/demon_spirit_web/mix.exs
COPY ./apps/demon_spirit/mix.exs ./apps/demon_spirit/mix.exs
COPY ./apps/demon_spirit_game/mix.exs ./apps/demon_spirit_game/mix.exs

COPY config config
RUN mix deps.get
RUN mix deps.compile

# build assets
# COPY assets assets
# RUN cd assets && npm install && npm run deploy
# RUN mix phx.digest

## Umbrella Version
COPY apps/demon_spirit_web/assets apps/demon_spirit_web/assets
COPY deps/phoenix deps/phoenix
COPY deps/phoenix_html deps/phoenix_html
COPY deps/phoenix_live_view deps/phoenix_live_view

# build project
#COPY priv priv
## Umbrella Version
COPY ./apps/demon_spirit_web/priv ./apps/demon_spirit_web/priv

RUN cd apps/demon_spirit_web/assets && npm install && npm run deploy
RUN mix phx.digest

#COPY lib lib
## Umbrella Version
COPY apps/demon_spirit_game/lib/ apps/demon_spirit_game/lib/
COPY apps/demon_spirit/lib/ apps/demon_spirit/lib/
COPY apps/demon_spirit_web/lib/ apps/demon_spirit_web/lib/

RUN mix compile

# build release
RUN mix release
#COPY rel rel

# prepare release image
FROM alpine:3.10 AS app
RUN apk add --update bash openssl

RUN mkdir /app
WORKDIR /app

# Change the 'demon_spirit_umbrella' here to the name of the app
COPY --from=build /app/_build/prod/rel/demon_spirit_umbrella ./
RUN chown -R nobody: /app
USER nobody

ENV HOME=/app

## Set on runtime (Preferably this is done out of container)
#ENV SECRET_KEY_BASE bv+H/Q06nr5psmLXAOWQwORe/brRsMHNhGvS7HgjetFrdcn84XJWolIgjNoM12gb
#ENV DATABASE_URL ecto://postgres:postgres@filecab.local.p/demon_spirit_umbrella_prod

CMD ["bin/demon_spirit_umbrella","start"]
