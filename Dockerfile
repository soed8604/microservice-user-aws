FROM node:22-alpine AS builder

WORKDIR /usr/src/app

COPY app/package*.json ./
RUN npm install --omit=dev

COPY ./app .

# Imagen final
FROM node:22-alpine

WORKDIR /usr/src/app
COPY --from=builder /usr/src/app .

EXPOSE 3000
CMD ["node", "index.js"]
