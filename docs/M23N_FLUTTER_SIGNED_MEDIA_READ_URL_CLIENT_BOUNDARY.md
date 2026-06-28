# M23N - Flutter signed media read URL client boundary

Status: completed.

## Purpose

M23N adds the Flutter-side client boundary for requesting signed media read URLs without opening playback yet.

The goal is to prepare Flutter for safe media playback while keeping storage internals hidden.

## Added file

- lib/local_social/media/cidentia_media_read_url_client.dart

## Client

CidentiaMediaReadUrlClient

## Result model

CidentiaSignedMediaReadUrlResult

## Request behavior

The Flutter client calls:

POST /api/media/read-url

It sends only:

- id

It sends CID only through:

- x-cidentia-cid header

It does not send:

- storageBucket
- storageObjectKey
- storage_bucket
- storage_object_key
- permanent public object URL
- secret config

## Response behavior

The client accepts signed playback only when all of these are true:

- ok is true
- HTTP status is 200
- signedMediaReadUrlCreated is true
- signedMediaReadUrl is present
- storageBucket is not exposed
- storageObjectKey is not exposed
- secretsExposed is not true

If any unsafe field appears, the client blocks playback and returns:

SIGNED_MEDIA_READ_URL_CLIENT_BOUNDARY_BLOCKED_*

## Logging safety

CidentiaSignedMediaReadUrlResult.toString does not print the signed URL.

It only prints:

- signedMediaReadUrlPresentHidden

This prevents signed media URLs from leaking into Flutter logs.

## Analyzer cleanup

A follow-up lint cleanup commit fixed the long-line analyzer info.

## Completed commits

- cbc0478 Add Flutter signed media read URL client boundary
- f9616b1 Clean Flutter signed media read URL client lint

## What this proves

- Flutter can request a signed read URL using media id + CID.
- Flutter does not need bucket or object key.
- Flutter can block unsafe responses client-side.
- Flutter will not print the signed URL in toString logs.
- Playback has not been opened yet.
- Public media rendering has not been opened yet.

## Current safe chain

Backend:

- Upload signed URL works.
- Object Storage PUT works.
- Media metadata write works.
- Persistent media record works.
- Profile media metadata read works.
- Read signed URL helper works.
- Read signed URL route works.
- Read URL route resolves bucket/key server-side by media id.

Flutter:

- Signed media read URL client boundary exists.
- It sends only media id and CID.
- It blocks bucket/key leaks.
- It hides signed URL in logs.

## Still not completed

- Profile media list is not rendered as real media yet.
- Reels page is not connected to backend media yet.
- VideoPlayer is not connected to signedMediaReadUrl yet.
- PM2 production runtime gates are not permanently opened.

## Next milestone

M23O - Profile media item tap read-url boundary.

M23O should connect the client boundary to a protected UI action without starting full playback:

1. Read profile media metadata.
2. Pick one media item id.
3. On tap, call CidentiaMediaReadUrlClient.
4. Show boundary status only.
5. Do not play video yet.
6. Do not print signed URL.
7. Do not expose bucket/key.
