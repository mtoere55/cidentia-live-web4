# M23C - Server artifact media metadata alignment and DB write smoke

Status: completed.

## Purpose

M23C aligns the server runtime artifact enough for the upload metadata chain to import correctly, then proves that media metadata can be written to the live database and cleaned up safely.

## Server artifact alignment

Server current path:

/opt/cidentia-live/app/current

The missing runtime file was deployed:

server/media/mediaMetadataSchema.js

Verification result:

- server/media/mediaMetadataSchema.js = importable
- server/media/uploadRequestBoundary.js = importable
- api/upload/request.js = importable

## Metadata repository exports

The server metadata repository exports:

- ALLOWED_MEDIA_METADATA_SURFACES
- createMediaMetadata
- mapMediaAssetRow
- sanitizeMediaMetadataDraft
- validateMediaMetadataDraft

## DB write smoke

The metadata write smoke was run with DB smoke gates enabled only for the current process.

PM2 production process was not changed.

Result:

- ok: true
- code: MEDIA_METADATA_WRITE_OK
- ownerCid: Cid-M23C-Metadata-Smoke
- surface: profile_cover
- mimeType: video/mp4
- byteLength: 24
- mediaMetadataCreated: true
- mediaAssetIdCreated: true
- cleanupDone: true
- dbConnected: true
- queryEnabled: true
- storageBucketPresentHidden: true
- storageObjectKeyPresentHidden: true
- publicRouteOpened: false
- profileUpdated: false
- flutterUploadOpened: false
- secretsExposed: false

## What this proves

- Server metadata schema is now present in the runtime artifact.
- Upload route import chain is no longer broken by the missing schema file.
- The media metadata repository can create a database record.
- The smoke-created database record can be cleaned up safely.
- DB connection and query gate work when explicitly enabled for smoke.
- No secret value, signed URL, bucket value, or object key value was printed.

## Current real upload chain status

Completed:

- Signed video upload URL creation
- Object Storage video PUT
- Media metadata DB write and cleanup

Still not completed:

- Public route-level upload request smoke
- Persistent media metadata record for a real uploaded object
- Profile/Reels media listing
- Flutter real video picker upload
- Flutter real video render
- Signed media read URL/render path

## Next milestone

M23D - Route-level upload request smoke.

M23D should test /api/upload/request through the route boundary with CID header and video metadata, while keeping PM2 production gates closed unless explicitly started under smoke env.
