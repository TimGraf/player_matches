# Elixir

FROM elixir:1.10.4

# Install debian packages
RUN apt-get update

COPY . /app

RUN cd /app && \
    rm -Rf deps _build && \
    mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get && \
    mix compile

WORKDIR /app