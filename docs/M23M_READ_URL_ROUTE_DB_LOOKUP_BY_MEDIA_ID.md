# M23M - Read URL route DB lookup by media id

Status: completed.

## Purpose

M23M changes api/media/read-url so clients do not send storageBucket or storageObjectKey.

Instead, the client sends only:

- media id
- CID via header or ownerCid

The backend resolves the media asset from DB and uses storage bucket/key server-side only.

## Changed files

- api/media/read-url.js
- server/media/mediaMetadataRepository.js

## Repository addition

server/media/mediaMetadataRepository.js now exports:

readMediaAssetForSignedReadUrl

This function reads a media asset from cidentia_media_assets using:

- id
- owner_cid

It returns the internal media asset to server-side code only.

## Route behavior

api/media/read-url.js now:

1. Accepts POST only.
2. Reads media id from body.id.
3. Reads CID from x-cidentia-cid header or body.ownerCid.
4. Calls readMediaAssetForSignedReadUrl.
5. Uses the DB result server-side.
6. Calls createSignedMediaReadUrl.
7. Returns signedMediaReadUrl only when gates allow it.
8. Does not expose storageBucket.
9. Does not expose storageObjectKey.

## Server smoke

Smoke name:

M23M ROUTE DB LOOKUP SIGNED READ URL SMOKE

Input request body sent to route:

- id only

CID was sent via header.

No storageBucket was sent.
No storageObjectKey was sent.

## Result

- ok: true
- code: M23M_ROUTE_DB_LOOKUP_SIGNED_READ_URL_OK
- httpStatus: 200
- routeCode: SIGNED_MEDIA_READ_URL_CREATED
- route: /api/media/read-url
- ownerCid: Cid-M23F-Persistent-Video-Smoke
- requestBodyOnlyMediaId: true
- requestBodyStorageBucketSent: false
- requestBodyStorageObjectKeySent: false
- mediaAssetIdPresent: true
- signedMediaReadUrlCreated: true
- signedMediaReadUrlPresentHidden: true
- expiresInSeconds: 300
- mediaUrlGenerationLocked: false
- objectStorageReadLocked: false
- signedMediaReadUrlLocked: false
- responseStorageBucketLeaked: false
- responseStorageObjectKeyLeaked: false
- publicRouteOpened: false
- flutterOpened: false
- secretsExposed: false

## What this proves

- Flutter no longer needs to know bucket or object key.
- The route can resolve the media asset server-side by id + CID.
- The route can generate a short-lived signed read URL.
- The signed URL was hidden in smoke output.
- Bucket and object key were not sent in the request.
- Bucket and object key were not returned in the response.
- No secrets were exposed.
- No Flutter playback was opened.
- No public production route was opened.

## Current completed chain

- Signed upload URL works.
- Object Storage video PUT works.
- Media metadata DB write works.
- Persistent media DB record works.
- Profile media metadata read works.
- Profile media storage fields are hidden.
- Signed media read URL helper works.
- Signed media read URL route works.
- Signed media read URL route now resolves bucket/key server-side by media id.

## Still not completed

- Flutter media/reels UI is not connected yet.
- Flutter video playback is not opened yet.
- PM2 production runtime gates are not permanently opened.
- No public production route rollout has been done.

## Next milestone

M23N - Flutter media playback client boundary.

M23N should define the Flutter-side request/response contract:

1. Load profile media metadata.
2. User taps media item.
3. Flutter sends media id with CID header to /api/media/read-url.
4. Backend returns signedMediaReadUrl.
5. Flutter plays video with that temporary URL.
6. Flutter never receives storageBucket or storageObjectKey.
