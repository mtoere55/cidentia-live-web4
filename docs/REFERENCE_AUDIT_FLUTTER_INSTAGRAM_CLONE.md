# Cidentia.Live Reference Audit - flutter-instagram-offline-first-clone-main

Reference source:
flutter-instagram-offline-first-clone-main

Status:
Read-only reference only. Not source of truth.

Hard rule:
Do not copy blindly.
Do not import Supabase/Auth/Password/Token identity logic.
Cidentia.Live identity authority is CidenDB.
CidentiaApp is onboarding/registration authority.
Cidentia.Live only accepts verified CID sessions.

Useful reference areas:

1. Comments
Reference paths:
lib/comments
lib/comments/comment/widgets/comment_input_controller.dart
lib/comments/comment/widgets/comment_text_input.dart
lib/comments/view/comments_page.dart

Use later for:
CID-protected comment page and input flow.

2. Chats
Reference paths:
lib/chats
lib/chats/chat/widgets/message_bubble.dart
lib/chats/chat/widgets/message_input_controller.dart
lib/chats/chat/widgets/message_text_field.dart
lib/chats/chat/widgets/replied_message_bubble.dart
lib/chats/chat/widgets/swipeable_message.dart

Use later for:
CID-protected real chat UI, message composer, reply/delete UX.

3. Feed/Post
Reference paths:
lib/feed
lib/feed/post
lib/feed/post/widgets
lib/feed/post/video

Use later for:
Post detail, post popup, share sheet, likes display, video post behavior.

4. Reels
Reference paths:
lib/reels
lib/reels/reel/view/reel_view.dart
lib/reels/reel/widgets/vertical_button.dart

Use later for:
Reels action rail, video behavior, vertical viewer polish.

5. Stories
Reference dependencies:
stories_editor
stories_repository
story_view

Use later for:
CID-protected story creation and public story viewing.

6. Navigation
Reference paths:
lib/navigation
lib/home

Use later for:
Mobile bottom navigation ideas only, not direct copy.

7. Localization
Reference paths:
lib/l10n

Use later for:
TR/EN/DE language system design. Do not keep EN/RU structure as-is.

Do not use:
lib/auth
lib/auth/login
lib/auth/sign_up
lib/auth/forgot_password
supabase_authentication_client
token_storage
google_sign_in
password/token/session logic
Firebase/Supabase identity logic

Recommended milestones:

M4B:
Real CidenDB OTP bridge planning and backend boundary.

M4C:
CID session indicator and guest/signed-in state polishing.

M5A:
Comments screen and comment input, CID protected.

M5B:
Chat detail UI, CID protected.

M5C:
Profile public view vs owner profile separation.

M5D:
Story viewer / story row.

M5E:
Upload/media picker planning, CID protected.

M6:
Offline-first/sync architecture review without adopting Supabase auth.
