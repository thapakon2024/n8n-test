# Use Node.js 18 Alpine as base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Install n8n globally
RUN npm install -g n8n

# Create n8n user and set permissions (use available GID/UID)
RUN addgroup n8n && \
    adduser -G n8n -s /bin/sh -D n8n

# Create necessary directories with proper permissions
RUN mkdir -p /home/n8n/.n8n && \
    chown -R n8n:n8n /home/n8n/.n8n && \
    mkdir -p /app/workflows && \
    chown -R n8n:n8n /app

# Copy startup script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh && chown n8n:n8n /app/start.sh

# Switch to n8n user
USER n8n

# Set environment variables
ENV N8N_USER_FOLDER=/home/n8n/.n8n
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=https
ENV NODE_ENV=production

# Expose port
EXPOSE 5678

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:5678/healthz || exit 1

# Start n8n
CMD ["/app/start.sh"]