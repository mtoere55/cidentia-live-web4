import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../auth/cidentia_session_state.dart';

const cidentiaEntryBridgeBaseUrl = 'http://localhost:3000';
const cidentiaAppOnboardingUrl = 'https://cidentiaapp.com';

enum CidentiaUiLanguage { en, tr, de }

extension CidentiaUiLanguageText on CidentiaUiLanguage {
  String get code {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'EN';
      case CidentiaUiLanguage.tr:
        return 'TR';
      case CidentiaUiLanguage.de:
        return 'DE';
    }
  }

  String get appTitle => 'Cidentia.Live';

  String get appSubtitle {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'Live / social program of the Cidentia ecosystem';
      case CidentiaUiLanguage.tr:
        return 'Cidentia ekosisteminin live / social programÄ±';
      case CidentiaUiLanguage.de:
        return 'Live- / Social-Programm des Cidentia-Ã–kosystems';
    }
  }

  String get heroLead {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'Connect, create and go live. Your identity is protected by CidenDB, the official identity databank of the Cidentia ecosystem.';
      case CidentiaUiLanguage.tr:
        return 'BaÄŸlan, Ã¼ret ve canlÄ±ya Ã§Ä±k. KimliÄŸiniz Cidentia ekosisteminin resmi kimlik databankÄ± CidenDB tarafÄ±ndan korunur.';
      case CidentiaUiLanguage.de:
        return 'Verbinden, erstellen und live gehen. Ihre IdentitÃ¤t wird durch CidenDB geschÃ¼tzt, die offizielle IdentitÃ¤tsdatenbank des Cidentia-Ã–kosystems.';
    }
  }

  String get signInTitle {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'Sign in with CidenDB';
      case CidentiaUiLanguage.tr:
        return 'CidenDB ile giriÅŸ yap';
      case CidentiaUiLanguage.de:
        return 'Mit CidenDB anmelden';
    }
  }

  String get signInHelp {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'We will send a 6-digit verification code to your email.';
      case CidentiaUiLanguage.tr:
        return 'E-postanÄ±za 6 haneli bir doÄŸrulama kodu gÃ¶ndereceÄŸiz.';
      case CidentiaUiLanguage.de:
        return 'Wir senden einen 6-stelligen BestÃ¤tigungscode an Ihre E-Mail.';
    }
  }

  String get emailLabel {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'Email';
      case CidentiaUiLanguage.tr:
        return 'E-posta';
      case CidentiaUiLanguage.de:
        return 'E-Mail';
    }
  }

  String get emailHint => 'you@domain.com';

  String get requestOtp {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'Request OTP';
      case CidentiaUiLanguage.tr:
        return 'OTP kodu iste';
      case CidentiaUiLanguage.de:
        return 'OTP anfordern';
    }
  }

  String get codeLabel {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'Verification code';
      case CidentiaUiLanguage.tr:
        return 'DoÄŸrulama kodu';
      case CidentiaUiLanguage.de:
        return 'BestÃ¤tigungscode';
    }
  }

  String get codeHint {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'Enter 6-digit code';
      case CidentiaUiLanguage.tr:
        return '6 haneli kodu girin';
      case CidentiaUiLanguage.de:
        return '6-stelligen Code eingeben';
    }
  }

  String get verifyCode {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'Verify Code';
      case CidentiaUiLanguage.tr:
        return 'Kodu doÄŸrula';
      case CidentiaUiLanguage.de:
        return 'Code bestÃ¤tigen';
    }
  }

  String get continueCidentiaApp {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'Go to CidentiaApp';
      case CidentiaUiLanguage.tr:
        return 'CidentiaAppâ€™a devam et';
      case CidentiaUiLanguage.de:
        return 'Zu CidentiaApp';
    }
  }

  String get exploreGuest {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'Explore without sign-in';
      case CidentiaUiLanguage.tr:
        return 'GiriÅŸ yapmadan keÅŸfet';
      case CidentiaUiLanguage.de:
        return 'Ohne Anmeldung entdecken';
    }
  }

  String get cidSetupTitle {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'CID setup required';
      case CidentiaUiLanguage.tr:
        return 'CID tamamlanmasÄ± gerekiyor';
      case CidentiaUiLanguage.de:
        return 'CID-Einrichtung erforderlich';
    }
  }

  String get cidSetupBody {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'Your email is verified, but this account does not have an active CID yet. Complete your identity setup in CidentiaApp before continuing.';
      case CidentiaUiLanguage.tr:
        return 'E-posta doÄŸrulandÄ±, ancak bu hesap iÃ§in aktif CID bulunamadÄ±. Devam etmek iÃ§in CidentiaApp Ã¼zerinden kimlik adÄ±mÄ±nÄ± tamamlayÄ±n.';
      case CidentiaUiLanguage.de:
        return 'Ihre E-Mail wurde bestÃ¤tigt, aber dieses Konto hat noch keine aktive CID. Bitte schlieÃŸen Sie die IdentitÃ¤tseinrichtung in CidentiaApp ab.';
    }
  }

  String get verifiedTitle {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'Verified session ready';
      case CidentiaUiLanguage.tr:
        return 'DoÄŸrulanmÄ±ÅŸ oturum hazÄ±r';
      case CidentiaUiLanguage.de:
        return 'Verifizierte Sitzung bereit';
    }
  }

  String get verifiedBody {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'Your identity is verified. A safe Cidentia.Live session is ready.';
      case CidentiaUiLanguage.tr:
        return 'KimliÄŸiniz doÄŸrulandÄ±. GÃ¼venli Cidentia.Live oturumu hazÄ±r.';
      case CidentiaUiLanguage.de:
        return 'Ihre IdentitÃ¤t ist bestÃ¤tigt. Eine sichere Cidentia.Live-Sitzung ist bereit.';
    }
  }

  String get invalidCodeTitle {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'Invalid code';
      case CidentiaUiLanguage.tr:
        return 'Kod doÄŸrulanamadÄ±';
      case CidentiaUiLanguage.de:
        return 'UngÃ¼ltiger Code';
    }
  }

  String get invalidCodeBody {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'The code is incorrect or expired. Please check your email and try again.';
      case CidentiaUiLanguage.tr:
        return 'Kod hatalÄ± veya sÃ¼resi dolmuÅŸ olabilir. E-postanÄ±za gelen son kodu kontrol edin.';
      case CidentiaUiLanguage.de:
        return 'Der Code ist falsch oder abgelaufen. Bitte prÃ¼fen Sie Ihre E-Mail und versuchen Sie es erneut.';
    }
  }

  String get serviceUnavailableTitle {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'Service unavailable';
      case CidentiaUiLanguage.tr:
        return 'Servis kullanÄ±lamÄ±yor';
      case CidentiaUiLanguage.de:
        return 'Dienst nicht verfÃ¼gbar';
    }
  }

  String get serviceUnavailableBody {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'CidenDB connection is currently unavailable. Please try again later.';
      case CidentiaUiLanguage.tr:
        return 'CidenDB baÄŸlantÄ±sÄ± ÅŸu anda kullanÄ±lamÄ±yor. LÃ¼tfen tekrar deneyin.';
      case CidentiaUiLanguage.de:
        return 'Die CidenDB-Verbindung ist derzeit nicht verfÃ¼gbar. Bitte versuchen Sie es spÃ¤ter erneut.';
    }
  }

  String get technicalDetails {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'Technical details';
      case CidentiaUiLanguage.tr:
        return 'Teknik detaylar';
      case CidentiaUiLanguage.de:
        return 'Technische Details';
    }
  }
}

class CidentiaEcosystemEntryGate extends StatefulWidget {
  const CidentiaEcosystemEntryGate({
    required this.language,
    required this.onLanguageChanged,
    required this.onEnter,
    this.onVerifiedEnter,
    super.key,
  });

  final CidentiaUiLanguage language;
  final ValueChanged<CidentiaUiLanguage> onLanguageChanged;
  final VoidCallback onEnter;
  final ValueChanged<CidentiaSessionState>? onVerifiedEnter;

  @override
  State<CidentiaEcosystemEntryGate> createState() =>
      _CidentiaEcosystemEntryGateState();
}

class _CidentiaEcosystemEntryGateState
    extends State<CidentiaEcosystemEntryGate> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();

  bool _busy = false;
  bool _showDetails = false;
  _EntryResult _result = _EntryResult.idle();

  CidentiaUiLanguage get text => widget.language;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    await _callBridge(
      route: '/api/cidendb/otp/send',
      payload: {'identifier': _emailController.text.trim()},
    );
  }

  Future<void> _verifyOtp() async {
    await _callBridge(
      route: '/api/cidendb/otp/verify',
      payload: {
        'identifier': _emailController.text.trim(),
        'otp': _codeController.text.trim(),
      },
    );
  }

  Future<void> _callBridge({
    required String route,
    required Map<String, String> payload,
  }) async {
    setState(() {
      _busy = true;
      _result = _EntryResult.pending(route);
    });

    try {
      final uri = Uri.parse('$cidentiaEntryBridgeBaseUrl$route');
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 6);
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(payload));

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      client.close(force: true);

      final decoded = jsonDecode(body) as Object;

      if (!mounted) {
        return;
      }

      final result = route.endsWith('/send')
          ? _EntryResult.otpSent(text)
          : _EntryResult.fromBridgeResponse(
              language: text,
              statusCode: response.statusCode,
              decoded: decoded,
              rawBody: body,
            );

      setState(() {
        _busy = false;
        _result = result;
      });

      if (result.kind == _EntryResultKind.verified) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            if (result.session != null && widget.onVerifiedEnter != null) {
              widget.onVerifiedEnter!(result.session!);
            } else {
              widget.onEnter();
            }
          }
        });
      }
    } on Object catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _result = _EntryResult.unavailable(text, '$error');
      });
    }
  }

  void _openCidentiaApp() {
    setState(() {
      _result = _EntryResult.onboarding(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 980;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _TopBar(
              language: widget.language,
              onLanguageChanged: widget.onLanguageChanged,
            ),
            const SizedBox(height: 24),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _HeroPanel(language: text)),
                  const SizedBox(width: 24),
                  SizedBox(width: 560, child: _signInPanel()),
                ],
              )
            else ...[
              _HeroPanel(language: text),
              const SizedBox(height: 18),
              _signInPanel(),
            ],
            const SizedBox(height: 20),
            _ActionCards(
              language: text,
              onCidentiaApp: _openCidentiaApp,
              onExplore: widget.onEnter,
            ),
            const SizedBox(height: 20),
            _ResultGrid(
              language: text,
              result: _result,
              showDetails: _showDetails,
              onToggleDetails: () =>
                  setState(() => _showDetails = !_showDetails),
              onCidentiaApp: _openCidentiaApp,
              onEnter: widget.onEnter,
            ),
            const SizedBox(height: 20),
            _Footer(language: text),
          ],
        ),
      ),
    );
  }

  Widget _signInPanel() {
    return _GlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBubble(
                icon: Icons.verified_user_outlined,
                color: const Color(0xFF38BDF8),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text.signInTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(text.signInHelp, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 18),
          Text(
            text.emailLabel,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.mail_outline_rounded),
                    hintText: text.emailHint,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _busy ? null : _requestOtp,
                icon: const Icon(Icons.send_rounded),
                label: Text(text.requestOtp),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            text.codeLabel,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.shield_outlined),
                    hintText: text.codeHint,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _busy ? null : _verifyOtp,
                icon: const Icon(Icons.lock_open_rounded),
                label: Text(text.verifyCode),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_busy) const LinearProgressIndicator(),
          const SizedBox(height: 10),
          _HowItWorks(language: text),
        ],
      ),
    );
  }
}

class _EntryResult {
  const _EntryResult({
    required this.title,
    required this.message,
    required this.code,
    required this.kind,
    this.details = '',
    this.session,
  });

  factory _EntryResult.idle() => const _EntryResult(
    title: 'Ready',
    message: 'Choose a sign-in path or explore public content.',
    code: 'LOCAL_ENTRY_READY',
    kind: _EntryResultKind.idle,
  );

  factory _EntryResult.pending(String route) => _EntryResult(
    title: 'Checking CidenDB',
    message: route,
    code: 'LOCAL_BRIDGE_PENDING',
    kind: _EntryResultKind.pending,
  );
  factory _EntryResult.otpSent(CidentiaUiLanguage language) {
    return const _EntryResult(
      title: 'OTP sent',
      message: 'Enter the code from CidenDB to continue.',
      code: 'CIDENDB_OTP_SENT',
      kind: _EntryResultKind.pending,
    );
  }

  factory _EntryResult.unavailable(CidentiaUiLanguage language, String error) {
    return _EntryResult(
      title: language.serviceUnavailableTitle,
      message: language.serviceUnavailableBody,
      code: 'LOCAL_BACKEND_NOT_RUNNING',
      kind: _EntryResultKind.unavailable,
      details: error,
    );
  }

  factory _EntryResult.onboarding(CidentiaUiLanguage language) {
    return _EntryResult(
      title: language.cidSetupTitle,
      message: language.cidSetupBody,
      code: 'CIDENDB_VERIFY_OK_CID_REQUIRED',
      kind: _EntryResultKind.onboarding,
      details:
          'onboardingRequired:true\nredirectUrl:$cidentiaAppOnboardingUrl\nsessionCreated:false',
    );
  }

  factory _EntryResult.fromBridgeResponse({
    required CidentiaUiLanguage language,
    required int statusCode,
    required Object decoded,
    required String rawBody,
  }) {
    Map<String, dynamic>? asMap(Object? value) {
      return value is Map<String, dynamic> ? value : null;
    }

    String? readText(Map<String, dynamic>? map, List<String> keys) {
      if (map == null) {
        return null;
      }

      for (final key in keys) {
        final value = map[key];
        if (value != null && '$value'.trim().isNotEmpty) {
          return '$value'.trim();
        }
      }

      return null;
    }

    if (decoded is! Map<String, dynamic>) {
      return _EntryResult(
        title: language.serviceUnavailableTitle,
        message: language.serviceUnavailableBody,
        code: 'UNKNOWN_RESPONSE',
        kind: _EntryResultKind.unavailable,
        details: rawBody,
      );
    }

    final code = '${decoded['code'] ?? 'UNKNOWN'}';
    final upstream = asMap(decoded['upstream']);
    final user = asMap(decoded['user']) ?? asMap(upstream?['user']);
    final details = const JsonEncoder.withIndent('  ').convert(decoded);

    final cid = readText(user, [
      'cid',
      'cid_number',
      'cidNumber',
      'ciden_id',
      'cidenId',
    ]);

    final displayName = readText(user, [
      'display_name',
      'full_name',
      'name',
      'email',
    ]);

    final email = readText(user, ['email', 'mail', 'contact']);

    final hasSafeSession =
        decoded['sessionCreated'] == true ||
        code == 'CIDENDB_SAFE_SESSION_CREATED' ||
        (code == 'CIDENDB_UPSTREAM_OK' && cid != null);

    if (hasSafeSession && cid != null) {
      final cidLine = '\nCID: $cid';
      final nameLine = displayName == null ? '' : '\nUser: $displayName';

      return _EntryResult(
        title: language.verifiedTitle,
        message: '${language.verifiedBody}$cidLine$nameLine',
        code: code,
        kind: _EntryResultKind.verified,
        details: details,
        session: CidentiaSessionState.verified(
          cid: cid,
          displayName: displayName,
          email: email,
          message: language.verifiedBody,
        ),
      );
    }

    if (code == 'CIDENDB_VERIFY_OK_CID_REQUIRED' ||
        decoded['onboardingRequired'] == true ||
        (code == 'CIDENDB_UPSTREAM_OK' && cid == null)) {
      return _EntryResult(
        title: language.cidSetupTitle,
        message: language.cidSetupBody,
        code: code,
        kind: _EntryResultKind.onboarding,
        details: details,
      );
    }

    if (statusCode == 401 ||
        code == 'CIDENDB_UPSTREAM_ERROR' ||
        code == 'CIDENDB_INVALID_OTP') {
      return _EntryResult(
        title: language.invalidCodeTitle,
        message: language.invalidCodeBody,
        code: code,
        kind: _EntryResultKind.invalid,
        details: details,
      );
    }

    if (code == 'CIDENDB_BRIDGE_DISABLED' ||
        code == 'CIDENDB_CONTRACT_NOT_CONFIRMED' ||
        code == 'CIDENDB_UPSTREAM_CLIENT_NOT_IMPLEMENTED') {
      return _EntryResult(
        title: language.serviceUnavailableTitle,
        message: language.serviceUnavailableBody,
        code: code,
        kind: _EntryResultKind.unavailable,
        details: details,
      );
    }

    return _EntryResult(
      title: language.serviceUnavailableTitle,
      message: language.serviceUnavailableBody,
      code: code,
      kind: _EntryResultKind.unavailable,
      details: details,
    );
  }

  final String title;
  final String message;
  final String code;
  final String details;
  final _EntryResultKind kind;
  final CidentiaSessionState? session;
}

enum _EntryResultKind {
  idle,
  pending,
  verified,
  onboarding,
  invalid,
  unavailable,
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.language, required this.onLanguageChanged});

  final CidentiaUiLanguage language;
  final ValueChanged<CidentiaUiLanguage> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _CidentiaLogo(),
        const SizedBox(width: 12),
        const Text(
          'cidentia.live',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
        ),
        const Spacer(),
        if (MediaQuery.sizeOf(context).width >= 900) const _EcosystemLinks(),
        const SizedBox(width: 16),
        _LanguageToggle(language: language, onChanged: onLanguageChanged),
      ],
    );
  }
}

class _CidentiaLogo extends StatelessWidget {
  const _CidentiaLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF9333EA), Color(0xFFEC4899)],
        ),
        border: Border.all(color: Colors.white24),
      ),
      child: const Center(
        child: Text(
          'C',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _EcosystemLinks extends StatelessWidget {
  const _EcosystemLinks();

  @override
  Widget build(BuildContext context) {
    const links = [
      ('cidentia.com', 'Ecosystem'),
      ('cidendb.com', 'Identity DB'),
      ('cidentiaapp.com', 'Onboarding'),
      ('cidenbridge.com', 'Bridge Layer'),
      ('cidentia.live', 'Live / Social'),
    ];

    return Wrap(
      spacing: 8,
      children: [
        for (final link in links)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: link.$1 == 'cidentia.live'
                  ? Colors.white10
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: link.$1 == 'cidentia.live'
                    ? const Color(0xFFA855F7)
                    : Colors.white12,
              ),
            ),
            child: Column(
              children: [
                Text(
                  link.$1,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(link.$2, style: const TextStyle(color: Colors.white60)),
              ],
            ),
          ),
      ],
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({required this.language, required this.onChanged});

  final CidentiaUiLanguage language;
  final ValueChanged<CidentiaUiLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<CidentiaUiLanguage>(
      segments: [
        for (final value in CidentiaUiLanguage.values)
          ButtonSegment(value: value, label: Text(value.code)),
      ],
      selected: {language},
      onSelectionChanged: (values) => onChanged(values.first),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.language});

  final CidentiaUiLanguage language;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language.appTitle,
            style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            language.appSubtitle,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Text(
            language.heroLead,
            style: const TextStyle(color: Colors.white70, height: 1.45),
          ),
          const SizedBox(height: 24),
          const Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _FeatureBadge(
                icon: Icons.shield_outlined,
                title: 'Secure Identity',
              ),
              _FeatureBadge(icon: Icons.person_outline, title: 'Your Control'),
              _FeatureBadge(icon: Icons.lock_outline, title: 'Safe Sessions'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCards extends StatelessWidget {
  const _ActionCards({
    required this.language,
    required this.onCidentiaApp,
    required this.onExplore,
  });

  final CidentiaUiLanguage language;
  final VoidCallback onCidentiaApp;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        _ActionCard(
          icon: Icons.person_add_alt_1_rounded,
          title: language.continueCidentiaApp,
          body: language.cidSetupBody,
          color: const Color(0xFF22C55E),
          onTap: onCidentiaApp,
        ),
        _ActionCard(
          icon: Icons.public_rounded,
          title: language.exploreGuest,
          body: 'Feed, Search, Reels and public live previews stay open.',
          color: const Color(0xFF3B82F6),
          onTap: onExplore,
        ),
        _ActionCard(
          icon: Icons.help_outline_rounded,
          title: 'What is CID?',
          body: 'CID is your Cidentia identity across the ecosystem.',
          color: const Color(0xFFA855F7),
          onTap: () {},
        ),
      ],
    );
  }
}

class _ResultGrid extends StatelessWidget {
  const _ResultGrid({
    required this.language,
    required this.result,
    required this.showDetails,
    required this.onToggleDetails,
    required this.onCidentiaApp,
    required this.onEnter,
  });

  final CidentiaUiLanguage language;
  final _EntryResult result;
  final bool showDetails;
  final VoidCallback onToggleDetails;
  final VoidCallback onCidentiaApp;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    final color = switch (result.kind) {
      _EntryResultKind.verified => const Color(0xFF22C55E),
      _EntryResultKind.onboarding => const Color(0xFFF59E0B),
      _EntryResultKind.invalid => const Color(0xFFEF4444),
      _EntryResultKind.unavailable => const Color(0xFF3B82F6),
      _ => const Color(0xFF8B5CF6),
    };

    return _GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verification status',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          _StatusCard(
            color: color,
            title: result.title,
            body: result.message,
            code: result.code,
            actionLabel: result.kind == _EntryResultKind.verified
                ? 'Go to Feed'
                : result.kind == _EntryResultKind.onboarding
                ? language.continueCidentiaApp
                : result.kind == _EntryResultKind.invalid
                ? language.requestOtp
                : 'Try Again',
            onAction: result.kind == _EntryResultKind.verified
                ? onEnter
                : result.kind == _EntryResultKind.onboarding
                ? onCidentiaApp
                : () {},
          ),
          TextButton.icon(
            onPressed: onToggleDetails,
            icon: Icon(showDetails ? Icons.expand_less : Icons.expand_more),
            label: Text(language.technicalDetails),
          ),
          if (showDetails)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                result.details.isEmpty
                    ? '${result.code}\nsessionCreated:false'
                    : result.details,
                style: const TextStyle(
                  color: Color(0xFF86EFAC),
                  fontFamily: 'monospace',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 40,
            color: Colors.black54,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.16),
      child: Icon(icon, color: color),
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  const _FeatureBadge({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon),
      label: Text(title),
      side: const BorderSide(color: Colors.white12),
      backgroundColor: Colors.white.withValues(alpha: 0.06),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 330,
      child: _GlassCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconBubble(icon: icon, color: color),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(body, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(title),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.color,
    required this.title,
    required this.body,
    required this.code,
    required this.actionLabel,
    required this.onAction,
  });

  final Color color;
  final String title;
  final String body;
  final String code;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user_outlined, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(body),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks({required this.language});

  final CidentiaUiLanguage language;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: const Text('How it works?'),
      children: [
        Text(
          '${language.appTitle} uses CidenDB for identity verification. If a CID is missing, CidentiaApp completes onboarding.',
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.language});

  final CidentiaUiLanguage language;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.security_rounded, color: Color(0xFF38BDF8)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '${language.appTitle} is part of the Cidentia ecosystem. Powered by CidenDB.',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
