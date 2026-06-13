import 'package:flutter/material.dart';

import '../local_social_data.dart';

const _cardBg = Color(0xFF101114);
const _cardSoft = Color(0xFF181A20);
const _line = Color(0xFF262A33);
const _textSoft = Color(0xFFA1A1AA);

class OriginalInspiredPostCard extends StatelessWidget {
  const OriginalInspiredPostCard({required this.post, super.key});

  final LocalPost post;

  @override
  Widget build(BuildContext context) {
    final firstLetter = post.author.isEmpty
        ? '?'
        : post.author.characters.first;

    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(
            blurRadius: 36,
            offset: Offset(0, 18),
            color: Color(0x55000000),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostHeader(post: post, firstLetter: firstLetter),
          _PostMedia(post: post),
          _PostActions(post: post),
          _PostCaption(post: post),
        ],
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  const _PostHeader({required this.post, required this.firstLetter});

  final LocalPost post;
  final String firstLetter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 12),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: post.accent),
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: Center(
              child: Text(
                firstLetter,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.author,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${post.handle} - ${post.time}',
                  style: const TextStyle(color: _textSoft, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text(
              'Follow',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.more_horiz_rounded, color: Colors.white70),
        ],
      ),
    );
  }
}

class _PostMedia extends StatelessWidget {
  const _PostMedia({required this.post});

  final LocalPost post;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.05,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: post.accent,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _MediaPatternPainter()),
            ),
            const Positioned(
              left: 18,
              top: 18,
              child: _OverlayBadge(
                icon: Icons.verified_rounded,
                label: 'CID proof',
              ),
            ),
            const Positioned(
              right: 18,
              top: 18,
              child: _OverlayBadge(
                icon: Icons.offline_bolt_rounded,
                label: 'Local media',
              ),
            ),
            Center(
              child: Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 62,
                  color: Colors.white,
                ),
              ),
            ),
            const Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Text(
                'Original-inspired social media block',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostActions extends StatelessWidget {
  const _PostActions({required this.post});

  final LocalPost post;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      _ActionButton(icon: Icons.favorite_border_rounded, label: post.likes),
      _ActionButton(icon: Icons.mode_comment_outlined, label: post.comments),
      const _ActionButton(icon: Icons.send_outlined, label: 'Share'),
      const _ActionButton(icon: Icons.bookmark_border_rounded, label: 'Save'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 360) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              children: actions,
            );
          }

          return Row(
            children: [
              actions[0],
              const SizedBox(width: 8),
              actions[1],
              const SizedBox(width: 8),
              actions[2],
              const Spacer(),
              actions[3],
            ],
          );
        },
      ),
    );
  }
}

class _PostCaption extends StatelessWidget {
  const _PostCaption({required this.post});

  final LocalPost post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${post.likes} likes',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white, height: 1.35),
              children: [
                TextSpan(
                  text: '${post.author} ',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                TextSpan(text: post.caption),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '#web4 #offlinefirst #cid #proof #social',
            style: TextStyle(color: _textSoft, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: _cardSoft,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _OverlayBadge extends StatelessWidget {
  const _OverlayBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (var i = 0; i < 9; i++) {
      final offset = i * size.width / 8;
      canvas.drawLine(
        Offset(offset, 0),
        Offset(size.width - offset / 2, size.height),
        paint,
      );
    }

    final circlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.26),
      size.width * 0.18,
      circlePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.72),
      size.width * 0.26,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
