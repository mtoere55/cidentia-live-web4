enum CidentiaProtectedAction {
  editProfile,
  connectWallet,
  manageProof,
  followUser,
  likePost,
  commentPost,
  sharePost,
  savePost,
  sendMessage,
  startLive,
  inviteLiveGuest,
  shareScreen,
  manageLiveDestination,
  uploadMedia,
  publishMedia,
}

enum CidentiaGateLanguage { tr, en, de }

class CidentiaAuthGateContract {
  const CidentiaAuthGateContract._();

  static bool get cidentiaLiveCreatesIdentity => false;
  static bool get cidentiaLiveStoresFrontendSecrets => false;
  static bool get fakeLoginAllowed => false;
  static bool get fakeVerifiedCidAllowed => false;

  static const publicSurfaces = <String>[
    'Feed',
    'Search',
    'Reels',
    'Story discovery',
    'Live discovery',
    'Live Room preview',
    'Create local preview',
  ];

  static const protectedSurfaces = <String>[
    'Chats real messaging',
    'Live Studio real streaming',
    'Profile management',
    'Wallet',
    'Proof management',
    'Upload',
    'Publish',
  ];

  static String titleFor(CidentiaProtectedAction action) {
    switch (action) {
      case CidentiaProtectedAction.editProfile:
        return 'Edit Profile';
      case CidentiaProtectedAction.connectWallet:
        return 'Wallet';
      case CidentiaProtectedAction.manageProof:
        return 'Proof';
      case CidentiaProtectedAction.followUser:
        return 'Follow';
      case CidentiaProtectedAction.likePost:
        return 'Like';
      case CidentiaProtectedAction.commentPost:
        return 'Comment';
      case CidentiaProtectedAction.sharePost:
        return 'Share';
      case CidentiaProtectedAction.savePost:
        return 'Save';
      case CidentiaProtectedAction.sendMessage:
        return 'Message';
      case CidentiaProtectedAction.startLive:
        return 'Start Live';
      case CidentiaProtectedAction.inviteLiveGuest:
        return 'Invite Guest';
      case CidentiaProtectedAction.shareScreen:
        return 'Share Screen';
      case CidentiaProtectedAction.manageLiveDestination:
        return 'Live Destination';
      case CidentiaProtectedAction.uploadMedia:
        return 'Upload Media';
      case CidentiaProtectedAction.publishMedia:
        return 'Publish Media';
    }
  }

  static String messageFor(
    CidentiaProtectedAction action, [
    CidentiaGateLanguage language = CidentiaGateLanguage.tr,
  ]) {
    final title = titleFor(action);

    switch (language) {
      case CidentiaGateLanguage.tr:
        return '$title gerçek işlemi için doğrulanmış CidenDB/CID oturumu gerekir. '
            'Bu local preview sahte giriş, frontend token veya gerçek backend çağrısı açmaz.';
      case CidentiaGateLanguage.en:
        return '$title requires a verified CidenDB/CID session. '
            'This local preview does not open fake login, frontend tokens, or real backend calls.';
      case CidentiaGateLanguage.de:
        return '$title benötigt eine verifizierte CidenDB/CID-Sitzung. '
            'Diese lokale Vorschau öffnet keinen Fake-Login, keine Frontend-Tokens und keine echten Backend-Aufrufe.';
    }
  }
}
