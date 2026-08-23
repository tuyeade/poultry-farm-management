import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _languagePreferenceKey = 'language_code';

final languageProvider =
    NotifierProvider<LanguageNotifier, Locale>(LanguageNotifier.new);

class LanguageNotifier extends Notifier<Locale> {
  bool _hasExplicitSelection = false;
  bool _disposed = false;

  @override
  Locale build() {
    ref.onDispose(() => _disposed = true);
    _restoreLanguage();
    return const Locale('en');
  }

  void setLanguage(String languageCode) {
    _hasExplicitSelection = true;
    state = Locale(languageCode);
    _persistLanguage(languageCode);
  }

  Future<void> _restoreLanguage() async {
    final preferences = await SharedPreferences.getInstance();
    final languageCode = preferences.getString(_languagePreferenceKey);
    if (_disposed || _hasExplicitSelection || languageCode == null) return;

    state = Locale(languageCode);
  }

  Future<void> _persistLanguage(String languageCode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_languagePreferenceKey, languageCode);
  }
}