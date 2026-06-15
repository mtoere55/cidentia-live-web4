# M4E CidenDB Backend Disabled Skeleton

## Status

M4E adds a disabled backend skeleton for future CidenDB OTP routes.

This milestone does not open live CidenDB calls, OTP sending, OTP verification, fake login, fake session, frontend token storage, verified CID handoff, upload, publishing, RTMP, wallet, payment, token, or blockchain behavior.

## Added files

- `server/cidendb/cidenDbBridgeGuard.js`
- `api/cidendb/otp/send.js`
- `api/cidendb/otp/verify.js`

## Routes

Future route placeholders:

- `POST /api/cidendb/otp/send`
- `POST /api/cidendb/otp/verify`

## Default behavior

By default, both routes return:

- `ok: false`
- `code: CIDENDB_BRIDGE_DISABLED`
- `liveCidenDbCall: false`
- `fakeSuccess: false`
- `sessionCreated: false`

## Required future env gates

A future live bridge must require:

- `CIDENDB_BRIDGE_ENABLED=true`
- `CIDENDB_CONTRACT_CONFIRMED=true`

If only the bridge flag is enabled but the contract flag is missing, the skeleton returns:

- `CIDENDB_CONTRACT_NOT_CONFIRMED`

If both flags are enabled, this skeleton still returns:

- `CIDENDB_UPSTREAM_CLIENT_NOT_IMPLEMENTED`

That is intentional. The live upstream CidenDB client is not implemented in this milestone.

## Locked boundaries

This milestone keeps closed:

- CidenDB live upstream call
- OTP send
- OTP verify
- Fake success
- Verified CID session creation
- Raw token handling
- Frontend secret storage
- Upload/publish
- RTMP/live stream
- Wallet/payment/token/blockchain
