# M4B Safe CidenDB OTP Boundary Guard

Status:
This document protects the Cidentia.Live app shell before any new CidenDB OTP bridge work.

Current safe base:
628e93f Document video reference candidates

Branch:
m4b-safe-cidendb-otp-boundary

Core rule:
CidenDB sign-in work must not damage the Cidentia.Live product shell.

Cidentia identity architecture:
- CidenDB is the identity and databank authority.
- CidentiaApp is the onboarding and registration authority.
- Cidentia.Live must not create its own identity authority.
- Cidentia.Live must not create password login, local registration, Supabase auth, Google sign-in, Firebase auth, or a clone auth system.
- Cidentia.Live may only accept a verified CidenDB/CID session.

Public/protected behavior that must be preserved:
- Guest users may browse Feed, Search, and Reels.
- Guest users must not open Chats, Live Studio, Profile, Wallet, Proof, RTMP management, destination management, upload, or message actions.
- Post actions such as Like, Comment, Share, and Save must route to the central CidenDB/CID protected action panel when no verified CID session exists.
- Live Studio is not a public watch page. It is a protected creator studio and must stay gated.
- Profile is account management and must stay gated for guests.
- Chats are protected and must stay gated for guests.

Forbidden in M4B:
- Do not edit Live Studio layout or behavior.
- Do not edit Chat or message layout.
- Do not remove or rebuild Studio panels.
- Do not add random placeholder cards, filler blocks, test cards, or "coming soon" panels.
- Do not restore the removed right-side Cidentia Center / Wallet / Proof / Trust empty panel.
- Do not open protected routes for guests.
- Do not put localhost backend errors directly into the user-facing entry UI.
- Do not hardcode frontend secrets.
- Do not store raw CidenDB tokens in Flutter UI state.
- Do not fake a verified CID session as if it were real.
- Do not use the Instagram clone auth, password, token, Supabase, Firebase, or Google sign-in logic.

Allowed in M4B:
- Read existing files.
- Add backend bridge boundary documentation.
- Add backend skeleton only if it does not affect the Flutter shell.
- Add safe frontend boundary wiring only after the backend contract is clear.
- Keep UI messages calm and non-breaking.
- Keep the entry panel inside the existing Cidentia ecosystem entry screen.
- Keep public browsing intact.
- Keep protected actions gated.

Required workflow:
1. Check branch and status.
2. Read the current files before coding.
3. Patch only a narrow scope.
4. Run dart format on changed Dart files.
5. Run flutter analyze on changed files.
6. Run git diff --check.
7. Run flutter run -d windows -t lib/main_local.dart for UI-sensitive changes.
8. Confirm protected behavior manually.
9. Commit only after checks pass.
10. Push only after the commit is clean.

Safe next step after this guard:
Read the current CidenDB entry, session, protected action, and app shell files.
Do not code until the file review is complete.
