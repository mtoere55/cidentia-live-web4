# M21N — VPS env names-only read gates

Status: completed as VPS read-only names/status check.

## Purpose

M21N reads VPS env files for future read/display media URL gates without printing secret values.

## Scope

- VPS read-only.
- Names/status only.
- No env value exposure.
- No VPS env change.
- No Object Storage call.
- No signed URL generation.
- No API opening.
- No Flutter change.

## VPS env directory

```text
/opt/cidentia-live/env
```

## Files found

```text
db-live-smoke.env
object-storage-live-smoke.env
```

## db-live-smoke.env result

```text
CIDENTIA_MEDIA_URL_GENERATION_ENABLED=missing
CIDENTIA_OBJECT_STORAGE_ACCESS_KEY_ID=missing
CIDENTIA_OBJECT_STORAGE_BUCKET=missing
CIDENTIA_OBJECT_STORAGE_ENDPOINT=missing
CIDENTIA_OBJECT_STORAGE_READ_ENABLED=missing
CIDENTIA_OBJECT_STORAGE_REGION=missing
CIDENTIA_OBJECT_STORAGE_SECRET_ACCESS_KEY=missing
CIDENTIA_SIGNED_MEDIA_READ_URL_ENABLED=missing
```

## object-storage-live-smoke.env result

```text
CIDENTIA_MEDIA_URL_GENERATION_ENABLED=missing
CIDENTIA_OBJECT_STORAGE_ACCESS_KEY_ID=present_value_hidden
CIDENTIA_OBJECT_STORAGE_BUCKET=present_value_hidden
CIDENTIA_OBJECT_STORAGE_ENDPOINT=present_value_hidden
CIDENTIA_OBJECT_STORAGE_READ_ENABLED=missing
CIDENTIA_OBJECT_STORAGE_REGION=present_value_hidden
CIDENTIA_OBJECT_STORAGE_SECRET_ACCESS_KEY=present_value_hidden
CIDENTIA_SIGNED_MEDIA_READ_URL_ENABLED=missing
```

## Interpretation

The Object Storage smoke env still has hidden Object Storage config present, but the future read/display gates are missing.

Therefore signed media read URL generation remains locked on VPS.

Missing read gates:

```text
CIDENTIA_MEDIA_URL_GENERATION_ENABLED
CIDENTIA_OBJECT_STORAGE_READ_ENABLED
CIDENTIA_SIGNED_MEDIA_READ_URL_ENABLED
```

## Secret guard

No secret values were printed.

Only these statuses were used:

```text
true
false
missing
present_value_hidden
```

## Locked boundaries preserved

- No VPS env change.
- No Object Storage client create.
- No Object Storage call.
- No Object Storage read.
- No Object Storage write.
- No signed URL.
- No public URL.
- No public upload/media route.
- No API opened.
- No Flutter rendering.
- No package change.
- No fake media.
- No fake CID/session/token.
- No wallet/payment/blockchain.
- No RTMP/WebRTC/live stream.
