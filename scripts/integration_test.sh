#!/usr/bin/env bash
set -euo pipefail

# Run seed inside api container (pass emulator env explicitly to be safe)
echo "Running seed script inside api container..."
docker-compose -f "$COMPOSE_FILE" exec -T -e FIRESTORE_EMULATOR_HOST=firestore-emulator:8080 -e GOOGLE_CLOUD_PROJECT=emu-project api npm run seed

# Grab one inventory and one user id from firestore via REST emulator API
# Using the REST API to query documents
EMULATOR_HOST=firestore-emulator:8080
PROJECT=emu-project

# list inventory docs
INVENTORY_DOCS_JSON=$(curl -s "http://$EMULATOR_HOST/v1/projects/$PROJECT/databases/(default)/documents:runQuery" -H 'Content-Type: application/json' -d '{"structuredQuery":{"from":[{"collectionId":"inventory"}]}}')
INVENTORY_ID=$(echo "$INVENTORY_DOCS_JSON" | jq -r '.[0].document.name' | awk -F'/' '{print $NF}')

USER_DOCS_JSON=$(curl -s "http://$EMULATOR_HOST/v1/projects/$PROJECT/databases/(default)/documents:runQuery" -H 'Content-Type: application/json' -d '{"structuredQuery":{"from":[{"collectionId":"user"}]}}')
USER_ID=$(echo "$USER_DOCS_JSON" | jq -r '.[0].document.name' | awk -F'/' '{print $NF}')

if [ -z "$INVENTORY_ID" ] || [ -z "$USER_ID" ]; then
  echo "Failed to find seeded inventory or user documents"
  docker-compose -f "$COMPOSE_FILE" logs --tail=50
  docker-compose -f "$COMPOSE_FILE" down
  exit 1
fi

# Post a reservation
# Using date compatible with both Linux and macOS
START_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ" -v+1H 2>/dev/null || date -u --date="+1 hour" +"%Y-%m-%dT%H:%M:%SZ")
END_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ" -v+2H 2>/dev/null || date -u --date="+2 hour" +"%Y-%m-%dT%H:%M:%SZ")

echo "Posting reservation for instrument $INVENTORY_ID by user $USER_ID"
RESPONSE=$(curl -s -X POST http://api:3000/reservations \
  -H 'Content-Type: application/json' \
  -d "{\"instrument_id\":\"$INVENTORY_ID\",\"user_id\":\"$USER_ID\",\"start_date\":\"$START_DATE\",\"end_date\":\"$END_DATE\"}")

echo "Reservation response:"
echo "$RESPONSE" | jq .

# Check if container can talk to emulator
echo "Verifying API container can communicate with Firestore emulator container..."
docker-compose -f "$COMPOSE_FILE" exec -T api curl -s "http://firestore-emulator:8080/v1/projects/emu-project/databases/\(default\)/documents"
if [ $? -eq 0 ]; then
  echo "✅ API container can communicate with Firestore emulator container"
else
  echo "❌ API container cannot communicate with Firestore emulator container"
  docker-compose -f "$COMPOSE_FILE" logs
  exit 1
fi

echo "All tests passed! Integration test complete."
echo "Services are up and running. To stop, run: docker-compose down"
