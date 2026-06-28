# M23O - Profile media read URL boundary call

Status: completed.

## Purpose

M23O connects the Flutter profile tab boundary to the signed media read URL client without opening actual playback.

This milestone proves that Flutter can move from profile media metadata to a short-lived signed read URL request while keeping storage internals and signed URLs hidden.

## Completed commits

- 0d23576 Add profile media asset id boundary extraction
- 7471e7a Add profile media read URL boundary call

## Files changed

- lib/local_social/widgets/local_profile_grid.dart

## Existing dependency

- lib/local_social/media/cidentia_media_read_url_client.dart

## Flow

1. Flutter reads profile tab metadata.
2. The profile tab boundary extracts a media asset id from the returned items.
3. If the active tab is not Posts and a media asset id exists, Flutter calls:

POST /api/media/read-url

4. The request is made through CidentiaMediaReadUrlClient.
5. The request sends:
   - mediaAssetId
   - CID through x-cidentia-cid

6. The request does not send:
   - storageBucket
   - storageObjectKey
   - storage_bucket
   - storage_object_key
   - object storage secrets
   - permanent public object URL

## UI boundary

The profile action sheet reports only boundary status.

It may show:

- readUrlCode
- signedMediaReadUrlCreated
- signedMediaReadUrlPresentHidden
- storageBucketExposed
- storageObjectKeyExposed
- canPlay
- playbackOpened=false

It does not show the signed media read URL.

## Safety result

M23O keeps all of these closed:

- video playback
- VideoPlayer binding
- public media rendering
- signed URL display
- signed URL logging
- bucket/key exposure
- permanent media URL creation

## Current result

M23O proves that Flutter can safely request a signed read URL after reading profile media metadata.

The signed URL remains temporary and hidden.

## Next milestone

M23P - Controlled profile media playback preview.

M23P may connect VideoPlayer to the signedMediaReadUrl only after this boundary is confirmed in UI.

M23P must still keep:

- signed URL hidden
- storageBucket hidden
- storageObjectKey hidden
- no permanent public URL
- no autoplay
- no publishing change
