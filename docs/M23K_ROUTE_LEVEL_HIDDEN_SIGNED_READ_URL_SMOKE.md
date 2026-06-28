# M23K - Route-level hidden signed read URL smoke

Status: completed.

## Purpose

M23K verifies that api/media/read-url.js can generate a signed media read URL through the route handler, using a persisted media asset, without exposing the signed URL, bucket, object key, or secrets in smoke output.

## Preconditions

Completed milestones:

- M23A signed upload helper smoke
- M23B Object Storage video PUT smoke
- M23C media metadata write smoke
- M23D upload request route smoke
- M23E route + PUT + metadata smoke
- M23F persistent media record smoke
- M23G media listing route audit
- M23H profile media storage fields hidden
- M23J signed media read URL helper implementation

## Server route

Route tested:

api/media/read-url.js

The route calls:

createSignedMediaReadUrl

## Test input

The smoke used a persisted media asset from:

- ownerCid: Cid-M23F-Persistent-Video-Smoke
- table: cidentia_media_assets

The smoke read internal storage bucket/key from DB server-side only.

## Runtime gates

The following read gates were enabled inline only for the smoke process:

- CIDENTIA_MEDIA_URL_GENERATION_ENABLED=true
- CIDENTIA_OBJECT_STORAGE_READ_ENABLED=true
- CIDENTIA_SIGNED_MEDIA_READ_URL_ENABLED=true
- CIDENTIA_DATABASE_QUERY_ENABLED=true

PM2 was not restarted.

No production runtime gate was permanently opened.

## M23K route-level smoke result

- ok: true
- code: M23K_ROUTE_SIGNED_READ_URL_CREATED_OK
- httpStatus: 200
- routeCode: SIGNED_MEDIA_READ_URL_CREATED
- route: /api/media/read-url
- ownerCid: Cid-M23F-Persistent-Video-Smoke
- mediaAssetIdPresent: true
- signedMediaReadUrlCreated: true
- signedMediaReadUrlPresentHidden: true
- expiresInSeconds: 300
- mediaUrlGenerationLocked: false
- objectStorageReadLocked: false
- signedMediaReadUrlLocked: false
- responseStorageBucketLeaked: false
- responseStorageObjectKeyLeaked: false
- storageBucketPresentHidden: true
- storageObjectKeyPresentHidden: true
- publicRouteOpened: false
- flutterOpened: false
- secretsExposed: false

## What this proves

- api/media/read-url.js can generate a signed media read URL through the route handler.
- The route returns HTTP 200 when read gates are enabled inline.
- The signed read URL is generated but hidden in the smoke output.
- Object Storage bucket is not exposed in the route response.
- Object Storage object key is not exposed in the route response.
- No storage secret is exposed.
- No Flutter render path is opened.
- No public production route is opened.
- PM2 was not restarted.

## Current completed backend media chain

- Signed upload URL: works.
- Object Storage video PUT: works.
- Media metadata DB write: works.
- Persistent media DB record: works.
- Profile media metadata read: works.
- Profile media storage fields hidden: works.
- Signed media read URL helper: works.
- Signed media read URL route: works.

## Still not completed

- Profile media route does not yet attach signed read URLs to media items.
- publicMediaUrl remains null in profile media metadata responses.
- Flutter media/reels UI is not connected to signed read URLs.
- Real video playback in Flutter is not opened.
- PM2 production runtime gates are not permanently opened.

## Next milestone

M23L - Profile media route signed URL attachment design.

M23L should decide how api/profile/media should expose playable media safely:

Option A:
- Keep api/profile/media metadata-only.
- Flutter calls api/media/read-url per item when playback is needed.

Option B:
- api/profile/media attaches signedMediaReadUrl per item when a guarded read gate is enabled.

Safer first choice is Option A, because bucket/object key stays server-side and signed URLs are generated only on demand.
