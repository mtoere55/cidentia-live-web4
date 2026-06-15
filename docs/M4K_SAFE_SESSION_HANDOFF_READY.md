# M4K Safe Session Handoff Ready

## Status

M4K prepares safe session handoff after CidenDB OTP verify success.

This milestone does not create fake CID, fake login, raw token storage, upload, RTMP, wallet, payment, token, or blockchain behavior.

## Behavior

If CidenDB verify succeeds and returns a usable `user.cid`, Cidentia.Live backend can create or forward a safe opaque `session_id`.

If CidenDB verify succeeds but returns an empty user object, Cidentia.Live does not create a fake session. It returns:

- `CIDENDB_VERIFY_OK_SESSION_PENDING`
- `sessionCreated:false`

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

Current verify response may still return `user:{}`. In that case M4K correctly refuses to create a fake verified session.

## Next

When CidenDB verify returns `user.cid`, Flutter can store the safe session fields and protected actions can start checking verified session state.
