# M10K Cloudflare API DNS and HTTPS Plan

M10K defines the Cloudflare DNS and HTTPS staging path for Cidentia.Live API.

This is a plan only.
This patch does not change Cloudflare DNS.
This patch does not enable Cloudflare proxy.
This patch does not open upload, Object Storage write, wallet, payment, CidenDB live session, CidenBridge, RTMP, live streaming or production deploy.

## Current DNS state observed

Existing records must not be changed during M10K:

- terminal.cidentia.live: A record to existing terminal server
- cidentia.live: owned Cidentia root domain, currently legacy Vercel CNAME
- www.cidentia.live: owned Cidentia www route, currently legacy Vercel CNAME
- market.cidentia.live: CNAME to Vercel
- Hostinger mail MX/SPF/DKIM records
- Vercel verification TXT records

Root and www are owned Cidentia records, but they are legacy Vercel routes. They must not be changed during M10K. Their migration requires a separate root/www cutover plan.

M10K is only for the new api.cidentia.live route.

## New API DNS target

Future record:

- Type: A
- Name: api
- Content: 167.233.122.49
- TTL: Auto
- Proxy status: DNS only for first test

Full hostname:

- api.cidentia.live

## Reason for DNS only first

The first API DNS test should be DNS only because:

- VPS HTTP staging route already works by IP
- Nginx currently serves disabled staging backend safely
- Cloudflare proxy/SSL mode has not been confirmed yet
- HTTPS origin certificate path has not been sealed yet
- rollback is simpler before proxy is enabled

## Current VPS staging backend

Public IP test already passed:

- http://167.233.122.49/api/health -> 200
- http://167.233.122.49/api/status -> 200
- http://167.233.122.49/api/storage/status -> 503 locked
- http://167.233.122.49/api/upload/request -> 503 locked
- http://167.233.122.49/api/cidendb/session/status -> 503 locked

Required locked flags remain:

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

## Nginx staging target

Nginx should later accept:

- server_name api.cidentia.live

The existing disabled backend proxy should remain:

- /api/* -> http://127.0.0.1:3010/api/*

The static infrastructure health route may remain:

- /health

## HTTPS path

Recommended safe order:

1. Add api.cidentia.live DNS record as DNS only.
2. Test HTTP through api.cidentia.live.
3. Add Nginx server_name api.cidentia.live.
4. Confirm disabled routes still return 200/503 as expected.
5. Decide HTTPS method:
   - Let's Encrypt certificate on origin, or
   - Cloudflare Origin Certificate with Full strict mode.
6. Only after HTTPS works, decide whether to enable Cloudflare proxy.

## Rollback path

If api.cidentia.live fails:

1. Remove or disable only the api A record.
2. Keep existing cidentia.live/www/market/terminal records unchanged.
3. Keep PM2 disabled backend running only on 127.0.0.1:3010.
4. Keep IP-based health route available.

## Locked boundaries

M10K does not open:

- production app deploy
- Flutter web deploy
- upload
- Object Storage write
- signed URL generation
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
- Cloudflare proxy
- DNS cutover for root/www/market/terminal

## Next safe step

After this plan is sealed, M10L can add only this DNS record:

api.cidentia.live A 167.233.122.49 DNS only

Then test:

- http://api.cidentia.live/health
- http://api.cidentia.live/api/health
- http://api.cidentia.live/api/status
- http://api.cidentia.live/api/storage/status
- http://api.cidentia.live/api/upload/request
- http://api.cidentia.live/api/cidendb/session/status
