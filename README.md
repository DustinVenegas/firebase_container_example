# Example Firebase Lemonaide

This project demonstrates a simple Node.js service that stores reservations in Firestore (using the local emulator).

Files added:
- `src/index.js` - Express API with POST /reservations
- `src/firebase.js` - Firestore client initialization
- `src/seed.js` - seed sample inventory and user documents
- `docker-compose.yml` - runs a Firestore emulator and the API service

Quick start (macOS):

1. Build and start the emulator + API:

```bash
docker-compose up --build
```

2. In a new terminal, seed sample data (runs inside host Node):

```bash
npm install
npm run seed
```

3. Create a reservation:

```bash
curl -X POST http://localhost:3000/reservations \
  -H 'Content-Type: application/json' \
  -d '{"instrument_id":"<instrument-id>","user_id":"<user-id>","start_date":"2025-10-18T10:00:00Z","end_date":"2025-10-19T10:00:00Z"}'
```

Notes:
- The emulator runs at localhost:8080 and the API is configured via `FIRESTORE_EMULATOR_HOST` in `docker-compose.yml` so the Admin SDK talks to the emulator.
- Collections created: `inventory`, `user`, `reservation`. IDs are UUIDs.
