#!/bin/sh
# Run all pending database migrations for all services
# Usage: ./scripts/migrate.sh

set -e

SERVICES="auth-service contracts-service templates-service"

for SERVICE in $SERVICES; do
  echo "Running migrations for $SERVICE..."
  # Example: adjust to your migration tool (TypeORM, Prisma, etc.)
  if [ -f "apps/$SERVICE/package.json" ]; then
    (cd apps/$SERVICE && pnpm run migration:run || echo "No migration script for $SERVICE")
  fi
done

echo "All migrations complete."
