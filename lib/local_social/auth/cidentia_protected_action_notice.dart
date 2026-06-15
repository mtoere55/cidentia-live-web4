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
    final message = CidentiaAuthGateContract.messageFor(action, language);
    final requestSignIn = CidentiaSessionScope.onSignInRequestedOf(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        action: requestSignIn == null
            ? null
            : SnackBarAction(label: 'CidenDB', onPressed: requestSignIn),
      ),
    );

    debugPrint('Protected action blocked: $title');
  }
}
