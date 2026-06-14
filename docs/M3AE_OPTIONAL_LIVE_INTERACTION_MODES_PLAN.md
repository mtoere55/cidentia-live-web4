# M3AE Optional Live Interaction Modes Plan

Status: product plan only, no code patch

Purpose:
Define optional Live Room interaction modes for Cidentia.Live before UI coding.

Core rule:
Normal Live Room is the base experience.
VS, Battle, Multi Guest, Support, Effect, Achievement and NFT-ready moments are optional modes.
They can be enabled by the creator or selected as a live format.
They are not mandatory for every stream.

Optional modes:
1. Normal Live Room
   - Default live room
   - Chat, viewers, signal, proof-safe preview
   - No battle pressure

2. VS / Battle Room
   - Two creators side by side
   - Score bar
   - Timer / round
   - Support and Signal events affect visual score preview
   - Used only when creator starts a battle

3. Multi Guest Room
   - Host plus multiple guests
   - Grid layout
   - Guest request / invite preview
   - Good for community rooms, panels and group live

4. Support / Effect Mode
   - Viewer can send local-preview support signal
   - Effects appear as visual reactions
   - No real payment, token, wallet or gift transaction

5. Achievement Moment
   - End-of-live or milestone preview
   - Live streak, proof reaction, creator support, community signal
   - Can become NFT-ready later but does not mint anything now

Cidentia language:
- Like becomes Signal
- Gift becomes Support
- Random effect becomes Earned Effect
- Badge becomes Proof / Achievement
- NFT becomes NFT-ready Moment
- Battle becomes Signal Battle / CID Battle

Boundaries:
- No backend
- No CidenDB/OTP
- No RTMP
- No wallet
- No token
- No payment
- No blockchain
- No minting
- No fake balance
- No fake reward claim
- No real stream

Next milestone:
M3AF Live Room Optional Mode Preview
- Add local-only optional mode selector
- Normal / VS Battle / Multi Guest preview states
- Keep existing Live Studio and Live Room boundaries closed
