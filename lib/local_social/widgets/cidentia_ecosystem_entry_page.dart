import 'dart:ui';

import 'package:flutter/material.dart';

enum _EntryPanelMode { welcome, otp }

class CidentiaEcosystemEntryHost extends StatefulWidget {
  const CidentiaEcosystemEntryHost({required this.child, super.key});

  final Widget child;

  @override
  State<CidentiaEcosystemEntryHost> createState() =>
      _CidentiaEcosystemEntryHostState();
}

class _CidentiaEcosystemEntryHostState extends State<CidentiaEcosystemEntryHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  var _enteredPublicContent = false;
  var _panelMode = _EntryPanelMode.welcome;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _enterPublicContent() {
    setState(() => _enteredPublicContent = true);
  }

  void _openOtpPanel() {
    setState(() => _panelMode = _EntryPanelMode.otp);
  }

  void _closeOtpPanel() {
    setState(() => _panelMode = _EntryPanelMode.welcome);
  }

  void _showPendingBridge(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title — $message'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_enteredPublicContent) return widget.child;

    return CidentiaEcosystemEntryPage(
      animation: _controller,
      panelMode: _panelMode,
      onExplorePublicContent: _enterPublicContent,
      onSignInWithCidenDb: _openOtpPanel,
      onCloseOtpPanel: _closeOtpPanel,
      onStartWithCidentiaApp: () => _showPendingBridge(
        'CidentiaApp.com',
        'CID kaydı olmayan kullanıcı onboarding/kayıt için CidentiaApp tarafına yönlendirilecek.',
      ),
      onNeedHelp: () => _showPendingBridge(
        'info@cidentia.live',
        'Destek bağlantısı daha sonra mail/link akışına bağlanacak.',
      ),
      onRequestOtp: () => _showPendingBridge(
        'CidenDB OTP',
        'Gerçek OTP send/verify köprüsü M4B aşamasında bağlanacak.',
      ),
    );
  }
}

class CidentiaEcosystemEntryPage extends StatelessWidget {
  const CidentiaEcosystemEntryPage({
    required this.animation,
    required this.panelMode,
    required this.onExplorePublicContent,
    required this.onSignInWithCidenDb,
    required this.onStartWithCidentiaApp,
    required this.onNeedHelp,
    required this.onCloseOtpPanel,
    required this.onRequestOtp,
    super.key,
  });

  final Animation<double> animation;
  final _EntryPanelMode panelMode;
  final VoidCallback onExplorePublicContent;
  final VoidCallback onSignInWithCidenDb;
  final VoidCallback onStartWithCidentiaApp;
  final VoidCallback onNeedHelp;
  final VoidCallback onCloseOtpPanel;
  final VoidCallback onRequestOtp;

  static const _assetPath = 'assets/images/cidentia_ecosystem_entry.png';
  static const _designWidth = 1672.0;
  static const _designHeight = 941.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 720) {
            return _MobileCidentiaEntry(
              animation: animation,
              panelMode: panelMode,
              onExplorePublicContent: onExplorePublicContent,
              onSignInWithCidenDb: onSignInWithCidenDb,
              onStartWithCidentiaApp: onStartWithCidentiaApp,
              onNeedHelp: onNeedHelp,
              onCloseOtpPanel: onCloseOtpPanel,
              onRequestOtp: onRequestOtp,
            );
          }

          final scale = _coverScale(
            Size(constraints.maxWidth, constraints.maxHeight),
          );
          final renderedWidth = _designWidth * scale;
          final renderedHeight = _designHeight * scale;
          final left = (constraints.maxWidth - renderedWidth) / 2;
          final top = (constraints.maxHeight - renderedHeight) / 2;

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  _assetPath,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              Positioned(
                left: left,
                top: top,
                width: renderedWidth,
                height: renderedHeight,
                child: AnimatedBuilder(
                  animation: animation,
                  builder: (context, _) {
                    return IgnorePointer(
                      child: CustomPaint(
                        painter: _CidentiaEntryPulsePainter(animation.value),
                      ),
                    );
                  },
                ),
              ),

              if (panelMode == _EntryPanelMode.welcome) ...[
                _EntryHotspot(
                  left: left,
                  top: top,
                  scale: scale,
                  rect: const Rect.fromLTWH(1030, 350, 560, 92),
                  tooltip: 'Sign in with CidenDB',
                  onTap: onSignInWithCidenDb,
                ),
                _EntryHotspot(
                  left: left,
                  top: top,
                  scale: scale,
                  rect: const Rect.fromLTWH(1030, 500, 560, 58),
                  tooltip: 'Start with CidentiaApp',
                  onTap: onStartWithCidentiaApp,
                ),
                _EntryHotspot(
                  left: left,
                  top: top,
                  scale: scale,
                  rect: const Rect.fromLTWH(1030, 562, 560, 58),
                  tooltip: 'Explore public content',
                  onTap: onExplorePublicContent,
                ),
                _EntryHotspot(
                  left: left,
                  top: top,
                  scale: scale,
                  rect: const Rect.fromLTWH(1030, 624, 560, 58),
                  tooltip: 'Need help',
                  onTap: onNeedHelp,
                ),
              ],

              if (panelMode == _EntryPanelMode.otp)
                _EntryOverlayPanel(
                  left: left,
                  top: top,
                  scale: scale,
                  rect: const Rect.fromLTWH(985, 92, 630, 765),
                  child: _CidenDbOtpPanel(
                    onClose: onCloseOtpPanel,
                    onRequestOtp: onRequestOtp,
                    onStartWithCidentiaApp: onStartWithCidentiaApp,
                    onExplorePublicContent: onExplorePublicContent,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  double _coverScale(Size viewport) {
    final scaleX = viewport.width / _designWidth;
    final scaleY = viewport.height / _designHeight;
    return scaleX > scaleY ? scaleX : scaleY;
  }
}

class _CidenDbOtpPanel extends StatelessWidget {
  const _CidenDbOtpPanel({
    required this.onClose,
    required this.onRequestOtp,
    required this.onStartWithCidentiaApp,
    required this.onExplorePublicContent,
  });

  final VoidCallback onClose;
  final VoidCallback onRequestOtp;
  final VoidCallback onStartWithCidentiaApp;
  final VoidCallback onExplorePublicContent;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(34),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(34, 28, 34, 28),
          decoration: BoxDecoration(
            color: const Color(0xEE06111F),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x99000000),
                blurRadius: 40,
                offset: Offset(0, 24),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.security_rounded,
                      color: Color(0xFF34D399),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'CidenDB verified sign-in',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Back',
                      onPressed: onClose,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Already have a CID?',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sign in with your CID, phone or email. Cidentia.Live accepts only CidenDB verified CID sessions for protected actions.',
                    style: TextStyle(color: Color(0xFFD1D5DB), height: 1.45),
                  ),
                ),
                const SizedBox(height: 24),
                const _OtpInputBox(
                  icon: Icons.badge_outlined,
                  label: 'CID / phone / email',
                  hint: 'CID-0000... or email@example.com',
                ),
                const SizedBox(height: 12),
                const _OtpInputBox(
                  icon: Icons.password_rounded,
                  label: 'OTP code',
                  hint: 'Enter code after request',
                ),
                const SizedBox(height: 20),
                _PrimaryActionButton(
                  icon: Icons.sms_outlined,
                  label: 'Request OTP from CidenDB',
                  onTap: onRequestOtp,
                ),
                const SizedBox(height: 12),
                _SecondaryActionButton(
                  icon: Icons.login_rounded,
                  label: 'Verify and continue',
                  onTap: onRequestOtp,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34D399).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFF34D399).withValues(alpha: 0.32),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: Color(0xFF34D399),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'No CID yet? Start registration and onboarding with CidentiaApp. CidenDB creates and owns the CID identity record.',
                          style: TextStyle(height: 1.35),
                        ),
                      ),
                      TextButton(
                        onPressed: onStartWithCidentiaApp,
                        child: const Text('CidentiaApp'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: onExplorePublicContent,
                  icon: const Icon(Icons.public_rounded),
                  label: const Text('Continue without sign-in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpInputBox extends StatelessWidget {
  const _OtpInputBox({
    required this.icon,
    required this.label,
    required this.hint,
  });

  final IconData icon;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: false,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.045),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0EA5E9), Color(0xFF7C3AED)],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        side: const BorderSide(color: Colors.white24),
      ),
    );
  }
}

class _MobileCidentiaEntry extends StatelessWidget {
  const _MobileCidentiaEntry({
    required this.animation,
    required this.panelMode,
    required this.onExplorePublicContent,
    required this.onSignInWithCidenDb,
    required this.onStartWithCidentiaApp,
    required this.onNeedHelp,
    required this.onCloseOtpPanel,
    required this.onRequestOtp,
  });

  final Animation<double> animation;
  final _EntryPanelMode panelMode;
  final VoidCallback onExplorePublicContent;
  final VoidCallback onSignInWithCidenDb;
  final VoidCallback onStartWithCidentiaApp;
  final VoidCallback onNeedHelp;
  final VoidCallback onCloseOtpPanel;
  final VoidCallback onRequestOtp;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            CidentiaEcosystemEntryPage._assetPath,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF020617).withValues(alpha: 0.70),
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: const SizedBox.expand(),
          ),
        ),
        SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: panelMode == _EntryPanelMode.otp
                ? _MobileOtpPanel(
                    key: const ValueKey('mobile-otp'),
                    onClose: onCloseOtpPanel,
                    onRequestOtp: onRequestOtp,
                    onStartWithCidentiaApp: onStartWithCidentiaApp,
                    onExplorePublicContent: onExplorePublicContent,
                  )
                : _MobileWelcomePanel(
                    key: const ValueKey('mobile-welcome'),
                    animation: animation,
                    onExplorePublicContent: onExplorePublicContent,
                    onSignInWithCidenDb: onSignInWithCidenDb,
                    onStartWithCidentiaApp: onStartWithCidentiaApp,
                    onNeedHelp: onNeedHelp,
                  ),
          ),
        ),
      ],
    );
  }
}

class _MobileWelcomePanel extends StatelessWidget {
  const _MobileWelcomePanel({
    required this.animation,
    required this.onExplorePublicContent,
    required this.onSignInWithCidenDb,
    required this.onStartWithCidentiaApp,
    required this.onNeedHelp,
    super.key,
  });

  final Animation<double> animation;
  final VoidCallback onExplorePublicContent;
  final VoidCallback onSignInWithCidenDb;
  final VoidCallback onStartWithCidentiaApp;
  final VoidCallback onNeedHelp;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF38BDF8)],
                ),
              ),
              child: const Center(
                child: Text(
                  'C',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CIDENTIA',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(
                    'One Identity. Infinite Possibilities.',
                    style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.language_rounded, size: 17),
                  SizedBox(width: 6),
                  Text('EN', style: TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 34),
        const Text(
          'Welcome to the',
          style: TextStyle(fontSize: 34, height: 0.95),
        ),
        const Text(
          'Cidentia Ecosystem',
          style: TextStyle(
            fontSize: 38,
            height: 1.05,
            fontWeight: FontWeight.w900,
            color: Color(0xFF60A5FA),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'A connected Web4 ecosystem for identity, truth, data, social interaction, and real-world integrations.',
          style: TextStyle(color: Color(0xFFD1D5DB), height: 1.45),
        ),
        const SizedBox(height: 28),
        _MobileGlassPanel(
          child: Column(
            children: [
              const _MobileLiveBadge(),
              const SizedBox(height: 22),
              AnimatedBuilder(
                animation: animation,
                builder: (context, _) {
                  final glow =
                      0.45 +
                      (animation.value < 0.5
                          ? animation.value
                          : 1 - animation.value);
                  return Text(
                    'Cidentia.Live',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF60A5FA),
                      shadows: [
                        Shadow(
                          color: const Color(
                            0xFF8B5CF6,
                          ).withValues(alpha: glow),
                          blurRadius: 26,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              const Text(
                'Live. Connect. Verify. Belong.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFD1D5DB)),
              ),
              const SizedBox(height: 24),
              _MobilePrimaryButton(
                icon: Icons.verified_user_outlined,
                label: 'Sign in with CidenDB',
                onTap: onSignInWithCidenDb,
              ),
              const SizedBox(height: 12),
              _MobileOptionButton(
                icon: Icons.person_outline_rounded,
                label: 'New here? Start with CidentiaApp',
                onTap: onStartWithCidentiaApp,
              ),
              const SizedBox(height: 10),
              _MobileOptionButton(
                icon: Icons.public_rounded,
                label: 'Explore public content',
                onTap: onExplorePublicContent,
              ),
              const SizedBox(height: 10),
              _MobileOptionButton(
                icon: Icons.help_outline_rounded,
                label: 'Need help? info@cidentia.live',
                onTap: onNeedHelp,
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF34D399).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF34D399).withValues(alpha: 0.34),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.security_rounded, color: Color(0xFF34D399)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Verified CID session required for protected actions.',
                        style: TextStyle(height: 1.3),
                      ),
                    ),
                    Icon(Icons.fingerprint_rounded, color: Color(0xFF34D399)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Browse public content freely. Sign in to go live, upload, message, connect wallet, manage profile, and access CID features.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFA1A1AA), height: 1.35),
        ),
      ],
    );
  }
}

class _MobileOtpPanel extends StatelessWidget {
  const _MobileOtpPanel({
    required this.onClose,
    required this.onRequestOtp,
    required this.onStartWithCidentiaApp,
    required this.onExplorePublicContent,
    super.key,
  });

  final VoidCallback onClose;
  final VoidCallback onRequestOtp;
  final VoidCallback onStartWithCidentiaApp;
  final VoidCallback onExplorePublicContent;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Back',
              onPressed: onClose,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const Expanded(
              child: Text(
                'CidenDB sign-in',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 18),
        _MobileGlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.security_rounded,
                color: Color(0xFF34D399),
                size: 42,
              ),
              const SizedBox(height: 16),
              const Text(
                'Already have a CID?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in with your CID, phone or email. Cidentia.Live accepts only CidenDB verified CID sessions for protected actions.',
                style: TextStyle(color: Color(0xFFD1D5DB), height: 1.45),
              ),
              const SizedBox(height: 22),
              const _OtpInputBox(
                icon: Icons.badge_outlined,
                label: 'CID / phone / email',
                hint: 'CID-0000... or email@example.com',
              ),
              const SizedBox(height: 12),
              const _OtpInputBox(
                icon: Icons.password_rounded,
                label: 'OTP code',
                hint: 'Enter code after request',
              ),
              const SizedBox(height: 18),
              _MobilePrimaryButton(
                icon: Icons.sms_outlined,
                label: 'Request OTP from CidenDB',
                onTap: onRequestOtp,
              ),
              const SizedBox(height: 12),
              _MobileOptionButton(
                icon: Icons.login_rounded,
                label: 'Verify and continue',
                onTap: onRequestOtp,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF34D399).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF34D399).withValues(alpha: 0.34),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'No CID yet?',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Start registration and onboarding with CidentiaApp. CidenDB creates and owns the CID identity record.',
                      style: TextStyle(height: 1.35),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: onStartWithCidentiaApp,
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('Start with CidentiaApp'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: onExplorePublicContent,
                  icon: const Icon(Icons.public_rounded),
                  label: const Text('Continue without sign-in'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MobileGlassPanel extends StatelessWidget {
  const _MobileGlassPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xEE06111F),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.28),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _MobilePrimaryButton extends StatelessWidget {
  const _MobilePrimaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0EA5E9), Color(0xFF7C3AED)],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const SizedBox(width: 18),
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
            const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }
}

class _MobileOptionButton extends StatelessWidget {
  const _MobileOptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        alignment: Alignment.centerLeft,
        side: const BorderSide(color: Colors.white24),
      ),
    );
  }
}

class _MobileLiveBadge extends StatelessWidget {
  const _MobileLiveBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.podcasts_rounded, color: Color(0xFF8B5CF6)),
            SizedBox(width: 8),
            Text('Cidentia.Live'),
            SizedBox(width: 10),
            CircleAvatar(radius: 4, backgroundColor: Color(0xFFEC4899)),
            SizedBox(width: 5),
            Text(
              'LIVE',
              style: TextStyle(
                color: Color(0xFFEC4899),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryOverlayPanel extends StatelessWidget {
  const _EntryOverlayPanel({
    required this.left,
    required this.top,
    required this.scale,
    required this.rect,
    required this.child,
  });

  final double left;
  final double top;
  final double scale;
  final Rect rect;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left + rect.left * scale,
      top: top + rect.top * scale,
      width: rect.width * scale,
      height: rect.height * scale,
      child: child,
    );
  }
}

class _EntryHotspot extends StatelessWidget {
  const _EntryHotspot({
    required this.left,
    required this.top,
    required this.scale,
    required this.rect,
    required this.tooltip,
    required this.onTap,
  });

  final double left;
  final double top;
  final double scale;
  final Rect rect;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left + rect.left * scale,
      top: top + rect.top * scale,
      width: rect.width * scale,
      height: rect.height * scale,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18 * scale),
            splashColor: Colors.white.withValues(alpha: 0.08),
            hoverColor: Colors.white.withValues(alpha: 0.035),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

class _CidentiaEntryPulsePainter extends CustomPainter {
  const _CidentiaEntryPulsePainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final titleSweepPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF60A5FA).withValues(alpha: 0.18),
          Colors.transparent,
        ],
        stops: const [0, 0.5, 1],
      ).createShader(Rect.fromLTWH(1070 + progress * 260, 236, 230, 70));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(1080, 230, 380, 82),
        const Radius.circular(32),
      ),
      titleSweepPaint,
    );

    final hubPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final pulse = 70 + progress * 42;
    canvas.drawCircle(const Offset(468, 530), pulse, hubPaint);
    canvas.drawCircle(
      const Offset(468, 530),
      42 + (1 - progress) * 36,
      Paint()
        ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final buttonGlow = Paint()
      ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(1030, 350, 560, 92),
        const Radius.circular(18),
      ),
      buttonGlow,
    );
  }

  @override
  bool shouldRepaint(covariant _CidentiaEntryPulsePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
