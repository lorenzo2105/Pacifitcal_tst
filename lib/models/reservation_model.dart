import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String id;
  final String userId;
  final String classId;
  final DateTime createdAt;
  final String? userName;
  final String? className;
  final DateTime? classDate;
  final String? classTime;

  ReservationModel({
    required this.id,
    required this.userId,
    required this.classId,
    required this.createdAt,
    this.userName,
    this.className,
    this.classDate,
    this.classTime,
  });

  factory ReservationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReservationModel(
      id: doc.id,
      userId: data['user_id'] ?? '',
      classId: data['class_id'] ?? '',
      createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
      userName: data['user_name'],
      className: data['class_name'],
      classDate: data['class_date'] != null
          ? (data['class_date'] as Timestamp).toDate()
          : null,
      classTime: data['class_time'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'class_id': classId,
      'created_at': Timestamp.fromDate(createdAt),
      'user_name': userName,
      'class_name': className,
      'class_date': classDate != null ? Timestamp.fromDate(classDate!) : null,
      'class_time': classTime,
    };
  }

  bool get isUpcoming {
    if (classDate == null || classTime == null) return false;
    final parts = classTime!.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    final classDateTime = DateTime(
      classDate!.year,
      classDate!.month,
      classDate!.day,
      hour,
      minute,
    );
    return classDateTime.isAfter(DateTime.now());
  }
}
