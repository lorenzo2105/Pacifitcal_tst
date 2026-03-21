import 'package:cloud_firestore/cloud_firestore.dart';

class ClassTemplateModel {
  final String id;
  final String name;
  final int dayOfWeek; // 1=Lundi … 7=Dimanche (DateTime.weekday)
  final String startTime; // "HH:mm"
  final String endTime;   // "HH:mm"
  final int maxParticipants;
  final String? coach;
  final String? description;
  final bool active;

  ClassTemplateModel({
    required this.id,
    required this.name,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.maxParticipants,
    this.coach,
    this.description,
    this.active = true,
  });

  int get durationMinutes {
    final s = startTime.split(':');
    final e = endTime.split(':');
    final startMins = int.parse(s[0]) * 60 + int.parse(s[1]);
    final endMins = int.parse(e[0]) * 60 + int.parse(e[1]);
    return endMins - startMins;
  }

  String get dayName {
    const days = ['', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return days[dayOfWeek];
  }

  factory ClassTemplateModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ClassTemplateModel(
      id: doc.id,
      name: d['name'] ?? '',
      dayOfWeek: d['day_of_week'] ?? 1,
      startTime: d['start_time'] ?? '09:00',
      endTime: d['end_time'] ?? '10:00',
      maxParticipants: d['max_participants'] ?? 10,
      coach: d['coach'],
      description: d['description'],
      active: d['active'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'max_participants': maxParticipants,
      'coach': coach,
      'description': description,
      'active': active,
    };
  }

  ClassTemplateModel copyWith({
    String? id,
    String? name,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    int? maxParticipants,
    String? coach,
    String? description,
    bool? active,
  }) {
    return ClassTemplateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      coach: coach ?? this.coach,
      description: description ?? this.description,
      active: active ?? this.active,
    );
  }
}
