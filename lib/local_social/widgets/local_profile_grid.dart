import 'package:flutter/material.dart';

import '../local_social_data.dart';

const _panel = Color(0xFF101114);
const _panelSoft = Color(0xFF181A20);
const _line = Color(0xFF262A33);
const _textSoft = Color(0xFFA1A1AA);

enum _ProfileTabKind { posts, reels, tagged }

class OriginalInspiredProfilePage extends StatefulWidget {
  const OriginalInspiredProfilePage({super.key});

  @override
  State<OriginalInspiredProfilePage> createState() =>
      _OriginalInspiredProfilePageState();
}

class _OriginalInspiredProfilePageState
    extends State<OriginalInspiredProfilePage> {
  _ProfileTabKind activeTab = _ProfileTabKind.posts;

  void _setTab(_ProfileTabKind tab) {
    setState(() => activeTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 90),
      children: [
        const _ProfileHero(),
        const SizedBox(height: 8),
        const _ProfileStatsRow(),
        const SizedBox(height: 10),
        const _ProfileActionRow(),
        const SizedBox(height: 10),
        const _CreatorEconomyPreviewCard(),
        const SizedBox(height: 10),
        _ProfileTabs(activeTab: activeTab, onChanged: _setTab),
        const SizedBox(height: 10),
        _ProfileGrid(activeTab: activeTab),
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 62,
            height: 62,
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
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
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
                SizedBox(height: 8),
                Text(
                  'Local creator profile. Reels, wallet, proof and trust layers will connect later.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, height: 1.25),
                ),
                SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 360;

                    if (!compact) {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
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
                      );
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: const Row(
                        children: [
                          _ProfileBadge(
                            icon: Icons.badge_outlined,
                            label: 'CID ready',
                          ),
                          SizedBox(width: 8),
                          _ProfileBadge(
                            icon: Icons.fingerprint_rounded,
                            label: 'Proof planned',
                          ),
                          SizedBox(width: 8),
                          _ProfileBadge(
                            icon: Icons.wallet_outlined,
                            label: 'Wallet locked',
                          ),
                        ],
                      ),
                    );
                  },
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
        SizedBox(width: 6),
        Expanded(
          child: _StatCard(value: '24.8K', label: 'Followers'),
        ),
        SizedBox(width: 6),
        Expanded(
          child: _StatCard(value: '386', label: 'Following'),
        ),
        SizedBox(width: 6),
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _textSoft,
              fontSize: 10,
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
    return Row(
      children: [
        Expanded(
          child: _ProfileActionButton(
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            primary: true,
            onTap: () => _openProfileActionSheet(
              context,
              title: 'Edit Profile',
              subtitle: 'Local profile editor preview',
              icon: Icons.edit_outlined,
              text:
                  'Profile editing will require a verified CID session later. This preview keeps the creator surface visible without opening backend or identity flows.',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ProfileActionButton(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Wallet',
            onTap: () => _openProfileActionSheet(
              context,
              title: 'Wallet',
              subtitle: 'Wallet locked preview',
              icon: Icons.account_balance_wallet_outlined,
              text:
                  'Wallet stays locked in this local social package. No payment, token, balance, or wallet connector is opened here.',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ProfileActionButton(
            icon: Icons.verified_user_outlined,
            label: 'Proof',
            onTap: () => _openProfileActionSheet(
              context,
              title: 'Proof',
              subtitle: 'CID proof preview',
              icon: Icons.verified_user_outlined,
              text:
                  'Proof and trust badges are visual only until the CidenDB/CID boundary is resumed in a separate planned track.',
            ),
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
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: primary ? Colors.white : _panelSoft,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: primary ? Colors.white : _line),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: primary ? Colors.black : Colors.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: primary ? Colors.black : Colors.white,
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

class _CreatorEconomyPreviewCard extends StatelessWidget {
  const _CreatorEconomyPreviewCard();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.ssid_chart_rounded, 'Signal', '94%', 'Live trust pulse'),
      (Icons.volunteer_activism_outlined, 'Support', 'Locked', 'No payment'),
      (Icons.verified_user_outlined, 'Proof', 'Ready', 'CID later'),
      (Icons.auto_awesome_rounded, 'Effect', 'Earned', 'NFT-ready'),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.hub_outlined, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Creator Economy Preview',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              _ProfilePill(label: 'VISUAL ONLY'),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Activity-based Web4 layer preview. Wallet, token, payment, minting and blockchain stay locked.',
            style: TextStyle(color: _textSoft, height: 1.35, fontSize: 12),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final metricWidth = constraints.maxWidth >= 760
                  ? (constraints.maxWidth - 24) / 4
                  : constraints.maxWidth >= 520
                  ? (constraints.maxWidth - 8) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in items)
                    _CreatorEconomyMetric(
                      width: metricWidth,
                      icon: item.$1,
                      label: item.$2,
                      value: item.$3,
                      note: item.$4,
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          const _CreatorAssetStrip(),
        ],
      ),
    );
  }
}

class _CreatorEconomyMetric extends StatelessWidget {
  const _CreatorEconomyMetric({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.note,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            note,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _textSoft, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _CreatorAssetStrip extends StatelessWidget {
  const _CreatorAssetStrip();

  @override
  Widget build(BuildContext context) {
    const assets = [
      (Icons.local_fire_department_outlined, 'Live streak'),
      (Icons.workspace_premium_outlined, 'Creator proof'),
      (Icons.auto_awesome_outlined, 'Earned effect'),
      (Icons.groups_2_outlined, 'Community support'),
      (Icons.emoji_events_outlined, 'Contest badge'),
      (Icons.token_outlined, 'NFT-ready asset'),
    ];

    return SizedBox(
      height: 84,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemCount: assets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final asset = assets[index];

          return Container(
            width: 128,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(asset.$1, size: 18),
                const Spacer(),
                Text(
                  asset.$2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    height: 1.15,
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

class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs({required this.activeTab, required this.onChanged});

  final _ProfileTabKind activeTab;
  final ValueChanged<_ProfileTabKind> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: _ProfileTab(
              icon: Icons.grid_on_rounded,
              label: 'Posts',
              active: activeTab == _ProfileTabKind.posts,
              onTap: () => onChanged(_ProfileTabKind.posts),
            ),
          ),
          Expanded(
            child: _ProfileTab(
              icon: Icons.play_circle_outline,
              label: 'Reels',
              active: activeTab == _ProfileTabKind.reels,
              onTap: () => onChanged(_ProfileTabKind.reels),
            ),
          ),
          Expanded(
            child: _ProfileTab(
              icon: Icons.sell_outlined,
              label: 'Tagged',
              active: activeTab == _ProfileTabKind.tagged,
              onTap: () => onChanged(_ProfileTabKind.tagged),
            ),
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
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}

class _ProfileGrid extends StatelessWidget {
  const _ProfileGrid({required this.activeTab});

  final _ProfileTabKind activeTab;

  @override
  Widget build(BuildContext context) {
    final itemCount = activeTab == _ProfileTabKind.tagged ? 6 : 12;

    return GridView.builder(
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final post = localPosts[index % localPosts.length];
        return _GridTile(post: post, index: index, activeTab: activeTab);
      },
    );
  }
}

class _GridTile extends StatelessWidget {
  const _GridTile({
    required this.post,
    required this.index,
    required this.activeTab,
  });

  final LocalPost post;
  final int index;
  final _ProfileTabKind activeTab;

  @override
  Widget build(BuildContext context) {
    final isReel = activeTab == _ProfileTabKind.reels || index % 4 == 1;
    final isTagged = activeTab == _ProfileTabKind.tagged;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => _openGridPreview(context, post, index, activeTab),
      child: Container(
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
                isTagged
                    ? Icons.sell_outlined
                    : isReel
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
                  Icon(
                    isTagged
                        ? Icons.alternate_email_rounded
                        : Icons.favorite_rounded,
                    size: 15,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      isTagged ? 'Tagged' : post.likes,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
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

void _openProfileActionSheet(
  BuildContext context, {
  required String title,
  required String subtitle,
  required IconData icon,
  required String text,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) {
      return _ProfilePreviewSheet(
        title: title,
        subtitle: subtitle,
        icon: icon,
        children: [
          _ProfileInfoCard(icon: icon, title: title, text: text),
          const SizedBox(height: 10),
          const _ProfileInfoCard(
            icon: Icons.lock_outline_rounded,
            title: 'Protected action boundary',
            text:
                'This is a local-only profile preview. Protected actions must later require a verified CidenDB/CID session.',
          ),
        ],
      );
    },
  );
}

void _openGridPreview(
  BuildContext context,
  LocalPost post,
  int index,
  _ProfileTabKind tab,
) {
  final title = switch (tab) {
    _ProfileTabKind.posts => 'Profile post',
    _ProfileTabKind.reels => 'Profile reel',
    _ProfileTabKind.tagged => 'Tagged preview',
  };

  final icon = switch (tab) {
    _ProfileTabKind.posts => Icons.collections_rounded,
    _ProfileTabKind.reels => Icons.play_circle_fill_rounded,
    _ProfileTabKind.tagged => Icons.sell_outlined,
  };

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) {
      return _ProfilePreviewSheet(
        title: '$title #${index + 1}',
        subtitle: 'Local profile grid preview',
        icon: icon,
        children: [
          _ProfileGridPreviewFrame(post: post, icon: icon, tab: tab),
          const SizedBox(height: 12),
          _ProfileInfoCard(
            icon: Icons.info_outline_rounded,
            title: 'Local grid item',
            text:
                'This preview shows the profile grid opening behavior only. Real post detail, reel playback, tagged routing, and backend data will be added later.',
          ),
        ],
      );
    },
  );
}

class _ProfilePreviewSheet extends StatelessWidget {
  const _ProfilePreviewSheet({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.84;

    return Container(
      margin: const EdgeInsets.all(14),
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(30),
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
                    Icon(icon, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: const TextStyle(color: _textSoft),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
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

class _ProfileGridPreviewFrame extends StatelessWidget {
  const _ProfileGridPreviewFrame({
    required this.post,
    required this.icon,
    required this.tab,
  });

  final LocalPost post;
  final IconData icon;
  final _ProfileTabKind tab;

  @override
  Widget build(BuildContext context) {
    final label = switch (tab) {
      _ProfileTabKind.posts => 'POST',
      _ProfileTabKind.reels => 'REEL',
      _ProfileTabKind.tagged => 'TAGGED',
    };

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
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
            Center(
              child: CircleAvatar(
                radius: 42,
                backgroundColor: Colors.black38,
                child: Icon(icon, color: Colors.white, size: 48),
              ),
            ),
            Positioned(left: 16, top: 16, child: _ProfilePill(label: label)),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Text(
                post.caption,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(color: _textSoft, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePill extends StatelessWidget {
  const _ProfilePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black38,
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
