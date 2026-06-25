# M17C — Disabled Profile Cover Metadata API Route

Status: Completed as a default-disabled API boundary.

## Purpose

M17C adds a guarded API route for future profile cover metadata persistence without enabling metadata writes by default.

## Added route

- `POST /api/profile/cover/metadata`

## Local backend wiring

The route is wired into the local disabled backend test server:

- `scripts/m10h-disabled-backend-local-server.js`

## Default behavior

With default environment settings, the route returns:

- `MEDIA_METADATA_WRITE_DISABLED`
- `mediaMetadataCreated:false`
- `profileUpdated:false`
- `objectStorageWrite:false`
- `dbConnected:false`
- `queryEnabled:false`
- `secretsExposed:false`

## CID gate

Requests without verified CID return:

- `PROFILE_CID_REQUIRED`

## Future explicit gate

The route will only attempt repository write when this future gate is explicitly enabled:

- `CIDENTIA_MEDIA_METADATA_WRITE_ENABLED=true`

Even then, DB write still also requires the existing DB/query gates.

## Locked boundaries preserved

M17C does not open:

- production metadata write
- profile database write
- public upload route
- Object Storage public URL exposure
- frontend Object Storage secrets
- fake CID/session/token
- wallet/payment/token/blockchain
- CidenBridge production route
- RTMP/WebRTC/live stream
- replay recording

## Result

M17C prepares the profile cover metadata API boundary while keeping runtime persistence disabled by default.
