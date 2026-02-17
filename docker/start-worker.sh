#!/usr/bin/env bash
set -euo pipefail

# Ensure runtime tmp dirs exist in ephemeral container filesystem.
mkdir -p tmp/pids tmp/cache

# Keep schema current before worker starts processing jobs.
bundle exec rails db:prepare

exec bundle exec sidekiq -C config/sidekiq.yml
