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
            story.isCreate ? 'Create' : 'Story',
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
