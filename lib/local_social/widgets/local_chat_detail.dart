import 'package:flutter/material.dart';

import '../local_social_data.dart';

const _panel = Color(0xFF101114);
const _panelSoft = Color(0xFF181A20);
const _line = Color(0xFF262A33);
const _textSoft = Color(0xFFA1A1AA);

class OriginalInspiredChatsPage extends StatelessWidget {
  const OriginalInspiredChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;

        if (compact) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 90),
            children: const [
              _ChatsHeader(),
              SizedBox(height: 16),
              _ChatListPanel(),
              SizedBox(height: 16),
              _ConversationPanel(),
            ],
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 90),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(width: 310, child: _ChatListPanel()),
              SizedBox(width: 18),
              Expanded(child: _ConversationPanel()),
            ],
          ),
        );
      },
    );
  }
}

class _ChatsHeader extends StatelessWidget {
  const _ChatsHeader();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Messages',
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.8,
      ),
    );
  }
}

class _ChatListPanel extends StatelessWidget {
  const _ChatListPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(6, 4, 6, 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Inbox',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
                  ),
                ),
                _RoundIconButton(icon: Icons.edit_square),
              ],
            ),
          ),
          const _SearchBox(),
          const SizedBox(height: 12),
          for (var i = 0; i < localChats.length; i++)
            _ChatInboxTile(chat: localChats[i], active: i == 0, index: i),
        ],
      ),
    );
  }
}

class _ChatInboxTile extends StatelessWidget {
  const _ChatInboxTile({
    required this.chat,
    required this.active,
    required this.index,
  });

  final LocalChat chat;
  final bool active;
  final int index;

  @override
  Widget build(BuildContext context) {
    final initial = chat.name.isEmpty ? '?' : chat.name.substring(0, 1);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: active ? Colors.white10 : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? Colors.white12 : Colors.transparent),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _avatarColors(index),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 1,
                bottom: 1,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: index < 3 ? const Color(0xFF22C55E) : _textSoft,
                    shape: BoxShape.circle,
                    border: Border.all(color: _panel, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  chat.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _textSoft, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            chat.time,
            style: const TextStyle(
              color: _textSoft,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationPanel extends StatelessWidget {
  const _ConversationPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: const [
          _ConversationHeader(),
          Divider(height: 1, color: _line),
          _MessageArea(),
          Divider(height: 1, color: _line),
          _MessageInputBar(),
        ],
      ),
    );
  }
}

class _ConversationHeader extends StatelessWidget {
  const _ConversationHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFE879F9), Color(0xFFF97316)],
              ),
            ),
            child: const Center(
              child: Text(
                'M',
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
                  'Mira Studio',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                SizedBox(height: 3),
                Text(
                  'Online - CID proof enabled',
                  style: TextStyle(color: _textSoft, fontSize: 12),
                ),
              ],
            ),
          ),
          const _RoundIconButton(icon: Icons.call_outlined),
          const SizedBox(width: 8),
          const _RoundIconButton(icon: Icons.videocam_outlined),
          const SizedBox(width: 8),
          const _RoundIconButton(icon: Icons.more_horiz_rounded),
        ],
      ),
    );
  }
}

class _MessageArea extends StatelessWidget {
  const _MessageArea();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 460,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: const [
          _DayChip(label: 'Today'),
          SizedBox(height: 16),
          _MessageBubble(
            text:
                'Local preview is ready. The social shell feels much better now.',
            time: '18:04',
            incoming: true,
          ),
          _MessageBubble(
            text:
                'Yes. Feed, profile, stories and CID panels are now connected.',
            time: '18:05',
            incoming: false,
          ),
          _AttachmentBubble(),
          _MessageBubble(
            text:
                'Next step: real media slots, chat actions and later backend adapter.',
            time: '18:08',
            incoming: true,
          ),
          _MessageBubble(
            text: 'Keep it backend-free until the UI is stable.',
            time: '18:09',
            incoming: false,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.text,
    required this.time,
    required this.incoming,
  });

  final String text;
  final String time;
  final bool incoming;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: incoming ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 430),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        decoration: BoxDecoration(
          color: incoming ? _panelSoft : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(incoming ? 4 : 18),
            bottomRight: Radius.circular(incoming ? 18 : 4),
          ),
          border: Border.all(color: incoming ? _line : Colors.white),
        ),
        child: Column(
          crossAxisAlignment: incoming
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: TextStyle(
                color: incoming ? Colors.white : Colors.black,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              time,
              style: TextStyle(
                color: incoming ? _textSoft : Colors.black54,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentBubble extends StatelessWidget {
  const _AttachmentBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 430),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _line),
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFF60A5FA), Color(0xFF7C3AED)],
                ),
              ),
              child: const Icon(Icons.fingerprint_rounded, size: 34),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Proof attachment',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Future signed media and verification preview.',
                    style: TextStyle(color: _textSoft, height: 1.3),
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

class _MessageInputBar extends StatelessWidget {
  const _MessageInputBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const _RoundIconButton(icon: Icons.add_rounded),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: _panelSoft,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: _line),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Message...',
                style: TextStyle(color: _textSoft, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const _RoundIconButton(icon: Icons.mic_none_rounded),
          const SizedBox(width: 10),
          const _SendButton(),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: _line),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: const Row(
        children: [
          Icon(Icons.search_rounded, color: _textSoft, size: 18),
          SizedBox(width: 8),
          Text(
            'Search messages',
            style: TextStyle(color: _textSoft, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: _panelSoft,
        shape: BoxShape.circle,
        border: Border.all(color: _line),
      ),
      child: Icon(icon, size: 19),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF60A5FA), Color(0xFFEC4899)],
        ),
      ),
      child: const Icon(Icons.send_rounded, size: 19),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: _line),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: _textSoft,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

List<Color> _avatarColors(int index) {
  const palettes = [
    [Color(0xFFE879F9), Color(0xFFF97316)],
    [Color(0xFF60A5FA), Color(0xFF06B6D4)],
    [Color(0xFFA78BFA), Color(0xFF6366F1)],
    [Color(0xFF34D399), Color(0xFF059669)],
    [Color(0xFFFBBF24), Color(0xFFF97316)],
  ];

  return palettes[index % palettes.length];
}
