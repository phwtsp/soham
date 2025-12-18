import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_styles.dart';
import 'models.dart';
import 'breathing_provider.dart';
import 'create_pattern_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_providers.dart';
import 'paywall_screen.dart';

// Provider para padrões customizados
final customPatternsProvider =
    StreamProvider.autoDispose<List<CustomPattern>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('custom_patterns')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => CustomPattern.fromMap(doc.id, doc.data()))
        .toList();
  });
});

class PatternsScreen extends ConsumerWidget {
  const PatternsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPattern = ref.watch(breathingProvider).pattern;
    final customPatternsAsync = ref.watch(customPatternsProvider);
    final customPatterns = customPatternsAsync.value ?? [];

    final allPatterns = [...defaultPatterns, ...customPatterns];

    return Scaffold(
      backgroundColor: AppColors.brandBlue,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 28),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Padrões de Respiração",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.splineSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Balance space
                ],
              ),
            ),

            // List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                children: [
                  Text(
                    "Escolha um ritmo para começar sua prática",
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.brandGreen.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Patterns
                  ...allPatterns.map((pattern) {
                    final isSelected = pattern.id == currentPattern.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _PatternCard(
                        pattern: pattern,
                        isSelected: isSelected,
                        onTap: () {
                          ref
                              .read(breathingProvider.notifier)
                              .setPattern(pattern);
                        },
                        onPlay: () {
                          ref
                              .read(breathingProvider.notifier)
                              .setPattern(pattern);
                          ref.read(breathingProvider.notifier).resetSession();
                          ref
                              .read(breathingProvider.notifier)
                              .togglePlayPause();
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                        onEdit: pattern is CustomPattern
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CreatePatternScreen(
                                          patternToEdit: pattern)),
                                );
                              }
                            : null,
                        onDelete: pattern is CustomPattern
                            ? () async {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.uid)
                                      .collection('custom_patterns')
                                      .doc(pattern.id)
                                      .delete();
                                }
                              }
                            : null,
                      ),
                    );
                  }),

                  const SizedBox(height: 80), // Fab space
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: SizedBox(
          width: MediaQuery.of(context).size.width -
              48, // Full width minus padding
          height: 56,
          child: FloatingActionButton.extended(
            onPressed: () {
              final isPremium = ref.read(isPremiumProvider);
              if (!isPremium) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PaywallScreen()));
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreatePatternScreen()),
              );
            },
            backgroundColor: AppColors.brandGreen,
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            icon: const Icon(Icons.add_circle_outline,
                color: AppColors.brandBlue),
            label: Text(
              "Adicionar Respiração Personalizada",
              style: GoogleFonts.notoSans(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.brandBlue,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _PatternCard extends StatelessWidget {
  final BreathingPattern pattern;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onPlay;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _PatternCard({
    required this.pattern,
    required this.isSelected,
    required this.onTap,
    required this.onPlay,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.brandGreen
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(32),
          border: isSelected
              ? null
              : Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  "SELECIONADO",
                  style: GoogleFonts.splineSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AppColors.brandBlue.withOpacity(0.6),
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  pattern.name,
                  style: GoogleFonts.splineSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.brandBlue : Colors.white,
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.brandBlue.withOpacity(0.2),
                            width: 2)),
                    child: Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.brandBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.brandGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.brandGreen.withOpacity(0.2)),
                    ),
                    child: Text(
                      "${pattern.inhale}${pattern.hold > 0 ? '-${pattern.hold}' : ''}-${pattern.exhale}",
                      style: GoogleFonts.robotoMono(
                          fontSize: 12,
                          color: AppColors.brandGreen,
                          fontWeight: FontWeight.w500),
                    ),
                  )
              ],
            ),
            const SizedBox(height: 8),
            // Pattern Visualizer Bar
            // Simple visualizer with 3 chunks
            if (isSelected)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    Expanded(
                        flex: pattern.inhale,
                        child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                                color: AppColors.brandBlue.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(4)))),
                    const SizedBox(width: 4),
                    if (pattern.hold > 0) ...[
                      Expanded(
                          flex: pattern.hold,
                          child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                  color: AppColors.brandBlue.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(4)))),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                        flex: pattern.exhale,
                        child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                                color: AppColors.brandBlue.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(4)))),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    Expanded(
                        flex: pattern.inhale,
                        child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(3)))),
                    const SizedBox(width: 4),
                    if (pattern.hold > 0) ...[
                      Expanded(
                          flex: pattern.hold,
                          child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(3)))),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                        flex: pattern.exhale,
                        child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(3)))),
                  ],
                ),
              ),

            // Details
            if (isSelected)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _DetailItem(
                      label: "Inspire",
                      value: "${pattern.inhale}s",
                      color: AppColors.brandBlue),
                  if (pattern.hold > 0)
                    _DetailItem(
                        label: "Segure",
                        value: "${pattern.hold}s",
                        color: AppColors.brandBlue),
                  _DetailItem(
                      label: "Expire",
                      value: "${pattern.exhale}s",
                      color: AppColors.brandBlue),
                ],
              ),

            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onPlay,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text("INICIAR"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                    if (onEdit != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onEdit,
                        icon:
                            const Icon(Icons.edit, color: AppColors.brandBlue),
                        tooltip: "Editar",
                      ),
                    ],
                    if (onDelete != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        tooltip: "Excluir",
                      ),
                    ]
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  pattern.description,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DetailItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.splineSans(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.splineSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
