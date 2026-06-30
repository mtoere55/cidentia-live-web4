import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../auth/cidentia_auth_gate_contract.dart';
import '../auth/cidentia_protected_action_notice.dart';
import '../auth/cidentia_session_scope.dart';
import '../local_social_data.dart';
import '../media/cidentia_media_read_url_client.dart';

const _panel = Color(0xFF101114);
const _panelSoft = Color(0xFF181A20);
const _line = Color(0xFF262A33);
const _textSoft = Color(0xFFA1A1AA);

const _profileApiBaseUrl = String.fromEnvironment(
  'CIDENTIA_LIVE_API_BASE_URL',
  defaultValue: 'https://api.cidentia.live',
);

class _ProfileIdentityView {
  const _ProfileIdentityView({
    required this.verified,
    required this.hasCid,
    required this.displayName,
    required this.handle,
    required this.initials,
    required this.identityLine,
    required this.description,
    required this.identityStatus,
    required this.cidBadgeLabel,
    required this.proofBadgeLabel,
    required this.emailLabel,
    required this.cidLabel,
  });

  final bool verified;
  final bool hasCid;
  final String displayName;
  final String handle;
  final String initials;
  final String identityLine;
  final String description;
  final String identityStatus;
  final String cidBadgeLabel;
  final String proofBadgeLabel;
  final String emailLabel;
  final String cidLabel;
}

_ProfileIdentityView _profileIdentityView({
  required bool verified,
  String? rawDisplayName,
  String? email,
  String? cid,
}) {
  final cleanName = rawDisplayName?.trim();
  final cleanEmail = email?.trim();
  final cleanCid = cid?.trim();
  final hasName =
      cleanName != null && cleanName.isNotEmpty && !cleanName.contains('@');
  final hasEmail = cleanEmail != null && cleanEmail.isNotEmpty;
  final hasCid = cleanCid != null && cleanCid.isNotEmpty;

  final displayName = verified
      ? hasName
            ? cleanName
            : hasCid
            ? 'CID $cleanCid'
            : hasEmail
            ? 'CidenDB profile incomplete'
            : 'Verified CidenDB User'
      : 'Cidentia Creator';

  final handle = verified ? _profileHandle(displayName) : '@cidentia.creator';
  final cidLabel = hasCid ? cleanCid : 'CID required';
  final emailLabel = hasEmail ? cleanEmail : 'email not provided';

  final identityLine = verified
      ? hasCid
            ? 'Verified CID: $cleanCid'
            : 'CidenDB verified ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â· CID onboarding required'
      : 'CID-ready creator identity';

  final description = verified
      ? hasCid
            ? 'Signed in as $emailLabel. Creator identity, avatar and cover workspace are ready.'
            : 'Signed in as $emailLabel. Complete CidentiaApp onboarding to receive a CID before protected creator services open.'
      : 'Build your Cidentia creator profile with live rooms, proof signals and media tools.';

  final identityStatus = verified
      ? hasCid
            ? 'CidenDB verified identity'
            : 'CID required from CidentiaApp'
      : 'CID sign-in available';

  return _ProfileIdentityView(
    verified: verified,
    hasCid: hasCid,
    displayName: displayName,
    handle: handle,
    initials: _profileInitials(displayName),
    identityLine: identityLine,
    description: description,
    identityStatus: identityStatus,
    cidBadgeLabel: hasCid ? 'CID $cleanCid' : 'CID required',
    proofBadgeLabel: hasCid ? 'Proof route locked' : 'Proof needs CID',
    emailLabel: emailLabel,
    cidLabel: cidLabel,
  );
}

String _profileDisplayName({
  required bool verified,
  String? rawDisplayName,
  String? email,
  String? cid,
}) {
  return _profileIdentityView(
    verified: verified,
    rawDisplayName: rawDisplayName,
    email: email,
    cid: cid,
  ).displayName;
}

Future<String> _requestProfileUpdateBoundary(
  _ProfileIdentityView identity,
) async {
  if (!identity.hasCid) {
    return 'PROFILE_CID_REQUIRED - Complete CidentiaApp onboarding before profile changes can be saved.';
  }

  final endpoint = Uri.parse('$_profileApiBaseUrl/api/profile/update');
  final client = HttpClient();

  try {
    final request = await client.postUrl(endpoint);
    request.headers.contentType = ContentType.json;
    request.headers.set('x-cidentia-cid', identity.cidLabel);
    request.write(
      jsonEncode({
        'ownerCid': identity.cidLabel,
        'displayName': identity.displayName,
        'email': identity.emailLabel,
        'client': 'cidentia-live-profile-preview',
      }),
    );

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    final decoded = jsonDecode(body);
    final code = decoded is Map<String, dynamic>
        ? decoded['code']?.toString()
        : null;
    final message = decoded is Map<String, dynamic>
        ? decoded['message']?.toString()
        : null;

    return '${code ?? 'PROFILE_WRITE_DISABLED'} - ${message ?? 'Profile write remains locked.'}';
  } catch (_) {
    return 'PROFILE_BOUNDARY_UNAVAILABLE - Profile backend boundary could not be reached.';
  } finally {
    client.close(force: true);
  }
}

Future<String> _requestProfileReadBoundary(
  _ProfileIdentityView identity,
) async {
  if (!identity.hasCid) {
    return 'PROFILE_CID_REQUIRED';
  }

  final endpoint = Uri.parse('$_profileApiBaseUrl/api/profile/me');
  final client = HttpClient();

  try {
    final request = await client.getUrl(endpoint);
    request.headers.set('x-cidentia-cid', identity.cidLabel);

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    final decoded = jsonDecode(body);
    final code = decoded is Map<String, dynamic>
        ? decoded['code']?.toString()
        : null;

    return code ?? 'PROFILE_READ_DISABLED';
  } catch (_) {
    return 'PROFILE_BOUNDARY_UNAVAILABLE';
  } finally {
    client.close(force: true);
  }
}

const _profileSocialPreviewTargetCid = 'Cid-M18C-Preview-Target';

Future<String> _requestProfileStatsBoundary(
  _ProfileIdentityView identity,
) async {
  if (!identity.hasCid) {
    return 'PROFILE_CID_REQUIRED';
  }

  final endpoint = Uri.parse('$_profileApiBaseUrl/api/profile/stats');
  final client = HttpClient();

  try {
    final request = await client.getUrl(endpoint);
    request.headers.set('x-cidentia-cid', identity.cidLabel);

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    final decoded = jsonDecode(body);

    if (decoded is Map<String, dynamic>) {
      final code = decoded['code']?.toString();
      final repositoryCode = decoded['repositoryCode']?.toString();
      final postsCount = decoded['postsCount'];
      final reelsCount = decoded['reelsCount'];
      final mediaCount = decoded['mediaCount'];
      final followersCount = decoded['followersCount'];
      final followingCount = decoded['followingCount'];
      final trustScore = decoded['trustScore'];

      return [
        if (code != null && code.isNotEmpty) code,
        if (repositoryCode != null && repositoryCode.isNotEmpty)
          'repository=$repositoryCode',
        'posts=$postsCount',
        'reels=$reelsCount',
        'media=$mediaCount',
        'followers=$followersCount',
        'following=$followingCount',
        'trust=$trustScore',
        'fakeCounters=false',
      ].join(' - ');
    }

    return 'PROFILE_STATS_BOUNDARY_UNKNOWN_RESPONSE';
  } catch (_) {
    return 'PROFILE_STATS_BOUNDARY_UNAVAILABLE';
  } finally {
    client.close(force: true);
  }
}

Future<String> _requestSocialFollowBoundary(
  _ProfileIdentityView identity,
) async {
  if (!identity.hasCid) {
    return 'SOCIAL_CID_REQUIRED - Verified CID is required before follow actions can be used.';
  }

  final endpoint = Uri.parse('$_profileApiBaseUrl/api/social/follow');
  final client = HttpClient();

  try {
    final request = await client.postUrl(endpoint);
    request.headers.contentType = ContentType.json;
    request.headers.set('x-cidentia-cid', identity.cidLabel);
    request.write(
      jsonEncode({
        'ownerCid': identity.cidLabel,
        'followedCid': _profileSocialPreviewTargetCid,
        'client': 'cidentia-live-profile-follow-boundary',
        'fakeFollowRequested': false,
        'fakeCounterRequested': false,
      }),
    );

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    final decoded = jsonDecode(body);

    if (decoded is Map<String, dynamic>) {
      final code = decoded['code']?.toString() ?? 'SOCIAL_ROUTE_DISABLED';
      final message = decoded['message']?.toString();
      final repositoryCode = decoded['repositoryCode']?.toString();
      final suffix = repositoryCode == null ? '' : ' ($repositoryCode)';

      if (message != null && message.isNotEmpty) {
        return '$code$suffix - $message';
      }

      return '$code$suffix';
    }

    return 'SOCIAL_ROUTE_DISABLED';
  } catch (_) {
    return 'SOCIAL_BOUNDARY_UNAVAILABLE - Social backend boundary could not be reached.';
  } finally {
    client.close(force: true);
  }
}

Future<String> _requestSocialListBoundary(
  _ProfileIdentityView identity, {
  required bool followers,
}) async {
  if (!identity.hasCid) {
    return 'SOCIAL_CID_REQUIRED';
  }

  final endpoint = Uri.parse(
    '$_profileApiBaseUrl/api/social/${followers ? 'followers' : 'following'}',
  ).replace(queryParameters: {'ownerCid': identity.cidLabel});
  final client = HttpClient();

  try {
    final request = await client.getUrl(endpoint);
    request.headers.set('x-cidentia-cid', identity.cidLabel);

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    final decoded = jsonDecode(body);

    if (decoded is Map<String, dynamic>) {
      final code = decoded['code']?.toString() ?? 'SOCIAL_ROUTE_DISABLED';
      final countKey = followers ? 'followerCount' : 'followingCount';
      final count = decoded[countKey];

      if (count is num) {
        return '$code - $countKey:$count';
      }

      final repositoryCode = decoded['repositoryCode']?.toString();
      return repositoryCode == null ? code : '$code ($repositoryCode)';
    }

    return 'SOCIAL_ROUTE_DISABLED';
  } catch (_) {
    return 'SOCIAL_BOUNDARY_UNAVAILABLE';
  } finally {
    client.close(force: true);
  }
}

String _profileCoverMimeType(String filename) {
  final lower = filename.toLowerCase();
  if (lower.endsWith('.png')) {
    return 'image/png';
  }
  if (lower.endsWith('.webp')) {
    return 'image/webp';
  }
  if (lower.endsWith('.gif')) {
    return 'image/gif';
  }
  return 'image/jpeg';
}

class _ProfileCoverUploadBoundaryResult {
  const _ProfileCoverUploadBoundaryResult({
    required this.status,
    required this.signedUploadUrlCreated,
    required this.uploadUri,
  });

  final String status;
  final bool signedUploadUrlCreated;
  final Uri? uploadUri;

  bool get canPutSignedUpload => signedUploadUrlCreated && uploadUri != null;

  static _ProfileCoverUploadBoundaryResult locked(String status) {
    return _ProfileCoverUploadBoundaryResult(
      status: status,
      signedUploadUrlCreated: false,
      uploadUri: null,
    );
  }
}

Future<_ProfileCoverUploadBoundaryResult> _requestProfileCoverUploadBoundary({
  required _ProfileIdentityView identity,
  required String filename,
  required int byteLength,
}) async {
  if (!identity.hasCid) {
    return _ProfileCoverUploadBoundaryResult.locked(
      'CID_REQUIRED_FOR_UPLOAD - Profile cover upload requires verified CID.',
    );
  }

  final endpoint = Uri.parse('$_profileApiBaseUrl/api/upload/request');
  final mimeType = _profileCoverMimeType(filename);
  final client = HttpClient();

  try {
    final request = await client.postUrl(endpoint);
    request.headers.contentType = ContentType.json;
    request.headers.set('x-cidentia-cid', identity.cidLabel);
    request.write(
      jsonEncode({
        'ownerCid': identity.cidLabel,
        'ownerEmail': identity.emailLabel,
        'filename': filename,
        'mimeType': mimeType,
        'byteLength': byteLength,
        'surface': 'profile-cover',
        'client': 'cidentia-live-profile-cover-preview',
        'metadataWriteRequested': false,
        'profileWriteRequested': false,
      }),
    );

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    final decoded = jsonDecode(body);

    if (decoded is Map<String, dynamic>) {
      final code = decoded['code']?.toString();
      final message = decoded['message']?.toString();
      final signedUploadUrlCreated = decoded['signedUploadUrlCreated'] == true;
      final rawUploadUrl = decoded['uploadUrl'];

      Uri? uploadUri;
      if (signedUploadUrlCreated &&
          rawUploadUrl is String &&
          rawUploadUrl.trim().isNotEmpty) {
        final parsed = Uri.tryParse(rawUploadUrl.trim());
        if (parsed != null && parsed.hasScheme && parsed.hasAuthority) {
          uploadUri = parsed;
        }
      }

      final status = message == null || message.isEmpty
          ? code ?? 'UPLOAD_ROUTE_DISABLED'
          : '${code ?? 'UPLOAD_ROUTE_DISABLED'} - $message';

      return _ProfileCoverUploadBoundaryResult(
        status: status,
        signedUploadUrlCreated: signedUploadUrlCreated,
        uploadUri: uploadUri,
      );
    }

    return _ProfileCoverUploadBoundaryResult.locked('UPLOAD_ROUTE_DISABLED');
  } catch (_) {
    return _ProfileCoverUploadBoundaryResult.locked(
      'UPLOAD_BOUNDARY_UNAVAILABLE',
    );
  } finally {
    client.close(force: true);
  }
}

Future<String?> _putProfileCoverSignedUpload({
  required Uri uploadUri,
  required Uint8List bytes,
  required String mimeType,
}) async {
  final client = HttpClient();

  try {
    final request = await client.putUrl(uploadUri);
    request.headers.contentType = ContentType.parse(mimeType);
    request.headers.contentLength = bytes.length;
    request.add(bytes);

    final response = await request.close();
    await response.drain<void>();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return null;
    }

    return 'SIGNED_UPLOAD_PUT_FAILED_${response.statusCode}';
  } catch (_) {
    return 'SIGNED_UPLOAD_PUT_UNAVAILABLE';
  } finally {
    client.close(force: true);
  }
}

String _profileCoverUploadBoundaryMessage(String status) {
  if (status == 'SIGNED_UPLOAD_PUT_OK') {
    return 'Cover preview updated. Cover uploaded; profile save is still locked.';
  }

  if (status.startsWith('SIGNED_UPLOAD_PUT_FAILED')) {
    return 'Cover preview saved locally. Signed upload PUT failed safely.';
  }

  if (status.startsWith('SIGNED_UPLOAD_PUT_TIMEOUT')) {
    return 'Cover preview saved locally. Signed upload PUT timed out.';
  }

  if (status.startsWith('SIGNED_UPLOAD_PUT_UNAVAILABLE')) {
    return 'Cover preview saved locally. Signed upload PUT is unavailable.';
  }

  if (status.startsWith('UPLOAD_ROUTE_DISABLED')) {
    return 'Cover preview saved locally. Upload route is still locked.';
  }

  if (status.startsWith('OBJECT_STORAGE_PRESIGNER_DISABLED')) {
    return 'Cover preview saved locally. Object Storage presigner is still locked.';
  }

  if (status.startsWith('CID_REQUIRED_FOR_UPLOAD')) {
    return 'Verified CID required for cover upload boundary.';
  }

  if (status.startsWith('UPLOAD_BOUNDARY_TIMEOUT')) {
    return 'Cover preview saved locally. Upload boundary timed out.';
  }

  if (status.startsWith('UPLOAD_BOUNDARY_UNAVAILABLE')) {
    return 'Cover preview saved locally. Upload boundary is unavailable.';
  }

  return status;
}

String _profileInitials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();

  if (parts.isEmpty) {
    return 'LC';
  }

  if (parts.length == 1) {
    final part = parts.first;
    if (part.length == 1) {
      return part.toUpperCase();
    }
    return part.substring(0, 2).toUpperCase();
  }

  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}

String _profileHandle(String value) {
  var normalized = value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '.')
      .replaceAll(RegExp(r'^\.+'), '')
      .replaceAll(RegExp(r'\.+$'), '');

  if (normalized.isEmpty) {
    normalized = 'local.creator';
  }

  return '@$normalized.cid';
}

enum _ProfileTabKind { posts, reels, live, proof }

String _profileTabRoute(_ProfileTabKind tab) {
  return switch (tab) {
    _ProfileTabKind.posts => '/api/profile/posts',
    _ProfileTabKind.reels => '/api/profile/reels',
    _ProfileTabKind.live => '/api/profile/media',
    _ProfileTabKind.proof => '/api/profile/media',
  };
}

String _profileTabLabel(_ProfileTabKind tab) {
  return switch (tab) {
    _ProfileTabKind.posts => 'Posts',
    _ProfileTabKind.reels => 'Reels',
    _ProfileTabKind.live => 'Live',
    _ProfileTabKind.proof => 'Proof',
  };
}

class _SafeProfileMediaItem {
  const _SafeProfileMediaItem({
    required this.mediaAssetId,
    required this.kind,
    required this.caption,
    required this.visibility,
    required this.createdAt,
    this.mimeType,
    this.byteSize,
    this.moderationStatus,
    this.uploadSource,
  });

  final String mediaAssetId;
  final String kind;
  final String caption;
  final String visibility;
  final String createdAt;
  final String? mimeType;
  final int? byteSize;
  final String? moderationStatus;
  final String? uploadSource;

  bool get canRequestReadUrl => mediaAssetId.trim().isNotEmpty;

  bool get hasCaption => caption.trim().isNotEmpty;
}

class _ProfileTabBoundaryResult {
  const _ProfileTabBoundaryResult({
    required this.status,
    this.mediaAssetId,
    this.safeItems = const <_SafeProfileMediaItem>[],
  });

  final String status;
  final String? mediaAssetId;
  final List<_SafeProfileMediaItem> safeItems;

  bool get hasMediaAssetId =>
      mediaAssetId != null && mediaAssetId!.trim().isNotEmpty;
}

String? _profileMediaAssetIdFromItems(Object? items) {
  if (items is! List) {
    return null;
  }

  const idKeys = [
    'mediaId',
    'media_id',
    'mediaAssetId',
    'media_asset_id',
    'assetId',
    'asset_id',
    'id',
  ];

  for (final item in items) {
    if (item is! Map) {
      continue;
    }

    for (final key in idKeys) {
      final value = item[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
  }

  return null;
}

String _safeProfileTabKind(_ProfileTabKind tab) {
  return switch (tab) {
    _ProfileTabKind.posts => 'post',
    _ProfileTabKind.reels => 'reel',
    _ProfileTabKind.live => 'live',
    _ProfileTabKind.proof => 'proof',
  };
}

String _safeProfileStringFromMap(
  Map item,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = item[key]?.toString().trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
  }

  return fallback;
}

int? _safeProfileIntFromMap(Map item, List<String> keys) {
  for (final key in keys) {
    final value = item[key];
    if (value is int) {
      return value;
    }

    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) {
      return parsed;
    }
  }

  return null;
}

List<_SafeProfileMediaItem> _safeProfileMediaItemsFromItems(
  Object? items,
  _ProfileTabKind tab,
) {
  if (items is! List) {
    return const <_SafeProfileMediaItem>[];
  }

  final safeItems = <_SafeProfileMediaItem>[];

  for (final item in items) {
    if (item is! Map) {
      continue;
    }

    final mediaAssetId = _safeProfileStringFromMap(item, const [
      'mediaId',
      'media_id',
      'mediaAssetId',
      'media_asset_id',
      'assetId',
      'asset_id',
      'id',
    ]);

    if (mediaAssetId.isEmpty) {
      continue;
    }

    safeItems.add(
      _SafeProfileMediaItem(
        mediaAssetId: mediaAssetId,
        kind: _safeProfileStringFromMap(item, const [
          'mediaSurface',
          'media_surface',
          'kind',
          'type',
        ], fallback: _safeProfileTabKind(tab)),
        caption: _safeProfileStringFromMap(item, const ['caption', 'title']),
        visibility: _safeProfileStringFromMap(item, const [
          'visibility',
        ], fallback: 'unknown'),
        createdAt: _safeProfileStringFromMap(item, const [
          'createdAt',
          'created_at',
        ]),
        mimeType: _safeProfileStringFromMap(item, const [
          'mimeType',
          'mime_type',
        ]),
        byteSize: _safeProfileIntFromMap(item, const ['byteSize', 'byte_size']),
        moderationStatus: _safeProfileStringFromMap(item, const [
          'moderationStatus',
          'moderation_status',
        ]),
        uploadSource: _safeProfileStringFromMap(item, const [
          'uploadSource',
          'upload_source',
        ]),
      ),
    );
  }

  return List<_SafeProfileMediaItem>.unmodifiable(safeItems);
}

Future<_ProfileTabBoundaryResult> _requestProfileTabBoundary(
  _ProfileIdentityView identity,
  _ProfileTabKind tab,
) async {
  final route = _profileTabRoute(tab);

  try {
    final response = await http.get(
      Uri.parse('$_profileApiBaseUrl$route'),
      headers: {'x-cidentia-cid': identity.cidLabel},
    );

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      final code = decoded['code']?.toString();
      final repositoryCode = decoded['repositoryCode']?.toString();
      final itemsRead = decoded['itemsRead'];
      final items = decoded['items'];
      final itemsLength = items is List ? items.length : 0;
      final publicMediaUrlsCreated = decoded['publicMediaUrlsCreated'];
      final fakeItemsCreated = decoded['fakeItemsCreated'];
      final mediaAssetId = _profileMediaAssetIdFromItems(items);
      final safeItems = _safeProfileMediaItemsFromItems(items, tab);

      return _ProfileTabBoundaryResult(
        status: [
          if (code != null && code.isNotEmpty) code,
          if (repositoryCode != null && repositoryCode.isNotEmpty)
            'repository=$repositoryCode',
          'route=$route',
          'itemsRead=$itemsRead',
          'items=$itemsLength',
          'mediaAssetIdPresent=${mediaAssetId != null}',
          'safeItems=${safeItems.length}',
          'safeFirstCanRequestReadUrl=${safeItems.isNotEmpty ? safeItems.first.canRequestReadUrl : false}',
          'publicMediaUrlsCreated=$publicMediaUrlsCreated',
          'fakeItemsCreated=$fakeItemsCreated',
        ].join(' - '),
        mediaAssetId: mediaAssetId,
        safeItems: safeItems,
      );
    }

    return const _ProfileTabBoundaryResult(
      status: 'PROFILE_TAB_BOUNDARY_UNKNOWN_RESPONSE',
    );
  } catch (_) {
    return const _ProfileTabBoundaryResult(
      status: 'PROFILE_TAB_BOUNDARY_UNAVAILABLE',
    );
  }
}

class _ProfileHeroDraft {
  const _ProfileHeroDraft({this.coverBytes, this.headline, this.intro});

  final Uint8List? coverBytes;
  final String? headline;
  final String? intro;
}

final ValueNotifier<_ProfileHeroDraft> _profileHeroDraft =
    ValueNotifier<_ProfileHeroDraft>(const _ProfileHeroDraft());

class OriginalInspiredProfilePage extends StatefulWidget {
  const OriginalInspiredProfilePage({super.key});

  @override
  State<OriginalInspiredProfilePage> createState() =>
      _OriginalInspiredProfilePageState();
}

class _OriginalInspiredProfilePageState
    extends State<OriginalInspiredProfilePage> {
  _ProfileTabKind activeTab = _ProfileTabKind.posts;
  String? _lastProfileReadCid;
  String? _profileReadBoundaryCode;
  String? _lastProfileTabBoundaryStatus;
  List<_SafeProfileMediaItem> _lastSafeProfileMediaItems =
      const <_SafeProfileMediaItem>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _requestVerifiedProfileReadBoundary();
  }

  void _requestVerifiedProfileReadBoundary() {
    final session = CidentiaSessionScope.maybeOf(context);
    final verified = session?.hasVerifiedCid ?? false;
    final identity = _profileIdentityView(
      verified: verified,
      rawDisplayName: session?.displayName,
      email: session?.email,
      cid: session?.cid,
    );

    if (!identity.hasCid || _lastProfileReadCid == identity.cidLabel) {
      return;
    }

    _lastProfileReadCid = identity.cidLabel;
    _requestProfileReadBoundary(identity).then((code) {
      if (!mounted) {
        return;
      }

      setState(() => _profileReadBoundaryCode = code);
    });
  }

  Future<void> _setTab(_ProfileTabKind tab) async {
    setState(() => activeTab = tab);

    if (tab != _ProfileTabKind.posts && tab != _ProfileTabKind.reels) {
      return;
    }

    final session = CidentiaSessionScope.maybeOf(context);
    final verified = session?.hasVerifiedCid ?? false;
    final identity = _profileIdentityView(
      verified: verified,
      rawDisplayName: session?.displayName,
      email: session?.email,
      cid: session?.cid,
    );

    if (!identity.hasCid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile tab boundary requires a verified CidenDB session with CID.',
          ),
        ),
      );
      return;
    }

    final boundary = await _requestProfileTabBoundary(identity, tab).timeout(
      const Duration(seconds: 5),
      onTimeout: () => const _ProfileTabBoundaryResult(
        status: 'PROFILE_TAB_BOUNDARY_TIMEOUT',
      ),
    );

    var status = boundary.status;
    var readUrlStatus = 'readUrlBoundary=not_requested';

    if (tab != _ProfileTabKind.posts && boundary.hasMediaAssetId) {
      final readUrl =
          await const CidentiaMediaReadUrlClient(baseUrl: _profileApiBaseUrl)
              .requestSignedReadUrl(
                mediaAssetId: boundary.mediaAssetId!,
                cid: identity.cidLabel,
              )
              .timeout(
                const Duration(seconds: 6),
                onTimeout: () => const CidentiaSignedMediaReadUrlResult(
                  ok: false,
                  code: 'SIGNED_MEDIA_READ_URL_CLIENT_TIMEOUT',
                  signedMediaReadUrl: null,
                  signedMediaReadUrlCreated: false,
                  expiresInSeconds: null,
                  httpStatus: null,
                  storageBucketExposed: false,
                  storageObjectKeyExposed: false,
                  secretsExposed: false,
                ),
              );

      final signedMediaReadUrlPresentHidden =
          readUrl.signedMediaReadUrl != null &&
          readUrl.signedMediaReadUrl!.isNotEmpty;

      readUrlStatus = [
        'readUrlCode=${readUrl.code}',
        'signedMediaReadUrlCreated=${readUrl.signedMediaReadUrlCreated}',
        'signedMediaReadUrlPresentHidden=$signedMediaReadUrlPresentHidden',
        'storageBucketExposed=${readUrl.storageBucketExposed}',
        'storageObjectKeyExposed=${readUrl.storageObjectKeyExposed}',
        'canPlay=${readUrl.canPlay}',
        'playbackOpened=false',
      ].join(' - ');
    } else if (tab != _ProfileTabKind.posts) {
      readUrlStatus = 'readUrlBoundary=no_media_asset_id';
    }

    status = '$status - $readUrlStatus';

    if (mounted) {
      setState(() {
        _lastProfileTabBoundaryStatus = status;
        _lastSafeProfileMediaItems = boundary.safeItems;
      });
    }

    if (!context.mounted) {
      return;
    }

    _openProfileActionSheet(
      context,
      title: '${_profileTabLabel(tab)} Boundary',
      subtitle: _profileTabRoute(tab),
      icon: tab == _ProfileTabKind.posts
          ? Icons.grid_on_rounded
          : Icons.play_circle_outline,
      text:
          'CID ${identity.cidLabel} requested ${_profileTabRoute(tab)}. '
          '$status. Placeholder grid stays unchanged. '
          'Signed URL hidden. Playback was not opened. '
          'No fake item or public media URL was applied.',
      identity: identity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileBoundaryVisible =
        _profileReadBoundaryCode != null &&
        _profileReadBoundaryCode != 'PROFILE_CID_REQUIRED';

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 96),
      children: [
        const _ProfileHero(),
        const SizedBox(height: 8),
        const _ProfileStatsRow(),
        const SizedBox(height: 10),
        const _ProfileActionRow(),
        if (profileBoundaryVisible) ...[
          const SizedBox(height: 10),
          _ProfileBoundaryStatusCard(code: _profileReadBoundaryCode!),
        ],
        const SizedBox(height: 10),
        const _CreatorRoleStrip(),
        const SizedBox(height: 10),
        const _CreatorEconomyPreviewCard(),
        const SizedBox(height: 10),
        _ProfileTabs(activeTab: activeTab, onChanged: _setTab),
        const SizedBox(height: 10),
        _ProfileGrid(
          activeTab: activeTab,
          safeBoundaryStatus: _lastProfileTabBoundaryStatus,
          safeMediaItems: _lastSafeProfileMediaItems,
        ),
      ],
    );
  }
}

class _ProfileBoundaryStatusCard extends StatelessWidget {
  const _ProfileBoundaryStatusCard({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.storage_outlined, color: _textSoft, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Profile read boundary: $code',
              style: const TextStyle(
                color: _textSoft,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileIdentityAvatar extends StatelessWidget {
  const _ProfileIdentityAvatar({
    required this.initials,
    required this.verified,
  });

  final String initials;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFE879F9), Color(0xFFF97316)],
            ),
            border: Border.all(color: Colors.white30, width: 3),
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: verified ? const Color(0xFF60A5FA) : _panelSoft,
              shape: BoxShape.circle,
              border: Border.all(color: _panel, width: 2),
            ),
            child: Icon(
              verified ? Icons.verified_rounded : Icons.photo_camera_outlined,
              size: 13,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileIdentityReadinessRow extends StatelessWidget {
  const _ProfileIdentityReadinessRow({
    required this.identityStatus,
    required this.mediaStatus,
  });

  final String identityStatus;
  final String mediaStatus;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _ProfileMiniStatus(icon: Icons.badge_outlined, label: identityStatus),
        _ProfileMiniStatus(
          icon: Icons.photo_library_outlined,
          label: mediaStatus,
        ),
      ],
    );
  }
}

class _ProfileMiniStatus extends StatelessWidget {
  const _ProfileMiniStatus({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _textSoft),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: _textSoft,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero();

  @override
  Widget build(BuildContext context) {
    final session = CidentiaSessionScope.maybeOf(context);
    final verified = session?.hasVerifiedCid ?? false;
    final identity = _profileIdentityView(
      verified: verified,
      rawDisplayName: session?.displayName,
      email: session?.email,
      cid: session?.cid,
    );

    final mediaStatus = 'Avatar / cover ready';
    final wideHero = MediaQuery.sizeOf(context).width >= 760;

    return ValueListenableBuilder<_ProfileHeroDraft>(
      valueListenable: _profileHeroDraft,
      builder: (context, draft, _) {
        final headline = draft.headline?.trim();
        final intro = draft.intro?.trim();
        final hasHeadline = headline != null && headline.isNotEmpty;
        final description = intro != null && intro.isNotEmpty
            ? intro
            : identity.description;

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: verified
                  ? const Color(0x6658A6FF)
                  : Colors.white.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    (verified
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFE879F9))
                        .withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: _ProfileHeroCoverBackground(
                  verified: verified,
                  coverBytes: draft.coverBytes,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.72),
                        Colors.black.withValues(alpha: 0.30),
                        Colors.black.withValues(alpha: 0.76),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.46),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              if (draft.coverBytes != null)
                const Positioned(
                  right: 18,
                  top: 18,
                  child: _ProfileLocalCoverPreviewBadge(),
                ),
              Positioned(
                right: -80,
                top: -90,
                child: Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        (verified
                                ? const Color(0xFF60A5FA)
                                : const Color(0xFFF472B6))
                            .withValues(alpha: 0.16),
                  ),
                ),
              ),
              if (wideHero)
                const Positioned(
                  right: 18,
                  bottom: 18,
                  child: _ProfileHeroSignalStack(),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileIdentityAvatar(
                      initials: identity.initials,
                      verified: verified,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  identity.displayName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.7,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (verified)
                                const Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFF60A5FA),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            identity.handle,
                            style: const TextStyle(
                              color: _textSoft,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            identity.identityLine,
                            style: const TextStyle(
                              color: Color(0xFF86EFAC),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (hasHeadline) ...[
                            const SizedBox(height: 6),
                            Text(
                              headline,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _ProfileIdentityReadinessRow(
                            identityStatus: identity.identityStatus,
                            mediaStatus: mediaStatus,
                          ),
                          const SizedBox(height: 10),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final compact = constraints.maxWidth < 360;

                              final badges = [
                                _ProfileBadge(
                                  icon: Icons.badge_outlined,
                                  label: identity.cidBadgeLabel,
                                ),
                                _ProfileBadge(
                                  icon: Icons.fingerprint_rounded,
                                  label: identity.proofBadgeLabel,
                                ),
                                const _ProfileBadge(
                                  icon: Icons.wallet_outlined,
                                  label: 'Wallet gateway',
                                ),
                              ];

                              if (!compact) {
                                return Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: badges,
                                );
                              }

                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    for (final badge in badges) ...[
                                      badge,
                                      const SizedBox(width: 8),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileLocalCoverPreviewBadge extends StatelessWidget {
  const _ProfileLocalCoverPreviewBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_outlined, size: 15, color: Colors.white),
            SizedBox(width: 6),
            Text(
              'Local cover preview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeroCoverBackground extends StatelessWidget {
  const _ProfileHeroCoverBackground({
    required this.verified,
    required this.coverBytes,
  });

  final bool verified;
  final Uint8List? coverBytes;

  @override
  Widget build(BuildContext context) {
    final bytes = coverBytes;

    if (bytes != null) {
      return Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: verified
              ? const [Color(0xFF101114), Color(0xFF172554), Color(0xFF111827)]
              : const [Color(0xFF101114), Color(0xFF3B0764), Color(0xFF111827)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CustomPaint(painter: _GridPatternPainter()),
    );
  }
}

class _ProfileHeroSignalStack extends StatelessWidget {
  const _ProfileHeroSignalStack();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: const [
        _ProfileHeroSignalChip(
          icon: Icons.live_tv_rounded,
          label: 'Live ready',
        ),
        _ProfileHeroSignalChip(
          icon: Icons.verified_user_outlined,
          label: 'Proof ready',
        ),
        _ProfileHeroSignalChip(
          icon: Icons.auto_awesome_rounded,
          label: 'Creator layer',
        ),
      ],
    );
  }
}

class _ProfileHeroSignalChip extends StatelessWidget {
  const _ProfileHeroSignalChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStatsRow extends StatelessWidget {
  const _ProfileStatsRow();

  Future<void> _openProfileStatsBoundary(BuildContext context) async {
    final session = CidentiaSessionScope.maybeOf(context);
    final verified = session?.hasVerifiedCid ?? false;
    final identity = _profileIdentityView(
      verified: verified,
      rawDisplayName: session?.displayName,
      email: session?.email,
      cid: session?.cid,
    );

    if (!verified || !identity.hasCid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verified CID required for profile stats boundary.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile stats boundary checking...')),
    );

    final status = await _requestProfileStatsBoundary(identity).timeout(
      const Duration(seconds: 6),
      onTimeout: () => 'PROFILE_STATS_BOUNDARY_TIMEOUT',
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    _openProfileActionSheet(
      context,
      title: 'Profile Stats Boundary',
      subtitle: '/api/profile/stats',
      icon: Icons.query_stats_rounded,
      text:
          'CID ${identity.cidLabel} requested /api/profile/stats. $status. '
          'Placeholder stats stay unchanged until real stats release. '
          'No fake counter was applied.',
    );
  }

  Future<void> _openSocialListBoundary(
    BuildContext context, {
    required bool followers,
  }) async {
    final session = CidentiaSessionScope.maybeOf(context);
    final verified = session?.hasVerifiedCid ?? false;
    final identity = _profileIdentityView(
      verified: verified,
      rawDisplayName: session?.displayName,
      email: session?.email,
      cid: session?.cid,
    );

    if (!verified || !identity.hasCid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verified CID required for social graph boundary.'),
        ),
      );
      return;
    }

    final label = followers ? 'Followers' : 'Following';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label boundary checking...'),
        duration: const Duration(seconds: 2),
      ),
    );

    final status =
        await _requestSocialListBoundary(
          identity,
          followers: followers,
        ).timeout(
          const Duration(seconds: 6),
          onTimeout: () => 'SOCIAL_BOUNDARY_TIMEOUT',
        );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    _openProfileActionSheet(
      context,
      title: label,
      subtitle: 'Social graph boundary',
      icon: followers
          ? Icons.groups_2_outlined
          : Icons.person_add_alt_1_outlined,
      text:
          '${identity.cidLabel} social graph boundary returned: $status. Counts stay unchanged until real profile stats are released.',
      identity: identity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '128',
            label: 'Posts',
            onTap: () => _openProfileStatsBoundary(context),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _StatCard(
            value: '24.8K',
            label: 'Followers',
            onTap: () => _openSocialListBoundary(context, followers: true),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _StatCard(
            value: '386',
            label: 'Following',
            onTap: () => _openSocialListBoundary(context, followers: false),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _StatCard(
            value: '98.4',
            label: 'Trust',
            onTap: () => _openProfileStatsBoundary(context),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, this.onTap});

  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_panel, Colors.white.withValues(alpha: 0.035)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _textSoft,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: card,
    );
  }
}

class _ProfileActionRow extends StatelessWidget {
  const _ProfileActionRow();

  Future<void> _openFollowBoundary(
    BuildContext context,
    _ProfileIdentityView identity,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Follow boundary checking...'),
        duration: Duration(seconds: 2),
      ),
    );

    final boundaryStatus = await _requestSocialFollowBoundary(identity).timeout(
      const Duration(seconds: 6),
      onTimeout: () => 'SOCIAL_BOUNDARY_TIMEOUT',
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    _openProfileActionSheet(
      context,
      title: 'Follow',
      subtitle: 'Social graph boundary',
      icon: Icons.person_add_alt_1_outlined,
      text: identity.hasCid
          ? 'CID ${identity.cidLabel} requested follow boundary for $_profileSocialPreviewTargetCid. $boundaryStatus. No fake follow state or fake counter was applied.'
          : 'Follow actions require a verified CidenDB session with CID. $boundaryStatus',
      identity: identity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = CidentiaSessionScope.maybeOf(context);
    final verified = session?.hasVerifiedCid ?? false;
    final identity = _profileIdentityView(
      verified: verified,
      rawDisplayName: session?.displayName,
      email: session?.email,
      cid: session?.cid,
    );

    final compact = MediaQuery.sizeOf(context).width < 420;

    return Row(
      children: [
        Expanded(
          child: _ProfileActionButton(
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            primary: true,
            onTap: () async {
              if (!verified) {
                CidentiaProtectedActionNotice.show(
                  context,
                  action: CidentiaProtectedAction.editProfile,
                );
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile boundary checking...'),
                  duration: Duration(seconds: 2),
                ),
              );

              final boundaryStatus =
                  await _requestProfileUpdateBoundary(identity).timeout(
                    const Duration(seconds: 6),
                    onTimeout: () =>
                        'PROFILE_BOUNDARY_TIMEOUT - Profile backend boundary did not answer in time.',
                  );

              if (!context.mounted) {
                return;
              }

              ScaffoldMessenger.of(context).hideCurrentSnackBar();

              _openProfileActionSheet(
                context,
                title: 'Edit Profile',
                subtitle: 'Creator identity workspace',
                icon: Icons.edit_outlined,
                text: identity.hasCid
                    ? '${identity.displayName} is connected to ${identity.cidLabel}. Signed in as ${identity.emailLabel}. $boundaryStatus'
                    : '${identity.displayName} is signed in as ${identity.emailLabel}, but no CID is attached yet. $boundaryStatus',
                identity: identity,
              );
            },
          ),
        ),
        SizedBox(width: compact ? 6 : 12),
        Expanded(
          child: _ProfileActionButton(
            icon: Icons.person_add_alt_1_outlined,
            label: 'Follow',
            onTap: () async {
              if (!verified) {
                CidentiaProtectedActionNotice.show(
                  context,
                  action: CidentiaProtectedAction.editProfile,
                );
                return;
              }

              await _openFollowBoundary(context, identity);
            },
          ),
        ),
        SizedBox(width: compact ? 6 : 12),
        Expanded(
          child: _ProfileActionButton(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Wallet',
            onTap: () {
              if (!verified) {
                CidentiaProtectedActionNotice.show(
                  context,
                  action: CidentiaProtectedAction.connectWallet,
                );
                return;
              }

              _openProfileActionSheet(
                context,
                title: 'Wallet',
                subtitle: 'CidenBridge wallet gateway',
                icon: Icons.account_balance_wallet_outlined,
                text: identity.hasCid
                    ? 'CID ${identity.cidLabel} is verified. Wallet access remains locked until the CidenBridge wallet gateway is connected.'
                    : 'Wallet access requires a CidenDB session with CID. Complete CidentiaApp onboarding first.',
              );
            },
          ),
        ),
        SizedBox(width: compact ? 6 : 12),
        Expanded(
          child: _ProfileActionButton(
            icon: Icons.verified_user_outlined,
            label: 'Proof',
            onTap: () {
              if (!verified) {
                CidentiaProtectedActionNotice.show(
                  context,
                  action: CidentiaProtectedAction.manageProof,
                );
                return;
              }

              _openProfileActionSheet(
                context,
                title: 'Proof',
                subtitle: 'CidenDB proof gateway',
                icon: Icons.verified_user_outlined,
                text: identity.hasCid
                    ? 'CID ${identity.cidLabel} is visible. Proof documents and audit routes remain locked until the protected proof gateway is connected.'
                    : 'Proof access requires a CidenDB session with CID. Complete CidentiaApp onboarding first.',
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: primary ? Colors.white : _panelSoft,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: primary ? Colors.white : _line),
        ),
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.sizeOf(context).width < 420 ? 8 : 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: primary ? Colors.black : Colors.white),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: primary ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreatorRoleStrip extends StatelessWidget {
  const _CreatorRoleStrip();

  @override
  Widget build(BuildContext context) {
    const roles = [
      (Icons.live_tv_rounded, 'Live creator', 'Rooms and replay'),
      (Icons.verified_user_outlined, 'Proof creator', 'CID signal'),
      (Icons.storefront_outlined, 'Market ready', 'Creator commerce'),
      (Icons.auto_awesome_rounded, 'Effect layer', 'Earned assets'),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_panel, const Color(0xFF151827), _panel],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Creator identity',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 560;
              final itemWidth = compact
                  ? (constraints.maxWidth - 8) / 2
                  : 150.0;

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final role in roles)
                    SizedBox(
                      width: itemWidth,
                      child: _CreatorRoleCard(
                        icon: role.$1,
                        title: role.$2,
                        subtitle: role.$3,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CreatorRoleCard extends StatelessWidget {
  const _CreatorRoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_panelSoft, Colors.white.withValues(alpha: 0.045)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _textSoft, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatorEconomyPreviewCard extends StatelessWidget {
  const _CreatorEconomyPreviewCard();

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        Icons.account_balance_wallet_outlined,
        'Credits',
        'Gateway',
        'Metered actions',
      ),
      (
        Icons.auto_awesome_rounded,
        'AI Credits',
        'Metered',
        'Image and video tools',
      ),
      (
        Icons.volunteer_activism_outlined,
        'Earnings',
        'Creator',
        'Support and gifts',
      ),
      (
        Icons.card_giftcard_outlined,
        'Gift Balance',
        'Support',
        'Live room gifts',
      ),
      (
        Icons.verified_user_outlined,
        'Proof Fees',
        'Prepared',
        'CID proof route',
      ),
      (
        Icons.workspace_premium_outlined,
        'Pro Status',
        'Creator',
        'Advanced tools',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.hub_outlined, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Creator Economy',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              _ProfilePill(label: 'CREATOR'),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Creator economy gateway for credits, earnings, gifts, proof fees and Pro access.',
            style: TextStyle(color: _textSoft, height: 1.35, fontSize: 12),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final metricWidth = constraints.maxWidth >= 760
                  ? (constraints.maxWidth - 16) / 3
                  : (constraints.maxWidth - 8) / 2;

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in items)
                    _CreatorEconomyMetric(
                      width: metricWidth,
                      icon: item.$1,
                      label: item.$2,
                      value: item.$3,
                      note: item.$4,
                    ),
                ],
              );
            },
          ),
          if (MediaQuery.sizeOf(context).width >= 520) ...[
            const SizedBox(height: 12),
            const _CreatorAssetStrip(),
          ],
        ],
      ),
    );
  }
}

class _CreatorEconomyMetric extends StatelessWidget {
  const _CreatorEconomyMetric({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.note,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            note,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _textSoft, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _CreatorAssetStrip extends StatelessWidget {
  const _CreatorAssetStrip();

  @override
  Widget build(BuildContext context) {
    const assets = [
      (Icons.account_balance_wallet_outlined, 'Credit gateway'),
      (Icons.auto_awesome_outlined, 'AI credit'),
      (Icons.card_giftcard_outlined, 'Gift support'),
      (Icons.workspace_premium_outlined, 'Creator proof'),
      (Icons.workspace_premium_outlined, 'Pro creator'),
      (Icons.token_outlined, 'NFT-ready asset'),
    ];

    return SizedBox(
      height: 84,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemCount: assets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final asset = assets[index];

          return Container(
            width: 128,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(asset.$1, size: 18),
                const Spacer(),
                Text(
                  asset.$2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs({required this.activeTab, required this.onChanged});

  final _ProfileTabKind activeTab;
  final ValueChanged<_ProfileTabKind> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: _ProfileTab(
              icon: Icons.grid_on_rounded,
              label: 'Posts',
              active: activeTab == _ProfileTabKind.posts,
              onTap: () => onChanged(_ProfileTabKind.posts),
            ),
          ),
          Expanded(
            child: _ProfileTab(
              icon: Icons.play_circle_outline,
              label: 'Reels',
              active: activeTab == _ProfileTabKind.reels,
              onTap: () => onChanged(_ProfileTabKind.reels),
            ),
          ),
          Expanded(
            child: _ProfileTab(
              icon: Icons.live_tv_rounded,
              label: 'Live',
              active: activeTab == _ProfileTabKind.live,
              onTap: () => onChanged(_ProfileTabKind.live),
            ),
          ),
          Expanded(
            child: _ProfileTab(
              icon: Icons.verified_user_outlined,
              label: 'Proof',
              active: activeTab == _ProfileTabKind.proof,
              onTap: () => onChanged(_ProfileTabKind.proof),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: active ? Colors.white10 : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: active ? Colors.white : _textSoft),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : _textSoft,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileGrid extends StatelessWidget {
  const _ProfileGrid({
    required this.activeTab,
    this.safeBoundaryStatus,
    this.safeMediaItems = const <_SafeProfileMediaItem>[],
  });

  final _ProfileTabKind activeTab;
  final String? safeBoundaryStatus;
  final List<_SafeProfileMediaItem> safeMediaItems;

  @override
  Widget build(BuildContext context) {
    final itemCount = switch (activeTab) {
      _ProfileTabKind.posts => 12,
      _ProfileTabKind.reels => 12,
      _ProfileTabKind.live => 6,
      _ProfileTabKind.proof => 6,
    };

    return GridView.builder(
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final post = localPosts[index % localPosts.length];
        final safeMediaItem = index < safeMediaItems.length
            ? safeMediaItems[index]
            : null;

        return _GridTile(
          post: post,
          index: index,
          activeTab: activeTab,
          safeBoundaryStatus: safeBoundaryStatus,
          safeMediaItem: safeMediaItem,
        );
      },
    );
  }
}

class _GridTile extends StatelessWidget {
  const _GridTile({
    required this.post,
    required this.index,
    required this.activeTab,
    this.safeBoundaryStatus,
    this.safeMediaItem,
  });

  final LocalPost post;
  final int index;
  final _ProfileTabKind activeTab;
  final String? safeBoundaryStatus;
  final _SafeProfileMediaItem? safeMediaItem;

  @override
  Widget build(BuildContext context) {
    final isReel = activeTab == _ProfileTabKind.reels || index % 4 == 1;
    final isTagged = activeTab == _ProfileTabKind.proof;
    final isLive = activeTab == _ProfileTabKind.live;
    final hasRealMediaItem = safeMediaItem?.canRequestReadUrl == true;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () =>
          _openGridPreview(context, post, index, activeTab, safeBoundaryStatus),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: post.accent,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _GridPatternPainter())),
            Positioned(
              left: 10,
              top: 10,
              child: Icon(
                isLive
                    ? Icons.live_tv_rounded
                    : isTagged
                    ? Icons.verified_user_outlined
                    : isReel
                    ? Icons.play_circle_fill_rounded
                    : Icons.collections_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '#${index + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            if (hasRealMediaItem)
              Positioned(
                right: 10,
                top: 42,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Text(
                    'REAL MEDIA',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Row(
                children: [
                  Icon(
                    isTagged
                        ? Icons.alternate_email_rounded
                        : Icons.favorite_rounded,
                    size: 15,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      isLive
                          ? 'Live'
                          : isTagged
                          ? 'Proof'
                          : post.likes,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
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
  }
}

void _openProfileActionSheet(
  BuildContext context, {
  required String title,
  required String subtitle,
  required IconData icon,
  required String text,
  _ProfileIdentityView? identity,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) {
      return _ProfilePreviewSheet(
        title: title,
        subtitle: subtitle,
        icon: icon,
        children: [
          if (title == 'Edit Profile') ...[
            _ProfileEditPreviewForm(identity: identity),
            const SizedBox(height: 10),
          ],
          if (title == 'Wallet') ...[
            const _ProfileGatewayStatusCard(
              title: 'Wallet gateway',
              subtitle: 'CID ready for wallet routing.',
              icon: Icons.account_balance_wallet_outlined,
              accent: Color(0xFFF97316),
              items: [
                _ProfileGatewayItem(
                  icon: Icons.verified_user_outlined,
                  label: 'CID session',
                  description: 'Ready for wallet routing.',
                ),
                _ProfileGatewayItem(
                  icon: Icons.lock_outline_rounded,
                  label: 'Balance hidden',
                  description:
                      'No token, payment or balance is displayed here.',
                ),
                _ProfileGatewayItem(
                  icon: Icons.hub_outlined,
                  label: 'CidenBridge required',
                  description: 'Wallet must pass through CidenBridge.',
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          if (title == 'Proof') ...[
            const _ProfileGatewayStatusCard(
              title: 'Proof gateway',
              subtitle: 'CID proof route is prepared.',
              icon: Icons.verified_user_outlined,
              accent: Color(0xFF60A5FA),
              items: [
                _ProfileGatewayItem(
                  icon: Icons.badge_outlined,
                  label: 'CID verified',
                  description: 'Verified CidenDB identity is visible.',
                ),
                _ProfileGatewayItem(
                  icon: Icons.fingerprint_rounded,
                  label: 'Proof module',
                  description:
                      'Document and audit routes open after proof service connection.',
                ),
                _ProfileGatewayItem(
                  icon: Icons.token_outlined,
                  label: 'Minting closed',
                  description:
                      'NFT, token and payment actions stay outside this profile view.',
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          _ProfileInfoCard(icon: icon, title: title, text: text),
          const SizedBox(height: 10),
          const _ProfileInfoCard(
            icon: Icons.lock_outline_rounded,
            title: 'Protected creator action',
            text:
                'Creator profile changes, wallet access and proof management require a verified CidenDB/CID session.',
          ),
        ],
      );
    },
  );
}

void _openGridPreview(
  BuildContext context,
  LocalPost post,
  int index,
  _ProfileTabKind tab,
  String? safeBoundaryStatus,
) {
  final title = switch (tab) {
    _ProfileTabKind.posts => 'Profile post',
    _ProfileTabKind.reels => 'Profile reel',
    _ProfileTabKind.live => 'Live room',
    _ProfileTabKind.proof => 'Proof item',
  };

  final icon = switch (tab) {
    _ProfileTabKind.posts => Icons.collections_rounded,
    _ProfileTabKind.reels => Icons.play_circle_fill_rounded,
    _ProfileTabKind.live => Icons.live_tv_rounded,
    _ProfileTabKind.proof => Icons.verified_user_outlined,
  };

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) {
      return _ProfilePreviewSheet(
        title: '$title #${index + 1}',
        subtitle: 'Creator profile item',
        icon: icon,
        children: [
          _ProfileGridPreviewFrame(post: post, icon: icon, tab: tab),
          const SizedBox(height: 12),
          _ProfileInfoCard(
            icon: Icons.info_outline_rounded,
            title: 'Creator profile item',
            text:
                'This item opens the creator content surface. Publishing, playback and proof actions remain protected by the creator release flow.',
          ),
          if (safeBoundaryStatus != null &&
              safeBoundaryStatus.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _ProfileInfoCard(
              icon: Icons.lock_outline_rounded,
              title: 'Safe media boundary status',
              text:
                  '$safeBoundaryStatus. Signed URL remains hidden. Playback is not opened from this sheet.',
            ),
          ],
        ],
      );
    },
  );
}

class _ProfileGatewayStatusCard extends StatelessWidget {
  const _ProfileGatewayStatusCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.items,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final List<_ProfileGatewayItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accent.withValues(alpha: 0.45)),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(color: _textSoft, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.icon, size: 19, color: accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.description,
                          style: const TextStyle(color: _textSoft, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileGatewayItem {
  const _ProfileGatewayItem({
    required this.icon,
    required this.label,
    required this.description,
  });

  final IconData icon;
  final String label;
  final String description;
}

class _ProfileEditPreviewForm extends StatefulWidget {
  const _ProfileEditPreviewForm({this.identity});

  final _ProfileIdentityView? identity;

  @override
  State<_ProfileEditPreviewForm> createState() =>
      _ProfileEditPreviewFormState();
}

class _ProfileEditPreviewFormState extends State<_ProfileEditPreviewForm> {
  late final TextEditingController nameController;
  late final TextEditingController handleController;
  late final TextEditingController bioController;
  late final TextEditingController initialsController;
  late final TextEditingController headlineController;
  late final TextEditingController introController;

  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? coverBytes;
  String initials = 'LC';
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) {
      return;
    }

    final session = CidentiaSessionScope.maybeOf(context);
    final verified = session?.hasVerifiedCid ?? false;
    final identity =
        widget.identity ??
        _profileIdentityView(
          verified: verified,
          rawDisplayName: session?.displayName,
          email: session?.email,
          cid: session?.cid,
        );
    final profileName = identity.displayName;
    final handle = _profileHandle(profileName).replaceFirst('@', '');
    final avatarInitials = _profileInitials(profileName);

    nameController = TextEditingController(text: profileName);
    handleController = TextEditingController(text: handle);
    final currentHeroDraft = _profileHeroDraft.value;

    bioController = TextEditingController(
      text:
          'Cidentia.Live creator profile connected to verified CidenDB/CID session.',
    );
    initialsController = TextEditingController(text: avatarInitials);
    headlineController = TextEditingController(
      text:
          currentHeroDraft.headline ??
          'Creator identity for live, proof and media.',
    );
    introController = TextEditingController(
      text:
          currentHeroDraft.intro ??
          'My Cidentia.Live space brings live rooms, proof signals and creator media together.',
    );
    coverBytes = currentHeroDraft.coverBytes;
    initials = avatarInitials;
    initialsController.addListener(_refreshAvatarPreview);
    _initialized = true;
  }

  @override
  void dispose() {
    initialsController.removeListener(_refreshAvatarPreview);
    nameController.dispose();
    handleController.dispose();
    bioController.dispose();
    initialsController.dispose();
    headlineController.dispose();
    introController.dispose();
    super.dispose();
  }

  void _refreshAvatarPreview() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _pickCoverImage() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return;
    }

    final bytes = await picked.readAsBytes();
    if (!mounted) {
      return;
    }

    setState(() {
      coverBytes = bytes;
    });

    _profileHeroDraft.value = _ProfileHeroDraft(
      coverBytes: bytes,
      headline: headlineController.text,
      intro: introController.text,
    );

    final identity = widget.identity;
    final uploadBoundary =
        await _requestProfileCoverUploadBoundary(
          identity:
              identity ??
              _profileIdentityView(
                verified: false,
                rawDisplayName: null,
                email: null,
                cid: null,
              ),
          filename: picked.name,
          byteLength: bytes.length,
        ).timeout(
          const Duration(seconds: 12),
          onTimeout: () => _ProfileCoverUploadBoundaryResult.locked(
            'UPLOAD_BOUNDARY_TIMEOUT - Upload boundary did not answer in time.',
          ),
        );

    var uploadStatus = uploadBoundary.status;

    if (uploadBoundary.canPutSignedUpload) {
      final putStatus =
          await _putProfileCoverSignedUpload(
            uploadUri: uploadBoundary.uploadUri!,
            bytes: bytes,
            mimeType: _profileCoverMimeType(picked.name),
          ).timeout(
            const Duration(seconds: 30),
            onTimeout: () => 'SIGNED_UPLOAD_PUT_TIMEOUT',
          );

      uploadStatus = putStatus ?? 'SIGNED_UPLOAD_PUT_OK';
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_profileCoverUploadBoundaryMessage(uploadStatus)),
        duration: const Duration(seconds: 8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPhotoPreviewNotice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Profile image workspace opens with the media release flow.',
        ),
      ),
    );
  }

  void _saveLocalDraft() {
    FocusScope.of(context).unfocus();

    _profileHeroDraft.value = _ProfileHeroDraft(
      coverBytes: coverBytes,
      headline: headlineController.text,
      intro: introController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Creator profile draft saved for this session.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Creator profile editor',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Shape your public creator identity before publishing it to the profile service.',
            style: TextStyle(color: _textSoft, height: 1.35),
          ),
          const SizedBox(height: 14),
          _ProfileCoverPreviewCard(
            coverBytes: coverBytes,
            onChangeCover: _pickCoverImage,
          ),
          const SizedBox(height: 14),
          _ProfileAvatarPreviewCard(
            initials: initialsController.text,
            onChangePhoto: _showPhotoPreviewNotice,
          ),
          const SizedBox(height: 14),
          _ProfileDraftField(
            controller: nameController,
            label: 'Display name',
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 10),
          _ProfileDraftField(
            controller: handleController,
            label: 'Handle',
            icon: Icons.alternate_email_rounded,
          ),
          const SizedBox(height: 10),
          _ProfileDraftField(
            controller: initialsController,
            label: 'Avatar initials',
            icon: Icons.account_circle_outlined,
          ),
          const SizedBox(height: 10),
          _ProfileDraftField(
            controller: headlineController,
            label: 'Hero headline',
            icon: Icons.campaign_outlined,
          ),
          const SizedBox(height: 10),
          _ProfileDraftField(
            controller: introController,
            label: 'Hero intro',
            icon: Icons.auto_stories_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 10),
          _ProfileDraftField(
            controller: bioController,
            label: 'Bio',
            icon: Icons.notes_rounded,
            maxLines: 3,
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _saveLocalDraft,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save profile draft'),
          ),
        ],
      ),
    );
  }
}

class _ProfileCoverPreviewCard extends StatelessWidget {
  const _ProfileCoverPreviewCard({
    required this.coverBytes,
    required this.onChangeCover,
  });

  final Uint8List? coverBytes;
  final VoidCallback onChangeCover;

  @override
  Widget build(BuildContext context) {
    final bytes = coverBytes;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hero cover',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 16 / 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (bytes != null)
                    Image.memory(
                      bytes,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    )
                  else
                    DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF101114),
                            Color(0xFF3B0764),
                            Color(0xFF111827),
                          ],
                        ),
                      ),
                      child: CustomPaint(painter: _GridPatternPainter()),
                    ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.45),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.50),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 14,
                    bottom: 12,
                    child: Text(
                      'Cover image keeps your creator message readable.',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onChangeCover,
            icon: const Icon(Icons.image_outlined, size: 18),
            label: const Text('Choose cover image'),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatarPreviewCard extends StatelessWidget {
  const _ProfileAvatarPreviewCard({
    required this.initials,
    required this.onChangePhoto,
  });

  final String initials;
  final VoidCallback onChangePhoto;

  String get safeInitials {
    final value = initials.trim().toUpperCase();
    if (value.isEmpty) return 'LC';
    if (value.length == 1) return value;
    return value.substring(0, 2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFE879F9), Color(0xFFF97316)],
              ),
              border: Border.all(color: Colors.white30, width: 3),
            ),
            child: Center(
              child: Text(
                safeInitials,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile image',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Avatar and cover media shape how your creator profile appears.',
                  style: TextStyle(color: _textSoft, height: 1.35),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: onChangePhoto,
                  icon: const Icon(Icons.photo_camera_outlined, size: 18),
                  label: const Text('Change photo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDraftField extends StatelessWidget {
  const _ProfileDraftField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF60A5FA)),
        ),
      ),
    );
  }
}

class _ProfilePreviewSheet extends StatelessWidget {
  const _ProfilePreviewSheet({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.84;

    return Container(
      margin: const EdgeInsets.all(14),
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x77000000),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: const TextStyle(color: _textSoft),
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
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileGridPreviewFrame extends StatelessWidget {
  const _ProfileGridPreviewFrame({
    required this.post,
    required this.icon,
    required this.tab,
  });

  final LocalPost post;
  final IconData icon;
  final _ProfileTabKind tab;

  @override
  Widget build(BuildContext context) {
    final label = switch (tab) {
      _ProfileTabKind.posts => 'POST',
      _ProfileTabKind.reels => 'REEL',
      _ProfileTabKind.live => 'LIVE',
      _ProfileTabKind.proof => 'PROOF',
    };

    final boundaryLabel = switch (tab) {
      _ProfileTabKind.posts => 'MEDIA LOCKED',
      _ProfileTabKind.reels => 'PLAYBACK READY',
      _ProfileTabKind.live => 'STUDIO LOCKED',
      _ProfileTabKind.proof => 'PROOF LOCKED',
    };

    final boundaryText = switch (tab) {
      _ProfileTabKind.posts =>
        'Post media playback remains locked for this profile surface.',
      _ProfileTabKind.reels =>
        'Controlled playback preview requires user tap. '
            'Autoplay is off. Signed URL remains hidden.',
      _ProfileTabKind.live =>
        'Live Studio boundary. Camera, microphone, stream key and '
            'RTMP broadcast remain locked.',
      _ProfileTabKind.proof =>
        'Proof preview stays locked. Document and audit routes open later.',
    };

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: post.accent,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _GridPatternPainter())),
            Center(
              child: CircleAvatar(
                radius: 42,
                backgroundColor: Colors.black38,
                child: Icon(icon, color: Colors.white, size: 48),
              ),
            ),
            Positioned(left: 16, top: 16, child: _ProfilePill(label: label)),
            Positioned(
              right: 16,
              top: 16,
              child: _ProfilePill(label: boundaryLabel),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.caption,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    boundaryText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _textSoft,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
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

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
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
                  text,
                  style: const TextStyle(color: _textSoft, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePill extends StatelessWidget {
  const _ProfilePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.11)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < 7; i++) {
      final x = i * size.width / 6;
      canvas.drawLine(
        Offset(x, 0),
        Offset(size.width - x / 3, size.height),
        paint,
      );
    }

    final dot = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.3), 18, dot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
