import 'dart:convert';

import 'package:http/http.dart' as http;

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

  static const _bridgeOrigin = String.fromEnvironment(
    'CIDENTIA_CIDENDB_BRIDGE_ORIGIN',
    defaultValue: 'http://127.0.0.1:8787',
  );

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

    try {
      final response = await http.post(
        Uri.parse('$_bridgeOrigin/api/cidendb/otp/send'),
        headers: const {'content-type': 'application/json'},
        body: jsonEncode({'identifier': clean}),
      );

      final data = _decode(response.body);
      final ok =
          response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data['ok'] == true;

      return CidenDbOtpRequestResult(
        ok: ok,
        message: _messageFrom(data, 'OTP request processed.'),
      );
    } catch (_) {
      return const CidenDbOtpRequestResult(
        ok: false,
        message:
            'CidenDB bridge is not reachable. Start the secure local bridge and try again.',
      );
    }
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

    try {
      final response = await http.post(
        Uri.parse('$_bridgeOrigin/api/cidendb/otp/verify'),
        headers: const {'content-type': 'application/json'},
        body: jsonEncode({'identifier': cleanIdentifier, 'otp': cleanOtp}),
      );

      final data = _decode(response.body);
      final session = _sessionFrom(data, cleanIdentifier);
      final ok =
          response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data['ok'] == true &&
          session.hasVerifiedCid;

      return CidenDbOtpVerifyResult(
        ok: ok,
        session: ok ? session : const CidentiaSessionState.signedOut(),
        message: _messageFrom(
          data,
          ok ? 'CID session verified.' : 'CidenDB OTP verify failed.',
        ),
      );
    } catch (_) {
      return const CidenDbOtpVerifyResult(
        ok: false,
        session: CidentiaSessionState.signedOut(),
        message:
            'CidenDB bridge is not reachable. Start the secure local bridge and try again.',
      );
    }
  }

  static Map<String, dynamic> _decode(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{};
  }

  static String _messageFrom(Map<String, dynamic> data, String fallback) {
    final message = data['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }
    return fallback;
  }

  static CidentiaSessionState _sessionFrom(
    Map<String, dynamic> data,
    String fallbackIdentifier,
  ) {
    final rawSession = data['session'];
    if (rawSession is! Map<String, dynamic>) {
      return const CidentiaSessionState.signedOut();
    }

    final cid = rawSession['cid'];
    if (cid is! String || cid.trim().isEmpty) {
      return const CidentiaSessionState.signedOut();
    }

    return CidentiaSessionState(
      status: CidentiaSessionStatus.signedIn,
      identifier: rawSession['identifier'] is String
          ? rawSession['identifier'] as String
          : fallbackIdentifier,
      cid: cid.trim(),
      displayName: rawSession['displayName'] is String
          ? rawSession['displayName'] as String
          : null,
      message: _messageFrom(data, 'CID session verified.'),
    );
  }
}
