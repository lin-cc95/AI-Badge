FROM node:26.9.0-alpine AS workspace
RUN corepack enable
WORKDIR /workspace
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/api/package.json apps/api/package.json
COPY apps/worker/package.json apps/worker/package.json
COPY tools/virtual-device/package.json tools/virtual-device/package.json

FROM workspace AS build
RUN pnpm install --frozen-lockfile
COPY apps/api/tsconfig.json apps/api/tsconfig.build.json apps/api/nest-cli.json apps/api/
COPY apps/api/src apps/api/src
RUN pnpm --filter @ai-badge/api build

FROM workspace AS production-dependencies
RUN pnpm --filter @ai-badge/api install --prod --frozen-lockfile

FROM node:26.9.0-alpine AS runtime
ENV NODE_ENV=production
WORKDIR /workspace
COPY --from=production-dependencies /workspace/node_modules ./node_modules
COPY --from=production-dependencies /workspace/apps/api/node_modules ./apps/api/node_modules
COPY --from=production-dependencies /workspace/apps/api/package.json ./apps/api/package.json
COPY --from=build /workspace/apps/api/dist ./apps/api/dist
RUN chown -R node:node /workspace
USER node
WORKDIR /workspace/apps/api
CMD ["node", "dist/main.js"]
