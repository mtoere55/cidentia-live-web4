# M4B CidenDB Reopen Stash Audit

## Current branch

`m4b-cidendb-cid-auth-reopen`

## Main state before reopening

Main is sealed at:

`81a9509 Merge M3AY full product gap handoff`

The working tree was clean before CidenDB review.

## Parked stash

`stash@{0}: On m4b-safe-cidendb-otp-boundary: park-m4b-cidendb-otp-wip-before-m3g-social-actions`

## Stash contents

The stash contains only frontend/auth-related files:

- `lib/local_social/auth/cidentia_protected_action_dialog.dart`
- `lib/local_social/auth/cidentia_session_scope.dart`
- `lib/local_social/widgets/cidentia_ecosystem_entry_page.dart`
- `lib/local_social/widgets/local_post_card.dart`
- `lib/local_social/widgets/local_profile_grid.dart`

The stash does not contain:

- `lib/local_social/auth/cidendb_login_bridge.dart`
- `server/cidendb/cidenDbOtpClient.js`
- backend route files
- real CidenDB OTP bridge code

## Findings

The stash is not a clean production-ready CidenDB bridge.

It appears to contain older frontend gate/session experiments.

Some text in the stashed files has encoding damage, for example broken Turkish characters in status messages.

Therefore the stash must not be applied directly.

## Decision

Do not run:

- `git stash apply`
- `git stash pop`

Do not copy the stash into main blindly.

The correct approach is to rebuild M4B cleanly from the current main state.

Useful concepts from the stash may be reimplemented manually only after reading the current real files.

## Safe M4B direction

M4B should be reopened in small steps:

1. Restore a clean auth boundary contract.
2. Restore a clean session scope/state only if needed.
3. Restore protected action handling without fake login.
4. Keep public Feed/Search/Reels open.
5. Keep protected operations behind verified CID session requirement.
6. Do not open real OTP/backend until the bridge contract is explicitly implemented.
7. Do not add frontend secrets or fake verified sessions.

## Locked boundaries

Still forbidden in this audit:

- Fake login
- Fake verified CID
- Fake local session success
- Frontend CidenDB token storage
- Frontend secrets
- Real backend call
- Upload/publish
- RTMP/live stream
- Wallet/token/payment/blockchain

## Result

The M4B stash is reviewed and parked. It remains a reference only, not a patch source.
