enum CidentiaGateLanguage { tr, en, de }

enum CidentiaAuthStatus { signedOut, signingIn, signedIn }

enum CidentiaAuthRequirement {
  publicBrowse,
  authRequired,
  cidRequired,
  ownerOnly,
  creatorRequired,
  walletRequired,
}

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
}

class CidentiaAuthGateContract {
  const CidentiaAuthGateContract._();

  static const identityAuthority = 'CidenDB';
  static const onboardingAuthority = 'CidentiaApp';
  static const liveAppRole =
      'Cidentia.Live accepts verified CID sessions only.';

  static const publicAreas = <String>[
    'feed.view',
    'reels.view',
    'profile.publicView',
    'live.watchPublic',
    'search.view',
  ];

  static const protectedActions =
      <CidentiaProtectedAction, Set<CidentiaAuthRequirement>>{
        CidentiaProtectedAction.editProfile: {
          CidentiaAuthRequirement.authRequired,
          CidentiaAuthRequirement.cidRequired,
          CidentiaAuthRequirement.ownerOnly,
        },
        CidentiaProtectedAction.connectWallet: {
          CidentiaAuthRequirement.authRequired,
          CidentiaAuthRequirement.cidRequired,
          CidentiaAuthRequirement.walletRequired,
        },
        CidentiaProtectedAction.manageProof: {
          CidentiaAuthRequirement.authRequired,
          CidentiaAuthRequirement.cidRequired,
        },
        CidentiaProtectedAction.followUser: {
          CidentiaAuthRequirement.authRequired,
          CidentiaAuthRequirement.cidRequired,
        },
        CidentiaProtectedAction.likePost: {
          CidentiaAuthRequirement.authRequired,
          CidentiaAuthRequirement.cidRequired,
        },
        CidentiaProtectedAction.commentPost: {
          CidentiaAuthRequirement.authRequired,
          CidentiaAuthRequirement.cidRequired,
        },
        CidentiaProtectedAction.sharePost: {
          CidentiaAuthRequirement.authRequired,
          CidentiaAuthRequirement.cidRequired,
        },
        CidentiaProtectedAction.savePost: {
          CidentiaAuthRequirement.authRequired,
          CidentiaAuthRequirement.cidRequired,
        },
        CidentiaProtectedAction.sendMessage: {
          CidentiaAuthRequirement.authRequired,
          CidentiaAuthRequirement.cidRequired,
        },
        CidentiaProtectedAction.startLive: {
          CidentiaAuthRequirement.authRequired,
          CidentiaAuthRequirement.cidRequired,
          CidentiaAuthRequirement.creatorRequired,
        },
        CidentiaProtectedAction.inviteLiveGuest: {
          CidentiaAuthRequirement.authRequired,
          CidentiaAuthRequirement.cidRequired,
        },
        CidentiaProtectedAction.shareScreen: {
          CidentiaAuthRequirement.authRequired,
          CidentiaAuthRequirement.cidRequired,
          CidentiaAuthRequirement.creatorRequired,
        },
        CidentiaProtectedAction.manageLiveDestination: {
          CidentiaAuthRequirement.authRequired,
          CidentiaAuthRequirement.cidRequired,
          CidentiaAuthRequirement.creatorRequired,
        },
        CidentiaProtectedAction.uploadMedia: {
          CidentiaAuthRequirement.authRequired,
          CidentiaAuthRequirement.cidRequired,
        },
      };

  static bool requiresVerifiedCid(CidentiaProtectedAction action) {
    return protectedActions[action]?.contains(
          CidentiaAuthRequirement.cidRequired,
        ) ??
        false;
  }

  static String messageFor(
    CidentiaProtectedAction action,
    CidentiaGateLanguage language,
  ) {
    switch (language) {
      case CidentiaGateLanguage.tr:
        return 'Bu işlem için CidenDB tarafından doğrulanmış CID oturumu '
            'gerekir.';
      case CidentiaGateLanguage.en:
        return 'This action requires a CidenDB verified CID '
            'session.';
      case CidentiaGateLanguage.de:
        return 'Diese Aktion erfordert eine von CidenDB bestätigte '
            'CID-Sitzung.';
    }
  }
}
