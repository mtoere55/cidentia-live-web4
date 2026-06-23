import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'auth/cidentia_session_scope.dart';
import 'auth/cidentia_session_state.dart';

import 'local_social_data.dart';
import 'local_social_modules.dart';
import 'widgets/local_post_card.dart';
import 'widgets/local_profile_grid.dart';
import 'widgets/local_stories_bar.dart';
import 'widgets/cidentia_brand_header.dart';
import 'widgets/cidentia_ecosystem_entry_gate.dart';
import 'widgets/local_chat_detail.dart';
import 'widgets/local_reels_page.dart';
import 'widgets/local_live_studio_page.dart';

void main() {
  runApp(const LocalSocialApp());
}

const _bg = Color(0xFF050505);
const _panel = Color(0xFF111113);
const _panelSoft = Color(0xFF18181B);
const _line = Color(0xFF29292E);
const _textSoft = Color(0xFFA1A1AA);

class LocalSocialApp extends StatefulWidget {
  const LocalSocialApp({super.key});

  @override
  State<LocalSocialApp> createState() => _LocalSocialAppState();
}

class _LocalSocialAppState extends State<LocalSocialApp> {
  var _language = CidentiaUiLanguage.en;
  var _entered = false;
  CidentiaSessionState _session = const CidentiaSessionState.signedOut();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cidentia.Live',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: _bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pinkAccent,
          brightness: Brightness.dark,
        ),
        cardTheme: const CardThemeData(
          color: _panel,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(22)),
            side: BorderSide(color: _line),
          ),
        ),
      ),
      home: _entered
          ? CidentiaSessionScope(
              session: _session,
              onSignInRequested: () {
                setState(() {
                  _session = const CidentiaSessionState.signedOut();
                  _entered = false;
                });
              },
              child: LocalShell(language: _language),
            )
          : CidentiaEcosystemEntryGate(
              language: _language,
              onLanguageChanged: (language) =>
                  setState(() => _language = language),
              onEnter: () {
                setState(() {
                  _session = const CidentiaSessionState.signedOut();
                  _entered = true;
                });
              },
              onVerifiedEnter: (session) {
                setState(() {
                  _session = session;
                  _entered = true;
                });
              },
            ),
    );
  }
}

class _SessionLifecycleCard extends StatelessWidget {
  const _SessionLifecycleCard();

  @override
  Widget build(BuildContext context) {
    final session = CidentiaSessionScope.of(context);
    final verified = session.hasVerifiedCid;
    final action = CidentiaSessionScope.onSignInRequestedOf(context);

    final title = verified ? 'Verified CID active' : 'Guest preview';
    final identity = verified
        ? session.cid ?? 'CID verified'
        : 'No verified CID';
    final subtitle = verified
        ? session.email == null
              ? 'Runtime session only. Not persisted.'
              : 'Signed in as ${session.email}'
        : 'Public Feed, Search and Reels stay open. Protected actions require CID.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: verified
              ? const Color(0xFF22C55E).withValues(alpha: 0.45)
              : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                verified
                    ? Icons.verified_user_rounded
                    : Icons.visibility_outlined,
                size: 17,
                color: verified ? const Color(0xFF86EFAC) : _textSoft,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            identity,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: verified ? const Color(0xFF86EFAC) : _textSoft,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _textSoft,
              height: 1.25,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: action,
              icon: Icon(
                verified ? Icons.logout_rounded : Icons.login_rounded,
                size: 16,
              ),
              label: Text(verified ? 'Sign out' : 'Sign in with CID'),
            ),
          ),
        ],
      ),
    );
  }
}

enum LocalSection { feed, search, reels, chats, liveStudio, profile }

enum StudioPanelMode { chat, destinations, status, focus }

extension StudioPanelModeMeta on StudioPanelMode {
  String get label {
    switch (this) {
      case StudioPanelMode.chat:
        return 'Chat';
      case StudioPanelMode.destinations:
        return 'Destinations';
      case StudioPanelMode.status:
        return 'Status';
      case StudioPanelMode.focus:
        return 'Focus';
    }
  }

  IconData get icon {
    switch (this) {
      case StudioPanelMode.chat:
        return Icons.chat_bubble_outline_rounded;
      case StudioPanelMode.destinations:
        return Icons.wifi_tethering_rounded;
      case StudioPanelMode.status:
        return Icons.speed_rounded;
      case StudioPanelMode.focus:
        return Icons.center_focus_strong_rounded;
    }
  }

  String get description {
    switch (this) {
      case StudioPanelMode.chat:
        return 'Expand live chat and audience messages.';
      case StudioPanelMode.destinations:
        return 'Expand stream destinations and routing controls.';
      case StudioPanelMode.status:
        return 'Expand stream health and quality status.';
      case StudioPanelMode.focus:
        return 'Collapse the right panel and give the stage more space.';
    }
  }
}

extension LocalSectionMeta on LocalSection {
  String get label {
    switch (this) {
      case LocalSection.feed:
        return 'Feed';
      case LocalSection.search:
        return 'Search';
      case LocalSection.reels:
        return 'Reels';
      case LocalSection.chats:
        return 'Chats';
      case LocalSection.liveStudio:
        return 'Live Studio';
      case LocalSection.profile:
        return 'Profile';
    }
  }

  IconData get icon {
    switch (this) {
      case LocalSection.feed:
        return Icons.home_rounded;
      case LocalSection.search:
        return Icons.search_rounded;
      case LocalSection.reels:
        return Icons.movie_creation_outlined;
      case LocalSection.chats:
        return Icons.chat_bubble_outline_rounded;
      case LocalSection.liveStudio:
        return Icons.live_tv_rounded;
      case LocalSection.profile:
        return Icons.person_outline_rounded;
    }
  }

  String get mobileLabel {
    switch (this) {
      case LocalSection.feed:
        return 'Feed';
      case LocalSection.search:
        return 'Search';
      case LocalSection.reels:
        return 'Reels';
      case LocalSection.chats:
        return 'Chats';
      case LocalSection.liveStudio:
        return 'Studio';
      case LocalSection.profile:
        return 'Profile';
    }
  }
}

class LocalShell extends StatefulWidget {
  const LocalShell({required this.language, super.key});

  final CidentiaUiLanguage language;

  @override
  State<LocalShell> createState() => _LocalShellState();
}

class _LocalShellState extends State<LocalShell> {
  LocalSection selected = LocalSection.feed;
  StudioPanelMode studioPanelMode = StudioPanelMode.chat;

  Widget get page {
    switch (selected) {
      case LocalSection.feed:
        return const FeedPreviewPage();
      case LocalSection.search:
        return const SearchPreviewPage();
      case LocalSection.reels:
        return const OriginalInspiredReelsPage();
      case LocalSection.chats:
        return const OriginalInspiredChatsPage();
      case LocalSection.liveStudio:
        return OriginalInspiredLiveStudioPage(
          showStageChatOverlay: studioPanelMode == StudioPanelMode.focus,
        );
      case LocalSection.profile:
        return const OriginalInspiredProfilePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        final liveStudioFocus =
            selected == LocalSection.liveStudio &&
            studioPanelMode == StudioPanelMode.focus;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                Container(
                  width: 260,
                  decoration: const BoxDecoration(
                    color: _panel,
                    border: Border(right: BorderSide(color: _line)),
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 24, 18, 18),
                          child: CidentiaBrandHeader(),
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: _SessionLifecycleCard(),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              for (final section in LocalSection.values)
                                _SideNavTile(
                                  section: section,
                                  selected: selected == section,
                                  onTap: () =>
                                      setState(() => selected = section),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                          child: _DesktopCreatePreviewButton(
                            onTap: () => _showLocalCreatePreviewSheet(context),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: _DesktopDraftTrayButton(
                            onTap: () => _showLocalDraftTraySheet(context),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: _LocalStatusCard(),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: page),
                if (selected == LocalSection.liveStudio)
                  if (liveStudioFocus)
                    Container(
                      width: 84,
                      decoration: const BoxDecoration(
                        color: _panel,
                        border: Border(left: BorderSide(color: _line)),
                      ),
                      child: SafeArea(
                        child: _LiveStudioFocusRail(
                          onExitFocus: () => setState(
                            () => studioPanelMode = StudioPanelMode.chat,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 320,
                      decoration: const BoxDecoration(
                        color: _panel,
                        border: Border(left: BorderSide(color: _line)),
                      ),
                      child: SafeArea(
                        child: LiveStudioRightPanel(
                          mode: studioPanelMode,
                          onModeChanged: (mode) =>
                              setState(() => studioPanelMode = mode),
                        ),
                      ),
                    ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: _bg,
            surfaceTintColor: Colors.transparent,
            title: Text(
              selected == LocalSection.feed
                  ? widget.language.appTitle
                  : selected.label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            actions: [
              IconButton(
                tooltip: 'Saved items',
                onPressed: () => _showLocalShellNotice(
                  context,
                  'Saved items',
                  'Saved and liked creator items will open through the personal library.',
                ),
                icon: const Icon(Icons.favorite_border_rounded),
              ),
              IconButton(
                tooltip: 'Draft tray',
                onPressed: () => _showLocalDraftTraySheet(context),
                icon: const Icon(Icons.drafts_outlined),
              ),
              IconButton(
                tooltip: 'Create Hub',
                onPressed: () => _showLocalCreatePreviewSheet(context),
                icon: const Icon(Icons.add_box_outlined),
              ),
              const SizedBox(width: 6),
            ],
          ),
          body: page,
          bottomNavigationBar: NavigationBar(
            height: 68,
            backgroundColor: _panel,
            indicatorColor: Colors.white10,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: selected.index,
            onDestinationSelected: (index) {
              setState(() => selected = LocalSection.values[index]);
            },
            destinations: [
              for (final section in LocalSection.values)
                NavigationDestination(
                  icon: Icon(section.icon, size: 22),
                  selectedIcon: Icon(
                    section.icon,
                    color: Colors.white,
                    size: 23,
                  ),
                  label: section.mobileLabel,
                ),
            ],
          ),
        );
      },
    );
  }
}

void _showLocalShellNotice(BuildContext context, String title, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text('$title ? $message'),
    ),
  );
}

Future<void> _showLocalCreatePreviewSheet(BuildContext context) async {
  final draft = await showModalBottomSheet<_LocalDraftPreview>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const _LocalCreatePreviewSheet(),
  );

  if (!context.mounted || draft == null) {
    return;
  }

  final captionPreview = draft.caption.trim().isEmpty
      ? 'No caption yet'
      : draft.caption.trim();

  _localDraftTray.value = [
    draft,
    ..._localDraftTray.value,
  ].take(12).toList(growable: false);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(
        'Local draft saved: ${draft.mode} ${draft.mediaType} - '
        '${draft.mediaSource} - ${draft.mediaLabel} - $captionPreview',
      ),
    ),
  );
}

class _LocalDraftPreview {
  const _LocalDraftPreview({
    required this.mode,
    required this.mediaType,
    required this.mediaLabel,
    required this.mediaSource,
    required this.caption,
  });

  final String mode;
  final String mediaType;
  final String mediaLabel;
  final String mediaSource;
  final String caption;
}

final ValueNotifier<List<_LocalDraftPreview>> _localDraftTray =
    ValueNotifier<List<_LocalDraftPreview>>(const []);

Future<void> _showLocalDraftTraySheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const _LocalDraftTraySheet(),
  );
}

class _LocalDraftTraySheet extends StatelessWidget {
  const _LocalDraftTraySheet();

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.82;

    return Container(
      margin: const EdgeInsets.all(10),
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x77000000),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: ValueListenableBuilder<List<_LocalDraftPreview>>(
            valueListenable: _localDraftTray,
            builder: (context, drafts, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.drafts_outlined),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Draft tray',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Local-only saved create drafts',
                              style: TextStyle(
                                color: _textSoft,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (drafts.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            _localDraftTray.value = const [];
                          },
                          child: const Text('Clear'),
                        ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const _DraftTrayInfoNotice(),
                  const SizedBox(height: 14),
                  if (drafts.isEmpty)
                    const _EmptyDraftTray()
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: drafts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          return _DraftTrayCard(
                            draft: drafts[index],
                            index: index,
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DraftTrayInfoNotice extends StatelessWidget {
  const _DraftTrayInfoNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline_rounded, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Drafts are saved locally for now. You can prepare media and captions before publishing is connected.',
              style: TextStyle(color: _textSoft, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDraftTray extends StatelessWidget {
  const _EmptyDraftTray();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: const Column(
        children: [
          Icon(Icons.drafts_outlined, size: 34, color: _textSoft),
          const SizedBox(height: 10),
          Text(
            'No local drafts yet',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            'Use Create preview and save a local draft to see it here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textSoft, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _DraftTrayCard extends StatelessWidget {
  const _DraftTrayCard({required this.draft, required this.index});

  final _LocalDraftPreview draft;
  final int index;

  @override
  Widget build(BuildContext context) {
    final caption = draft.caption.trim().isEmpty
        ? 'No caption yet'
        : draft.caption.trim();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
              ),
            ),
            child: Icon(
              draft.mediaType == 'Photo'
                  ? Icons.image_outlined
                  : Icons.play_circle_outline_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${draft.mode} ${draft.mediaType} #${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  draft.mediaLabel,
                  style: const TextStyle(
                    color: _textSoft,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Source: ${draft.mediaSource}',
                  style: const TextStyle(
                    color: _textSoft,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(height: 1.25),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.lock_outline_rounded, color: _textSoft, size: 18),
        ],
      ),
    );
  }
}

class _LocalCreatePreviewSheet extends StatefulWidget {
  const _LocalCreatePreviewSheet();

  @override
  State<_LocalCreatePreviewSheet> createState() =>
      _LocalCreatePreviewSheetState();
}

class _LocalCreatePreviewSheetState extends State<_LocalCreatePreviewSheet> {
  String selectedMode = 'Post';
  String selectedMediaType = 'Photo';
  String selectedMediaLabel = 'Local frame 01';
  String selectedMediaSource = 'Device gallery';
  static const _uploadRequestEndpoint = String.fromEnvironment(
    'CIDENTIA_LIVE_API_BASE_URL',
    defaultValue: 'https://api.cidentia.live',
  );

  String? mediaPickerStatus;
  final TextEditingController captionController = TextEditingController();

  String get _selectedUploadMimeType {
    switch (selectedMediaType) {
      case 'Video':
        return 'video/mp4';
      case 'Audio':
        return 'audio/mpeg';
      case 'Photo':
      default:
        return 'image/png';
    }
  }

  String get _selectedUploadFilename {
    final safeLabel = selectedMediaLabel
        .trim()
        .replaceAll(RegExp('[^a-zA-Z0-9._-]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');

    final base = safeLabel.isEmpty ? 'cidentia-upload-preview' : safeLabel;

    switch (selectedMediaType) {
      case 'Video':
        return '$base.mp4';
      case 'Audio':
        return '$base.mp3';
      case 'Photo':
      default:
        return '$base.png';
    }
  }

  String get _selectedUploadSurface {
    switch (selectedMode) {
      case 'Reel':
        return 'reel';
      case 'Story':
        return 'story';
      case 'Replay':
        return 'replay';
      case 'Post':
      default:
        return 'post';
    }
  }

  Future<void> _pickDeviceMedia() async {
    setState(() {
      mediaPickerStatus = 'Requesting upload permission from backend...';
    });

    final endpoint = Uri.parse('$_uploadRequestEndpoint/api/upload/request');
    final session = CidentiaSessionScope.of(context);
    final cid = session.hasVerifiedCid ? session.cid?.trim() : null;
    final hasCid = cid != null && cid.isNotEmpty;

    try {
      final client = HttpClient();
      final request = await client.postUrl(endpoint);
      request.headers.contentType = ContentType.json;

      if (hasCid) {
        request.headers.add('x-cidentia-cid', cid);
      }

      request.write(
        jsonEncode({
          'mode': selectedMode,
          'mediaType': selectedMediaType,
          'mediaSource': selectedMediaSource,
          'mediaLabel': selectedMediaLabel,
          'filename': _selectedUploadFilename,
          'mimeType': _selectedUploadMimeType,
          'surface': _selectedUploadSurface,
          'client': 'cidentia-live-local-create-preview',
          if (hasCid) 'ownerCid': cid,
          if (session.email != null) 'ownerEmail': session.email,
        }),
      );

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      client.close(force: true);

      final decoded = jsonDecode(body);
      final data = decoded is Map<String, dynamic> ? decoded : null;
      final code = data?['code'];
      final message = data?['message'];
      final signedUrlCreated = data?['signedUploadUrlCreated'] == true;
      final objectKey = data?['storageObjectKey'];
      final expires = data?['expiresInSeconds'];

      if (!mounted) {
        return;
      }

      setState(() {
        if (signedUrlCreated) {
          mediaPickerStatus =
              'SIGNED_UPLOAD_URL_CREATED - Upload permission ready. Object: ${objectKey ?? _selectedUploadFilename}. Expires: ${expires ?? 0}s.';
        } else {
          mediaPickerStatus =
              '${code ?? 'UPLOAD_REQUEST_PENDING'} - ${message ?? 'Upload request did not return a signed URL yet.'}';
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        mediaPickerStatus =
            'Upload request unavailable. Backend connection did not answer.';
      });
    }
  }

  Future<void> _reviewCreatorPolicyThenShowPublishNotice() async {
    final accepted = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _CreatePolicyGateSheet(),
    );

    if (!mounted || accepted != true) {
      return;
    }

    setState(() {
      mediaPickerStatus =
          'Policy reviewed. Publish will require verified CID and media release connection.';
    });
  }

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

    return Container(
      margin: const EdgeInsets.all(10),
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x77000000),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _CreateSheetHeader(),
              const SizedBox(height: 14),
              _CreateModeRow(
                selectedMode: selectedMode,
                onModeChanged: (mode) => setState(() => selectedMode = mode),
              ),
              const SizedBox(height: 14),
              if (selectedMode == 'Post' ||
                  selectedMode == 'Reel' ||
                  selectedMode == 'Story' ||
                  selectedMode == 'Replay') ...[
                _CreatePickerPreview(
                  selectedType: selectedMediaType,
                  selectedLabel: selectedMediaLabel,
                  onMediaSelected: (type, label) => setState(() {
                    selectedMediaType = type;
                    selectedMediaLabel = label;
                    mediaPickerStatus = null;
                  }),
                ),
                const SizedBox(height: 14),
                _CreateMediaSourcePicker(
                  selectedSource: selectedMediaSource,
                  onSourceSelected: (source) => setState(() {
                    selectedMediaSource = source;
                  }),
                ),
                if (mediaPickerStatus != null) ...[
                  const SizedBox(height: 10),
                  _CreateMediaPickerStatus(message: mediaPickerStatus!),
                ],
                const SizedBox(height: 14),
                _CreateMediaPreview(
                  mode: selectedMode,
                  mediaType: selectedMediaType,
                  mediaLabel: selectedMediaLabel,
                ),
                const SizedBox(height: 14),
                _CreateCaptionPreview(controller: captionController),
                const SizedBox(height: 14),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await _pickDeviceMedia();
                            },
                            icon: const Icon(Icons.cloud_upload_outlined),
                            label: const Text('Upload media'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed:
                                _reviewCreatorPolicyThenShowPublishNotice,
                            icon: const Icon(Icons.publish_outlined),
                            label: const Text('Publish'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop(
                            _LocalDraftPreview(
                              mode: selectedMode,
                              mediaType: selectedMediaType,
                              mediaLabel: selectedMediaLabel,
                              mediaSource: selectedMediaSource,
                              caption: captionController.text,
                            ),
                          );
                        },
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Save draft'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                _CreateHubPreviewCard(mode: selectedMode),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateSheetHeader extends StatelessWidget {
  const _CreateSheetHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.add_box_outlined),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create preview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 3),
              Text(
                'Choose what you want to create',
                style: TextStyle(color: _textSoft, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }
}

class _CreatePolicyGateSheet extends StatelessWidget {
  const _CreatePolicyGateSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x77000000),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                Icon(Icons.policy_outlined),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Cidentia creator policy',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const _PolicyGateLine(
              icon: Icons.verified_user_outlined,
              text: 'Publishing requires a verified CidenDB/CID session.',
            ),
            const _PolicyGateLine(
              icon: Icons.video_library_outlined,
              text:
                  'Media release, rights and safety checks apply before public posting.',
            ),
            const _PolicyGateLine(
              icon: Icons.account_balance_wallet_outlined,
              text:
                  'Ad, donation and market actions stay separated from draft creation.',
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Not now'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Review and continue'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyGateLine extends StatelessWidget {
  const _PolicyGateLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: _textSoft, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: _textSoft, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateModeRow extends StatelessWidget {
  const _CreateModeRow({
    required this.selectedMode,
    required this.onModeChanged,
  });

  final String selectedMode;
  final ValueChanged<String> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _CreateModeChip(
          icon: Icons.crop_square_rounded,
          label: 'Post',
          active: selectedMode == 'Post',
          onTap: () => onModeChanged('Post'),
        ),
        _CreateModeChip(
          icon: Icons.movie_creation_outlined,
          label: 'Reel',
          active: selectedMode == 'Reel',
          onTap: () => onModeChanged('Reel'),
        ),
        _CreateModeChip(
          icon: Icons.auto_stories_outlined,
          label: 'Story',
          active: selectedMode == 'Story',
          onTap: () => onModeChanged('Story'),
        ),
        _CreateModeChip(
          icon: Icons.live_tv_outlined,
          label: 'Live',
          active: selectedMode == 'Live',
          onTap: () => onModeChanged('Live'),
        ),
        _CreateModeChip(
          icon: Icons.auto_awesome_outlined,
          label: 'AI',
          active: selectedMode == 'AI',
          onTap: () => onModeChanged('AI'),
        ),
        _CreateModeChip(
          icon: Icons.campaign_outlined,
          label: 'Ad',
          active: selectedMode == 'Ad',
          onTap: () => onModeChanged('Ad'),
        ),
        _CreateModeChip(
          icon: Icons.volunteer_activism_outlined,
          label: 'Donation',
          active: selectedMode == 'Donation',
          onTap: () => onModeChanged('Donation'),
        ),
        _CreateModeChip(
          icon: Icons.storefront_outlined,
          label: 'Market',
          active: selectedMode == 'Market',
          onTap: () => onModeChanged('Market'),
        ),
        _CreateModeChip(
          icon: Icons.video_library_outlined,
          label: 'Replay',
          active: selectedMode == 'Replay',
          onTap: () => onModeChanged('Replay'),
        ),
      ],
    );
  }
}

class _CreateModeChip extends StatelessWidget {
  const _CreateModeChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: active ? Colors.white : _panelSoft,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: active ? Colors.white : _line),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: active ? Colors.black : Colors.white, size: 17),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateHubPreviewCard extends StatelessWidget {
  const _CreateHubPreviewCard({required this.mode});

  final String mode;

  @override
  Widget build(BuildContext context) {
    final data = switch (mode) {
      'Live' => (
        Icons.live_tv_outlined,
        'Open Live Studio',
        'Create a live room with camera, guests, chat and destinations.',
      ),
      'AI' => (
        Icons.auto_awesome_outlined,
        'AI Create',
        'Create images, captions, clips and creator ideas with AI.',
      ),
      'Ad' => (
        Icons.campaign_outlined,
        'Promotion',
        'Prepare a campaign for a post, product or creator profile.',
      ),
      'Donation' => (
        Icons.volunteer_activism_outlined,
        'Donation campaign',
        'Prepare a verified campaign for community support.',
      ),
      'Market' => (
        Icons.storefront_outlined,
        'Market listing',
        'Create a product, service or digital asset listing.',
      ),
      _ => (
        Icons.add_box_outlined,
        'Create',
        'Choose a create type to continue.',
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            child: Icon(data.$1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.$2,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  data.$3,
                  style: const TextStyle(color: _textSoft, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatePickerPreview extends StatelessWidget {
  const _CreatePickerPreview({
    required this.selectedType,
    required this.selectedLabel,
    required this.onMediaSelected,
  });

  final String selectedType;
  final String selectedLabel;
  final void Function(String type, String label) onMediaSelected;

  @override
  Widget build(BuildContext context) {
    const photoItems = ['Local frame 01', 'Local frame 02', 'Local frame 03'];
    const videoItems = ['Local clip 01', 'Local clip 02', 'Local clip 03'];
    final items = selectedType == 'Photo' ? photoItems : videoItems;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Local media picker preview',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text(
            'Backend upload request is connected. File picking opens in the next upload step.',
            style: TextStyle(color: _textSoft, height: 1.25),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PickerTypeChip(
                label: 'Photo',
                icon: Icons.photo_library_outlined,
                active: selectedType == 'Photo',
                onTap: () => onMediaSelected('Photo', photoItems.first),
              ),
              _PickerTypeChip(
                label: 'Video',
                icon: Icons.video_library_outlined,
                active: selectedType == 'Video',
                onTap: () => onMediaSelected('Video', videoItems.first),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final item in items)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: item == items.last ? 0 : 8),
                    child: _PickerThumb(
                      label: item,
                      icon: selectedType == 'Photo'
                          ? Icons.image_outlined
                          : Icons.play_circle_outline_rounded,
                      active: selectedLabel == item,
                      onTap: () => onMediaSelected(selectedType, item),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PickerTypeChip extends StatelessWidget {
  const _PickerTypeChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: active ? Colors.white : _line),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: active ? Colors.black : Colors.white, size: 16),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerThumb extends StatelessWidget {
  const _PickerThumb({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 82,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: active ? Colors.white : _line),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? Colors.black : Colors.white),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: active ? Colors.black : Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateMediaSourcePicker extends StatelessWidget {
  const _CreateMediaSourcePicker({
    required this.selectedSource,
    required this.onSourceSelected,
  });

  final String selectedSource;
  final ValueChanged<String> onSourceSelected;

  @override
  Widget build(BuildContext context) {
    const sources = [
      ('Device gallery', Icons.photo_library_outlined),
      ('Camera capture', Icons.photo_camera_outlined),
      ('Live replay', Icons.history_rounded),
      ('Studio clip', Icons.video_library_outlined),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose media source',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final source in sources)
                _CreateSourceOptionChip(
                  label: source.$1,
                  icon: source.$2,
                  selected: selectedSource == source.$1,
                  onTap: () => onSourceSelected(source.$1),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreateSourceOptionChip extends StatelessWidget {
  const _CreateSourceOptionChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onSelected: (_) => onTap(),
    );
  }
}

class _CreateMediaPickerStatus extends StatelessWidget {
  const _CreateMediaPickerStatus({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_file_rounded, size: 17, color: _textSoft),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: _textSoft,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateMediaPreview extends StatelessWidget {
  const _CreateMediaPreview({
    required this.mode,
    required this.mediaType,
    required this.mediaLabel,
  });

  final String mode;
  final String mediaType;
  final String mediaLabel;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.35,
      child: Container(
        decoration: BoxDecoration(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _line),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Center(
              child: Icon(
                mediaType == 'Photo'
                    ? Icons.add_photo_alternate_outlined
                    : Icons.play_circle_outline_rounded,
                size: 58,
                color: Colors.white,
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Text(
                '$mode $mediaType preview - $mediaLabel',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateCaptionPreview extends StatelessWidget {
  const _CreateCaptionPreview({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 3,
      maxLines: 5,
      decoration: InputDecoration(
        filled: true,
        fillColor: _panelSoft,
        labelText: 'Caption',
        hintText: 'Write a local draft caption...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _line),
        ),
      ),
    );
  }
}

class _SideNavTile extends StatelessWidget {
  const _SideNavTile({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  final LocalSection section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? Colors.white10 : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Icon(section.icon, size: 25),
              const SizedBox(width: 14),
              Text(
                section.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopDraftTrayButton extends StatelessWidget {
  const _DesktopDraftTrayButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<_LocalDraftPreview>>(
      valueListenable: _localDraftTray,
      builder: (context, drafts, _) {
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _panelSoft,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _line),
            ),
            child: Row(
              children: [
                const Icon(Icons.drafts_outlined, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Draft tray',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                Text(
                  '${drafts.length}',
                  style: const TextStyle(
                    color: _textSoft,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DesktopCreatePreviewButton extends StatelessWidget {
  const _DesktopCreatePreviewButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.add_box_outlined, size: 20),
        label: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Create preview',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _LocalStatusCard extends StatelessWidget {
  const _LocalStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Creator workspace',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Profile, live rooms, drafts and creator tools are ready for CID flow.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: _textSoft, height: 1.2),
          ),
        ],
      ),
    );
  }
}

class FeedPreviewPage extends StatelessWidget {
  const FeedPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            const SliverToBoxAdapter(child: OriginalInspiredStoriesBar()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverList.separated(
              itemCount: localPosts.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                if (index == 1) {
                  return const _SuggestedCreatorsPreview();
                }

                final postIndex = index > 1 ? index - 1 : index;
                return OriginalInspiredPostCard(post: localPosts[postIndex]);
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 60)),
          ],
        ),
      ),
    );
  }
}

class StoriesStrip extends StatelessWidget {
  const StoriesStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: localStories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final story = localStories[index];
          final isLiveStory = index == 1 && !story.isCreate;

          return GestureDetector(
            onTap: isLiveStory
                ? () => _showStoryLiveRoomPreview(
                    context,
                    story.label,
                    story.color,
                  )
                : null,
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: isLiveStory
                              ? const [Color(0xFFFF1744), Color(0xFF8B5CF6)]
                              : [story.color, Colors.pinkAccent],
                        ),
                        boxShadow: isLiveStory
                            ? const [
                                BoxShadow(
                                  color: Color(0x55FF1744),
                                  blurRadius: 18,
                                  offset: Offset(0, 8),
                                ),
                              ]
                            : null,
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: _bg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          story.isCreate
                              ? Icons.add_rounded
                              : isLiveStory
                              ? Icons.wifi_tethering_rounded
                              : Icons.person_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (isLiveStory)
                      const Positioned(
                        left: 12,
                        right: 12,
                        bottom: -7,
                        child: _StoryLiveBadge(),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  story.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isLiveStory ? FontWeight.w900 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StoryLiveBadge extends StatefulWidget {
  const _StoryLiveBadge();

  @override
  State<_StoryLiveBadge> createState() => _StoryLiveBadgeState();
}

class _StoryLiveBadgeState extends State<_StoryLiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    )..repeat(reverse: true);

    _pulse = Tween<double>(
      begin: 0.5,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _pulse,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFF1744),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: Colors.white24),
        ),
        child: const Text(
          'LIVE',
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

void _showStoryLiveRoomPreview(
  BuildContext context,
  String creator,
  Color accent,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF121217),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _line),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _line,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Cidentia Live Room',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                '$creator - Story live discovery',
                style: const TextStyle(color: _textSoft),
              ),
              const SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 1.35,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [accent, const Color(0xFF8B5CF6)],
                    ),
                    border: Border.all(color: _line),
                  ),
                  child: Stack(
                    children: [
                      const Positioned(
                        left: 16,
                        top: 16,
                        child: _StoryLiveBadge(),
                      ),
                      Center(
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.black38,
                          child: Text(
                            creator.characters.first,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Text(
                          'Story live discovery - Signal, Proof and Effect tools connect in upcoming creator releases.',
                          style: TextStyle(color: Colors.white70, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B22),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _line),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.remove_red_eye_outlined, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'CID-safe viewers - 1.2K',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Spacer(),
                        Text(
                          'Signal 94%',
                          style: TextStyle(color: Color(0xFF22C55E)),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Mira: Story room is live now.',
                      style: TextStyle(color: Colors.white70, height: 1.3),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Viewer: Proof reaction sent - effect preview earned.',
                      style: TextStyle(color: Colors.white60, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _StoryLiveAction(
                      icon: Icons.remove_red_eye_outlined,
                      label: 'Enter',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StoryLiveAction(
                      icon: Icons.auto_awesome_rounded,
                      label: 'Effect',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StoryLiveAction(
                      icon: Icons.verified_user_outlined,
                      label: 'Proof',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _StoryLiveAction extends StatelessWidget {
  const _StoryLiveAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _line),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestedCreatorsPreview extends StatefulWidget {
  const _SuggestedCreatorsPreview();

  @override
  State<_SuggestedCreatorsPreview> createState() =>
      _SuggestedCreatorsPreviewState();
}

class _SuggestedCreatorsPreviewState extends State<_SuggestedCreatorsPreview> {
  final Set<String> following = {};

  static const creators = [
    (
      name: 'Aylin Creator',
      handle: '@aylin.creator',
      signal: 'CID-ready creator',
      colors: [Color(0xFF60A5FA), Color(0xFF8B5CF6)],
    ),
    (
      name: 'Live Builder',
      handle: '@live.builder',
      signal: 'Live room host',
      colors: [Color(0xFF22C55E), Color(0xFF14B8A6)],
    ),
    (
      name: 'Market Studio',
      handle: '@market.studio',
      signal: 'Market-ready creator',
      colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
    ),
    (
      name: 'Truth Creator',
      handle: '@truth.creator',
      signal: 'Proof signal creator',
      colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
    ),
  ];

  void _openCreatorProfile(
    BuildContext context, {
    required String name,
    required String handle,
    required String signal,
    required List<Color> colors,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _line),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 180,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: colors,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(painter: _SubtlePatternPainter()),
                      ),
                      Center(
                        child: Container(
                          width: 92,
                          height: 92,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            gradient: LinearGradient(colors: colors),
                          ),
                          child: CircleAvatar(
                            backgroundColor: _panel,
                            child: Text(
                              name.characters.first,
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(handle, style: const TextStyle(color: _textSoft)),
                const SizedBox(height: 10),
                Text(
                  signal,
                  style: const TextStyle(
                    color: Color(0xFF86EFAC),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _MiniCreatorStat(label: 'Posts', value: 'Preview'),
                    _MiniCreatorStat(label: 'Live', value: 'Ready'),
                    _MiniCreatorStat(label: 'CID', value: 'Needed'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showLocalShellNotice(
                            context,
                            'Follow preview',
                            'Creator follow activates after the social graph is connected.',
                          );
                        },
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        label: const Text('Follow'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showLocalShellNotice(
                            context,
                            'Creator profile',
                            'Full creator profile opens after profile routes are connected.',
                          );
                        },
                        icon: const Icon(Icons.person_outline_rounded),
                        label: const Text('View profile'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person_add_alt_1_outlined, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Suggested creators',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 204,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 700;
                  final visibleCount = isWide ? 4 : 2;
                  final gapTotal = 10 * (visibleCount - 1);
                  final cardWidth =
                      (constraints.maxWidth - gapTotal) / visibleCount;

                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: creators.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final creator = creators[index];
                      final isFollowing = following.contains(creator.handle);

                      return SizedBox(
                        width: cardWidth,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _openCreatorProfile(
                            context,
                            name: creator.name,
                            handle: creator.handle,
                            signal: creator.signal,
                            colors: creator.colors,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _panelSoft,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _line),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 54,
                                  height: 54,
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: creator.colors,
                                    ),
                                  ),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: _panel,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        creator.name.substring(0, 1),
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  creator.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  creator.handle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: _textSoft,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  creator.signal,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: _textSoft,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed: () {
                                      setState(() {
                                        if (isFollowing) {
                                          following.remove(creator.handle);
                                        } else {
                                          following.add(creator.handle);
                                        }
                                      });
                                    },
                                    child: Text(
                                      isFollowing ? 'Following' : 'Follow',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubtlePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    for (var i = 0; i < 7; i++) {
      final dx = size.width * (i / 6);
      canvas.drawLine(
        Offset(dx, 0),
        Offset(size.width - dx, size.height),
        line,
      );
    }

    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.30),
      size.shortestSide * 0.22,
      line,
    );

    canvas.drawCircle(
      Offset(size.width * 0.20, size.height * 0.86),
      size.shortestSide * 0.26,
      line,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniCreatorStat extends StatelessWidget {
  const _MiniCreatorStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(color: _textSoft, fontSize: 12)),
      ],
    );
  }
}

class LocalPostCard extends StatelessWidget {
  const LocalPostCard({super.key, required this.post});

  final LocalPost post;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: post.accent.first,
                child: Text(post.author.characters.first),
              ),
              title: Text(
                post.author,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text('${post.handle} - ${post.time}'),
              trailing: const Icon(Icons.more_horiz_rounded),
            ),
          ),
          AspectRatio(
            aspectRatio: 1.35,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: post.accent,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _GridGlowPainter()),
                  ),
                  const Center(
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 76,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                _Action(icon: Icons.favorite_border_rounded, label: post.likes),
                const SizedBox(width: 18),
                _Action(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: post.comments,
                ),
                const SizedBox(width: 18),
                const _Action(icon: Icons.send_outlined, label: 'Share'),
                const Spacer(),
                const Icon(Icons.bookmark_border_rounded),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Text(post.caption, style: const TextStyle(height: 1.35)),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 23),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class SearchPreviewPage extends StatelessWidget {
  const SearchPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _PageFrame(
      title: 'Search',
      child: GridView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: 24,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 210,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemBuilder: (context, index) {
          final colors = localPosts[index % localPosts.length].accent;
          final isLive = index % 7 == 2;
          final isReel = !isLive && index % 3 == 1;
          final label = isLive
              ? 'LIVE'
              : isReel
              ? 'Reel'
              : 'Post';
          final views = [
            '445K',
            '1.4M',
            '3.2M',
            '6M',
            '7.2M',
            '13.9M',
          ][index % 6];

          return InkWell(
            onTap: () => _openSearchMediaPreview(
              context,
              index: index,
              label: label,
              views: views,
              colors: colors,
              isLive: isLive,
              isReel: isReel,
            ),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.04),
                            Colors.black.withValues(alpha: 0.28),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      isLive
                          ? Icons.live_tv_rounded
                          : isReel
                          ? Icons.play_circle_outline_rounded
                          : Icons.photo_camera_outlined,
                      size: 54,
                      color: Colors.white.withValues(alpha: 0.30),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.34),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isLive
                                ? Icons.fiber_manual_record_rounded
                                : isReel
                                ? Icons.play_arrow_rounded
                                : Icons.grid_on_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.remove_red_eye_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          views,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

void _openSearchMediaPreview(
  BuildContext context, {
  required int index,
  required String label,
  required String views,
  required List<Color> colors,
  required bool isLive,
  required bool isReel,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _line),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isLive
                        ? Icons.live_tv_rounded
                        : isReel
                        ? Icons.play_circle_outline_rounded
                        : Icons.photo_camera_outlined,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$label preview',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    views,
                    style: const TextStyle(
                      color: _textSoft,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AspectRatio(
                aspectRatio: isReel || isLive ? 9 / 14 : 1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: colors,
                    ),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          isLive
                              ? Icons.sensors_rounded
                              : isReel
                              ? Icons.play_arrow_rounded
                              : Icons.grid_on_rounded,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.34),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        top: 14,
                        child: _SearchPreviewPill(label: label),
                      ),
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 14,
                        child: Text(
                          isLive
                              ? 'Live room discovery. Creator stream route opens through verified access.'
                              : isReel
                              ? 'Reel discovery. Playback opens through the creator media route.'
                              : 'Post discovery. Detail opens through the creator content route.',
                          style: const TextStyle(
                            color: Colors.white,
                            height: 1.3,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _SearchPreviewPill extends StatelessWidget {
  const _SearchPreviewPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class ReelsPreviewPage extends StatelessWidget {
  const ReelsPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _PageFrame(
      title: 'Reels',
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: 5,
        itemBuilder: (context, index) {
          final post = localPosts[index % localPosts.length];
          return Padding(
            padding: const EdgeInsets.all(18),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: post.accent,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _GridGlowPainter()),
                  ),
                  Positioned(
                    left: 24,
                    right: 88,
                    bottom: 28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.handle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(post.caption),
                      ],
                    ),
                  ),
                  const Positioned(
                    right: 22,
                    bottom: 28,
                    child: Column(
                      children: [
                        Icon(Icons.favorite_rounded, size: 34),
                        SizedBox(height: 22),
                        Icon(Icons.chat_bubble_rounded, size: 32),
                        SizedBox(height: 22),
                        Icon(Icons.send_rounded, size: 32),
                      ],
                    ),
                  ),
                  const Center(child: Icon(Icons.play_arrow_rounded, size: 88)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChatsPreviewPage extends StatelessWidget {
  const ChatsPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _PageFrame(
      title: 'Chats',
      child: ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: localChats.length,
        separatorBuilder: (_, __) => const Divider(color: _line),
        itemBuilder: (context, index) {
          final chat = localChats[index];
          return Material(
            color: Colors.transparent,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    localPosts[index % localPosts.length].accent.first,
                child: Text(chat.name.characters.first),
              ),
              title: Text(
                chat.name,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(chat.message),
              trailing: Text(
                chat.time,
                style: const TextStyle(color: _textSoft),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProfilePreviewPage extends StatelessWidget {
  const ProfilePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _PageFrame(
      title: 'Profile',
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.pinkAccent,
                        child: Icon(Icons.person_rounded, size: 44),
                      ),
                      const SizedBox(width: 22),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'local.creator',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Cidentia creator profile. Verified CID, wallet and proof routes connect through protected access.',
                              style: TextStyle(color: _textSoft, height: 1.35),
                            ),
                          ],
                        ),
                      ),
                      FilledButton(onPressed: () {}, child: const Text('Edit')),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  _StatCard(label: 'Posts', value: '128'),
                  SizedBox(width: 12),
                  _StatCard(label: 'Followers', value: '18.4K'),
                  SizedBox(width: 12),
                  _StatCard(label: 'Following', value: '421'),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(18),
            sliver: SliverGrid.builder(
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: localPosts[index % localPosts.length].accent,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: _textSoft)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageFrame extends StatelessWidget {
  const _PageFrame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (MediaQuery.sizeOf(context).width >= 900)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 10),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class RightPreviewPanel extends StatelessWidget {
  const RightPreviewPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
      children: [
        const Text(
          'Cidentia Center',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        const Text(
          'CID, wallet, trust and proof modules open through protected creator access.',
          style: TextStyle(color: _textSoft, height: 1.35),
        ),
        const SizedBox(height: 18),
        for (final module in localFutureModules) _ModuleCard(module: module),
        const SizedBox(height: 12),
        const _LocalStatusCard(),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module});

  final LocalFutureModule module;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(colors: module.colors),
                ),
                child: Icon(module.icon, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  module.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              _MetricPill(label: module.status),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            module.value,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            module.subtitle,
            style: const TextStyle(color: _textSoft, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _GridGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1;

    for (var x = 0.0; x < size.width; x += 38) {
      canvas.drawLine(Offset(x, 0), Offset(x + 80, size.height), linePaint);
    }

    for (var y = 0.0; y < size.height; y += 38) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 40), linePaint);
    }

    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 32);

    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.25),
      size.shortestSide * 0.22,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LiveStudioRightPanel extends StatelessWidget {
  const LiveStudioRightPanel({
    super.key,
    required this.mode,
    required this.onModeChanged,
  });

  final StudioPanelMode mode;
  final ValueChanged<StudioPanelMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
      children: [
        const Text(
          'Studio Panel',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          mode.description,
          style: const TextStyle(color: _textSoft, height: 1.35),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in StudioPanelMode.values)
              _StudioPanelModeChip(
                mode: item,
                selected: mode == item,
                onTap: () => onModeChanged(item),
              ),
          ],
        ),
        const SizedBox(height: 18),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: KeyedSubtree(key: ValueKey(mode), child: _activePanel()),
        ),
        const SizedBox(height: 14),
        const _StudioPreviewStatusCard(),
        const SizedBox(height: 14),
        const _StudioNextModulesCard(),
      ],
    );
  }

  Widget _activePanel() {
    switch (mode) {
      case StudioPanelMode.chat:
        return const _StudioChatPanelCard();
      case StudioPanelMode.destinations:
        return const _StudioDestinationsPanelCard();
      case StudioPanelMode.status:
        return const _StudioStreamStatusPanelCard();
      case StudioPanelMode.focus:
        return const _StudioFocusPanelCard();
    }
  }
}

class _StudioPreviewStatusCard extends StatelessWidget {
  const _StudioPreviewStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user_outlined, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Preview Safety',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                'LOCAL',
                style: TextStyle(
                  color: Color(0xFF4ADE80),
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Live Studio tools are being prepared here. Production streaming, wallet and creator services connect in their own release steps.',
            style: TextStyle(color: _textSoft, height: 1.35, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StudioNextModulesCard extends StatelessWidget {
  const _StudioNextModulesCard();

  @override
  Widget build(BuildContext context) {
    const modules = [
      ('CID Proof', Icons.badge_outlined),
      ('Wallet', Icons.account_balance_wallet_outlined),
      ('RTMP / Multi', Icons.wifi_tethering_rounded),
      ('TR EN DE', Icons.translate_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Next Studio Modules',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in modules)
                _StudioModulePill(label: item.$1, icon: item.$2),
            ],
          ),
        ],
      ),
    );
  }
}

class _StudioModulePill extends StatelessWidget {
  const _StudioModulePill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF101114),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _textSoft),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: _textSoft,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudioPanelModeChip extends StatelessWidget {
  const _StudioPanelModeChip({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final StudioPanelMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : _panelSoft,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? Colors.white : _line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              mode.icon,
              size: 15,
              color: selected ? Colors.black : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              mode.label,
              style: TextStyle(
                color: selected ? Colors.black : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudioFocusPanelCard extends StatelessWidget {
  const _StudioFocusPanelCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.center_focus_strong_rounded, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Stage Focus',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'The right panel becomes a narrow focus rail so the studio stage can grow.',
            style: TextStyle(color: _textSoft, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _LiveStudioFocusRail extends StatelessWidget {
  const _LiveStudioFocusRail({required this.onExitFocus});

  final VoidCallback onExitFocus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 18, 10, 18),
      child: Column(
        children: [
          IconButton(
            tooltip: 'Exit Focus',
            onPressed: onExitFocus,
            icon: const Icon(Icons.keyboard_double_arrow_left_rounded),
          ),
          const SizedBox(height: 16),
          const RotatedBox(
            quarterTurns: 3,
            child: Text(
              'Stage Focus',
              maxLines: 1,
              style: TextStyle(
                color: _textSoft,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const Spacer(),
          const Icon(Icons.center_focus_strong_rounded, color: Colors.white),
          const SizedBox(height: 10),
          const CircleAvatar(radius: 4, backgroundColor: Color(0xFF4ADE80)),
        ],
      ),
    );
  }
}

class _StudioChatPanelCard extends StatelessWidget {
  const _StudioChatPanelCard();

  @override
  Widget build(BuildContext context) {
    final messages = [
      ('Selin Kaya', 'Great stream!', '12:45'),
      ('Alex M.', 'Love the new Web4 tools.', '12:45'),
      ('CryptoNomad', 'Proof is the future.', '12:46'),
      ('BuildTogether', 'CID is leveling up creators.', '12:46'),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.chat_bubble_outline_rounded, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Live Chat',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                '1.2K',
                style: TextStyle(color: _textSoft, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final msg in messages)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: const Color(0xFF27272A),
                    child: Text(
                      msg.$1.characters.first,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                msg.$1,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              msg.$3,
                              style: const TextStyle(
                                color: _textSoft,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          msg.$2,
                          style: const TextStyle(
                            color: _textSoft,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _line),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'Type a message...',
                    style: TextStyle(color: _textSoft, fontSize: 12),
                  ),
                ),
                Icon(Icons.send_rounded, size: 17),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudioDestinationsPanelCard extends StatelessWidget {
  const _StudioDestinationsPanelCard();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('YouTube', '@CidentiaLive', Color(0xFFFF0000), Icons.play_arrow_rounded),
      ('Twitch', '/cidentialive', Color(0xFF9146FF), Icons.chat_bubble_rounded),
      (
        'Instagram',
        '@cidentia.live',
        Color(0xFFEC4899),
        Icons.camera_alt_rounded,
      ),
      ('Facebook', 'Cidentia.Live', Color(0xFF3B82F6), Icons.facebook_rounded),
      ('TikTok', 'web4/live', Color(0xFF111827), Icons.music_note_rounded),
      ('Custom RTMP', 'rtmp://custom', Color(0xFF334155), Icons.public_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.wifi_tethering_rounded, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Destinations',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                '6 / 6',
                style: TextStyle(
                  color: Color(0xFF4ADE80),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _StudioDestinationRow(
                name: item.$1,
                handle: item.$2,
                color: item.$3,
                icon: item.$4,
              ),
            ),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: () => _showLocalShellNotice(
              context,
              'Add Destination',
              'Destination creation is protected. RTMP and multi-platform routing open through creator studio access.',
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Destination'),
          ),
        ],
      ),
    );
  }
}

class _StudioDestinationRow extends StatelessWidget {
  const _StudioDestinationRow({
    required this.name,
    required this.handle,
    required this.color,
    required this.icon,
  });

  final String name;
  final String handle;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
                Text(
                  handle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _textSoft, fontSize: 11),
                ),
              ],
            ),
          ),
          const Text(
            'LIVE',
            style: TextStyle(
              color: Color(0xFF4ADE80),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.toggle_on_rounded, color: Color(0xFF4ADE80)),
        ],
      ),
    );
  }
}

class _StudioStreamStatusPanelCard extends StatelessWidget {
  const _StudioStreamStatusPanelCard();

  @override
  Widget build(BuildContext context) {
    const stats = [
      ('Video', '1080p60'),
      ('Audio', '48 kHz'),
      ('Bitrate', '6.2 Mbps'),
      ('Dropped Frames', '0'),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.speed_rounded, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Stream Status',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                'Excellent',
                style: TextStyle(
                  color: Color(0xFF4ADE80),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final stat in stats)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      stat.$1,
                      style: const TextStyle(color: _textSoft),
                    ),
                  ),
                  Text(
                    stat.$2,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 8),
                  const CircleAvatar(
                    radius: 4,
                    backgroundColor: Color(0xFF4ADE80),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
