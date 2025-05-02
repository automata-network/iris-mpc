#!/usr/bin/env bash
set -e

echo ">>> Enter entrypoint"

#1. Use official Postgres entrypoint script
docker-entrypoint.sh postgres &

echo ">>> Waiting for Postgres to be ready..."
until pg_isready -h localhost -p 5432; do
  sleep 1
done
echo ">>> Postgres is up!"

#2. LocalStack
echo ">>> Starting LocalStack services: $SERVICES"
localstack start --host &
sleep 10
echo ">>> LocalStack exec init-localstack.sh"
/app/init-localstack.sh
sleep 10
awslocal sqs list-queues
awslocal s3 ls
awslocal kms list-keys

#3. Start the hawk-participant servers
for id in 0 1 2; do
  echo "=> Starting hawk-participant ${id}"
  /app/run-server-docker.sh ${id} &
  sleep 30
done
sleep 10

#4. Start client
/app/run-client-docker.sh

# Keep container alive
# wait
tail -f /dev/null
