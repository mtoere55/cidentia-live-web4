import 'package:flutter/material.dart';

const _bg = Color(0xFF09090B);
const _panel = Color(0xFF101114);
const _panelSoft = Color(0xFF181A20);
const _line = Color(0xFF262A33);
const _textSoft = Color(0xFFA1A1AA);

class OriginalInspiredLiveStudioPage extends StatefulWidget {
  const OriginalInspiredLiveStudioPage({super.key});

  @override
  State<OriginalInspiredLiveStudioPage> createState() =>
      _OriginalInspiredLiveStudioPageState();
}

class _OriginalInspiredLiveStudioPageState
    extends State<OriginalInspiredLiveStudioPage> {
  bool destinationsExpanded = true;
  bool translateEnabled = true;
  bool liveReady = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 820;

        if (compact) {
          return _MobileLiveStudio(
            destinationsExpanded: destinationsExpanded,
            translateEnabled: translateEnabled,
            liveReady: liveReady,
            onToggleDestinations: () =>
                setState(() => destinationsExpanded = !destinationsExpanded),
            onToggleTranslate: () =>
                setState(() => translateEnabled = !translateEnabled),
            onToggleLive: () => setState(() => liveReady = !liveReady),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 90),
          children: [
            _StudioTopBar(
              translateEnabled: translateEnabled,
              liveReady: liveReady,
              onToggleTranslate: () =>
                  setState(() => translateEnabled = !translateEnabled),
            ),
            const SizedBox(height: 16),
            _DesktopStudioPreview(
              translateEnabled: translateEnabled,
              liveReady: liveReady,
              onToggleLive: () => setState(() => liveReady = !liveReady),
            ),
            const SizedBox(height: 14),
            const _SceneStrip(),
            const SizedBox(height: 14),
            _StudioControlDock(
              liveReady: liveReady,
              translateEnabled: translateEnabled,
              onToggleLive: () => setState(() => liveReady = !liveReady),
              onToggleTranslate: () =>
                  setState(() => translateEnabled = !translateEnabled),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _DestinationsPanel(expanded: true, onToggle: () {}),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _TranslatePanel(translateEnabled: translateEnabled),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StudioTopBar extends StatelessWidget {
  const _StudioTopBar({
    required this.translateEnabled,
    required this.liveReady,
    required this.onToggleTranslate,
  });

  final bool translateEnabled;
  final bool liveReady;
  final VoidCallback onToggleTranslate;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const _MetricCard(title: 'Session', value: 'Morning Build #42'),
        const _MetricCard(title: 'Time', value: '00:24:18'),
        const _MetricCard(title: 'Viewers', value: '1.2K'),
        const _MetricCard(title: 'Bitrate', value: '6.2 Mbps'),
        const _MetricCard(title: 'FPS', value: '60'),
        _StatusCard(liveReady: liveReady),
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onToggleTranslate,
          child: _TranslateChip(enabled: translateEnabled),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: _textSoft, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.liveReady});

  final bool liveReady;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Icon(
            liveReady ? Icons.radio_button_checked : Icons.shield_outlined,
            color: liveReady
                ? const Color(0xFFEF4444)
                : const Color(0xFF22C55E),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            liveReady ? 'On Air' : 'Excellent',
            style: TextStyle(
              color: liveReady
                  ? const Color(0xFFFCA5A5)
                  : const Color(0xFF86EFAC),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopStudioPreview extends StatelessWidget {
  const _DesktopStudioPreview({
    required this.translateEnabled,
    required this.liveReady,
    required this.onToggleLive,
  });

  final bool translateEnabled;
  final bool liveReady;
  final VoidCallback onToggleLive;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _line),
          boxShadow: const [
            BoxShadow(
              blurRadius: 44,
              offset: Offset(0, 22),
              color: Color(0x66000000),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            const Positioned.fill(child: _StudioVideoStage()),
            Positioned(
              left: 18,
              top: 18,
              child: Row(
                children: [
                  _LiveBadge(liveReady: liveReady),
                  const SizedBox(width: 10),
                  const _GlassBadge(
                    icon: Icons.visibility_rounded,
                    label: '1.2K',
                  ),
                ],
              ),
            ),
            Positioned(
              right: 18,
              top: 18,
              child: _TranslateChip(enabled: translateEnabled),
            ),
            const Positioned(left: 18, bottom: 18, child: _HostOverlay()),
            const Positioned(right: 22, bottom: 22, child: _SubtitleOverlay()),
            Positioned(
              right: 18,
              top: 78,
              child: _SmallIconButton(
                icon: Icons.fullscreen_rounded,
                onTap: () {},
              ),
            ),
            Positioned(
              right: 18,
              bottom: 118,
              child: _GoLiveFloatingButton(
                liveReady: liveReady,
                onTap: onToggleLive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudioVideoStage extends StatelessWidget {
  const _StudioVideoStage();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.25, -0.12),
          radius: 1.15,
          colors: [Color(0xFF7C3AED), Color(0xFF111827), Color(0xFF030712)],
        ),
      ),
      child: CustomPaint(
        painter: _StudioPatternPainter(),
        child: Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFE879F9), Color(0xFFF97316)],
              ),
              border: Border.all(color: Colors.white24, width: 2),
              boxShadow: const [
                BoxShadow(blurRadius: 60, color: Color(0x66EC4899)),
              ],
            ),
            child: const Center(
              child: Text(
                'LIVE\nHOST',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StudioPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < 16; i++) {
      final x = i * size.width / 15;
      canvas.drawLine(
        Offset(x, 0),
        Offset(size.width - x / 2, size.height),
        line,
      );
    }

    final glow = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.25), 130, glow);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.75), 180, glow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.liveReady});

  final bool liveReady;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: liveReady ? const Color(0xFFEF4444) : Colors.black45,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: liveReady ? const Color(0xFFFCA5A5) : Colors.white12,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        child: Row(
          children: [
            Icon(
              liveReady ? Icons.circle : Icons.radio_button_unchecked,
              color: Colors.white,
              size: 10,
            ),
            const SizedBox(width: 7),
            Text(
              liveReady ? 'LIVE' : 'READY',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassBadge extends StatelessWidget {
  const _GlassBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 7),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _TranslateChip extends StatelessWidget {
  const _TranslateChip({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled ? const Color(0xFF22C55E) : Colors.white12,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate_rounded, size: 16),
            const SizedBox(width: 8),
            const Text('TR', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(width: 6),
            const Icon(Icons.swap_horiz_rounded, size: 15),
            const SizedBox(width: 6),
            const Text('EN', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(width: 6),
            const Icon(Icons.swap_horiz_rounded, size: 15),
            const SizedBox(width: 6),
            const Text('DE', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(width: 10),
            const Text('Hub', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 4,
              backgroundColor: enabled
                  ? const Color(0xFF22C55E)
                  : const Color(0xFF71717A),
            ),
          ],
        ),
      ),
    );
  }
}

class _HostOverlay extends StatelessWidget {
  const _HostOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 330,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFE879F9), Color(0xFFF97316)],
              ),
            ),
            child: const Center(
              child: Text(
                'W4',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'web4.creator',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 3),
                Text(
                  'CID Verified Host',
                  style: TextStyle(color: _textSoft, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified_rounded, color: Color(0xFF60A5FA)),
        ],
      ),
    );
  }
}

class _SubtitleOverlay extends StatelessWidget {
  const _SubtitleOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EN  Building in Web4 is about ownership, identity and real connections.',
            style: TextStyle(height: 1.35),
          ),
          SizedBox(height: 10),
          _WaveLine(),
        ],
      ),
    );
  }
}

class _WaveLine extends StatelessWidget {
  const _WaveLine();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        24,
        (index) => Expanded(
          child: Container(
            height: (index % 5 + 1) * 4,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: index.isEven
                  ? const Color(0xFFA855F7)
                  : const Color(0xFFEC4899),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
      ),
    );
  }
}

class _SceneStrip extends StatelessWidget {
  const _SceneStrip();

  @override
  Widget build(BuildContext context) {
    const scenes = [
      'Talking Head',
      'Camera',
      'Screen Share',
      'Slides',
      'Webcam + Slides',
      'Add Source',
    ];

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: scenes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final selected = index == 0;
          return Container(
            width: 154,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: selected ? Colors.white10 : _panel,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? const Color(0xFFA855F7) : _line,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  index == scenes.length - 1
                      ? Icons.add_rounded
                      : Icons.video_camera_front_rounded,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    scenes[index],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
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

class _StudioControlDock extends StatelessWidget {
  const _StudioControlDock({
    required this.liveReady,
    required this.translateEnabled,
    required this.onToggleLive,
    required this.onToggleTranslate,
  });

  final bool liveReady;
  final bool translateEnabled;
  final VoidCallback onToggleLive;
  final VoidCallback onToggleTranslate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _line),
      ),
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: [
          const _ControlButton(
            icon: Icons.mic_rounded,
            label: 'Mic',
            active: true,
          ),
          const _ControlButton(
            icon: Icons.videocam_rounded,
            label: 'Camera',
            active: true,
          ),
          const _ControlButton(
            icon: Icons.monitor_rounded,
            label: 'Share Screen',
          ),
          const _ControlButton(
            icon: Icons.person_add_alt_1_rounded,
            label: 'Invite Guest',
          ),
          const _ControlButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat',
          ),
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onToggleTranslate,
            child: _ControlButton(
              icon: Icons.translate_rounded,
              label: 'Translate',
              active: translateEnabled,
            ),
          ),
          const _ControlButton(
            icon: Icons.verified_user_outlined,
            label: 'Proof',
            active: true,
          ),
          const _ControlButton(
            icon: Icons.fiber_manual_record_rounded,
            label: 'Record',
          ),
          const _ControlButton(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Wallet Support',
          ),
          _LiveControlButton(liveReady: liveReady, onTap: onToggleLive),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
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
      width: 112,
      height: 70,
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: active ? const Color(0xFF22C55E) : _line),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _LiveControlButton extends StatelessWidget {
  const _LiveControlButton({required this.liveReady, required this.onTap});

  final bool liveReady;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 148,
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: liveReady
                ? const [Color(0xFFEF4444), Color(0xFFB91C1C)]
                : const [Color(0xFFEC4899), Color(0xFFF97316)],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            liveReady ? 'End Live' : 'Go Live',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}

class _DestinationsPanel extends StatelessWidget {
  const _DestinationsPanel({required this.expanded, required this.onToggle});

  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final destinations = _destinations;

    return Container(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _line),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onToggle,
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Destinations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                const Text(
                  '6 / 6 Connected',
                  style: TextStyle(
                    color: Color(0xFF4ADE80),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_up_rounded,
                ),
              ],
            ),
          ),
          if (expanded) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: destinations
                  .map((item) => _DestinationTile(item: item))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _Destination {
  const _Destination({
    required this.name,
    required this.handle,
    required this.icon,
    required this.colors,
  });

  final String name;
  final String handle;
  final IconData icon;
  final List<Color> colors;
}

const _destinations = [
  _Destination(
    name: 'YouTube',
    handle: '@CidentiaLive',
    icon: Icons.play_arrow_rounded,
    colors: [Color(0xFFFF0000), Color(0xFFB91C1C)],
  ),
  _Destination(
    name: 'Twitch',
    handle: '/cidentialive',
    icon: Icons.chat_bubble_rounded,
    colors: [Color(0xFF9146FF), Color(0xFF6D28D9)],
  ),
  _Destination(
    name: 'Instagram',
    handle: '@cidentia.live',
    icon: Icons.camera_alt_rounded,
    colors: [Color(0xFFEC4899), Color(0xFFF97316)],
  ),
  _Destination(
    name: 'Facebook',
    handle: 'Cidentia.Live',
    icon: Icons.facebook_rounded,
    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
  ),
  _Destination(
    name: 'TikTok',
    handle: '@cidentia.live',
    icon: Icons.music_note_rounded,
    colors: [Color(0xFF111827), Color(0xFFEC4899)],
  ),
  _Destination(
    name: 'Custom RTMP',
    handle: 'rtmp://custom',
    icon: Icons.public_rounded,
    colors: [Color(0xFF334155), Color(0xFF0F172A)],
  ),
];

class _DestinationTile extends StatelessWidget {
  const _DestinationTile({required this.item});

  final _Destination item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _openDestinationManager(context, item),
      child: Container(
        width: 156,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _line),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(colors: item.colors),
              ),
              child: Icon(item.icon),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.handle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _textSoft, fontSize: 11),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'MANAGE',
                    style: TextStyle(
                      color: Color(0xFF4ADE80),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
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

class _TranslatePanel extends StatelessWidget {
  const _TranslatePanel({required this.translateEnabled});

  final bool translateEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _line),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.translate_rounded),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Live Translation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              Switch(value: translateEnabled, onChanged: null),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'TR Original',
            style: TextStyle(color: _textSoft, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Web4 is about ownership, identity and real connections.',
            style: TextStyle(height: 1.35),
          ),
          const SizedBox(height: 14),
          const Text(
            'EN Translation',
            style: TextStyle(color: _textSoft, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Building in Web4 is about ownership, identity and real connections.',
            style: TextStyle(height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _MobileLiveStudio extends StatelessWidget {
  const _MobileLiveStudio({
    required this.destinationsExpanded,
    required this.translateEnabled,
    required this.liveReady,
    required this.onToggleDestinations,
    required this.onToggleTranslate,
    required this.onToggleLive,
  });

  final bool destinationsExpanded;
  final bool translateEnabled;
  final bool liveReady;
  final VoidCallback onToggleDestinations;
  final VoidCallback onToggleTranslate;
  final VoidCallback onToggleLive;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _MobileVideoPreview()),
        Positioned(
          left: 14,
          top: 14,
          child: Row(
            children: [
              _LiveBadge(liveReady: liveReady),
              const SizedBox(width: 8),
              const _GlassBadge(icon: Icons.visibility_rounded, label: '1.2K'),
            ],
          ),
        ),
        Positioned(
          right: 14,
          top: 14,
          child: _TranslateChip(enabled: translateEnabled),
        ),
        const Positioned(left: 14, top: 72, child: _MobileHostBadge()),
        Positioned(
          right: 14,
          top: 104,
          child: _MobileQuickRail(
            translateEnabled: translateEnabled,
            onToggleTranslate: onToggleTranslate,
            onToggleDestinations: onToggleDestinations,
          ),
        ),
        Positioned(
          left: 14,
          right: 14,
          bottom: 14,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MobileDestinationsSheet(
                expanded: destinationsExpanded,
                onToggle: onToggleDestinations,
              ),
              const SizedBox(height: 10),
              _MobileControlDock(
                liveReady: liveReady,
                destinationsExpanded: destinationsExpanded,
                onToggleLive: onToggleLive,
                onToggleDestinations: onToggleDestinations,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MobileControlDock extends StatelessWidget {
  const _MobileControlDock({
    required this.liveReady,
    required this.destinationsExpanded,
    required this.onToggleLive,
    required this.onToggleDestinations,
  });

  final bool liveReady;
  final bool destinationsExpanded;
  final VoidCallback onToggleLive;
  final VoidCallback onToggleDestinations;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 28,
            offset: Offset(0, 12),
            color: Color(0xAA000000),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          const Expanded(
            child: _MiniControl(icon: Icons.mic_rounded, label: 'Mute'),
          ),
          const Expanded(
            child: _MiniControl(icon: Icons.videocam_rounded, label: 'Camera'),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(99),
              onTap: onToggleLive,
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: liveReady
                        ? const [Color(0xFFEF4444), Color(0xFFB91C1C)]
                        : const [Color(0xFFEC4899), Color(0xFFF97316)],
                  ),
                  boxShadow: const [
                    BoxShadow(blurRadius: 24, color: Color(0x66EC4899)),
                  ],
                ),
                child: Icon(
                  liveReady ? Icons.stop_rounded : Icons.wifi_tethering_rounded,
                  size: 30,
                ),
              ),
            ),
          ),
          const Expanded(
            child: _MiniControl(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Chat',
            ),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onToggleDestinations,
              child: _MiniControl(
                icon: destinationsExpanded
                    ? Icons.keyboard_arrow_down_rounded
                    : Icons.more_horiz_rounded,
                label: destinationsExpanded ? 'Close' : 'More',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniControl extends StatelessWidget {
  const _MiniControl({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  const _SmallIconButton({required this.icon, required this.onTap});

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
        child: Icon(icon),
      ),
    );
  }
}

class _GoLiveFloatingButton extends StatelessWidget {
  const _GoLiveFloatingButton({required this.liveReady, required this.onTap});

  final bool liveReady;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: Container(
        width: 86,
        height: 86,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: liveReady
                ? const [Color(0xFFEF4444), Color(0xFFB91C1C)]
                : const [Color(0xFFEC4899), Color(0xFFF97316)],
          ),
          boxShadow: const [
            BoxShadow(blurRadius: 28, color: Color(0x66EC4899)),
          ],
        ),
        child: Center(
          child: Text(
            liveReady ? 'END\nLIVE' : 'GO\nLIVE',
            textAlign: TextAlign.center,
            style: const TextStyle(height: 1.0, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}

class _MobileVideoPreview extends StatelessWidget {
  const _MobileVideoPreview();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.2, -0.25),
          radius: 1.25,
          colors: [Color(0xFF7C3AED), Color(0xFF111827), Color(0xFF030712)],
        ),
      ),
      child: CustomPaint(
        painter: _StudioPatternPainter(),
        child: Stack(
          children: [
            Center(
              child: Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE879F9), Color(0xFFF97316)],
                  ),
                  border: Border.all(color: Colors.white24, width: 2),
                  boxShadow: const [
                    BoxShadow(blurRadius: 70, color: Color(0x66EC4899)),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'LIVE\nHOST',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      height: 1.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.1,
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 18,
              right: 18,
              bottom: 250,
              child: _MobileSubtitleBubble(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileHostBadge extends StatelessWidget {
  const _MobileHostBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 218,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFE879F9), Color(0xFFF97316)],
              ),
            ),
            child: const Center(
              child: Text('W4', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'web4.creator',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 2),
                Text(
                  'CID Verified Host',
                  style: TextStyle(color: _textSoft, fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.verified_rounded,
            color: Color(0xFF60A5FA),
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _MobileQuickRail extends StatelessWidget {
  const _MobileQuickRail({
    required this.translateEnabled,
    required this.onToggleTranslate,
    required this.onToggleDestinations,
  });

  final bool translateEnabled;
  final VoidCallback onToggleTranslate;
  final VoidCallback onToggleDestinations;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _MobileRailButton(icon: Icons.mic_rounded, active: true),
        const SizedBox(height: 10),
        const _MobileRailButton(icon: Icons.videocam_rounded, active: true),
        const SizedBox(height: 10),
        const _MobileRailButton(icon: Icons.flip_camera_ios_rounded),
        const SizedBox(height: 10),
        const _MobileRailButton(
          icon: Icons.chat_bubble_outline_rounded,
          badge: '12',
        ),
        const SizedBox(height: 10),
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onToggleTranslate,
          child: _MobileRailButton(
            icon: Icons.translate_rounded,
            active: translateEnabled,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onToggleDestinations,
          child: const _MobileRailButton(icon: Icons.tune_rounded),
        ),
      ],
    );
  }
}

class _MobileRailButton extends StatelessWidget {
  const _MobileRailButton({
    required this.icon,
    this.active = false,
    this.badge,
  });

  final IconData icon;
  final bool active;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: active ? const Color(0xFF22C55E) : Colors.white12,
            ),
          ),
          child: Icon(icon),
        ),
        if (badge != null)
          Positioned(
            right: -4,
            top: -5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MobileSubtitleBubble extends StatelessWidget {
  const _MobileSubtitleBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EN  Building in Web4 is about ownership and real connections.',
              style: TextStyle(fontSize: 12, height: 1.35),
            ),
            SizedBox(height: 8),
            _WaveLine(),
          ],
        ),
      ),
    );
  }
}

class _MobileDestinationsSheet extends StatelessWidget {
  const _MobileDestinationsSheet({
    required this.expanded,
    required this.onToggle,
  });

  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      height: expanded ? 320 : 72,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 32,
            offset: Offset(0, 16),
            color: Color(0xAA000000),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                children: [
                  Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Destinations',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const Text(
                        '6 / 6 Connected',
                        style: TextStyle(
                          color: Color(0xFF4ADE80),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        expanded
                            ? Icons.keyboard_arrow_down_rounded
                            : Icons.keyboard_arrow_up_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            SizedBox(
              height: 118,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                scrollDirection: Axis.horizontal,
                itemCount: _destinations.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final item = _destinations[index];
                  return _MobileDestinationChip(item: item);
                },
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: _MobileQuickToolsGrid(),
            ),
          ],
        ],
      ),
    );
  }
}

class _MobileDestinationChip extends StatelessWidget {
  const _MobileDestinationChip({required this.item});

  final _Destination item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _openDestinationManager(context, item),
      child: Container(
        width: 104,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(colors: item.colors),
              ),
              child: Icon(item.icon, size: 18),
            ),
            const Spacer(),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
            ),
            const SizedBox(height: 3),
            const Text(
              'MANAGE',
              style: TextStyle(
                color: Color(0xFF4ADE80),
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileQuickToolsGrid extends StatelessWidget {
  const _MobileQuickToolsGrid();

  @override
  Widget build(BuildContext context) {
    const tools = [
      (Icons.group_rounded, 'Guests', '1 / 4'),
      (Icons.verified_user_outlined, 'Proof', 'Active'),
      (Icons.fiber_manual_record_rounded, 'Record', 'Off'),
      (Icons.account_balance_wallet_outlined, 'Wallet', 'EUR 0.00'),
      (Icons.translate_rounded, 'Translate', 'TR <> EN'),
    ];

    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tools.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final tool = tools[index];

          return Container(
            width: 104,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _panelSoft,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(tool.$1, size: 20),
                const Spacer(),
                Text(
                  tool.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                Text(
                  tool.$3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _textSoft, fontSize: 11),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

void _openDestinationManager(BuildContext context, _Destination item) {
  showDialog<void>(
    context: context,
    builder: (context) => _DestinationManagerDialog(item: item),
  );
}

class _DestinationManagerDialog extends StatefulWidget {
  const _DestinationManagerDialog({required this.item});

  final _Destination item;

  @override
  State<_DestinationManagerDialog> createState() =>
      _DestinationManagerDialogState();
}

class _DestinationManagerDialogState extends State<_DestinationManagerDialog> {
  bool enabled = true;
  bool revealKey = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final rtmpValue = item.name == 'Custom RTMP'
        ? 'rtmp://custom.server/live'
        : 'rtmp://studio.cidentia.live/${item.name.toLowerCase()}';
    final streamKeyValue = revealKey
        ? 'demo-local-stream-key-locked'
        : '????????????????';

    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      backgroundColor: _panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: _line),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(colors: item.colors),
                    ),
                    child: Icon(item.icon),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.name} Destination',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.handle,
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
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _panelSoft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _line),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      value: enabled,
                      onChanged: (value) => setState(() => enabled = value),
                      title: const Text(
                        'Destination Enabled',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(
                        enabled ? 'Ready for local studio routing' : 'Disabled',
                        style: const TextStyle(color: _textSoft),
                      ),
                    ),
                    const Divider(color: _line),
                    _ManagerField(
                      icon: Icons.link_rounded,
                      label: 'RTMP URL',
                      value: rtmpValue,
                    ),
                    const SizedBox(height: 12),
                    _ManagerField(
                      icon: Icons.key_rounded,
                      label: 'Stream Key',
                      value: streamKeyValue,
                      trailing: IconButton(
                        onPressed: () => setState(() => revealKey = !revealKey),
                        icon: Icon(
                          revealKey
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _ManagerStatusRow(
                      label: 'Mode',
                      value: 'Local placeholder only',
                      color: Color(0xFFFBBF24),
                    ),
                    const SizedBox(height: 8),
                    _ManagerStatusRow(
                      label: 'Status',
                      value: enabled ? 'Ready' : 'Disabled',
                      color: enabled
                          ? const Color(0xFF4ADE80)
                          : const Color(0xFFA1A1AA),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const _DestinationSafetyNote(),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.settings_ethernet_rounded),
                      label: const Text('Test Connection'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Save Local'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManagerField extends StatelessWidget {
  const _ManagerField({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _textSoft,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _ManagerStatusRow extends StatelessWidget {
  const _ManagerStatusRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: _textSoft)),
        ),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.w900),
        ),
        const SizedBox(width: 8),
        CircleAvatar(radius: 4, backgroundColor: color),
      ],
    );
  }
}

class _DestinationSafetyNote extends StatelessWidget {
  const _DestinationSafetyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1B12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF854D0E)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_rounded, color: Color(0xFFFBBF24)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No real stream key is stored here. Real RTMP credentials will be encrypted later on the server side.',
              style: TextStyle(color: Color(0xFFFDE68A), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

void _openLiveTranslationHub(BuildContext context) {
  final compact = MediaQuery.sizeOf(context).width < 720;

  if (compact) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _LiveTranslationHubSheet(),
    );
    return;
  }

  showDialog<void>(
    context: context,
    builder: (context) => const _LiveTranslationHubDialog(),
  );
}

class _LiveTranslationHubDialog extends StatelessWidget {
  const _LiveTranslationHubDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      backgroundColor: _panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: _line),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(18),
          child: _LiveTranslationHubContent(),
        ),
      ),
    );
  }
}

class _LiveTranslationHubSheet extends StatelessWidget {
  const _LiveTranslationHubSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.78,
        ),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _line),
          boxShadow: const [
            BoxShadow(
              blurRadius: 34,
              offset: Offset(0, 16),
              color: Color(0xAA000000),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(18),
          child: _LiveTranslationHubContent(),
        ),
      ),
    );
  }
}

class _LiveTranslationHubContent extends StatefulWidget {
  const _LiveTranslationHubContent();

  @override
  State<_LiveTranslationHubContent> createState() =>
      _LiveTranslationHubContentState();
}

class _LiveTranslationHubContentState
    extends State<_LiveTranslationHubContent> {
  String speakerLanguage = 'Auto';
  String hearingLanguage = 'Turkish';
  String subtitleMode = 'Dual';
  bool subtitlesEnabled = true;
  bool voicePreviewEnabled = false;

  @override
  Widget build(BuildContext context) {
    final speakerOptions = ['Auto', 'Turkish', 'English', 'German'];
    final languageOptions = ['Turkish', 'English', 'German'];
    final subtitleOptions = ['Off', 'Single', 'Dual'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                ),
              ),
              child: const Icon(Icons.translate_rounded),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Translation Hub',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Compact TR / EN / DE studio translation control.',
                    style: TextStyle(color: _textSoft, height: 1.3),
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
        const SizedBox(height: 18),
        _HubSection(
          title: 'Speaker Language',
          child: _HubChoiceWrap(
            values: speakerOptions,
            selected: speakerLanguage,
            onSelected: (value) => setState(() => speakerLanguage = value),
          ),
        ),
        const SizedBox(height: 12),
        _HubSection(
          title: 'I want to hear',
          child: _HubChoiceWrap(
            values: languageOptions,
            selected: hearingLanguage,
            onSelected: (value) => setState(() => hearingLanguage = value),
          ),
        ),
        const SizedBox(height: 12),
        _HubSection(
          title: 'Subtitle Mode',
          child: _HubChoiceWrap(
            values: subtitleOptions,
            selected: subtitleMode,
            onSelected: (value) => setState(() => subtitleMode = value),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: _panelSoft,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _line),
          ),
          child: Column(
            children: [
              SwitchListTile(
                value: subtitlesEnabled,
                onChanged: (value) => setState(() => subtitlesEnabled = value),
                title: const Text(
                  'Subtitles',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text(
                  'Show translated captions over the live preview.',
                  style: TextStyle(color: _textSoft),
                ),
              ),
              const Divider(height: 1, color: _line),
              SwitchListTile(
                value: voicePreviewEnabled,
                onChanged: (value) =>
                    setState(() => voicePreviewEnabled = value),
                title: const Text(
                  'Voice Translation Preview',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text(
                  'Local UI placeholder. Real voice engine will be connected later.',
                  style: TextStyle(color: _textSoft),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _HubPreviewCard(),
        const SizedBox(height: 12),
        const _HubStatsRow(),
        const SizedBox(height: 14),
        const _HubSafetyNote(),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.hearing_rounded),
                label: const Text('Test Voice'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Save Local'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HubSection extends StatelessWidget {
  const _HubSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _HubChoiceWrap extends StatelessWidget {
  const _HubChoiceWrap({
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  final List<String> values;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values
          .map(
            (value) => ChoiceChip(
              label: Text(value),
              selected: selected == value,
              onSelected: (_) => onSelected(value),
              selectedColor: const Color(0xFF7C3AED),
              backgroundColor: Colors.black26,
              side: const BorderSide(color: _line),
              labelStyle: const TextStyle(fontWeight: FontWeight.w900),
            ),
          )
          .toList(),
    );
  }
}

class _HubPreviewCard extends StatelessWidget {
  const _HubPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Live Caption Preview',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 10),
          _CaptionLine(label: 'TR Original', text: 'Ben Turkce konusuyorum.'),
          SizedBox(height: 8),
          _CaptionLine(
            label: 'EN Translation',
            text: 'I am speaking in Turkish.',
          ),
          SizedBox(height: 8),
          _CaptionLine(label: 'DE Translation', text: 'Ich spreche Turkisch.'),
        ],
      ),
    );
  }
}

class _CaptionLine extends StatelessWidget {
  const _CaptionLine({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 118,
          child: Text(
            label,
            style: const TextStyle(
              color: _textSoft,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(child: Text(text, style: const TextStyle(height: 1.35))),
      ],
    );
  }
}

class _HubStatsRow extends StatelessWidget {
  const _HubStatsRow();

  @override
  Widget build(BuildContext context) {
    const stats = [
      ('Latency', '0.8s demo', Color(0xFF4ADE80)),
      ('Confidence', '94%', Color(0xFF60A5FA)),
      ('Mode', 'Local UI', Color(0xFFFBBF24)),
    ];

    return Row(
      children: stats
          .map(
            (stat) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _panelSoft,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _line),
                ),
                child: Column(
                  children: [
                    Text(
                      stat.$1,
                      style: const TextStyle(color: _textSoft, fontSize: 11),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      stat.$2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: stat.$3,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _HubSafetyNote extends StatelessWidget {
  const _HubSafetyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF93C5FD)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'This is a local product shell. Real speech-to-text, translation and voice output will be connected in a later engine step.',
              style: TextStyle(color: Color(0xFFBFDBFE), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
