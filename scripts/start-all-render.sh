#!/bin/bash

# Exit immediately if any command fails
set -e

echo "Starting Nivo Money Microservices in the background..."

# Export correct routing URLs for the gateway to reach microservices locally
export IDENTITY_SERVICE_URL="http://localhost:8080"
export LEDGER_SERVICE_URL="http://localhost:8081"
export RBAC_SERVICE_URL="http://localhost:8082"
export WALLET_SERVICE_URL="http://localhost:8083"
export TRANSACTION_SERVICE_URL="http://localhost:8084"
export RISK_SERVICE_URL="http://localhost:8085"
export SIMULATION_SERVICE_URL="http://localhost:8086"
export NOTIFICATION_SERVICE_URL="http://localhost:8087"

# Also set them for service-to-service calls
export INTERNAL_SERVICE_SECRET="nivo-internal-secret-key-123456"

# Ensure we have a default JWT_SECRET if not set
if [ -z "$JWT_SECRET" ]; then
  export JWT_SECRET="nivo-jwt-secret-key-1234567890-secure-key"
fi

# Set MIGRATIONS_DIR to a non-existent path to prevent concurrent migration attempts
# since we have already run the migrations during setup.
export MIGRATIONS_DIR="./no_migrations_on_startup"

# Start microservices in the background, override PORT for each to avoid conflicts
echo "Starting RBAC on port 8082..."
PORT=8082 ./bin/rbac > rbac.log 2>&1 &

echo "Starting Identity on port 8080..."
PORT=8080 ./bin/identity > identity.log 2>&1 &

echo "Starting Ledger on port 8081..."
PORT=8081 ./bin/ledger > ledger.log 2>&1 &

echo "Starting Wallet on port 8083..."
PORT=8083 ./bin/wallet > wallet.log 2>&1 &

echo "Starting Transaction on port 8084..."
PORT=8084 ./bin/transaction > transaction.log 2>&1 &

echo "Starting Risk on port 8085..."
PORT=8085 ./bin/risk > risk.log 2>&1 &

echo "Starting Simulation on port 8086..."
PORT=8086 ./bin/simulation > simulation.log 2>&1 &

echo "Starting Notification on port 8087..."
PORT=8087 ./bin/notification > notification.log 2>&1 &

# Wait a few seconds for services to initialize
echo "Waiting for services to start up..."
sleep 5

# Start the API Gateway in the foreground on Render's designated port
echo "Starting API Gateway in the foreground..."
exec ./bin/gateway
