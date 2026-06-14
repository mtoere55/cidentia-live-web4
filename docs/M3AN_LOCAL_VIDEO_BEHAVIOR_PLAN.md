# M3AN - Local Video Behavior Plan

## Status

M3AN is a planning/documentation milestone only.

No Flutter video player is added in this milestone.
No media upload is added.
No post/reel publish pipeline is opened.
No backend, storage, CDN, RTMP, stream key, CidenDB OTP, wallet, token, payment, blockchain, minting, fake reward, or real live stream is opened.

Current branch:

m3an-local-video-behavior-plan

Base:

016e32b Merge M3AM video upload publish readiness audit

## Current product surface read

The current local social files were inspected before any decision:

- lib/local_social/widgets/local_reels_page.dart
- lib/local_social/widgets/local_post_card.dart
- lib/local_social/widgets/local_stories_bar.dart
- lib/local_social/widgets/local_live_studio_page.dart
- docs/M3AM_VIDEO_UPLOAD_PUBLISH_READINESS_AUDIT.md

## Current behavior summary

### Reels

Current Reels is already a local vertical viewer surface.

Observed behavior:

- Uses a ScrollController.
- Tracks active reel index with `_index`.
- Uses vertical viewport-style scrolling through SliverFillViewport.
- Supports keyboard navigation with arrow down, page down, space, arrow up and page up.
- Supports mouse, touch, trackpad and stylus drag devices.
- Desktop width >= 1280 shows a left live discovery sidebar.
- Viewer sees live discovery profiles and active room labels.
- No real video player is connected yet.
- No real video asset pipeline is connected yet.

### Feed post media

Current Feed post media is visual local preview only.

Observed behavior:

- `_PostMedia` uses a gradient media area.
- It shows CID proof / Local media badges.
- It shows a central play icon.
- Tapping opens local post detail sheet.
- It does not play a real video file.
- It does not load remote media.
- It does not upload or publish media.

### Stories

Current Story surface is local preview only.

Observed behavior:

- Story bar supports normal story, create story, live/replay surface, proof story and market replay labels.
- Tapping opens a local Story preview sheet.
- Create story explicitly says upload/backend will connect later.
- Local-only viewer text confirms no CidenDB, wallet, RTMP, payment or live streaming is connected.
- No real story video playback is connected yet.

### Live Studio

Current Live Studio is creator control center preview only.

Observed behavior:

- Desktop stage exists as local visual stage.
- Stage chat overlay can appear in focus mode.
- Room Mode strip exists for creator-side local mode selection.
- Destinations and translation panels are visual/control previews.
- Live ready / On Air state is local UI state only.
- No RTMP engine, stream key, real live backend or streaming service is connected.

## Reference clone read-only findings

The reference clone file list was inspected only for future UI/UX behavior ideas.

Useful future reference areas:

- lib/feed/post/video/view/video_player.dart
- lib/feed/post/widgets/post_video_player.dart
- lib/reels/reel/view/reel_view.dart
- lib/reels/view/reels_view.dart
- packages/instagram_blocks_ui/lib/src/widgets/inline_video.dart
- packages/instagram_blocks_ui/lib/src/smooth_video_progress_indicator.dart
- packages/gallery_media_picker/lib/src/presentation/pages/gallery_media_picker.dart
- packages/image_picker_plus/lib/src/video_layout/
- lib/user_profile/widgets/user_profile_create_post.dart
- screenshots/Posts/Post video media play.mov
- screenshots/Posts/Reels View.png
- screenshots/Media picker/Video picker View.png

Clone reference may help with:

- Feed video card behavior
- Reels video player behavior
- Visibility-based play/pause logic
- Long press pause behavior
- Progress indicator behavior
- Media picker UI flow
- Caption/media preview UI flow
- Mobile media surface arrangement

## Forbidden clone areas

The following must not be copied or adopted from the clone:

- Auth system
- Supabase/Firebase/Google login
- Token/session storage
- Backend/storage service
- Password/login/register screen
- User identity creation logic
- Repository/backend data model as product source
- Upload implementation
- Production media pipeline

Cidentia.Live must keep its own Cidentia/CidenDB/CID identity boundary.

## Local video behavior target

When local video preview is later approved, the correct behavior should be:

### Feed video behavior

- Feed video card should remain inside the current post card structure.
- Only visible media should play.
- Media should pause when scrolled off screen.
- Tapping media should open detail view, not start upload.
- Sound control should be local UI only at first.
- Progress indicator should be small and clean.
- No remote video URL should be required in the first local preview.

### Reels video behavior

- Only the active reel index should be considered playable.
- Non-active reels should be paused.
- Keyboard and mouse scroll behavior must remain preserved.
- Desktop live discovery sidebar must remain preserved.
- Mobile Reels surface must remain uncluttered.
- Long press pause can be planned later, but not rushed.
- Progress indicator should not block Cidentia live discovery UI.

### Story video behavior

- Story video should follow separate viewer logic.
- Story progress should be top/compact.
- Live/proof/replay labels must remain Cidentia-specific.
- Create story must remain preview-only until upload milestone.
- Story viewer must not open backend/storage in local preview.

### Live Room / Live Studio video behavior

- Live Room remains local preview until real streaming milestone.
- Live Studio stage remains local creator control center.
- Local On Air state must not pretend to be a real stream.
- RTMP/stream key must not be introduced in M3AN.
- Real live streaming must be a later separate milestone.

## Safe future implementation order

1. M3AO - Local Media Picker / Publish UI Preview
   - Visual-only create/publish surface.
   - No real upload.
   - No storage.
   - No backend.
   - No video player dependency unless explicitly approved.

2. M3AP - Local Feed/Reel Video Preview Polish
   - Add local-only sample video behavior if approved.
   - Keep assets local or mocked safely.
   - Preserve current Feed/Reels/Story/Live discovery structure.

3. M3AQ - Local Story Video Preview Polish
   - Add story progress/play preview if approved.
   - Keep create/upload disabled.

4. Later CidenDB/CID protected publish planning
   - Only after explicit approval.
   - Must decide verified CID session boundary first.
   - No fake session.

5. Later storage/CDN planning
   - Only after explicit approval.
   - Must not hardcode secrets in Flutter.
   - Must not use clone backend/storage.

6. Later real live streaming planning
   - Only after explicit approval.
   - RTMP/stream key/live engine must be separate milestone.
   - No fake stream success.

## M3AN seal decision

M3AN remains documentation-only.

No code patch is required.

Expected final state:

- One document added:
  docs/M3AN_LOCAL_VIDEO_BEHAVIOR_PLAN.md

- No Flutter UI changed.
- No dependency changed.
- No backend opened.
- No stash applied.
- No clone code copied.
- No upload/storage/RTMP/video pipeline connected.
