# M6A Safe Session Persistence Preview Contract

## Current state

Cidentia.Live currently receives a verified CidenDB/CID session only after OTP verify returns a safe session result.

Current Flutter flow:

- `CidentiaEcosystemEntryGate` calls the local CidenDB bridge.
- `/api/cidendb/otp/verify` returns a sanitized response.
- `_EntryResult.fromBridgeResponse` extracts safe user fields.
- If a CID is present, it creates `CidentiaSessionState.verified`.
- `onVerifiedEnter` passes that verified session into the local app shell.
- Protected surfaces use `CidentiaSessionScope` and `hasVerifiedCid`.

This is correct for runtime session state, but it is not persistent yet.

## What persistence may store later

A future persistence step may store only a safe Cidentia.Live session reference:

- `cid`
- `email`
- `displayName`
- `sessionReference`
- `issuedAt`
- `expiresAt`
- `source: CidenDB`
- `scope: Cidentia.Live local app session`

## What persistence must never store

Cidentia.Live Flutter must not store:

- raw CidenDB JWT
- raw access token
- raw refresh token
- raw id token
- OTP code
- CidenDB secret
- backend secret
- wallet private key
- payment token
- blockchain key
- stream key
- RTMP credential

## Required future behavior

If persistence is added later:

1. App boot may restore only a safe session reference.
2. Restored session must be expiry-aware.
3. Expired sessions must return to signed-out state.
4. Protected actions must still check `hasVerifiedCid`.
5. Missing CID must route to CidentiaApp onboarding.
6. Sign out must clear the local session reference.
7. A real backend may invalidate the session reference later.
8. Flutter must not become the identity authority.

## Locked boundaries

CidenDB remains the identity/databank authority.

CidentiaApp remains the onboarding/registration authority.

Cidentia.Live remains only the live/social program that accepts a verified CID session.

No local fake CID, fake verified user, local password login, Supabase auth, Google auth, token storage, wallet/payment/blockchain, RTMP/live-stream, upload/publish, or stream credential storage is opened by this milestone.

## M6A decision

M6A is a contract/readiness step only.

Actual storage implementation should be a later patch after choosing a safe local persistence mechanism and verifying that it does not reuse clone/Supabase token storage for CidenDB identity.
