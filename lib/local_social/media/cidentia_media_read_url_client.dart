import 'dart:async';
import 'dart:convert';
import 'dart:io';

const cidentiaMediaApiBaseUrl = String.fromEnvironment(
  'CIDENTIA_LIVE_API_BASE_URL',
  defaultValue: 'https://api.cidentia.live',
);

class CidentiaSignedMediaReadUrlResult {
  const CidentiaSignedMediaReadUrlResult({
    required this.ok,
    required this.code,
    required this.signedMediaReadUrl,
    required this.signedMediaReadUrlCreated,
    required this.expiresInSeconds,
    required this.httpStatus,
    required this.storageBucketExposed,
    required this.storageObjectKeyExposed,
    required this.secretsExposed,
  });

  final bool ok;
  final String code;
  final String? signedMediaReadUrl;
  final bool signedMediaReadUrlCreated;
  final int? expiresInSeconds;
  final int? httpStatus;
  final bool storageBucketExposed;
  final bool storageObjectKeyExposed;
  final bool secretsExposed;

  bool get canPlay =>
      ok &&
      signedMediaReadUrlCreated &&
      signedMediaReadUrl != null &&
      signedMediaReadUrl!.isNotEmpty &&
      !storageBucketExposed &&
      !storageObjectKeyExposed &&
      !secretsExposed;

  @override
  String toString() {
    return 'CidentiaSignedMediaReadUrlResult('
        'ok: $ok, '
        'code: $code, '
        'signedMediaReadUrlPresentHidden: ${signedMediaReadUrl != null && signedMediaReadUrl!.isNotEmpty}, '
        'signedMediaReadUrlCreated: $signedMediaReadUrlCreated, '
        'expiresInSeconds: $expiresInSeconds, '
        'httpStatus: $httpStatus, '
        'storageBucketExposed: $storageBucketExposed, '
        'storageObjectKeyExposed: $storageObjectKeyExposed, '
        'secretsExposed: $secretsExposed'
        ')';
  }
}

class CidentiaMediaReadUrlClient {
  const CidentiaMediaReadUrlClient({this.baseUrl = cidentiaMediaApiBaseUrl});

  final String baseUrl;

  Future<CidentiaSignedMediaReadUrlResult> requestSignedReadUrl({
    required String mediaAssetId,
    required String cid,
    Duration timeout = const Duration(seconds: 6),
  }) async {
    final safeMediaAssetId = mediaAssetId.trim();
    final safeCid = cid.trim();

    if (safeMediaAssetId.isEmpty) {
      return _locked('MEDIA_ASSET_ID_REQUIRED');
    }

    if (safeCid.isEmpty) {
      return _locked('CID_REQUIRED_FOR_MEDIA_READ_URL');
    }

    final endpoint = Uri.parse('$baseUrl/api/media/read-url');
    final client = HttpClient();

    try {
      final request = await client.postUrl(endpoint).timeout(timeout);
      request.headers.contentType = ContentType.json;
      request.headers.set('x-cidentia-cid', safeCid);
      request.write(jsonEncode({'id': safeMediaAssetId}));

      final response = await request.close().timeout(timeout);
      final body = await response
          .transform(utf8.decoder)
          .join()
          .timeout(timeout);
      final decoded = jsonDecode(body);

      if (decoded is! Map<String, dynamic>) {
        return _locked(
          'SIGNED_MEDIA_READ_URL_UNKNOWN_RESPONSE',
          httpStatus: response.statusCode,
        );
      }

      final mediaAsset = decoded['mediaAsset'];
      final storageBucketExposed =
          decoded.containsKey('storageBucket') ||
          decoded.containsKey('storage_bucket') ||
          decoded['storageBucketExposed'] == true ||
          (mediaAsset is Map &&
              (mediaAsset.containsKey('storageBucket') ||
                  mediaAsset.containsKey('storage_bucket')));

      final storageObjectKeyExposed =
          decoded.containsKey('storageObjectKey') ||
          decoded.containsKey('storage_object_key') ||
          decoded['storageObjectKeyExposed'] == true ||
          (mediaAsset is Map &&
              (mediaAsset.containsKey('storageObjectKey') ||
                  mediaAsset.containsKey('storage_object_key')));

      final secretsExposed = decoded['secretsExposed'] == true;
      final signedMediaReadUrl = decoded['signedMediaReadUrl']?.toString();
      final signedMediaReadUrlCreated =
          decoded['signedMediaReadUrlCreated'] == true;
      final code =
          decoded['code']?.toString() ?? 'SIGNED_MEDIA_READ_URL_UNKNOWN';

      final ok =
          decoded['ok'] == true &&
          response.statusCode == 200 &&
          signedMediaReadUrlCreated &&
          signedMediaReadUrl != null &&
          signedMediaReadUrl.isNotEmpty &&
          !storageBucketExposed &&
          !storageObjectKeyExposed &&
          !secretsExposed;

      return CidentiaSignedMediaReadUrlResult(
        ok: ok,
        code: ok ? code : 'SIGNED_MEDIA_READ_URL_CLIENT_BOUNDARY_BLOCKED_$code',
        signedMediaReadUrl: ok ? signedMediaReadUrl : null,
        signedMediaReadUrlCreated: signedMediaReadUrlCreated,
        expiresInSeconds: _asInt(decoded['expiresInSeconds']),
        httpStatus: response.statusCode,
        storageBucketExposed: storageBucketExposed,
        storageObjectKeyExposed: storageObjectKeyExposed,
        secretsExposed: secretsExposed,
      );
    } on TimeoutException {
      return _locked('SIGNED_MEDIA_READ_URL_TIMEOUT');
    } catch (_) {
      return _locked('SIGNED_MEDIA_READ_URL_UNAVAILABLE');
    } finally {
      client.close(force: true);
    }
  }

  CidentiaSignedMediaReadUrlResult _locked(String code, {int? httpStatus}) {
    return CidentiaSignedMediaReadUrlResult(
      ok: false,
      code: code,
      signedMediaReadUrl: null,
      signedMediaReadUrlCreated: false,
      expiresInSeconds: null,
      httpStatus: httpStatus,
      storageBucketExposed: false,
      storageObjectKeyExposed: false,
      secretsExposed: false,
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }
}
