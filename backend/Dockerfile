# Build stage
FROM node:18-alpine as builder

WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./

# Installer les dépendances de production
RUN npm ci --only=production

# ========================================
# Production stage
FROM node:18-alpine

WORKDIR /app

# Copier les dépendances du builder
COPY --from=builder /app/node_modules /app/node_modules

# Copier le reste du code
COPY . .

# Créer les répertoires uploads et logs
RUN mkdir -p uploads logs

# Exposer le port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:5000/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})" || exit 1

# Variables d'environnement par défaut
ENV NODE_ENV=production
ENV PORT=5000

# Démarrer le serveur
CMD ["node", "server.js"]
