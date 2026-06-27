# M21J — Read Presigner Implementation Plan

Status: Implementation plan only.

## Purpose

M21J defines the implementation plan for future server-only signed media read URL generation.

M21J does not implement signed URL generation.

## Current package location

Root `package.json` is not present.

Server package files are located at:

- `server/package.json`
- `server/package-lock.json`

Package capability check is limited to the server package files.

No package change is made in M21J.

## Current package capability

The server package already contains:

- `@aws-sdk/client-s3`
- `@aws-sdk/s3-request-presigner`

Observed version:

- `3.1075.0`

This means a future read presigner can likely use the existing AWS SDK package set without adding a new package.

M21J does not verify runtime import of `GetObjectCommand`; that remains for M21K.

## Current state

The read/display signed media URL chain is prepared but still locked:

- env contract has read/display gates
- `/api/media/read-url` reads the env contract
- disabled smoke returns `MEDIA_URL_GENERATION_DISABLED`
- positive local gate smoke reaches `SIGNED_MEDIA_READ_URL_SIGNER_NOT_IMPLEMENTED`
- no Object Storage client call is made
- no signed read URL is created

## Upload/read separation

Upload signed URL and read/display signed URL must remain separate.

Existing upload presigner:

- `server/media/objectStoragePresignerClient.js`

Read/display helper skeleton:

- `server/media/objectStorageReadPresignerClient.js`

The read/display helper must not reuse upload/write behavior.

## Future read presigner requirement

Future implementation should add read-only presigner behavior using Object Storage read semantics only.

Expected future command type:

- `GetObjectCommand`

Disallowed for read/display URL generation:

- `PutObjectCommand`
- write-capable signed URL
- upload-capable signed URL
- unrestricted bucket URL
- frontend-built Object Storage URL

## Required gates

Future signed media read URL generation must require all of these gates:

- `CIDENTIA_MEDIA_URL_GENERATION_ENABLED=true`
- `CIDENTIA_OBJECT_STORAGE_READ_ENABLED=true`
- `CIDENTIA_SIGNED_MEDIA_READ_URL_ENABLED=true`

These gates are separate from upload/write gates.

## Required media policy checks

Before creating a signed media read URL, the route/helper must confirm:

- verified CID exists
- media asset exists
- owner CID exists
- storage bucket exists
- storage object key exists
- surface is explicitly allowed
- visibility allows the current viewer
- moderation status is approved
- media URL policy allows generation
- read gates are enabled
- TTL is short
- Object Storage credentials stay server-only

## Required response fields

When disabled or blocked:

- `publicMediaUrl:null`
- `signedMediaReadUrl:null`
- `signedMediaReadUrlCreated:false`
- `storageSignedUrlCreated:false`
- `objectStorageCalled:false`
- `objectStorageRead:false`
- `objectStorageWrite:false`
- `storageBucketExposed:false`
- `storageObjectKeyExposed:false`
- `storageSecretExposed:false`
- `frontendSecretExposed:false`
- `secretsExposed:false`

When future server-only read smoke succeeds, allowed response should be limited to:

- `signedMediaReadUrlCreated:true`
- short-lived `signedMediaReadUrl`
- `expiresInSeconds`
- `objectStorageRead:true`
- `objectStorageWrite:false`
- `secretsExposed:false`

Bucket names, object keys, access keys, and secret keys must not be exposed to Flutter unless a separate explicit policy allows non-secret metadata.

## TTL policy

Future signed media read URLs must be short-lived.

Suggested default:

- 300 seconds

Suggested maximum:

- 900 seconds

The TTL must be controlled server-side only.

## Temporary object smoke rule

A future positive smoke must use a temporary object only.

The object must be:

- test-only
- non-user-private
- not a proof document
- not a real user document
- safe to delete
- clearly namespaced under a smoke/test prefix

Suggested object key pattern:

- `smoke/m21-read-url/<timestamp>-test-object.txt`

## Required future smoke sequence

Recommended sequence after this plan:

1. M21K — package/read command capability check, no storage call
2. M21L — read presigner disabled implementation, no storage call by default
3. M21M — positive local gate smoke still stops before missing config or signer
4. M21N — VPS env names-only read for future read gates after manual env addition
5. M21O — server-only temporary object signed read URL smoke, only if gates are explicitly opened
6. M21P — close gates and prove disabled state again
7. M21Q — Flutter boundary read for media URL status, no rendering

## Close-gate requirement

Any future live signed read URL smoke must be followed by a close-gate smoke proving:

- read gates closed again
- API returns disabled state again
- `signedMediaReadUrl:null`
- `signedMediaReadUrlCreated:false`
- `objectStorageCalled:false`
- `secretsExposed:false`

## Locked boundaries preserved

M21J does not open:

- implementation code
- package changes
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
