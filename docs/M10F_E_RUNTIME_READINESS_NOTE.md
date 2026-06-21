# M10F-E Runtime Readiness Note

M10F-E records the first VPS runtime preparation for Cidentia.Live.

This is not a production deploy.
This is not a Flutter deploy.
This is not a backend app launch.
This is not an upload, payment, wallet, AI, RTMP or live-stream opening.

## Runtime installed on VPS

VPS:

- server: cidentia-live-api-01
- public IPv4: 167.233.122.49
- OS: Ubuntu 24.04.4 LTS

Installed runtime:

- Node.js: v22.23.0
- npm: 10.9.8
- PM2: 7.0.1
- Nginx: 1.24.0
- PostgreSQL: 16.14

Service state:

- nginx: active
- postgresql: active
- fail2ban: active
- ufw: active

Firewall allowed ports:

- 22 / SSH
- 80 / HTTP
- 443 / HTTPS

## PostgreSQL staging database

A staging database was created.

Database:

- cidentia_live_staging

Database user:

- cidentia_app

Connection test passed through:

- host: 127.0.0.1
- port: 5432
- database: cidentia_live_staging
- user: cidentia_app

The database password is not stored in the repository.

This is staging preparation only.
No production database schema was deployed.

## Nginx health route

A static health page and JSON health route were created on the VPS.

Local test passed:

- http://127.0.0.1/
- http://127.0.0.1/health

External IP test passed:

- http://167.233.122.49/
- http://167.233.122.49/health

Expected health response:

ok=true
service=cidentia-live-api
deployActive=false
uploadLocked=true
objectStorageWrite=false
walletPaymentLocked=true

## Current health meaning

The health route means:

- infrastructure is reachable
- Nginx is serving
- HTTP port is open
- staging runtime is prepared

The health route does not mean:

- production app is deployed
- upload is enabled
- Object Storage write is enabled
- wallet/payment is enabled
- CidenDB session service is live
- CidenBridge is live
- RTMP/live stream is live

## Locked boundaries

M10F-E did not open:

- production deploy
- backend app deployment
- Flutter web deployment
- CidenDB live session service
- CidenBridge wallet/payment
- real upload
- real Object Storage write
- real signed URL generation
- PostgreSQL production schema
- payment
- wallet
- token transfer
- blockchain route
- NFT mint
- AI provider call
- RTMP/live stream
- replay recording
- CDN cutover
- Cloudflare DNS cutover

## Next safe steps

Recommended next steps:

1. Document runtime readiness in repository.
2. Create disabled backend skeleton only after repo plan is sealed.
3. Add disabled health/status API route.
4. Add disabled Object Storage client skeleton.
5. Add disabled upload permission boundary.
6. Keep all secrets in server env only.
7. Connect Cloudflare DNS only after staging backend route is ready.
