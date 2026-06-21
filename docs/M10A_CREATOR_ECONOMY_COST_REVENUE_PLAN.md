# M10A Creator Economy Cost and Revenue Plan

M10A defines the cost and revenue boundary for Cidentia.Live before opening expensive production services.

## Purpose

Cidentia.Live should not make the project owner carry all AI, video, storage, live recording, wallet, blockchain, NFT and creator economy costs alone.

Heavy operations must be paid through:
- Pro subscriptions
- User credits
- Creator gifts
- AI generation fees
- Marketplace fees
- NFT mint fees
- Blockchain proof fees
- Promotion / boost fees

## Core principle

The app can remain open for public browsing, but expensive actions must be metered.

Public and low-cost surfaces:
- Feed browsing
- Search browsing
- Reels watching
- Public profile viewing
- Basic CID session entry
- Basic profile presence
- Basic chat surface

Metered or protected surfaces:
- AI image generation
- AI video generation
- Media upload
- Long video storage
- Live stream recording
- Replay archive
- Live gifts
- Paid effects
- Creator support
- Promotion / boost
- NFT minting
- Blockchain proof
- Wallet-based creator economy actions

## Free plan

Free users can:
- Browse public Feed/Search/Reels
- View profiles
- Use basic profile surfaces
- Access limited local drafts
- Verify CID where available
- See protected creator economy surfaces without executing real paid operations

Free users should not receive unlimited expensive operations.

## Pro plan

Pro users can receive:
- Higher upload limits
- Longer replay retention
- More creator profile tools
- More live room tools
- More AI credits or discounted AI actions
- Creator economy dashboard access
- Advanced profile customization
- Proof-ready media moments
- Market profile access

## Credit model

Credits can be used for:
- AI image generation
- AI video generation
- Premium effects
- Live gifts
- Creator boosts
- Story/reel promotion
- Replay extension
- NFT preparation
- Blockchain proof request

Credits should be visible as a simple user balance.

The user should not need to understand backend GPU, storage, CDN or blockchain cost details.

## Live gifts and effects

Live rooms can generate revenue from:
- Gift animations
- Paid reactions
- Premium chat messages
- Creator support
- Proof badges
- Effect unlocks
- Top supporter placement
- Special room access

Example platform split:
- User sends 1.00 EUR value
- Creator receives 0.80 EUR
- Platform keeps 0.20 EUR

Exact percentages remain future business settings.

## AI generation cost boundary

AI image/video generation should not run as a free unlimited system.

Flow:
1. User requests AI generation.
2. System checks credit/pro entitlement.
3. Job is sent to GPU/API provider.
4. Result is saved to object/video storage.
5. Database stores only metadata.
6. User receives generated media.

The app must not store generated media inside Flutter or directly inside the main database.

## Video and live recording cost boundary

Video/live recording flow:
1. User uploads or streams media.
2. Media goes to object/video storage.
3. Transcoding and delivery happen through video/CDN infrastructure.
4. Database stores metadata only.
5. Replay retention depends on plan or paid extension.

Database stores:
- media_id
- owner_cid
- media_type
- object_key or storage_url
- thumbnail_url
- duration
- size
- visibility
- created_at
- proof_status
- retention_until

Database must not store raw video files.

## NFT and blockchain boundary

Not every post should go directly to blockchain.

Correct staged flow:
1. Normal media/post exists inside platform.
2. User marks it as proof-ready.
3. Platform creates internal proof metadata.
4. User optionally requests blockchain proof.
5. User optionally mints NFT.
6. Marketplace sale creates platform commission.

Paid blockchain actions:
- Proof anchor
- NFT mint
- NFT transfer
- Marketplace listing
- Marketplace sale

Gas/network costs must be paid by the user, covered by credits, or included in Pro/creator packages.

## Wallet boundary

Wallet connection should be required for:
- Creator earnings
- Gift receiving
- Paid support
- NFT minting
- Blockchain proof
- Marketplace settlement

The UI should show simple terms:
- Balance
- Credits
- Creator earnings
- Gift balance
- NFT / Proof fees

The user should not be forced into technical wallet complexity during normal browsing.

## Infrastructure cost responsibility

The project owner can cover baseline infrastructure:
- App hosting
- API hosting
- Basic metadata database
- Basic monitoring
- Development/testing costs

Users or revenue flows should cover:
- AI GPU/API cost
- Heavy upload/storage
- Video transcoding
- CDN delivery
- Long replay archive
- Blockchain gas
- NFT minting
- Creator payouts
- Premium effects

## Locked boundaries

M10A is planning only.

No code changes.
No real payment route.
No real wallet route.
No blockchain transaction.
No NFT mint.
No AI generation call.
No upload/storage route.
No RTMP/live stream route.
No fake balance.
No fake payout.
No fake token.
No fake CID/session.

## Future milestones

Recommended next steps:
- M10B Wallet/Credits UI Preview
- M10C AI Credits Flow Plan
- M10D Live Gifts and Effects Preview
- M10E NFT/Proof Transaction Boundary
- M10F Media Storage and Replay Architecture Plan
