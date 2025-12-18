import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// --- Provider para buscar dados dos últimos 7 dias ---

final weeklyStatsProvider = FutureProvider.autoDispose<List<double>>((
  ref,
) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return List.filled(7, 0.0);

  final now = DateTime.now();
  // Começo do dia (00:00) de 6 dias atrás (totalizando 7 dias com hoje)
  final startOfPeriod = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(const Duration(days: 6));

  final querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('sessions')
      .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfPeriod))
      .get();

  // Inicializa mapa com 0.0 para os últimos 7 dias
  // Chave: 'YYYY-MM-DD'
  Map<String, double> dailyMinutes = {};
  for (int i = 0; i < 7; i++) {
    final date = startOfPeriod.add(Duration(days: i));
    final key = DateFormat('yyyy-MM-dd').format(date);
    dailyMinutes[key] = 0.0;
  }

  // Agrega os minutos
  for (var doc in querySnapshot.docs) {
    final data = doc.data();
    final timestamp = (data['date'] as Timestamp).toDate();
    final durationSeconds = data['duration'] as int; // em segundos

    // Converte timestamp para chave do dia local
    final key = DateFormat('yyyy-MM-dd').format(timestamp);

    if (dailyMinutes.containsKey(key)) {
      dailyMinutes[key] = dailyMinutes[key]! + (durationSeconds / 60);
    }
  }

  // Retorna a lista ordenada (do dia mais antigo para hoje)
  return dailyMinutes.values.toList();
});

// --- Widget da Tela de Estatísticas ---

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyStatsAsync = ref.watch(weeklyStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seu Progresso'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Últimos 7 dias',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: const Color(
                  0xff232d37,
                ), // Cor de fundo escura para o gráfico ficar bonito
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 16.0,
                    left: 0,
                    top: 24,
                    bottom: 12,
                  ),
                  child: weeklyStatsAsync.when(
                    data: (data) => _BarChartWidget(data: data),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(
                      child: Text(
                        'Erro: $err',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Espaço para resumo textual se quiser
          ],
        ),
      ),
    );
  }
}

class _BarChartWidget extends StatelessWidget {
  final List<double> data;

  const _BarChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Calculando o máximo para o eixo Y não ficar cortado
    double maxY = 5.0; // Mínimo de 5 minutos
    if (data.isNotEmpty) {
      final maxData = data.reduce((curr, next) => curr > next ? curr : next);
      if (maxData > maxY) maxY = maxData + 5; // Folga de 5 min
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.round()} min',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (parsedValue, meta) {
                // Mapeia index 0..6 para dias da semana (ex: Seg, Ter)
                final index = parsedValue.toInt();
                if (index < 0 || index >= 7) return const SizedBox.shrink();

                final now = DateTime.now();
                // startOfPeriod foi (now - 6 dias)
                // O index 0 corresponde a 6 dias atrás. index 6 é hoje.
                final date = now.subtract(Duration(days: 6 - index));

                // Formatação simples do dia (ex: 16) ou dia da semana (ex: Seg)
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat(
                      'E',
                      'pt_BR',
                    ).format(date), // Requer initializeDateFormatting
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ), // Oculta eixo Y esquerdo para design limpo
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              const FlLine(color: Colors.white10, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                color: Colors.cyanAccent,
                width: 16,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY, // Fundo cinza até o topo
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
