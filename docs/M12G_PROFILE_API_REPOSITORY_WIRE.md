# M12G — Profile API Repository Wire

M12G wires the guarded Profile API routes to the profile repository layer.

## Updated

- api/profile/me.js
- api/profile/update.js

## Added

- scripts/m12g-profile-api-repository-wire-check.js

## Behavior

GET /api/profile/me

- missing CID: 401 PROFILE_CID_REQUIRED
- CID present: calls readProfileByCid()
- database still disabled: 503 PROFILE_READ_DISABLED
- repositoryCode:DATABASE_DISABLED

POST /api/profile/update

- missing CID: 401 PROFILE_CID_REQUIRED
- CID present: calls upsertProfileByCid()
- database still disabled: 503 PROFILE_WRITE_DISABLED
- repositoryCode:DATABASE_DISABLED

## Still Locked

- PostgreSQL connection
- real DB query execution
- profile read
- profile write
- avatar upload
- cover upload
- media metadata write
- Object Storage
- signed URL
- fake CID/session/token
- UI filler/test buttons
