# M14J Cover Upload Boundary QA

M14J verifies the Flutter profile cover upload boundary after M14I.

## Branch

m14j-cover-upload-boundary-qa

## Verified behavior

The user signs in with a verified CidenDB/CID session, opens:

Profile > Edit Profile > Hero cover

Then selects a cover image.

The Flutter profile cover picker calls the guarded upload boundary:

/api/upload/request

The runtime response is:

UPLOAD_ROUTE_DISABLED

## Result

This confirms that the Flutter side reaches the upload boundary with the verified profile/CID flow, while the production upload route remains locked.

## Locked boundaries preserved

- No real object storage PUT was opened from Flutter.
- No media metadata write was opened.
- No profile database write was opened.
- No public media publish was opened.
- No fake CID/session/token was created.
- Guest users remain protected by the CID boundary.

## Status

M14J QA is sealed as a locked-boundary runtime verification.
