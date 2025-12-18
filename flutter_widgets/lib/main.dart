import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app_styles.dart';
import 'breathing_provider.dart';
import 'stats_screen.dart';
import 'patterns_screen.dart';
import 'firebase_setup.dart';
import 'profile_screen.dart';
import 'session_repository.dart';
import 'models.dart';
import 'ad_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'user_providers.dart';

import 'package:flutter/foundation.dart';

// -----------------------------------------------------------------------------
// UI PRINCIPAL (MAIN E SCAFFOLD)
// -----------------------------------------------------------------------------

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseSetup.init();
  if (!kIsWeb) {
    await MobileAds.instance.initialize();
    await Purchases.setLogLevel(LogLevel.debug);
    PurchasesConfiguration configuration =
        PurchasesConfiguration("test_RadxtpdWbcleaXPhjqfjUkYVrzS");
    await Purchases.configure(configuration);
  }
  await initializeDateFormatting('pt_BR', null);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: BreathingApp()));
}

class BreathingApp extends StatelessWidget {
  const BreathingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soham Breath',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.brandBlue,
        primaryColor: AppColors.primary,
        useMaterial3: true,
        textTheme: GoogleFonts.notoSansTextTheme(
          ThemeData.dark().textTheme,
        ).apply(bodyColor: Colors.white, displayColor: Colors.white),
      ),
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    BreathingScreen(),
    StatsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.brandBlue,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.brandGreen.withOpacity(0.5),
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed, // Ensure labels are shown
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.spa_outlined),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Estatísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class BreathingScreen extends ConsumerStatefulWidget {
  const BreathingScreen({super.key});

  @override
  ConsumerState<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends ConsumerState<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateToState(BreathingState state) {
    switch (state.phase) {
      case BreathPhase.inhale:
        _controller.animateTo(
          1.0,
          duration: state.duration,
          curve: Curves.easeInOutQuad,
        );
        break;
      case BreathPhase.hold:
        // Pequena pulsação durante o hold se desejar, mas o design 02 usa 4-7-8
        // e o design HTML não mostra animação específica no hold além de manter.
        _controller.value = 1.0;
        break;
      case BreathPhase.exhale:
        _controller.animateTo(
          0.0,
          duration: state.duration,
          curve: Curves.easeInOutQuad,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<BreathingState>(breathingProvider, (previous, next) {
      if (previous?.phase != next.phase && next.isPlaying) {
        _animateToState(next);
      }

      if (previous?.isPlaying != next.isPlaying) {
        if (next.isPlaying) {
          // Resume or start animation
          if (_controller.status == AnimationStatus.dismissed ||
              _controller.status == AnimationStatus.completed) {
            _animateToState(next);
          } else {
            _controller.forward();
          }
        } else {
          _controller.stop();
        }
      }
    });

    final breathState = ref.watch(breathingProvider);

    // Initial kickstart if idle
    if (_controller.status == AnimationStatus.dismissed &&
        breathState.phase == BreathPhase.inhale &&
        !ref.read(breathingProvider.notifier).mounted) {
      // This check is a bit naive, relying on the provider to drive.
      // Provider starts automatically on init.
      // Just ensure controller syncs if it desyncs.
      _animateToState(breathState);
    }

    // Force sync first frame if playing (auto-play scenario if ever enabled)
    // or if we just want to set initial state visually without animating
    if (_controller.value == 0.0 &&
        breathState.phase == BreathPhase.inhale &&
        !_controller.isAnimating &&
        breathState.isPlaying) {
      _animateToState(breathState);
    }

    return Scaffold(
      backgroundColor: AppColors.brandBlue,
      body: SafeArea(
        child: Stack(
          children: [
            // --- TOP BAR ---
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Soham",
                      style: GoogleFonts.splineSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: -0.5,
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_circle,
                        color: Colors.white,
                        size: 24,
                      ),
                    )
                  ],
                ),
              ),
            ),

            // --- CENTER CONTENT ---
            Positioned.fill(
              bottom: 350, // Increased space to avoid overlap with new controls
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Breathing Visual Core
                  SizedBox(
                    width: 320,
                    height: 320,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Static Rings
                        Container(
                          width: 320,
                          height: 320,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.brandGreen.withOpacity(0.1),
                                width: 1),
                          ),
                        ),
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.brandGreen.withOpacity(0.2),
                                width: 1),
                          ),
                        ),
                        // Main Circle
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            final size = 200.0 + (_controller.value * 50.0);
                            return Container(
                              width: size,
                              height: size,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFF0A5A8A),
                                    AppColors.brandBlue,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.brandGreen.withOpacity(0.15),
                                    blurRadius: 50,
                                    spreadRadius: 0,
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // Inner Glow
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.brandGreen
                                            .withOpacity(0.05),
                                      ),
                                    ),
                                  ),
                                  // Timer Text
                                  Center(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                "${breathState.remainingSeconds}",
                                            style: GoogleFonts.splineSans(
                                              fontSize: 72,
                                              fontWeight: FontWeight.w300,
                                              color: Colors.white,
                                              height: 1.0,
                                              letterSpacing: -2,
                                            ),
                                          ),
                                          TextSpan(
                                            text: "s",
                                            style: GoogleFonts.notoSans(
                                              fontSize: 30,
                                              fontWeight: FontWeight.normal,
                                              color: AppColors.brandGreen
                                                  .withOpacity(0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Label Text
                  Text(
                    breathState.label, // "Inhale"
                    style: GoogleFonts.splineSans(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: 0.5,
                        shadows: [
                          const Shadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    breathState.subLabel,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSans(
                      fontSize: 18,
                      color: AppColors.brandGreen.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // --- BOTTOM CONTROLS (Updated for Home02) ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                    margin:
                        const EdgeInsets.only(bottom: 24), // Above Ad Banner
                    child: Column(
                      children: [
                        // Play/Pause Button
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(breathingProvider.notifier)
                                .togglePlayPause();
                          },
                          child: Container(
                            height: 64, // Bigger prominence
                            width: 64,
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: AppColors.brandGreen,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.brandGreen.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Icon(
                              breathState.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: AppColors.brandBlue,
                              size: 32,
                            ),
                          ),
                        ),

                        // Finish Button
                        GestureDetector(
                          onTap: () async {
                            // Logic to save session if needed
                            // For simplicity, we assume "Finish" means a session was completed
                            // In a real app we would track actual time spent.
                            // Here we just save a dummy session for the current pattern

                            try {
                              final duration =
                                  breathState.sessionDuration.inSeconds;
                              if (duration < 5) {
                                // Minimum 5 seconds to count
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content:
                                        Text("Sessão muito curta para salvar."),
                                  ));
                                }
                                return;
                              }

                              final session = Session(
                                date: DateTime.now(),
                                duration: duration,
                                pattern: breathState.pattern.name,
                                completed: true,
                              );

                              await SessionRepository().saveSession(session);

                              // Reset session state after saving
                              ref
                                  .read(breathingProvider.notifier)
                                  .resetSession();

                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("Sessão salva com sucesso!"),
                                  backgroundColor: AppColors.brandGreen,
                                ));

                                // Show Interstitial Ad if not premium
                                final isPremium = ref.read(isPremiumProvider);
                                ref
                                    .read(adManagerProvider)
                                    .showInterstitialAdIfAppropriate(isPremium);
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text("Faça login para salvar: $e"),
                                  backgroundColor: Colors.redAccent,
                                ));
                              }
                            }
                          },
                          child: Container(
                            height: 48,
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.stop_circle,
                                    color:
                                        AppColors.brandGreen.withOpacity(0.9),
                                    size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  "FINALIZAR",
                                  style: GoogleFonts.notoSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),

                        // Pattern Selector
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const PatternsScreen()),
                            );
                          },
                          child: Container(
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.brandGreen,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 30,
                                  offset: const Offset(0, 8),
                                )
                              ],
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "PADRÃO ATUAL",
                                            style: GoogleFonts.splineSans(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1.5,
                                              color: AppColors.brandBlue
                                                  .withOpacity(0.6),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.brandBlue
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              breathState
                                                  .pattern.intervalString,
                                              style: GoogleFonts.splineSans(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.brandBlue,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      SizedBox(
                                        width: 200,
                                        child: Text(
                                          breathState.pattern.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.splineSans(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.brandBlue,
                                            height: 1.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.brandBlue.withOpacity(0.1),
                                      borderRadius:
                                          BorderRadius.circular(12), // Squircle
                                    ),
                                    child: const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.brandBlue,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Ad Banner
                  const BottomBannerAd(), // Replaces the static Placeholder
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.brandBlue,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.white24),
            const SizedBox(height: 20),
            Text(
              "EM BREVE",
              style: GoogleFonts.splineSans(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.notoSans(
                color: Colors.white54,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
