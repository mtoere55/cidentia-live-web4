class CidentiaSessionState {
  const CidentiaSessionState._({
    required this.hasVerifiedCid,
    required this.backendAuthorized,
    this.cid,
    this.displayName,
    this.email,
    this.message,
  });

  const CidentiaSessionState.signedOut()
    : this._(
        hasVerifiedCid: false,
        backendAuthorized: false,
        cid: null,
        displayName: null,
        email: null,
        message: 'Signed out. Verified CidenDB/CID session required.',
      );

  const CidentiaSessionState.previewVerified({
    required String cid,
    String? displayName,
    String? email,
    String? message,
  }) : this._(
         hasVerifiedCid: true,
         backendAuthorized: false,
         cid: cid,
         displayName: displayName,
         email: email,
         message: message ?? 'CID confirmed by CidenDB. Preview only; publishing requires production backend session.',
       );

  const CidentiaSessionState.verified({
    required String cid,
    String? displayName,
    String? email,
    String? message,
    bool backendAuthorized = false,
  }) : this._(
         hasVerifiedCid: true,
         backendAuthorized: backendAuthorized,
         cid: cid,
         displayName: displayName,
         email: email,
         message: message,
       );

  final bool hasVerifiedCid;
  // Preview identity is not production API authorization.
  final bool backendAuthorized;
  final String? cid;
  final String? displayName;
  final String? email;
  final String? message;

  bool canPerformProtectedAction() => hasVerifiedCid && backendAuthorized;

  @override
  String toString() {
    return 'CidentiaSessionState('
        'hasVerifiedCid: $hasVerifiedCid, '
        'backendAuthorized: $backendAuthorized, '
        'cid: $cid, '
        'displayName: $displayName, '
        'email: $email'
        ')';
  }
}
