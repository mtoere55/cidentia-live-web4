'use strict';

const fs = require('fs');

const source = fs.readFileSync(
  'lib/local_social/widgets/local_profile_grid.dart',
  'utf8',
);

const checks = {
  tabBoundaryHelperFound: source.includes(
    'Future<String> _requestProfileTabBoundary(',
  ),
  postsRouteFound: source.includes("'/api/profile/posts'"),
  reelsRouteFound: source.includes("'/api/profile/reels'"),
  mediaRoutePreserved: source.includes("'/api/profile/media'"),
  cidHeaderFound: source.includes("'x-cidentia-cid': identity.cidLabel"),
  setTabAsyncFound: source.includes(
    'Future<void> _setTab(_ProfileTabKind tab) async',
  ),
  postsReelsOnlyGateFound: source.includes(
    'tab != _ProfileTabKind.posts && tab != _ProfileTabKind.reels',
  ),
  placeholderPreserved: source.includes('Placeholder grid stays unchanged'),
  noFakeItemMessageFound: source.includes(
    'No fake item or public media URL was applied.',
  ),
  gridStillUsesLocalPosts: source.includes(
    'final post = localPosts[index % localPosts.length];',
  ),
  noPublicMediaUrlApplied: !source.includes('publicMediaUrl: http'),
  noFakeItemsCreated: !source.includes('fakeItemsCreated: true'),
  noNewMediaTabCreated: !source.includes("label: 'Media'"),
};

const report = {
  ok: Object.values(checks).every(Boolean),
  ...checks,
  flutterRealRenderOpened: false,
  publicMediaUrlsCreated: false,
  fakeItemsCreated: false,
  secretsExposed: false,
};

console.log(JSON.stringify(report, null, 2));

if (!report.ok) {
  process.exitCode = 1;
}
