# syntax=docker/dockerfile:1.7

ARG RUBY_VERSION=3.4.4
ARG NODE_VERSION=24

FROM node:${NODE_VERSION}-bookworm-slim AS node

FROM ruby:${RUBY_VERSION}-slim AS base

ENV LANG=C.UTF-8 \
    TZ=Etc/UTC \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

WORKDIR /app

# System dependencies commonly required by Chatwoot gems and asset build.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    pkg-config \
    libpq-dev \
    libyaml-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    imagemagick \
    ffmpeg \
    libvips \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Bring Node.js + corepack from official Node image.
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/bin/npm /usr/local/bin/npm
COPY --from=node /usr/local/bin/npx /usr/local/bin/npx
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -sf /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -sf /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

RUN npm install -g pnpm

# Install Ruby gems first to maximize Docker layer cache.
COPY Gemfile Gemfile.lock ./
RUN bundle config set deployment true \
    && bundle config set without 'development test' \
    && bundle install --jobs=4 --retry=3

# Install JS dependencies.
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Copy application source.
COPY . .
RUN chmod +x ./docker/start-web.sh ./docker/start-worker.sh

# Precompile assets for production image.
# Dummy values are only for build-time asset compilation.
ENV SECRET_KEY_BASE=dummy \
    RAILS_ENV=production \
    NODE_ENV=production \
    DATABASE_URL=postgresql://postgres:postgres@localhost:5432/chatwoot
RUN bundle exec rails assets:precompile

# Runtime defaults. DATABASE_URL/REDIS_URL come from Railway variables.
ENV RAILS_ENV=production \
    NODE_ENV=production

EXPOSE 3000

CMD ["./docker/start-web.sh"]
