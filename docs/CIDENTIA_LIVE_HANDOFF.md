# Cidentia.Live Web4 Flutter Handoff

Project:
Cidentia.Live Web4 Flutter local social preview

Repo path:
C:\PROJELER\cidentia-live-web4

Run command:
flutter run -d windows -t lib/main_local.dart

Sealed chain:
M3A: 3b4264f - Add Cidentia Live Studio UI shell
M3B: c44cb2f - Add Live Studio right panel
M3C: 1f7f85b - Polish Live Studio mobile bottom sheet
M3D: 3c277fe - Add Live Studio destination manager placeholder
M3E: bfbf368 - Add compact Live Translation Hub

Current state:
Flutter Windows local backend-free social preview works.
Feed, Search, Reels, Chats, Profile, and Live Studio exist.
Live Studio has destination manager placeholder.
Live Studio has compact TR / EN / DE Translation Hub.
No real backend is connected.
No real RTMP is connected.
No real stream key is connected.
No real AI translation is connected.
No real live server is connected.

Current milestone:
M3F - Adaptive Studio Panel + Stage Focus

M3F target:
Right Studio Panel must stop being only fixed stacked boxes.
Studio Panel modes:
- Chat
- Destinations
- Status
- Focus

Expected behavior:
Chat mode expands chat.
Destinations mode expands destination manager area.
Status mode expands stream status.
Focus mode hides or collapses the right panel and expands the video stage.
When needed, chat can appear as an overlay on the stage.

Working rules:
Do not write code before checking git status and reading current files.
Do not patch blindly.
Use PowerShell commands.
Use small reversible patches.
Do not add real backend.
Do not add real RTMP.
Do not add real stream keys.
Do not add real AI translation.
Do not add live server connection.
Do not seal before running and checking the app.

Safety:
This is local UI only.
Backend-free preview only.
No production connection.
No live streaming connection.
