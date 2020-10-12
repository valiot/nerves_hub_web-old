FROM elixir:alpine

# install git and build-base
RUN apk --update --no-cache add git openssh npm make bash build-base gcc musl-dev libc-dev inotify-tools
RUN apk add 'fwup~=1.8.1' \
  --repository http://nl.alpinelinux.org/alpine/edge/community/ \
  --no-cache

RUN echo "127.0.0.1 nerves-hub.org" | tee -a /etc/hosts
RUN mix local.hex --force && mix local.rebar --force
RUN mix archive.install hex phx_new --force

# ADD mix.exs /build/mix.exs
# ADD mix.lock /build/mix.lock
ADD . /build/
WORKDIR /build
RUN mix deps.clean --all && mix do deps.get, compile
RUN mix assets.install && mix assets.build

# RUN make reset-db
EXPOSE 4000
EXPOSE 4001
EXPOSE 4002
CMD ["mix", "phx.server"]