# M4B Safe Backend Target Decision

Status:
Decision document only. No backend code is added in this patch.

Branch:
m4b-safe-cidendb-otp-boundary

Current safe commits:
- bc75dd1 Add M4B safe CidenDB boundary guard
- fb8edd5 Block fake CidenDB OTP session
- df365a6 Document safe CidenDB backend bridge contract

Decision:
CidenDB OTP bridge must not be implemented as a random local Flutter-side localhost server.
The Flutter app shell must stay clean.
The backend bridge must be a deliberate server-side boundary.

Chosen direction:
Use a small server-side CidenDB OTP bridge with reserved routes:

POST /api/cidendb/otp/send
POST /api/cidendb/otp/verify

The bridge may later be implemented as one of these, after final deployment choice:
- Vercel serverless api routes,
- separate Node bridge service,
- or existing Cidentia backend infrastructure.

Not allowed:
- No .tmp local bridge server files.
- No localhost backend dependency in user-facing UI.
- No fake CidenDB success.
- No fake CID session.
- No raw CidenDB token in Flutter state.
- No CidenDB secrets in Flutter.
- No direct Flutter-to-CidenDB sensitive auth call.
- No edits to Live Studio, Chat, Profile, Feed, Reels, shell layout, or right panels for backend work.

Required backend behavior later:
- Read identifier and OTP from Flutter.
- Call CidenDB upstream server-side only.
- Keep upstream credentials server-side only.
- Validate and sanitize the upstream response.
- Return only safe session metadata to Flutter.
- Never expose raw token or sensitive upstream fields to Flutter.

Required Flutter behavior until backend exists:
- Stay signed out.
- Show calm boundary message.
- Keep Feed/Search/Reels public.
- Keep Chats/Live Studio/Profile protected.
- Do not show localhost or server stack errors to users.
- Do not create signedIn state locally from OTP text.

Next implementation step:
Before adding backend skeleton, inspect deployment target and repository structure again.
Then add the smallest possible backend skeleton only if it does not affect Flutter shell or protected navigation.
