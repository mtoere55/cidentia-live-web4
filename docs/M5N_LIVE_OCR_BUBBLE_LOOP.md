# M5N-A — Live OCR Bubble Update Loop

M5N-A adds an auto-update loop for the Social Translate floating bubble.

Opened:
- Start auto translate
- Stop auto translate
- 3-second timer loop
- latest approved OCR cache is read repeatedly
- if OCR text changes, Turkish translation is pushed to the floating bubble
- duplicate bubble updates are skipped

Still locked:
- no automatic WhatsApp sending
- no Accessibility automation
- no hidden WhatsApp reading
- no backend upload
- no account/login control

Important:
This patch updates the bubble from the latest approved OCR result. Native continuous screen capture is reserved for M5N-B.
