import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// -----------------------------------------------------------------------------
// 1. CONFIGURAÇÃO DE TEMA E CORES
// -----------------------------------------------------------------------------
class AppColors {
  static const Color background = Color(0xFF0F172A); // Navy muito escuro
  static const Color surface = Color(0xFF1E293B); // Slate escuro
  static const Color primary = Color(0xFF2DD4BF); // Teal vibrante
  static const Color secondary = Color(0xFF94A3B8); // Cinza azulado
  static const Color accentGlow = Color(0xFF0EA5E9); // Azul celeste (glow)
}

final appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.primary,
  useMaterial3: true,
  textTheme: GoogleFonts.montserratTextTheme(
    ThemeData.dark().textTheme,
  ).apply(bodyColor: Colors.white, displayColor: Colors.white),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.secondary,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
);

// -----------------------------------------------------------------------------
// 2. GERENCIAMENTO DE ESTADO (RIVERPOD)
// -----------------------------------------------------------------------------

enum BreathPhase { inhale, hold, exhale }

class BreathingState {
  final BreathPhase phase;
  final String label;
  final Duration duration;

  const BreathingState({
    required this.phase,
    required this.label,
    required this.duration,
  });
}

class BreathingNotifier extends StateNotifier<BreathingState> {
  Timer? _timer;

  BreathingNotifier()
    : super(
        const BreathingState(
          phase: BreathPhase.inhale,
          label: "INSPIRE...",
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
            label: "SEGURE",
            duration: Duration(seconds: 7),
          );
          break;
        case BreathPhase.hold:
          state = const BreathingState(
            phase: BreathPhase.exhale,
            label: "EXPIRE O AR",
            duration: Duration(seconds: 8),
          );
          break;
        case BreathPhase.exhale:
          state = const BreathingState(
            phase: BreathPhase.inhale,
            label: "INSPIRE...",
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

void main() {
  // Configuração para deixar a barra de status transparente no Android
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
    PlaceholderScreen(title: "Seu Histórico", icon: Icons.bar_chart),
    PlaceholderScreen(title: "Perfil & Ajustes", icon: Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.air), label: 'Respirar'),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: 'Progresso',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
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
    // O Controller não tem duração fixa global, definiremos a cada passo
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
        // Cresce de onde estiver até 1.0 (infla)
        _controller.animateTo(
          1.0,
          duration: state.duration,
          curve: Curves.easeInOutQuad,
        );
        break;

      case BreathPhase.hold:
        // Pulsar levemente enquanto segura no máximo (cheio)
        _controller.repeat(
          min: 0.95,
          max: 1.0,
          period: const Duration(milliseconds: 1500),
          reverse: true,
        );
        break;

      case BreathPhase.exhale:
        // Para qualquer animação de repetição e garante que vai para 0 (esvazia)
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
    // Escuta mudanças de estado para disparar animações
    ref.listen<BreathingState>(breathingProvider, (previous, next) {
      _animateToState(next);
    });

    // Estado atual para exibir textos (rebuilda UI)
    final breathState = ref.watch(breathingProvider);

    // Inicializa animação se for a primeira vez (Inhale começa auto no provider)
    if (_controller.status == AnimationStatus.dismissed &&
        breathState.phase == BreathPhase.inhale) {
      _animateToState(breathState);
    }

    return Stack(
      children: [
        // Fundo com gradiente radial sutil para dar profundidade
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF1B3B5A), AppColors.background],
                center: Alignment.center,
                radius: 1.5,
              ),
            ),
          ),
        ),

        // Elementos Centrais
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Círculo Animado
              SizedBox(
                width: 320,
                height: 320,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    // Calculando tamanho baseado no controller (0.0 a 1.0)
                    // Minimo 150px, Máximo 280px
                    final size = 150.0 + (_controller.value * 130.0);

                    // Opacidade do brilho aumenta com a inspiração
                    final opacity = 0.3 + (_controller.value * 0.4);

                    return Center(
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary.withOpacity(0.9),
                              AppColors.accentGlow.withOpacity(0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(opacity),
                              blurRadius: 30 + (30 * _controller.value),
                              spreadRadius: 5 + (10 * _controller.value),
                            ),
                            BoxShadow(
                              color: AppColors.accentGlow.withOpacity(opacity),
                              blurRadius: 60,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.self_improvement, // Ícone Zen
                            color: Colors.white.withOpacity(0.9),
                            size: 40 + (24 * _controller.value),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 60),

              // Texto Indicativo com Animação de Entrada
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.5),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  breathState.label,
                  key: ValueKey<String>(breathState.label),
                  style: GoogleFonts.montserrat(
                    fontSize: 26,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 6,
                    color: Colors.white.withOpacity(0.95),
                    shadows: [
                      const Shadow(
                        color: Colors.black45,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColors.surface),
          const SizedBox(height: 20),
          Text(
            "EM BREVE",
            style: GoogleFonts.montserrat(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 22),
          ),
        ],
      ),
    );
  }
}
