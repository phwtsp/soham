import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'app_styles.dart';
import 'models.dart';
import 'user_providers.dart';
import 'guest_view.dart';

// --- Providers ---

final recentSessionsProvider = StreamProvider.autoDispose<List<Session>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('sessions')
      .orderBy('date', descending: true)
      .limit(20) // Limit to recent 20 for list and streak calc
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Session.fromMap(doc.data())).toList());
});

final currentStreakProvider = Provider.autoDispose<int>((ref) {
  final sessionsAsync = ref.watch(recentSessionsProvider);
  final sessions = sessionsAsync.value ?? [];
  if (sessions.isEmpty) return 0;

  // Simple streak calculation
  // ordered desc
  int streak = 0;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Unique dates set
  final uniqueDates = <String>{};
  for (var s in sessions) {
    uniqueDates.add(DateFormat('yyyy-MM-dd').format(s.date));
  }

  // Check from today backwards
  // Note: This logic assumes 'sessions' contains enough history.
  // If user has 100 day streak but we only fetched 20 sessions, it might be cut off.
  // For a proper app, we should store 'currentStreak' in UserStats in Firestore.
  // For this demo, we verify against the fetched list.

  var checkDate = today;
  // If user didn't breathe today yet, check yesterday to start streak count?
  // Usually streak is "current active streak". If I haven't done it today, is it 0?
  // Or is it "streak so far"? Usually allowances are made.
  // Let's say: if today is missing, but yesterday exists, streak is alive.
  // If today exists, streak includes today.

  if (!uniqueDates.contains(DateFormat('yyyy-MM-dd').format(checkDate))) {
    // Check yesterday
    checkDate = checkDate.subtract(const Duration(days: 1));
    if (!uniqueDates.contains(DateFormat('yyyy-MM-dd').format(checkDate))) {
      return 0;
    }
  }

  while (true) {
    if (uniqueDates.contains(DateFormat('yyyy-MM-dd').format(checkDate))) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }

  return streak;
});

final weeklyStatsProvider =
    FutureProvider.autoDispose<List<double>>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return List.filled(7, 0.0);
  }

  final now = DateTime.now();
  final startOfPeriod =
      DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));

  final querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('sessions')
      .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfPeriod))
      .get();

  Map<String, double> dailyMinutes = {};
  for (int i = 0; i < 7; i++) {
    final date = startOfPeriod.add(Duration(days: i));
    final key = DateFormat('yyyy-MM-dd').format(date);
    dailyMinutes[key] = 0.0;
  }

  for (var doc in querySnapshot.docs) {
    final data = doc.data();
    final timestamp = (data['date'] as Timestamp).toDate();
    final durationSeconds = data['duration'] as int;

    final key = DateFormat('yyyy-MM-dd').format(timestamp);

    if (dailyMinutes.containsKey(key)) {
      dailyMinutes[key] = dailyMinutes[key]! + (durationSeconds / 60);
    }
  }

  return dailyMinutes.values.toList();
});

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final weeklyStatsAsync = ref.watch(weeklyStatsProvider);
    final recentSessionsAsync = ref.watch(recentSessionsProvider);
    final streak = ref.watch(currentStreakProvider);

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Seu Progresso'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: GuestView(
                message: "Faça login para acompanhar suas estatísticas"),
          ),
        ),
      );
    }

    // Default stats if user doc isn't created yet
    final totalSessions = userAsync.value?.stats.totalSessions ?? 0;
    final totalMinutes = userAsync.value?.stats.totalMinutes ?? 0;

    return Scaffold(
      backgroundColor: AppColors.brandBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Estatísticas",
                    style: GoogleFonts.splineSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(Icons.person, color: Colors.white),
                  )
                ],
              ),
              const SizedBox(height: 24),

              // Streak Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.brandGreen,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Decorative glow
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 30,
                            )
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "SEQUÊNCIA ATUAL",
                              style: GoogleFonts.splineSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: AppColors.brandBlue.withOpacity(0.7),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  "$streak",
                                  style: GoogleFonts.splineSans(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.brandBlue,
                                      height: 1.0),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "dias seguidos",
                                  style: GoogleFonts.splineSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.brandBlue,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.local_fire_department,
                            color: Color(0xFFF9BC06),
                            size: 32,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Chart Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.brandGreen,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "MINUTOS TOTAIS",
                              style: GoogleFonts.splineSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: AppColors.brandBlue.withOpacity(0.7),
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "${totalMinutes}m",
                                    style: GoogleFonts.splineSans(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.brandBlue,
                                    ),
                                  ),
                                  TextSpan(
                                    text: " / ${totalSessions} sessões",
                                    style: GoogleFonts.notoSans(
                                      fontSize: 14,
                                      color:
                                          AppColors.brandBlue.withOpacity(0.6),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "ÚLTIMOS 7 DIAS",
                            style: GoogleFonts.splineSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.brandBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Chart
                    SizedBox(
                      height: 180,
                      child: weeklyStatsAsync.when(
                        data: (data) => _BarChartWidget(data: data),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const SizedBox(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Recent Sessions Header
              Text(
                "Sessões Recentes",
                style: GoogleFonts.splineSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // List Items
              recentSessionsAsync.when(
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          "Nenhuma sessão recente.",
                          style: GoogleFonts.notoSans(color: Colors.white54),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: sessions
                        .map((session) => _SessionCard(session: session))
                        .toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Text("Erro: $e", style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarChartWidget extends StatelessWidget {
  final List<double> data;

  const _BarChartWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    double maxY = 5.0;
    if (data.isNotEmpty) {
      final maxData = data.reduce((curr, next) => curr > next ? curr : next);
      if (maxData > maxY) maxY = maxData + 5;
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceBetween,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: AppColors.brandBlue,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.round()} min',
                const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
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
                final index = parsedValue.toInt();
                if (index < 0 || index >= 7) return const SizedBox.shrink();
                final now = DateTime.now();
                final date = now.subtract(Duration(days: 6 - index));
                final isToday = index == 6;

                return Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    DateFormat('E', 'pt_BR').format(date)[0].toUpperCase(),
                    style: GoogleFonts.splineSans(
                        color:
                            AppColors.brandBlue.withOpacity(isToday ? 1 : 0.6),
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                );
              },
            ),
          ),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;
          final isToday = index == 6;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                color: isToday
                    ? const Color(0xFFF9F506)
                    : AppColors.brandBlue, // Primary yellow vs Brand Blue
                width: 12,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                    bottom: Radius.circular(6)), // Fully rounded
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: AppColors.brandBlue.withOpacity(0.1),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final Session session;

  const _SessionCard({required this.session});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDay = DateTime(date.year, date.month, date.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (sessionDay == today) return "Hoje";
    if (sessionDay == yesterday) return "Ontem";
    return DateFormat('d MMM', 'pt_BR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: AppColors.brandGreen.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ]),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.brandGreen,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.self_improvement, color: AppColors.brandBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.pattern,
                  style: GoogleFonts.splineSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandBlue,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _formatDate(session.date),
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.brandBlue.withOpacity(0.6),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.brandBlue.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(session.date),
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.brandBlue.withOpacity(0.6),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${(session.duration / 60).ceil()} min", // Display minutes
              style: GoogleFonts.splineSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.brandBlue,
              ),
            ),
          )
        ],
      ),
    );
  }
}
