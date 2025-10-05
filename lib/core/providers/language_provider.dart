import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en', 'US');

  Locale get locale => _locale;

  LanguageProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    final countryCode = prefs.getString('country_code') ?? 'US';
    
    _locale = Locale(languageCode, countryCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    await prefs.setString('country_code', locale.countryCode ?? '');
  }

  List<Map<String, String>> get supportedLanguages => [
    {'code': 'en_US', 'name': 'English'},
    {'code': 'hi_IN', 'name': 'हिंदी'},
    {'code': 'ta_IN', 'name': 'தமிழ்'},
    {'code': 'te_IN', 'name': 'తెలుగు'},
    {'code': 'kn_IN', 'name': 'ಕನ್ನಡ'},
    {'code': 'ml_IN', 'name': 'മലയാളം'},
  ];
}
