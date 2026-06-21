# M10F-A Infrastructure Readiness Note

M10F-A records the first real infrastructure preparation for Cidentia.Live.

This is not a production deploy.
This is not a backend launch.
This is not a payment, wallet, upload, AI, RTMP or live-stream opening.

## VPS

Provider: Hetzner Cloud
Server name: cidentia-live-api-01
Public IPv4: 167.233.122.49
OS: Ubuntu 24.04.4 LTS
Plan used for bootstrap: CX23
Disk: about 38 GB usable
RAM: about 3.7 GB
Swap: 2 GB enabled

Purpose:

- API/backend host
- CidenDB/CidenBridge backend bridge preparation
- future session service
- future credit ledger service
- future queue/worker bootstrap
- PostgreSQL bootstrap if needed
- Nginx reverse proxy later

The VPS must not be used as permanent media storage.

Do not store these permanently on VPS disk:

- uploaded videos
- replay videos
- AI generated images
- AI generated videos
- thumbnails archive
- proof package files
- public media archive

These belong in Object Storage.

## Object Storage

Provider: Hetzner Object Storage
Bucket: cidentia-live-media
Endpoint: fsn1.your-objectstorage.com
Region/location: Falkenstein / eu-central
Visibility: private

Purpose:

- profile media
- post media
- reels media
- replay files
- thumbnails
- AI output
- proof package media

Access keys were created but are not stored in the repository.

Object Storage keys must only live in trusted backend environment variables.
They must never be added to Flutter, public JavaScript, GitHub, docs or screenshots.

## Storage Box

Provider: Hetzner Storage Box
Name: cidentia-live-backup-01
Host: u618982.your-storagebox.de
SSH port: 23
Plan: BX11 / 1 TB
Location: Falkenstein
SSH support: enabled
WebDAV support: enabled
SMB support: disabled

Purpose:

- database backups
- server configuration backups
- deployment archive backups
- weekly recovery archive

The Storage Box is for backup only.
It is not a live media delivery layer.

## Cloudflare

Cloudflare remains the DNS, SSL, firewall and edge layer.

Expected future DNS roles:

- api.cidentia.live -> Hetzner VPS
- media.cidentia.live -> Object Storage or CDN routing
- cdn.cidentia.live -> future CDN/media delivery
- terminal.cidentia.live remains separate market terminal infrastructure

No DNS cutover was performed in M10F-A.

## SSH security

A non-root admin user was created:

- user: cidentia
- sudo: enabled
- SSH key login: enabled
- local SSH alias: cidentia-live-api

Normal server login:

ssh cidentia-live-api

Root SSH login was disabled.
SSH password authentication was disabled after key login was verified.

Firewall state:

- UFW active
- OpenSSH allowed
- 80/tcp allowed
- 443/tcp allowed

Fail2ban is active.

## Locked boundaries

M10F-A did not open:

- production deploy
- Node.js app deployment
- Nginx public routing
- PostgreSQL production database
- CidenDB live session service
- CidenBridge wallet/payment
- real wallet
- real payment
- token transfer
- blockchain route
- NFT mint
- upload production route
- Object Storage write route
- AI provider call
- RTMP/live stream
- replay recording

## Next safe steps

Recommended order:

1. Document media storage and replay architecture.
2. Document Object Storage env contract.
3. Document Storage Box backup contract.
4. Install Node.js, Nginx and PostgreSQL only after plan is sealed.
5. Create staging backend route before production route.
6. Connect Cloudflare DNS only after staging health check is ready.
7. Keep public media and private/signed media separated.
