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
  final PageController _controller = PageController();
  int _index = 0;
  bool _wheelLocked = false;

  void _go(int direction) {
    if (!_controller.hasClients) return;

    final next = (_index + direction).clamp(0, 5).toInt();
    if (next == _index) return;

    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (_wheelLocked) return;

    final dy = event.scrollDelta.dy;
    if (dy.abs() < 8) return;

    _wheelLocked = true;
    _go(dy > 0 ? 1 : -1);

    Future<void>.delayed(const Duration(milliseconds: 430), () {
      if (mounted) {
        _wheelLocked = false;
      }
    });
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
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerSignal: _onPointerSignal,
        child: Stack(
          children: [
            ScrollConfiguration(
              behavior: const _ReelsScrollBehavior(),
              child: PageView.builder(
                controller: _controller,
                scrollDirection: Axis.vertical,
                physics: const PageScrollPhysics(),
                itemCount: 6,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, index) {
                  final post = localPosts[index % localPosts.length];
                  return _ReelSlide(post: post, index: index);
                },
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

class _ReelSlide extends StatelessWidget {
  const _ReelSlide({required this.post, required this.index});

  final LocalPost post;
  final int index;

  @override
  Widget build(BuildContext context) {
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
                  _ReelAction(icon: Icons.favorite_rounded, label: post.likes),
                  _ReelAction(
                    icon: Icons.mode_comment_rounded,
                    label: post.comments,
                  ),
                  const _ReelAction(icon: Icons.send_rounded, label: 'Share'),
                  const _ReelAction(
                    icon: Icons.bookmark_rounded,
                    label: 'Save',
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
  const _ReelAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 13),
      child: Column(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: Colors.black38,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
          ),
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
