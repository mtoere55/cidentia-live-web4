import 'package:flutter/material.dart';

import '../auth/cidentia_auth_gate_contract.dart';
import '../auth/cidentia_protected_action_notice.dart';
import '../auth/cidentia_session_scope.dart';
import '../local_social_data.dart';

const _panel = Color(0xFF101114);
const _panelSoft = Color(0xFF181A20);
const _line = Color(0xFF262A33);
const _textSoft = Color(0xFFA1A1AA);

String _profileDisplayName({
  required bool verified,
  String? rawDisplayName,
  String? email,
  String? cid,
}) {
  final value = rawDisplayName?.trim();

  if (verified) {
    if (value != null && value.isNotEmpty && !value.contains('@')) {
      return value;
    }

    if (email != null && email.trim().isNotEmpty) {
      return 'CidenDB profile incomplete';
    }

    if (cid != null && cid.trim().isNotEmpty) {
      return 'CID ${cid.trim()}';
    }

    return 'Verified CidenDB User';
  }

  return 'Cidentia Creator';
}

String _profileInitials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();

  if (parts.isEmpty) {
    return 'LC';
  }

  if (parts.length == 1) {
    final part = parts.first;
    if (part.length == 1) {
      return part.toUpperCase();
    }
    return part.substring(0, 2).toUpperCase();
  }

  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}

String _profileHandle(String value) {
  var normalized = value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '.')
      .replaceAll(RegExp(r'^\.+'), '')
      .replaceAll(RegExp(r'\.+$'), '');

  if (normalized.isEmpty) {
    normalized = 'local.creator';
  }

  return '@$normalized.cid';
}

enum _ProfileTabKind { posts, reels, live, proof }

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
        const _CreatorRoleStrip(),
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

class _ProfileIdentityAvatar extends StatelessWidget {
  const _ProfileIdentityAvatar({
    required this.initials,
    required this.verified,
  });

  final String initials;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
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
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: verified ? const Color(0xFF60A5FA) : _panelSoft,
              shape: BoxShape.circle,
              border: Border.all(color: _panel, width: 2),
            ),
            child: Icon(
              verified ? Icons.verified_rounded : Icons.photo_camera_outlined,
              size: 13,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileIdentityReadinessRow extends StatelessWidget {
  const _ProfileIdentityReadinessRow({
    required this.identityStatus,
    required this.mediaStatus,
  });

  final String identityStatus;
  final String mediaStatus;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _ProfileMiniStatus(icon: Icons.badge_outlined, label: identityStatus),
        _ProfileMiniStatus(
          icon: Icons.photo_library_outlined,
          label: mediaStatus,
        ),
      ],
    );
  }
}

class _ProfileMiniStatus extends StatelessWidget {
  const _ProfileMiniStatus({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _textSoft),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: _textSoft,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero();

  @override
  Widget build(BuildContext context) {
    final session = CidentiaSessionScope.maybeOf(context);
    final verified = session?.hasVerifiedCid ?? false;
    final cid = session?.cid;
    final email = session?.email;
    final profileName = _profileDisplayName(
      verified: verified,
      rawDisplayName: session?.displayName,
      email: email,
      cid: cid,
    );

    final profileHandle = verified
        ? _profileHandle(profileName)
        : '@cidentia.creator';

    final avatarLabel = _profileInitials(profileName);

    final identityLine = verified && cid != null
        ? 'Verified CID: $cid'
        : 'CID-ready creator identity';

    final profileDescription = verified && email != null
        ? 'Signed in as $email. Creator identity, avatar and cover workspace are ready.'
        : 'Build your Cidentia creator profile with live rooms, proof signals and media tools.';

    final identityStatus = verified
        ? 'CidenDB verified identity'
        : 'CID sign-in available';

    final mediaStatus = verified
        ? 'Avatar / cover preview ready'
        : 'Avatar / cover ready';

    final cidBadgeLabel = verified && cid != null ? 'CID $cid' : 'CID entry';
    final proofBadgeLabel = verified ? 'Proof verified' : 'Proof path';

    return Container(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileIdentityAvatar(initials: avatarLabel, verified: verified),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        profileName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.7,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (verified)
                      const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF60A5FA),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  profileHandle,
                  style: const TextStyle(
                    color: _textSoft,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  identityLine,
                  style: const TextStyle(
                    color: _textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  profileDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, height: 1.25),
                ),
                const SizedBox(height: 8),
                _ProfileIdentityReadinessRow(
                  identityStatus: identityStatus,
                  mediaStatus: mediaStatus,
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 360;

                    if (!compact) {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ProfileBadge(
                            icon: Icons.badge_outlined,
                            label: cidBadgeLabel,
                          ),
                          _ProfileBadge(
                            icon: Icons.fingerprint_rounded,
                            label: proofBadgeLabel,
                          ),
                          const _ProfileBadge(
                            icon: Icons.wallet_outlined,
                            label: 'Wallet gateway',
                          ),
                        ],
                      );
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _ProfileBadge(
                            icon: Icons.badge_outlined,
                            label: cidBadgeLabel,
                          ),
                          const SizedBox(width: 8),
                          _ProfileBadge(
                            icon: Icons.fingerprint_rounded,
                            label: proofBadgeLabel,
                          ),
                          const SizedBox(width: 8),
                          const _ProfileBadge(
                            icon: Icons.wallet_outlined,
                            label: 'Wallet gateway',
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
    final session = CidentiaSessionScope.maybeOf(context);
    final verified = session?.hasVerifiedCid ?? false;
    final cid = session?.cid ?? 'CID pending';
    final email = session?.email ?? 'verified CidenDB user';
    final profileName = _profileDisplayName(
      verified: verified,
      rawDisplayName: session?.displayName,
      email: session?.email,
      cid: session?.cid,
    );

    final compact = MediaQuery.sizeOf(context).width < 420;

    return Row(
      children: [
        Expanded(
          child: _ProfileActionButton(
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            primary: true,
            onTap: () {
              if (!verified) {
                CidentiaProtectedActionNotice.show(
                  context,
                  action: CidentiaProtectedAction.editProfile,
                );
                return;
              }

              _openProfileActionSheet(
                context,
                title: 'Edit Profile',
                subtitle: 'Creator identity workspace',
                icon: Icons.edit_outlined,
                text:
                    '$profileName is connected to $cid. Signed in as $email. Profile editing will save after the creator profile service is connected.',
              );
            },
          ),
        ),
        SizedBox(width: compact ? 6 : 12),
        Expanded(
          child: _ProfileActionButton(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Wallet',
            onTap: () {
              if (!verified) {
                CidentiaProtectedActionNotice.show(
                  context,
                  action: CidentiaProtectedAction.connectWallet,
                );
                return;
              }

              _openProfileActionSheet(
                context,
                title: 'Wallet',
                subtitle: 'CidenBridge wallet gateway',
                icon: Icons.account_balance_wallet_outlined,
                text:
                    'CID session is verified. Wallet access opens through CidenBridge when the wallet gateway is connected.',
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ProfileActionButton(
            icon: Icons.verified_user_outlined,
            label: 'Proof',
            onTap: () {
              if (!verified) {
                CidentiaProtectedActionNotice.show(
                  context,
                  action: CidentiaProtectedAction.manageProof,
                );
                return;
              }

              _openProfileActionSheet(
                context,
                title: 'Proof',
                subtitle: 'CidenDB proof gateway',
                icon: Icons.verified_user_outlined,
                text:
                    'CID proof status is visible. Proof documents and audit routes open through the protected proof gateway.',
              );
            },
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
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.sizeOf(context).width < 420 ? 8 : 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: primary ? Colors.black : Colors.white),
            const SizedBox(width: 5),
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

class _CreatorRoleStrip extends StatelessWidget {
  const _CreatorRoleStrip();

  @override
  Widget build(BuildContext context) {
    const roles = [
      (Icons.live_tv_rounded, 'Live creator', 'Rooms and replay'),
      (Icons.verified_user_outlined, 'Proof creator', 'CID signal'),
      (Icons.storefront_outlined, 'Market ready', 'Creator commerce'),
      (Icons.auto_awesome_rounded, 'Effect layer', 'Earned assets'),
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
          const Text(
            'Creator identity',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 560;
              final itemWidth = compact
                  ? (constraints.maxWidth - 8) / 2
                  : 150.0;

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final role in roles)
                    SizedBox(
                      width: itemWidth,
                      child: _CreatorRoleCard(
                        icon: role.$1,
                        title: role.$2,
                        subtitle: role.$3,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CreatorRoleCard extends StatelessWidget {
  const _CreatorRoleCard({
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _textSoft, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
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
                  'Creator Economy',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              _ProfilePill(label: 'CREATOR'),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Activity-based Web4 layer for signal, support, proof and earned creator assets.',
            style: TextStyle(color: _textSoft, height: 1.35, fontSize: 12),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final metricWidth = constraints.maxWidth >= 760
                  ? (constraints.maxWidth - 24) / 4
                  : (constraints.maxWidth - 8) / 2;

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
          if (MediaQuery.sizeOf(context).width >= 520) ...[
            const SizedBox(height: 12),
            const _CreatorAssetStrip(),
          ],
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
              icon: Icons.live_tv_rounded,
              label: 'Live',
              active: activeTab == _ProfileTabKind.live,
              onTap: () => onChanged(_ProfileTabKind.live),
            ),
          ),
          Expanded(
            child: _ProfileTab(
              icon: Icons.verified_user_outlined,
              label: 'Proof',
              active: activeTab == _ProfileTabKind.proof,
              onTap: () => onChanged(_ProfileTabKind.proof),
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

class _ProfileServerBoundaryNotice extends StatelessWidget {
  const _ProfileServerBoundaryNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: const Row(
        children: [
          Icon(Icons.storage_outlined, size: 18, color: _textSoft),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Profile posts/reels still use local preview data. Future profile media reads from GET /api/profile/posts after CID session validation.',
              style: TextStyle(color: _textSoft, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileGrid extends StatelessWidget {
  const _ProfileGrid({required this.activeTab});

  final _ProfileTabKind activeTab;

  @override
  Widget build(BuildContext context) {
    final itemCount = switch (activeTab) {
      _ProfileTabKind.posts => 12,
      _ProfileTabKind.reels => 12,
      _ProfileTabKind.live => 6,
      _ProfileTabKind.proof => 6,
    };

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
    final isTagged = activeTab == _ProfileTabKind.proof;
    final isLive = activeTab == _ProfileTabKind.live;

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
                    ? Icons.verified_user_outlined
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
                      isTagged ? 'Proof' : post.likes,
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
          if (title == 'Edit Profile') ...[
            const _ProfileEditPreviewForm(),
            const SizedBox(height: 10),
          ],
          if (title == 'Wallet') ...[
            const _ProfileGatewayStatusCard(
              title: 'Wallet gateway',
              subtitle: 'CID ready for wallet routing.',
              icon: Icons.account_balance_wallet_outlined,
              accent: Color(0xFFF97316),
              items: [
                _ProfileGatewayItem(
                  icon: Icons.verified_user_outlined,
                  label: 'CID session',
                  description: 'Ready for future wallet routing.',
                ),
                _ProfileGatewayItem(
                  icon: Icons.lock_outline_rounded,
                  label: 'Balance hidden',
                  description:
                      'No token, payment or balance is displayed here.',
                ),
                _ProfileGatewayItem(
                  icon: Icons.hub_outlined,
                  label: 'CidenBridge required',
                  description: 'Wallet must pass through CidenBridge.',
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          if (title == 'Proof') ...[
            const _ProfileGatewayStatusCard(
              title: 'Proof gateway',
              subtitle: 'CID proof route is prepared.',
              icon: Icons.verified_user_outlined,
              accent: Color(0xFF60A5FA),
              items: [
                _ProfileGatewayItem(
                  icon: Icons.badge_outlined,
                  label: 'CID verified',
                  description: 'Verified CidenDB identity is visible.',
                ),
                _ProfileGatewayItem(
                  icon: Icons.fingerprint_rounded,
                  label: 'Proof module',
                  description:
                      'Document and audit routes open after proof service connection.',
                ),
                _ProfileGatewayItem(
                  icon: Icons.token_outlined,
                  label: 'Minting closed',
                  description:
                      'NFT, token and payment actions stay outside this profile view.',
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          _ProfileInfoCard(icon: icon, title: title, text: text),
          const SizedBox(height: 10),
          const _ProfileInfoCard(
            icon: Icons.lock_outline_rounded,
            title: 'Protected creator action',
            text:
                'Creator profile changes, wallet access and proof management require a verified CidenDB/CID session.',
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
    _ProfileTabKind.live => 'Live room',
    _ProfileTabKind.proof => 'Proof item',
  };

  final icon = switch (tab) {
    _ProfileTabKind.posts => Icons.collections_rounded,
    _ProfileTabKind.reels => Icons.play_circle_fill_rounded,
    _ProfileTabKind.live => Icons.live_tv_rounded,
    _ProfileTabKind.proof => Icons.verified_user_outlined,
  };

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) {
      return _ProfilePreviewSheet(
        title: '$title #${index + 1}',
        subtitle: 'Creator profile item',
        icon: icon,
        children: [
          _ProfileGridPreviewFrame(post: post, icon: icon, tab: tab),
          const SizedBox(height: 12),
          _ProfileInfoCard(
            icon: Icons.info_outline_rounded,
            title: 'Creator profile item',
            text:
                'This item opens the creator content surface. Publishing, playback and proof actions remain protected by the creator release flow.',
          ),
        ],
      );
    },
  );
}

class _ProfileGatewayStatusCard extends StatelessWidget {
  const _ProfileGatewayStatusCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.items,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final List<_ProfileGatewayItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accent.withValues(alpha: 0.45)),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(color: _textSoft, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.icon, size: 19, color: accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.description,
                          style: const TextStyle(color: _textSoft, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileGatewayItem {
  const _ProfileGatewayItem({
    required this.icon,
    required this.label,
    required this.description,
  });

  final IconData icon;
  final String label;
  final String description;
}

class _ProfileEditPreviewForm extends StatefulWidget {
  const _ProfileEditPreviewForm();

  @override
  State<_ProfileEditPreviewForm> createState() =>
      _ProfileEditPreviewFormState();
}

class _ProfileEditPreviewFormState extends State<_ProfileEditPreviewForm> {
  late final TextEditingController nameController;
  late final TextEditingController handleController;
  late final TextEditingController bioController;
  late final TextEditingController initialsController;

  String initials = 'LC';
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) {
      return;
    }

    final session = CidentiaSessionScope.maybeOf(context);
    final verified = session?.hasVerifiedCid ?? false;
    final profileName = _profileDisplayName(
      verified: verified,
      rawDisplayName: session?.displayName,
      email: session?.email,
      cid: session?.cid,
    );
    final handle = _profileHandle(profileName).replaceFirst('@', '');
    final avatarInitials = _profileInitials(profileName);

    nameController = TextEditingController(text: profileName);
    handleController = TextEditingController(text: handle);
    bioController = TextEditingController(
      text:
          'Cidentia.Live creator profile connected to verified CidenDB/CID session.',
    );
    initialsController = TextEditingController(text: avatarInitials);
    initials = avatarInitials;
    initialsController.addListener(_refreshAvatarPreview);
    _initialized = true;
  }

  @override
  void dispose() {
    initialsController.removeListener(_refreshAvatarPreview);
    nameController.dispose();
    handleController.dispose();
    bioController.dispose();
    initialsController.dispose();
    super.dispose();
  }

  void _refreshAvatarPreview() {
    if (!mounted) return;
    setState(() {});
  }

  void _showPhotoPreviewNotice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Profile photo picker is preview-only. Upload and storage are still locked.',
        ),
      ),
    );
  }

  void _saveLocalDraft() {
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Local profile draft saved. Production backend save is still locked.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Local profile editor',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'These fields are local preview controls only. Real profile save will connect to the production backend later.',
            style: TextStyle(color: _textSoft, height: 1.35),
          ),
          const SizedBox(height: 14),
          _ProfileAvatarPreviewCard(
            initials: initialsController.text,
            onChangePhoto: _showPhotoPreviewNotice,
          ),
          const SizedBox(height: 14),
          _ProfileDraftField(
            controller: nameController,
            label: 'Display name',
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 10),
          _ProfileDraftField(
            controller: handleController,
            label: 'Handle',
            icon: Icons.alternate_email_rounded,
          ),
          const SizedBox(height: 10),
          _ProfileDraftField(
            controller: initialsController,
            label: 'Avatar initials',
            icon: Icons.account_circle_outlined,
          ),
          const SizedBox(height: 10),
          _ProfileDraftField(
            controller: bioController,
            label: 'Bio',
            icon: Icons.notes_rounded,
            maxLines: 3,
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _saveLocalDraft,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save local draft'),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatarPreviewCard extends StatelessWidget {
  const _ProfileAvatarPreviewCard({
    required this.initials,
    required this.onChangePhoto,
  });

  final String initials;
  final VoidCallback onChangePhoto;

  String get safeInitials {
    final value = initials.trim().toUpperCase();
    if (value.isEmpty) return 'LC';
    if (value.length == 1) return value;
    return value.substring(0, 2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFE879F9), Color(0xFFF97316)],
              ),
              border: Border.all(color: Colors.white30, width: 3),
            ),
            child: Center(
              child: Text(
                safeInitials,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile image preview',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Local avatar preview only. Real photo upload and storage will connect later.',
                  style: TextStyle(color: _textSoft, height: 1.35),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: onChangePhoto,
                  icon: const Icon(Icons.photo_camera_outlined, size: 18),
                  label: const Text('Change photo preview'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDraftField extends StatelessWidget {
  const _ProfileDraftField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF60A5FA)),
        ),
      ),
    );
  }
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
      _ProfileTabKind.live => 'LIVE',
      _ProfileTabKind.proof => 'PROOF',
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
