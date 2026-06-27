# M21A — Media URL Policy Helper Disabled

Status: Helper only, disabled by default.

## Purpose

M21A adds a backend media URL policy helper without generating public or signed URLs.

## Added helper

- `server/media/mediaUrlPolicy.js`

## Added check

- `scripts/m21a-media-url-policy-disabled-check.js`

## Default behavior

The default policy returns:

- `MEDIA_URL_GENERATION_DISABLED`
- `publicMediaUrl:null`
- `publicMediaUrlsCreated:false`
- `storageSignedUrlCreated:false`
- `storageBucketExposed:false`
- `storageSecretExposed:false`
- `frontendSecretExposed:false`
- `secretsExposed:false`

## Required future gates

A future media URL may only be considered when all gates pass:

- media asset exists
- owner CID exists
- storage bucket exists
- storage object key exists
- media URL generation is explicitly enabled
- surface is explicitly allowed
- visibility is allowed
- moderation status is allowed
- runtime URL generation is explicitly enabled

## Locked boundaries preserved

M21A does not open:

- public media URL generation
- signed URL generation
- Object Storage client call
- Object Storage public access
- Object Storage secret exposure
- frontend secret
- API route
- Flutter real media rendering
- Flutter real posts rendering
- Flutter real reels rendering
- new Media tab
- fake posts
- fake reels
- fake media assets
- fake counters
- public feed publishing
- public upload/media route
- fake CID/session/token
- wallet/payment/token/blockchain
- CidenBridge production route
- RTMP/WebRTC/live stream
- replay recording
