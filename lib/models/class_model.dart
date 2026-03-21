import 'package:cloud_firestore/cloud_firestore.dart';

class ClassModel {
  final String id;
  final String name;
  final DateTime date;
  final String time;
  final int duration;
  final int maxParticipants;
  final int currentParticipants;
  final String? description;
  final String? coach;
  final String? endTime;

  ClassModel({
    required this.id,
    required this.name,
    required this.date,
    required this.time,
    required this.duration,
    required this.maxParticipants,
    this.currentParticipants = 0,
    this.description,
    this.coach,
    this.endTime,
  });

  bool get isFull => currentParticipants >= maxParticipants;
  int get availableSpots => maxParticipants - currentParticipants;

  bool get isPast {
    final classDateTime = _parseDateTime();
    return classDateTime.isBefore(DateTime.now());
  }

  DateTime _parseDateTime() {
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  DateTime get dateTime => _parseDateTime();

  factory ClassModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClassModel(
      id: doc.id,
      name: data['name'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'] ?? '00:00',
      duration: data['duration'] ?? 60,
      maxParticipants: data['max_participants'] ?? 10,
      currentParticipants: data['current_participants'] ?? 0,
      description: data['description'],
      coach: data['coach'],
      endTime: data['end_time'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'date': Timestamp.fromDate(date),
      'time': time,
      'end_time': endTime,
      'duration': duration,
      'max_participants': maxParticipants,
      'current_participants': currentParticipants,
      'description': description,
      'coach': coach,
    };
  }

  ClassModel copyWith({
    String? id,
    String? name,
    DateTime? date,
    String? time,
    int? duration,
    int? maxParticipants,
    int? currentParticipants,
    String? description,
    String? coach,
    String? endTime,
  }) {
    return ClassModel(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      description: description ?? this.description,
      coach: coach ?? this.coach,
      endTime: endTime ?? this.endTime,
    );
  }
}
