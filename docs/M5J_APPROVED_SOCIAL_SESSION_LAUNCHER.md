# M5J — Approved Social Session Launcher

## Purpose

M5J adds an approved Social Translate session layer and social app launcher.

The user can start an approved session, open WhatsApp, Telegram, Discord or X, and return to Cidentia for local reply preparation.

## Added

- Approved social session card.
- Open WhatsApp / Telegram / Discord / X buttons.
- Android native app launcher through MethodChannel.
- Local reply composer.
- Copy reply action.
- Session stop action.
- Android package visibility entries for supported social apps.

## Opened Capability

- Launching an installed social app or fallback URL.
- Keeping user-controlled Social Translate session state.
- Local reply preparation inside Cidentia.

## Still Locked

- No WhatsApp login by Cidentia.
- No account/session token collection.
- No hidden message reading.
- No OCR.
- No overlay bubble.
- No Accessibility service.
- No automatic send.
- No simulated taps.
- No backend upload.

## Safety Rule

Cidentia can assist the user after explicit approval, but it must not control the user's social account or send messages without the user.

## Next Milestones

- M5K: OCR preview on approved snapshot.
- M5L: TR / EN / DE translation from OCR text.
- M5M: visible overlay reply layer.
