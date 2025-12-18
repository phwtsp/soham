import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BreathingCircle extends StatefulWidget {
  final Duration inhaleDuration;
  final Duration holdDuration;
  final Duration exhaleDuration;
  final double minSize;
  final double maxSize;
  final Color color;

  const BreathingCircle({
    super.key,
    required this.inhaleDuration,
    required this.holdDuration,
    required this.exhaleDuration,
    this.minSize = 100.0,
    this.maxSize = 200.0,
    this.color = Colors.blueAccent,
  });

  @override
  _BreathingCircleState createState() => _BreathingCircleState();
}

enum BreathingState { inhaling, holding, exhaling }

class _BreathingCircleState extends State<BreathingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  BreathingState _currentState = BreathingState.inhaling;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // O controller não terá duração fixa aqui, pois controlaremos dinamicamente
    _controller = AnimationController(vsync: this);
    _animation = Tween<double>(begin: widget.minSize, end: widget.maxSize)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _startBreathingCycle();
  }

  void _triggerHaptic() {
    if (!kIsWeb) {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _startBreathingCycle() async {
    if (!mounted) return;

    // 1. Inspiração (Cresce)
    setState(() => _currentState = BreathingState.inhaling);
    _triggerHaptic();
    await _controller.animateTo(1.0, duration: widget.inhaleDuration);

    if (!mounted) return;

    // 2. Retenção (Mantém cheio)
    setState(() => _currentState = BreathingState.holding);
    _triggerHaptic();
    // Pausa usando um Future.delayed, pois o controller já está em 1.0
    await Future.delayed(widget.holdDuration);

    if (!mounted) return;

    // 3. Expiração (Diminui)
    setState(() => _currentState = BreathingState.exhaling);
    _triggerHaptic();
    await _controller.animateTo(0.0, duration: widget.exhaleDuration);

    if (!mounted) return;

    // Recomeça o ciclo
    _startBreathingCycle();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: _animation.value,
          height: _animation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(0.8),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Text(
              _getStateText(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  String _getStateText() {
    switch (_currentState) {
      case BreathingState.inhaling:
        return "Inspire";
      case BreathingState.holding:
        return "Segure";
      case BreathingState.exhaling:
        return "Expire";
    }
  }
}
