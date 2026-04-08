import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pacifitcal/config/app_theme.dart';
import 'package:pacifitcal/config/routes.dart';
import 'package:pacifitcal/providers/auth_provider.dart';
import 'package:pacifitcal/providers/class_provider.dart';
import 'package:pacifitcal/providers/reservation_provider.dart';
import 'package:pacifitcal/services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // NotificationService désactivé temporairement (nécessite Google Play Services)
    // await NotificationService().initialize();
  } catch (e, stackTrace) {
    print('❌ Erreur Firebase: $e');
    print('StackTrace: $stackTrace');
  }

  runApp(const PacifitCalApp());
}

class PacifitCalApp extends StatelessWidget {
  const PacifitCalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ClassProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp.router(
            title: 'PacifitCal',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            routerConfig: AppRouter.router(authProvider),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('fr', 'FR'),
              Locale('en', 'US'),
            ],
            locale: const Locale('fr', 'FR'),
          );
        },
      ),
    );
  }
}
