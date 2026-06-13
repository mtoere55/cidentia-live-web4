import 'package:flutter/material.dart';

import '../auth/cidendb_login_bridge.dart';
import '../auth/cidentia_session_scope.dart';
import '../auth/cidentia_session_state.dart';

class CidentiaEcosystemEntryHost extends StatefulWidget {
  const CidentiaEcosystemEntryHost({required this.child, super.key});

  final Widget child;

  @override
  State<CidentiaEcosystemEntryHost> createState() =>
      _CidentiaEcosystemEntryHostState();
}

class _CidentiaEcosystemEntryHostState
    extends State<CidentiaEcosystemEntryHost> {
  final _identifierController = TextEditingController();
  final _otpController = TextEditingController();

  var _session = const CidentiaSessionState.signedOut();
  var _enteredPublicContent = false;
  var _busy = false;
  var _statusMessage =
      'CID, telefon veya e-posta yaz. OTP iste, sonra gelen kodu doğrula.';

  @override
  void dispose() {
    _identifierController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _enterPublicContent() {
    setState(() => _enteredPublicContent = true);
  }

  void _showPendingBridge(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title - $message'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _requestOtp() async {
    if (_busy) return;

    setState(() {
      _busy = true;
      _statusMessage = 'CidenDB OTP isteniyor...';
    });

    final result = await const CidenDbLoginBridge().requestOtp(
      identifier: _identifierController.text,
    );

    if (!mounted) return;

    setState(() {
      _busy = false;
      _statusMessage = result.message;
    });
  }

  Future<void> _verifyOtp() async {
    if (_busy) return;

    setState(() {
      _busy = true;
      _statusMessage = 'CID oturumu doğrulanıyor...';
    });

    final result = await const CidenDbLoginBridge().verifyOtp(
      identifier: _identifierController.text,
      otp: _otpController.text,
    );

    if (!mounted) return;

    if (result.ok && result.session.hasVerifiedCid) {
      setState(() {
        _session = result.session;
        _enteredPublicContent = true;
        _statusMessage = result.message;
      });
      return;
    }

    setState(() {
      _busy = false;
      _statusMessage = result.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_enteredPublicContent || _session.hasVerifiedCid) {
      return CidentiaSessionScope(session: _session, child: widget.child);
    }

    return _CidentiaCleanEntryPage(
      identifierController: _identifierController,
      otpController: _otpController,
      busy: _busy,
      statusMessage: _statusMessage,
      onRequestOtp: _requestOtp,
      onVerifyOtp: _verifyOtp,
      onExplorePublicContent: _enterPublicContent,
      onStartWithCidentiaApp: () => _showPendingBridge(
        'CidentiaApp',
        'CID kaydı olmayan kullanıcı onboarding/kayıt için CidentiaApp akışına yönlendirilecek.',
      ),
      onNeedHelp: () => _showPendingBridge(
        'info@cidentia.live',
        'Destek bağlantısı daha sonra mail/link akışına bağlanacak.',
      ),
    );
  }
}

class _CidentiaCleanEntryPage extends StatelessWidget {
  const _CidentiaCleanEntryPage({
    required this.identifierController,
    required this.otpController,
    required this.busy,
    required this.statusMessage,
    required this.onRequestOtp,
    required this.onVerifyOtp,
    required this.onExplorePublicContent,
    required this.onStartWithCidentiaApp,
    required this.onNeedHelp,
  });

  final TextEditingController identifierController;
  final TextEditingController otpController;
  final bool busy;
  final String statusMessage;
  final VoidCallback onRequestOtp;
  final VoidCallback onVerifyOtp;
  final VoidCallback onExplorePublicContent;
  final VoidCallback onStartWithCidentiaApp;
  final VoidCallback onNeedHelp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;

          final content = isDesktop
              ? Row(
                  children: [
                    Expanded(
                      child: _EntryHero(onExplore: onExplorePublicContent),
                    ),
                    SizedBox(
                      width: 520,
                      child: _EntrySignInPanel(
                        identifierController: identifierController,
                        otpController: otpController,
                        busy: busy,
                        statusMessage: statusMessage,
                        onRequestOtp: onRequestOtp,
                        onVerifyOtp: onVerifyOtp,
                        onExplorePublicContent: onExplorePublicContent,
                        onStartWithCidentiaApp: onStartWithCidentiaApp,
                        onNeedHelp: onNeedHelp,
                      ),
                    ),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                  children: [
                    _EntryHero(onExplore: onExplorePublicContent),
                    const SizedBox(height: 20),
                    _EntrySignInPanel(
                      identifierController: identifierController,
                      otpController: otpController,
                      busy: busy,
                      statusMessage: statusMessage,
                      onRequestOtp: onRequestOtp,
                      onVerifyOtp: onVerifyOtp,
                      onExplorePublicContent: onExplorePublicContent,
                      onStartWithCidentiaApp: onStartWithCidentiaApp,
                      onNeedHelp: onNeedHelp,
                    ),
                  ],
                );

          return DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.25,
                colors: [
                  Color(0xFF1E1B4B),
                  Color(0xFF020617),
                  Color(0xFF020617),
                ],
              ),
            ),
            child: SafeArea(child: content),
          );
        },
      ),
    );
  }
}

class _EntryHero extends StatelessWidget {
  const _EntryHero({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(44, 42, 34, 42),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BrandLine(),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
              ),
            ),
            child: const Text(
              'CidenDB verified CID session',
              style: TextStyle(
                color: Color(0xFFBAE6FD),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Cidentia.Live',
            style: TextStyle(
              fontSize: 64,
              height: 0.95,
              fontWeight: FontWeight.w900,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Public Feed, Search and Reels stay open. Chats, Live Studio, Profile, wallet, proof, upload and creator tools require a verified CidenDB/CID session.',
            style: TextStyle(
              color: Color(0xFFD1D5DB),
              height: 1.45,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 26),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _FeaturePill('Feed public'),
              _FeaturePill('Reels public'),
              _FeaturePill('Studio protected'),
              _FeaturePill('Chats protected'),
              _FeaturePill('CID required'),
            ],
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: onExplore,
            icon: const Icon(Icons.public_rounded),
            label: const Text('Explore public content'),
          ),
          const Spacer(),
          const Text(
            'Identity authority: CidenDB. Onboarding authority: CidentiaApp.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _EntrySignInPanel extends StatelessWidget {
  const _EntrySignInPanel({
    required this.identifierController,
    required this.otpController,
    required this.busy,
    required this.statusMessage,
    required this.onRequestOtp,
    required this.onVerifyOtp,
    required this.onExplorePublicContent,
    required this.onStartWithCidentiaApp,
    required this.onNeedHelp,
  });

  final TextEditingController identifierController;
  final TextEditingController otpController;
  final bool busy;
  final String statusMessage;
  final VoidCallback onRequestOtp;
  final VoidCallback onVerifyOtp;
  final VoidCallback onExplorePublicContent;
  final VoidCallback onStartWithCidentiaApp;
  final VoidCallback onNeedHelp;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 28, 34, 28),
        child: Container(
          padding: const EdgeInsets.fromLTRB(30, 28, 30, 26),
          decoration: BoxDecoration(
            color: const Color(0xFF020617).withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0xAA000000),
                blurRadius: 36,
                offset: Offset(0, 24),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(Icons.verified_user_rounded, color: Color(0xFF34D399)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'CidenDB sign-in',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Already have a CID?',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in with your CID, phone or email. Cidentia.Live accepts only CidenDB verified CID sessions for protected actions.',
                style: TextStyle(color: Color(0xFFD1D5DB), height: 1.45),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: identifierController,
                enabled: !busy,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.badge_outlined),
                  labelText: 'CID / phone / email',
                  hintText: 'email@example.com',
                  filled: true,
                  fillColor: Color(0x141E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: otpController,
                enabled: !busy,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.password_rounded),
                  labelText: 'OTP code',
                  hintText: 'CidenDB code',
                  filled: true,
                  fillColor: Color(0x141E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Text(
                  statusMessage,
                  style: const TextStyle(
                    color: Color(0xFFD1D5DB),
                    height: 1.35,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: busy ? null : onRequestOtp,
                icon: const Icon(Icons.sms_outlined),
                label: const Text('Request OTP from CidenDB'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: busy ? null : onVerifyOtp,
                icon: const Icon(Icons.login_rounded),
                label: const Text('Verify and continue'),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF34D399).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF34D399).withValues(alpha: 0.28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'No CID yet?',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Start onboarding with CidentiaApp. CidenDB creates and owns the CID identity record.',
                      style: TextStyle(color: Color(0xFFD1D5DB), height: 1.35),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: busy ? null : onStartWithCidentiaApp,
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('Start with CidentiaApp'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: busy ? null : onExplorePublicContent,
                icon: const Icon(Icons.public_rounded),
                label: const Text('Continue without sign-in'),
              ),
              TextButton.icon(
                onPressed: busy ? null : onNeedHelp,
                icon: const Icon(Icons.help_outline_rounded),
                label: const Text('Need help? info@cidentia.live'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandLine extends StatelessWidget {
  const _BrandLine();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.podcasts_rounded, color: Color(0xFF60A5FA)),
        SizedBox(width: 10),
        Text(
          'CIDENTIA',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(width: 9),
        CircleAvatar(radius: 4, backgroundColor: Color(0xFFEC4899)),
        SizedBox(width: 5),
        Text(
          'LIVE',
          style: TextStyle(
            color: Color(0xFFEC4899),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.3,
          ),
        ),
      ],
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFE5E7EB),
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
