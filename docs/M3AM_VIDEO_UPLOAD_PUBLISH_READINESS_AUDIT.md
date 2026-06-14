# M3AM - Video / Upload / Publish Readiness Audit

## Status

M3AM is a readiness audit only. No production video upload, media storage, post/reel publishing pipeline, RTMP, stream key, CDN, backend video service, wallet, token, blockchain, minting, CidenDB OTP, or real live stream is opened in this milestone.

Current branch:

m3am-video-upload-publish-readiness-audit

Base state:

main HEAD before branch:
8b31742 Merge M3AL local social final handoff

M4B/CidenDB OTP stash remains parked and must not be applied:

stash@{0}: On m4b-safe-cidendb-otp-boundary: park-m4b-cidendb-otp-wip-before-m3g-social-actions

## Current Cidentia.Live surface read

The following local preview files were inspected as the current product surface:

- lib/local_social/local_social_app.dart
- lib/local_social/widgets/local_post_card.dart
- lib/local_social/widgets/local_reels_page.dart
- lib/local_social/widgets/local_live_studio_page.dart
- lib/local_social/widgets/local_profile_grid.dart

Current Cidentia.Live status:

- Feed is local social preview.
- Search is local media wall preview.
- Reels is local viewer surface with desktop live discovery list.
- Story/live discovery is local preview.
- Live Room is local preview.
- Optional Live Room modes are local preview.
- Live Studio is creator control center preview only.
- Profile creator economy is visual preview only.
- Mobile surface QA is sealed.

## Important boundary

Video upload / publish / real live streaming has not started yet.

Live Studio currently represents the creator control center surface only. Stage, scene, room mode, destinations, translation, chat, proof, support/effect and related areas are product-flow UI previews. They are not connected to a real streaming engine.

## Reference clone audit

The uploaded/reference project `flutter-instagram-offline-first-clone-main` may be used only as read-only UI/UX behavior reference.

Useful reference areas for future milestones:

- Feed video card behavior
- Reels video player behavior
- Story video/viewer behavior
- Video play/pause visibility logic
- Long press pause
- Progress indicator
- Media picker / upload UI flow
- Post/Reel publish form structure
- Caption/input/media preview behavior
- Mobile navigation and media surface arrangement

Reference files identified for future reading:

- lib/feed/post/video/view/video_player.dart
- lib/feed/post/widgets/post_video_player.dart
- packages/instagram_blocks_ui/lib/src/widgets/inline_video.dart
- packages/instagram_blocks_ui/lib/src/smooth_video_progress_indicator.dart
- lib/reels/reel/view/reel_view.dart
- lib/reels/view/reels_view.dart
- packages/gallery_media_picker/lib/src/presentation/pages/gallery_media_picker.dart
- lib/user_profile/widgets/user_profile_create_post.dart

## Clone parts that must not be copied

The following clone areas are forbidden for Cidentia.Live:

- Auth system
- Supabase/Firebase connection
- Google login
- Token/session storage
- Backend/storage services
- Password/login/register screens
- User identity creation logic

Cidentia.Live identity must remain aligned with Cidentia/CidenDB/CID boundaries. The clone must never become the identity, backend, storage, or session source.

## Future milestone order

Video/upload/publish work must be opened as a separate milestone only after this audit is sealed.

Safe future order:

1. M3AN - Local video behavior plan
   - Decide local-only video preview behavior.
   - No upload/storage/backend.

2. M3AO - Local media picker/publish UI preview
   - Add visual-only picker/publish surface if approved.
   - No real upload.
   - No backend.
   - No storage.

3. M3AP - Local feed/reel video preview polish
   - Add local sample video behavior only if explicitly approved.
   - No production pipeline.

4. Later backend milestone
   - Only after explicit approval.
   - Plan CidenDB/CID session boundary first.
   - Plan storage/CDN/security separately.
   - Never hardcode secrets in Flutter.

5. Later real live streaming milestone
   - Only after explicit approval.
   - RTMP/stream key/live engine must be separate from local preview.
   - No fake stream success.

## Testing rule for future code milestones

If a future milestone changes code, always run:

dart format <changed files>
flutter analyze <changed files or related main files>
git diff --check
flutter run -d windows -t lib/main_local.dart
git status --short

Commit rules:

- No commit if analyze has errors.
- No commit if git diff --check fails.
- Stop if unexpected files are changed.
- Commit/push only after user visual approval.
- After merge to main, verify with git log --oneline -10 and git status --short.

## M3AM seal decision

M3AM should remain documentation-only.

No code patch is required in this milestone.

M3AM final state should be:

- One audit document added.
- No Flutter UI changed.
- No backend opened.
- No stash applied.
- No dependency upgrade.
- No upload/storage/RTMP/video pipeline connected.
