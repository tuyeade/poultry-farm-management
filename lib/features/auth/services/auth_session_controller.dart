import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthSessionController extends ChangeNotifier {
  AuthSessionController({bool startWithPasswordRecovery = false}) {
    final auth = Supabase.instance.client.auth;

    _isPasswordRecovery = startWithPasswordRecovery;
    _splashTimer = Timer(const Duration(seconds: 3), () {
      _isSplashComplete = true;
      notifyListeners();
    });

    // Supabase restores the persisted session during initialization.
    _session = auth.currentSession;
    debugPrint('AUTH STARTUP SESSION: ${_session != null ? "FOUND" : "NONE"}');

    // Listen for login, logout, token refresh, etc.
    _subscription = auth.onAuthStateChange.listen(_handleAuthState);

    // Initial session check is complete.
    _isInitialized = true;
  }

  late final StreamSubscription<AuthState> _subscription;
  late final Timer _splashTimer;

  Session? _session;

  bool _isInitialized = false;
  bool _isPasswordRecovery = false;
  bool _isSplashComplete = false;

  bool get isInitialized => _isInitialized;

  bool get isAuthenticated => _session != null;

  bool get isPasswordRecovery => _isPasswordRecovery;

  bool get isSplashComplete => _isSplashComplete;

  Session? get session => _session;

  void _handleAuthState(AuthState state) {
    _session = state.session;

    _isPasswordRecovery = state.event == AuthChangeEvent.passwordRecovery;

    _isInitialized = true;

    notifyListeners();
  }

  @override
  void dispose() {
    _splashTimer.cancel();
    _subscription.cancel();
    super.dispose();
  }
}
