#!/bin/bash
set -e

# 啟動 sshd 服務
/usr/sbin/sshd &

# Start PostgreSQL in the background
docker-entrypoint.sh postgres &

# Wait for PostgreSQL to start
until pg_isready -h localhost -p 5432; do
    sleep 1;
done

# Run a loop to keep the container alive
while true; do
    sleep 60;
done