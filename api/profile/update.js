const {
  cidFromProfileRequest,
  profileCidRequiredBoundary,
  profileWriteDisabledBoundary,
} = require('../../server/profile/profileBoundary');

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
  const cid = cidFromProfileRequest(req, body);

  if (!cid) {
    return res.status(401).json(
      profileCidRequiredBoundary('/api/profile/update'),
    );
  }

  return res.status(503).json(
    profileWriteDisabledBoundary('/api/profile/update', cid),
  );
};
