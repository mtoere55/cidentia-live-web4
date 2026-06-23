# M14D Object Storage Live Smoke Gate

M14D adds a server-side live smoke gate for Object Storage signed upload URL generation.

## Added

- `scripts/m14d-object-storage-live-smoke-check.js`

## Default behavior

The live smoke check is disabled by default.

Without:

- `CIDENTIA_OBJECT_STORAGE_LIVE_SMOKE=true`

the script exits successfully with:

- `OBJECT_STORAGE_LIVE_SMOKE_DISABLED`

## Live smoke behavior

When explicitly enabled on the backend/VPS, the script validates that a signed upload URL can be generated through the guarded M14A presigner client.

It requires the existing upload/storage gates:

- `CIDENTIA_UPLOAD_ENABLED=true`
- `CIDENTIA_OBJECT_STORAGE_ENABLED=true`
- `CIDENTIA_OBJECT_STORAGE_WRITE_ENABLED=true`
- `CIDENTIA_SIGNED_URL_ENABLED=true`

It also requires server-only Object Storage env:

- `CIDENTIA_OBJECT_STORAGE_ENDPOINT`
- `CIDENTIA_OBJECT_STORAGE_BUCKET`
- `CIDENTIA_OBJECT_STORAGE_REGION`
- `CIDENTIA_OBJECT_STORAGE_ACCESS_KEY_ID`
- `CIDENTIA_OBJECT_STORAGE_SECRET_ACCESS_KEY`

## Locked boundaries

M14D does not:

- upload a real file
- perform an Object Storage write
- create media metadata
- expose secrets
- add Flutter UI
- add test cards
- change wallet/payment/RTMP/WebRTC

The script only generates a pre-signed PUT URL and redacts query secrets from logs.

## Next safe step

After M14D is deployed to VPS, run the default locked check first. Then run the live smoke only with server-only Object Storage env loaded. If signed URL generation succeeds, M14E can add a controlled server-side upload PUT smoke using a tiny disposable object and immediate cleanup.
