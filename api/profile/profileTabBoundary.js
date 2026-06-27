const {
  cidFromProfileRequest,
  profileCidRequiredBoundary,
} = require('../../server/profile/profileBoundary');

function profileTabsDisabledBoundary(route, cid, tab) {
  return Object.freeze({
    ok: false,
    code: 'PROFILE_TABS_DISABLED',
    route,
    ownerCid: cid,
    tab,
    message: 'Profile tab boundary is locked. Real tab read is not enabled for this runtime.',
    itemsRead: false,
    items: [],
    nextCursor: null,
    dbConnected: false,
    queryEnabled: false,
    secretsExposed: false,
    publicMediaUrlsCreated: false,
    fakeItemsCreated: false,
  });
}

function methodNotAllowed(res) {
  return res.status(405).json({
    ok: false,
    code: 'METHOD_NOT_ALLOWED',
    message: 'Use GET.',
  });
}

async function handleProfileTabRead(req, res, config) {
  if (req.method !== 'GET') {
    return methodNotAllowed(res);
  }

  const cid = cidFromProfileRequest(req);

  if (!cid) {
    return res.status(401).json(
      profileCidRequiredBoundary(config.route),
    );
  }

  const result = await config.read(cid);

  if (!result.ok) {
    return res.status(503).json({
      ...profileTabsDisabledBoundary(config.route, cid, config.tab),
      repositoryCode: result.code,
      dbConnected: result.dbConnected,
      queryEnabled: result.queryEnabled,
    });
  }

  return res.status(200).json({
    ...result,
    route: config.route,
    nextCursor: null,
    publicMediaUrlsCreated: false,
    fakeItemsCreated: false,
  });
}

module.exports = {
  handleProfileTabRead,
  profileTabsDisabledBoundary,
};
