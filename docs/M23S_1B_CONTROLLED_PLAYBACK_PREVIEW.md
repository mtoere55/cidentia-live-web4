# M23S-1B - Controlled playback preview

Status: completed.

## Scope

This milestone adds controlled playback preview for safe profile media.

It does not open upload, write, live streaming, payment or wallet features.

## What changed

- Added `video_player` as a direct Flutter dependency.
- Added controlled playback launcher to the profile grid preview sheet.
- The user must tap `Open controlled preview` before a signed URL is requested.
- The user must tap `Play preview` before playback starts.
- Autoplay remains off.
- The signed media read URL is passed only into `VideoPlayerController.networkUrl`.
- The signed URL is not printed, logged or displayed.
- Bucket name and object key are not displayed.

## Safety rules

The following remain closed or hidden:

- signed URL display
- bucket exposure
- object key exposure
- autoplay
- upload/write
- metadata write
- live streaming
- payment/wallet
- CidenBridge live call

## Expected test

1. Run Flutter with:

   flutter run -d chrome --dart-define=CIDENTIA_LIVE_API_BASE_URL=https://api.cidentia.live

2. Open profile grid.
3. Open a REAL MEDIA item.
4. Tap `Open controlled preview`.
5. Tap `Play preview`.
6. Existing smoke video should play through the public signed read URL route.
