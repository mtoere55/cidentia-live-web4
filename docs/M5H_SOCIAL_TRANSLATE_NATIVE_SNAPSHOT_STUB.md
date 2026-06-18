# M5H — Social Translate Native Snapshot Stub

## Purpose

M5H wires the Flutter Social Translate preview to an Android native MethodChannel stub.

This milestone proves the bridge contract only. It does not request permissions and does not capture the screen.

## Added Contract

Channel:

`cidentia.live/social_translate_snapshot`

Method:

`startSingleSnapshotPreview`

Expected safe response:

- ok: false
- code: SOCIAL_TRANSLATE_SNAPSHOT_STUB_ONLY
- mediaProjectionOpened: false
- screenCaptured: false
- ocrStarted: false
- overlayOpened: false
- automaticSend: false

## Flutter UI

The Social Translate Layer sheet includes a Native snapshot bridge stub card.

The user can tap Check native stub.

On Android, the native stub returns a safe closed response.

On desktop platforms, Flutter returns a bridge-not-available safe response.

## Locked Boundaries

M5H does not open:

- MediaProjection
- Screen capture
- OCR
- Overlay permission
- Accessibility service
- Foreground service
- Background capture
- Backend translation
- WhatsApp or Telegram automation
- Automatic message sending

## Seal

M5H is bridge wiring only.

No sensitive capability was opened.
