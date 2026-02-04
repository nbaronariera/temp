#!/usr/bin/env bash
set -euo pipefail

# Usage:
# ./scripts/build-local.sh --image myname/plywrith-tests:local [--minikube]
# If --minikube is passed, the script will attempt to load the image into Minikube.

IMAGE="plywrith-tests:local"
LOAD_MINIKUBE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --image)
      IMAGE="$2"; shift 2;;
    --minikube)
      LOAD_MINIKUBE=true; shift;;
    -h|--help)
      echo "Usage: $0 [--image <name>] [--minikube]"; exit 0;;
    *) echo "Unknown arg: $1"; exit 1;;
  esac
done

echo "Building image: ${IMAGE}"
if command -v docker >/dev/null 2>&1; then
  docker build -t "${IMAGE}" .
elif command -v podman >/dev/null 2>&1; then
  podman build -t "${IMAGE}" .
else
  echo "Neither docker nor podman found in PATH." >&2
  exit 1
fi

if [ "${LOAD_MINIKUBE}" = true ]; then
  if ! command -v minikube >/dev/null 2>&1; then
    echo "minikube not found; cannot load image into Minikube" >&2
    exit 1
  fi
  echo "Loading image into Minikube: ${IMAGE}"
  minikube image load "${IMAGE}"
fi

echo "Done. Image available locally as: ${IMAGE}"
