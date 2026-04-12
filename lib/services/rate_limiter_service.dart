import 'package:shared_preferences/shared_preferences.dart';

/// Service de limitation des tentatives de connexion
/// Protection contre les attaques par force brute
class RateLimiterService {
  static const String _keyPrefix = 'login_attempts_';
  static const String _keyLockUntil = 'login_lock_until_';
  static const int maxAttempts = 5;
  static const int lockDurationMinutes = 15;

  /// Vérifier si l'utilisateur est bloqué
  static Future<BlockStatus> checkBlock(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final lockKey = _keyLockUntil + email.toLowerCase();
    final lockUntilTimestamp = prefs.getInt(lockKey);

    if (lockUntilTimestamp != null) {
      final lockUntil = DateTime.fromMillisecondsSinceEpoch(lockUntilTimestamp);
      final now = DateTime.now();

      if (now.isBefore(lockUntil)) {
        final remainingMinutes = lockUntil.difference(now).inMinutes + 1;
        return BlockStatus(
          isBlocked: true,
          remainingMinutes: remainingMinutes,
        );
      } else {
        // Le blocage a expiré, nettoyer
        await prefs.remove(lockKey);
        await prefs.remove(_keyPrefix + email.toLowerCase());
      }
    }

    return BlockStatus(isBlocked: false, remainingMinutes: 0);
  }

  /// Enregistrer une tentative échouée
  static Future<int> recordFailedAttempt(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final attemptsKey = _keyPrefix + email.toLowerCase();
    final attempts = (prefs.getInt(attemptsKey) ?? 0) + 1;

    await prefs.setInt(attemptsKey, attempts);

    // Si nombre max atteint, bloquer le compte
    if (attempts >= maxAttempts) {
      final lockUntil = DateTime.now().add(Duration(minutes: lockDurationMinutes));
      await prefs.setInt(
        _keyLockUntil + email.toLowerCase(),
        lockUntil.millisecondsSinceEpoch,
      );
    }

    return attempts;
  }

  /// Réinitialiser les tentatives après connexion réussie
  static Future<void> resetAttempts(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final emailLower = email.toLowerCase();
    await prefs.remove(_keyPrefix + emailLower);
    await prefs.remove(_keyLockUntil + emailLower);
  }

  /// Obtenir le nombre de tentatives restantes
  static Future<int> getRemainingAttempts(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = prefs.getInt(_keyPrefix + email.toLowerCase()) ?? 0;
    return maxAttempts - attempts;
  }
}

/// Statut de blocage d'un utilisateur
class BlockStatus {
  final bool isBlocked;
  final int remainingMinutes;

  BlockStatus({required this.isBlocked, required this.remainingMinutes});
}
