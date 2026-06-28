# M23P-1 - Controlled playback readiness boundary

Status: planned readiness boundary.

## Purpose

M23P-1 defines the safe rules for the next playback milestone before any VideoPlayer binding is opened.

M23O proved that Flutter can move from profile media metadata to a signed media read URL boundary call.

M23P-1 keeps playback closed and documents the requirements for a later controlled playback preview.

## Current sealed state

Backend chain:

- signed upload URL works
- object storage PUT works
- media metadata write works
- persistent media record works
- profile media metadata read works
- signed read URL helper works
- signed read URL route works
- read URL route resolves bucket/key server-side by media id

Flutter chain:

- signed media read URL client exists
- profile tab metadata can expose mediaAssetIdPresent status
- profile tab can call CidentiaMediaReadUrlClient
- signedMediaReadUrl is not displayed
- signedMediaReadUrl is not printed by toString
- storageBucket is not sent by Flutter
- storageObjectKey is not sent by Flutter
- storageBucket/storageObjectKey exposure is checked
- playbackOpened=false

## Rules for M23P-2

M23P-2 may only open a controlled playback preview if all of these remain true:

- user action is required
- no autoplay
- readUrl.canPlay must be true
- signedMediaReadUrlCreated must be true
- signedMediaReadUrl must exist only in memory
- signedMediaReadUrl must not be printed to logs
- signedMediaReadUrl must not be shown on screen
- storageBucket must not be shown on screen
- storageObjectKey must not be shown on screen
- permanent public media URL must not be created
- upload/publishing flow must remain unchanged
- route gates must remain respected

## UI rule

The UI may show safe status only:

- readUrlCode
- signedMediaReadUrlCreated
- signedMediaReadUrlPresentHidden
- storageBucketExposed
- storageObjectKeyExposed
- canPlay
- playbackOpened

The UI must not show:

- signedMediaReadUrl
- storageBucket
- storageObjectKey
- object storage secrets
- permanent object URL

## Playback preview rule

A later M23P-2 implementation may connect VideoPlayer only inside a controlled preview surface.

The preview must be opened by explicit user tap.

It must not autoplay from profile grid render.

It must dispose the controller when the preview closes.

## Out of scope

M23P-1 does not implement:

- VideoPlayer binding
- autoplay
- public media URL rendering
- permanent URL caching
- publishing changes
- storage policy changes
- backend gate changes

## Next milestone

M23P-2 - Controlled profile media playback preview.
