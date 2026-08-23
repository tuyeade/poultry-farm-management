import 'package:go_router/go_router.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/update_password_page.dart';
import '../features/auth/services/auth_session_controller.dart';
import '../features/navigation/presentation/pages/main_page.dart';
import '../features/splash/presentation/pages/splash_page.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String updatePassword = '/update-password';

  static GoRouter create(AuthSessionController auth) {
    return GoRouter(
      initialLocation: splash,
      refreshListenable: auth,
      redirect: (context, state) {
        final location = state.matchedLocation;
        if (location == splash && !auth.isSplashComplete) {
          return null;
        }
        if (!auth.isInitialized) {
          return location == splash ? null : splash;
        }
        if (auth.isPasswordRecovery) {
          return location == updatePassword ? null : updatePassword;
        }
        if (!auth.isAuthenticated) {
          return location == login ? null : login;
        }
        if (location == splash || location == login) return dashboard;
        return null;
      },
      routes: [
        GoRoute(path: splash, builder: (_, _) => const SplashPage()),
        GoRoute(path: login, builder: (_, _) => const LoginPage()),
        GoRoute(path: dashboard, builder: (_, _) => const MainPage()),
        GoRoute(
          path: updatePassword,
          builder: (_, _) => const UpdatePasswordPage(),
        ),
      ],
    );
  }
}
