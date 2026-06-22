'use strict';

const {
  PRODUCTION_CAPABLE_FLAGS,
  loadCidentiaEnvContract,
} = require('../server/runtime/envContract');

const defaultContract = loadCidentiaEnvContract({});

const enabledSample = loadCidentiaEnvContract({
  CIDENTIA_BACKEND_DEPLOY_ACTIVE: 'true',
  CIDENTIA_PRODUCTION_MODE: 'true',
  CIDENTIA_UPLOAD_ENABLED: 'true',
});

console.log(JSON.stringify({
  defaultAllFalse: PRODUCTION_CAPABLE_FLAGS.every(
    (key) => defaultContract.gates[key] === false,
  ),
  defaultProductionDeploy: defaultContract.productionDeploy,
  defaultSecretsExposed: defaultContract.secretsExposed,
  defaultDbConnected: defaultContract.dbConnected,
  defaultObjectStorageConnected: defaultContract.objectStorageConnected,
  enabledSampleProductionDeploy: enabledSample.productionDeploy,
  enabledSampleUploadLocked: enabledSample.locked.uploadLocked,
}, null, 2));
