# M5N-B — Native Continuous OCR Loop

M5N-B adds native continuous OCR capture for the Social Translate floating bubble.

Opened:
- native startLiveSocialOcrLoop bridge
- native stopLiveSocialOcrLoop bridge
- one user-approved MediaProjection session stays open
- visible screen is captured repeatedly
- ML Kit OCR updates the local approved OCR cache
- Flutter loop reads the cache and updates the floating bubble translation
- Start live translate / Stop live translate UI

Still locked:
- no automatic message sending
- no Accessibility automation
- no hidden WhatsApp reading
- no WhatsApp database access
- no backend upload
- no account/login control

Safety:
The loop only reads visible screen pixels after user approval and keeps a visible foreground capture notification.
