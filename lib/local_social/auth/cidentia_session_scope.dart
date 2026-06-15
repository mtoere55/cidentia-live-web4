import 'package:flutter/widgets.dart';

import 'cidentia_session_state.dart';

class CidentiaSessionScope extends InheritedWidget {
  const CidentiaSessionScope({
    required this.session,
    required super.child,
    this.onSignInRequested,
    super.key,
  });

  final CidentiaSessionState session;
  final VoidCallback? onSignInRequested;

  static CidentiaSessionState? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CidentiaSessionScope>()
        ?.session;
  }

  static CidentiaSessionState of(BuildContext context) {
    return maybeOf(context) ?? const CidentiaSessionState.signedOut();
  }

  static VoidCallback? onSignInRequestedOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CidentiaSessionScope>()
        ?.onSignInRequested;
  }

  @override
  bool updateShouldNotify(CidentiaSessionScope oldWidget) {
    return oldWidget.session != session ||
        oldWidget.onSignInRequested != onSignInRequested;
  }
}
