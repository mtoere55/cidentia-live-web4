'use strict';

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

function cidFromUploadRequest(req, body = {}) {
  const headers = req.headers || {};
  const cid =
    normalizeCid(headers['x-cidentia-cid']) ||
    normalizeCid(headers['x-cid']) ||
    normalizeCid(body.ownerCid) ||
    normalizeCid(body.cid);

  return cid;
}

function uploadCidRequiredBoundary(route) {
  return Object.freeze({
    ok: false,
    route,
    code: 'CID_REQUIRED_FOR_UPLOAD',
    message:
      'A verified CidenDB/CID session is required before upload can be requested.',
    uploadCreated: false,
    signedUploadUrlCreated: false,
    mediaMetadataCreated: false,
    cidRequired: true,
    cidVerified: false,
    guarded: true,
    readOnly: true,
  });
}

module.exports = {
  cidFromUploadRequest,
  uploadCidRequiredBoundary,
};
