import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/services/database_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/notification_service.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/customer_provider.dart';
import 'core/providers/transaction_provider.dart';
import 'core/providers/language_provider.dart';
import 'core/utils/app_localizations.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/home/home_screen.dart';
import 'ui/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize Database
  await DatabaseService.instance.initialize();
  
  // Initialize Notifications
  await NotificationService.instance.initialize();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            title: 'Frincy',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: languageProvider.locale,
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('hi', 'IN'),
              Locale('ta', 'IN'),
              Locale('te', 'IN'),
              Locale('kn', 'IN'),
              Locale('ml', 'IN'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}
