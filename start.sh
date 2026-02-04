#!/usr/bin/env bash
set -euo pipefail

# Determine shard index and run tests accordingly.
# If ROLE=coordinator the container runs the `setup` project and exits.

SHARD_COUNT=${SHARD_COUNT:-1}

# Infer SHARD_INDEX: prefer explicit env, otherwise derive from HOSTNAME (StatefulSet ordinal)
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

# Defensive: ensure SHARD_INDEX is within [0, SHARD_COUNT-1]
if [ "$SHARD_COUNT" -le 0 ]; then
  echo "Invalid SHARD_COUNT=$SHARD_COUNT, defaulting to 1"
  SHARD_COUNT=1
fi
if [ "$SHARD_INDEX" -ge "$SHARD_COUNT" ]; then
  echo "Warning: SHARD_INDEX ($SHARD_INDEX) >= SHARD_COUNT ($SHARD_COUNT). Using modulo to fit."
  SHARD_INDEX=$((SHARD_INDEX % SHARD_COUNT))
fi

echo "Role: ${ROLE:-worker} | Shard: ${SHARD_INDEX}/${SHARD_COUNT}"

# Generate BDD files (bddgen) before running tests
echo "Generating BDD artifacts..."
bunx bddgen

if [ "${ROLE:-worker}" = "coordinator" ]; then
  echo "Running coordinator/setup project"
  exec bunx playwright test --project=setup
fi

# Build Playwright command. If only one shard, run normally (no --shard)
PLAYWRIGHT_CMD=(bunx playwright test)
if [ "$SHARD_COUNT" -gt 1 ]; then
  PLAYWRIGHT_CMD+=(--shard=${SHARD_INDEX}/${SHARD_COUNT})
fi

# Allow extra args from env
if [ -n "${PLAYWRIGHT_ARGS:-}" ]; then
  # split PLAYWRIGHT_ARGS into array
  IFS=' ' read -r -a EXTRA_ARGS <<< "$PLAYWRIGHT_ARGS"
  PLAYWRIGHT_CMD+=("${EXTRA_ARGS[@]}")
fi

echo "Executing: ${PLAYWRIGHT_CMD[*]}"
exec "${PLAYWRIGHT_CMD[@]}"
