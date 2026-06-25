'use strict';

const {
  cidFromSocialRequest,
  socialCidRequiredBoundary,
  socialRouteDisabledBoundary,
  readJsonBody,
  socialRoutesEnabled,
  unfollowCid,
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
      socialCidRequiredBoundary('/api/social/unfollow'),
    );
  }

  if (!socialRoutesEnabled()) {
    return res.status(503).json({
      ...socialRouteDisabledBoundary('/api/social/unfollow', followerCid),
      followedCid: followedCid || null,
    });
  }

  const result = await unfollowCid(followerCid, followedCid);

  if (!result.ok) {
    return res.status(503).json(
      socialRouteDisabledBoundary('/api/social/unfollow', followerCid, result),
    );
  }

  return res.status(200).json({
    ...result,
    route: '/api/social/unfollow',
    publicRouteDefaultOpened: false,
    flutterFollowOpened: false,
    secretsExposed: false,
  });
};
