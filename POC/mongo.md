# MongoDB Architecture and Production Guidance

This document describes MongoDB usage in TravelMemory, database responsibilities, and production guidance.

## What it is

MongoDB is used as the application database.

Key files:
- `backend/conn.js` — database connection to MongoDB.
- `backend/models/trip.model.js` — document schema for travel entries.
- `ansible/db.yml` — MongoDB installation and initial user setup.

## Responsibilities

- Store travel experiences and journal metadata.
- Provide a flexible schema for optional fields such as hotels, locations, images, and notes.
- Persist data for the backend API.

## Production-grade guidance

- Use MongoDB Atlas or a managed hosted MongoDB service in production.
- Never hard-code connection strings in source control.
- Use a dedicated application user with least privilege.
- Enable TLS/SSL and require authentication.
- Restrict network access so only the application tier can reach the database.
- Implement backups and monitoring.
- Prefer replica sets for high availability.
- Separate development, staging, and production databases.

## Why MongoDB

- The dataset is semi-structured and fits a document model well.
- MongoDB supports optional fields and evolving record shape.
- The JSON-style data model simplifies developer productivity.
- It is a good fit for travel journal content with text, dates, URLs, and flags.

## Notes for improvement

- Add stricter schema validation via MongoDB JSON schema rules.
- Add indexes for fields used in query operations.
- Move connection secrets into a secrets manager.
