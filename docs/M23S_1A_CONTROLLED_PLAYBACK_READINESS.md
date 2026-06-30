# M23S-1A - Controlled playback readiness

Status: completed.

## Scope

This milestone does not open real video playback yet.

It prepares the creator profile grid for controlled playback by passing:

- safe media item
- verified CID identity
- active profile tab
- safe boundary status

into the grid preview sheet.

## What changed

- Fixed broken CidenDB verified text encoding.
- Grid tile now reads the current Cidentia session.
- Grid tile builds a safe `_ProfileIdentityView`.
- `_openGridPreview` now receives:
  - `_SafeProfileMediaItem?`
  - `_ProfileIdentityView`
- Preview sheet can now show a controlled playback readiness card.
- The card only appears when:
  - a real safe media item exists
  - CID exists
  - tab is not Live

## Safety

The following remain true:

- No video player package was added.
- No signed URL is displayed.
- No bucket name is displayed.
- No object key is displayed.
- No autoplay exists.
- Playback is not opened yet.
- Upload/write/live/payment remain outside this milestone.

## Next milestone

M23S-1B:

- Add `video_player`.
- Request signed read URL only after user action.
- Open video in a controlled modal preview.
- Do not log or display signed URL.
- Keep autoplay off.
