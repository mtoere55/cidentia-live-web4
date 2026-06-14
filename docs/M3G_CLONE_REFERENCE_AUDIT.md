# M3G Clone Reference Audit

Date: 2026-06-14
Active branch: m3g-social-action-paths-preview
Active commit: 90a818c Add local social action paths preview

## Reference clone path

C:\PROJELER\cidentia-live-web4_reference\flutter-instagram-offline-first-clone-main\flutter-instagram-offline-first-clone-main

The clone is a read-only reference source. It must stay outside Git and must not be copied blindly into Cidentia.Live.

## Purpose

Cidentia.Live is not becoming the clone. The clone is used only to study mature social-app behavior and adapt useful patterns to the Cidentia.Live product direction.

## Useful reference zones

The following clone areas are useful for product and UI behavior study:

- comments
  - comment page
  - comment view
  - comment input controller
  - comment text input
  - replied comment
- chats
  - chat page
  - message bubble
  - message input controller
  - message text field
  - replied message bubble
  - swipeable message
- feed / post
  - post view
  - post preview
  - post popup
  - post popup dialog
  - post likes count
  - post likers in followings
  - share post
- feed / post / video
  - post video player
  - video player view
  - inherited video player widget
- reels
  - reels view
  - reel view
  - vertical action button
- stories
  - stories page
  - stories carousel
  - story avatar
  - user stories avatar
- navigation
  - bottom navigation structure
- l10n
  - labels for likes, comments, reels, stories, share, chat

## Auth / identity boundary

The clone auth area may be studied for visual and UX patterns only, such as form layout, loading state, disabled buttons, and error feedback.

The clone auth logic must not become the Cidentia.Live identity system.

Cidentia.Live identity remains:

- CidenDB as identity / databank authority
- CidentiaApp as onboarding / registration authority
- Cidentia.Live accepts verified CID session only
- No clone password login
- No clone signup authority
- No clone forgot-password flow
- No clone token/session model
- No Supabase/Firebase/Google auth replacement
- No frontend OTP generation
- No fake verified session

## Current Cidentia.Live M3G state

M3G already added local social action paths:

- Follow toggle
- Like toggle
- Save toggle
- Comment sheet
- Share sheet
- Post options sheet

These are local preview behaviors only.

No backend, CidenDB, wallet, payment, RTMP, or real live stream connection is opened in M3G.

## Gaps found from clone comparison

Near-term M3G gaps:

1. Comment sheet polish
   - Add a more realistic local comment composer.
   - Keep it local-only.
   - No backend.
   - No CID/session requirement for preview behavior.

2. Share sheet polish
   - Improve local share preview.
   - Add clearer copy-link/send-to-preview rows.
   - Keep it local-only.

3. Post options polish
   - Improve local options menu.
   - Keep product-safe preview actions only.

Later gaps:

1. Chat UI polish
   - Use clone chat widgets only as UI reference.
   - Keep Chats behind CID gate in product behavior.

2. Stories / replay preview
   - Use clone story avatar/carousel as future reference.

3. Video / Reels player polish
   - Study clone video player behavior before adding real video controls.

## Patch plan

M3G Patch 3:
Create this audit document and remove temporary scan files.

M3G Patch 4:
Polish local comment sheet using clone comments as reference.

M3G Patch 5:
Polish local share/options sheets using clone feed/post widgets as reference.

## Safety rules

- Do not copy clone auth logic.
- Do not import clone backend/session/token logic.
- Do not add random filler cards.
- Do not reopen removed right empty panel.
- Do not touch M4B CidenDB stash during M3G.
- Do not connect wallet/payment/RTMP/live backend.
- Read real files before each patch.
- Keep patches small and reversible.
