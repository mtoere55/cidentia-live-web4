const {
  cidFromProfileRequest,
  profileCidRequiredBoundary,
} = require('../../server/profile/profileBoundary');
const { readProfileStatsByCid } = require('../../server/profile/profileStatsRepository');

function profileStatsDisabledBoundary(route, cid) {
  return Object.freeze({
    ok: false,
    code: 'PROFILE_STATS_DISABLED',
    route,
    ownerCid: cid,
    message: 'Profile stats boundary is locked. Real stats read is not enabled for this runtime.',
    statsRead: false,
    postsCount: null,
    reelsCount: null,
    mediaCount: null,
    followersCount: null,
    followingCount: null,
    trustScore: null,
    dbConnected: false,
    queryEnabled: false,
    secretsExposed: false,
  });
}

module.exports = async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({
      ok: false,
      code: 'METHOD_NOT_ALLOWED',
      message: 'Use GET.',
    });
  }

  const cid = cidFromProfileRequest(req);

  if (!cid) {
    return res.status(401).json(
      profileCidRequiredBoundary('/api/profile/stats'),
    );
  }

  const result = await readProfileStatsByCid(cid);

  if (!result.ok) {
    return res.status(503).json({
      ...profileStatsDisabledBoundary('/api/profile/stats', cid),
      repositoryCode: result.code,
      dbConnected: result.dbConnected,
      queryEnabled: result.queryEnabled,
    });
  }

  return res.status(200).json(result);
};
