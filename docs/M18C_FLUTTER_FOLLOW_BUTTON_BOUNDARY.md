# M18C — Flutter Follow Button Boundary

Status: Flutter profile follow boundary connected.

## Purpose

M18C connects profile social actions to the guarded backend social boundary.

## Changed UI behavior

The profile screen now has:

- Follow action button
- Followers stat card tap boundary
- Following stat card tap boundary

## Boundary behavior

When verified CID exists, Flutter calls:

- `POST /api/social/follow`
- `GET /api/social/followers`
- `GET /api/social/following`

When backend routes are locked/default-disabled, UI shows:

- `SOCIAL_ROUTE_DISABLED`
- `DATABASE_DISABLED`

## Locked behavior preserved

M18C does not create:

- fake follow state
- fake follower counter
- fake following counter
- fake CID/session/token
- default public follow persistence

Stats remain unchanged until real profile stats are released.

## Verified local QA

Local QA confirmed:

- Follow button opens social boundary sheet
- Followers card opens social graph boundary sheet
- Following card opens social graph boundary sheet
- locked backend returns safe disabled state
- no fake counter or fake follow state is applied
