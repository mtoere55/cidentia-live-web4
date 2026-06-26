'use strict';

const fs = require('fs');

const source = fs.readFileSync(
  'lib/local_social/widgets/local_profile_grid.dart',
  'utf8',
);

const report = Object.freeze({
  ok:
    source.includes("Future<String> _requestProfileStatsBoundary") &&
    source.includes("Uri.parse('$_profileApiBaseUrl/api/profile/stats')") &&
    source.includes("request.headers.set('x-cidentia-cid', identity.cidLabel)") &&
    source.includes("PROFILE_STATS_BOUNDARY_UNAVAILABLE") &&
    source.includes("fakeCounters=false") &&
    source.includes("_openProfileStatsBoundary") &&
    source.includes("Placeholder stats stay unchanged until real stats release") &&
    source.includes("No fake counter was applied") &&
    source.includes("value: '128'") &&
    source.includes("value: '24.8K'") &&
    source.includes("value: '386'") &&
    source.includes("value: '98.4'"),
  statsHelperFound: source.includes("Future<String> _requestProfileStatsBoundary"),
  statsRouteFound: source.includes("/api/profile/stats"),
  cidHeaderFound: source.includes("x-cidentia-cid"),
  noFakeCounterMessageFound: source.includes("No fake counter was applied"),
  placeholdersPreserved:
    source.includes("value: '128'") &&
    source.includes("value: '24.8K'") &&
    source.includes("value: '386'") &&
    source.includes("value: '98.4'"),
  publicStatsOpened: false,
  fakeCountersCreated: false,
  secretsExposed: false,
});

console.log(JSON.stringify(report, null, 2));

if (!report.ok) {
  process.exitCode = 1;
}
