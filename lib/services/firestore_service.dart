import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pacifitcal/models/user_model.dart';
import 'package:pacifitcal/models/class_model.dart';
import 'package:pacifitcal/models/class_template_model.dart';
import 'package:pacifitcal/models/reservation_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── USERS ───────────────────────────────────────────────────────────────

  Stream<List<UserModel>> streamUsers() {
    return _db.collection('users').orderBy('nom').snapshots().map(
          (snap) => snap.docs.map((d) => UserModel.fromFirestore(d)).toList(),
        );
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toFirestore());
  }

  Future<void> updateUser(UserModel user) async {
    await _db.collection('users').doc(user.id).update(user.toFirestore());
  }

  Future<void> deleteUser(String uid) async {
    final batch = _db.batch();
    final reservations = await _db
        .collection('reservations')
        .where('user_id', isEqualTo: uid)
        .get();
    for (final doc in reservations.docs) {
      batch.delete(doc.reference);
      final classId = doc.data()['class_id'] as String?;
      if (classId != null) {
        batch.update(_db.collection('classes').doc(classId), {
          'current_participants': FieldValue.increment(-1),
        });
      }
    }
    batch.delete(_db.collection('users').doc(uid));
    await batch.commit();
  }

  Future<void> setUserActive(String uid, bool active) async {
    await _db.collection('users').doc(uid).update({'active': active});
  }

  Future<void> updateSubscription({
    required String uid,
    required DateTime start,
    required DateTime end,
  }) async {
    await _db.collection('users').doc(uid).update({
      'subscription_start': Timestamp.fromDate(start),
      'subscription_end': Timestamp.fromDate(end),
    });
  }

  // ─── CLASSES ─────────────────────────────────────────────────────────────

  Stream<List<ClassModel>> streamUpcomingClasses() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _db
        .collection('classes')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
        .orderBy('date')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ClassModel.fromFirestore(d)).toList());
  }

  Stream<List<ClassModel>> streamAllClasses() {
    return _db
        .collection('classes')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ClassModel.fromFirestore(d)).toList());
  }

  Future<ClassModel?> getClass(String classId) async {
    final doc = await _db.collection('classes').doc(classId).get();
    if (!doc.exists) return null;
    return ClassModel.fromFirestore(doc);
  }

  Future<String> createClass(ClassModel classModel) async {
    final docRef =
        await _db.collection('classes').add(classModel.toFirestore());
    return docRef.id;
  }

  Future<void> updateClass(ClassModel classModel) async {
    await _db
        .collection('classes')
        .doc(classModel.id)
        .update(classModel.toFirestore());
  }

  Future<void> deleteClass(String classId) async {
    final batch = _db.batch();
    final reservations = await _db
        .collection('reservations')
        .where('class_id', isEqualTo: classId)
        .get();
    for (final doc in reservations.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_db.collection('classes').doc(classId));
    await batch.commit();
  }

  // ─── RESERVATIONS ─────────────────────────────────────────────────────────

  Future<bool> hasReservation(String userId, String classId) async {
    final snap = await _db
        .collection('reservations')
        .where('user_id', isEqualTo: userId)
        .where('class_id', isEqualTo: classId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<ReservationModel> createReservation({
    required String userId,
    required String userName,
    required ClassModel classModel,
  }) async {
    final alreadyBooked = await hasReservation(userId, classModel.id);
    if (alreadyBooked) throw Exception('Vous avez déjà réservé ce cours.');

    final classDoc = await _db.collection('classes').doc(classModel.id).get();
    final classData = classDoc.data()!;
    final current = classData['current_participants'] as int? ?? 0;
    final max = classData['max_participants'] as int? ?? 0;
    if (current >= max) throw Exception('Ce cours est complet.');

    final batch = _db.batch();
    final reservationRef = _db.collection('reservations').doc();
    final reservation = ReservationModel(
      id: reservationRef.id,
      userId: userId,
      classId: classModel.id,
      createdAt: DateTime.now(),
      userName: userName,
      className: classModel.name,
      classDate: classModel.date,
      classTime: classModel.time,
    );

    batch.set(reservationRef, reservation.toFirestore());
    batch.update(_db.collection('classes').doc(classModel.id), {
      'current_participants': FieldValue.increment(1),
    });

    await batch.commit();
    return reservation;
  }

  Future<void> cancelReservation(String reservationId, String classId) async {
    final batch = _db.batch();
    batch.delete(_db.collection('reservations').doc(reservationId));
    batch.update(_db.collection('classes').doc(classId), {
      'current_participants': FieldValue.increment(-1),
    });
    await batch.commit();
  }

  Stream<List<ReservationModel>> streamUserReservations(String userId) {
    return _db
        .collection('reservations')
        .where('user_id', isEqualTo: userId)
        .orderBy('class_date', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ReservationModel.fromFirestore(d)).toList());
  }

  Stream<List<ReservationModel>> streamClassReservations(String classId) {
    return _db
        .collection('reservations')
        .where('class_id', isEqualTo: classId)
        .snapshots()
        .map((snap) {
      final reservations =
          snap.docs.map((d) => ReservationModel.fromFirestore(d)).toList();
      reservations.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return reservations;
    });
  }

  Stream<List<ReservationModel>> streamAllReservations() {
    return _db
        .collection('reservations')
        .orderBy('class_date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ReservationModel.fromFirestore(d)).toList());
  }

  Future<void> adminDeleteReservation(
      String reservationId, String classId) async {
    await cancelReservation(reservationId, classId);
  }

  // ─── CLASSES PAR DATE ─────────────────────────────────────────────────────

  Stream<List<ClassModel>> streamClassesByDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return _db
        .collection('classes')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ClassModel.fromFirestore(d)).toList());
  }

  // ─── CLASS TEMPLATES ──────────────────────────────────────────────────────

  Stream<List<ClassTemplateModel>> streamTemplates() {
    return _db
        .collection('class_templates')
        .orderBy('day_of_week')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ClassTemplateModel.fromFirestore(d)).toList());
  }

  Future<ClassTemplateModel?> getTemplate(String templateId) async {
    final doc = await _db.collection('class_templates').doc(templateId).get();
    if (!doc.exists) return null;
    return ClassTemplateModel.fromFirestore(doc);
  }

  Future<String> createTemplate(ClassTemplateModel template) async {
    final docRef =
        await _db.collection('class_templates').add(template.toFirestore());
    await _generateClassesFromTemplate(template.copyWith(id: docRef.id),
        weeksAhead: 4);
    return docRef.id;
  }

  Future<void> updateTemplate(ClassTemplateModel template) async {
    await _db
        .collection('class_templates')
        .doc(template.id)
        .update(template.toFirestore());

    // Mettre à jour toutes les séances futures générées par ce template
    await _updateFutureClassesFromTemplate(template);
  }

  /// Met à jour toutes les séances futures d'un template avec les nouvelles données
  Future<void> _updateFutureClassesFromTemplate(
      ClassTemplateModel template) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Récupérer toutes les séances de ce template (pas de where sur date pour éviter index composite)
    final allClassesSnap = await _db
        .collection('classes')
        .where('template_id', isEqualTo: template.id)
        .get();

    // Filtrer en mémoire pour ne garder que les séances futures
    final futureClasses = allClassesSnap.docs.where((doc) {
      final data = doc.data();
      final timestamp = data['date'] as Timestamp;
      final classDate = timestamp.toDate();
      final classDateOnly =
          DateTime(classDate.year, classDate.month, classDate.day);
      return classDateOnly.isAfter(today) ||
          classDateOnly.isAtSameMomentAs(today);
    }).toList();

    if (futureClasses.isEmpty) return;

    // Mettre à jour par batch
    final batch = _db.batch();
    for (final doc in futureClasses) {
      batch.update(doc.reference, {
        'name': template.name,
        'time': template.startTime,
        'end_time': template.endTime,
        'duration': template.durationMinutes,
        'max_participants': template.maxParticipants,
        'coach': template.coach,
        'description': template.description,
      });
    }

    await batch.commit();
    debugPrint(
        '✅ ${futureClasses.length} séance(s) future(s) mise(s) à jour pour ${template.name}');
  }

  Future<void> deleteTemplate(String templateId) async {
    final batch = _db.batch();
    // Supprimer les cours générés par ce template
    final classes = await _db
        .collection('classes')
        .where('template_id', isEqualTo: templateId)
        .get();
    for (final doc in classes.docs) {
      // Supprimer les réservations associées
      final reservations = await _db
          .collection('reservations')
          .where('class_id', isEqualTo: doc.id)
          .get();
      for (final r in reservations.docs) {
        batch.delete(r.reference);
      }
      batch.delete(doc.reference);
    }
    batch.delete(_db.collection('class_templates').doc(templateId));
    await batch.commit();
  }

  Future<void> _generateClassesFromTemplate(ClassTemplateModel template,
      {int weeksAhead = 8}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final batch = _db.batch();

    for (int week = 0; week < weeksAhead; week++) {
      // Trouver la prochaine occurrence du jour de semaine
      int daysUntil = (template.dayOfWeek - today.weekday) % 7;
      final targetDate = today.add(Duration(days: daysUntil + (week * 7)));

      // Vérifier qu'un cours n'existe pas déjà pour ce template/date
      final existing = await _db
          .collection('classes')
          .where('template_id', isEqualTo: template.id)
          .where('date',
              isEqualTo: Timestamp.fromDate(
                  DateTime(targetDate.year, targetDate.month, targetDate.day)))
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) continue;

      final classRef = _db.collection('classes').doc();
      batch.set(classRef, {
        'name': template.name,
        'date': Timestamp.fromDate(
            DateTime(targetDate.year, targetDate.month, targetDate.day)),
        'time': template.startTime,
        'end_time': template.endTime,
        'duration': template.durationMinutes,
        'max_participants': template.maxParticipants,
        'current_participants': 0,
        'coach': template.coach,
        'description': template.description,
        'template_id': template.id,
      });
    }
    await batch.commit();
  }

  Future<void> generateMoreClassesFromTemplate(String templateId,
      {int weeksAhead = 8}) async {
    final template = await getTemplate(templateId);
    if (template != null) {
      await _generateClassesFromTemplate(template, weeksAhead: weeksAhead);
    }
  }

  /// Maintient automatiquement un mois glissant (4 semaines) de séances pour tous les templates actifs
  /// Cette fonction doit être appelée régulièrement (ex: au chargement de l'écran admin)
  Future<void> maintainRollingMonthClasses() async {
    try {
      // Récupérer tous les templates actifs
      final templatesSnap = await _db
          .collection('class_templates')
          .where('active', isEqualTo: true)
          .get();

      if (templatesSnap.docs.isEmpty) return;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final fourWeeksAhead = today.add(const Duration(days: 28)); // 4 semaines

      for (final templateDoc in templatesSnap.docs) {
        final template = ClassTemplateModel.fromFirestore(templateDoc);

        // Récupérer toutes les séances de ce template (pas de where sur date pour éviter index composite)
        final allClassesSnap = await _db
            .collection('classes')
            .where('template_id', isEqualTo: template.id)
            .get();

        // Filtrer en mémoire pour ne garder que les séances futures et extraire les dates
        final existingDates = allClassesSnap.docs
            .map((doc) {
              final data = doc.data();
              final timestamp = data['date'] as Timestamp;
              final date = timestamp.toDate();
              return DateTime(date.year, date.month, date.day);
            })
            .where(
                (date) => date.isAfter(today) || date.isAtSameMomentAs(today))
            .toSet();

        // Générer les séances manquantes pour les 4 prochaines semaines
        final batch = _db.batch();
        int generatedCount = 0;

        for (int week = 0; week < 4; week++) {
          // Calculer la date cible pour cette semaine
          int daysUntil = (template.dayOfWeek - today.weekday) % 7;
          if (daysUntil == 0 && week == 0)
            daysUntil = 7; // Si c'est aujourd'hui, prendre la semaine prochaine
          final targetDate = today.add(Duration(days: daysUntil + (week * 7)));

          // Ne générer que si la date est dans les 4 semaines et n'existe pas déjà
          if (targetDate.isBefore(fourWeeksAhead) ||
              targetDate.isAtSameMomentAs(fourWeeksAhead)) {
            if (!existingDates.contains(targetDate)) {
              final classRef = _db.collection('classes').doc();
              batch.set(classRef, {
                'name': template.name,
                'date': Timestamp.fromDate(targetDate),
                'time': template.startTime,
                'end_time': template.endTime,
                'duration': template.durationMinutes,
                'max_participants': template.maxParticipants,
                'current_participants': 0,
                'coach': template.coach,
                'description': template.description,
                'template_id': template.id,
              });
              generatedCount++;
            }
          }
        }

        if (generatedCount > 0) {
          await batch.commit();
          debugPrint(
              '✅ Généré $generatedCount séance(s) pour ${template.name}');
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la maintenance des séances: $e');
    }
  }
}
