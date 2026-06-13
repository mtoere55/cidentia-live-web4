import 'package:flutter/widgets.dart';

import 'cidentia_session_state.dart';

class CidentiaSessionScope extends InheritedWidget {
  const CidentiaSessionScope({
    required this.session,
    required super.child,
    super.key,
  });

  final CidentiaSessionState session;

  static CidentiaSessionState? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CidentiaSessionScope>()
        ?.session;
  }

  @override
  bool updateShouldNotify(CidentiaSessionScope oldWidget) {
    return oldWidget.session != session;
  }
}
