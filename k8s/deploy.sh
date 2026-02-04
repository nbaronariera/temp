#!/usr/bin/env bash
set -euo pipefail

# IMAGE: container image to use
# REPLICAS: number of worker replicas/shards (default: 3)
# SHARD_COUNT: optional override for shard count (defaults to REPLICAS)

IMAGE=${IMAGE:-ghcr.io/youruser/plywrith-tests:latest}
REPLICAS=${REPLICAS:-3}
SHARD_COUNT=${SHARD_COUNT:-$REPLICAS}
MINIKUBE=${MINIKUBE:-false}

echo "IMAGE=${IMAGE} | REPLICAS=${REPLICAS} | SHARD_COUNT=${SHARD_COUNT} | MINIKUBE=${MINIKUBE}"

if [ "${MINIKUBE}" = "true" ]; then
	echo "Detected Minikube flow: building local image and loading into Minikube"
	if ! command -v minikube >/dev/null 2>&1; then
		echo "minikube not found in PATH. Install minikube or set MINIKUBE=false." >&2
		exit 1
	fi
	# Build image locally (docker/podman) then load into minikube
	if command -v docker >/dev/null 2>&1; then
		echo "Building image with docker..."
		docker build -t ${IMAGE} .
	elif command -v podman >/dev/null 2>&1; then
		echo "Building image with podman..."
		podman build -t ${IMAGE} .
	else
		echo "No docker or podman found to build the image." >&2
		exit 1
	fi

	echo "Loading image into Minikube..."
	minikube image load ${IMAGE}
fi

echo "Applying headless service and setup job..."
kubectl apply -f k8s/service-headless.yaml

# Apply setup job (coordinator) using the image
kubectl apply -f k8s/setup-job.yaml
echo "Waiting for setup job to complete (timeout 10m)..."
kubectl wait --for=condition=complete job/playwright-setup --timeout=600s

echo "Templating StatefulSet with replicas=${REPLICAS} and SHARD_COUNT=${SHARD_COUNT}"
# Create a templated manifest replacing placeholders and apply it
sed -e "s/__REPLICAS__/${REPLICAS}/g" -e "s/__SHARD_COUNT__/${SHARD_COUNT}/g" k8s/statefulset-workers.yaml | kubectl apply -f -

echo "Deployment applied. To scale workers and update shard count, re-run with REPLICAS and SHARD_COUNT set accordingly."
