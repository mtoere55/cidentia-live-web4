# M10N Cloudflare API Proxy Readiness Plan

M10N defines the readiness and rollback plan before enabling Cloudflare proxy for api.cidentia.live.

This is a plan only.
This patch does not enable Cloudflare proxy.
This patch does not change DNS.
This patch does not open upload, Object Storage write, CidenDB live session, CidenBridge, wallet, payment, RTMP, live streaming or production deploy.

## Current sealed state

api.cidentia.live is already working with:

- DNS only
- HTTPS origin certificate through Let's Encrypt
- Nginx proxy to disabled backend
- PM2 disabled backend online

Verified HTTPS endpoints:

- GET https://api.cidentia.live/api/health -> 200
- GET https://api.cidentia.live/api/status -> 200
- GET https://api.cidentia.live/api/storage/status -> 503 OBJECT_STORAGE_WRITE_DISABLED
- POST https://api.cidentia.live/api/upload/request -> 503 UPLOAD_ROUTE_DISABLED
- GET https://api.cidentia.live/api/cidendb/session/status -> 503 CIDENDB_SESSION_SERVICE_DISABLED

## Cloudflare proxy target

Future Cloudflare DNS change:

- Record: api
- Type: A
- Target: 167.233.122.49
- Current mode: DNS only
- Future mode: Proxied

Only api.cidentia.live may be changed.

The following records must not be changed during M10N:

- cidentia.live root legacy Vercel route
- www.cidentia.live legacy Vercel route
- market.cidentia.live
- terminal.cidentia.live
- Hostinger mail records
- Vercel verification records

## Required Cloudflare SSL mode

Cloudflare SSL/TLS mode should remain:

- Full

Full is acceptable because the origin already has a valid Let's Encrypt certificate.

If later switching to Full strict, confirm Cloudflare accepts the origin certificate and no route breaks.

## Expected behavior after proxy

Expected public HTTPS behavior after enabling proxy:

- GET https://api.cidentia.live/api/health -> 200
- GET https://api.cidentia.live/api/status -> 200
- GET https://api.cidentia.live/api/storage/status -> 503 locked
- POST https://api.cidentia.live/api/upload/request -> 503 locked
- GET https://api.cidentia.live/api/cidendb/session/status -> 503 locked

Expected locked flags:

- deployActive=false
- uploadLocked=true
- objectStorageWrite=false
- walletPaymentLocked=true
- cidenDbSessionLive=false
- cidenBridgeLive=false
- rtmpLive=false
- replayRecording=false
- guarded=true
- readOnly=true

## Headers to verify

Expected headers after Cloudflare proxy:

- Cache-Control: no-store
- X-Cidentia-Staging-Backend: disabled

Cloudflare may add its own headers, such as:

- cf-cache-status
- cf-ray
- server: cloudflare

Cloudflare headers are acceptable only if locked response bodies remain unchanged.

## Rollback path

If proxy causes any issue:

1. Change only api.cidentia.live back to DNS only.
2. Do not touch root/www/market/terminal/mail records.
3. Confirm direct origin still works:
   - https://api.cidentia.live/api/health
4. Confirm PM2 remains online:
   - cidentia-live-disabled-backend
5. Confirm Nginx remains valid:
   - sudo nginx -t

## Locked boundaries

M10N does not open:

- production app deploy
- Flutter web deploy
- upload
- Object Storage write
- signed upload URL generation
- media metadata creation
- CidenDB live session
- frontend token exposure
- CidenBridge
- wallet
- payment
- RTMP
- WebRTC
- live streaming
- replay recording
- root/www DNS cutover
- market/terminal/mail DNS changes

## Next safe step

After this plan is sealed, M10O can enable Cloudflare proxy only for api.cidentia.live and run the HTTPS proxy tests.

M10O must verify locked route behavior before and after proxy.
