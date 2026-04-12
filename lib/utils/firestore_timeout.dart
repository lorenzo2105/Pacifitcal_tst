import 'dart:async';

/// Utilitaire pour ajouter des timeouts sur les opérations Firestore
/// Prévient les blocages infinis et améliore l'UX
class FirestoreTimeout {
  /// Timeout par défaut pour les requêtes Firestore (30 secondes)
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Timeout pour les opérations rapides (10 secondes)
  static const Duration shortTimeout = Duration(seconds: 10);

  /// Timeout pour les opérations longues (60 secondes)
  static const Duration longTimeout = Duration(seconds: 60);

  /// Exécuter une Future avec timeout
  /// 
  /// Lance [TimeoutException] si l'opération dépasse [timeout]
  /// 
  /// Exemple :
  /// ```dart
  /// final user = await FirestoreTimeout.run(
  ///   () => firestoreService.getUser(uid),
  ///   timeout: FirestoreTimeout.shortTimeout,
  /// );
  /// ```
  static Future<T> run<T>(
    Future<T> Function() operation, {
    Duration timeout = defaultTimeout,
    String? operationName,
  }) async {
    try {
      return await operation().timeout(
        timeout,
        onTimeout: () {
          final name = operationName ?? 'Opération Firestore';
          throw TimeoutException(
            '$name a dépassé le délai de ${timeout.inSeconds}s',
            timeout,
          );
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Wrapper pour les streams Firestore avec timeout sur le premier élément
  /// 
  /// Assure que le stream initial se charge rapidement
  /// 
  /// Exemple :
  /// ```dart
  /// final usersStream = FirestoreTimeout.stream(
  ///   () => firestoreService.streamUsers(),
  ///   timeout: FirestoreTimeout.defaultTimeout,
  /// );
  /// ```
  static Stream<T> stream<T>(
    Stream<T> Function() streamOperation, {
    Duration timeout = defaultTimeout,
    String? operationName,
  }) {
    final controller = StreamController<T>();
    bool isFirst = true;

    streamOperation().listen(
      (data) {
        if (isFirst) {
          isFirst = false;
        }
        controller.add(data);
      },
      onError: (error) {
        controller.addError(error);
      },
      onDone: () {
        controller.close();
      },
    );

    // Timeout uniquement sur le premier élément
    return controller.stream.timeout(
      timeout,
      onTimeout: (sink) {
        final name = operationName ?? 'Stream Firestore';
        sink.addError(TimeoutException(
          '$name a dépassé le délai de ${timeout.inSeconds}s',
          timeout,
        ));
      },
    );
  }
}
