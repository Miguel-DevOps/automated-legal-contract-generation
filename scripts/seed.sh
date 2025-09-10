#!/bin/sh
# Run all seeders for all services
# Usage: ./scripts/seed.sh

set -e

SERVICES="auth-service contracts-service templates-service"

for SERVICE in $SERVICES; do
  echo "Running seeders for $SERVICE..."
  # Example: adjust to your seeder tool
  if [ -f "apps/$SERVICE/package.json" ]; then
    (cd apps/$SERVICE && pnpm run seed || echo "No seed script for $SERVICE")
  fi
done

echo "All seeders complete."
