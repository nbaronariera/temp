FROM oven/bun:1-alpine AS builder

WORKDIR /app

COPY package.json bun.lock ./

RUN bun install --production

RUN bun install

COPY . .
RUN chmod +x ./start.sh || true

FROM oven/bun:1-alpine

WORKDIR /app

RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    font-noto \
    font-noto-emoji \
    libstdc++ \
    libx11

ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
ENV PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium-browser

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/bun.lock ./bun.lock
COPY --from=builder /app/features ./features
COPY --from=builder /app/steps ./steps
COPY --from=builder /app/playwright.config.ts ./playwright.config.ts
COPY --from=builder /app/tsconfig.json ./tsconfig.json
COPY --from=builder /app/start.sh ./start.sh

RUN chmod +x ./start.sh || true

ENTRYPOINT ["/bin/bash", "./start.sh"]