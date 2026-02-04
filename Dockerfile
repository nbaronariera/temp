FROM oven/bun:latest

# Working directory
WORKDIR /app

# Copy only manifest first to leverage cache for dependency install
COPY package.json package.json
COPY bun.lock bun.lock

# Install dependencies (devDependencies required for Playwright)
RUN bun install

# Copy the rest of the repository
COPY . .

# Install Playwright browsers (with system dependencies)
RUN bunx playwright install --with-deps

# Make entrypoint executable
RUN chmod +x ./start.sh || true

ENTRYPOINT ["/bin/bash", "./start.sh"]
