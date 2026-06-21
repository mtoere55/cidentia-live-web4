# M10I VPS Staging Disabled Backend Deploy Plan

M10I defines how the disabled backend skeleton can be staged on the VPS without opening production features.

This is a deploy plan only.
This patch does not deploy to the VPS.
This patch does not change Flutter UI.
This patch does not open upload, Object Storage write, CidenDB live session, CidenBridge, wallet, payment, RTMP or live streaming.

## Current sealed backend state

The repository already contains a disabled backend skeleton:

- /api/health
- /api/status
- /api/storage/status
- /api/upload/request
- /api/cidendb/session/status
- server/runtime/backendStatusGuard.js
- scripts/m10h-disabled-backend-local-server.js

Local test result:

- /api/health returns 200 safe status
- /api/status returns 200 safe status
- /api/storage/status returns 503 OBJECT_STORAGE_WRITE_DISABLED
- /api/upload/request returns 503 UPLOAD_ROUTE_DISABLED
- /api/cidendb/session/status returns 503 CIDENDB_SESSION_SERVICE_DISABLED

## VPS staging target

Server:

- cidentia-live-api-01
- IPv4: 167.233.122.49
- OS: Ubuntu 24.04.4 LTS

Runtime already prepared:

- Node.js v22.23.0
- npm 10.9.8
- PM2 7.0.1
- Nginx 1.24.0
- PostgreSQL 16.14

Staging directory target:

- /opt/cidentia-live/app

Runtime env directory:

- /opt/cidentia-live/env

Logs directory:

- /opt/cidentia-live/logs

## Staging app behavior

The first VPS staging backend should run only the disabled backend server.

Allowed:

- serve /api/health
- serve /api/status
- serve /api/storage/status as locked
- serve /api/upload/request as locked
- serve /api/cidendb/session/status as locked

Not allowed:

- real upload
- real Object Storage write
- signed upload URL creation
- media metadata creation
- CidenDB live session creation
- frontend token exposure
- CidenBridge wallet or payment
- RTMP connection
- WebRTC connection
- replay recording
- production deploy

## PM2 staging process

Future process name:

- cidentia-live-disabled-backend

Future local port:

- 3010

Expected command:

node scripts/m10h-disabled-backend-local-server.js

Expected bind address:

- 127.0.0.1

The process should stay private behind Nginx until Cloudflare DNS is ready.

## Nginx staging proxy plan

The current Nginx static health route already works.

Future Nginx proxy should map:

- /api/health
- /api/status
- /api/storage/status
- /api/upload/request
- /api/cidendb/session/status

to:

- http://127.0.0.1:3010

The existing static /health route may remain as infrastructure health.

## Environment safety

No secrets should be committed.

Server-only env files may later live under:

- /opt/cidentia-live/env

Required default safety values:

- CIDENTIA_DISABLED_BACKEND_PORT=3010
- CIDENTIA_OBJECT_STORAGE_ENABLED=false
- CIDENTIA_OBJECT_STORAGE_WRITE_ENABLED=false
- MEDIA_BRIDGE_ENABLED=false
- LIVE_BRIDGE_ENABLED=false
- CIDENDB_BRIDGE_ENABLED=false

## Verification checklist before staging deploy

Before any VPS deploy command:

1. git status must be clean.
2. main must be pushed.
3. local disabled backend server test must pass.
4. VPS /health must still return deployActive=false.
5. Nginx must be active.
6. PM2 must be installed.
7. No secrets may be printed in terminal output.

## Verification checklist after staging deploy

Expected endpoint behavior through VPS:

- GET /api/health -> 200
- GET /api/status -> 200
- GET /api/storage/status -> 503 locked
- POST /api/upload/request -> 503 locked
- GET /api/cidendb/session/status -> 503 locked

Required flags:

- deployActive=false
- uploadLocked=true
- objectStorageWrite=false
- walletPaymentLocked=true
- cidenDbSessionLive=false
- cidenBridgeLive=false
- rtmpLive=false
- replayRecording=false

## Locked boundaries

M10I does not open:

- production deploy
- Flutter UI change
- upload
- Object Storage write
- signed URL generation
- wallet
- payment
- CidenBridge
- CidenDB live session
- frontend token exposure
- RTMP
- live stream
- replay recording
- Cloudflare DNS cutover

## Next safe step

After this plan is sealed, the next step can be M10J:

VPS staging disabled backend deployment.

M10J should copy only the disabled backend skeleton to the VPS, run it with PM2 on 127.0.0.1:3010, and keep Nginx/Cloudflare production boundaries locked.
