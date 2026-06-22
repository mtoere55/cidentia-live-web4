# M13B — Profile API Live DB Smoke

M13B verifies that the profile API route path can use the real PostgreSQL profile repository under a server-only query gate.

## Verified on VPS

Host:

- `cidentia-live-api-01`

Runtime path:

- `/opt/cidentia-live/app/current`

Server-only env:

- `/opt/cidentia-live/env/db-live-smoke.env`

Query gate used only for smoke:

- `CIDENTIA_DATABASE_QUERY_ENABLED=true`

## Results

The local smoke server was started on:

- `127.0.0.1:3012`

Verified API behavior:

- `GET /api/profile/me` without CID returned `PROFILE_CID_REQUIRED`.
- `POST /api/profile/update` with `x-cidentia-cid: Cid-M13A-Api-Smoke` returned `PROFILE_WRITE_OK`.
- `GET /api/profile/me` with the same CID returned `PROFILE_READ_OK`.
- The temporary smoke row was deleted.
- Cleanup verification returned count `0`.
- The smoke server was stopped.

## Safety boundaries

- PM2/staging runtime query gate was not permanently enabled.
- No Flutter DB secret was introduced.
- No upload was opened.
- No Object Storage write was opened.
- No signed URL was created.
- No feed/reels real media read was opened.
- No wallet/payment route was opened.
- No RTMP/WebRTC/live stream route was opened.
- No fake CID/session/token was created.

## Note

The smoke server banner still says no DB connection/profile write is opened. That text is stale for this M13B smoke mode. The actual JSON route responses confirmed `dbConnected:true`, `queryEnabled:true`, `PROFILE_WRITE_OK`, and `PROFILE_READ_OK`.
