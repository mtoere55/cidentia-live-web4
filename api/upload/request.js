const { sendLocked } = require('../../server/runtime/backendStatusGuard');
const {
  cidFromUploadRequest,
  uploadCidRequiredBoundary,
} = require('../../server/media/uploadRequestBoundary');

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

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({
      ok: false,
      code: 'METHOD_NOT_ALLOWED',
      message: 'Use POST.',
    });
  }

  const body = await readJsonBody(req);
  const cid = cidFromUploadRequest(req, body);

  if (!cid) {
    return res.status(401).json(
      uploadCidRequiredBoundary('/api/upload/request'),
    );
  }

  return sendLocked(
    res,
    '/api/upload/request',
    'UPLOAD_ROUTE_DISABLED',
    'Upload permission route is disabled until the media contract is implemented.',
    {
      ownerCid: cid,
      cidRequired: true,
      cidVerified: false,
      uploadCreated: false,
      signedUploadUrlCreated: false,
      mediaMetadataCreated: false,
    },
  );
};
