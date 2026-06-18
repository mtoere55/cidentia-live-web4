# M5G — Social Translate Local Snapshot Design Seal

## Purpose

M5G seals the safe design boundary for the future Social Translate local snapshot flow.

This milestone is documentation only. It does not add Android native code, MediaProjection, OCR, overlay permission, backend calls or social app automation.

## Current State

M5D added the Social Translate Layer preview in Flutter.

M5E documented the Android bridge plan.

M5F added the permission stub UI and documented the permission boundary.

M5G confirms the next safe native direction before any real screen capture code is opened.

## Future Snapshot Flow

The first real native snapshot milestone must be user-triggered and single-shot only.

Expected future flow:

1. User opens Cidentia Social Translate.
2. User reads the permission explanation.
3. User taps Start single snapshot.
4. Android shows the official screen capture permission dialog.
5. User approves.
6. Cidentia captures one current screen snapshot.
7. Snapshot is shown inside Cidentia for review.
8. No OCR runs yet.
9. No backend upload happens.
10. No file is stored permanently.
11. User can discard the snapshot.
12. Session ends immediately.

## Strict M5G Boundary

M5G does not open:

- MediaProjection.
- OCR.
- Overlay bubble.
- Accessibility service.
- Foreground service.
- Background capture.
- Continuous screen recording.
- WhatsApp automation.
- Telegram automation.
- Automatic message sending.
- Cloud translation.
- Screenshot storage.
- CidenDB/CidenBridge production integration.

## Design Rules For Future Native Snapshot

The first native implementation must follow these rules:

- Capture only after explicit Android system permission.
- Capture only one snapshot.
- Show clear active-session UI.
- Provide stop/discard button.
- Do not capture in background.
- Do not store screenshot by default.
- Do not upload screenshot by default.
- Do not read or send messages automatically.
- Do not simulate taps or send buttons.
- Do not bypass Android consent dialogs.

## Privacy Position

Social Translate must be user-controlled.

Cidentia should behave like a visible translation assistant, not a hidden monitoring tool.

The user must always know when screen capture is active.

## Next Safe Step

M5H may become:

Social Translate Native Snapshot Stub

Recommended scope:

- Add Android bridge method names only.
- Add Flutter-side disabled/start button state.
- Do not call MediaProjection yet.
- Do not request permission yet.
- Do not capture anything yet.

Or, if native code is approved:

M5H could become:

Social Translate Single Snapshot Prototype

Recommended scope:

- Android-only.
- One user-approved snapshot.
- No OCR.
- No backend.
- No overlay.
- No automation.
- No storage.

## M5G Seal

This milestone seals the design boundary only.

No production capability was opened.
No sensitive permission was requested.
No social app was automated.
No screen content was captured.
