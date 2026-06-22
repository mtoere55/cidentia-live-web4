'use strict';

function signedUploadUrlDisabledBoundary() {
  return Object.freeze({
    ok: false,
    code: 'SIGNED_UPLOAD_URL_DISABLED',
    signedUploadUrlCreated: false,
    objectStorageConnected: false,
    objectStorageWrite: false,
    uploadCreated: false,
    mediaMetadataCreated: false,
    expiresInSeconds: 0,
    uploadUrl: null,
    storageBucket: null,
    storageObjectKey: null,
  });
}

module.exports = {
  signedUploadUrlDisabledBoundary,
};
