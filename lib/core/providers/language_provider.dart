import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/preferences_service.dart';
import 'app_providers.dart';

/// Provider for managing app language/locale
final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  final preferencesAsync = ref.watch(preferencesServiceProvider);
  return LanguageNotifier(preferencesAsync);
});

class LanguageNotifier extends StateNotifier<Locale> {
  final AsyncValue<PreferencesService> _preferencesAsync;
  PreferencesService? _preferences;

  LanguageNotifier(this._preferencesAsync) : super(const Locale('en')) {
    _loadLanguage();
  }

  /// Load saved language preference
  Future<void> _loadLanguage() async {
    _preferencesAsync.when(
      data: (prefs) {
        _preferences = prefs;
        final languageCode = prefs.getLanguage();
        state = Locale(languageCode);
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  /// Change app language
  Future<void> setLanguage(String languageCode) async {
    state = Locale(languageCode);
    if (_preferences != null) {
      await _preferences!.setLanguage(languageCode);
    }
  }

  /// Toggle between English and Spanish
  Future<void> toggleLanguage() async {
    final newLanguage = state.languageCode == 'en' ? 'es' : 'en';
    await setLanguage(newLanguage);
  }
}
