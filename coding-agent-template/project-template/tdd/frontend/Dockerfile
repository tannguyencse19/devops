# docker build -t demo-develop-app-with-tdd:lastest .

# Single-stage build for React/Vite frontend with preview server
FROM node:20-alpine

# Build args for Coolify FQDN and Vite environment variables
ARG COOLIFY_FQDN
ARG VITE_SUPABASE_URL
ARG VITE_SUPABASE_PUBLISHABLE_KEY

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including devDependencies for preview)
RUN npm ci --silent

# Copy source code
COPY . .

# Set environment variables for build
ENV VITE_ALLOWED_DOMAIN=$COOLIFY_FQDN
ENV VITE_SUPABASE_URL=$VITE_SUPABASE_URL
ENV VITE_SUPABASE_PUBLISHABLE_KEY=$VITE_SUPABASE_PUBLISHABLE_KEY

# Build the application
RUN npm run build

EXPOSE 4173
CMD ["npm", "run", "preview", "--", "--host", "0.0.0.0", "--port", "4173"]