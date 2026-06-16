# M5B Create / Upload / Publish boundary QA seal

## Seal purpose

This document seals the M5A Create upload/publish boundary work.

## Current sealed state

M5A added protected Upload Media and Publish Media boundary actions inside the existing Create preview sheet.

Existing Create preview flow remains:

- Create preview sheet
- Post / Reel / Story mode selection
- local photo/video picker preview
- local media preview frame
- caption draft field
- Save local draft
- upload/publish protected boundary actions

## Protected boundary behavior

Upload Media and Publish Media are protected actions.

Expected behavior:

- guest / unverified users receive the CidenDB/CID required notice
- verified CID users receive the verified-but-production-locked notice
- no real file picker is opened
- no upload is started
- no storage route is called
- no backend publish route is called
- no fake success is created

## Locked production boundaries

The following remain closed:

- real media upload
- file system picker for production media
- image/video storage
- backend publish route
- production post creation
- realtime feed publishing
- CidenDB token exposure
- wallet/payment/token/blockchain
- RTMP/live stream
- fake upload success
- fake published post

## Architecture rule

Create local preview is allowed as a public/local surface.

Real Upload and Publish remain protected production actions and must require a verified CidenDB/CID session before any future backend route is opened.

Cidentia.Live must not create identity, store frontend secrets, expose raw CidenDB tokens, or simulate production publishing.

## QA expectation

After M5A:

- Create preview opens from desktop sidebar and mobile/top create button
- Upload / Publish boundary card is visible
- Upload Media opens protected action notice
- Publish Media opens protected action notice
- Save local draft still works as local-only preview
- no backend/storage/upload/publish action is opened

## Seal decision

M5B is a QA/documentation seal only. It does not add new runtime behavior.
