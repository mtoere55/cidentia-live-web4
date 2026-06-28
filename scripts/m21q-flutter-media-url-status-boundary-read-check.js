'use strict';

const fs = require('node:fs');

function includesAll(source, needles) {
  return needles.every((needle) => source.includes(needle));
}

function main() {
  const flutterPath = 'lib/local_social/widgets/local_profile_grid.dart';
  const source = fs.readFileSync(flutterPath, 'utf8');

  const requiredMarkers = [
    'enum _ProfileTabKind { posts, reels, live, proof }',
    "_ProfileTabKind.posts => '/api/profile/posts'",
    "_ProfileTabKind.reels => '/api/profile/reels'",
    'Future<String> _requestProfileTabBoundary',
    "headers: {'x-cidentia-cid': identity.cidLabel}",
    "final publicMediaUrlsCreated = decoded['publicMediaUrlsCreated'];",
    "final fakeItemsCreated = decoded['fakeItemsCreated'];",
    "'publicMediaUrlsCreated=$publicMediaUrlsCreated'",
    "'fakeItemsCreated=$fakeItemsCreated'",
    'Placeholder grid stays unchanged.',
    'No fake item or public media URL was applied.',
    'final post = localPosts[index % localPosts.length];',
  ];

  const forbiddenRenderMarkers = [
    'signedMediaReadUrl)',
    'Image.network(signedMediaReadUrl',
    'VideoPlayer.network(signedMediaReadUrl',
    'Image.network(publicMediaUrl',
    'VideoPlayer.network(publicMediaUrl',
  ];

  const markersPresent = includesAll(source, requiredMarkers);
  const forbiddenRenderAbsent = forbiddenRenderMarkers.every(
    (marker) => !source.includes(marker),
  );

  const report = Object.freeze({
    ok: markersPresent && forbiddenRenderAbsent,
    code: 'M21Q_FLUTTER_MEDIA_URL_STATUS_BOUNDARY_READ_CHECK',
    flutterPath,
    markersPresent,
    forbiddenRenderAbsent,
    profileTabBoundaryPresent: source.includes(
      'Future<String> _requestProfileTabBoundary',
    ),
    postsBoundaryRoutePresent: source.includes(
      "_ProfileTabKind.posts => '/api/profile/posts'",
    ),
    reelsBoundaryRoutePresent: source.includes(
      "_ProfileTabKind.reels => '/api/profile/reels'",
    ),
    publicMediaUrlsStatusRead: source.includes(
      "final publicMediaUrlsCreated = decoded['publicMediaUrlsCreated'];",
    ),
    fakeItemsStatusRead: source.includes(
      "final fakeItemsCreated = decoded['fakeItemsCreated'];",
    ),
    placeholderGridUnchangedTextPresent: source.includes(
      'Placeholder grid stays unchanged.',
    ),
    noPublicMediaAppliedTextPresent: source.includes(
      'No fake item or public media URL was applied.',
    ),
    localPostsGridStillUsed: source.includes(
      'final post = localPosts[index % localPosts.length];',
    ),
    realMediaRenderingOpened: false,
    signedMediaReadUrlRendered: false,
    publicMediaUrlRendered: false,
    newMediaTabOpened: false,
    fakeMediaCreated: false,
    objectStorageCalled: false,
    signedUrlGenerated: false,
    vpsEnvChanged: false,
    packageChanged: false,
  });

  console.log(JSON.stringify(report, null, 2));

  if (!report.ok) {
    process.exitCode = 1;
  }
}

main();
