#!/bin/bash

# n8n startup script for Render deployment
set -e

echo "🚀 Starting n8n on Render..."

# Wait for database to be ready if using PostgreSQL
if [ "$DB_TYPE" = "postgresdb" ]; then
    echo "⏳ Waiting for PostgreSQL database to be ready..."
    
    # Simple check for database connectivity
    until pg_isready -h "$DB_POSTGRESDB_HOST" -p "$DB_POSTGRESDB_PORT" -U "$DB_POSTGRESDB_USER" 2>/dev/null; do
        echo "Database is not ready yet. Waiting 5 seconds..."
        sleep 5
    done
    
    echo "✅ Database is ready!"
    
    # Run database migrations
    echo "🔄 Running database migrations..."
    n8n db:migrate
fi

# Initialize n8n if first time
echo "🔧 Initializing n8n configuration..."

# Create .n8n directory if it doesn't exist
mkdir -p /home/n8n/.n8n

# Set proper permissions
chmod 755 /home/n8n/.n8n

# Start n8n
echo "🎯 Starting n8n server..."
echo "📍 Access n8n at: https://${RENDER_EXTERNAL_HOSTNAME:-localhost:5678}"
echo "🔐 Username: ${N8N_BASIC_AUTH_USER:-admin}"
echo "🔐 Password: ${N8N_BASIC_AUTH_PASSWORD:-[check environment variables]}"

# Start n8n with proper configuration
exec n8n start