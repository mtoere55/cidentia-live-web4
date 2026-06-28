'use strict';

function main() {
  const plan = Object.freeze({
    milestone: 'M21O',
    mode: 'plan-only',
    requiresExplicitApprovalBeforeRealSmoke: true,
    currentVpsReadGatesMissingFromM21N: true,
    requiredReadGates: Object.freeze({
      CIDENTIA_MEDIA_URL_GENERATION_ENABLED: 'true',
      CIDENTIA_OBJECT_STORAGE_READ_ENABLED: 'true',
      CIDENTIA_SIGNED_MEDIA_READ_URL_ENABLED: 'true',
    }),
    allowedFutureProofFields: Object.freeze([
      'signedMediaReadUrlCreated',
      'signedUrlGenerated',
      'signedUrlValuePrinted:false',
      'signedUrlHostHidden:true',
      'signedUrlLength',
      'storageBucketExposed:false',
      'storageObjectKeyExposed:false',
      'storageSecretExposed:false',
      'secretsExposed:false',
    ]),
    forbiddenOutput: Object.freeze([
      'full signed URL',
      'query string',
      'access key',
      'secret key',
      'bucket value',
      'object key value',
      'endpoint value',
      'raw env values',
    ]),
  });

  const report = Object.freeze({
    ok:
      plan.mode === 'plan-only' &&
      plan.requiresExplicitApprovalBeforeRealSmoke === true &&
      plan.currentVpsReadGatesMissingFromM21N === true,
    code: 'M21O_SERVER_ONLY_SIGNED_READ_URL_SMOKE_PLAN_CHECK',
    mode: plan.mode,
    requiresExplicitApprovalBeforeRealSmoke:
      plan.requiresExplicitApprovalBeforeRealSmoke,
    currentVpsReadGatesMissingFromM21N:
      plan.currentVpsReadGatesMissingFromM21N,
    requiredReadGates: plan.requiredReadGates,
    signedMediaReadUrlCreated: false,
    signedUrlGenerated: false,
    signedUrlValuePrinted: false,
    signedUrlHostHidden: true,
    objectStorageCalled: false,
    objectStorageRead: false,
    objectStorageWrite: false,
    storageBucketExposed: false,
    storageObjectKeyExposed: false,
    storageSecretExposed: false,
    secretsExposed: false,
    vpsEnvChanged: false,
    apiOpened: false,
    flutterOpened: false,
    packageChanged: false,
    mustRunM21PAfterFutureRealSmoke: true,
  });

  console.log(JSON.stringify(report, null, 2));

  if (!report.ok) {
    process.exitCode = 1;
  }
}

main();
