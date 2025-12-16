import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

// Importe as opções geradas pelo flutterfire configure, se tiver
// import 'firebase_options.dart';

class FirebaseSetup {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Inicializa o Firebase
    // Se você usou o FlutterFire CLI, descomente e use o DefaultFirebaseOptions
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
    await Firebase.initializeApp();

    // Configura o Firestore
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true, // Garante o cache offline (Padrão no mobile)
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    
    // Em Web, a persistência precisa ser ativada explicitamente se necessário,
    // mas o persistenceEnabled acima já tenta cobrir.
    // Para web especificamente: enablePersistence(PersistenceSettings(synchronizeTabs: true))
  }
}
