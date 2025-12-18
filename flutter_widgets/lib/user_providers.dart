import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'models.dart';

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
          .snapshots(
              includeMetadataChanges:
                  true) // Opcional: para saber se vem do cache
          .map((doc) => AppUser.fromDocument(doc));
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// Provider para CustomerInfo do RevenueCat
final customerInfoProvider = StreamProvider.autoDispose<CustomerInfo?>((ref) {
  if (kIsWeb) return Stream.value(null);

  // Create a stream controller to bridge the listener
  final controller = StreamController<CustomerInfo?>();

  // Initial fetch
  Purchases.getCustomerInfo()
      .then((info) => controller.add(info))
      .catchError((_) {});

  // Listen for updates
  Purchases.addCustomerInfoUpdateListener((info) {
    if (!controller.isClosed) controller.add(info);
  });

  ref.onDispose(() {
    controller.close();
  });

  return controller.stream;
});

// Provider para sincronizar Auth do Firebase com RevenueCat
final revenueCatSyncProvider = Provider.autoDispose<void>((ref) {
  final authUserAsync = ref.watch(authUserProvider);

  authUserAsync.whenData((user) {
    if (kIsWeb) return;

    if (user != null) {
      Purchases.logIn(user.uid);
      Purchases.setEmail(user.email ?? "");
    } else {
      // Don't log out of RC necessarily, or maybe allow anonymous.
      // Usually good to reset to anonymous if app user logs out.
      // Purchases.logOut();
      // But typically for this app flow, we can just leave it or handle explicit logout elsewhere.
    }
  });
});

// Apenas um atalho para saber se é premium
// Checa RevenueCat ("Soham Pro") E Firestore (fallback/web)
final isPremiumProvider = Provider.autoDispose<bool>((ref) {
  // Ensure sync is active
  ref.watch(revenueCatSyncProvider);

  // 1. Check RevenueCat (Mobile / User-Verify)
  final customerInfoAsync = ref.watch(customerInfoProvider);
  final rcPremium =
      customerInfoAsync.value?.entitlements.all['Soham Pro']?.isActive ?? false;

  if (rcPremium) return true;

  // 2. Check Firestore (Web / Cache / Webhook update)
  final userAsync = ref.watch(userProvider);
  return userAsync.value?.isPremium ?? false;
});
