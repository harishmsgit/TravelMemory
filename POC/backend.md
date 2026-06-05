# Backend Architecture and Production Guidance

This document describes the TravelMemory backend architecture, implementation details, and production-grade recommendations.

## What it is

The backend is a Node.js Express API server located in `backend/`.

Key files:
- `backend/index.js` — app entrypoint and route registration.
- `backend/routes/trip.routes.js` — REST routes for trip operations.
- `backend/controllers/trip.controller.js` — business logic and handlers.
- `backend/models/trip.model.js` — MongoDB schema for travel entries.
- `backend/conn.js` — Mongoose connection logic.

## Responsibilities

- Serve REST endpoints for trip creation and retrieval.
- Validate and persist travel journal data.
- Expose a health endpoint at `/hello`.
- Connect securely to MongoDB using `MONGO_URI`.

## Production-grade guidance

- Do not run `node index.js` directly in production.
- Use a process manager or system service such as:
  - `systemd` unit file
  - `pm2`
  - a container platform such as ECS/EKS.
- Inject `MONGO_URI` securely at runtime, not through committed code.
- Use environment-based configuration for development, staging, and production.
- Configure CORS only for trusted front-end origin(s).
- Add health checks and readiness probes behind load balancers.

## Why this architecture

- **Express** is lightweight and appropriate for a small JSON API.
- **Mongoose** provides schema enforcement and simplifies MongoDB integration.
- A separate backend enables independent scaling from the frontend.
- It supports future API extension and service-oriented deployment.

## Notes for improvement

- Add request validation middleware (e.g. `express-validator` or Joi).
- Introduce structured logging and centralized error handling.
- Implement authentication and authorization for user-specific data.
