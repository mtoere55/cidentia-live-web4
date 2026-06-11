import 'package:authentication_client/authentication_client.dart';
import 'package:app_ui/app_ui.dart';
import 'package:database_client/database_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/auth/auth.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:user_repository/user_repository.dart';

void main() {
  final userRepository = UserRepository(
    databaseClient: _PreviewDatabaseClient(),
    authenticationClient: _PreviewAuthenticationClient(),
  );

  runApp(_OriginalClonePreviewApp(userRepository: userRepository));
}

class _OriginalClonePreviewApp extends StatelessWidget {
  const _OriginalClonePreviewApp({required this.userRepository});

  final UserRepository userRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: userRepository,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Instagram',
        theme: const AppTheme().theme,
        darkTheme: const AppDarkTheme().theme,
        themeMode: ThemeMode.dark,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AuthPage(),
      ),
    );
  }
}

class _PreviewAuthenticationClient implements AuthenticationClient {
  final _controller = Stream<AuthenticationUser>.value(
    AuthenticationUser.anonymous,
  ).asBroadcastStream();

  @override
  Stream<AuthenticationUser> get user => _controller;

  @override
  Future<void> logInWithPassword({
    required String password,
    String? email,
    String? phone,
  }) async {}

  @override
  Future<void> logInWithGoogle() async {}

  @override
  Future<void> logInWithGithub() async {}

  @override
  Future<void> signUpWithPassword({
    required String password,
    required String fullName,
    required String username,
    String? avatarUrl,
    String? email,
    String? phone,
    String? pushToken,
  }) async {}

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    String? redirectTo,
  }) async {}

  @override
  Future<void> resetPassword({
    required String token,
    required String email,
    required String newPassword,
  }) async {}

  @override
  Future<void> logOut() async {}
}

class _PreviewDatabaseClient extends DatabaseClient {
  @override
  String? get currentUserId => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
