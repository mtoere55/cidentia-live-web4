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
        ],
      ),
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

class _ReelsTitle extends StatelessWidget {
  const _ReelsTitle();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white12),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(
          children: [
            Icon(Icons.smart_display_outlined, size: 18),
            SizedBox(width: 8),
            Text('Reels', style: TextStyle(fontWeight: FontWeight.w900)),
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
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(34),
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
              left: 18,
              right: 86,
              bottom: 26,
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
              right: 18,
              bottom: 26,
              child: Column(
                children: [
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
            const Positioned(
              left: 18,
              top: 18,
              child: _ReelBadge(label: 'Mouse wheel ready'),
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

class _ReelBadge extends StatelessWidget {
  const _ReelBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
        ),
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
