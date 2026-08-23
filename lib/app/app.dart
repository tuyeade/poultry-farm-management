import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'theme/app_theme.dart';
import 'router.dart';
import 'localization/generated/app_localizations.dart';
import 'localization/language_provider.dart';
import '../features/splash/presentation/pages/splash_page.dart';
import '../features/auth/services/auth_session_controller.dart';

class PoultryFarmApp extends ConsumerStatefulWidget {
  final bool startWithPasswordRecovery;
  final bool enableAuthListener;

  const PoultryFarmApp({
    super.key,
    this.startWithPasswordRecovery = false,
    this.enableAuthListener = true,
  });

  @override
  ConsumerState<PoultryFarmApp> createState() => _PoultryFarmAppState();
}

class _PoultryFarmAppState extends ConsumerState<PoultryFarmApp> {
  AuthSessionController? _auth;
  GoRouter? _router;

  @override
  void initState() {
    super.initState();

    if (widget.enableAuthListener) {
      _auth = AuthSessionController(
        startWithPasswordRecovery: widget.startWithPasswordRecovery,
      );
      _router = AppRouter.create(_auth!);
    }
  }

  @override
  void dispose() {
    _router?.dispose();
    _auth?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = _router;
    final locale = ref.watch(languageProvider);

    if (router == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Poultry Farm Manager',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        locale: locale,
        localizationsDelegates:
            AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SplashPage(),
      );
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Poultry Farm Manager',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      locale: locale,
      localizationsDelegates:
          AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}