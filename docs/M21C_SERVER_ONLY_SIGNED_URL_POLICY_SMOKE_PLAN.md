# M21C — Server-only Signed URL Policy Smoke Plan

Status: Plan/read-only only.

## Purpose

M21C defines the safe plan for a future server-only signed media URL smoke.

M21C does not generate a signed URL.

## Current presigner state

The current Object Storage presigner client exists at:

- `server/media/objectStoragePresignerClient.js`

It currently supports guarded signed upload URL creation.

The current presigner path uses upload/write semantics and must not be reused as a read/display media URL path without a separate read policy.

## Existing gate names

The existing presigner config is controlled by these gates:

- `CIDENTIA_UPLOAD_ENABLED`
- `CIDENTIA_OBJECT_STORAGE_ENABLED`
- `CIDENTIA_OBJECT_STORAGE_WRITE_ENABLED`
- `CIDENTIA_SIGNED_URL_ENABLED`

The existing Object Storage config names are:

- `CIDENTIA_OBJECT_STORAGE_ENDPOINT`
- `CIDENTIA_OBJECT_STORAGE_BUCKET`
- `CIDENTIA_OBJECT_STORAGE_REGION`
- `CIDENTIA_OBJECT_STORAGE_ACCESS_KEY_ID`
- `CIDENTIA_OBJECT_STORAGE_SECRET_ACCESS_KEY`
- `CIDENTIA_OBJECT_STORAGE_FORCE_PATH_STYLE`
- `CIDENTIA_SIGNED_UPLOAD_TTL_SECONDS`

## Important separation

Upload signed URL and media display signed URL are not the same boundary.

Upload signed URL:

- creates a write-capable URL
- uses upload/write gates
- is tied to `PutObject` behavior
- must stay guarded

Media display signed URL:

- must be read-only
- must never allow write
- must be short-lived
- must be server-only
- must require media URL policy approval first
- must require visibility and moderation approval
- must not expose Object Storage secrets

## Required future read-only gates

A future read/display signed URL smoke must require separate explicit gates, for example:

- `CIDENTIA_MEDIA_URL_GENERATION_ENABLED`
- `CIDENTIA_OBJECT_STORAGE_READ_ENABLED`
- `CIDENTIA_SIGNED_MEDIA_READ_URL_ENABLED`

These gates should be separate from upload/write gates.

## Required future helper

A future read/display URL helper should be separate from the upload presigner.

Suggested future file:

- `server/media/objectStorageReadPresignerClient.js`

Suggested behavior:

- use server-side Object Storage credentials only
- use read-only signed URL generation only
- do not return bucket secrets
- do not return access keys
- do not return secret keys
- do not allow write operations
- use short TTL
- return `storageSignedUrlCreated:true` only after all gates pass

## Required future smoke object rule

A future smoke must use a temporary object only.

The object must be:

- test-only
- short-lived or safe to delete
- non-user-private
- not a real user document
- not a proof document
- not a production personal asset

## Required future policy chain

A future signed media read URL may only be created after all of these pass:

1. verified CID exists
2. media asset exists
3. owner CID exists
4. storage bucket exists
5. storage object key exists
6. surface is explicitly allowed
7. visibility allows the viewer
8. moderation status is approved
9. media URL generation gate is enabled
10. Object Storage read gate is enabled
11. signed media read URL gate is enabled
12. Object Storage credentials exist only on server
13. URL TTL is short
14. response does not expose secrets

## Expected disabled response before opening gates

Until future gates are explicitly opened, responses must remain:

- `publicMediaUrl:null`
- `publicMediaUrlsCreated:false`
- `storageSignedUrlCreated:false`
- `storageBucketExposed:false`
- `storageSecretExposed:false`
- `frontendSecretExposed:false`
- `objectStorageCalled:false`
- `secretsExposed:false`

## Future milestone sequence

Recommended next sequence:

1. M21D — read-only signed media URL helper skeleton, disabled by default
2. M21E — disabled read signed URL API boundary smoke
3. M21F — VPS env gate read, names only, no values
4. M21G — server-only temporary object signed read URL smoke, only if gates are explicitly opened
5. M21H — close gates and prove disabled state again
6. M21I — Flutter boundary read for media URL status, no rendering

## Locked boundaries preserved

M21C does not open:

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
