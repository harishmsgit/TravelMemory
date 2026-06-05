# Frontend Architecture and Production Guidance

This document describes the TravelMemory frontend architecture, implementation details, and production-grade recommendations.

## What it is

The frontend is a React application located in `frontend/`.

Key files:
- `frontend/src/App.js` — main React app layout and routing.
- `frontend/src/components/pages/` — page views for Home, AddExperience, ExperienceDetails.
- `frontend/src/components/UIC/` — shared UI composition components.
- `frontend/package.json` — build and dependency definitions.

## Responsibilities

- Render the travel journal user interface.
- Query backend endpoints using the configured backend URL.
- Build a production static site with `npm run build`.

## Production-grade guidance

- Build the app for production: `npm run build`.
- Serve `frontend/build/` from a static host such as:
  - Nginx or Apache
  - Cloud CDN (S3 + CloudFront)
  - Managed static hosting service.
- Configure the backend URL via `REACT_APP_BACKEND_URL`.
- Ensure HTTPS for web and API traffic.

## Why this architecture

- **React** provides a mature SPA framework with a strong ecosystem.
- Create React App standardizes the build and developer workflow.
- A static frontend decouples deployment from backend services.
- This architecture supports CDN distribution and independent release.

## Notes for improvement

- Consider replacing `react-scripts` with a lighter build tool for better performance.
- Add error pages and offline support for resilience.
- Add automated static asset optimization.
