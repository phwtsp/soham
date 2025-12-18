import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'models.dart';

// --- Session Repository ---
class SessionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SessionRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Salva a sessão na sub-coleção users/{uid}/sessions
  /// E atualiza os stats do usuário (total_sessions e total_minutes) atomicamente.
  Future<void> saveSession(Session session) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    final userRef = _firestore.collection('users').doc(user.uid);
    final sessionRef = userRef.collection('sessions').doc(); // Auto-ID

    // Usar batch ou transaction para atomicidade
    final batch = _firestore.batch();

    // 1. Salvar a sessão
    batch.set(sessionRef, session.toMap());

    // 2. Atualizar stats (Incrementar contadores)
    // Usamos FieldValue.increment para garantir consistência mesmo com concorrência
    batch.set(
      userRef,
      {
        'stats': {
          'total_sessions': FieldValue.increment(1),
          // Converte duração de segundos para minutos (arredondando ou não, depende da regra)
          // Aqui estou somando minutos aproximados
          'total_minutes': FieldValue.increment((session.duration / 60).ceil()),
        },
        // Atualiza last_active ou similar se necessário
        'last_active': FieldValue.serverTimestamp(),
      },
      SetOptions(
          merge:
              true), // Merge para não sobrescrever outros campos como email/is_premium
    );

    await batch.commit();
  }
}
