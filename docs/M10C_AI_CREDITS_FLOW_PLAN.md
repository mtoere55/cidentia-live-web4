# M10C AI Credits Flow Plan

M10C defines how Cidentia.Live should handle AI image and video generation without making expensive GPU/API usage free or unlimited.

## Purpose

AI creation must be useful for creators, but it must not become an unlimited cost for the project owner.

AI operations must be controlled by:
- Verified CidenDB/CID session
- User credits
- Pro plan allowance
- Job queue
- Storage rules
- Safety checks
- Metadata-only database records

## Core principle

Flutter must never run AI generation directly.

Flutter can:
- Show AI creation UI
- Show available credit status when backend supports it
- Submit a generation request to backend
- Show job status
- Display generated media from storage/CDN

Flutter must not:
- Hold AI provider keys
- Call GPU/API providers directly
- Store generated media inside the app bundle
- Fake credit balance
- Fake successful generation
- Fake Pro entitlement
- Store raw generated video in database
- Open payment/token/wallet routes directly

## Required session boundary

AI generation should require a verified CidenDB/CID session.

Guest users can:
- See AI creation preview
- See explanation of credit usage
- Prepare local draft ideas

Guest users cannot:
- Execute paid AI generation
- Consume real GPU/API credits
- Save generated output to account storage
- Publish AI output as verified creator media

## Credit and entitlement check

Before any AI job starts, backend must check:

1. User has verified CID session.
2. User has enough credits or Pro allowance.
3. Requested generation type is allowed.
4. User has not exceeded rate limits.
5. Content request passes safety rules.
6. Storage quota is available.

If any check fails, no AI provider call should happen.

## AI job flow

Correct flow:

1. Flutter sends generation request to backend.
2. Backend validates CID session.
3. Backend checks credits or Pro entitlement.
4. Backend creates pending AI job.
5. Backend reserves or holds required credits.
6. Worker sends request to AI provider.
7. AI provider returns result.
8. Result is saved to object/video storage.
9. Database stores metadata only.
10. Backend marks job completed.
11. Flutter displays result from storage/CDN.

## Failure flow

If generation fails:

- Job status becomes failed.
- Reserved credits are released or refunded.
- Failure reason is sanitized.
- Provider secrets and raw errors are not shown to Flutter.
- No fake result is created.

## Credit usage examples

AI image generation:
- Low cost
- Small output size
- Good for profile images, post visuals, thumbnails, stickers

AI video generation:
- High cost
- Large output size
- Requires strict metering
- Should be limited by Pro plan, credits, duration and resolution

Premium effects:
- Medium cost
- Can be charged per effect render or effect unlock

## Suggested credit labels

UI should use simple creator terms:

- AI Credits
- Image generation
- Video generation
- Premium effects
- Draft render
- Final render
- Replay extension
- Proof-ready package

The user should not need to understand GPU, CDN, transcoding or model pricing.

## Storage boundary

AI output must be stored in object/video storage.

Database stores only metadata:

- ai_job_id
- owner_cid
- generation_type
- prompt_hash or prompt_summary
- provider_reference_safe_id
- output_media_id
- thumbnail_url
- storage_url or object_key
- credit_cost
- status
- created_at
- completed_at
- expires_at
- safety_status

Database must not store:
- Raw image binary
- Raw video binary
- Provider secret
- Raw access token
- Payment token
- Wallet private key
- Unsafe prompt payload if policy requires redaction

## Retention

Free users:
- Limited preview retention
- Limited draft storage
- No unlimited AI archive

Pro users:
- Longer retention
- More AI credits
- Higher resolution options
- Larger storage quota

Paid extension:
- Can extend retention
- Can upgrade quality
- Can unlock proof-ready packaging

## Queue and worker requirement

AI generation should use a queue.

Needed worker tasks:
- Validate generation job
- Call AI provider
- Save output to storage
- Generate thumbnail
- Update metadata
- Handle retry/failure
- Refund/release credits when needed

The main API should not block while video generation runs.

## Safety and moderation

AI requests should pass safety checks before provider call.

Generated results should also be checked before public publishing.

Unsafe or blocked content:
- Should not consume final credits unless provider cost already occurred
- Should not become public creator media
- Should not be proof-ready

## Wallet and payment boundary

M10C does not open real payments.

Credits may later be purchased through:
- CidenBridge wallet/payment gateway
- Pro subscription
- Gift/support conversion
- Admin/test grant

But M10C does not implement:
- Real wallet
- Real payment
- Token transfer
- Blockchain transaction
- NFT mint
- Creator payout

## Future implementation order

Recommended future order:

1. Add backend credit ledger contract.
2. Add AI job database schema.
3. Add object storage bucket contract.
4. Add queue worker skeleton.
5. Add Flutter AI creation preview UI.
6. Add disabled backend route for AI job request.
7. Add credit check without provider call.
8. Add provider adapter behind server-side env keys.
9. Add storage save flow.
10. Add safe result display.

## Locked boundaries

M10C is planning only.

No code changes.
No AI provider call.
No GPU/API key.
No real credit deduction.
No payment route.
No wallet route.
No blockchain transaction.
No NFT mint.
No upload/storage implementation.
No fake credit balance.
No fake Pro plan.
No fake AI result.
No fake CID/session.
