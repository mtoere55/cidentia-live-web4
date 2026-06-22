# M12A — Real DB Foundation

M12A adds the backend database foundation files for the real Cidentia.Live
social/media data model.

This step does not connect to PostgreSQL and does not run migrations.

## Added

- server/db/databaseContract.js
- server/db/migrations/001_m12a_social_media_foundation.sql
- scripts/m12a-db-foundation-check.js

## Tables Prepared

- cidentia_profiles
- cidentia_media_assets
- cidentia_posts
- cidentia_reels
- cidentia_comments
- cidentia_likes
- cidentia_follows

## Still Locked

- DB connection
- migration execution
- profile write
- media metadata write
- upload
- signed URL
- Object Storage
- public media read
- fake CID/session/token

M12B should connect profile API boundaries to this model, still guarded by CID
and env gates.
