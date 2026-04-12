import 'package:flutter/foundation.dart';

/// Gestionnaire d'erreurs centralisé pour mapper les erreurs techniques
/// en messages utilisateur conviviaux (protection contre la fuite d'informations)
class ErrorHandler {
  /// Mapper une exception à un message utilisateur générique
  static String getUserMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Erreurs Firebase Auth
    if (_isAuthError(errorString)) {
      return _mapAuthError(errorString);
    }

    // Erreurs Firestore
    if (_isFirestoreError(errorString)) {
      return _mapFirestoreError(errorString);
    }

    // Erreurs réseau
    if (_isNetworkError(errorString)) {
      return 'Erreur de connexion. Vérifiez votre réseau et réessayez.';
    }

    // Erreurs de permission
    if (_isPermissionError(errorString)) {
      return 'Action non autorisée. Contactez un administrateur.';
    }

    // Message générique par défaut (ne jamais exposer les détails techniques)
    return 'Une erreur est survenue. Veuillez réessayer ou contacter le support.';
  }

  /// Vérifier si c'est une erreur d'authentification
  static bool _isAuthError(String error) {
    return error.contains('firebase_auth') ||
        error.contains('auth/') ||
        error.contains('user-not-found') ||
        error.contains('wrong-password') ||
        error.contains('email-already-in-use') ||
        error.contains('weak-password') ||
        error.contains('invalid-credential') ||
        error.contains('too-many-requests');
  }

  /// Mapper les erreurs d'authentification
  static String _mapAuthError(String error) {
    if (error.contains('user-not-found') ||
        error.contains('wrong-password') ||
        error.contains('invalid-credential')) {
      return 'Email ou mot de passe incorrect.';
    }
    if (error.contains('email-already-in-use')) {
      return 'Cet email est déjà utilisé.';
    }
    if (error.contains('weak-password')) {
      return 'Mot de passe trop faible. Minimum 12 caractères avec majuscule, minuscule, chiffre et caractère spécial.';
    }
    if (error.contains('too-many-requests')) {
      return 'Trop de tentatives. Veuillez réessayer dans quelques minutes.';
    }
    if (error.contains('network-request-failed')) {
      return 'Erreur réseau. Vérifiez votre connexion.';
    }
    if (error.contains('compte désactivé') ||
        error.contains('account disabled')) {
      return 'Votre compte a été désactivé. Contactez l\'administrateur.';
    }
    return 'Erreur d\'authentification. Veuillez réessayer.';
  }

  /// Vérifier si c'est une erreur Firestore
  static bool _isFirestoreError(String error) {
    return error.contains('firestore') ||
        error.contains('permission-denied') ||
        error.contains('not-found') ||
        error.contains('already-exists') ||
        error.contains('failed-precondition');
  }

  /// Mapper les erreurs Firestore
  static String _mapFirestoreError(String error) {
    if (error.contains('permission-denied')) {
      return 'Accès refusé. Vous n\'avez pas les permissions nécessaires.';
    }
    if (error.contains('not-found')) {
      return 'Document introuvable.';
    }
    if (error.contains('already-exists')) {
      return 'Cet élément existe déjà.';
    }
    if (error.contains('failed-precondition')) {
      return 'Opération impossible. Vérifiez les conditions requises.';
    }
    if (error.contains('cours complet') || error.contains('class full')) {
      return 'Ce cours est complet.';
    }
    if (error.contains('déjà réservé') || error.contains('already booked')) {
      return 'Vous avez déjà réservé ce cours.';
    }
    if (error.contains('abonnement expiré') ||
        error.contains('subscription expired')) {
      return 'Votre abonnement a expiré. Renouvelez-le pour continuer.';
    }
    return 'Erreur lors de l\'opération. Veuillez réessayer.';
  }

  /// Vérifier si c'est une erreur réseau
  static bool _isNetworkError(String error) {
    return error.contains('network') ||
        error.contains('timeout') ||
        error.contains('connection') ||
        error.contains('unreachable') ||
        error.contains('socket');
  }

  /// Vérifier si c'est une erreur de permission
  static bool _isPermissionError(String error) {
    return error.contains('permission') ||
        error.contains('unauthorized') ||
        error.contains('forbidden') ||
        error.contains('access denied');
  }

  /// Mapper les erreurs de réservation (métier)
  static String mapReservationError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('cours complet') ||
        errorString.contains('current_participants')) {
      return 'Ce cours est complet. Réservation impossible.';
    }
    if (errorString.contains('déjà réservé') ||
        errorString.contains('already booked')) {
      return 'Vous avez déjà réservé ce cours.';
    }
    if (errorString.contains('abonnement') ||
        errorString.contains('subscription')) {
      return 'Abonnement requis ou expiré. Contactez l\'administrateur.';
    }

    return getUserMessage(error);
  }

  /// Mapper les erreurs de formulaire utilisateur (admin)
  static String mapUserFormError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('email-already-in-use')) {
      return 'Cet email est déjà utilisé par un autre utilisateur.';
    }
    if (errorString.contains('invalid-email')) {
      return 'Format d\'email invalide.';
    }

    return getUserMessage(error);
  }

  /// Logger l'erreur technique (en debug uniquement)
  static void logError(dynamic error, {StackTrace? stackTrace}) {
    // En production, envoyer à un service de monitoring (Sentry, Crashlytics)
    // En debug, afficher dans la console
    if (kDebugMode && error != null) {
      print('❌ ERROR: $error');
      if (stackTrace != null) {
        print('📍 STACK: $stackTrace');
      }
    }
  }
}
