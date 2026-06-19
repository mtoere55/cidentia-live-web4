# M5N-C — Native Direct Bubble Update

M5N-C stabilizes the live OCR bubble update.

Changed:
- one MediaProjection session stays open
- one VirtualDisplay stays open
- one ImageReader stays open
- OCR frames are throttled to about every 3 seconds
- native OCR result updates the floating bubble directly
- Flutter timer is no longer the only path for bubble updates while WhatsApp is foreground

Still locked:
- no automatic WhatsApp sending
- no Accessibility automation
- no hidden WhatsApp reading
- no backend upload
- no account/login control

Expected:
When Start live translate is active and WhatsApp is visible, the bubble text changes as visible screen text changes.
