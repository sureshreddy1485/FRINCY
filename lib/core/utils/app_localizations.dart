import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  Future<bool> load() async {
    try {
      String jsonString = await rootBundle.loadString(
        'assets/lang/${locale.languageCode}_${locale.countryCode}.json',
      );
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
      return true;
    } catch (e) {
      // Fallback to English if translation file not found
      String jsonString = await rootBundle.loadString('assets/lang/en_US.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
      return true;
    }
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Common translations
  String get appName => translate('app_name');
  String get login => translate('login');
  String get signup => translate('signup');
  String get email => translate('email');
  String get password => translate('password');
  String get phoneNumber => translate('phone_number');
  String get name => translate('name');
  String get customers => translate('customers');
  String get transactions => translate('transactions');
  String get reports => translate('reports');
  String get settings => translate('settings');
  String get addCustomer => translate('add_customer');
  String get addTransaction => translate('add_transaction');
  String get credit => translate('credit');
  String get debit => translate('debit');
  String get amount => translate('amount');
  String get date => translate('date');
  String get notes => translate('notes');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get search => translate('search');
  String get youWillGet => translate('you_will_get');
  String get youWillGive => translate('you_will_give');
  String get totalBalance => translate('total_balance');
  String get reminder => translate('reminder');
  String get sendReminder => translate('send_reminder');
  String get export => translate('export');
  String get backup => translate('backup');
  String get restore => translate('restore');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'ta', 'te', 'kn', 'ml'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
