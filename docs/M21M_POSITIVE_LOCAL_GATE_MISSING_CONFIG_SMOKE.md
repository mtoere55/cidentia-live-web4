# M21M — Positive local gate + missing config smoke

Status: completed locally.

## Scope

M21M verifies the safe positive-gate path where read/display gates are enabled locally, but Object Storage read config is intentionally missing.

## Safety boundary

- Local smoke only.
- No VPS env change.
- No Object Storage client create.
- No Object Storage call.
- No signed URL.
- No public URL.
- No package change.
- No Flutter change.
- No fake media.
- No fake CID/session/token.

## Local gates used

```text
CIDENTIA_MEDIA_URL_GENERATION_ENABLED=true
CIDENTIA_OBJECT_STORAGE_READ_ENABLED=true
CIDENTIA_SIGNED_MEDIA_READ_URL_ENABLED=true
```

## Object Storage config

Intentionally omitted:

```text
CIDENTIA_OBJECT_STORAGE_ENDPOINT
CIDENTIA_OBJECT_STORAGE_BUCKET
CIDENTIA_OBJECT_STORAGE_ACCESS_KEY_ID
CIDENTIA_OBJECT_STORAGE_SECRET_ACCESS_KEY
```

## Smoke result

```text
OBJECT_STORAGE_READ_CONFIG_MISSING
signedMediaReadUrl:null
signedMediaReadUrlCreated:false
objectStorageCalled:false
objectStorageRead:false
objectStorageWrite:false
signedUrlGenerated:false
secretsExposed:false
vpsEnvChanged:false
apiOpened:false
flutterOpened:false
packageChanged:false
```
