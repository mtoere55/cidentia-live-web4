# Cidentia.Live Web4

Cidentia.Live Web4 is a local-first social experience prototype for the Cidentia ecosystem.

This repository is not an Instagram clone product. It is a Cidentia.Live preview shell built with Flutter. Selected open-source Flutter social UI ideas may be studied only as read-only visual references during development.

## Project Purpose

Cidentia.Live is planned as a Web4 social and live interaction layer connected to the Cidentia ecosystem.

The long-term goal is to provide a social platform where public browsing can stay open while protected actions are connected to verified CidenDB/CID identity sessions.

Current work focuses on building a stable local Flutter interface before connecting real backend services.

## Current Local Preview Scope

The current branch contains local-only preview surfaces for:

- Feed and post action paths
- Reels scrolling and local actions
- Stories viewer preview
- Chats local interaction preview
- Profile tabs, grid preview, and local action sheets
- Live Studio layout previews
- Creator and social surface experiments

These features are local preview behavior only. They are not connected to production backend services.

## Identity Boundary

CidenDB is the identity and databank authority.

CidentiaApp is the onboarding and registration authority.

Cidentia.Live must not create its own identity authority, password login, fake OTP system, or independent user registration flow.

Public browsing can remain open. Protected actions must later require a verified CidenDB/CID session.

Protected actions include, but are not limited to:

- Editing profile
- Sending messages
- Managing proof
- Connecting wallet
- Starting live studio actions
- Managing RTMP or live destinations
- Uploading media
- Wallet or payment operations

## Current Safety State

The current local preview does not open:

- Real CidenDB session
- Real OTP verification
- Real wallet connection
- Real payment flow
- Real backend write operation
- Real RTMP stream
- Real live broadcast
- Real token storage

Any future connection to these systems must be implemented in a separate planned backend and identity phase.

## Development Principles

This project must be developed in small reversible patches.

Before coding, the current repository state must be checked through branch, status, log, and relevant file reads.

No random filler cards, test blocks, placeholder panels, or unrelated UI elements should be added just to fill empty space.

Existing page structure must be protected. Fix the real cause of UI or runtime problems without changing the intended product direction.

## Reference Policy

The original Flutter Instagram offline-first clone is a read-only reference source.

Allowed reference areas:

- Feed layout ideas
- Reels layout behavior
- Story viewer patterns
- Chat bubble and input patterns
- Profile grid and tab behavior
- Local social interaction UX

Not allowed:

- Copying identity or auth logic
- Supabase auth replacement
- Google sign-in replacement
- Firebase or Supabase backend dependency as identity source
- Password login
- Token or session architecture from the reference project
- Blind copying without adapting to Cidentia.Live architecture

## Current Branch Direction

The active development direction is local social product completion before real backend and CidenDB integration.

M3G and M3H focused on local social surface behavior.

Backend, OTP, CidenDB, wallet, RTMP, payment, and real live-streaming work must remain separate unless explicitly resumed.

## Local Run

Use the local Flutter entry point:

    flutter run -d windows -t lib/main_local.dart

Common local checks:

    flutter analyze lib\main_local.dart lib\local_social\local_social_app.dart lib\local_social\widgets\local_post_card.dart lib\local_social\widgets\local_reels_page.dart lib\local_social\widgets\local_stories_bar.dart lib\local_social\widgets\local_chat_detail.dart lib\local_social\widgets\local_profile_grid.dart

    git diff --check
    git status --short

## Project Status

Cidentia.Live Web4 is under active local preview development.

The current goal is to stabilize the Flutter social interface first, then connect real CidenDB/CID and backend systems through a controlled and documented boundary.
