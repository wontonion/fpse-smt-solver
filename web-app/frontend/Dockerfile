# Use Node.js 20 as the base image
FROM node:20-slim

# Set working directory for frontend
WORKDIR /app/frontend/

USER root
# Install pnpm globally
RUN corepack enable && corepack prepare pnpm@latest --activate

# We'll mount the source code as a volume, so we only need to copy package files
COPY ./ ./

# Set environment variables
ENV NODE_ENV=development
ENV PNPM_HOME=/usr/local/share/pnpm
ENV PATH=$PNPM_HOME:$PATH

# Install dependencies
RUN pnpm install 

# Expose the default port for frontend dev servers
EXPOSE 5173

# Create a startup script
RUN echo '#!/bin/sh\npnpm install & pnpm run dev:all' > /start.sh && \
    chmod +x /start.sh

# Use the startup script
CMD ["/start.sh"]