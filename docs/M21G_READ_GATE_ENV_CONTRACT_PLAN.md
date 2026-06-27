# M21G — Read Gate Env Contract Plan

Status: Env contract only, default disabled.

## Purpose

M21G adds future read/display media URL gates to the local env contract.

M21G does not change VPS env files.

## Added gates

- `CIDENTIA_MEDIA_URL_GENERATION_ENABLED`
- `CIDENTIA_OBJECT_STORAGE_READ_ENABLED`
- `CIDENTIA_SIGNED_MEDIA_READ_URL_ENABLED`

## Added locked flags

- `mediaUrlGenerationLocked`
- `objectStorageReadLocked`
- `signedMediaReadUrlLocked`

## Default behavior

When env values are missing, all new gates default to `false`.

Therefore locked values default to:

- `mediaUrlGenerationLocked:true`
- `objectStorageReadLocked:true`
- `signedMediaReadUrlLocked:true`

## VPS env behavior

M21G does not modify:

- `/opt/cidentia-live/env/db-live-smoke.env`
- `/opt/cidentia-live/env/object-storage-live-smoke.env`

## Added check

- `scripts/m21g-read-gate-env-contract-check.js`

The check verifies:

- new flags are present
- missing env defaults to false
- locked flags default to true
- explicit true env can open only the contract flags
- no secrets are exposed

## Locked boundaries preserved

M21G does not open:

- VPS env gate change
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
