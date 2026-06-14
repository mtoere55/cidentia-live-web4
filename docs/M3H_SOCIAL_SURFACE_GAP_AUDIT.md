# M3H Social Surface Gap Audit

Date: 2026-06-14
Base branch: m3g-social-action-paths-preview
Starting point: cab0358 Document M3G final QA handoff

## Purpose

M3H exists because M3G only completed the Feed/Post local action preview surface.

Cidentia.Live still needs a full social surface audit before more polish is added.

This document maps the remaining local UI gaps before backend, CID, wallet, payment, RTMP, or real live streaming are connected.

## Current surface map

### Feed/Post

Status: partially polished in M3G.

Completed:

- Follow toggle
- Like toggle
- Save toggle
- Comment sheet
- Local comment composer
- Share sheet
- Options sheet
- Scroll-safe bottom sheets
- Post action overflow fix

Remaining:

- Real share route is not connected.
- Share sheet remains local preview.
- Post detail route is not built.
- Feed preferences/report flows are placeholders.

### Chats / Messages

Observed file:

- lib/local_social/widgets/local_chat_detail.dart

Current state:

- Inbox panel exists.
- Conversation panel exists.
- Message area exists.
- Message input bar exists.
- Layout supports compact and wide screens.

Remaining:

- Chat selection behavior is not product-complete.
- Message send should become local-only interactive preview before backend.
- Share-to-chat from Feed currently shows preview only.
- Reply/swipe behavior can be studied from the clone reference.
- Chats should remain behind CID gate when protected app behavior is active.

### Stories

Observed file:

- lib/local_social/widgets/local_stories_bar.dart

Current state:

- Horizontal stories bar exists.
- Avatar rings exist.
- Live badge exists.
- Proof dot exists.

Remaining:

- Story tap/open viewer is not implemented.
- Replay/live memory surface is not implemented.
- Create story is only visual.
- Clone stories carousel/viewer should be studied as reference.

### Reels

Observed file:

- lib/local_social/widgets/local_reels_page.dart

Current state:

- Reels page exists.
- Mouse wheel and keyboard scrolling exist.
- Up/down controls exist.
- Counter exists.
- Action rail is visual.

Remaining:

- Reel like/comment/share/save actions are not interactive.
- Reel comment/share sheet is not connected to the Feed sheet pattern.
- No video play/pause/progress behavior yet.
- Clone reel/video player should be studied as reference.

### Profile

Observed file:

- lib/local_social/widgets/local_profile_grid.dart

Current state:

- Profile hero exists.
- Stats cards exist.
- Edit Profile / Wallet / Proof action row exists.
- Tabs exist.
- Grid exists.

Remaining:

- Action buttons are not interactive.
- Tabs do not switch content.
- Grid tile open/detail is not implemented.
- Profile protected actions must respect CID gate later.
- Wallet/proof must remain preview until proper CidenDB/CID boundary is resumed.

### Live Studio

Observed file:

- lib/local_social/widgets/local_live_studio_page.dart

Current state:

- Live Studio exists as a local preview surface.
- Desktop and mobile layouts exist.
- Destination, translation, liveReady states exist.

Remaining:

- Real RTMP/live backend is not connected.
- Live Studio should remain protected creator tooling.
- Do not mix Live Studio backend work into M3H social surface polish unless explicitly planned.

## Recommended M3H package order

### M3H-A: Documentation and scope correction

- Correct M3G handoff wording.
- Add this gap audit.
- No code behavior changes.

### M3H-B: Reels local action polish package

- Make Reel like/save local toggles.
- Reuse local share/comment sheet pattern if safe.
- Keep it local-only.
- No backend.

### M3H-C: Stories local viewer preview package

- Story tap opens local viewer sheet/page.
- Create story remains preview.
- Live/replay labels remain local.

### M3H-D: Chats local interaction preview package

- Message input can add a local preview message.
- Share-to-chat preview can route to the chat surface later.
- Keep protected behavior plan separate.

### M3H-E: Profile action polish package

- Profile action buttons open safe local preview sheets.
- Tabs can switch locally.
- Wallet/proof remain locked preview.

## Safety rules

- Do not connect backend.
- Do not connect CidenDB live flow.
- Do not touch M4B stash unless explicitly returning to M4B.
- Do not add clone auth/session/token logic.
- Do not add wallet/payment/RTMP/live connections.
- Do not add random filler/test cards.
- Keep each package screen-focused and visually checked before commit.
