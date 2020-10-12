ARG ELIXIR_VERSION=1.10.2
FROM bitwalker/alpine-elixir-phoenix:${ELIXIR_VERSION}

#ENV MIX_ENV=prod

RUN apk --no-cache add make bash build-base gcc musl-dev libc-dev inotify-tools
RUN apk add 'fwup~=1.8.1' \
  --repository http://nl.alpinelinux.org/alpine/edge/community/ \
  --no-cache
RUN mix local.hex --force && mix local.rebar --force
RUN echo "127.0.0.1 nerves-hub.org" | tee -a /etc/hosts
# ADD mix.exs /build/mix.exs
# ADD mix.lock /build/mix.lock
ADD . /build/
WORKDIR /build
RUN mix deps.clean --all && mix do deps.get, compile && mix assets.install
RUN cd apps/nerves_hub_www/assets && npm rebuild node-sass
# RUN make reset-db
EXPOSE 4000
EXPOSE 4001
EXPOSE 4002
CMD ["mix", "phx.server"]