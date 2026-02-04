# Dockerfile
FROM oven/bun:latest

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    bash \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

COPY package.json bun.lock ./

RUN bun install

RUN npx playwright install chromium

RUN npx playwright install-deps chromium

COPY . .

RUN chmod +x ./start.sh || true

ENTRYPOINT ["/bin/bash", "./start.sh"]