FROM elixir:1.5-alpine

ADD . /app
WORKDIR /app

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get

CMD ["mix", "phx.server"]

