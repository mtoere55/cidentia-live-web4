# M3AO - Local Media Picker / Publish UI Audit

## Status

M3AO is a UI scope audit only.

No media picker is implemented in this milestone.
No post/reel publish UI is implemented in this milestone.
No media upload, storage, backend, CDN, RTMP, stream key, CidenDB OTP, wallet, token, payment, blockchain, minting, fake reward, or real live stream is opened.

Current branch:

m3ao-local-media-picker-publish-ui-audit

Base:

f804289 Merge M3AN local video behavior plan

## Current product surface read

The following current Cidentia.Live local preview files were inspected:

- lib/local_social/local_social_app.dart
- lib/local_social/widgets/local_post_card.dart
- lib/local_social/widgets/local_profile_grid.dart
- lib/local_social/widgets/local_reels_page.dart
- docs/M3AN_LOCAL_VIDEO_BEHAVIOR_PLAN.md

## Current create/publish surface

### App shell

Current `LocalSection` contains:

- Feed
- Search
- Reels
- Chats
- Live Studio
- Profile

There is no separate Create section in the main navigation.

On mobile/compact shell, the app bar already has a `Create preview` icon. It only shows a local notice:

Creation will be connected only after the approved media/upload milestone.

This is a safe placeholder and does not open picker, upload, storage, backend, or publish flow.

### Desktop shell

Desktop navigation currently does not show a Create entry.

This is good for now because adding a permanent Create nav item could crowd the primary product sections and imply a real publishing capability before the upload/publish boundary is opened.

### Feed

Feed post media currently shows local visual media only.

- No upload.
- No real publish.
- No real video file.
- No remote media.
- Tapping media opens local detail sheet only.

### Profile

Profile contains creator identity, stats, action row, creator economy preview, tabs and grid.

Profile is a possible future entry point for creator publishing, but it should not receive random filler cards or a premature upload/publish block.

### Reels

Reels currently focuses on viewer behavior and live discovery.

Reels should not receive a visible publish/create panel yet because mobile and desktop Reels surfaces must remain clean.

## Reference clone read-only findings

The reference clone file list was inspected only for UI/UX behavior ideas.

Useful future reference areas:

- lib/feed/post/widgets/post_edit.dart
- lib/feed/post/widgets/post_preview.dart
- lib/user_profile/widgets/user_profile_create_post.dart
- packages/gallery_media_picker/lib/src/presentation/pages/gallery_media_picker.dart
- packages/gallery_media_picker/lib/src/presentation/widgets/gallery_grid/gallery_grid_view.dart
- packages/gallery_media_picker/lib/src/presentation/widgets/gallery_grid/thumbnail_widget.dart
- packages/image_picker_plus/lib/src/gallery_display.dart
- packages/image_picker_plus/lib/src/images_view_page.dart
- packages/image_picker_plus/lib/src/video_layout/
- packages/instagram_blocks_ui/lib/src/post_large/post_caption.dart
- packages/instagram_blocks_ui/lib/src/post_large/post_media.dart
- packages/instagram_blocks_ui/lib/src/widgets/media_carousel.dart
- packages/shared/lib/src/models/media.dart
- screenshots/Media picker/
- screenshots/Posts/Post create View.png
- screenshots/User Profile/Create media botom sheet.png

Clone reference may help with:

- Create media bottom sheet layout
- Gallery grid layout
- Media preview layout
- Post/Reel type selection
- Caption input flow
- Preview-before-publish flow
- Mobile media surface spacing

## Forbidden clone areas

The following must not be copied or adopted from the clone:

- Auth system
- Supabase/Firebase/Google login
- Token/session storage
- Backend/storage services
- Password/login/register screens
- User identity creation logic
- Upload implementation
- Repository/backend media model
- Production publish pipeline
- Any package dependency imported blindly from the clone

Cidentia.Live must keep its own Cidentia/CidenDB/CID identity boundary.

## Recommended future Create UI placement

When local media/publish preview is approved later, the safest placement is:

### Mobile

Use the existing app bar `Create preview` icon as the entry point.

Reason:

- It already exists.
- It does not add a new bottom navigation item.
- It keeps the mobile bottom nav stable.
- It does not clutter Reels or Feed.
- It can open a local-only bottom sheet later.

### Desktop

Use a compact Create action in the left shell area or top area only after approval.

Preferred future option:

- A small `Create` button near the left nav/status area.
- Not a new full right panel.
- Not a permanent large card.
- Not inside Reels viewer.
- Not random filler in Profile.

### Profile

Profile can later show creator-owned posts and local draft preview, but should not be the first forced publish entry point.

### Feed

Feed can later show local newly-created preview posts, but should not own the create flow.

## Recommended future local-only publish sheet

If approved in a later code milestone, the first local-only create sheet should include:

- Post / Reel / Story mode selector
- Local media preview placeholder
- Caption input
- Audience/status row
- CID/proof notice
- Local preview only warning
- Disabled or safe `Publish preview` action
- No file upload
- No storage
- No backend call
- No CidenDB/CID session creation
- No fake successful production publish

The button text should avoid implying real publishing.

Safer labels:

- Save local preview
- Preview post
- Add to local draft
- Continue preview

Avoid labels until backend is approved:

- Upload
- Publish live
- Go production
- Send to server
- Mint
- Earn
- Pay
- Connect wallet

## Future milestone order

1. M3AP - Local Create Sheet Preview
   - Small local-only bottom sheet/dialog.
   - Use existing mobile create icon.
   - Add compact desktop create entry only if approved.
   - No upload/storage/backend.

2. M3AQ - Local Draft / Media Preview Polish
   - Optional local preview card/state.
   - No production publish.

3. M3AR - Feed/Reel Local Video Preview
   - Local sample video behavior only if approved.
   - No remote media.

4. Later CidenDB/CID protected publish plan
   - Only after explicit approval.
   - Must resume identity boundary carefully.
   - No fake session.

5. Later storage/CDN/backend plan
   - Only after explicit approval.
   - No secrets in Flutter.
   - No clone backend/storage copied.

6. Later real live streaming plan
   - Only after explicit approval.
   - RTMP/stream key/live engine separate milestone.
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

## M3AO seal decision

M3AO remains documentation-only.

No code patch is required.

Expected final state:

- One document added:
  docs/M3AO_LOCAL_MEDIA_PICKER_PUBLISH_UI_AUDIT.md

- No Flutter UI changed.
- No dependency changed.
- No backend opened.
- No stash applied.
- No clone code copied.
- No upload/storage/RTMP/video pipeline connected.
