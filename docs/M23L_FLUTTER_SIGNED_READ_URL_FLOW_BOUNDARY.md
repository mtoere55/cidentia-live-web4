# M23L - Flutter signed read URL flow boundary

Status: planned.

## Purpose

M23L defines the safe Flutter playback flow now that backend signed read URL generation works through both helper and route-level smokes.

## Current completed backend chain

Completed:

- Signed upload URL helper works.
- Object Storage video PUT works.
- Media metadata DB write works.
- Persistent media DB record works.
- Profile media metadata route works.
- Profile media response no longer exposes storageBucket or storageObjectKey.
- Signed media read URL helper works.
- api/media/read-url route works.
- Signed URL is hidden in server-only smoke output.
- Bucket/key are hidden from route response.
- No Flutter/public render path has been opened yet.

## Decision

Use Option A first.

## Option A - On-demand signed read URL

api/profile/media remains metadata-only.

Flutter first calls:

/api/profile/media

This returns safe metadata only:

- id
- ownerCid
- mediaSurface
- mimeType
- byteSize
- visibility
- moderationStatus
- createdAt
- publicMediaUrl: null

It must not return:

- storageBucket
- storageObjectKey
- signedMediaReadUrl
- raw object URL
- secret config

When a user taps or opens a media item, Flutter calls:

/api/media/read-url

The backend then generates a short-lived signed read URL for that media item.

## Why Option A is safer

- Bucket and object key stay server-side.
- Signed read URLs are generated only when needed.
- api/profile/media remains cache-friendly metadata.
- The read URL TTL stays short.
- Flutter does not need storage internals.
- A future permissions check can be placed directly on /api/media/read-url.

## Option B - Attach signed URLs inside profile media

Option B is deferred.

It would make api/profile/media attach signedMediaReadUrl to each item when read gates are enabled.

This is less safe as a first rollout because it creates signed URLs for every list item even if the user never plays them.

## Required next checks before Flutter playback

M23L should not open production playback yet.

Before Flutter render:

1. Confirm api/media/read-url can work without Flutter sending storageBucket/storageObjectKey.
2. Backend should resolve the media asset by id + ownerCid from DB.
3. Flutter should send only media id and CID.
4. api/media/read-url should fetch storageBucket/storageObjectKey server-side.
5. Response to Flutter should include signedMediaReadUrl but not bucket/key.
6. Signed URL should stay short-lived.
7. Route should remain gated and CID-guarded.

## Security rule

Flutter must never receive:

- storageBucket
- storageObjectKey
- access key
- secret key
- endpoint secret
- permanent public object URL

Flutter may receive only:

- signedMediaReadUrl
- expiresInSeconds
- media asset metadata required for playback

## Proposed next milestone

M23M - Read URL route DB lookup by media id.

M23M should change api/media/read-url so Flutter only sends:

- id
- ownerCid or CID header

The route should then read the media asset from DB and use bucket/key server-side.

This avoids requiring Flutter to send storageBucket or storageObjectKey.
