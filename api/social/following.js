'use strict';

const {
  cidFromSocialRequest,
  socialCidRequiredBoundary,
  socialRouteDisabledBoundary,
  readFollowing,
} = require('./socialBoundary');

module.exports = async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({
      ok: false,
      code: 'METHOD_NOT_ALLOWED',
      message: 'Use GET.',
    });
  }

  const ownerCid =
    (req.query && (req.query.ownerCid || req.query.cid || req.query.profileCid)) ||
    cidFromSocialRequest(req);

  if (!ownerCid) {
    return res.status(401).json(
      socialCidRequiredBoundary('/api/social/following'),
    );
  }

  const result = await readFollowing(ownerCid);

  if (!result.ok) {
    return res.status(503).json(
      socialRouteDisabledBoundary('/api/social/following', ownerCid, result),
    );
  }

  return res.status(200).json({
    ...result,
    route: '/api/social/following',
    publicRouteDefaultOpened: false,
    flutterFollowOpened: false,
    secretsExposed: false,
  });
};
