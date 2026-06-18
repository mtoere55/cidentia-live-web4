# M5F — Social Translate Android Permission Stub

## Purpose

M5F adds a visible permission-readiness stub to the Social Translate Layer preview.

This milestone does not open real Android native permissions. It only explains the future permission boundary to the user.

## UI Scope

The Social Translate Layer sheet now shows an Android permission stub card covering:

- Screen capture permission planned, but not requested.
- Floating overlay planned, but not requested.
- Accessibility automation locked.
- Reply sending remains user-approved only.

## Locked Boundaries

This milestone does not add or request:

- MediaProjection.
- SYSTEM_ALERT_WINDOW overlay permission.
- Accessibility service.
- OCR.
- Foreground service.
- Background capture.
- WhatsApp or Telegram automation.
- Backend translation call.
- Automatic message sending.
- Hidden screen reading.

## Future Rule

The next native Android milestone must still be explicit and reversible. The first real native step should only explain permission flow or request a single user-approved snapshot. It must not capture continuously, run OCR, or automate social apps without a separate review.

## Seal

M5F is a UI and documentation stub only.
