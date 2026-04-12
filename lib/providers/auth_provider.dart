import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pacifitcal/models/user_model.dart';
import 'package:pacifitcal/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = true;
  String? _error;
  StreamSubscription<User?>? _authSubscription;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isSubscriptionExpired =>
      _currentUser?.isSubscriptionExpired ?? false;

  AuthProvider() {
    _init();
  }

  void _init() {
    try {
      _authSubscription = _authService.authStateChanges.listen(
        (user) async {
          try {
            if (user != null) {
              final userData = await _authService.getUserData(user.uid);

              // Vérifier si le compte est désactivé
              if (userData != null && !userData.active) {
                if (kDebugMode) {
                  print('⚠️ Compte désactivé détecté, déconnexion...');
                }
                await _authService.signOut();
                _currentUser = null;
                _error =
                    'Votre compte a été désactivé. Contactez l\'administrateur.';
              } else {
                _currentUser = userData;
              }
            } else {
              _currentUser = null;
            }
          } catch (e) {
            if (kDebugMode) {
              print('❌ Erreur lors du chargement des données utilisateur: $e');
            }
            _currentUser = null;
          }
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          if (kDebugMode) {
            print('❌ Erreur dans le stream d\'authentification: $error');
          }
          _isLoading = false;
          _currentUser = null;
          notifyListeners();
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de l\'initialisation de l\'authentification: $e');
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authService.signIn(email, password);
    } on Exception catch (e) {
      _error = _parseError(e.toString());
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
  }) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authService.register(
        nom: nom,
        prenom: prenom,
        email: email,
        password: password,
      );
    } on Exception catch (e) {
      _error = _parseError(e.toString());
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    if (_currentUser == null) return;
    try {
      final updatedUser = await _authService.getUserData(_currentUser!.id);
      if (updatedUser != null) {
        _currentUser = updatedUser;
      }
    } catch (e) {
      // Ignorer les erreurs de refresh, les données seront mises à jour au prochain authStateChanges
      if (kDebugMode) {
        debugPrint('⚠️ Erreur refresh user: $e');
      }
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _parseError(String raw) {
    if (raw.contains('user-not-found') ||
        raw.contains('wrong-password') ||
        raw.contains('invalid-credential')) {
      return 'Email ou mot de passe incorrect.';
    }
    if (raw.contains('email-already-in-use')) {
      return 'Cet email est déjà utilisé.';
    }
    if (raw.contains('weak-password')) {
      return 'Mot de passe trop faible (minimum 6 caractères).';
    }
    if (raw.contains('network-request-failed')) {
      return 'Erreur réseau. Vérifiez votre connexion.';
    }
    if (raw.contains('Compte désactivé')) {
      return 'Compte désactivé. Contactez l\'administrateur.';
    }
    return 'Une erreur est survenue. Réessayez.';
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
