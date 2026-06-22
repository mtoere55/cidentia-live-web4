# M11D — Media Upload Contract Seal

## Purpose

M11D defines the upload contract before any real upload, Object Storage write,
signed URL creation, or media metadata write is opened.

This document is a boundary seal only. It does not enable upload.

## Current Runtime State

Create > Upload media in Flutter is connected to:

POST /api/upload/request

The route must remain disabled by default and return:

- code: UPLOAD_ROUTE_DISABLED
- uploadCreated: false
- signedUploadUrlCreated: false
- mediaMetadataCreated: false

## Identity Authority

Cidentia.Live is not the identity authority.

- CidenDB owns verified CID identity.
- CidentiaApp handles onboarding / missing CID completion.
- CidenBridge later handles bridge, wallet, payment, and integration surfaces.
- Cidentia.Live only accepts verified CID session state.

## Upload Eligibility Contract

A future upload request may only be accepted when all conditions are true:

- CIDENTIA_UPLOAD_ENABLED=true
- CIDENTIA_CIDENDB_SESSION_ENABLED=true
- request has verified CidenDB/CID session
- owner CID is present
- media contract is confirmed
- Object Storage contract is confirmed
- metadata write contract is confirmed

If any condition is missing, upload must remain locked.

## Allowed Media Types

Initial allowed types for later staging only:

- image/jpeg
- image/png
- image/webp
- video/mp4
- video/webm

No executable, archive, document, script, SVG, HTML, or unknown binary upload.

## Initial Size Limits

Initial safe staging limits:

- image max: 10 MB
- short video / reel max: 100 MB
- story video max: 50 MB
- replay/live recording: disabled until replay contract exists

These limits are contract defaults and may be reduced before production.

## Media Surfaces

The upload contract must distinguish:

- post image
- post video
- reel video
- story media
- profile avatar
- profile cover
- live replay

Live streaming and replay recording remain locked separately.

## Required Metadata Shape

A future media metadata record must include at minimum:

- mediaId
- ownerCid
- ownerDisplayName snapshot
- mediaSurface
- mimeType
- byteSize
- storageBucket
- storageObjectKey
- visibility
- createdAt
- moderationStatus
- uploadSource

The frontend must never create trusted metadata by itself.

## Storage Boundary

Object Storage must stay backend-only.

Flutter must never receive:

- storage secret
- permanent token
- bucket secret
- service role key
- raw database credential

Flutter may only receive a short-lived signed upload URL after all gates are open.

## Required Disabled Gates

The following env flags must default to false:

- CIDENTIA_UPLOAD_ENABLED
- CIDENTIA_OBJECT_STORAGE_ENABLED
- CIDENTIA_OBJECT_STORAGE_WRITE_ENABLED
- CIDENTIA_SIGNED_URL_ENABLED
- CIDENTIA_MEDIA_METADATA_WRITE_ENABLED

A production-capable upload path requires all relevant gates to be explicitly enabled.

## Locked Until Later

M11D does not open:

- file picker
- real upload
- Object Storage write
- signed upload URL
- media metadata write
- public media read
- replay recording
- RTMP/WebRTC
- wallet/payment
- CidenBridge live calls
- fake CID/session/token

## Next Safe Milestones

M11E should add a disabled media metadata schema/contract document or skeleton.

M11F may add a disabled signed URL skeleton that still returns locked responses.

M11G may connect verified CID checks to upload request boundaries without opening upload.

Real staging upload can only start after the above contracts are sealed.
