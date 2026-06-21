# M10F-D Storage Box Backup Contract

M10F-D defines how the Hetzner Storage Box should be used for Cidentia.Live backups.

This is a safety and planning contract only.

No backup automation is activated.
No production deploy is performed.
No database dump is created.
No secret is committed.
No Storage Box password is stored in the repository.

## Storage Box target

Provider: Hetzner Storage Box
Name: cidentia-live-backup-01
Host: u618982.your-storagebox.de
SSH port: 23
Plan: BX11 / 1 TB
Location: Falkenstein
SSH support: enabled
WebDAV support: enabled
SMB support: disabled

## Core rule

Storage Box is for backup and recovery only.

It is not a live media delivery layer.
It is not an Object Storage replacement.
It is not a CDN.
It is not a production file server.

Live media belongs in Object Storage.
Backup copies and recovery archives may go to Storage Box.

## What should be backed up

Backup candidates:

- PostgreSQL dumps
- backend deployment manifests
- Nginx configuration
- systemd service files
- safe application config templates
- package/version inventory
- restore scripts
- selected metadata exports
- weekly recovery archive

## What should not be blindly backed up

Do not blindly mirror all Object Storage media to Storage Box unless a paid backup policy exists.

Do not backup unlimited:

- public videos
- replay archive
- AI generated video output
- large media buckets
- temporary upload files
- moderation-blocked files

Large media backup must be controlled by policy, retention and cost.

## Secret handling

Secrets must not be committed to GitHub.

Secrets must not be written into public docs.

Secrets include:

- Storage Box password
- Object Storage access key
- Object Storage secret key
- CidenDB tokens
- CidenBridge secrets
- SMTP password
- database password
- JWT/session secrets
- payment or wallet keys

If secrets need backup, they must be encrypted before leaving the VPS.

## Suggested backend env variables

Future backup scripts may use backend/server-only env values:

CIDENTIA_BACKUP_ENABLED=false
CIDENTIA_BACKUP_PROVIDER=hetzner-storage-box
CIDENTIA_BACKUP_HOST=u618982.your-storagebox.de
CIDENTIA_BACKUP_PORT=23
CIDENTIA_BACKUP_USER=
CIDENTIA_BACKUP_REMOTE_BASE=/backups/cidentia-live
CIDENTIA_BACKUP_RETENTION_DAYS=14
CIDENTIA_BACKUP_WEEKLY_RETENTION_WEEKS=8
CIDENTIA_BACKUP_MONTHLY_RETENTION_MONTHS=6
CIDENTIA_BACKUP_ENCRYPTION_REQUIRED=true
CIDENTIA_BACKUP_WRITE_ENABLED=false

Default state must be disabled:

CIDENTIA_BACKUP_ENABLED=false
CIDENTIA_BACKUP_WRITE_ENABLED=false

## Suggested backup folders

Remote folder structure:

backups/cidentia-live/
backups/cidentia-live/db/
backups/cidentia-live/config/
backups/cidentia-live/deployments/
backups/cidentia-live/metadata/
backups/cidentia-live/log-snapshots/
backups/cidentia-live/restore-tests/

## Backup frequency

Suggested starting schedule:

Daily:

- PostgreSQL dump
- deployment manifest
- Nginx config snapshot
- systemd service snapshot

Weekly:

- full recovery archive
- selected metadata export
- restore script snapshot

Monthly:

- long retention recovery archive

## Retention policy

Suggested default:

- daily backups: 14 days
- weekly backups: 8 weeks
- monthly backups: 6 months

Retention must be enforced by cleanup scripts.

Never allow backup storage to grow without limit.

## Restore requirement

Every backup policy must have a restore path.

Minimum restore checks:

- can download latest DB dump
- can inspect archive integrity
- can restore config to a staging path
- can verify deployment manifest
- can verify backup timestamps

A backup that cannot be restored is not a real backup.

## VPS disk rule

The VPS may create temporary backup files.

Temporary backup files must be deleted after upload to Storage Box.

Large temporary files must not fill the 40 GB VPS disk.

Backup scripts must check free disk space before creating archives.

## Locked boundaries

M10F-D does not open:

- real backup automation
- cron job
- database dump
- Storage Box write
- encrypted secret backup
- production deploy
- Node.js deployment
- Nginx routing
- PostgreSQL production database
- Object Storage write
- upload route
- payment
- wallet
- blockchain
- NFT mint
- AI provider call
- RTMP/live stream
- replay recording

## Next safe steps

Recommended next steps:

1. Install Node.js, Nginx and PostgreSQL on the VPS.
2. Add server setup notes to docs.
3. Create disabled staging backend health route.
4. Create disabled Object Storage client skeleton.
5. Create disabled backup script skeleton.
6. Test locked responses only before enabling writes.
