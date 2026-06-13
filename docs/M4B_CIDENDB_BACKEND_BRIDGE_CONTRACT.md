# M4B Safe CidenDB Backend Bridge Contract

Status:
Planning and contract only. No live backend connection is opened by this document.

Branch:
m4b-safe-cidendb-otp-boundary

Depends on:
- bc75dd1 Add M4B safe CidenDB boundary guard
- fb8edd5 Block fake CidenDB OTP session

Purpose:
Define the safe backend bridge boundary for CidenDB OTP send and verify.

Core principle:
Flutter must not talk to CidenDB upstream directly for sensitive authentication.
Flutter must not generate OTP.
Flutter must not verify OTP locally.
Flutter must not create fake verified CID sessions.
Flutter must not store CidenDB raw tokens in UI state.

Architecture:
Cidentia.Live Flutter UI
  -> calls Cidentia.Live backend bridge routes
  -> backend bridge calls CidenDB upstream OTP endpoints
  -> backend validates and sanitizes the CidenDB response
  -> Flutter receives only safe session metadata

CidenDB role:
CidenDB is the identity and databank authority.
CidenDB creates and verifies the CID identity.

CidentiaApp role:
CidentiaApp is the registration and onboarding authority for users without CID.

Cidentia.Live role:
Cidentia.Live accepts a verified CidenDB/CID session.
Cidentia.Live does not create its own identity authority.

Backend bridge routes to reserve:
POST /api/cidendb/otp/send
POST /api/cidendb/otp/verify

Expected frontend payload for send:
{
  "identifier": "CID / email / phone"
}

Expected frontend payload for verify:
{
  "identifier": "CID / email / phone",
  "otp": "123456"
}

Expected safe frontend response for send:
{
  "ok": true,
  "message": "OTP request accepted."
}

Expected safe frontend response for verify:
{
  "ok": true,
  "session": {
    "status": "signedIn",
    "cid": "CID...",
    "identifier": "user identifier",
    "displayName": "optional safe display name"
  },
  "message": "CID session verified."
}

Never expose to Flutter:
- CidenDB raw token
- API secrets
- upstream authorization headers
- server-only credentials
- full upstream response if it contains sensitive fields

Frontend behavior while backend is not ready:
- Show calm boundary message.
- Do not show localhost errors to users.
- Do not create signedIn session.
- Keep user signedOut.
- Keep Feed/Search/Reels public.
- Keep Chats/Live Studio/Profile protected.

Forbidden implementation:
- No local fake success.
- No CID-PREVIEW-VERIFIED.
- No local signedIn state from OTP text alone.
- No Supabase/Firebase/Google sign-in.
- No password login.
- No direct CidenDB secret in Flutter.
- No editing Live Studio, Chat, Profile, Feed layout, Reels layout, or app shell for backend work.

Safe implementation order:
1. Keep current Flutter bridge returning signedOut until backend exists.
2. Add backend route skeleton in a later patch only after deployment target is selected.
3. Add server-side environment variable guard.
4. Add upstream CidenDB call server-side only.
5. Sanitize upstream response.
6. Add frontend bridge call to local backend route.
7. Only then create a verified CID session from sanitized backend success.
8. Re-test protected routes.

Deployment question before code:
Before adding backend code, decide whether this repository will use:
- Vercel serverless api folder,
- a Node server folder,
- Firebase/Cloud Functions,
- or another backend host.

Until that is decided, do not add live backend code.
