import 'package:cloud_firestore/cloud_firestore.dart';

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
    return UserModel(
      id: doc.id,
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] == 'admin' ? UserRole.admin : UserRole.user,
      subscriptionStart: data['subscription_start'] != null
          ? (data['subscription_start'] as Timestamp).toDate()
          : null,
      subscriptionEnd: data['subscription_end'] != null
          ? (data['subscription_end'] as Timestamp).toDate()
          : null,
      active: data['active'] ?? true,
      fcmToken: data['fcm_token'],
    );
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
      'subscription_end': subscriptionEnd != null
          ? Timestamp.fromDate(subscriptionEnd!)
          : null,
      'active': active,
      'fcm_token': fcmToken,
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
