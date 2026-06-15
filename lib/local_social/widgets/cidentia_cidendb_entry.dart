import 'package:flutter/material.dart';

const _entryPanel = Color(0xFF101114);
const _entryLine = Color(0xFF262A33);
const _entrySoft = Color(0xFFA1A1AA);

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
    useSafeArea: true,
    builder: (context) => const _CidenDbEntrySheet(),
  );
}

class _CidenDbEntrySheet extends StatelessWidget {
  const _CidenDbEntrySheet();

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        'Central sign-in boundary',
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
              'This is the reserved CidenDB/CID sign-in entry for Cidentia.Live.',
              style: TextStyle(fontWeight: FontWeight.w800, height: 1.35),
            ),
            const SizedBox(height: 10),
            const Text(
              'No OTP request, backend bridge, fake login, fake CID, frontend token, upload, RTMP, wallet, payment, blockchain or session creation is opened in this milestone.',
              style: TextStyle(color: _entrySoft, height: 1.35),
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
                      'Real CidenDB OTP and verified CID session handoff must be opened later in a separate backend-confirmed milestone.',
                      style: TextStyle(color: Color(0xFFFDE68A), height: 1.35),
                    ),
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
