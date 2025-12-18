import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'stats_screen.dart';

// -----------------------------------------------------------------------------
// 1. CONFIGURAÇÃO DE TEMA E CORES
// -----------------------------------------------------------------------------
class AppColors {
  static const Color brandBlue = Color(0xFF084D75);
  static const Color brandGreen = Color(0xFFD1E9DE);
  static const Color primary = Color(0xFFF9F506);
  static const Color backgroundLight = Color(0xFFF8F8F5);
  static const Color backgroundDark = Color(0xFF23220F);
}

final appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor:
      AppColors.brandBlue, // Fundo principal é o Brand Blue
  primaryColor: AppColors.primary,
  useMaterial3: true,
  textTheme: GoogleFonts.notoSansTextTheme(
    ThemeData.dark().textTheme,
  ).apply(bodyColor: Colors.white, displayColor: Colors.white),
);

// -----------------------------------------------------------------------------
// 2. GERENCIAMENTO DE ESTADO (RIVERPOD)
// -----------------------------------------------------------------------------

enum BreathPhase { inhale, hold, exhale }

class BreathingState {
  final BreathPhase phase;
  final String label;
  final String subLabel;
  final Duration duration;

  const BreathingState({
    required this.phase,
    required this.label,
    required this.subLabel,
    required this.duration,
  });
}

class BreathingNotifier extends StateNotifier<BreathingState> {
  Timer? _timer;

  BreathingNotifier()
    : super(
        const BreathingState(
          phase: BreathPhase.inhale,
          label: "Inhale",
          subLabel: "Deeply through your nose",
          duration: Duration(seconds: 4),
        ),
      ) {
    _startCycle();
  }

  void _startCycle() {
    _scheduleNextPhase();
  }

  void _scheduleNextPhase() {
    _timer = Timer(state.duration, () {
      switch (state.phase) {
        case BreathPhase.inhale:
          state = const BreathingState(
            phase: BreathPhase.hold,
            label: "Hold",
            subLabel: "Keep your chest expanded",
            duration: Duration(seconds: 7),
          );
          break;
        case BreathPhase.hold:
          state = const BreathingState(
            phase: BreathPhase.exhale,
            label: "Exhale",
            subLabel: "Release slowly through mouth",
            duration: Duration(seconds: 8),
          );
          break;
        case BreathPhase.exhale:
          state = const BreathingState(
            phase: BreathPhase.inhale,
            label: "Inhale",
            subLabel: "Deeply through your nose",
            duration: Duration(seconds: 4),
          );
          break;
      }
      _scheduleNextPhase();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final breathingProvider =
    StateNotifierProvider.autoDispose<BreathingNotifier, BreathingState>((ref) {
      return BreathingNotifier();
    });

// -----------------------------------------------------------------------------
// 3. UI PRINCIPAL (MAIN E SCAFFOLD)
// -----------------------------------------------------------------------------

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      theme: appTheme,
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
    PlaceholderScreen(title: "Perfil & Ajustes", icon: Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    // Na tela principal de respiração (index 0), escondemos a BottomNavBar
    // para ficar fiel ao design full-screen clean,
    // OU mantemos styles similares. O design original não mostra bottom nav,
    // mas o app atual tem. Vou manter a nav por navegar, mas ajustada.
    return Scaffold(
      body: _screens[_currentIndex],
      // Opcional: Se quiser esconder a nav na home
      bottomNavigationBar: _currentIndex != 0
          ? BottomNavigationBar(
              backgroundColor: AppColors.brandBlue,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.brandGreen.withOpacity(0.5),
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.air),
                  label: 'Respirar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.show_chart),
                  label: 'Progresso',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Perfil',
                ),
              ],
            )
          : null, // Sem nav bar na home para imersão total
    );
  }
}

// -----------------------------------------------------------------------------
// 4. TELAS E WIDGETS
// -----------------------------------------------------------------------------

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
        _controller.repeat(
          min: 0.95,
          max: 1.0,
          period: const Duration(milliseconds: 1500),
          reverse: true,
        );
        break;
      case BreathPhase.exhale:
        _controller.stop();
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
      _animateToState(next);
    });

    final breathState = ref.watch(breathingProvider);

    if (_controller.status == AnimationStatus.dismissed &&
        breathState.phase == BreathPhase.inhale) {
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
                  horizontal: 16.0,
                  vertical: 20.0,
                ),
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
                    ),
                  ],
                ),
              ),
            ),

            // --- CENTER CONTENT ---
            Positioned.fill(
              bottom: 150, // Espaço para controles inferiores
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // VISUAL DO BREATHING (Círculos)
                  SizedBox(
                    width: 340,
                    height: 340,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Anéis Estáticos
                        Container(
                          width: 340,
                          height: 340,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        // Círculo Principal Animado
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            // Tamanho varia: min 200, max 260 (aprox)
                            final size = 200.0 + (_controller.value * 60.0);
                            return Container(
                              width: size,
                              height: size,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF0A5A8A),
                                    AppColors.brandBlue,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.15),
                                    blurRadius: 50,
                                    spreadRadius: 0,
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              // Inner Glow (simulado)
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primary.withOpacity(
                                          0.05,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Timer Text no centro
                                  Center(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                "${breathState.duration.inSeconds}",
                                            style: GoogleFonts.splineSans(
                                              fontSize: 64,
                                              fontWeight:
                                                  FontWeight.w100, // Thin
                                              color: Colors.white,
                                              height: 1.0,
                                            ),
                                          ),
                                          TextSpan(
                                            text: "s",
                                            style: GoogleFonts.splineSans(
                                              fontSize: 24,
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
                  // TEXTO DE ORIENTAÇÃO
                  Text(
                    breathState.label,
                    style: GoogleFonts.splineSans(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      shadows: [
                        const Shadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    breathState.subLabel,
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      color: AppColors.brandGreen.withOpacity(0.7),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

            // --- BOTTOM CONTROLS ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Botão de Seleção de Padrão
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 24.0,
                      left: 20,
                      right: 20,
                    ),
                    child: Container(
                      height: 56,
                      // minWidth e maxWidth manuseados pelo padding/container
                      decoration: BoxDecoration(
                        color: AppColors.brandGreen,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // TODO: Implementar seleção
                          },
                          borderRadius: BorderRadius.circular(100),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "CURRENT PATTERN",
                                      style: GoogleFonts.splineSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                        color: AppColors.brandBlue.withOpacity(
                                          0.6,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "4-7-8 Relaxation",
                                      style: GoogleFonts.splineSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.brandBlue,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.brandBlue.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.expand_less,
                                    color: AppColors.brandBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Ad Banner (Placeholder)
                  Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark.withOpacity(0.95),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withOpacity(0.05),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "AD SPACE",
                          style: GoogleFonts.notoSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 128,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
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
              style: GoogleFonts.notoSans(color: Colors.white54, fontSize: 22),
            ),
            const SizedBox(height: 40),
            // Botão para voltar
            TextButton(
              onPressed: () {
                // Navega para a home trocando o index no Scaffold pai
                // Isso requer que o estado seja elevado ou usando GlobalKey,
                // mas como é placeholder, deixaremos sem ação por enquanto
              },
              child: const Text(
                "Voltar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
