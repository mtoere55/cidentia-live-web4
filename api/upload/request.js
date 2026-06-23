const {
  createSignedUploadUrl,
} = require('../../server/media/objectStoragePresignerClient');
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
  const ownerCid = cidFromUploadRequest(req, body);

  if (!ownerCid) {
    return res.status(401).json(
      uploadCidRequiredBoundary('/api/upload/request'),
    );
  }

  try {
    const result = await createSignedUploadUrl({
      ownerCid,
      filename: body.filename,
      mimeType: body.mimeType,
      surface: body.surface,
    });

    const status = result.ok ? 200 : 503;

    return res.status(status).json({
      ...result,
      route: '/api/upload/request',
      ownerCid,
      cidRequired: true,
      cidVerified: true,
      guarded: true,
      readOnly: !result.ok,
    });
  } catch (_) {
    return res.status(503).json({
      ok: false,
      route: '/api/upload/request',
      code: 'UPLOAD_REQUEST_BOUNDARY_ERROR',
      message: 'Upload request boundary failed safely.',
      ownerCid,
      cidRequired: true,
      cidVerified: true,
      signedUploadUrlCreated: false,
      objectStorageConnected: false,
      objectStorageWrite: false,
      uploadCreated: false,
      mediaMetadataCreated: false,
      secretsExposed: false,
      guarded: true,
      readOnly: true,
    });
  }
};
