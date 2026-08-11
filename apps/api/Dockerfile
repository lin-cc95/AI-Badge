FROM node:24.14.0-alpine AS build
RUN corepack enable
WORKDIR /app
COPY package.json ./
RUN pnpm install --frozen-lockfile=false
COPY tsconfig*.json nest-cli.json ./
COPY src ./src
RUN pnpm build

FROM node:24.14.0-alpine
ENV NODE_ENV=production
WORKDIR /app
COPY package.json ./
RUN corepack enable && pnpm install --prod --frozen-lockfile=false
COPY --from=build /app/dist ./dist
CMD ["node", "dist/main.js"]

