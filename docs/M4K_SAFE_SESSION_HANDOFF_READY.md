# M4K Safe Session Handoff Ready

## Status

M4K prepares safe session handoff after CidenDB OTP verify success.

This milestone does not create fake CID, fake login, raw token storage, upload, RTMP, wallet, payment, token, or blockchain behavior.

## Behavior

If CidenDB verify succeeds and returns a usable `user.cid`, Cidentia.Live backend can create or forward a safe opaque `session_id`.

If CidenDB verify succeeds but no CID is returned, Cidentia.Live does not create a fake session.

Instead it returns:

- `CIDENDB_VERIFY_OK_CID_REQUIRED`
- `sessionCreated:false`
- `onboardingRequired:true`
- `redirectUrl:https://cidentiaapp.com`

That means the user must complete CidentiaApp onboarding before Cidentia.Live can open a verified session.

## Identity authority rule

CidenDB remains the identity/databank authority.

CidentiaApp remains the onboarding/registration authority.

Cidentia.Live must not create its own CID identity and must not fake a verified CID session.

## Safe fields

Allowed to return to Flutter:

- `cid`
- `email`
- `display_name`
- `trust_score`
- `profile_complete`
- `is_new_user`
- `session.session_id`
- `session.expires_in_seconds`
- `session.safe_claims`
- `onboardingRequired`
- `redirectUrl`

Never return to Flutter:

- raw JWT
- access_token
- id_token
- refresh_token
- API key
- secret
- signing key
- backend internal token

## Current CidenDB state

Live OTP send and verify are working.

If the current verify response still returns `user:{}` or no CID field, M4K correctly refuses to create a fake verified session and points the user to CidentiaApp onboarding.

## Next

When CidenDB verify returns `user.cid`, Flutter can store the safe session fields and protected actions can start checking verified session state.
