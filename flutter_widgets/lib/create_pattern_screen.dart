import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_styles.dart';
import 'models.dart';
import 'breathing_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatePatternScreen extends ConsumerStatefulWidget {
  final CustomPattern? patternToEdit;

  const CreatePatternScreen({super.key, this.patternToEdit});

  @override
  ConsumerState<CreatePatternScreen> createState() =>
      _CreatePatternScreenState();
}

class _CreatePatternScreenState extends ConsumerState<CreatePatternScreen> {
  late TextEditingController _nameController;
  late double _inhale;
  late double _hold;
  late double _exhale;

  @override
  void initState() {
    super.initState();
    final p = widget.patternToEdit;
    _nameController =
        TextEditingController(text: p?.name ?? "Respiração Personalizada");
    _inhale = p?.inhale.toDouble() ?? 4;
    _hold = p?.hold.toDouble() ?? 2;
    _exhale = p?.exhale.toDouble() ?? 6;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalCycle = _inhale + _hold + _exhale;

    return Scaffold(
      backgroundColor:
          AppColors.backgroundLight, // Light mode by default as in html
      // Handling dark mode if system requires it, but HTML shows "light" class initially with dark mode support.
      // Let's stick to valid Flutter theming or forces. The app seems dark themed generally.
      // HTML has <body class="bg-background-light dark:bg-background-dark">.
      // Main app is Dark. Let's make this screen Dark to match the app consistency,
      // or light if we want to follow the specific HTML file strictly.
      // HTML `criar.html` has light background by default but supports dark.
      // Since the rest of the app (`main.dart`) sets `brightness: Brightness.dark` and `scaffoldBackgroundColor: AppColors.brandBlue`,
      // I should probably stick to the dark theme for consistency, OR implement the light theme for this screen.
      // The `main.dart` theme is forced dark. I will use dark theme for consistency.

      body: Container(
        color: AppColors.backgroundDark,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 28),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Criar Respiração",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.splineSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Name Input
                      Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "NOME DO PADRÃO",
                              style: GoogleFonts.splineSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                                color: AppColors.brandGreen,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _nameController,
                              style: GoogleFonts.splineSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.brandBlue.withOpacity(0.5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.all(20),
                                suffixIcon: Icon(Icons.edit,
                                    color: Colors.white.withOpacity(0.4)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Visualizer
                      AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(32),
                            image: const DecorationImage(
                              image: NetworkImage(
                                  "https://lh3.googleusercontent.com/aida-public/AB6AXuCZGuiRnGx29kNDMS5qEKZmwIA_UPIOrPSB36tVKk0g8yyQ_Z1Tc2kACdbG5fLq13pgSqr4ftLKjECM_1MYkIS1NH-xenN7aOykDT8CdNPv2j8jDROXhDafOGc3hwR4SG8LzRD56jTzAU9rLyXh05FfYRdYyNYrSUMo2JzhbV2i3O7e5bFT_v2tHwJfc-5Qgtt561CBXQ6W18XGUhKayt1GiXL0nUR-VbW3TTYi1tUBu2H3PBFPoIZaZCBnGgJ6FUv2kX_n4BH2Ytg"),
                              fit: BoxFit.cover,
                              opacity: 0.4,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color:
                                          AppColors.brandGreen.withOpacity(0.2),
                                      width: 6),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 110,
                                    height: 110,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white.withOpacity(0.1)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "${totalCycle.toInt()}s",
                                          style: GoogleFonts.splineSans(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            height: 1.0,
                                          ),
                                        ),
                                        Text(
                                          "CICLO",
                                          style: GoogleFonts.splineSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                            color: AppColors.brandGreen,
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
                      ),

                      const SizedBox(height: 32),

                      // Sliders
                      _BreathingSlider(
                        label: "Tempo Inspirar",
                        icon: Icons.air,
                        value: _inhale,
                        color: AppColors.brandGreen,
                        onChanged: (val) => setState(() => _inhale = val),
                      ),
                      const SizedBox(height: 16),
                      _BreathingSlider(
                        label: "Tempo Segurar",
                        icon: Icons.pause_circle_outline,
                        value: _hold,
                        color: AppColors
                            .primary, // Using primary yellow/green distinct
                        onChanged: (val) => setState(() => _hold = val),
                      ),
                      const SizedBox(height: 16),
                      _BreathingSlider(
                        label: "Tempo Expirar",
                        icon: Icons.air,
                        value: _exhale,
                        flippedIcon: true,
                        color: AppColors.brandGreen,
                        onChanged: (val) => setState(() => _exhale = val),
                      ),
                      const SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        color: AppColors.backgroundDark.withOpacity(0.95), // Match bg
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                final newPattern = CustomPattern(
                  id: widget.patternToEdit?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _nameController.text.isNotEmpty
                      ? _nameController.text
                      : "Personalizado",
                  description: "Personalizado",
                  inhale: _inhale.toInt(),
                  hold: _hold.toInt(),
                  exhale: _exhale.toInt(),
                );

                // 1. Save locally to provider to play immediately
                ref.read(breathingProvider.notifier).setPattern(newPattern);

                // 2. Save to Firestore if user is logged in
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('custom_patterns')
                        .doc(widget.patternToEdit?.id ?? newPattern.id)
                        .set(newPattern.toMap());

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(widget.patternToEdit != null
                                ? "Padrão atualizado!"
                                : "Padrão salvo na nuvem!")),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Erro ao salvar: $e")),
                      );
                    }
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text("Faça login para salvar permanentemente.")),
                    );
                  }
                }

                // Return to home, popping both this and pattern screen?
                // The flow says: Custom -> Create. Upon creating, we likely visualize it immediately.
                // So navigate "Back" to home.
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.brandBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline),
                  const SizedBox(width: 8),
                  Text(
                    "Salvar Padrão",
                    style: GoogleFonts.splineSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BreathingSlider extends StatelessWidget {
  final String label;
  final IconData icon;
  final double value;
  final Color color;
  final ValueChanged<double> onChanged;
  final bool flippedIcon;

  const _BreathingSlider({
    required this.label,
    required this.icon,
    required this.value,
    required this.color,
    required this.onChanged,
    this.flippedIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Transform.scale(
                      scaleX: flippedIcon ? -1 : 1,
                      child: Icon(icon, color: AppColors.brandGreen)),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: GoogleFonts.splineSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                "${value.toInt()}s",
                style: GoogleFonts.splineSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 12,
              activeTrackColor: color,
              inactiveTrackColor: Colors.white.withOpacity(0.1),
              thumbColor: Colors.white,
              overlayColor: color.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 20, // Max reasonable seconds
              divisions: 20,
              onChanged: onChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("0s",
                    style: TextStyle(color: Colors.white.withOpacity(0.4))),
                Text("20s",
                    style: TextStyle(color: Colors.white.withOpacity(0.4))),
              ],
            ),
          )
        ],
      ),
    );
  }
}
