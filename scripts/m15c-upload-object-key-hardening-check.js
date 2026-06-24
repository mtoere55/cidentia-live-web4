'use strict';

const {
  buildUploadObjectKey,
} = require('../server/media/objectStoragePresignerClient');

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

function assertNoUnsafePath(key, label) {
  assert(key.startsWith('uploads/'), `${label}: key must start with uploads/`);
  assert(!key.includes('..'), `${label}: key must not include ..`);
  assert(!key.includes('\\'), `${label}: key must not include backslash`);
  assert(!key.includes('//'), `${label}: key must not include double slash`);
  assert(!key.includes('/./'), `${label}: key must not include /./`);
}

function main() {
  const fixedNow = new Date('2026-06-24T19:45:00.000Z');

  const traversal = buildUploadObjectKey({
    ownerCid: '../Cid 26/00004',
    surface: '../../profile-cover',
    filename: '../../evil\\cover image!!.jpg',
    now: fixedNow,
  });

  assertNoUnsafePath(traversal, 'traversal');
  assert(
    traversal ===
      'uploads/Cid-26-00004/profile-cover/2026-06-24T19-45-00-000Z-evil-cover-image-.jpg',
    `traversal sanitized key mismatch: ${traversal}`,
  );

  const longName = `${'a'.repeat(200)}.jpg`;
  const longKey = buildUploadObjectKey({
    ownerCid: 'Cid-M15C-Long-Key',
    surface: 'profile_cover',
    filename: longName,
    now: fixedNow,
  });

  const filenameSegment = longKey.split('/').pop().replace(
    '2026-06-24T19-45-00-000Z-',
    '',
  );

  assertNoUnsafePath(longKey, 'long filename');
  assert(
    filenameSegment.length === 120,
    `filename segment should be capped at 120, got ${filenameSegment.length}`,
  );

  const fallback = buildUploadObjectKey({
    ownerCid: '',
    surface: '',
    filename: '',
    now: fixedNow,
  });

  assertNoUnsafePath(fallback, 'fallback');
  assert(
    fallback ===
      'uploads/cid-required/media/2026-06-24T19-45-00-000Z-upload.bin',
    `fallback key mismatch: ${fallback}`,
  );

  console.log(JSON.stringify({
    ok: true,
    code: 'M15C_UPLOAD_OBJECT_KEY_HARDENING_OK',
    traversal,
    longFilenameSegmentLength: filenameSegment.length,
    fallback,
    objectStorageWrite: false,
    signedUploadUrlCreated: false,
    uploadCreated: false,
    mediaMetadataCreated: false,
    secretsExposed: false,
  }, null, 2));
}

try {
  main();
} catch (error) {
  console.error(JSON.stringify({
    ok: false,
    code: 'M15C_UPLOAD_OBJECT_KEY_HARDENING_FAILED',
    message: error.message,
  }, null, 2));
  process.exit(1);
}
