import 'package:cloud_firestore/cloud_firestore.dart';

class BreathingPattern {
  final String id;
  final String name;
  final String description;
  final int inhale;
  final int hold;
  final int exhale;

  const BreathingPattern({
    required this.id,
    required this.name,
    required this.description,
    required this.inhale,
    required this.hold,
    required this.exhale,
  });

  Duration get inhaleDuration => Duration(seconds: inhale);
  Duration get holdDuration => Duration(seconds: hold);
  Duration get exhaleDuration => Duration(seconds: exhale);

  String get intervalString => "$inhale-$hold-$exhale";
}

class CustomPattern extends BreathingPattern {
  CustomPattern({
    required super.id,
    required super.name,
    required super.description,
    required super.inhale,
    required super.hold,
    required super.exhale,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'inhale': inhale,
      'hold': hold,
      'exhale': exhale,
    };
  }

  factory CustomPattern.fromMap(String id, Map<String, dynamic> map) {
    return CustomPattern(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? 'Personalizado',
      inhale: map['inhale'] ?? 4,
      hold: map['hold'] ?? 0,
      exhale: map['exhale'] ?? 4,
    );
  }
}

class Session {
  final DateTime date;
  final int duration;
  final String pattern;
  final bool completed;

  Session({
    required this.date,
    required this.duration,
    required this.pattern,
    required this.completed,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'duration': duration,
      'pattern': pattern,
      'completed': completed,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      date: (map['date'] as Timestamp).toDate(),
      duration: map['duration'] ?? 0,
      pattern: map['pattern'] ?? '',
      completed: map['completed'] ?? false,
    );
  }
}

class UserStats {
  final int totalSessions;
  final int totalMinutes;

  UserStats({required this.totalSessions, required this.totalMinutes});

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      totalSessions: map['total_sessions'] ?? 0,
      totalMinutes: map['total_minutes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total_sessions': totalSessions,
      'total_minutes': totalMinutes,
    };
  }

  factory UserStats.zero() => UserStats(totalSessions: 0, totalMinutes: 0);
}

class AppUser {
  final String uid;
  final String email;
  final bool isPremium;
  final UserStats stats;
  final DateTime? createdAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.isPremium,
    required this.stats,
    this.createdAt,
  });

  factory AppUser.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      return AppUser(
        uid: doc.id,
        email: '',
        isPremium: false,
        stats: UserStats.zero(),
      );
    }
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      isPremium: data['is_premium'] ?? false,
      stats: UserStats.fromMap(data['stats'] ?? {}),
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'is_premium': isPremium,
      'stats': stats.toMap(),
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}

const defaultPatterns = [
  BreathingPattern(
    id: '4-7-8',
    name: 'Relaxamento 4-7-8',
    description: 'Técnica clássica para relaxamento profundo.',
    inhale: 4,
    hold: 7,
    exhale: 8,
  ),
  BreathingPattern(
    id: 'box',
    name: 'Box Breathing',
    description: 'Foco e clareza mental. Ideal antes de tarefas importantes.',
    inhale: 4,
    hold: 4,
    exhale: 4,
  ),
  BreathingPattern(
    id: 'balance',
    name: 'Equilíbrio',
    description: 'Restaura a calma e clareza. Ritmo natural e suave.',
    inhale: 4,
    hold: 0,
    exhale: 4,
  ),
  BreathingPattern(
    id: 'sleep',
    name: 'Sono Profundo',
    description: 'Prolonga a expiração para induzir sonolência e relaxamento.',
    inhale: 4,
    hold: 0,
    exhale: 8,
  ),
  BreathingPattern(
    id: 'energy',
    name: 'Energia Matinal',
    description: 'Ativação rápida do corpo e mente para começar o dia.',
    inhale: 6,
    hold: 0,
    exhale: 2,
  ),
];
