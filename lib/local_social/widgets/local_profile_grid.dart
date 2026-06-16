import 'package:flutter/material.dart';

import '../auth/cidentia_auth_gate_contract.dart';
import '../auth/cidentia_protected_action_notice.dart';
import '../auth/cidentia_session_scope.dart';
import '../local_social_data.dart';

const _panel = Color(0xFF101114);
const _panelSoft = Color(0xFF181A20);
const _line = Color(0xFF262A33);
const _textSoft = Color(0xFFA1A1AA);

String _profileInitials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();

  if (parts.isEmpty) {
    return 'MT';
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
    normalized = 'murat.toere';
  }

  return '@$normalized.cid';
}

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
    final session = CidentiaSessionScope.maybeOf(context);
    final verified = session?.hasVerifiedCid ?? false;
    final cid = session?.cid;
    final email = session?.email;
    final rawDisplayName = session?.displayName?.trim();
    final displayNameLooksLikeEmail =
        rawDisplayName != null && rawDisplayName.contains('@');

    final profileName =
        verified &&
            rawDisplayName != null &&
            rawDisplayName.isNotEmpty &&
            !displayNameLooksLikeEmail
        ? rawDisplayName
        : 'Murat Toere';

    final profileHandle = verified
        ? _profileHandle(profileName)
        : '@murat.toere.preview';

    final avatarLabel = _profileInitials(profileName);

    final identityLine = verified && cid != null
        ? 'Verified CID: $cid'
        : 'CID Local - Social identity preview';

    final profileDescription = verified && email != null
        ? 'Signed in as $email. Wallet, proof and creator economy modules stay locked until production backend is connected.'
        : 'Local creator profile. Reels, wallet, proof and trust layers will connect later.';

    final cidBadgeLabel = verified && cid != null ? 'CID $cid' : 'CID ready';
    final proofBadgeLabel = verified ? 'Proof verified' : 'Proof planned';

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
            child: Center(
              child: Text(
                avatarLabel,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
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
                            label: 'Wallet locked',
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
    final session = CidentiaSessionScope.maybeOf(context);
    final verified = session?.hasVerifiedCid ?? false;
    final cid = session?.cid ?? 'CID pending';
    final email = session?.email ?? 'verified CidenDB user';

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
                subtitle: 'Verified CID profile workspace',
                icon: Icons.edit_outlined,
                text:
                    'Murat Toere profile is connected to $cid. Signed in as $email. Local profile editing controls come next; production save remains locked until the backend profile route is connected.',
              );
            },
          ),
        ),
        const SizedBox(width: 12),
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
                    'Verified CID session is ready for wallet access. Real wallet, balance, token, payment and blockchain actions stay locked until the CidenBridge wallet module is connected.',
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
                    'Verified CID proof state is available for this local profile. Real proof documents, trust audit and CidenDB proof details will connect through the production backend.',
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
          if (title == 'Edit Profile') ...[
            const _ProfileEditPreviewForm(),
            const SizedBox(height: 10),
          ],
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

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: 'Murat Toere');
    handleController = TextEditingController(text: 'murat.toere.cid');
    bioController = TextEditingController(
      text:
          'Cidentia.Live creator profile connected to verified CidenDB/CID session.',
    );
    initialsController = TextEditingController(text: 'MT');
    initialsController.addListener(_refreshAvatarPreview);
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
    if (value.isEmpty) return 'MT';
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
