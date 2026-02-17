#!/usr/bin/env bash
set -euo pipefail

role="${APP_ROLE:-web}"

mkdir -p tmp/pids tmp/cache
bundle exec rails db:prepare

if [ "$role" = "worker" ]; then
  exec bundle exec sidekiq -C config/sidekiq.yml -q critical -q high -q default -q low
fi

exec bundle exec puma -C config/puma.rb -p "${PORT:-3000}"