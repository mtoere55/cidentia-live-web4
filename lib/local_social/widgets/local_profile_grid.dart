import 'package:flutter/material.dart';

import '../local_social_data.dart';

const _bg = Color(0xFF09090B);
const _panel = Color(0xFF101114);
const _panelSoft = Color(0xFF181A20);
const _line = Color(0xFF262A33);
const _textSoft = Color(0xFFA1A1AA);

class OriginalInspiredProfilePage extends StatelessWidget {
  const OriginalInspiredProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 90),
      children: const [
        _ProfileHero(),
        SizedBox(height: 18),
        _ProfileStatsRow(),
        SizedBox(height: 18),
        _ProfileActionRow(),
        SizedBox(height: 22),
        _ProfileTabs(),
        SizedBox(height: 14),
        _ProfileGrid(),
      ],
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _line),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFE879F9), Color(0xFFF97316)],
              ),
              border: Border.all(color: Colors.white30, width: 3),
            ),
            child: const Center(
              child: Text(
                'W4',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'web4.creator',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.7,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.verified_rounded, color: Color(0xFF60A5FA)),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'CID Local - Social identity preview',
                  style: TextStyle(
                    color: _textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Offline-first creator profile. Posts, reels, wallet, proof and trust layers will be connected step by step.',
                  style: TextStyle(color: Colors.white, height: 1.35),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ProfileBadge(
                      icon: Icons.badge_outlined,
                      label: 'CID ready',
                    ),
                    _ProfileBadge(
                      icon: Icons.fingerprint_rounded,
                      label: 'Proof planned',
                    ),
                    _ProfileBadge(
                      icon: Icons.wallet_outlined,
                      label: 'Wallet locked',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
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

class _ProfileStatsRow extends StatelessWidget {
  const _ProfileStatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _StatCard(value: '128', label: 'Posts'),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _StatCard(value: '24.8K', label: 'Followers'),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _StatCard(value: '386', label: 'Following'),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _StatCard(value: '98.4', label: 'Trust'),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: _textSoft,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileActionRow extends StatelessWidget {
  const _ProfileActionRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _ProfileActionButton(
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            primary: true,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _ProfileActionButton(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Wallet',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _ProfileActionButton(
            icon: Icons.verified_user_outlined,
            label: 'Proof',
          ),
        ),
      ],
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({
    required this.icon,
    required this.label,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: primary ? Colors.white : _panelSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary ? Colors.white : _line),
      ),
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: primary ? Colors.black : Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: primary ? Colors.black : Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      padding: const EdgeInsets.all(6),
      child: const Row(
        children: [
          Expanded(
            child: _ProfileTab(
              icon: Icons.grid_on_rounded,
              label: 'Posts',
              active: true,
            ),
          ),
          Expanded(
            child: _ProfileTab(icon: Icons.play_circle_outline, label: 'Reels'),
          ),
          Expanded(
            child: _ProfileTab(icon: Icons.sell_outlined, label: 'Tagged'),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: active ? Colors.white10 : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: active ? Colors.white : _textSoft),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : _textSoft,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileGrid extends StatelessWidget {
  const _ProfileGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final post = localPosts[index % localPosts.length];
        return _GridTile(post: post, index: index);
      },
    );
  }
}

class _GridTile extends StatelessWidget {
  const _GridTile({required this.post, required this.index});

  final LocalPost post;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isReel = index % 4 == 1;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: post.accent,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPatternPainter())),
          Positioned(
            left: 10,
            top: 10,
            child: Icon(
              isReel
                  ? Icons.play_circle_fill_rounded
                  : Icons.collections_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                '#${index + 1}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Row(
              children: [
                const Icon(Icons.favorite_rounded, size: 15),
                const SizedBox(width: 4),
                Text(
                  post.likes,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
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

class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.11)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < 7; i++) {
      final x = i * size.width / 6;
      canvas.drawLine(
        Offset(x, 0),
        Offset(size.width - x / 3, size.height),
        paint,
      );
    }

    final dot = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.3), 18, dot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
