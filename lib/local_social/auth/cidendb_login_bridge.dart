import 'cidentia_session_state.dart';

class CidenDbOtpRequestResult {
  const CidenDbOtpRequestResult({required this.ok, required this.message});

  final bool ok;
  final String message;
}

class CidenDbOtpVerifyResult {
  const CidenDbOtpVerifyResult({
    required this.ok,
    required this.session,
    required this.message,
  });

  final bool ok;
  final CidentiaSessionState session;
  final String message;
}

class CidenDbLoginBridge {
  const CidenDbLoginBridge();

  Future<CidenDbOtpRequestResult> requestOtp({
    required String identifier,
  }) async {
    final clean = identifier.trim();

    if (clean.isEmpty) {
      return const CidenDbOtpRequestResult(
        ok: false,
        message: 'CID, phone or email is required.',
      );
    }

    await Future<void>.delayed(const Duration(milliseconds: 350));

    return CidenDbOtpRequestResult(
      ok: true,
      message:
          'OTP request prepared for $clean. Real CidenDB send endpoint will be connected in the backend bridge.',
    );
  }

  Future<CidenDbOtpVerifyResult> verifyOtp({
    required String identifier,
    required String otp,
  }) async {
    final cleanIdentifier = identifier.trim();
    final cleanOtp = otp.trim();

    if (cleanIdentifier.isEmpty) {
      return const CidenDbOtpVerifyResult(
        ok: false,
        session: CidentiaSessionState.signedOut(),
        message: 'CID, phone or email is required.',
      );
    }

    if (cleanOtp.length < 4) {
      return const CidenDbOtpVerifyResult(
        ok: false,
        session: CidentiaSessionState.signedOut(),
        message: 'OTP code is required.',
      );
    }

    await Future<void>.delayed(const Duration(milliseconds: 450));

    final cid = cleanIdentifier.toUpperCase().startsWith('CID')
        ? cleanIdentifier
        : 'CID-PREVIEW-VERIFIED';

    return CidenDbOtpVerifyResult(
      ok: true,
      session: CidentiaSessionState(
        status: CidentiaSessionStatus.signedIn,
        identifier: cleanIdentifier,
        cid: cid,
        displayName: 'Cidentia Preview User',
        message:
            'Verified CID session prepared locally. Real CidenDB verify endpoint will replace this bridge body.',
      ),
      message:
          'Verified CID session prepared locally. Real CidenDB verify endpoint will replace this bridge body.',
    );
  }
}
