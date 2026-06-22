'use strict';

const { loadDatabaseContract } = require('../db/databaseContract');

function normalizeCid(value) {
  if (typeof value !== 'string') {
    return null;
  }

  const cid = value.trim();

  if (cid.length < 3) {
    return null;
  }

  return cid;
}

function cidFromProfileRequest(req, body = {}) {
  const headers = req.headers || {};

  return (
    normalizeCid(headers['x-cidentia-cid']) ||
    normalizeCid(headers['x-cid']) ||
    normalizeCid(body.ownerCid) ||
    normalizeCid(body.cid)
  );
}

function profileCidRequiredBoundary(route) {
  return Object.freeze({
    ok: false,
    route,
    code: 'PROFILE_CID_REQUIRED',
    message:
      'A verified CidenDB/CID session is required before profile data can be accessed.',
    cidRequired: true,
    cidVerified: false,
    profileRead: false,
    profileUpdated: false,
    dbConnected: false,
    guarded: true,
    readOnly: true,
  });
}

function profileReadDisabledBoundary(route, ownerCid) {
  const database = loadDatabaseContract();

  return Object.freeze({
    ok: false,
    route,
    code: 'PROFILE_READ_DISABLED',
    message:
      'Profile database read is disabled until the backend database gate is enabled.',
    ownerCid,
    cidRequired: true,
    cidVerified: false,
    profileRead: false,
    profileUpdated: false,
    dbConnected: database.dbConnected,
    databaseEnabled: database.databaseEnabled,
    writeLocked: database.locked.writeLocked,
    guarded: true,
    readOnly: true,
  });
}

function profileWriteDisabledBoundary(route, ownerCid) {
  const database = loadDatabaseContract();

  return Object.freeze({
    ok: false,
    route,
    code: 'PROFILE_WRITE_DISABLED',
    message:
      'Profile database write is disabled until the backend database gate is enabled.',
    ownerCid,
    cidRequired: true,
    cidVerified: false,
    profileRead: false,
    profileUpdated: false,
    dbConnected: database.dbConnected,
    databaseEnabled: database.databaseEnabled,
    writeLocked: database.locked.writeLocked,
    guarded: true,
    readOnly: true,
  });
}

module.exports = {
  cidFromProfileRequest,
  profileCidRequiredBoundary,
  profileReadDisabledBoundary,
  profileWriteDisabledBoundary,
};
