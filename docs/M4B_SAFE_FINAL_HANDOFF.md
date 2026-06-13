# M4B Safe Final Handoff

Branch: m4b-safe-cidendb-otp-boundary
Sealed commit before this handoff: 5e33685 Connect safe CidenDB OTP bridge and restore Studio panel

Current sealed result:
- CidenDB OTP sign-in works through the safe bridge boundary.
- No fake CID/session is allowed.
- Cidentia.Live frontend does not generate OTP.
- Cidentia.Live frontend does not verify OTP directly with CidenDB.
- Frontend uses a local/dev bridge origin through dart-define for now.
- Verified CID session is kept inside the app as host-only session state.
- Public Feed/Search/Reels remain browsable.
- Chats, Live Studio, Profile and protected creator actions require verified CID.
- Live Studio right panel is restored and must stay intact:
  Chat / Destinations / Status / Focus.
- The old image/hotspot entry screen was replaced with a clean stable entry page.
- Separate OTP dialog was removed.

Important:
Do not judge M4B-safe with a blind full `flutter analyze`.

Reason:
This repo currently contains reference/legacy source folders such as:
- _reference/flutter-instagram-offline-first-clone-main
- old packages/env generated-file references
- old packages/storage secure_storage references

A full `flutter analyze` scans those areas and reports unrelated errors.
Those errors are not caused by M4B-safe.

For this milestone, use:

powershell -ExecutionPolicy Bypass -File .\tool\m4b_safe_check.ps1

Do not patch Studio/Chat/layout while working on CidenDB backend bridge.
Do not add random cards, placeholder panels, or filler UI.
Do not reintroduce fake sessions.
Do not put CidenDB secrets/tokens in Flutter.
Do not connect Flutter directly to CidenDB upstream.
Next production step is to replace the local dev bridge with a deployable backend route.
