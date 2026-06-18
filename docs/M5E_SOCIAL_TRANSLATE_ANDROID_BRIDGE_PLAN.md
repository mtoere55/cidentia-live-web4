# M5E — Social Translate Android Bridge Plan

## Purpose

M5D added the safe Flutter preview for Social Translate Layer.

M5E defines the future Android native bridge plan for translating social app screens such as WhatsApp, Telegram, Discord, X, Instagram or Facebook while keeping Cidentia.Live safe.

This milestone is documentation only. It does not open real screen capture, OCR, MediaProjection, overlay permission, backend calls, WhatsApp automation, message sending or hidden app access.

## Product Goal

The user opens Cidentia first, starts Social Translate mode, then opens another social app. Cidentia remains available as a small overlay/floating helper. The user can translate visible text on screen and prepare a reply suggestion.

The final send action must stay with the user. Cidentia must not automatically send messages into WhatsApp, Telegram or any other social platform.

## Safe User Flow

1. User opens Cidentia.Live / Cidentia Social Translate.
2. User taps Start Social Translate.
3. Android asks for explicit screen capture permission.
4. User approves only for the current session.
5. User opens WhatsApp, Telegram, Discord, X or another app.
6. Cidentia reads visible text from user-approved screen snapshots.
7. OCR extracts text from the snapshot.
8. Translation engine translates between Turkish, English and German.
9. Cidentia shows a floating translation card or bubble.
10. User may copy a reply suggestion.
11. User manually pastes/sends the reply.

## Android Native Components

Future implementation may require:

- MediaProjection API for user-approved screen capture.
- Foreground service for active translation session.
- Overlay permission for floating translation bubble.
- OCR engine for text extraction.
- Translation engine for TR / EN / DE.
- Clipboard helper for user-approved copy.
- Accessibility service only if explicitly needed and only after a separate safety review.

## Strict Boundaries

Cidentia.Live must not:

- Generate fake OTP or fake CidenDB sessions.
- Read private messages without explicit user approval.
- Capture screen in the background without visible session state.
- Send WhatsApp/Telegram messages automatically.
- Use hidden automation to press send buttons.
- Bypass Android permission dialogs.
- Store screenshots permanently by default.
- Upload sensitive screen content to backend without user consent.
- Act as a spam bot or raid bot.

## Privacy Rules

Default mode should be local-first.

If cloud translation is ever added, the UI must clearly show:

- What text leaves the device.
- Which service processes it.
- Whether screenshots are stored.
- How the user can delete session data.
- Whether CidenDB/CidenBridge identity is required.

No raw screen snapshot should be stored unless the user explicitly saves it.

## Cidentia Ecosystem Role

Cidentia.Live is the live/social surface.

CidenDB remains the identity authority.

CidenBridge may later become the integration layer for cross-app translation workflows.

Cidentia.Live should provide the visible user interface and safe session state, but should not become a hidden surveillance or automation tool.

## First Real Android Milestone Candidate

M5F could be:

Social Translate Android Permission Stub

Scope:

- Android-only permission explanation screen.
- No real OCR.
- No real MediaProjection stream yet.
- No overlay bubble yet.
- A native bridge placeholder describing required permissions.
- Clear user consent copy.

## Second Real Android Milestone Candidate

M5G could be:

Social Translate Local Snapshot Prototype

Scope:

- Request MediaProjection permission.
- Take one user-triggered snapshot only.
- Show the snapshot inside Cidentia.
- Do not run OCR yet.
- Do not store or upload the image.
- User can stop session immediately.

## Third Real Android Milestone Candidate

M5H could be:

Social Translate OCR Preview

Scope:

- Run OCR on one approved snapshot.
- Show detected text.
- No automatic translation yet.
- No message sending.
- No background capture.

## Fourth Real Android Milestone Candidate

M5I could be:

Social Translate TR / EN / DE Local Translation Preview

Scope:

- Translate detected text.
- Show translation card.
- Prepare reply suggestion.
- User manually copies reply.
- No automatic sending.

## Production Readiness Requirements

Before production use:

- Android permission review.
- Privacy policy update.
- CidenDB/CidenBridge identity boundary review.
- App store policy review.
- WhatsApp/Telegram/X automation policy review.
- Abuse prevention design.
- Clear user-facing stop button.
- Session indicator always visible.
- No hidden background capture.

## M5E Seal

This document only defines the plan.

No Android native code was opened.
No screen capture was opened.
No OCR was opened.
No overlay permission was opened.
No backend call was opened.
No WhatsApp bot was opened.
No automatic message sending was opened.
No CidenDB/CidenBridge production integration was opened.
