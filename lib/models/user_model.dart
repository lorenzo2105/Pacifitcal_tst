import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pacifitcal/utils/schema_version.dart';

enum UserRole { user, admin }

enum SubscriptionType { oneMonth, sixMonths, twelveMonths }

class UserModel {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final UserRole role;
  final DateTime? subscriptionStart;
  final DateTime? subscriptionEnd;
  final bool active;
  final String? fcmToken;
  final bool weakPassword;
  final int schemaVersion;

  UserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
    this.subscriptionStart,
    this.subscriptionEnd,
    required this.active,
    this.fcmToken,
    this.weakPassword = false,
    this.schemaVersion = SchemaVersion.userModelVersion,
  });

  bool get isAdmin => role == UserRole.admin;

  bool get isSubscriptionExpired {
    if (isAdmin) return false;
    if (subscriptionEnd == null) return true;
    return DateTime.now().isAfter(subscriptionEnd!);
  }

  bool get isActive => active && !isSubscriptionExpired;

  int get daysUntilExpiration {
    if (subscriptionEnd == null) return 0;
    return subscriptionEnd!.difference(DateTime.now()).inDays;
  }

  String get fullName => '$prenom $nom';

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final storedVersion = SchemaVersion.getVersion(data);

    // Migration automatique si nécessaire
    final migratedData = SchemaVersion.needsMigration(
      storedVersion,
      SchemaVersion.userModelVersion,
    )
        ? SchemaVersion.migrateUserData(data, storedVersion)
        : data;
    return UserModel(
      id: doc.id,
      nom: migratedData['nom'] ?? '',
      prenom: migratedData['prenom'] ?? '',
      email: migratedData['email'] ?? '',
      role: migratedData['role'] == 'admin' ? UserRole.admin : UserRole.user,
      subscriptionStart: migratedData['subscription_start'] != null
          ? (migratedData['subscription_start'] as Timestamp).toDate()
          : null,
      subscriptionEnd: migratedData['subscription_end'] != null
          ? (migratedData['subscription_end'] as Timestamp).toDate()
          : null,
      active: _parseBool(migratedData['active'], defaultValue: true),
      fcmToken: migratedData['fcm_token'],
      weakPassword: _parseBool(migratedData['weak_password'], defaultValue: false),
      schemaVersion:
          migratedData['schema_version'] ?? SchemaVersion.userModelVersion,
    );
  }

  static bool _parseBool(dynamic value, {required bool defaultValue}) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return defaultValue;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'role': role == UserRole.admin ? 'admin' : 'user',
      'subscription_start': subscriptionStart != null
          ? Timestamp.fromDate(subscriptionStart!)
          : null,
      'subscription_end':
          subscriptionEnd != null ? Timestamp.fromDate(subscriptionEnd!) : null,
      'active': active,
      'fcm_token': fcmToken,
      'weak_password': weakPassword,
      'schema_version': schemaVersion,
    };
  }

  UserModel copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? email,
    UserRole? role,
    DateTime? subscriptionStart,
    DateTime? subscriptionEnd,
    bool? active,
    String? fcmToken,
    bool? weakPassword,
    int? schemaVersion,
  }) {
    return UserModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      role: role ?? this.role,
      subscriptionStart: subscriptionStart ?? this.subscriptionStart,
      subscriptionEnd: subscriptionEnd ?? this.subscriptionEnd,
      active: active ?? this.active,
      fcmToken: fcmToken ?? this.fcmToken,
      weakPassword: weakPassword ?? this.weakPassword,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  static DateTime calculateSubscriptionEnd(
      DateTime start, SubscriptionType type) {
    switch (type) {
      case SubscriptionType.oneMonth:
        return DateTime(start.year, start.month + 1, start.day);
      case SubscriptionType.sixMonths:
        return DateTime(start.year, start.month + 6, start.day);
      case SubscriptionType.twelveMonths:
        return DateTime(start.year + 1, start.month, start.day);
    }
  }

  static String subscriptionTypeLabel(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.oneMonth:
        return '1 mois';
      case SubscriptionType.sixMonths:
        return '6 mois';
      case SubscriptionType.twelveMonths:
        return '12 mois';
    }
  }
}
