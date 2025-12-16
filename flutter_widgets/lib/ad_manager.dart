import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_providers.dart';

class AdManager {
  // IDs fornecidos
  static const String _appId = 'ca-app-pub-4999983709632277~6014044234';

  // Nota: É recomendável usar IDs de teste durante o desenvolvimento (kDebugMode)
  // Mas aqui estamos usando os IDs fornecidos conforme solicitado.
  static String get bannerAdUnitId {
    if (kIsWeb) return ''; // Ads not supported on web

    if (kDebugMode) {
      // ID de teste do Google para Banner (Android/iOS)
      return defaultTargetPlatform == TargetPlatform.android
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';
    }
    return 'ca-app-pub-4999983709632277/1560434531';
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';

    if (kDebugMode) {
      // ID de teste do Google para Interstitial (Android/iOS)
      return defaultTargetPlatform == TargetPlatform.android
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    }
    return 'ca-app-pub-4999983709632277/8564826586';
  }

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  /// Inicializa o SDK (Chamar no main)
  Future<InitializationStatus> init() {
    if (kIsWeb) return Future.value(InitializationStatus({}));
    return MobileAds.instance.initialize();
  }

  /// Carrega o Interstitial Ad antecipadamente
  void loadInterstitial() {
    if (kIsWeb) return;
    if (_isInterstitialLoading) return;
    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('$ad loaded');
          _interstitialAd = ad;
          _isInterstitialLoading = false;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
          _interstitialAd = null;
          _isInterstitialLoading = false;
        },
      ),
    );
  }

  /// Exibe o Interstitial APENAS se não for Premium.
  /// Deve ser chamado ao finalizar a respiração.
  void showInterstitialIfFree(BuildContext context, WidgetRef ref) {
    if (kIsWeb) return;

    // Verifica se é Premium
    final isPremium = ref.read(isPremiumProvider);

    if (isPremium) {
      print('Usuário é Premium. Anúncio pulado.');
      return;
    }

    if (_interstitialAd == null) {
      print(
          'Warning: Interstitial não carregado ainda. Tentando carregar para a próxima.');
      loadInterstitial();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitial(); // Prepara o próximo
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitial();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null; // Limpa referência para evitar reuso
  }
}

final adManagerProvider = Provider<AdManager>((ref) => AdManager());

/// Widget de Banner que se esconde automaticamente se o usuário for Premium
class BottomBannerAd extends ConsumerStatefulWidget {
  const BottomBannerAd({Key? key}) : super(key: key);

  @override
  ConsumerState<BottomBannerAd> createState() => _BottomBannerAdState();
}

class _BottomBannerAdState extends ConsumerState<BottomBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAdIfNeeded();
  }

  void _loadAdIfNeeded() {
    if (kIsWeb) return;

    // Se já estiver carregado ou se for premium, não faz nada
    final isPremium = ref.read(isPremiumProvider);
    if (isPremium || _bannerAd != null) return;

    _bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Banner failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const SizedBox.shrink();

    // Escuta mudanças no userProvider (Premium status)
    final isPremium = ref.watch(isPremiumProvider);

    // Se virou Premium, removemos o anúncio da tela
    if (isPremium) {
      if (_bannerAd != null) {
        _bannerAd!.dispose();
        _bannerAd = null;
        _isLoaded = false;
      }
      return const SizedBox.shrink();
    }

    // Se não é premium e não tem anúncio, tenta carregar
    if (_bannerAd == null) {
      _loadAdIfNeeded();
    }

    if (_bannerAd != null && _isLoaded) {
      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // Espaço reservado ou vazio enquanto carrega
    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
