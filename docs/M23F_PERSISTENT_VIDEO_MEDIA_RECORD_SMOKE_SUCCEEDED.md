# M23F - Persistent server-only video media record smoke succeeded

Status: completed.

## Purpose

M23F proves that the server-only video upload chain can create a persistent media metadata record and read it back from the database.

The smoke keeps signed URL, bucket, object key, and secrets hidden.

## Server runtime

Server current path:

/opt/cidentia-live/app/current

PM2 production process was not restarted and was not changed.

Object Storage and DB smoke env files were loaded only for the current process.

## Important schema correction

The first M23F read-back query used incorrect column names:

- surface
- byte_length

The live table uses:

- media_surface
- byte_size

The corrected V2 read-back query succeeded.

## Pre-check

Before the corrected V2 run, the test CID already had one persistent media record:

- ownerCid: Cid-M23F-Persistent-Video-Smoke
- recordCount: 1
- secretsExposed: false

This means the first M23F attempt created a DB record before the read-back query failed on the wrong column name.

## Corrected M23F V2 result

- ok: true
- code: M23F_PERSISTENT_VIDEO_MEDIA_RECORD_OK
- routeCode: SIGNED_UPLOAD_URL_CREATED
- metadataCode: MEDIA_METADATA_WRITE_OK
- cidRequired: true
- cidVerified: true
- guarded: true
- routeHttpStatus: 200
- putHttpStatus: 200
- signedUploadUrlCreated: true
- uploadUrlPresentHidden: true
- storageBucketPresentHidden: true
- storageObjectKeyPresentHidden: true
- objectStorageWrite: true
- uploadCreated: true
- mediaMetadataCreated: true
- mediaAssetIdCreated: true
- mediaRecordPersisted: true
- readBackFound: true
- readBackMatches: true
- dbConnected: true
- queryEnabled: true
- bytesUploaded: 24
- contentType: video/mp4
- testCid: Cid-M23F-Persistent-Video-Smoke
- cleanupDone: false
- publicRouteOpened: false
- profileUpdated: false
- flutterUploadOpened: false
- flutterRenderOpened: false
- secretsExposed: false

## What this proves

- /api/upload/request route boundary works.
- CID header path works.
- Signed upload URL creation works.
- Object Storage PUT works.
- Media metadata DB write works.
- Persistent DB record creation works.
- DB read-back by created media asset ID works.
- Read-back values match expected CID, surface, MIME type, byte size, and upload source.
- No signed URL was printed.
- No bucket value was printed.
- No object key value was printed.
- No secret was printed.
- PM2 production process was not changed.

## Completed backend chain through M23F

- M23A: Presigner driver and signed video URL smoke passed.
- M23B: Server-only Object Storage video PUT smoke passed.
- M23C: Server artifact metadata schema alignment and DB write cleanup smoke passed.
- M23D: Route-level upload request signed URL smoke passed.
- M23E: Route + PUT + metadata + cleanup smoke passed.
- M23F: Route + PUT + persistent metadata + read-back smoke passed.

## Current persistent test state

The test CID may now have more than one persistent media record because the first M23F attempt created a record before failing on the read-back column name.

Test CID:

Cid-M23F-Persistent-Video-Smoke

This is acceptable for M23F, but future cleanup or listing tests should account for multiple test records.

## Still not completed

- Public media read URL/render path.
- Profile/Reels listing endpoint for persisted media.
- Flutter real video picker upload.
- Flutter real video render.
- PM2 production process started with upload/write gates.
- Real user media flow.

## Next milestone

M23G - Media listing/read route audit.

M23G should inspect existing media listing/read endpoints and determine the safest route for Flutter to retrieve persisted media metadata without exposing storage secrets or object keys.
