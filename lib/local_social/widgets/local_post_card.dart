import 'package:flutter/material.dart';

import '../local_social_data.dart';

const _cardBg = Color(0xFF101114);
const _cardSoft = Color(0xFF181A20);
const _line = Color(0xFF262A33);
const _textSoft = Color(0xFFA1A1AA);

class OriginalInspiredPostCard extends StatefulWidget {
  const OriginalInspiredPostCard({required this.post, super.key});

  final LocalPost post;

  @override
  State<OriginalInspiredPostCard> createState() =>
      _OriginalInspiredPostCardState();
}

class _OriginalInspiredPostCardState extends State<OriginalInspiredPostCard> {
  bool isFollowing = false;
  bool isLiked = false;
  bool isSaved = false;

  void _toggleFollow() {
    setState(() => isFollowing = !isFollowing);
    _showLocalActionSnack(
      context,
      isFollowing ? 'Following ${widget.post.author}' : 'Unfollowed preview',
    );
  }

  void _toggleLike() {
    setState(() => isLiked = !isLiked);
  }

  void _toggleSave() {
    setState(() => isSaved = !isSaved);
    _showLocalActionSnack(
      context,
      isSaved ? 'Saved to local preview' : 'Removed from saved preview',
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
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
          _PostHeader(
            post: post,
            firstLetter: firstLetter,
            isFollowing: isFollowing,
            onToggleFollow: _toggleFollow,
            onMoreOptions: () => _showPostOptionsSheet(context, post),
          ),
          _PostMedia(post: post),
          _PostActions(
            post: post,
            isLiked: isLiked,
            isSaved: isSaved,
            onToggleLike: _toggleLike,
            onComment: () => _showCommentsSheet(context, post),
            onShare: () => _showShareSheet(context, post),
            onToggleSave: _toggleSave,
          ),
          _PostCaption(post: post, isLiked: isLiked),
        ],
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  const _PostHeader({
    required this.post,
    required this.firstLetter,
    required this.isFollowing,
    required this.onToggleFollow,
    required this.onMoreOptions,
  });

  final LocalPost post;
  final String firstLetter;
  final bool isFollowing;
  final VoidCallback onToggleFollow;
  final VoidCallback onMoreOptions;

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
          GestureDetector(
            onTap: onToggleFollow,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isFollowing ? _cardSoft : Colors.white,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: isFollowing ? const Color(0xFF22C55E) : Colors.white,
                ),
              ),
              child: Text(
                isFollowing ? 'Following' : 'Follow',
                style: TextStyle(
                  color: isFollowing ? const Color(0xFF86EFAC) : Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onMoreOptions,
            icon: const Icon(Icons.more_horiz_rounded, color: Colors.white70),
            tooltip: 'Post options',
          ),
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
  const _PostActions({
    required this.post,
    required this.isLiked,
    required this.isSaved,
    required this.onToggleLike,
    required this.onComment,
    required this.onShare,
    required this.onToggleSave,
  });

  final LocalPost post;
  final bool isLiked;
  final bool isSaved;
  final VoidCallback onToggleLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onToggleSave;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      _ActionButton(
        icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        label: isLiked ? 'Liked' : post.likes,
        active: isLiked,
        onTap: onToggleLike,
      ),
      _ActionButton(
        icon: Icons.mode_comment_outlined,
        label: post.comments,
        onTap: onComment,
      ),
      _ActionButton(icon: Icons.send_outlined, label: 'Share', onTap: onShare),
      _ActionButton(
        icon: isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
        label: isSaved ? 'Saved' : 'Save',
        active: isSaved,
        onTap: onToggleSave,
      ),
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
  const _PostCaption({required this.post, required this.isLiked});

  final LocalPost post;
  final bool isLiked;

  @override
  Widget build(BuildContext context) {
    final likeText = isLiked
        ? 'You and ${post.likes} others liked this'
        : '${post.likes} likes';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(likeText, style: const TextStyle(fontWeight: FontWeight.w900)),
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

void _showLocalActionSnack(BuildContext context, String message) {
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

void _showPostOptionsSheet(BuildContext context, LocalPost post) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (context) {
      return _LocalPreviewSheet(
        title: 'Post options',
        subtitle: '${post.author} - local preview only',
        children: [
          _LocalSheetAction(
            icon: Icons.visibility_rounded,
            title: 'View post details',
            subtitle: 'Open a local detail preview later.',
            onTap: () {
              Navigator.of(context).pop();
              _showLocalActionSnack(context, 'Post detail preview');
            },
          ),
          _LocalSheetAction(
            icon: Icons.person_add_alt_1_rounded,
            title: 'Creator actions',
            subtitle: 'Follow, mute, report and proof actions later.',
            onTap: () {
              Navigator.of(context).pop();
              _showLocalActionSnack(context, 'Creator options preview');
            },
          ),
          _LocalSheetAction(
            icon: Icons.info_outline_rounded,
            title: 'CID proof note',
            subtitle: 'Real CID verification will be connected later.',
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}

void _showCommentsSheet(BuildContext context, LocalPost post) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return _LocalPreviewSheet(
        title: 'Comments',
        subtitle: '${post.comments} comments - local preview',
        children: [_LocalCommentsPreview(post: post)],
      );
    },
  );
}

void _showShareSheet(BuildContext context, LocalPost post) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (context) {
      return _LocalPreviewSheet(
        title: 'Share',
        subtitle: 'Local share paths for ${post.author}',
        children: [
          _LocalSheetAction(
            icon: Icons.link_rounded,
            title: 'Copy local link',
            subtitle: 'Preview only. No backend link is created.',
            onTap: () {
              Navigator.of(context).pop();
              _showLocalActionSnack(context, 'Local link copied preview');
            },
          ),
          _LocalSheetAction(
            icon: Icons.send_outlined,
            title: 'Send to chat',
            subtitle: 'Chat share path will be connected later.',
            onTap: () {
              Navigator.of(context).pop();
              _showLocalActionSnack(context, 'Chat share preview');
            },
          ),
          _LocalSheetAction(
            icon: Icons.qr_code_2_rounded,
            title: 'CID share proof',
            subtitle: 'Proof-backed share is planned for later.',
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}

class _LocalPreviewSheet extends StatelessWidget {
  const _LocalPreviewSheet({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
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
            Text(subtitle, style: const TextStyle(color: _textSoft)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _LocalSheetAction extends StatelessWidget {
  const _LocalSheetAction({
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
            color: _cardSoft,
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
                      style: const TextStyle(color: _textSoft, fontSize: 12),
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

class _LocalCommentsPreview extends StatefulWidget {
  const _LocalCommentsPreview({required this.post});

  final LocalPost post;

  @override
  State<_LocalCommentsPreview> createState() => _LocalCommentsPreviewState();
}

class _LocalCommentsPreviewState extends State<_LocalCommentsPreview> {
  late final TextEditingController _controller;
  final List<_LocalCommentDraft> _comments = [
    const _LocalCommentDraft(
      name: 'Selin',
      text: 'This Web4 creator flow feels clean.',
    ),
    const _LocalCommentDraft(
      name: 'Alex',
      text: 'The CID proof layer can become powerful.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _comments.add(_LocalCommentDraft(name: 'You', text: text));
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _controller.text.trim().isNotEmpty;
    final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return _PreviewComment(name: comment.name, text: comment.text);
              },
            ),
          ),
          const SizedBox(height: 12),
          _LocalCommentComposer(
            controller: _controller,
            canSend: canSend,
            onSubmit: _submitComment,
          ),
          const SizedBox(height: 8),
          const Text(
            'Local-only comment preview. Real comments will use the Cidentia.Live backend later.',
            style: TextStyle(color: _textSoft, fontSize: 11, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _LocalCommentDraft {
  const _LocalCommentDraft({required this.name, required this.text});

  final String name;
  final String text;
}

class _LocalCommentComposer extends StatelessWidget {
  const _LocalCommentComposer({
    required this.controller,
    required this.canSend,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool canSend;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: BoxDecoration(
        color: _cardSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: canSend ? const Color(0xFF22C55E) : _line),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 15,
            backgroundColor: Color(0xFF27272A),
            child: Text(
              'Y',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSubmit(),
              decoration: const InputDecoration(
                hintText: 'Add a local preview comment...',
                hintStyle: TextStyle(color: _textSoft),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            onPressed: canSend ? onSubmit : null,
            icon: Icon(
              Icons.send_rounded,
              color: canSend ? const Color(0xFF86EFAC) : Colors.white30,
            ),
            tooltip: 'Send local comment',
          ),
        ],
      ),
    );
  }
}

class _PreviewComment extends StatelessWidget {
  const _PreviewComment({required this.name, required this.text});

  final String name;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: const Color(0xFF27272A),
            child: Text(
              name.characters.first,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _cardSoft,
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
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
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: active ? const Color(0x3322C55E) : _cardSoft,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: active ? const Color(0xFF22C55E) : _line),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 19,
              color: active ? const Color(0xFF86EFAC) : Colors.white,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: active ? const Color(0xFFBBF7D0) : Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
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
