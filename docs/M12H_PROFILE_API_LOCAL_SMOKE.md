# M12H — Profile API Local Smoke

M12H adds a local-only smoke server for guarded profile API routes.

## Added

- scripts/m12h-profile-api-local-smoke-server.js
- scripts/m12h-profile-api-local-smoke-check.js

## Local Routes

- GET /api/profile/me
- POST /api/profile/update

## Expected Smoke Results

GET /api/profile/me without CID:

- 401 PROFILE_CID_REQUIRED

GET /api/profile/me with CID:

- 503 PROFILE_READ_DISABLED
- repositoryCode:DATABASE_DISABLED

POST /api/profile/update without CID:

- 401 PROFILE_CID_REQUIRED

POST /api/profile/update with CID:

- 503 PROFILE_WRITE_DISABLED
- repositoryCode:DATABASE_DISABLED
- profileUpdated:false
- queryEnabled:false

## Still Locked

- PostgreSQL connection
- DB query execution
- migration
- profile read/write
- avatar upload
- cover upload
- Object Storage
- signed URL
- CidenDB live session
- fake CID/session/token
- deploy
- UI filler/test buttons
