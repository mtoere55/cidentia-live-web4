# M12J — Server Package Boundary

M12J creates the backend runtime package boundary under `server/package.json`.

## Added

- server/package.json
- scripts/m12j-server-package-boundary-check.js

## Decision

Backend Node dependencies belong under `server/`.

The Flutter root remains clean and still has no root `package.json`.

## Current Package State

- dependencies:{}
- devDependencies:{}
- pg dependency not added
- npm install not required
- CommonJS runtime preserved

## Still Locked

- PostgreSQL driver
- npm install
- PostgreSQL connection
- DB query execution
- migration execution
- profile read/write
- upload/storage/signed URL
- secrets
- fake CID/session/token
- UI filler/test buttons

M12K can add the PostgreSQL driver only after the backend package boundary is
accepted and only under `server/`.
