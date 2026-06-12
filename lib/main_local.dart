import 'package:flutter/material.dart';

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

enum LocalSection { feed, search, reels, chats, profile }

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
      case LocalSection.profile:
        return Icons.person_outline_rounded;
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

  Widget get page {
    switch (selected) {
      case LocalSection.feed:
        return const FeedPreviewPage();
      case LocalSection.search:
        return const SearchPreviewPage();
      case LocalSection.reels:
        return const ReelsPreviewPage();
      case LocalSection.chats:
        return const ChatsPreviewPage();
      case LocalSection.profile:
        return const ProfilePreviewPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

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
                          padding: EdgeInsets.fromLTRB(24, 26, 24, 18),
                          child: Text(
                            'Social Preview',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.8,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Local dev mode',
                            style: TextStyle(color: _textSoft),
                          ),
                        ),
                        const SizedBox(height: 28),
                        for (final section in LocalSection.values)
                          _SideNavTile(
                            section: section,
                            selected: selected == section,
                            onTap: () => setState(() => selected = section),
                          ),
                        const Spacer(),
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: _LocalStatusCard(),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: page),
                Container(
                  width: 320,
                  decoration: const BoxDecoration(
                    color: _panel,
                    border: Border(left: BorderSide(color: _line)),
                  ),
                  child: const SafeArea(child: RightPreviewPanel()),
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
              selected == LocalSection.feed ? 'Social Preview' : selected.label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            actions: const [
              Icon(Icons.favorite_border_rounded),
              SizedBox(width: 16),
              Icon(Icons.add_box_outlined),
              SizedBox(width: 16),
            ],
          ),
          body: page,
          bottomNavigationBar: NavigationBar(
            backgroundColor: _panel,
            indicatorColor: Colors.white10,
            selectedIndex: selected.index,
            onDestinationSelected: (index) {
              setState(() => selected = LocalSection.values[index]);
            },
            destinations: [
              for (final section in LocalSection.values)
                NavigationDestination(
                  icon: Icon(section.icon),
                  selectedIcon: Icon(section.icon, color: Colors.white),
                  label: section.label,
                ),
            ],
          ),
        );
      },
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

class _LocalStatusCard extends StatelessWidget {
  const _LocalStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Backend-free', style: TextStyle(fontWeight: FontWeight.w900)),
          SizedBox(height: 8),
          Text(
            'Firebase, Supabase ve PowerSync kapalı. Bu ekran sadece sağlam local geliştirme yoludur.',
            style: TextStyle(color: _textSoft, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class LocalPost {
  const LocalPost({
    required this.author,
    required this.handle,
    required this.time,
    required this.caption,
    required this.accent,
    required this.likes,
    required this.comments,
  });

  final String author;
  final String handle;
  final String time;
  final String caption;
  final List<Color> accent;
  final String likes;
  final String comments;
}

const _posts = [
  LocalPost(
    author: 'Mira Studio',
    handle: '@mira.studio',
    time: '18m',
    caption:
        'Offline-first sosyal akış hazır. Önce sağlam çalışan gövde, sonra gerçek kimlik ve wallet katmanı.',
    accent: [Color(0xFFE879F9), Color(0xFFEC4899), Color(0xFFF97316)],
    likes: '12.8K',
    comments: '384',
  ),
  LocalPost(
    author: 'Web4 Lab',
    handle: '@web4.lab',
    time: '2h',
    caption:
        'Feed, reels, chat ve profil alanları local veriyle açılıyor. Backend bağlanınca aynı gövde büyüyecek.',
    accent: [Color(0xFF60A5FA), Color(0xFF06B6D4), Color(0xFF14B8A6)],
    likes: '8.1K',
    comments: '211',
  ),
  LocalPost(
    author: 'Creator Node',
    handle: '@creator.node',
    time: '1d',
    caption:
        'Bu aşama tasarım finali değil. Sadece bozuk sistem üstüne kurmamak için güvenli çalışma tabanı.',
    accent: [Color(0xFFA78BFA), Color(0xFF6366F1), Color(0xFF0EA5E9)],
    likes: '4.6K',
    comments: '97',
  ),
];

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
            const SliverToBoxAdapter(child: StoriesStrip()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverList.separated(
              itemCount: _posts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                return LocalPostCard(post: _posts[index]);
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
    final names = ['You', 'Mira', 'Web4', 'Node', 'Live', 'Market', 'Truth'];
    final colors = [
      Colors.pinkAccent,
      Colors.orangeAccent,
      Colors.cyanAccent,
      Colors.purpleAccent,
      Colors.lightGreenAccent,
      Colors.amberAccent,
      Colors.blueAccent,
    ];

    return SizedBox(
      height: 112,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: names.length,
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
                    colors: [colors[index], Colors.pinkAccent],
                  ),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: _bg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    index == 0 ? Icons.add_rounded : Icons.person_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(names[index], style: const TextStyle(fontSize: 12)),
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
          ListTile(
            leading: CircleAvatar(
              backgroundColor: post.accent.first,
              child: Text(post.author.characters.first),
            ),
            title: Text(
              post.author,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text('${post.handle} · ${post.time}'),
            trailing: const Icon(Icons.more_horiz_rounded),
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
        padding: const EdgeInsets.all(16),
        itemCount: 24,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 210,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final colors = _posts[index % _posts.length].accent;
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(colors: colors),
            ),
            child: Center(
              child: Icon(
                index.isEven
                    ? Icons.photo_camera_outlined
                    : Icons.play_circle_outline,
                size: 42,
                color: Colors.white,
              ),
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
          final post = _posts[index % _posts.length];
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
    final chats = [
      ('Mira Studio', 'Local preview hazır mı?', '2m'),
      ('Web4 Lab', 'Backend sonra bağlanacak.', '21m'),
      ('Creator Node', 'Profil ekranı demo veride.', '1h'),
      ('Market Intel', 'Wallet alanı sonra gelecek.', '4h'),
      ('Truth Scanner', 'Proof katmanı planlandı.', '1d'),
    ];

    return _PageFrame(
      title: 'Chats',
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: chats.length,
        separatorBuilder: (_, __) => const Divider(color: _line),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _posts[index % _posts.length].accent.first,
              child: Text(chat.$1.characters.first),
            ),
            title: Text(
              chat.$1,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(chat.$2),
            trailing: Text(chat.$3, style: const TextStyle(color: _textSoft)),
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
                  padding: const EdgeInsets.all(22),
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
                              'Sosyal uygulama local çalışma profili. Gerçek CID ve wallet sonra bağlanacak.',
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
                      colors: _posts[index % _posts.length].accent,
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
      padding: const EdgeInsets.all(22),
      children: const [
        Text(
          'Today',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 14),
        _InfoTile(
          icon: Icons.check_circle_outline_rounded,
          title: 'Local route active',
          subtitle: 'main_local.dart backend olmadan çalışır.',
        ),
        _InfoTile(
          icon: Icons.storage_rounded,
          title: 'Backend later',
          subtitle: 'Supabase / PowerSync sonra bağlanacak.',
        ),
        _InfoTile(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Wallet placeholder',
          subtitle: 'Cüzdan alanı sonraki aşamada eklenecek.',
        ),
        SizedBox(height: 20),
        _LocalStatusCard(),
      ],
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
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
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
