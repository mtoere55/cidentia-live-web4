# M17A — Profile Metadata Save Boundary Plan

Status: Planning boundary only.

## Purpose

M17A defines the safe next step after M16F and M16G.

M16F proved that Flutter can complete a controlled real PUT to Object Storage through a smoke-only signed upload route.

M16G improved the user experience by showing a local profile cover preview and a visible local preview badge while keeping production upload and profile persistence locked.

M17A does not enable persistence. It documents how profile cover metadata and profile save should be opened later without breaking Cidentia.Live security boundaries.

## Current confirmed state

The current app can:

- select a profile cover image
- show the selected image as a local profile hero preview
- show a `Local cover preview` badge
- request upload boundary status
- complete a controlled signed PUT only through smoke-only test routing
- keep normal public upload disabled

Public upload route remains locked and returns:

- `UPLOAD_ROUTE_DISABLED`
- `uploadLocked:true`
- `objectStorageWrite:false`
- `uploadCreated:false`
- `signedUploadUrlCreated:false`
- `mediaMetadataCreated:false`

## Required future boundary

A future profile save flow must be split into separate guarded steps:

1. verified CID session check
2. profile ownership check
3. Object Storage signed upload request
4. Flutter PUT to signed URL
5. media metadata write
6. profile cover reference update
7. profile read refresh

Each step must return explicit status codes and must be independently lockable.

## Required tables

The existing migrated database already includes:

- `cidentia_profiles`
- `cidentia_media_assets`

The future profile cover save should use these tables only after DB write gates are explicitly enabled.

## Future media metadata fields

A future `cidentia_media_assets` write should store only safe metadata such as:

- owner CID
- media surface: `profile-cover`
- storage bucket
- storage object key
- MIME type
- byte length
- upload status
- created timestamp

It must not store:

- signed upload URL
- Object Storage secret
- access key
- raw token
- refresh token
- frontend secret
- fake CID

## Future profile update fields

A future `cidentia_profiles` update may store:

- owner CID
- display name
- handle
- avatar initials
- hero headline
- hero intro
- cover media asset reference

It must not create a profile for guests or CID-less users.

## Required guards

The future write path must require:

- verified CID identity
- `CIDENTIA_DATABASE_ENABLED=true`
- profile write gate enabled
- media metadata write gate enabled
- Object Storage write gate enabled
- signed URL gate enabled

Default behavior must remain locked.

## Required locked responses

When gates are disabled, APIs must keep returning explicit locked codes such as:

- `PROFILE_CID_REQUIRED`
- `PROFILE_WRITE_DISABLED`
- `MEDIA_METADATA_WRITE_DISABLED`
- `UPLOAD_ROUTE_DISABLED`
- `OBJECT_STORAGE_PRESIGNER_DISABLED`
- `DATABASE_DISABLED`

## Frontend rule

Flutter may show local preview immediately, but must clearly label it as local or unsaved until the backend confirms metadata/profile persistence.

Flutter must never receive:

- database URL
- Object Storage access key
- Object Storage secret
- raw CidenDB token
- server-only env values

## Safe future implementation order

Recommended future order:

1. M17B — backend media metadata repository boundary
2. M17C — profile cover metadata API disabled route
3. M17D — profile cover save Flutter boundary, still locked by default
4. M17E — local smoke for metadata write with test CID only
5. M17F — guarded profile cover persistence smoke
6. M17G — final QA seal before any public enablement

## Locked boundaries preserved by M17A

M17A does not open:

- production upload route
- metadata database write
- profile database write
- public media publish
- Object Storage public URL exposure
- frontend Object Storage secrets
- fake CID/session/token
- wallet/payment/token/blockchain
- CidenBridge production route
- RTMP/WebRTC/live stream
- replay recording

## Result

M17A is a planning seal for the next persistence boundary.

No runtime behavior changes are made in this milestone.
