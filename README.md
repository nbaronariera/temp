# plywrith-tests

To install dependencies:

```bash
bun install
```

To run:

```bash
bun run index.ts
```

This project was created using `bun init` in bun v1.3.3. [Bun](https://bun.com) is a fast all-in-one JavaScript runtime.

## Kubernetes / Minikube deployment

Build the container image and deploy to a Kubernetes cluster. For Minikube, use the `MINIKUBE=true` flow which builds the image locally and loads it into the Minikube node.

**Note:** The Dockerfile is optimized for low memory footprint using Alpine base, multi-stage build, and only Chromium browser (~600MB final image vs ~3GB with all browsers).

1. Build locally (without push)

```bash
# Build and keep locally
./scripts/build-local.sh --image ghcr.io/<tu-usuario>/plywrith-tests:latest

# Or build and load into Minikube
./scripts/build-local.sh --image ghcr.io/<tu-usuario>/plywrith-tests:latest --minikube
```

2. Build & load (Minikube)

```bash
docker build -t ghcr.io/<tu-usuario>/plywrith-tests:latest .
docker push ghcr.io/<tu-usuario>/plywrith-tests:latest
IMAGE=ghcr.io/<tu-usuario>/plywrith-tests:latest REPLICAS=3 ./k8s/deploy.sh
```

Notes:

- Keep `REPLICAS` equal to the desired `SHARD_COUNT` (or set `SHARD_COUNT` explicitly).
- `start.sh` infers shard index from the StatefulSet ordinal (pod name suffix) and runs Playwright with `--shard=index/count` when appropriate.
- To change shard count later, re-run the deploy script with a new `REPLICAS` value.
