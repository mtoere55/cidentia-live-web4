# M3AV — Create / Media Final Handoff

## Status

M3AV is the final handoff for the local Create / Draft / Media Picker preview track.

Baseline before this handoff:

- `5953244 Merge M3AU local media picker QA seal`
- Repository is clean.
- M4B / CidenDB OTP work remains parked in stash and must not be applied unless explicitly returning to that track.

## Completed Milestones

This handoff closes the following local preview milestones:

- M3AP — Mobile Create sheet
- M3AP-B — Desktop Create entry
- M3AQ — Local draft polish
- M3AR — Create / Draft QA seal
- M3AS — Media picker readiness seal
- M3AT — Local media picker UI preview
- M3AU — Local media picker QA seal

## Current Create Surface

The project now has an approved local Create surface on both mobile and desktop.

### Mobile

- Create entry exists in the mobile top app bar.
- It opens the local Create preview sheet.
- It uses the existing approved app shell path.

### Desktop

- Compact Create preview entry exists in the left sidebar.
- It opens the same local Create preview sheet.
- No right panel, filler card, debug card, or temporary test surface was added.

## Current Create Sheet

The Create sheet now supports:

- Post / Reel / Story mode selection
- Active visual state for the selected mode
- Local media preview area
- Photo / Video local picker preview chips
- Local thumbnail preview choices
- Selected media label state
- Preview text that updates by mode and selected media
- Writable caption input
- Save local draft action

The Save local draft action remains local-preview only.

## Locked Boundaries

The following were not opened:

- Real file picker
- Real media upload
- Real post / reel / story publishing
- Storage or CDN
- Backend publish API
- CidenDB / OTP / verified session changes
- RTMP
- Stream key
- Real live streaming
- Wallet
- Token
- Payment
- Blockchain
- Minting
- NFT creation
- Fake success
- Fake balance
- Fake reward
- Fake login
- Temporary test buttons
- Debug cards
- Placeholder filler UI

## QA Rule Going Forward

Testing must use commands and existing approved UI paths only:

- `flutter analyze`
- `git diff --check`
- `flutter run -d windows -t lib/main_local.dart`
- Visual QA through existing mobile and desktop Create preview entries

Do not add temporary test buttons, test cards, debug widgets, or filler UI just to test behavior.

## Reference Clone Rule

The Flutter Instagram reference clone may still be studied only as a read-only UI/UX reference.

Allowed reference areas:

- gallery picker UX
- media preview UX
- caption flow
- post preview
- reel preview
- story preview
- video visibility/playback behavior

Forbidden reference areas:

- auth
- login
- registration
- Supabase
- Firebase
- Google sign-in
- token/session storage
- backend/storage implementation
- identity flow

Cidentia.Live must keep its own CidenDB/Cidentia identity architecture.

## Next Safe Options

After this handoff, the next possible tracks are:

### Option 1 — Stop Here

Recommended if the current local Create / Draft / Media preview is visually acceptable.

### Option 2 — Real Media Picker Planning

A future planning milestone may inspect packages and platform requirements before adding any real picker.

No real upload should be opened in that step.

### Option 3 — Local Draft State Persistence

A future local-only milestone may keep draft state temporarily inside the app session.

It must not write to backend, storage, CidenDB, wallet, token, blockchain, or real publishing.

### Option 4 — CidenDB Protected Publish Planning

Only when explicitly approved, publishing can be planned behind verified CidenDB/CID session gates.

M4B / CidenDB OTP stash must stay parked until that track is explicitly reopened.

### Option 5 — Backend Upload / Storage

Only after identity, publish contract, storage contract, and security boundaries are approved.

### Option 6 — Real Live Streaming

RTMP, stream key, ingest, destination routing, and real live state remain future milestones.

## Seal Result

M3AV seals the Create / Draft / Local Media Picker preview track.

The local product surface is ready for handoff to a new chat or future milestone without opening real upload, backend, CidenDB, RTMP, wallet, payment, token, blockchain, minting, or fake success behavior.
