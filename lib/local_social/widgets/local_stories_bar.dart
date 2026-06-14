import 'package:flutter/material.dart';

import '../local_social_data.dart';

const _panel = Color(0xFF101114);
const _line = Color(0xFF262A33);
const _textSoft = Color(0xFFA1A1AA);

class OriginalInspiredStoriesBar extends StatelessWidget {
  const OriginalInspiredStoriesBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 156,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 24),
        itemCount: localStories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final story = localStories[index];
          return _StoryTile(story: story, index: index);
        },
      ),
    );
  }
}

class _StoryTile extends StatelessWidget {
  const _StoryTile({required this.story, required this.index});

  final LocalStory story;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isLive = index == 3 || story.label == 'Live';
    final isProof = story.label == 'Truth' || story.label == 'Web4';

    return SizedBox(
      width: 92,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () => _openStoryPreview(context, story, index),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        story.color,
                        const Color(0xFFEC4899),
                        const Color(0xFFF97316),
                      ],
                    ),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _panel,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            story.color.withValues(alpha: 0.85),
                            const Color(0xFF181A20),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Center(
                        child: story.isCreate
                            ? const Icon(Icons.add_rounded, size: 30)
                            : Text(
                                story.label.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                if (isLive)
                  const Positioned(
                    left: 13,
                    right: 13,
                    bottom: -5,
                    child: _MiniStoryBadge(label: 'LIVE'),
                  ),
                if (isProof)
                  const Positioned(right: -2, top: -2, child: _ProofDot()),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              story.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              story.isCreate ? 'Create' : _storyTypeLabel(story, index),
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
      ),
    );
  }
}

String _storyTypeLabel(LocalStory story, int index) {
  if (index == 3 || story.label == 'Live') return 'Live';
  if (story.label == 'Truth' || story.label == 'Web4') return 'Proof';
  if (story.label == 'Market') return 'Replay';
  return 'Story';
}

void _openStoryPreview(BuildContext context, LocalStory story, int index) {
  final isCreate = story.isCreate;
  final isLive = index == 3 || story.label == 'Live';
  final isProof = story.label == 'Truth' || story.label == 'Web4';
  final isReplay = story.label == 'Market';

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return _StoryPreviewSheet(
        story: story,
        title: isCreate ? 'Create story' : '${story.label} story',
        subtitle: isCreate
            ? 'Local creator story preview'
            : _storyPreviewSubtitle(
                isLive: isLive,
                isProof: isProof,
                isReplay: isReplay,
              ),
        isCreate: isCreate,
        isLive: isLive,
        isProof: isProof,
        isReplay: isReplay,
      );
    },
  );
}

String _storyPreviewSubtitle({
  required bool isLive,
  required bool isProof,
  required bool isReplay,
}) {
  if (isLive) return 'Live / replay surface preview';
  if (isProof) return 'CID proof story preview';
  if (isReplay) return 'Market replay story preview';
  return 'Local story viewer preview';
}

class _StoryPreviewSheet extends StatelessWidget {
  const _StoryPreviewSheet({
    required this.story,
    required this.title,
    required this.subtitle,
    required this.isCreate,
    required this.isLive,
    required this.isProof,
    required this.isReplay,
  });

  final LocalStory story;
  final String title;
  final String subtitle;
  final bool isCreate;
  final bool isLive;
  final bool isProof;
  final bool isReplay;

  @override
  Widget build(BuildContext context) {
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.86;

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
              children: [
                _StorySheetHeader(title: title, subtitle: subtitle),
                const SizedBox(height: 16),
                _StoryPreviewFrame(
                  story: story,
                  isCreate: isCreate,
                  isLive: isLive,
                  isProof: isProof,
                  isReplay: isReplay,
                ),
                const SizedBox(height: 16),
                if (isCreate)
                  const _StoryInfoCard(
                    icon: Icons.add_photo_alternate_outlined,
                    title: 'Create preview only',
                    text:
                        'Story creation will connect later. No media upload or backend is opened here.',
                  )
                else ...[
                  _StoryInfoCard(
                    icon: isLive
                        ? Icons.sensors_rounded
                        : isProof
                        ? Icons.verified_user_outlined
                        : Icons.auto_stories_outlined,
                    title: _storyInfoTitle(
                      isLive: isLive,
                      isProof: isProof,
                      isReplay: isReplay,
                    ),
                    text: _storyInfoText(
                      isLive: isLive,
                      isProof: isProof,
                      isReplay: isReplay,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const _StoryInfoCard(
                    icon: Icons.lock_outline_rounded,
                    title: 'Local-only viewer',
                    text:
                        'This story viewer is a safe local preview. It does not connect CidenDB, wallet, RTMP, payment, or live streaming.',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StorySheetHeader extends StatelessWidget {
  const _StorySheetHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.auto_stories_outlined, color: Colors.white),
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
              Text(subtitle, style: const TextStyle(color: _textSoft)),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }
}

class _StoryPreviewFrame extends StatelessWidget {
  const _StoryPreviewFrame({
    required this.story,
    required this.isCreate,
    required this.isLive,
    required this.isProof,
    required this.isReplay,
  });

  final LocalStory story;
  final bool isCreate;
  final bool isLive;
  final bool isProof;
  final bool isReplay;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 14,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 520),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: [
              story.color.withValues(alpha: 0.9),
              const Color(0xFF181A20),
              const Color(0xFF09090B),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _StoryPatternPainter()),
            ),
            Positioned(
              left: 18,
              right: 18,
              top: 18,
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: const LinearProgressIndicator(
                        value: 0.62,
                        minHeight: 4,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isCreate ? 'NEW' : '0:08',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            Center(
              child: CircleAvatar(
                radius: 54,
                backgroundColor: Colors.black38,
                child: Icon(
                  isCreate
                      ? Icons.add_rounded
                      : isLive
                      ? Icons.sensors_rounded
                      : isProof
                      ? Icons.verified_rounded
                      : Icons.play_arrow_rounded,
                  size: 58,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              left: 22,
              right: 22,
              bottom: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (isLive) const _StoryPill(label: 'LIVE'),
                      if (isProof) const _StoryPill(label: 'CID PROOF'),
                      if (isReplay) const _StoryPill(label: 'REPLAY'),
                      if (isCreate) const _StoryPill(label: 'CREATE'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isCreate ? 'Your next story' : story.label,
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isCreate
                        ? 'Media picker and upload will be added later.'
                        : 'Story viewer surface is ready for local product polish.',
                    style: const TextStyle(height: 1.35),
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

class _StoryPill extends StatelessWidget {
  const _StoryPill({required this.label});

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

class _StoryInfoCard extends StatelessWidget {
  const _StoryInfoCard({
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

String _storyInfoTitle({
  required bool isLive,
  required bool isProof,
  required bool isReplay,
}) {
  if (isLive) return 'Live story placeholder';
  if (isProof) return 'Proof-aware story';
  if (isReplay) return 'Replay-ready surface';
  return 'Story viewer placeholder';
}

String _storyInfoText({
  required bool isLive,
  required bool isProof,
  required bool isReplay,
}) {
  if (isLive) {
    return 'Live and replay behavior is represented visually only. Real streaming remains locked for a later package.';
  }

  if (isProof) {
    return 'CID proof story context is visual only until the CidenDB/CID boundary returns in a separate track.';
  }

  if (isReplay) {
    return 'Replay routing is planned after stories and reels are connected into a shared local preview flow.';
  }

  return 'This viewer can later connect to story media, reactions, replies, and replay sharing.';
}

class _StoryPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    for (var i = 0; i < 9; i++) {
      final x = i * size.width / 8;
      canvas.drawLine(
        Offset(x, 0),
        Offset(size.width - x / 3, size.height),
        line,
      );
    }

    final circle = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    canvas.drawCircle(
      Offset(size.width * 0.24, size.height * 0.74),
      size.width * 0.30,
      circle,
    );
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.22),
      size.width * 0.24,
      circle,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniStoryBadge extends StatelessWidget {
  const _MiniStoryBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEC4899),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _ProofDot extends StatelessWidget {
  const _ProofDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Icon(Icons.verified_rounded, size: 14, color: Colors.white),
    );
  }
}
