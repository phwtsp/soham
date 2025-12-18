import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

// Importe as opções geradas pelo flutterfire configure, se tiver
import 'firebase_options.dart';

class FirebaseSetup {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      // Tenta inicializar com as opções geradas
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("✅ Firebase inicializado com sucesso!");

      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      print("⚠️ ERRO AO INICIALIZAR FIREBASE: $e");
      print("Para corrigir, execute: flutterfire configure");
      // Não relança o erro para permitir que o app abra offline/sem firebase por enquanto
    }
  }
}
