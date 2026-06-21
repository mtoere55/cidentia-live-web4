import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../local_social_data.dart';

const _panel = Color(0xFF101114);
const _line = Color(0xFF262A33);

class OriginalInspiredReelsPage extends StatefulWidget {
  const OriginalInspiredReelsPage({super.key});

  @override
  State<OriginalInspiredReelsPage> createState() =>
      _OriginalInspiredReelsPageState();
}

class _OriginalInspiredReelsPageState extends State<OriginalInspiredReelsPage> {
  static const int _reelCount = 6;

  final ScrollController _controller = ScrollController();
  int _index = 0;

  void _go(int direction) {
    if (!_controller.hasClients) return;

    final next = (_index + direction).clamp(0, _reelCount - 1).toInt();
    if (next == _index) return;

    final viewport = _controller.position.viewportDimension;
    final target = next * viewport;

    _controller.animateTo(
      target.clamp(
        _controller.position.minScrollExtent,
        _controller.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  bool _onScrollNotification(ScrollNotification notification) {
    final metrics = notification.metrics;
    if (metrics.axis != Axis.vertical) return false;
    if (metrics.viewportDimension <= 0) return false;

    final next = (metrics.pixels / metrics.viewportDimension)
        .round()
        .clamp(0, _reelCount - 1)
        .toInt();

    if (next != _index) {
      setState(() => _index = next);
    }

    return false;
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.pageDown ||
        key == LogicalKeyboardKey.space) {
      _go(1);
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.pageUp) {
      _go(-1);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: _onKeyEvent,
      child: Stack(
        children: [
          ScrollConfiguration(
            behavior: const _ReelsScrollBehavior(),
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScrollNotification,
              child: CustomScrollView(
                controller: _controller,
                physics: const ClampingScrollPhysics(),
                slivers: [
                  SliverFillViewport(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final post = localPosts[index % localPosts.length];
                      return _ReelSlide(post: post, index: index);
                    }, childCount: _reelCount),
                  ),
                ],
              ),
            ),
          ),
          Positioned(right: 18, top: 24, child: _ReelCounter(index: _index)),
          Positioned(
            right: 18,
            top: 92,
            child: Column(
              children: [
                _RoundControl(
                  icon: Icons.keyboard_arrow_up_rounded,
                  onTap: () => _go(-1),
                ),
                const SizedBox(height: 10),
                _RoundControl(
                  icon: Icons.keyboard_arrow_down_rounded,
                  onTap: () => _go(1),
                ),
              ],
            ),
          ),
          const Positioned(left: 22, top: 24, child: _ReelsTitle()),
          const Positioned(
            right: 22,
            top: 24,
            child: _ReelsServerBoundaryBadge(),
          ),
          if (MediaQuery.sizeOf(context).width >= 1280)
            const Positioned(
              left: 22,
              top: 86,
              bottom: 28,
              child: _ReelsLiveDiscoverySidebar(),
            ),
        ],
      ),
    );
  }
}

class _ReelsServerBoundaryBadge extends StatelessWidget {
  const _ReelsServerBoundaryBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.44),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Server reels locked',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'GET /api/reels - 503 guarded',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ReelsLiveDiscoverySidebar extends StatelessWidget {
  const _ReelsLiveDiscoverySidebar();

  @override
  Widget build(BuildContext context) {
    const sections = [
      (
        'Following Live',
        [
          ('Mira Studio', 'Normal Live', '1.2K', Icons.sensors_rounded),
          ('Web4 Proof', 'Proof Room', '860', Icons.verified_user_outlined),
        ],
      ),
      (
        'VS / Battle',
        [('CID Battle', 'VS active', '3.7K', Icons.compare_arrows_rounded)],
      ),
      (
        'Multi Guest',
        [('Community Room', 'Guest grid', '2.4K', Icons.grid_view_rounded)],
      ),
      (
        'Proof Rooms',
        [('Truth Room', 'CID signal', '640', Icons.shield_outlined)],
      ),
    ];

    return SizedBox(
      width: 292,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final section = sections[index];

          return _ReelsLiveDiscoverySection(
            title: section.$1,
            rooms: section.$2,
          );
        },
      ),
    );
  }
}

class _ReelsLiveDiscoverySection extends StatelessWidget {
  const _ReelsLiveDiscoverySection({required this.title, required this.rooms});

  final String title;
  final List<(String, String, String, IconData)> rooms;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 9),
            for (final room in rooms)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ReelsLiveDiscoveryProfile(
                  name: room.$1,
                  mode: room.$2,
                  viewers: room.$3,
                  icon: room.$4,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReelsLiveDiscoveryProfile extends StatelessWidget {
  const _ReelsLiveDiscoveryProfile({
    required this.name,
    required this.mode,
    required this.viewers,
    required this.icon,
  });

  final String name;
  final String mode;
  final String viewers;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: const Color(0xFF27272A),
              child: Icon(icon, color: Colors.white, size: 17),
            ),
            const Positioned(
              left: 1,
              right: 1,
              bottom: -7,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFFF1744),
                  borderRadius: BorderRadius.all(Radius.circular(99)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    'LIVE',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 2),
              Text(
                mode,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF86EFAC),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.remove_red_eye_outlined,
          size: 13,
          color: Colors.white60,
        ),
        const SizedBox(width: 3),
        Text(
          viewers,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ReelsScrollBehavior extends MaterialScrollBehavior {
  const _ReelsScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
  };
}

class _ReelsTitle extends StatefulWidget {
  const _ReelsTitle();

  @override
  State<_ReelsTitle> createState() => _ReelsTitleState();
}

class _ReelsTitleState extends State<_ReelsTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _liveOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);

    _liveOpacity = Tween<double>(
      begin: 0.35,
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(
          children: [
            const Icon(Icons.smart_display_outlined, size: 18),
            const SizedBox(width: 8),
            const Text('Reels', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(width: 12),
            FadeTransition(
              opacity: _liveOpacity,
              child: const Text(
                'Live',
                style: TextStyle(
                  color: Color(0xFFFDA4AF),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReelCounter extends StatelessWidget {
  const _ReelCounter({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        child: Text(
          '${index + 1} / 6',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _ReelSlide extends StatefulWidget {
  const _ReelSlide({required this.post, required this.index});

  final LocalPost post;
  final int index;

  @override
  State<_ReelSlide> createState() => _ReelSlideState();
}

class _ReelSlideState extends State<_ReelSlide> {
  bool isLiked = false;
  bool isSaved = false;

  void _toggleLike() {
    setState(() => isLiked = !isLiked);
  }

  void _toggleSave() {
    setState(() => isSaved = !isSaved);
    _showReelSnack(
      context,
      isSaved ? 'Reel saved to local preview' : 'Reel removed from preview',
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final isLivePreview = widget.index % 3 == 0;
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        margin: const EdgeInsets.fromLTRB(4, 8, 4, 10),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _line),
          boxShadow: const [
            BoxShadow(
              blurRadius: 40,
              offset: Offset(0, 20),
              color: Color(0x66000000),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: post.accent,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned.fill(child: CustomPaint(painter: _ReelPatternPainter())),
            const Center(
              child: CircleAvatar(
                radius: 42,
                backgroundColor: Colors.black38,
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 64,
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 78,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.author,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    post.caption,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(height: 1.35),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '#cidentia #web4 #reels #proof',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 12,
              bottom: 20,
              child: Column(
                children: [
                  if (isLivePreview) ...[
                    _LiveCreatorBubble(
                      post: post,
                      onTap: () => _showLiveWatchPreviewSheet(context, post),
                    ),
                    const SizedBox(height: 18),
                  ],
                  _ReelAction(
                    icon: isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    label: isLiked ? 'Liked' : post.likes,
                    active: isLiked,
                    onTap: _toggleLike,
                  ),
                  _ReelAction(
                    icon: Icons.mode_comment_rounded,
                    label: post.comments,
                    onTap: () => _showReelCommentsSheet(context, post),
                  ),
                  _ReelAction(
                    icon: Icons.send_rounded,
                    label: 'Share',
                    onTap: () => _showReelShareSheet(context, post),
                  ),
                  _ReelAction(
                    icon: isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    label: isSaved ? 'Saved' : 'Save',
                    active: isSaved,
                    onTap: _toggleSave,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveCreatorBubble extends StatefulWidget {
  const _LiveCreatorBubble({required this.post, required this.onTap});

  final LocalPost post;
  final VoidCallback onTap;

  @override
  State<_LiveCreatorBubble> createState() => _LiveCreatorBubbleState();
}

class _LiveCreatorBubbleState extends State<_LiveCreatorBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    )..repeat(reverse: true);

    _pulse = Tween<double>(
      begin: 0.55,
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
    final initial = widget.post.author.isEmpty
        ? '?'
        : widget.post.author.characters.first;

    return GestureDetector(
      onTap: widget.onTap,
      child: FadeTransition(
        opacity: _pulse,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: widget.post.accent),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 14,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF111216),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -9,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF1744),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: Colors.white, width: 1.3),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const Positioned(
              bottom: -8,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Color(0xFFFF2D55),
                child: Icon(Icons.add_rounded, size: 17, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReelAction extends StatelessWidget {
  const _ReelAction({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = active ? const Color(0xFF86EFAC) : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(top: 13),
      child: InkWell(
        borderRadius: BorderRadius.circular(99),
        onTap: onTap,
        child: Column(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: active
                  ? const Color(0x3322C55E)
                  : Colors.black38,
              child: Icon(icon, color: activeColor),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: activeColor,
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

void _showReelSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1200),
      ),
    );
}

void _showReelCommentsSheet(BuildContext context, LocalPost post) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return _ReelPreviewSheet(
        title: 'Reel comments',
        subtitle: '${post.comments} comments - local preview',
        children: [
          _ReelCommentRow(name: post.author, text: 'Pinned creator reel note.'),
          const _ReelCommentRow(
            name: 'Mira',
            text: 'This short format works well for Web4 creators.',
          ),
          const _ReelCommentRow(
            name: 'Can',
            text: 'CID proof plus reels can become a strong trust signal.',
          ),
          const SizedBox(height: 12),
          const _ReelComposerPreview(),
        ],
      );
    },
  );
}

void _showReelShareSheet(BuildContext context, LocalPost post) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (context) {
      return _ReelPreviewSheet(
        title: 'Share reel',
        subtitle: 'Local share paths for ${post.author}',
        children: [
          _ReelSheetAction(
            icon: Icons.link_rounded,
            title: 'Copy reel link',
            subtitle: 'Preview only. No backend link is created.',
            onTap: () {
              Navigator.of(context).pop();
              _showReelSnack(context, 'Reel link copied preview');
            },
          ),
          _ReelSheetAction(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Send to Cidentia chat',
            subtitle: 'Future CID chat share route placeholder.',
            onTap: () {
              Navigator.of(context).pop();
              _showReelSnack(context, 'Reel chat share preview');
            },
          ),
          _ReelSheetAction(
            icon: Icons.auto_stories_outlined,
            title: 'Share to story / replay',
            subtitle: 'Future story and replay share surface.',
            onTap: () {
              Navigator.of(context).pop();
              _showReelSnack(context, 'Reel story share preview');
            },
          ),
          _ReelSheetAction(
            icon: Icons.verified_user_outlined,
            title: 'CID proof share',
            subtitle: 'Proof-backed reel sharing is planned later.',
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}

void _showLiveWatchPreviewSheet(BuildContext context, LocalPost post) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return _ReelPreviewSheet(
        title: 'Cidentia Live Room',
        subtitle: '${post.author} · CID-safe local watch surface',
        children: [
          Container(
            height: 320,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: post.accent,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _line),
            ),
            child: Stack(
              children: [
                const Positioned(
                  left: 16,
                  top: 16,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFFFF1744),
                      borderRadius: BorderRadius.all(Radius.circular(99)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Text(
                        'LIVE',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.black38,
                    child: Text(
                      post.author.characters.first,
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
                    'Live stream watch surface. RTMP, backend and real camera stream stay locked.',
                    style: TextStyle(color: Colors.white70, height: 1.35),
                  ),
                ),
              ],
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
                      'CID-safe viewers · 1.2K',
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
                  'Mira: Welcome to the Cidentia Live Room.',
                  style: TextStyle(color: Colors.white70, height: 1.3),
                ),
                SizedBox(height: 6),
                Text(
                  'Viewer: Proof reaction sent · effect preview earned.',
                  style: TextStyle(color: Colors.white60, height: 1.3),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _LiveRoomMiniPill(label: 'Signal'),
                    _LiveRoomMiniPill(label: 'Support'),
                    _LiveRoomMiniPill(label: 'Proof'),
                    _LiveRoomMiniPill(label: 'Effect'),
                  ],
                ),
                SizedBox(height: 12),
                _ReelActiveRoomMode(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ReelSheetAction(
            icon: Icons.remove_red_eye_outlined,
            title: 'Enter Live Room',
            subtitle: 'Watch the local room surface. No real stream is opened.',
            onTap: () {
              Navigator.of(context).pop();
              _showReelSnack(context, 'Live watch preview only');
            },
          ),
          _ReelSheetAction(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'CID Signal Chat',
            subtitle: 'Preview the future verified chat lane.',
            onTap: () {
              Navigator.of(context).pop();
              _showReelSnack(context, 'Live chat preview only');
            },
          ),
          _ReelSheetAction(
            icon: Icons.notifications_active_outlined,
            title: 'Follow Signal',
            subtitle: 'Future live notification and trust signal path.',
            onTap: () {
              Navigator.of(context).pop();
              _showReelSnack(context, 'Live notify preview only');
            },
          ),
          _ReelSheetAction(
            icon: Icons.auto_awesome_rounded,
            title: 'Effect earned preview',
            subtitle:
                'Future effects can become achievement or NFT-ready assets.',
            onTap: () {
              Navigator.of(context).pop();
              _showReelSnack(context, 'Effect reward preview only');
            },
          ),
          _ReelSheetAction(
            icon: Icons.verified_user_outlined,
            title: 'Proof support',
            subtitle:
                'Future creator support will use CID proof and economy rules.',
            onTap: () {
              Navigator.of(context).pop();
              _showReelSnack(context, 'Proof support preview only');
            },
          ),
        ],
      );
    },
  );
}

class _LiveRoomMiniPill extends StatelessWidget {
  const _LiveRoomMiniPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x3314B8A6),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0x5522C55E)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ReelActiveRoomMode extends StatelessWidget {
  const _ReelActiveRoomMode();

  @override
  Widget build(BuildContext context) {
    return const _ReelLiveModeInfo(
      icon: Icons.sensors_rounded,
      title: 'Active room mode: Normal Live',
      subtitle:
          'Mira selected this mode from Live Studio. Viewers join the active room and react inside it.',
    );
  }
}

class _ReelLiveModeInfo extends StatelessWidget {
  const _ReelLiveModeInfo({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0x2214B8A6),
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border.fromBorderSide(BorderSide(color: Color(0x4422C55E))),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w900)),
                SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReelPreviewSheet extends StatelessWidget {
  const _ReelPreviewSheet({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.82;

    return Container(
      margin: const EdgeInsets.all(14),
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x77000000),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                Text(subtitle, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReelSheetAction extends StatelessWidget {
  const _ReelSheetAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _line),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFA78BFA)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReelCommentRow extends StatelessWidget {
  const _ReelCommentRow({required this.name, required this.text});

  final String name;
  final String text;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name.characters.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: const Color(0xFF27272A),
            child: Text(
              initial,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _line),
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.white, height: 1.3),
                  children: [
                    TextSpan(
                      text: '$name ',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    TextSpan(text: text),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReelComposerPreview extends StatelessWidget {
  const _ReelComposerPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: Color(0xFF27272A),
            child: Text(
              'Y',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Reel comment composer preview...',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          Icon(Icons.send_rounded, color: Colors.white30),
        ],
      ),
    );
  }
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _ReelPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (var i = 0; i < 12; i++) {
      final x = i * size.width / 11;
      canvas.drawLine(
        Offset(x, 0),
        Offset(size.width - x / 2, size.height),
        line,
      );
    }

    final circle = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(
      Offset(size.width * 0.22, size.height * 0.72),
      size.width * 0.28,
      circle,
    );
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.22),
      size.width * 0.22,
      circle,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
