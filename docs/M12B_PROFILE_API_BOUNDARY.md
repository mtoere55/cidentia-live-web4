# M12B — Profile API Boundary

M12B adds guarded profile API boundaries for the future real profile backend.

## Added

- server/profile/profileBoundary.js
- api/profile/me.js
- api/profile/update.js
- scripts/m12b-profile-boundary-check.js

## Behavior

GET /api/profile/me

- missing CID: 401 PROFILE_CID_REQUIRED
- CID present: 503 PROFILE_READ_DISABLED

POST /api/profile/update

- missing CID: 401 PROFILE_CID_REQUIRED
- CID present: 503 PROFILE_WRITE_DISABLED

## Still Locked

- DB connection
- profile read
- profile write
- avatar upload
- cover upload
- media metadata write
- Object Storage
- signed URL
- fake CID/session/token

M12C should connect Flutter Profile actions to these profile API boundaries
without opening DB writes yet.
