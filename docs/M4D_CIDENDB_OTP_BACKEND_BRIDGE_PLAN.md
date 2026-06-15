# M4D CidenDB OTP Backend Bridge Plan

## Status

M4D is a planning milestone only.

This document defines the safe boundary for opening a real CidenDB OTP backend bridge later. No code path in this milestone should call CidenDB, request OTP, verify OTP, create a verified CID session, store tokens, or open frontend secrets.

## Current sealed base

The current main branch already includes:

- M4B protected action notice layer
- M4C central CidenDB/CID visual entry
- Desktop CID entry under the Cidentia.Live brand header
- Mobile AppBar CID/shield entry
- Protected notices for profile, chat, and Live Studio real action boundaries

## Goal of a future real bridge

A future backend bridge may allow Cidentia.Live to request and verify OTP through CidenDB.

The frontend must not call CidenDB directly.

The frontend should only call trusted backend routes controlled by Cidentia.Live infrastructure.

Expected future frontend routes:

- `POST /api/cidendb/otp/send`
- `POST /api/cidendb/otp/verify`

Expected future backend upstream routes, only if contract is confirmed:

- `POST https://api.cidendb.com/api/v1/auth/otp/send`
- `POST https://api.cidendb.com/api/v1/auth/otp/verify`

## Required backend guardrails

A future backend bridge must require explicit environment gates before any live upstream request:

- `CIDENDB_BRIDGE_ENABLED=true`
- `CIDENDB_CONTRACT_CONFIRMED=true`

Without both flags, the backend must return a safe disabled response.

## Frontend rules

The Flutter frontend must never:

- Generate OTP
- Verify OTP locally
- Store CidenDB secrets
- Store raw CidenDB tokens
- Create fake verified CID sessions
- Create password login
- Add Supabase/Firebase/Google clone auth
- Treat preview success as real identity
- Open protected production actions without a verified CID session

## Backend rules

The backend bridge must:

- Keep CidenDB secrets server-side only
- Sanitize sensitive upstream responses before returning to Flutter
- Never return raw tokens to UI unless a later security design explicitly approves it
- Never log OTP codes, secrets, raw tokens, or private identity payloads
- Return stable error codes for disabled bridge, missing contract, upstream failure, and verification failure
- Keep fake success disabled

## Session handoff rules

A verified CID session handoff may only be implemented after the backend verification flow is confirmed.

A future session handoff must expose only safe session state to Flutter, such as:

- verified true / false
- CID number or safe public CID reference
- display name if safe
- limited expiry/session status

The frontend must not own permanent identity authority. CidenDB remains the identity/databank authority.

## Protected action behavior after future verification

After a real verified CID session exists, protected actions may be allowed through the existing auth boundary.

Protected surfaces include:

- Profile edit
- Wallet entry
- Proof management
- Chat send
- Live Studio Go Live
- Share Screen
- Invite Guest
- Destination / RTMP manager
- Upload media
- Publish media

Public preview surfaces stay open:

- Feed
- Search
- Reels
- Story discovery
- Live Room preview
- Create preview
- Save local draft

## Locked in this milestone

This M4D plan does not open:

- OTP request
- OTP verify
- Backend route
- CidenDB upstream call
- Verified session handoff
- Fake login/session/CID
- Frontend token storage
- Upload/publish
- RTMP/live stream
- Wallet/payment/token/blockchain

## Next implementation order

Recommended future order:

1. Confirm exact CidenDB OTP request and response contract.
2. Add backend route skeleton returning disabled responses by default.
3. Add guarded server-side CidenDB client.
4. Test disabled states.
5. Enable only in local/dev environment with explicit env flags.
6. Connect Flutter entry panel to backend route.
7. Add verified session handoff only after backend verification is proven safe.
8. Allow protected actions through the existing M4B auth boundary.
