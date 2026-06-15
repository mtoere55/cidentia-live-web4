# M4C Central CidenDB Entry QA Seal

## Status

M4C central CidenDB sign-in entry preview is sealed.

This milestone adds only a visual and informational CidenDB/CID entry point for Cidentia.Live. It does not open real authentication, backend, OTP, session, upload, publishing, RTMP, wallet, payment, token, or blockchain behavior.

## Included patch

- M4C Patch 1: Central CidenDB sign-in entry preview

## Changed files

- `lib/local_social/widgets/cidentia_cidendb_entry.dart`
- `lib/local_social/widgets/cidentia_brand_header.dart`
- `lib/local_social/local_social_app.dart`

## Desktop behavior

The desktop left navigation header keeps the Cidentia.Live brand visible and places the CID entry below the brand header.

Expected desktop behavior:

- Cidentia.Live title remains readable.
- Web4 social preview subtitle remains readable.
- CID entry appears under the brand header.
- Pressing the CID entry opens the CidenDB/CID entry information sheet.

## Mobile behavior

The mobile AppBar includes a shield/CID entry icon.

Expected mobile behavior:

- AppBar title remains visible.
- CID/shield icon appears in the AppBar actions.
- Pressing the icon opens the CidenDB/CID entry information sheet.

## Entry sheet behavior

The CidenDB/CID entry sheet clearly states that this is only a reserved central sign-in boundary.

The sheet must not perform any of the following:

- OTP request
- Backend bridge call
- Fake login
- Fake CID
- Verified CID session creation
- Frontend token creation
- Frontend secret storage
- Upload
- Publish
- RTMP connection
- Wallet connection
- Payment
- Token action
- Blockchain action

## QA confirmation

Visual QA confirmed:

- Desktop CID entry is visible without squeezing the Cidentia.Live brand title.
- Mobile AppBar CID/shield icon is visible.
- Entry sheet opens on both desktop and mobile layouts.
- Protected action notices from M4B remain intact.
- No real service boundary was opened.

## Locked production boundaries

The following remain intentionally closed:

- CidenDB OTP
- Real CidenDB backend bridge
- Verified CID session handoff
- Fake login/session/CID
- Frontend token or secret storage
- Upload/publish
- Storage/CDN
- Real RTMP/live stream
- Wallet/payment/token/blockchain

## Next safe direction

The next milestone must be separate and explicitly planned.

Possible next tracks:

1. Real CidenDB OTP/backend bridge planning after exact contract confirmation.
2. Verified CID session handoff after backend verification exists.
3. Continue local product QA without opening production services.
4. Create/publish/upload production planning as a separate protected track.

Do not apply the old parked stash directly. It remains reference-only.
