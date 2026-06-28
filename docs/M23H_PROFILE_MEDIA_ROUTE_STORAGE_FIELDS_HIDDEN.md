# M23H - Profile media route storage fields hidden

Status: completed.

## Purpose

M23H verifies that persisted M23F media records can be read through the existing profile media route without leaking Object Storage bucket, object key, signed URL, or secrets.

## Starting point

M23F created two persistent media records for:

Cid-M23F-Persistent-Video-Smoke

The first M23H smoke proved that api/profile/media returned the two records, but also exposed internal response fields:

- storageBucket
- storageObjectKey

This was not acceptable for Flutter/public response safety.

## Patch

File changed:

server/profile/profileTabsRepository.js

The profile media response mapper no longer returns:

- storageBucket
- storageObjectKey

The repository may still query storage columns internally, but they are no longer exposed in the route response.

## Server verification

Server runtime path:

/opt/cidentia-live/app/current

Patch verification showed only:

- publicMediaUrl
- function mapMediaRow

No storageBucket or storageObjectKey response fields remained.

Node syntax check passed:

server/profile/profileTabsRepository.js

## M23H V2 route smoke result

- ok: true
- code: M23H_PROFILE_MEDIA_ROUTE_STORAGE_HIDDEN_OK
- httpStatus: 200
- routeCode: PROFILE_MEDIA_READ_OK
- ownerCid: Cid-M23F-Persistent-Video-Smoke
- itemsRead: true
- itemCount: 2
- publicMediaUrlsCreated: false
- fakeItemsCreated: false
- storageBucketHidden: true
- storageObjectKeyHidden: true
- signedUrlHidden: true
- publicMediaUrlNull: true
- flutterUploadOpened: false
- flutterRenderOpened: false
- secretsExposed: false

## Safe item result

Each returned item had:

- idPresent: true
- ownerCid: Cid-M23F-Persistent-Video-Smoke
- mediaSurface: profile_cover
- mimeType: video/mp4
- byteSize: 24
- visibility: private
- moderationStatus: pending
- publicMediaUrlIsNull: true
- publicMediaUrlPresent: false
- storageBucketLeaked: false
- storageObjectKeyLeaked: false
- signedUrlLeaked: false

## What this proves

- api/profile/media can read persisted media records.
- The route returns metadata-only items safely.
- Object Storage bucket is not exposed.
- Object Storage object key is not exposed.
- Signed URL is not exposed.
- Public media URL remains null.
- No fake item is created.
- No Flutter upload/render path is opened.
- No secret is exposed.

## Completed backend chain through M23H

- M23A: signed video URL helper works.
- M23B: Object Storage video PUT works.
- M23C: media metadata DB write and cleanup works.
- M23D: /api/upload/request route signed URL works.
- M23E: route + PUT + metadata + cleanup works.
- M23F: persistent media record and DB read-back works.
- M23G: media listing route audit completed.
- M23H: profile media route storage fields hidden and safe metadata read works.

## Still not completed

- Signed media read URL.
- Public media URL.
- Actual video playback/render.
- Flutter real video picker upload.
- Flutter media/reels UI connected to persisted media.
- PM2 production process restarted with real upload/write/read gates.

## Next milestone

M23I - Signed media read URL gap decision.

M23I should decide whether to implement guarded signed read URL generation next, or first connect Flutter to metadata-only profile media route.
