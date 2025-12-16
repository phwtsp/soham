import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- User Model ---
class AppUser {
  final String uid;
  final String email;
  final bool isPremium;
  final UserStats stats;

  AppUser({
    required this.uid,
    required this.email,
    required this.isPremium,
    required this.stats,
  });

  factory AppUser.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      // Retorno padrão caso o documento ainda não exista
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

  factory UserStats.zero() => UserStats(totalSessions: 0, totalMinutes: 0);
}

// --- Providers ---

// Provider para obter o usuário autenticado do Firebase Auth
final authUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Provider PRINCIPAL: Escuta o documento do usuário em tempo real
// Transforma o User do Auth em um Stream do AppUser (Firestore)
final userProvider = StreamProvider.autoDispose<AppUser?>((ref) {
  final authUserAsync = ref.watch(authUserProvider);

  return authUserAsync.when(
    data: (user) {
      if (user == null) return Stream.value(null);

      // Ouvindo o documento em tempo real
      // A persistência (cache) do Firestore cuida do offline automaticamente
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(includeMetadataChanges: true) // Opcional: para saber se vem do cache
          .map((doc) => AppUser.fromDocument(doc));
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// Apenas um atalho para saber se é premium
final isPremiumProvider = Provider.autoDispose<bool>((ref) {
  final userAsync = ref.watch(userProvider);
  return userAsync.value?.isPremium ?? false;
});
