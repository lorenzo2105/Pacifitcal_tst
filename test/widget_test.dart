import 'package:flutter_test/flutter_test.dart';
import 'package:pacifitcal/models/user_model.dart';
import 'package:pacifitcal/models/class_model.dart';
import 'package:pacifitcal/models/reservation_model.dart';

void main() {
  group('UserModel', () {
    test('isSubscriptionExpired retourne true si date passée', () {
      final user = UserModel(
        id: '1',
        nom: 'Dupont',
        prenom: 'Jean',
        email: 'jean@test.com',
        role: UserRole.user,
        subscriptionStart: DateTime(2024, 1, 1),
        subscriptionEnd: DateTime(2024, 1, 31),
        active: true,
      );
      expect(user.isSubscriptionExpired, isTrue);
    });

    test('isSubscriptionExpired retourne false si date future', () {
      final user = UserModel(
        id: '2',
        nom: 'Martin',
        prenom: 'Marie',
        email: 'marie@test.com',
        role: UserRole.user,
        subscriptionStart: DateTime.now(),
        subscriptionEnd: DateTime.now().add(const Duration(days: 30)),
        active: true,
      );
      expect(user.isSubscriptionExpired, isFalse);
    });

    test('Admin n\'est jamais expiré', () {
      final admin = UserModel(
        id: '3',
        nom: 'Admin',
        prenom: 'Super',
        email: 'admin@test.com',
        role: UserRole.admin,
        active: true,
      );
      expect(admin.isSubscriptionExpired, isFalse);
      expect(admin.isAdmin, isTrue);
    });

    test('calculateSubscriptionEnd - 1 mois', () {
      final start = DateTime(2025, 3, 15);
      final end = UserModel.calculateSubscriptionEnd(
          start, SubscriptionType.oneMonth);
      expect(end, DateTime(2025, 4, 15));
    });

    test('calculateSubscriptionEnd - 6 mois', () {
      final start = DateTime(2025, 1, 10);
      final end = UserModel.calculateSubscriptionEnd(
          start, SubscriptionType.sixMonths);
      expect(end, DateTime(2025, 7, 10));
    });

    test('calculateSubscriptionEnd - 12 mois', () {
      final start = DateTime(2025, 6, 1);
      final end = UserModel.calculateSubscriptionEnd(
          start, SubscriptionType.twelveMonths);
      expect(end, DateTime(2026, 6, 1));
    });

    test('fullName retourne prénom + nom', () {
      final user = UserModel(
        id: '4',
        nom: 'Durand',
        prenom: 'Pierre',
        email: 'p@test.com',
        role: UserRole.user,
        active: true,
      );
      expect(user.fullName, 'Pierre Durand');
    });
  });

  group('ClassModel', () {
    test('isFull retourne true quand complet', () {
      final cls = ClassModel(
        id: 'c1',
        name: 'WOD',
        date: DateTime.now().add(const Duration(days: 1)),
        time: '09:00',
        duration: 60,
        maxParticipants: 10,
        currentParticipants: 10,
      );
      expect(cls.isFull, isTrue);
      expect(cls.availableSpots, 0);
    });

    test('availableSpots correct', () {
      final cls = ClassModel(
        id: 'c2',
        name: 'HIIT',
        date: DateTime.now().add(const Duration(days: 2)),
        time: '18:00',
        duration: 45,
        maxParticipants: 15,
        currentParticipants: 6,
      );
      expect(cls.isFull, isFalse);
      expect(cls.availableSpots, 9);
    });

    test('isPast retourne true pour un cours passé', () {
      final cls = ClassModel(
        id: 'c3',
        name: 'Cardio',
        date: DateTime.now().subtract(const Duration(days: 1)),
        time: '08:00',
        duration: 60,
        maxParticipants: 10,
      );
      expect(cls.isPast, isTrue);
    });
  });

  group('ReservationModel', () {
    test('isUpcoming retourne true pour une réservation future', () {
      final res = ReservationModel(
        id: 'r1',
        userId: 'u1',
        classId: 'c1',
        createdAt: DateTime.now(),
        classDate: DateTime.now().add(const Duration(days: 1)),
        classTime: '10:00',
      );
      expect(res.isUpcoming, isTrue);
    });

    test('isUpcoming retourne false pour un cours passé', () {
      final res = ReservationModel(
        id: 'r2',
        userId: 'u1',
        classId: 'c2',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        classDate: DateTime.now().subtract(const Duration(days: 1)),
        classTime: '09:00',
      );
      expect(res.isUpcoming, isFalse);
    });
  });
}
