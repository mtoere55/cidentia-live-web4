import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../auth/cidentia_session_state.dart';

const cidentiaEntryBridgeBaseUrl = String.fromEnvironment(
  'CIDENDB_ENTRY_BRIDGE_BASE_URL',
  defaultValue: 'http://localhost:3000',
);
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
        return 'Cidentia ekosisteminin live / social programÃ„Â±';
      case CidentiaUiLanguage.de:
        return 'Live- / Social-Programm des Cidentia-Ãƒâ€“kosystems';
    }
  }

  String get heroLead {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'Connect, create and go live. Your identity is protected by CidenDB, the official identity databank of the Cidentia ecosystem.';
      case CidentiaUiLanguage.tr:
        return 'BaÃ„Å¸lan, ÃƒÂ¼ret ve canlÃ„Â±ya ÃƒÂ§Ã„Â±k. KimliÃ„Å¸iniz Cidentia ekosisteminin resmi kimlik databankÃ„Â± CidenDB tarafÃ„Â±ndan korunur.';
      case CidentiaUiLanguage.de:
        return 'Verbinden, erstellen und live gehen. Ihre IdentitÃƒÂ¤t wird durch CidenDB geschÃƒÂ¼tzt, die offizielle IdentitÃƒÂ¤tsdatenbank des Cidentia-Ãƒâ€“kosystems.';
    }
  }

  String get signInTitle {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'Sign in with CidenDB';
      case CidentiaUiLanguage.tr:
        return 'CidenDB ile giriÃ…Å¸ yap';
      case CidentiaUiLanguage.de:
        return 'Mit CidenDB anmelden';
    }
  }

  String get signInHelp {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'We will send a 6-digit verification code to your email.';
      case CidentiaUiLanguage.tr:
        return 'E-postanÃ„Â±za 6 haneli bir doÃ„Å¸rulama kodu gÃƒÂ¶ndereceÃ„Å¸iz.';
      case CidentiaUiLanguage.de:
        return 'Wir senden einen 6-stelligen BestÃƒÂ¤tigungscode an Ihre E-Mail.';
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
        return 'DoÃ„Å¸rulama kodu';
      case CidentiaUiLanguage.de:
        return 'BestÃƒÂ¤tigungscode';
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
        return 'Kodu doÃ„Å¸rula';
      case CidentiaUiLanguage.de:
        return 'Code bestÃƒÂ¤tigen';
    }
  }

  String get continueCidentiaApp {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'Go to CidentiaApp';
      case CidentiaUiLanguage.tr:
        return 'CidentiaAppÃ¢â‚¬â„¢a devam et';
      case CidentiaUiLanguage.de:
        return 'Zu CidentiaApp';
    }
  }

  String get exploreGuest {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'Explore without sign-in';
      case CidentiaUiLanguage.tr:
        return 'GiriÃ…Å¸ yapmadan keÃ…Å¸fet';
      case CidentiaUiLanguage.de:
        return 'Ohne Anmeldung entdecken';
    }
  }

  String get cidSetupTitle {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'CID setup required';
      case CidentiaUiLanguage.tr:
        return 'CID tamamlanmasÃ„Â± gerekiyor';
      case CidentiaUiLanguage.de:
        return 'CID-Einrichtung erforderlich';
    }
  }

  String get cidSetupBody {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'Your email is verified, but this account does not have an active CID yet. Complete your identity setup in CidentiaApp before continuing.';
      case CidentiaUiLanguage.tr:
        return 'E-posta doÃ„Å¸rulandÃ„Â±, ancak bu hesap iÃƒÂ§in aktif CID bulunamadÃ„Â±. Devam etmek iÃƒÂ§in CidentiaApp ÃƒÂ¼zerinden kimlik adÃ„Â±mÃ„Â±nÃ„Â± tamamlayÃ„Â±n.';
      case CidentiaUiLanguage.de:
        return 'Ihre E-Mail wurde bestÃƒÂ¤tigt, aber dieses Konto hat noch keine aktive CID. Bitte schlieÃƒÅ¸en Sie die IdentitÃƒÂ¤tseinrichtung in CidentiaApp ab.';
    }
  }

  String get verifiedTitle {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'Verified session ready';
      case CidentiaUiLanguage.tr:
        return 'DoÃ„Å¸rulanmÃ„Â±Ã…Å¸ oturum hazÃ„Â±r';
      case CidentiaUiLanguage.de:
        return 'Verifizierte Sitzung bereit';
    }
  }

  String get verifiedBody {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'Your identity is verified. A safe Cidentia.Live session is ready.';
      case CidentiaUiLanguage.tr:
        return 'KimliÃ„Å¸iniz doÃ„Å¸rulandÃ„Â±. GÃƒÂ¼venli Cidentia.Live oturumu hazÃ„Â±r.';
      case CidentiaUiLanguage.de:
        return 'Ihre IdentitÃƒÂ¤t ist bestÃƒÂ¤tigt. Eine sichere Cidentia.Live-Sitzung ist bereit.';
    }
  }

  String get invalidCodeTitle {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'Invalid code';
      case CidentiaUiLanguage.tr:
        return 'Kod doÃ„Å¸rulanamadÃ„Â±';
      case CidentiaUiLanguage.de:
        return 'UngÃƒÂ¼ltiger Code';
    }
  }

  String get invalidCodeBody {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'The code is incorrect or expired. Please check your email and try again.';
      case CidentiaUiLanguage.tr:
        return 'Kod hatalÃ„Â± veya sÃƒÂ¼resi dolmuÃ…Å¸ olabilir. E-postanÃ„Â±za gelen son kodu kontrol edin.';
      case CidentiaUiLanguage.de:
        return 'Der Code ist falsch oder abgelaufen. Bitte prÃƒÂ¼fen Sie Ihre E-Mail und versuchen Sie es erneut.';
    }
  }

  String get serviceUnavailableTitle {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'Service unavailable';
      case CidentiaUiLanguage.tr:
        return 'Servis kullanÃ„Â±lamÃ„Â±yor';
      case CidentiaUiLanguage.de:
        return 'Dienst nicht verfÃƒÂ¼gbar';
    }
  }

  String get serviceUnavailableBody {
    switch (this) {
      case CidentiaUiLanguage.en:
        return 'CidenDB connection is currently unavailable. Please try again later.';
      case CidentiaUiLanguage.tr:
        return 'CidenDB baÃ„Å¸lantÃ„Â±sÃ„Â± Ã…Å¸u anda kullanÃ„Â±lamÃ„Â±yor. LÃƒÂ¼tfen tekrar deneyin.';
      case CidentiaUiLanguage.de:
        return 'Die CidenDB-Verbindung ist derzeit nicht verfÃƒÂ¼gbar. Bitte versuchen Sie es spÃƒÂ¤ter erneut.';
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

  Future<void> _openExternalUrl(String url) async {
    try {
      if (Platform.isWindows) {
        await Process.run('rundll32', [
          'url.dll,FileProtocolHandler',
          url,
        ], runInShell: true);
      } else if (Platform.isMacOS) {
        await Process.run('open', [url]);
      } else {
        await Process.run('xdg-open', [url]);
      }
    } catch (_) {
      // Local preview only: keep UI responsive even if opening browser fails.
    }
  }

  void _showEntryInfo({
    required String title,
    required String body,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF11131B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
          ),
          title: Text(title),
          content: Text(body, style: const TextStyle(height: 1.45)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            if (actionLabel != null && onAction != null)
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onAction();
                },
                child: Text(actionLabel),
              ),
          ],
        );
      },
    );
  }

  void _showCidInfo() {
    _showEntryInfo(
      title: 'What is CID?',
      body:
          'CID is your verified Cidentia identity. It lets Cidentia.Live know that the user is real, verified and connected to the wider Cidentia ecosystem.',
    );
  }

  void _showCidenDbInfo() {
    _showEntryInfo(
      title: 'Why CidenDB?',
      body:
          'CidenDB is the identity databank of the Cidentia ecosystem. Cidentia.Live accepts verified CID sessions from CidenDB and keeps protected actions locked until the proper production modules are connected.',
    );
  }

  void _openCidentiaApp() {
    _openExternalUrl(cidentiaAppOnboardingUrl);
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
              onCidInfo: _showCidInfo,
              onCidenDbInfo: _showCidenDbInfo,
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
    final language = text;

    return _GlassCard(
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x14138BFF), Color(0x16EC4899), Color(0x06000000)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 460;

              final emailField = _EntryTextField(
                controller: _emailController,
                icon: Icons.mail_outline_rounded,
                hintText: language.emailHint,
                keyboardType: TextInputType.emailAddress,
              );

              final codeField = _EntryTextField(
                controller: _codeController,
                icon: Icons.shield_outlined,
                hintText: language.codeHint,
                keyboardType: TextInputType.number,
              );

              final requestButton = _EntryGradientButton(
                label: language.requestOtp,
                icon: Icons.send_rounded,
                colors: const [Color(0xFFA855F7), Color(0xFFEC4899)],
                onPressed: _busy ? null : _requestOtp,
              );

              final verifyButton = _EntryGradientButton(
                label: language.verifyCode,
                icon: Icons.lock_open_rounded,
                colors: const [Color(0xFF2563EB), Color(0xFF38BDF8)],
                onPressed: _busy ? null : _verifyOtp,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      _IconBubble(
                        icon: Icons.verified_user_outlined,
                        color: Color(0xFF38BDF8),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Sign in with CidenDB',
                          style: TextStyle(
                            fontSize: 30,
                            height: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'CidenDB protects your identity across the Cidentia ecosystem. We will send a 6-digit verification code to your email.',
                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.45,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 26),
                  const _EntryStepLabel(
                    step: 'STEP 1',
                    label: 'Enter your email',
                  ),
                  const SizedBox(height: 8),
                  compact
                      ? Column(
                          children: [
                            emailField,
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: requestButton,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: emailField),
                            const SizedBox(width: 14),
                            SizedBox(width: 168, child: requestButton),
                          ],
                        ),
                  const SizedBox(height: 22),
                  const _EntryStepLabel(
                    step: 'STEP 2',
                    label: 'Enter 6-digit code',
                  ),
                  const SizedBox(height: 8),
                  compact
                      ? Column(
                          children: [
                            codeField,
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: verifyButton,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: codeField),
                            const SizedBox(width: 14),
                            SizedBox(width: 168, child: verifyButton),
                          ],
                        ),
                  const SizedBox(height: 22),
                  const _EntryHowItWorksPanel(),
                  const SizedBox(height: 18),
                  _EntryCtaStrip(
                    title: 'No CID yet?',
                    body: 'Create or complete your identity at CidentiaApp.com',
                    onTap: _openCidentiaApp,
                  ),
                  const SizedBox(height: 12),
                  _EntryTextLink(
                    label: 'Explore public preview without sign-in',
                    onTap: widget.onEnter,
                  ),
                ],
              );
            },
          ),
        ),
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

    final displayName = readText(user, ['display_name', 'full_name', 'name']);

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
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 520;

    return Row(
      children: [
        const _CidentiaLogo(),
        SizedBox(width: compact ? 8 : 12),
        Expanded(
          child: Text(
            compact ? 'Cidentia' : 'cidentia.live',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              fontSize: compact ? 20 : 26,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (width >= 900) ...[
          const SizedBox(width: 16),
          const _EcosystemLinks(),
        ],
        SizedBox(width: compact ? 8 : 16),
        if (compact)
          _CompactLanguageMenu(language: language, onChanged: onLanguageChanged)
        else
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

class _CompactLanguageMenu extends StatelessWidget {
  const _CompactLanguageMenu({required this.language, required this.onChanged});

  final CidentiaUiLanguage language;
  final ValueChanged<CidentiaUiLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<CidentiaUiLanguage>(
      tooltip: 'Language',
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final value in CidentiaUiLanguage.values)
          PopupMenuItem(value: value, child: Text(value.code)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language_rounded, size: 18),
            const SizedBox(width: 6),
            Text(
              language.code,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
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
      padding: EdgeInsets.zero,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(28)),
          gradient: RadialGradient(
            center: Alignment(0.6, -0.2),
            radius: 1.1,
            colors: [Color(0x302563EB), Color(0x12111827), Color(0x00111827)],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 720;

            final copy = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CIDENTIA.LIVE',
                  style: TextStyle(
                    color: Color(0xFFC084FC),
                    fontSize: 14,
                    letterSpacing: 1.8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'One verified identity\nfor social, live and\ncreator space.',
                  style: TextStyle(
                    fontSize: compact ? 40 : 55,
                    height: 1.02,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.4,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Sign in with CidenDB to access Cidentia.Live. Verified CID users get a safe session. No CID yet? We route you to CidentiaApp.com to complete onboarding.',
                  style: TextStyle(
                    color: Colors.white70,
                    height: 1.48,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 28),
                const Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _FeatureBadge(
                      icon: Icons.shield_outlined,
                      title: 'CidenDB verified',
                    ),
                    _FeatureBadge(
                      icon: Icons.visibility_outlined,
                      title: 'Public preview',
                    ),
                    _FeatureBadge(
                      icon: Icons.lock_outline,
                      title: 'Safe session',
                    ),
                  ],
                ),
              ],
            );

            if (compact) {
              return Padding(
                padding: const EdgeInsets.all(26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    copy,
                    const SizedBox(height: 28),
                    const Center(child: _OrbitIdentityVisual(compact: true)),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(34),
              child: Row(
                children: [
                  Expanded(child: copy),
                  const SizedBox(width: 28),
                  const _OrbitIdentityVisual(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OrbitIdentityVisual extends StatelessWidget {
  const _OrbitIdentityVisual({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final width = compact ? 300.0 : 420.0;
    final height = compact ? 300.0 : 360.0;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0x664F46E5),
                    const Color(0x2238BDF8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: compact ? 34 : 58,
            bottom: compact ? 28 : 16,
            child: _NeonPlatform(compact: compact),
          ),
          Positioned(
            left: compact ? 14 : 26,
            top: compact ? 78 : 74,
            child: _HoloCard(
              width: compact ? 128 : 158,
              height: compact ? 186 : 224,
              angle: -0.16,
              title: 'LIVE',
              subtitle: 'Go live securely',
              icon: Icons.live_tv_rounded,
              colors: const [Color(0xFF2563EB), Color(0xFF8B5CF6)],
            ),
          ),
          Positioned(
            right: compact ? 10 : 22,
            top: compact ? 58 : 64,
            child: _HoloCard(
              width: compact ? 138 : 170,
              height: compact ? 196 : 232,
              angle: 0.15,
              title: 'CREATOR',
              subtitle: 'Build and grow',
              icon: Icons.play_circle_outline_rounded,
              colors: const [Color(0xFFF97316), Color(0xFFEC4899)],
            ),
          ),
          Positioned(
            left: compact ? 82 : 120,
            top: compact ? 52 : 50,
            child: _HoloCard(
              width: compact ? 146 : 190,
              height: compact ? 206 : 258,
              angle: 0,
              title: 'Cidentia',
              subtitle: 'Verified identity',
              icon: Icons.verified_user_rounded,
              colors: const [Color(0xFF7C3AED), Color(0xFF22D3EE)],
              primary: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _NeonPlatform extends StatelessWidget {
  const _NeonPlatform({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 230 : 310,
      height: compact ? 70 : 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const RadialGradient(
          colors: [Color(0xAAE879F9), Color(0x5538BDF8), Colors.transparent],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0xAA7C3AED), blurRadius: 46, spreadRadius: 4),
        ],
      ),
    );
  }
}

class _HoloCard extends StatelessWidget {
  const _HoloCard({
    required this.width,
    required this.height,
    required this.angle,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    this.primary = false,
  });

  final double width;
  final double height;
  final double angle;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(primary ? 20 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(primary ? 30 : 26),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.38)),
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: 0.45),
              blurRadius: primary ? 42 : 30,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: primary ? 34 : 26),
            const Spacer(),
            if (primary)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Text(
                  'VERIFIED IDENTITY',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                ),
              ),
            if (primary) const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: primary ? 25 : 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _EntryStepLabel extends StatelessWidget {
  const _EntryStepLabel({required this.step, required this.label});

  final String step;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          step,
          style: const TextStyle(
            color: Color(0xFFC4B5FD),
            fontSize: 11,
            letterSpacing: 1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _EntryTextField extends StatelessWidget {
  const _EntryTextField({
    required this.controller,
    required this.icon,
    required this.hintText,
    required this.keyboardType,
  });

  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.18),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.24)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEC4899), width: 1.4),
        ),
      ),
    );
  }
}

class _EntryGradientButton extends StatelessWidget {
  const _EntryGradientButton({
    required this.label,
    required this.icon,
    required this.colors,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;

    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: colors),
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: 0.32),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EntryHowItWorksPanel extends StatelessWidget {
  const _EntryHowItWorksPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How it works', style: TextStyle(fontWeight: FontWeight.w900)),
          SizedBox(height: 12),
          _EntryNumberedLine(
            number: '1',
            text: 'Enter your email and request a 6-digit code.',
          ),
          _EntryNumberedLine(
            number: '2',
            text: 'Check your inbox and enter the code.',
          ),
          _EntryNumberedLine(
            number: '3',
            text: 'Enter Cidentia.Live with a safe verified session.',
          ),
        ],
      ),
    );
  }
}

class _EntryNumberedLine extends StatelessWidget {
  const _EntryNumberedLine({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xFF7C3AED).withValues(alpha: 0.22),
            child: Text(number, style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}

class _EntryCtaStrip extends StatelessWidget {
  const _EntryCtaStrip({
    required this.title,
    required this.body,
    required this.onTap,
  });

  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0x442563EB), Color(0x337C3AED)],
          ),
          border: Border.all(color: const Color(0xFF7C3AED)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(body, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const CircleAvatar(
              backgroundColor: Color(0xFF2563EB),
              child: Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryTextLink extends StatelessWidget {
  const _EntryTextLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.arrow_forward_rounded),
      label: Text(label),
    );
  }
}

class _VisualCard extends StatelessWidget {
  const _VisualCard({
    required this.width,
    required this.height,
    required this.angle,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });

  final double width;
  final double height;
  final double angle;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.38)),
          boxShadow: const [
            BoxShadow(
              blurRadius: 36,
              color: Colors.black54,
              offset: Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _ActionCards extends StatelessWidget {
  const _ActionCards({
    required this.language,
    required this.onCidentiaApp,
    required this.onExplore,
    required this.onCidInfo,
    required this.onCidenDbInfo,
  });

  final CidentiaUiLanguage language;
  final VoidCallback onCidentiaApp;
  final VoidCallback onExplore;
  final VoidCallback onCidInfo;
  final VoidCallback onCidenDbInfo;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        _ActionCard(
          icon: Icons.person_add_alt_1_rounded,
          title: 'Create your CID at CidentiaApp',
          body:
              'Your email is verified, but this account does not have an active CID yet. Complete your identity setup.',
          action: 'Go to CidentiaApp.com',
          color: const Color(0xFF22C55E),
          onTap: onCidentiaApp,
        ),
        _ActionCard(
          icon: Icons.visibility_outlined,
          title: 'Explore public preview',
          body:
              'Feed, Search, Reels and public live previews are open to everyone.',
          action: 'Explore without sign-in',
          color: const Color(0xFFA855F7),
          onTap: onExplore,
        ),
        _ActionCard(
          icon: Icons.help_outline_rounded,
          title: 'What is CID?',
          body: 'CID is your Cidentia identity across the ecosystem.',
          action: 'Learn more about CID',
          color: const Color(0xFF3B82F6),
          onTap: onCidInfo,
        ),
        _ActionCard(
          icon: Icons.verified_user_outlined,
          title: 'Why CidenDB?',
          body:
              'CidenDB is the official identity databank of the Cidentia ecosystem: secure, private and future-ready.',
          action: 'Learn about CidenDB',
          color: const Color(0xFFEC4899),
          onTap: onCidenDbInfo,
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
    // M5S premium hides idle verification status.
    if (result.kind == _EntryResultKind.idle) {
      return const SizedBox.shrink();
    }

    // M5S-A hide idle verification status.
    if (result.kind == _EntryResultKind.idle) {
      return const SizedBox.shrink();
    }

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
    required this.action,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final String action;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final width = screenWidth < 720 ? screenWidth - 44 : 452.0;

    return SizedBox(
      width: width.clamp(280.0, 452.0),
      child: _GlassCard(
        padding: const EdgeInsets.all(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBubble(icon: icon, color: color),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                body,
                style: const TextStyle(color: Colors.white70, height: 1.35),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      action,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, color: color, size: 18),
                ],
              ),
            ],
          ),
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
