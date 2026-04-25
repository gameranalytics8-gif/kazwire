FROM node:18-alpine AS builder
WORKDIR /app

# Install OpenSSL for Prisma
RUN apk add --no-cache openssl

COPY package*.json .
RUN npm ci
COPY . .
RUN npx prisma generate
ENV PUBLIC_API_BASE_URL=
RUN npm run build
RUN npm prune --production

FROM node:18-alpine
WORKDIR /app

# Install OpenSSL for Prisma runtime
RUN apk add --no-cache openssl

COPY --from=builder /app/build build/
COPY --from=builder /app/node_modules node_modules/
COPY package.json .
EXPOSE 3000
ENV NODE_ENV=production
ENV DATABASE_URL=url
CMD [ "node", "build" ]
