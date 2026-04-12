/// Gestion du versioning des schémas de données
/// Permet la rétrocompatibilité et les migrations futures
class SchemaVersion {
  /// Version actuelle du schéma de l'application
  static const int current = 1;

  /// Versions des différents modèles
  static const int userModelVersion = 1;
  static const int classModelVersion = 1;
  static const int reservationModelVersion = 1;
  static const int templateModelVersion = 1;

  /// Vérifier si une migration est nécessaire
  static bool needsMigration(int? storedVersion, int currentVersion) {
    if (storedVersion == null) return false; // Nouveau document
    return storedVersion < currentVersion;
  }

  /// Obtenir le numéro de version depuis les données Firestore
  static int getVersion(Map<String, dynamic> data, {int defaultVersion = 1}) {
    return data['schema_version'] as int? ?? defaultVersion;
  }

  /// Migrer les données d'une version à l'autre
  static Map<String, dynamic> migrateUserData(
    Map<String, dynamic> data,
    int fromVersion,
  ) {
    var migratedData = Map<String, dynamic>.from(data);

    // Migration v1 → v2 (exemple futur)
    // if (fromVersion < 2) {
    //   migratedData['new_field'] = 'default_value';
    //   migratedData['schema_version'] = 2;
    // }

    // Pour l'instant, pas de migration nécessaire
    migratedData['schema_version'] = userModelVersion;
    return migratedData;
  }

  /// Migrer les données de classe
  static Map<String, dynamic> migrateClassData(
    Map<String, dynamic> data,
    int fromVersion,
  ) {
    var migratedData = Map<String, dynamic>.from(data);

    // Migrations futures ici
    // if (fromVersion < 2) {
    //   // Ajouter nouveaux champs
    // }

    migratedData['schema_version'] = classModelVersion;
    return migratedData;
  }

  /// Migrer les données de réservation
  static Map<String, dynamic> migrateReservationData(
    Map<String, dynamic> data,
    int fromVersion,
  ) {
    var migratedData = Map<String, dynamic>.from(data);

    // Migrations futures ici
    migratedData['schema_version'] = reservationModelVersion;
    return migratedData;
  }

  /// Log de migration (debug uniquement)
  static void logMigration(
    String modelType,
    String documentId,
    int fromVersion,
    int toVersion,
  ) {
    // En production, envoyer à un service de monitoring
    print('🔄 Migration $modelType [$documentId]: v$fromVersion → v$toVersion');
  }
}
