# M21F — VPS Env Gate Read Names Only

Status: VPS read-only, names/status only.

## Purpose

M21F reads VPS environment gate names and status without printing secret values.

M21F does not call Object Storage and does not generate signed URLs.

## VPS env directory

The VPS env directory is:

- `/opt/cidentia-live/env`

Files found:

- `db-live-smoke.env`
- `object-storage-live-smoke.env`

## Object Storage smoke env status

File checked:

- `object-storage-live-smoke.env`

Gate status, names only:

- `CIDENTIA_UPLOAD_ENABLED=true`
- `CIDENTIA_OBJECT_STORAGE_ENABLED=true`
- `CIDENTIA_OBJECT_STORAGE_WRITE_ENABLED=true`
- `CIDENTIA_SIGNED_URL_ENABLED=true`
- `CIDENTIA_MEDIA_URL_GENERATION_ENABLED=missing`
- `CIDENTIA_OBJECT_STORAGE_READ_ENABLED=missing`
- `CIDENTIA_SIGNED_MEDIA_READ_URL_ENABLED=missing`

Config key presence, values hidden:

- `CIDENTIA_OBJECT_STORAGE_ENDPOINT=present_value_hidden`
- `CIDENTIA_OBJECT_STORAGE_BUCKET=present_value_hidden`
- `CIDENTIA_OBJECT_STORAGE_REGION=present_value_hidden`
- `CIDENTIA_OBJECT_STORAGE_ACCESS_KEY_ID=present_value_hidden`
- `CIDENTIA_OBJECT_STORAGE_SECRET_ACCESS_KEY=present_value_hidden`
- `CIDENTIA_OBJECT_STORAGE_FORCE_PATH_STYLE=missing`
- `CIDENTIA_SIGNED_UPLOAD_TTL_SECONDS=missing`

## DB smoke env status

File checked:

- `db-live-smoke.env`

Object Storage keys in DB smoke env:

- `CIDENTIA_OBJECT_STORAGE_ACCESS_KEY_ID=missing`
- `CIDENTIA_OBJECT_STORAGE_SECRET_ACCESS_KEY=missing`
- `CIDENTIA_OBJECT_STORAGE_BUCKET=missing`
- `CIDENTIA_OBJECT_STORAGE_ENDPOINT=missing`

## Secret guard

No secret values were printed.

Confirmed:

- `M21F_NO_SECRET_VALUES_PRINTED`
- `secretsExposed=false`

## Interpretation

The VPS currently has upload/write Object Storage smoke gates and hidden Object Storage config in the object storage smoke env file.

The future read/display media URL gates are not present yet:

- `CIDENTIA_MEDIA_URL_GENERATION_ENABLED`
- `CIDENTIA_OBJECT_STORAGE_READ_ENABLED`
- `CIDENTIA_SIGNED_MEDIA_READ_URL_ENABLED`

Therefore read/display signed media URL generation remains disabled.

## Locked boundaries preserved

M21F does not open:

- public media URL generation
- signed media read URL generation
- signed upload URL generation
- Object Storage client call
- Object Storage read
- Object Storage write
- Object Storage public access
- Object Storage secret exposure
- frontend secret
- API route
- Flutter real media rendering
- Flutter real posts rendering
- Flutter real reels rendering
- new Media tab
- fake posts
- fake reels
- fake media assets
- fake counters
- public feed publishing
- public upload/media route
- fake CID/session/token
- wallet/payment/token/blockchain
- CidenBridge production route
- RTMP/WebRTC/live stream
- replay recording
