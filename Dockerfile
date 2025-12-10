FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install --silent
COPY . .
RUN npm run build || true

FROM node:18-alpine
WORKDIR /app
COPY --from=build /app . 
EXPOSE 3000
CMD ["npm","start"]
#for nodejs
