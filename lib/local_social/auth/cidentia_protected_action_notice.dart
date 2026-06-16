import 'package:flutter/material.dart';

import 'cidentia_auth_gate_contract.dart';
import 'cidentia_session_scope.dart';

class CidentiaProtectedActionNotice {
  const CidentiaProtectedActionNotice._();

  static bool canPerform(BuildContext context, CidentiaProtectedAction action) {
    final session = CidentiaSessionScope.maybeOf(context);

    if (session?.hasVerifiedCid ?? false) {
      return true;
    }

    show(context, action: action);

    return false;
  }

  static void show(
    BuildContext context, {
    required CidentiaProtectedAction action,
    CidentiaGateLanguage language = CidentiaGateLanguage.tr,
  }) {
    final title = CidentiaAuthGateContract.titleFor(action);
    final session = CidentiaSessionScope.maybeOf(context);
    final verified = session?.hasVerifiedCid ?? false;

    final message = verified
        ? _verifiedPreviewMessage(title, session?.cid)
        : CidentiaAuthGateContract.messageFor(action, language);

    final requestSignIn = verified
        ? null
        : CidentiaSessionScope.onSignInRequestedOf(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        action: requestSignIn == null
            ? null
            : SnackBarAction(label: 'CidenDB', onPressed: requestSignIn),
      ),
    );

    debugPrint(
      verified
          ? 'Protected module preview locked after CID verify: $title'
          : 'Protected action blocked: $title',
    );
  }

  static String _verifiedPreviewMessage(String title, String? cid) {
    final cidLine = cid == null ? '' : ' CID: $cid.';
    return '$title is CID verified.$cidLine '
        'This real module is still locked in local preview. '
        'No wallet, payment, token, blockchain, upload, RTMP, or production '
        'backend action is opened here.';
  }
}
