import 'package:flutter/material.dart';

import '../auth/cidentia_auth_gate_contract.dart';
import '../auth/cidentia_protected_action_notice.dart';
import '../local_social_data.dart';

const _panel = Color(0xFF101114);
const _panelSoft = Color(0xFF181A20);
const _line = Color(0xFF262A33);
const _textSoft = Color(0xFFA1A1AA);

class OriginalInspiredChatsPage extends StatefulWidget {
  const OriginalInspiredChatsPage({super.key});

  @override
  State<OriginalInspiredChatsPage> createState() =>
      _OriginalInspiredChatsPageState();
}

class _OriginalInspiredChatsPageState extends State<OriginalInspiredChatsPage> {
  int selectedIndex = 0;

  late final Map<int, List<_LocalMessage>> threads = {
    for (var i = 0; i < localChats.length; i++) i: _seedMessages(i),
  };

  void _selectChat(int index) {
    setState(() => selectedIndex = index);
  }

  void _sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    CidentiaProtectedActionNotice.show(
      context,
      action: CidentiaProtectedAction.sendMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedChat = localChats[selectedIndex];
    final selectedMessages = threads[selectedIndex]!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;

        if (compact) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 90),
            children: [
              const _ChatsHeader(),
              const SizedBox(height: 16),
              _ChatListPanel(
                selectedIndex: selectedIndex,
                onSelect: _selectChat,
              ),
              const SizedBox(height: 16),
              _ConversationPanel(
                chat: selectedChat,
                index: selectedIndex,
                messages: selectedMessages,
                onSend: _sendMessage,
              ),
            ],
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 90),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 310,
                child: _ChatListPanel(
                  selectedIndex: selectedIndex,
                  onSelect: _selectChat,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _ConversationPanel(
                  chat: selectedChat,
                  index: selectedIndex,
                  messages: selectedMessages,
                  onSend: _sendMessage,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LocalMessage {
  const _LocalMessage({
    required this.text,
    required this.time,
    required this.incoming,
    this.attachment = false,
  });

  final String text;
  final String time;
  final bool incoming;
  final bool attachment;
}

List<_LocalMessage> _seedMessages(int index) {
  final chat = localChats[index];

  return [
    const _LocalMessage(text: 'Today', time: '', incoming: true),
    _LocalMessage(
      text: '${chat.name} local preview conversation is open.',
      time: '18:04',
      incoming: true,
    ),
    const _LocalMessage(
      text: 'Good. Keep the UI stable before backend.',
      time: '18:05',
      incoming: false,
    ),
    const _LocalMessage(
      text: 'Proof attachment',
      time: '18:06',
      incoming: true,
      attachment: true,
    ),
    _LocalMessage(text: chat.message, time: chat.time, incoming: true),
  ];
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
  const _ChatListPanel({required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

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
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 6, 14),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Inbox',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
                  ),
                ),
                _RoundIconButton(
                  icon: Icons.edit_square,
                  onTap: () =>
                      _showChatSnack(context, 'New chat composer preview'),
                ),
              ],
            ),
          ),
          const _SearchBox(),
          const SizedBox(height: 12),
          for (var i = 0; i < localChats.length; i++)
            _ChatInboxTile(
              chat: localChats[i],
              active: i == selectedIndex,
              index: i,
              onTap: () => onSelect(i),
            ),
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
    required this.onTap,
  });

  final LocalChat chat;
  final bool active;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial = chat.name.isEmpty ? '?' : chat.name.substring(0, 1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: active ? Colors.white10 : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active ? Colors.white12 : Colors.transparent,
            ),
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
        ),
      ),
    );
  }
}

class _ConversationPanel extends StatelessWidget {
  const _ConversationPanel({
    required this.chat,
    required this.index,
    required this.messages,
    required this.onSend,
  });

  final LocalChat chat;
  final int index;
  final List<_LocalMessage> messages;
  final ValueChanged<String> onSend;

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
        children: [
          _ConversationHeader(chat: chat, index: index),
          const Divider(height: 1, color: _line),
          _MessageArea(messages: messages),
          const Divider(height: 1, color: _line),
          _MessageInputBar(onSend: onSend),
        ],
      ),
    );
  }
}

class _ConversationHeader extends StatelessWidget {
  const _ConversationHeader({required this.chat, required this.index});

  final LocalChat chat;
  final int index;

  @override
  Widget build(BuildContext context) {
    final initial = chat.name.isEmpty ? '?' : chat.name.substring(0, 1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: _avatarColors(index)),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Online - local CID chat preview',
                  style: TextStyle(color: _textSoft, fontSize: 12),
                ),
              ],
            ),
          ),
          _RoundIconButton(
            icon: Icons.call_outlined,
            onTap: () => _showChatSnack(context, 'Voice call preview'),
          ),
          const SizedBox(width: 8),
          _RoundIconButton(
            icon: Icons.videocam_outlined,
            onTap: () => _showChatSnack(context, 'Video call preview'),
          ),
          const SizedBox(width: 8),
          _RoundIconButton(
            icon: Icons.more_horiz_rounded,
            onTap: () => _showChatSnack(context, 'Chat options preview'),
          ),
        ],
      ),
    );
  }
}

class _MessageArea extends StatelessWidget {
  const _MessageArea({required this.messages});

  final List<_LocalMessage> messages;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 460,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const _DayChip(label: 'Today'),
          const SizedBox(height: 16),
          for (final message in messages)
            if (message.attachment)
              const _AttachmentBubble()
            else if (message.text != 'Today')
              _MessageBubble(
                text: message.text,
                time: message.time,
                incoming: message.incoming,
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

class _MessageInputBar extends StatefulWidget {
  const _MessageInputBar({required this.onSend});

  final ValueChanged<String> onSend;

  @override
  State<_MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<_MessageInputBar> {
  final TextEditingController controller = TextEditingController();

  bool get canSend => controller.text.trim().isNotEmpty;

  void _send() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    widget.onSend(text);
    controller.clear();
    setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _RoundIconButton(
            icon: Icons.add_rounded,
            onTap: () => _showChatSnack(context, 'Attachment picker preview'),
          ),
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
              child: TextField(
                controller: controller,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _send(),
                decoration: const InputDecoration(
                  hintText: 'Message...',
                  hintStyle: TextStyle(
                    color: _textSoft,
                    fontWeight: FontWeight.w600,
                  ),
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _RoundIconButton(
            icon: Icons.mic_none_rounded,
            onTap: () => _showChatSnack(context, 'Voice note preview'),
          ),
          const SizedBox(width: 10),
          _SendButton(enabled: canSend, onTap: _send),
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
  const _RoundIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _panelSoft,
          shape: BoxShape.circle,
          border: Border.all(color: _line),
        ),
        child: Icon(icon, size: 19),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = enabled
        ? [const Color(0xFF60A5FA), const Color(0xFFEC4899)]
        : [const Color(0xFF3F3F46), const Color(0xFF27272A)];

    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: enabled ? onTap : null,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: colors),
        ),
        child: Icon(
          Icons.send_rounded,
          size: 19,
          color: enabled ? Colors.white : _textSoft,
        ),
      ),
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

void _showChatSnack(BuildContext context, String message) {
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
