class CidentiaSessionState {
  const CidentiaSessionState._({
    required this.hasVerifiedCid,
    this.cid,
    this.displayName,
    this.message,
  });

  const CidentiaSessionState.signedOut()
    : this._(
        hasVerifiedCid: false,
        cid: null,
        displayName: null,
        message: 'Signed out. Verified CidenDB/CID session required.',
      );

  const CidentiaSessionState.verified({
    required String cid,
    String? displayName,
    String? message,
  }) : this._(
         hasVerifiedCid: true,
         cid: cid,
         displayName: displayName,
         message: message,
       );

  final bool hasVerifiedCid;
  final String? cid;
  final String? displayName;
  final String? message;

  bool canPerformProtectedAction() => hasVerifiedCid;

  @override
  String toString() {
    return 'CidentiaSessionState('
        'hasVerifiedCid: $hasVerifiedCid, '
        'cid: $cid, '
        'displayName: $displayName'
        ')';
  }
}
