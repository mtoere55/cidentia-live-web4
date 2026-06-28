# M23G - Media listing and read route audit

Status: completed.

## Purpose

M23G audits the existing media/profile listing routes after M23F created persistent server-only video media records.

The goal is to determine how persisted media metadata can be read safely before opening Flutter video rendering or signed media read URLs.

## Existing route files found

The server artifact contains these relevant route files:

- api/profile/media.js
- api/profile/me.js
- api/profile/posts.js
- api/profile/profileTabBoundary.js
- api/profile/reels.js
- api/profile/stats.js
- api/profile/update.js

Relevant backend modules include:

- server/profile/profileTabsRepository.js
- server/profile/profileStatsRepository.js
- server/media/mediaMetadataRepository.js

## Existing profile tab route behavior

The existing M20C profile tab route smoke uses:

- api/profile/posts
- api/profile/reels
- api/profile/media

It verifies:

- posts route returns PROFILE_POSTS_READ_OK
- reels route returns PROFILE_REELS_READ_OK
- media route returns PROFILE_MEDIA_READ_OK
- itemsRead is true
- publicMediaUrlsCreated is false
- fakeItemsCreated is false
- returned items have publicMediaUrl null

This means the current listing layer is safe as a metadata-only boundary and does not create public media URLs.

## Persistent M23F test records

Test CID:

Cid-M23F-Persistent-Video-Smoke

Safe DB listing result:

- ok: true
- count: 2
- secretsExposed: false

Each listed item had:

- idPresent: true
- ownerCid: Cid-M23F-Persistent-Video-Smoke
- mediaSurface: profile_cover
- mimeType: video/mp4
- byteSize: 24
- visibility: private
- moderationStatus: pending
- uploadSource: m17d_smoke
- createdAtPresent: true
- storageBucketHidden: true
- storageObjectKeyHidden: true

## What this proves

- Persistent M23F media records can be read from the database.
- The DB listing can return safe metadata without printing storage bucket or object key values.
- Existing profile tab routes already support safe metadata-only reads.
- Existing route smoke history confirms public media URLs remain disabled/null.
- No signed read URL was created.
- No media render path was opened.
- No Flutter video upload/render path was opened.
- No storage secret was exposed.

## Important limitation

M23F created media assets with surface:

profile_cover

This happened because the metadata repository currently allows media surfaces:

- profile_cover
- avatar
- post
- reel
- live_replay

The upload request route accepts reel_video, but media metadata repository normalizes/stores only allowed metadata surfaces. A future real video flow should align upload surface and metadata surface, likely mapping:

- reel_video -> reel
- post_video -> post
- profile_cover -> profile_cover
- profile_avatar -> avatar
- live_replay -> live_replay

## Current status after M23G

Completed backend write chain:

- signed video upload URL
- Object Storage PUT
- media metadata DB write
- persistent media record
- safe DB metadata list

Still not completed:

- signed media read URL
- public media URL
- Flutter video picker upload
- Flutter video playback/render
- profile/reels UI connected to persisted media
- PM2 production process started with upload/write/read gates

## Next milestone

M23H - Profile media route smoke with persisted M23F CID.

M23H should call api/profile/media for Cid-M23F-Persistent-Video-Smoke and verify the route returns the two persisted media records safely, with publicMediaUrl null and without exposing storage bucket, object key, signed URL, or secrets.
