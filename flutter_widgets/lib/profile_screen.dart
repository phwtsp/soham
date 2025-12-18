import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_styles.dart';
import 'user_providers.dart';
import 'models.dart';
import 'guest_view.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.brandBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Perfil",
                style: GoogleFonts.splineSans(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              userAsync.when(
                data: (user) {
                  if (user == null) {
                    return const GuestView(); // Use shared GuestView
                  }
                  return _UserView(user: user);
                },
                loading: () => const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.brandGreen)),
                error: (err, stack) => Text('Erro: $err',
                    style: const TextStyle(color: Colors.white)),
              ),

              const SizedBox(height: 48),

              // Settings Section (Placeholder)
              Text(
                "Configurações",
                style: GoogleFonts.splineSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: "Lembretes",
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: "Tema Escuro",
                onTap: () {},
                trailing: Switch(
                  value: true,
                  onChanged: (v) {},
                  activeColor: AppColors.brandGreen,
                ),
              ),
              _SettingsTile(
                icon: Icons.info_outline,
                title: "Sobre",
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserView extends StatelessWidget {
  final AppUser user;

  const _UserView({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.brandGreen,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  user.email.isNotEmpty ? user.email[0].toUpperCase() : 'U',
                  style: GoogleFonts.splineSans(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.email,
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (user.isPremium)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "PREMIUM",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.logout, color: Colors.redAccent),
            )
          ],
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: "Sessões",
                value: "${user.stats.totalSessions}",
                icon: Icons.check_circle_outline,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                label: "Minutos",
                value: "${user.stats.totalMinutes}",
                icon: Icons.timer_outlined,
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.brandGreen, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.splineSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingsTile(
      {required this.icon,
      required this.title,
      required this.onTap,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.notoSans(
            color: Colors.white, fontWeight: FontWeight.w500),
      ),
      trailing:
          trailing ?? const Icon(Icons.chevron_right, color: Colors.white30),
    );
  }
}
