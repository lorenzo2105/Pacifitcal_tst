import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.messageId}');
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message opened app: ${message.data}');
    });
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  static Future<void> sendReservationConfirmation({
    required String userId,
    required String className,
    required String classDate,
    required String classTime,
  }) async {
    await FirebaseFirestore.instance.collection('notifications_queue').add({
      'type': 'reservation_confirmation',
      'user_id': userId,
      'title': 'Réservation confirmée !',
      'body': '$className le $classDate à $classTime',
      'created_at': FieldValue.serverTimestamp(),
      'sent': false,
    });
  }

  static Future<void> sendCancellationNotification({
    required String userId,
    required String className,
  }) async {
    await FirebaseFirestore.instance.collection('notifications_queue').add({
      'type': 'reservation_cancelled',
      'user_id': userId,
      'title': 'Réservation annulée',
      'body': 'Votre réservation pour $className a été annulée.',
      'created_at': FieldValue.serverTimestamp(),
      'sent': false,
    });
  }

  static Future<void> sendSubscriptionExpiryReminder({
    required String userId,
    required int daysLeft,
  }) async {
    await FirebaseFirestore.instance.collection('notifications_queue').add({
      'type': 'subscription_expiry',
      'user_id': userId,
      'title': 'Abonnement bientôt expiré',
      'body': 'Votre abonnement expire dans $daysLeft jour(s). Renouvelez-le !',
      'created_at': FieldValue.serverTimestamp(),
      'sent': false,
    });
  }
}
