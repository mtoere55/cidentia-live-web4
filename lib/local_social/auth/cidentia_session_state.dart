class CidentiaSessionState {
  const CidentiaSessionState._({
    required this.hasVerifiedCid,
    this.cid,
    this.displayName,
    this.email,
    this.message,
  });

  const CidentiaSessionState.signedOut()
    : this._(
        hasVerifiedCid: false,
        cid: null,
        displayName: null,
        email: null,
        message: 'Signed out. Verified CidenDB/CID session required.',
      );

  const CidentiaSessionState.verified({
    required String cid,
    String? displayName,
    String? email,
    String? message,
  }) : this._(
         hasVerifiedCid: true,
         cid: cid,
         displayName: displayName,
         email: email,
         message: message,
       );

  final bool hasVerifiedCid;
  final String? cid;
  final String? displayName;
  final String? email;
  final String? message;

  bool canPerformProtectedAction() => hasVerifiedCid;

  @override
  String toString() {
    return 'CidentiaSessionState('
        'hasVerifiedCid: $hasVerifiedCid, '
        'cid: $cid, '
        'displayName: $displayName, '
        'email: $email'
        ')';
  }
}
