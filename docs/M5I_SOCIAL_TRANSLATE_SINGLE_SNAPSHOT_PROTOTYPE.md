# M5I — Social Translate Single Snapshot Prototype

## Purpose

M5I opens the first real Android screen-capture prototype for Social Translate.

The prototype requests Android's official screen-capture consent and captures one snapshot frame only.

## Real Capability Opened

- Android MediaProjection consent flow.
- One user-approved screen snapshot.
- Immediate resource release after the first frame.

## Still Locked

- OCR is not started.
- Overlay permission is not requested.
- Accessibility service is not used.
- No backend upload happens.
- Screenshot is not stored permanently.
- WhatsApp and Telegram are not automated.
- No message is sent automatically.

## Safety Response Contract

Channel:

`cidentia.live/social_translate_snapshot`

Method:

`startSingleSnapshotPreview`

Successful response:

- ok: true
- code: SOCIAL_TRANSLATE_SINGLE_SNAPSHOT_CAPTURED
- mediaProjectionOpened: true
- screenCaptured: true
- ocrStarted: false
- overlayOpened: false
- automaticSend: false
- snapshotStored: false
- backendUpload: false

## Seal Rule

This is a one-shot capture prototype only. It must not be expanded into continuous capture, OCR, overlay or automation without a separate milestone and review.
