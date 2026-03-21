import 'package:cloud_firestore/cloud_firestore.dart';
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
    final docRef = await _db.collection('classes').add(classModel.toFirestore());
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
        .orderBy('created_at')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ReservationModel.fromFirestore(d)).toList());
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
    await _generateClassesFromTemplate(
        template.copyWith(id: docRef.id), weeksAhead: 8);
    return docRef.id;
  }

  Future<void> updateTemplate(ClassTemplateModel template) async {
    await _db
        .collection('class_templates')
        .doc(template.id)
        .update(template.toFirestore());
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
      final targetDate =
          today.add(Duration(days: daysUntil + (week * 7)));

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
}
