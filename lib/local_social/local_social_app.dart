import 'package:flutter/material.dart';

import 'local_social_data.dart';
import 'local_social_modules.dart';
import 'widgets/local_post_card.dart';
import 'widgets/local_profile_grid.dart';
import 'widgets/local_stories_bar.dart';
import 'widgets/cidentia_brand_header.dart';
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

class LocalSocialApp extends StatelessWidget {
  const LocalSocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Local Preview',
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
      home: const LocalShell(),
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
  const LocalShell({super.key});

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
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: _LocalStatusCard(),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: page),
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
                      child: selected == LocalSection.liveStudio
                          ? LiveStudioRightPanel(
                              mode: studioPanelMode,
                              onModeChanged: (mode) =>
                                  setState(() => studioPanelMode = mode),
                            )
                          : const RightPreviewPanel(),
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
              selected == LocalSection.feed ? 'Cidentia.Live' : selected.label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            actions: [
              IconButton(
                tooltip: 'Local favorites',
                onPressed: () => _showLocalShellNotice(
                  context,
                  'Local favorites',
                  'Saved and liked items are local-preview only in this milestone.',
                ),
                icon: const Icon(Icons.favorite_border_rounded),
              ),
              IconButton(
                tooltip: 'Create preview',
                onPressed: () => _showLocalShellNotice(
                  context,
                  'Create preview',
                  'Creation will be connected only after the approved media/upload milestone.',
                ),
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
            'Cidentia local preview',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 6),
          Text(
            'Local preview only. Backend, CidenDB, wallet and RTMP stay closed.',
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
              itemCount: localPosts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                return OriginalInspiredPostCard(post: localPosts[index]);
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
          return Column(
            children: [
              Container(
                width: 76,
                height: 76,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [localStories[index].color, Colors.pinkAccent],
                  ),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: _bg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    localStories[index].isCreate
                        ? Icons.add_rounded
                        : Icons.person_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                localStories[index].label,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          );
        },
      ),
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

          return Container(
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
          );
        },
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
                              'Local social profile preview. Verified CID and wallet will be connected later.',
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
          'Bu alan ileride CID, wallet, trust ve proof mod\u{00FC}llerinin merkezi olacak.',
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

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(icon),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(subtitle),
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
        const _StudioPreviewBoundaryCard(),
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

class _StudioPreviewBoundaryCard extends StatelessWidget {
  const _StudioPreviewBoundaryCard();

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
            'Studio UI is running as a local preview. Real live backend, wallet, CID and RTMP will open only in their own secured milestones.',
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
              'Destination creation is protected. Real RTMP/backend setup opens only in its own approved milestone.',
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
