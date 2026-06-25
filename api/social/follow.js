'use strict';

const {
  cidFromSocialRequest,
  socialCidRequiredBoundary,
  socialRouteDisabledBoundary,
  readJsonBody,
  socialRoutesEnabled,
  followCid,
} = require('./socialBoundary');

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({
      ok: false,
      code: 'METHOD_NOT_ALLOWED',
      message: 'Use POST.',
    });
  }

  const body = await readJsonBody(req);
  const followerCid = cidFromSocialRequest(req, body);
  const followedCid = body.followedCid || body.targetCid || body.profileCid;

  if (!followerCid) {
    return res.status(401).json(
      socialCidRequiredBoundary('/api/social/follow'),
    );
  }

  if (!socialRoutesEnabled()) {
    return res.status(503).json({
      ...socialRouteDisabledBoundary('/api/social/follow', followerCid),
      followedCid: followedCid || null,
    });
  }

  const result = await followCid(followerCid, followedCid);

  if (!result.ok) {
    return res.status(503).json(
      socialRouteDisabledBoundary('/api/social/follow', followerCid, result),
    );
  }

  return res.status(200).json({
    ...result,
    route: '/api/social/follow',
    publicRouteDefaultOpened: false,
    flutterFollowOpened: false,
    secretsExposed: false,
  });
};
