# Adria Reserve — Backend image for Kubernetes
# Build from repo root:
#   docker build -f docker/backend/Dockerfile -t leartt0/adria-reserve-backend:1.0.0 ./app/backend

FROM node:18-alpine

WORKDIR /app

RUN apk add --no-cache python3 make g++ curl

COPY package*.json ./
RUN npm ci --omit=dev 2>/dev/null || npm install --omit=dev

COPY . .
RUN npm run build 2>/dev/null || true

RUN apk del python3 make g++

ENV NODE_ENV=production
ENV PORT=3001

EXPOSE 3001

HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:3001/health || exit 1

CMD ["npm", "start"]
