#!/usr/bin/env bash
set -euo pipefail

# Apply pending migrations/create db if needed before web boots.
bundle exec rails db:prepare

# Railway sets PORT automatically. Fall back to 3000 for local runs.
exec bundle exec puma -C config/puma.rb -p "${PORT:-3000}"
