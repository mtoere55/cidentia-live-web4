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

    return CidenDbOtpRequestResult(
      ok: false,
      message:
          'CidenDB OTP send is reserved for the safe backend bridge. '
          'No OTP is generated or sent by the Flutter client.',
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

    return const CidenDbOtpVerifyResult(
      ok: false,
      session: CidentiaSessionState.signedOut(),
      message:
          'CidenDB OTP verify is reserved for the safe backend bridge. '
          'Flutter does not create a fake verified CID session.',
    );
  }
}
