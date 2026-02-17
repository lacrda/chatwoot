#!/usr/bin/env bash
set -euo pipefail

# Keep schema current before worker starts processing jobs.
bundle exec rails db:prepare

exec bundle exec sidekiq -C config/sidekiq.yml
