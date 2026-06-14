# M3AS — Local Media Picker Readiness Seal

## Status

M3AS prepares the next Create / Draft step after M3AR without opening real upload or storage.

Baseline before this seal:

- `2e7ad03 Merge M3AR local create draft QA seal`
- Mobile Create entry exists.
- Desktop Create entry exists.
- Create sheet supports Post / Reel / Story selection.
- Caption input is writable.
- Save local draft remains local-preview only.

## Purpose

This milestone does not add code.

It defines the safe boundary before any future media picker work begins.

The next picker step must not be treated as real publishing. It must remain local-preview only until backend, storage, CidenDB protected publishing, and upload contracts are explicitly opened.

## Current Create Surface

The current local Create sheet already supports:

- Mobile entry from the approved top app bar Create preview icon
- Desktop entry from the approved compact left sidebar Create preview button
- Post / Reel / Story mode selection
- Local media placeholder
- Writable caption input
- Save local draft action

The Save local draft action is only a local preview close action. It does not persist media, upload files, create a post, publish a reel, create a story, mint an asset, or call any backend.

## Future Picker Readiness

Before adding any media picker UI or package integration, the following must be checked:

- Existing Create sheet structure in `lib/local_social/local_social_app.dart`
- Existing Feed post preview path in `lib/local_social/widgets/local_post_card.dart`
- Existing Reels preview path in `lib/local_social/widgets/local_reels_page.dart`
- Existing Story preview path in `lib/local_social/widgets/local_stories_bar.dart`
- Existing Profile grid preview path in `lib/local_social/widgets/local_profile_grid.dart`
- Existing local data shape in `lib/local_social/local_social_data.dart`

The reference clone may be studied only for UI/UX patterns around gallery picker, media preview, caption flow, post preview, reel preview, and story preview.

The reference clone must not be copied blindly.

## Allowed Future Local Picker Preview

A future local picker preview may include:

- A local visual picker sheet
- Photo / video type tabs
- Local-only selected media placeholder
- Preview thumbnail area
- Mode-aware Post / Reel / Story layout
- Caption attached to local preview state
- Disabled or clearly local-only publish/save action

## Forbidden Until Explicitly Opened

The following remain locked:

- Real media upload
- Real file storage
- CDN
- Backend publish API
- CidenDB / OTP / verified session changes
- Real user media persistence
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

## QA Rule

Testing must use commands and existing approved UI paths only:

- `flutter analyze`
- `git diff --check`
- `flutter run -d windows -t lib/main_local.dart`
- Visual QA through existing mobile and desktop Create preview entries

No temporary test button, test card, debug widget, or filler UI should be added for QA.

## Recommended Next Milestone

After M3AS, the next safe coded step is:

M3AT — Local Media Picker UI Preview

M3AT should be small and reversible.

It should only add a local picker preview surface inside the existing Create sheet. It must not open real upload, storage, backend, CidenDB, RTMP, wallet, token, payment, blockchain, minting, or real publishing.

## Seal Result

M3AS is a documentation-only readiness seal.

The project is ready to plan a local media picker preview, but not ready for real upload or publishing.
