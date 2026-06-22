# M12F — Profile Repository Boundary

M12F adds the profile repository layer that will later read and write the
`cidentia_profiles` table.

## Added

- server/profile/profileRepository.js
- scripts/m12f-profile-repository-check.js

## Prepared Functions

- sanitizeProfileDraft()
- readProfileByCid()
- upsertProfileByCid()

## Current Behavior

The repository calls the guarded database client.

Because the database client is still disabled by default:

- profileRead:false
- profileUpdated:false
- dbConnected:false
- queryEnabled:false

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

M12G can wire the Profile API boundary to this repository while still returning
guarded disabled responses.
