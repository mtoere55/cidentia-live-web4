enum CidentiaSessionStatus { signedOut, otpRequested, signedIn }

class CidentiaSessionState {
  const CidentiaSessionState({
    required this.status,
    this.identifier,
    this.cid,
    this.displayName,
    this.message,
  });

  const CidentiaSessionState.signedOut()
    : status = CidentiaSessionStatus.signedOut,
      identifier = null,
      cid = null,
      displayName = null,
      message = null;

  final CidentiaSessionStatus status;
  final String? identifier;
  final String? cid;
  final String? displayName;
  final String? message;

  bool get isSignedIn => status == CidentiaSessionStatus.signedIn;
  bool get hasVerifiedCid => cid != null && cid!.trim().isNotEmpty;

  CidentiaSessionState copyWith({
    CidentiaSessionStatus? status,
    String? identifier,
    String? cid,
    String? displayName,
    String? message,
  }) {
    return CidentiaSessionState(
      status: status ?? this.status,
      identifier: identifier ?? this.identifier,
      cid: cid ?? this.cid,
      displayName: displayName ?? this.displayName,
      message: message ?? this.message,
    );
  }
}
