FROM node:26.8-alpine AS workspace
RUN corepack enable
WORKDIR /workspace
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/api/package.json apps/api/package.json
COPY apps/worker/package.json apps/worker/package.json
COPY tools/virtual-device/package.json tools/virtual-device/package.json

FROM workspace AS build
RUN pnpm install --frozen-lockfile
COPY apps/worker/tsconfig.json apps/worker/tsconfig.json
COPY apps/worker/src apps/worker/src
RUN pnpm --filter @ai-badge/worker build

FROM workspace AS production-dependencies
RUN pnpm --filter @ai-badge/worker install --prod --frozen-lockfile

FROM node:26.8-alpine AS runtime
ENV NODE_ENV=production
WORKDIR /workspace
COPY --from=production-dependencies /workspace/node_modules ./node_modules
COPY --from=production-dependencies /workspace/apps/worker/node_modules ./apps/worker/node_modules
COPY --from=production-dependencies /workspace/apps/worker/package.json ./apps/worker/package.json
COPY --from=build /workspace/apps/worker/dist ./apps/worker/dist
RUN chown -R node:node /workspace
USER node
WORKDIR /workspace/apps/worker
CMD ["node", "dist/main.js"]
