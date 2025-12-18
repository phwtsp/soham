import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'user_providers.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if (kIsWeb) return ''; // Web not supported by this plugin
    if (Platform.isAndroid) {
      return 'ca-app-pub-4999983709632277/1560434531';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4999983709632277/1560434531';
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return 'ca-app-pub-4999983709632277/8564826586';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4999983709632277/8564826586';
    }
    throw UnsupportedError("Unsupported platform");
  }
}

class AdManager {
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  void loadInterstitialAd() {
    if (kIsWeb) return;
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          _interstitialAd?.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              // Load next one
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  void showInterstitialAdIfAppropriate(bool isPremium) {
    if (isPremium) return;

    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
      _isInterstitialAdReady = false;
      _interstitialAd = null;
    } else {
      // Try to load for next time if it wasn't ready
      loadInterstitialAd();
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}

// Global provider for AdManager
final adManagerProvider = Provider<AdManager>((ref) {
  final manager = AdManager();
  manager.loadInterstitialAd();
  ref.onDispose(() => manager.dispose());
  return manager;
});

class BottomBannerAd extends ConsumerStatefulWidget {
  const BottomBannerAd({super.key});

  @override
  ConsumerState<BottomBannerAd> createState() => _BottomBannerAdState();
}

class _BottomBannerAdState extends ConsumerState<BottomBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    // Load ad immediately, we verify premium state in build or parent
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // We check premium in build to decide whether to show,
    // but we can also optimize loading.
    _loadAd();
  }

  void _loadAd() {
    if (kIsWeb) return;
    if (_bannerAd != null) return; // Already loaded or loading

    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Ad failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is premium
    final isPremium = ref.watch(isPremiumProvider);

    if (isPremium) {
      return const SizedBox.shrink();
    }

    if (!_isLoaded || _bannerAd == null) {
      // Placeholder or empty while loading
      return const SizedBox(height: 50);
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
