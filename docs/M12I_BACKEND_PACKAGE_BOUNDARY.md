# M12I — Backend Package Boundary

M12I records the backend runtime/package boundary before adding any PostgreSQL
driver or real DB connection.

## Current Repository Reality

The repository root is a Flutter project and has:

- pubspec.yaml
- pubspec.lock
- lib/
- api/
- server/
- scripts/

There is currently no package.json anywhere in the repository.

## Decision

Do not add PostgreSQL dependencies blindly.

Before real DB connection is opened, the project must choose one backend runtime
package boundary:

1. Root package.json
2. server/package.json
3. deployment-only package.json on VPS

The preferred direction is `server/package.json`, because:

- Flutter root stays clean
- backend dependencies stay isolated
- api/server scripts can use the same Node dependency boundary
- future PostgreSQL driver can be added server-side only

## Locked Until Explicit Next Step

- no pg dependency added
- no npm install
- no PostgreSQL connection
- no DATABASE_URL committed
- no secrets committed
- no migration execution
- no real profile read/write
- no upload/storage/signed URL
- no fake CID/session/token

## Next Safe Step

M12J should add a disabled `server/package.json` boundary only if we decide to
standardize backend runtime dependencies under `server/`.

M12J must still not install or require `pg` unless the backend runtime decision
is accepted.
