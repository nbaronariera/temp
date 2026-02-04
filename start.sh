#!/usr/bin/env bash
set -euo pipefail

# If ROLE=coordinator the container runs the `setup` project and exits.

SHARD_COUNT=${SHARD_COUNT:-1}

# Infer SHARD_INDEX: prefer explicit env, otherwise derive from HOSTNAME
if [ -z "${SHARD_INDEX:-}" ]; then
  if [ -n "${HOSTNAME:-}" ]; then
    ORDINAL=${HOSTNAME##*-}
    if [[ "$ORDINAL" =~ ^[0-9]+$ ]]; then
      SHARD_INDEX=$ORDINAL
    else
      SHARD_INDEX=0
    fi
  else
    SHARD_INDEX=0
  fi
fi

# Normalize to integers
SHARD_INDEX=$((SHARD_INDEX + 0))
SHARD_COUNT=$((SHARD_COUNT + 0))

# Defensive checks
if [ "$SHARD_COUNT" -le 0 ]; then
  echo "Invalid SHARD_COUNT=$SHARD_COUNT, defaulting to 1"
  SHARD_COUNT=1
fi
if [ "$SHARD_INDEX" -ge "$SHARD_COUNT" ]; then
  echo "Warning: SHARD_INDEX ($SHARD_INDEX) >= SHARD_COUNT ($SHARD_COUNT). Using modulo to fit."
  SHARD_INDEX=$((SHARD_INDEX % SHARD_COUNT))
fi

echo "Role: ${ROLE:-worker} | Shard: ${SHARD_INDEX}/${SHARD_COUNT}"

# Generate BDD files
echo "Generating BDD artifacts..."
# CORRECCIÓN 1: Usamos npx para asegurar que bddgen use la config de Node
npx bddgen

if [ "${ROLE:-worker}" = "coordinator" ]; then
  echo "Running coordinator/setup project"
  exec npx playwright test --project=setup
fi

# Build Playwright command.
# CORRECCIÓN 2: Quitamos '--bun'. Usamos npx puro.
# Esto usa el 'node' que instalaste en el Dockerfile.
PLAYWRIGHT_CMD=(npx playwright test --project=chromium)

if [ "$SHARD_COUNT" -gt 1 ]; then
  PLAYWRIGHT_CMD+=(--shard=${SHARD_INDEX}/${SHARD_COUNT})
fi

# Allow extra args from env
if [ -n "${PLAYWRIGHT_ARGS:-}" ]; then
  IFS=' ' read -r -a EXTRA_ARGS <<< "$PLAYWRIGHT_ARGS"
  PLAYWRIGHT_CMD+=("${EXTRA_ARGS[@]}")
fi

echo "Executing: ${PLAYWRIGHT_CMD[*]}"
exec "${PLAYWRIGHT_CMD[@]}"