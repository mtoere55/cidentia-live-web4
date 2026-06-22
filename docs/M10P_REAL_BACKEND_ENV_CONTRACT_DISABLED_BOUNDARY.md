# M10P Real Backend Env Contract and Disabled Production Boundary

M10P defines the real backend environment contract before any production backend feature is opened.

This is a contract document only.
This patch does not deploy a real backend.
This patch does not change Flutter UI.
This patch does not open upload, Object Storage write, CidenDB live session, CidenBridge, wallet, payment, RTMP, live streaming or replay recording.

## Current sealed infrastructure state

The current public API route is:

- https://api.cidentia.live

Current API status:

- Cloudflare proxy enabled for api.cidentia.live
- HTTPS active
- Nginx proxy active
- PM2 disabled backend online
- disabled backend routes verified

Current safe endpoints:

- GET /api/health -> 200
- GET /api/status -> 200
- GET /api/storage/status -> 503 locked
- POST /api/upload/request -> 503 locked
- GET /api/cidendb/session/status -> 503 locked

## Server env location

Server-only env files may live under:

- /opt/cidentia-live/env

The env directory must remain private:

- chmod 700 /opt/cidentia-live/env
- owned by cidentia:cidentia
- never committed to Git
- never printed in chat
- never exposed to Flutter

Recommended future env file:

- /opt/cidentia-live/env/cidentia-live-api.env

## Default safety gates

Every production-capable feature must default to disabled.

Required default values:

CIDENTIA_BACKEND_DEPLOY_ACTIVE=false
CIDENTIA_PRODUCTION_MODE=false
CIDENTIA_UPLOAD_ENABLED=false
CIDENTIA_OBJECT_STORAGE_ENABLED=false
CIDENTIA_OBJECT_STORAGE_WRITE_ENABLED=false
CIDENTIA_SIGNED_URL_ENABLED=false
CIDENTIA_MEDIA_METADATA_WRITE_ENABLED=false
CIDENTIA_CIDENDB_SESSION_ENABLED=false
CIDENTIA_CIDENBRIDGE_ENABLED=false
CIDENTIA_WALLET_ENABLED=false
CIDENTIA_PAYMENT_ENABLED=false
CIDENTIA_RTMP_ENABLED=false
CIDENTIA_WEBRTC_ENABLED=false
CIDENTIA_REPLAY_RECORDING_ENABLED=false
CIDENTIA_AI_PROVIDER_ENABLED=false

## Database env contract

PostgreSQL staging database exists:

- database: cidentia_live_staging
- user: cidentia_app
- host: 127.0.0.1
- port: 5432

Future env names:

DATABASE_URL=
POSTGRES_HOST=127.0.0.1
POSTGRES_PORT=5432
POSTGRES_DATABASE=cidentia_live_staging
POSTGRES_USER=cidentia_app
POSTGRES_PASSWORD=

Rules:

- password must never be committed
- password must never be printed in terminal logs
- database write routes must remain disabled until schema and migrations are sealed
- no production schema should be applied during M10P

## Object Storage env contract

Object Storage bucket is prepared:

- bucket: cidentia-live-media
- endpoint: fsn1.your-objectstorage.com
- visibility: private

Future env names:

CIDENTIA_OBJECT_STORAGE_ENDPOINT=fsn1.your-objectstorage.com
CIDENTIA_OBJECT_STORAGE_BUCKET=cidentia-live-media
CIDENTIA_OBJECT_STORAGE_REGION=fsn1
CIDENTIA_OBJECT_STORAGE_ACCESS_KEY=
CIDENTIA_OBJECT_STORAGE_SECRET_KEY=

Required gates:

CIDENTIA_OBJECT_STORAGE_ENABLED=false
CIDENTIA_OBJECT_STORAGE_WRITE_ENABLED=false
CIDENTIA_SIGNED_URL_ENABLED=false

Rules:

- credentials are server-only
- Flutter must never receive Object Storage credentials
- signed upload URLs must not be generated until upload permissions are implemented
- writes must remain disabled by default

## Upload env contract

Future upload gates:

CIDENTIA_UPLOAD_ENABLED=false
CIDENTIA_UPLOAD_REQUEST_ENABLED=false
CIDENTIA_MEDIA_METADATA_WRITE_ENABLED=false
CIDENTIA_MAX_UPLOAD_MB=
CIDENTIA_ALLOWED_MEDIA_TYPES=

Rules:

- upload request route must stay locked unless upload gate is true
- media metadata write must be separate from file upload
- upload must require verified CidenDB/CID session
- Pro/credit/payment gate must be checked before expensive storage operations

## CidenDB env contract

CidenDB remains the identity/databank authority.

Future env names:

CIDENDB_BRIDGE_ENABLED=false
CIDENDB_CONTRACT_CONFIRMED=false
CIDENDB_BASE_URL=
CIDENDB_OTP_SEND_PATH=
CIDENDB_OTP_VERIFY_PATH=
CIDENDB_API_KEY=
CIDENDB_CLIENT_ID=
CIDENDB_CLIENT_SECRET=

Rules:

- Cidentia.Live must not create its own identity authority
- Cidentia.Live must not create fake CID sessions
- raw CidenDB tokens must not be exposed to Flutter
- safe session handoff must return only safe session references
- missing CID must route to CidentiaApp onboarding

## CidenBridge env contract

CidenBridge is the future integration/payment/wallet bridge.

Future env names:

CIDENBRIDGE_ENABLED=false
CIDENBRIDGE_BASE_URL=
CIDENBRIDGE_API_KEY=
CIDENBRIDGE_WALLET_ENABLED=false
CIDENBRIDGE_PAYMENT_ENABLED=false

Rules:

- wallet/payment must remain disabled by default
- no token transfer route may be opened in M10P
- no fake balance or fake payout may be created
- creator earnings UI remains preview until bridge/payment is implemented

## Live/RTMP env contract

Future live gates:

CIDENTIA_LIVE_ENABLED=false
CIDENTIA_RTMP_ENABLED=false
CIDENTIA_WEBRTC_ENABLED=false
CIDENTIA_SCREEN_SHARE_ENABLED=false
CIDENTIA_REPLAY_RECORDING_ENABLED=false

Rules:

- Live Studio local preview can remain visible
- real broadcast must require verified CID
- RTMP destination must not connect until live contract is implemented
- replay recording must not write files until storage and retention policy are implemented

## AI provider env contract

Future AI gates:

CIDENTIA_AI_PROVIDER_ENABLED=false
CIDENTIA_AI_CREDITS_ENABLED=false
CIDENTIA_AI_QUEUE_ENABLED=false

Rules:

- no AI provider key in Flutter
- no provider call until AI credit gate is implemented
- expensive AI work must check credit/pro allowance first
- generated media must use Object Storage only after storage write is enabled

## Required response flags

Every disabled backend response should keep these flags visible:

- deployActive=false
- uploadLocked=true
- objectStorageWrite=false
- walletPaymentLocked=true
- cidenDbSessionLive=false
- cidenBridgeLive=false
- rtmpLive=false
- replayRecording=false
- guarded=true
- readOnly=true

## Locked boundaries

M10P does not open:

- production app deploy
- Flutter web deploy
- upload
- Object Storage write
- signed upload URL generation
- media metadata creation
- database schema migration
- CidenDB live session
- frontend token exposure
- CidenBridge
- wallet
- payment
- RTMP
- WebRTC
- live streaming
- replay recording
- AI provider call
- root/www DNS cutover
- market/terminal/mail DNS changes

## Next safe step

The next safe step is M10Q.

M10Q should add a server-side env example file or runtime env loader skeleton with all production-capable gates disabled by default.

No real secrets should be added.
No real feature should be enabled.
