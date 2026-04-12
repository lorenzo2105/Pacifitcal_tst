import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

/// Service de configuration Firebase App Check
/// Protection anti-bot et CSRF sur les requêtes Firebase
class AppCheckService {
  static Future<void> initialize() async {
    try {
      await FirebaseAppCheck.instance.activate(
        // En debug : utiliser le debug provider (tokens illimités)
        // En production : utiliser DeviceCheck (iOS) ou Play Integrity (Android)
        androidProvider: kDebugMode
            ? AndroidProvider.debug
            : AndroidProvider.playIntegrity,
        
        appleProvider: kDebugMode
            ? AppleProvider.debug
            : AppleProvider.deviceCheck,
        
        // Provider web (reCAPTCHA v3)
        webProvider: ReCaptchaV3Provider('YOUR_RECAPTCHA_SITE_KEY'),
      );

      if (kDebugMode) {
        print('✅ Firebase App Check activé (mode debug)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Erreur Firebase App Check: $e');
        print('💡 App Check nécessite un plan Blaze pour la production');
        print('   En développement, les tokens debug sont utilisés');
      }
    }
  }

  /// Obtenir un token App Check (pour vérification manuelle si nécessaire)
  static Future<String?> getToken() async {
    try {
      final token = await FirebaseAppCheck.instance.getToken();
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur récupération token App Check: $e');
      }
      return null;
    }
  }
}
