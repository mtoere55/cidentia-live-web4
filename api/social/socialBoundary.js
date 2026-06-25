'use strict';

const {
  normalizeCid,
  followCid,
  unfollowCid,
  readFollowers,
  readFollowing,
} = require('../../server/social/followsRepository');

function envTrue(key) {
  return process.env[key] === 'true' || process.env[key] === '1';
}

function cidFromSocialRequest(req, body = {}) {
  const headers = req.headers || {};

  return (
    normalizeCid(headers['x-cidentia-cid']) ||
    normalizeCid(headers['x-cid']) ||
    normalizeCid(body.ownerCid) ||
    normalizeCid(body.cid)
  );
}

function socialCidRequiredBoundary(route) {
  return Object.freeze({
    ok: false,
    route,
    code: 'SOCIAL_CID_REQUIRED',
    message:
      'A verified CidenDB/CID session is required before social actions can be used.',
    cidRequired: true,
    cidVerified: false,
    followCreated: false,
    followDeleted: false,
    followersRead: false,
    followingRead: false,
    dbConnected: false,
    guarded: true,
    readOnly: true,
  });
}

function socialRouteDisabledBoundary(route, ownerCid, repositoryResult = {}) {
  return Object.freeze({
    ok: false,
    route,
    code: 'SOCIAL_ROUTE_DISABLED',
    message:
      'Social follow routes are disabled until the backend database gate is enabled.',
    ownerCid,
    repositoryCode: repositoryResult.code || 'SOCIAL_REPOSITORY_DISABLED',
    followCreated: false,
    followDeleted: false,
    followersRead: false,
    followingRead: false,
    dbConnected: repositoryResult.dbConnected === true,
    queryEnabled: repositoryResult.queryEnabled === true,
    guarded: true,
    readOnly: true,
    secretsExposed: false,
  });
}

async function readJsonBody(req) {
  if (req.body && typeof req.body === 'object') {
    return req.body;
  }

  return new Promise((resolve) => {
    let raw = '';

    req.on('data', (chunk) => {
      raw += chunk;
    });

    req.on('end', () => {
      if (!raw) {
        resolve({});
        return;
      }

      try {
        resolve(JSON.parse(raw));
      } catch (_) {
        resolve({});
      }
    });

    req.on('error', () => {
      resolve({});
    });
  });
}

function socialRoutesEnabled() {
  return envTrue('CIDENTIA_SOCIAL_FOLLOW_ROUTES_ENABLED');
}

module.exports = {
  cidFromSocialRequest,
  socialCidRequiredBoundary,
  socialRouteDisabledBoundary,
  readJsonBody,
  socialRoutesEnabled,
  followCid,
  unfollowCid,
  readFollowers,
  readFollowing,
};
