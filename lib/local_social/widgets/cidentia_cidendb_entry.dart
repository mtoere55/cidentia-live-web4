import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

const _entryPanel = Color(0xFF101114);
const _entryLine = Color(0xFF262A33);
const _entrySoft = Color(0xFFA1A1AA);
const _entryBridgeBaseUrl = String.fromEnvironment(
  'CIDENDB_ENTRY_BRIDGE_BASE_URL',
  defaultValue: 'http://localhost:3000',
);

class CidenDbEntryButton extends StatelessWidget {
  const CidenDbEntryButton({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return IconButton(
        tooltip: 'CidenDB / CID',
        onPressed: () => showCidenDbEntryNotice(context),
        icon: const Icon(Icons.verified_user_outlined),
      );
    }

    return Tooltip(
      message: 'CidenDB / CID sign-in entry',
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => showCidenDbEntryNotice(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _entryPanel,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _entryLine),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_user_outlined, size: 16),
              SizedBox(width: 6),
              Text(
                'CID',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showCidenDbEntryNotice(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const _CidenDbEntrySheet(),
  );
}

class _CidenDbEntrySheet extends StatefulWidget {
  const _CidenDbEntrySheet();

  @override
  State<_CidenDbEntrySheet> createState() => _CidenDbEntrySheetState();
}

class _CidenDbEntrySheetState extends State<_CidenDbEntrySheet> {
  final _identifierController = TextEditingController();
  final _otpController = TextEditingController();

  bool _busy = false;
  String _statusTitle = 'Bridge not tested yet';
  String _statusMessage =
      'This panel can call the disabled local backend skeleton only.';
  String _statusCode = 'LOCAL_PREVIEW_IDLE';

  @override
  void dispose() {
    _identifierController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    await _callDisabledBridge(
      route: '/api/cidendb/otp/send',
      payload: {'identifier': _identifierController.text.trim()},
    );
  }

  Future<void> _verifyOtp() async {
    await _callDisabledBridge(
      route: '/api/cidendb/otp/verify',
      payload: {
        'identifier': _identifierController.text.trim(),
        'otp': _otpController.text.trim(),
      },
    );
  }

  Future<void> _callDisabledBridge({
    required String route,
    required Map<String, String> payload,
  }) async {
    setState(() {
      _busy = true;
      _statusTitle = 'Calling disabled bridge...';
      _statusMessage = route;
      _statusCode = 'LOCAL_PREVIEW_PENDING';
    });

    try {
      final uri = Uri.parse('$_entryBridgeBaseUrl$route');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);

      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(payload));

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      client.close(force: true);

      final decoded = jsonDecode(body);

      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _statusTitle = 'Disabled bridge response';
        _statusCode = decoded is Map<String, dynamic>
            ? '${decoded['code'] ?? 'UNKNOWN'}'
            : 'UNKNOWN';
        _statusMessage =
            'HTTP ${response.statusCode} - ${decoded is Map<String, dynamic> ? decoded['message'] ?? body : body}';
      });
    } on Object catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _statusTitle = 'Backend not reachable';
        _statusCode = 'LOCAL_BACKEND_NOT_RUNNING';
        _statusMessage =
            'No live CidenDB call was made. Start the local backend/dev server later to test M4E routes. $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.42,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _entryPanel,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _entryLine),
          ),
          child: SafeArea(
            top: false,
            child: ListView(
              controller: scrollController,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF60A5FA),
                            Color(0xFF7C3AED),
                            Color(0xFFEC4899),
                          ],
                        ),
                      ),
                      child: const Icon(Icons.verified_user_outlined),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CidenDB / CID Entry',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Disabled backend bridge preview',
                            style: TextStyle(
                              color: _entrySoft,
                              fontWeight: FontWeight.w700,
                            ),
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
                const Text(
                  'This panel is connected only to the local disabled M4E backend skeleton.',
                  style: TextStyle(fontWeight: FontWeight.w800, height: 1.35),
                ),
                const SizedBox(height: 10),
                const Text(
                  'It can show bridge-disabled responses, but it cannot create a login, CID session, token, upload, RTMP, wallet, payment, blockchain action, or verified identity.',
                  style: TextStyle(color: _entrySoft, height: 1.35),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _identifierController,
                  decoration: const InputDecoration(
                    labelText: 'Email or phone preview',
                    hintText: 'example@mail.com',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _otpController,
                  decoration: const InputDecoration(
                    labelText: 'OTP preview',
                    hintText: 'Disabled bridge only',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: _busy ? null : _requestOtp,
                      icon: const Icon(Icons.sms_outlined),
                      label: const Text('Request OTP'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _verifyOtp,
                      icon: const Icon(Icons.verified_outlined),
                      label: const Text('Verify OTP'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _BridgeStatusCard(
                  busy: _busy,
                  title: _statusTitle,
                  code: _statusCode,
                  message: _statusMessage,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
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
                          'Real CidenDB OTP and verified CID session handoff remain closed until a separate backend-confirmed milestone.',
                          style: TextStyle(
                            color: Color(0xFFFDE68A),
                            height: 1.35,
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
      },
    );
  }
}

class _BridgeStatusCard extends StatelessWidget {
  const _BridgeStatusCard({
    required this.busy,
    required this.title,
    required this.code,
    required this.message,
  });

  final bool busy;
  final String title;
  final String code;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF151821),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _entryLine),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (busy)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            const Icon(Icons.info_outline_rounded, color: Color(0xFF93C5FD)),
          const SizedBox(width: 10),
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
                  code,
                  style: const TextStyle(
                    color: Color(0xFF93C5FD),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(color: _entrySoft, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
