# M21O — Server-only signed read URL smoke plan

Status: plan only.

## Purpose

M21O defines the safety protocol for a future server-only temporary signed media read URL smoke.

This milestone does not generate a signed URL.

## Why plan-only

M21N proved that VPS read/display gates are still missing.

Therefore signed media read URL generation remains locked on VPS.

## Required explicit approval before real smoke

A future real M21O smoke may only run after explicit approval and after read gates are intentionally added.

Required read gates:

```text
CIDENTIA_MEDIA_URL_GENERATION_ENABLED=true
CIDENTIA_OBJECT_STORAGE_READ_ENABLED=true
CIDENTIA_SIGNED_MEDIA_READ_URL_ENABLED=true
```

## Safety boundary for this plan

- No VPS env change.
- No Object Storage client create.
- No Object Storage call.
- No Object Storage read.
- No Object Storage write.
- No signed URL generation.
- No signed URL printed.
- No bucket value printed.
- No object key value printed.
- No secret value printed.
- No public URL.
- No public upload/media route.
- No API opened.
- No Flutter change.
- No package change.
- No fake media.
- No fake CID/session/token.
- No wallet/payment/blockchain.
- No RTMP/WebRTC/live stream.

## Future real smoke guardrails

If a future real smoke is approved, the report must hide all sensitive values.

Allowed proof fields only:

```text
signedMediaReadUrlCreated:true|false
signedUrlGenerated:true|false
signedUrlValuePrinted:false
signedUrlHostHidden:true
signedUrlLength:number
storageBucketExposed:false
storageObjectKeyExposed:false
storageSecretExposed:false
secretsExposed:false
```

Forbidden output:

```text
full signed URL
query string
access key
secret key
bucket value
object key value
endpoint value
raw env values
```

## Required closing step after any future real smoke

After any future real signed URL smoke, M21P must close/prove disabled state again.

## Current conclusion

M21O remains plan-only because VPS read gates are missing.

No signed read URL can be safely generated in this milestone.
