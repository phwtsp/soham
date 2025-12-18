import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'app_styles.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  Package? _monthlyPackage;
  Package? _annualPackage;
  Package? _lifetimePackage;
  Package? _selectedPackage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOfferings();
  }

  Future<void> _fetchOfferings() async {
    if (kIsWeb) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        final current = offerings.current!;
        setState(() {
          _monthlyPackage = current.monthly;
          _annualPackage = current.annual;
          _lifetimePackage = current.lifetime;
          _selectedPackage =
              _annualPackage ?? _monthlyPackage ?? _lifetimePackage;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching offerings: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);
    if (kIsWeb) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Indisponível na Web.")));
      setState(() => _isLoading = false);
      return;
    }
    try {
      await Purchases.restorePurchases();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Compras restauradas com sucesso!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao restaurar: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _purchase() async {
    if (_selectedPackage == null) return;
    setState(() => _isLoading = true);

    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Compras indisponíveis na Web (Use Mobile).")));
      setState(() => _isLoading = false);
      return;
    }

    try {
      await Purchases.purchasePackage(_selectedPackage!);
      // Success is handled by listener or we can pop here
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        // User cancelled is common, don't necessarily show error unless distinct
        if (e is PlatformException && e.code == 'PURCHASE_CANCELLED') {
          // do nothing
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erro na compra: $e")),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If loading or no packages, show loader or fallback
    // But we want to show the UI even if loading (maybe skeleton).
    // For now, let's show loader only if doing transaction,
    // but if fetching initially, we show loading screen.

    // UI Constants from HTML
    const Color brandMint = Color(0xFFD1E9DE);
    // AppColors.brandBlue is typically 0xFF084D75

    if (_isLoading && _monthlyPackage == null && _annualPackage == null) {
      return const Scaffold(
        backgroundColor: AppColors.brandBlue,
        body:
            Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.brandBlue,
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      "https://lh3.googleusercontent.com/aida-public/AB6AXuB26Y9weXtVEfRKBRzvcnEZiiV5YC5gNiszRYrLHs1e96ibUXWROCLwxW_F-iVtdB-tSbXy2Y_x0QppZOvdFAJ9c6Mdyb1S8TrFjc0poPm14nUTUzTT1xjd-eEGqlz0GYSSs4JvloHLph2z5NJ0LlYB1FfOQL_O3rIe1yXxHKyg8tKivl0cF-5cu9bbTztZFDTvzHIUbIVwsx6Qn48DcXcRMUR6cWre86JVdy0x65VBAaiu9FnqMfBzQfUZPqg9z2lXaJ1Q81IXGVw"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Gradient Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x4D084D75), // brand-blue/30
                    Color(0x99084D75), // brand-blue/60
                    AppColors.brandBlue,
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: brandMint.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "PREMIUM",
                          style: GoogleFonts.splineSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: brandMint,
                            letterSpacing: 1.0,
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 120), // Spacing for image
                        // Headline
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: "Desbloqueie sua\n"),
                              TextSpan(
                                text: "Paz Interior",
                                style: TextStyle(color: brandMint),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.splineSans(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Eleve sua prática e encontre o equilíbrio.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: brandMint.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Benefits
                        _buildBenefitItem(Icons.block, "Remover Anúncios",
                            "Navegue sem interrupções", brandMint),
                        const SizedBox(height: 16),
                        _buildBenefitItem(Icons.tune, "Tempos Personalizados",
                            "Medite no seu próprio ritmo", brandMint),
                        const SizedBox(height: 16),
                        _buildBenefitItem(
                            Icons.query_stats,
                            "Gráficos Avançados",
                            "Acompanhe sua jornada diária",
                            brandMint),

                        const SizedBox(height: 32),

                        // Pricing Cards
                        Row(
                          children: [
                            Expanded(
                                child: _buildPricingCard(_annualPackage,
                                    type: 'annual')),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _buildPricingCard(_monthlyPackage,
                                    type: 'monthly')),
                          ],
                        ),
                        if (_lifetimePackage != null) ...[
                          const SizedBox(height: 12),
                          _buildPricingCard(_lifetimePackage, type: 'lifetime'),
                        ],

                        const SizedBox(height: 24),

                        // CTA Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _purchase,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.brandBlue,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              elevation: 8,
                              shadowColor: AppColors.primary.withOpacity(0.4),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "ASSINAR AGORA",
                                        style: GoogleFonts.splineSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward, size: 20),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        Text(
                          "Cancelamento grátis a qualquer momento.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            color: brandMint.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Footer Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: _restorePurchases,
                              child: Text(
                                "Restaurar Compras",
                                style: GoogleFonts.notoSans(
                                  fontSize: 12,
                                  color: brandMint.withOpacity(0.6),
                                ),
                              ),
                            ),
                            Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                    color: brandMint.withOpacity(0.2),
                                    shape: BoxShape.circle)),
                            TextButton(
                              onPressed: () {
                                // TODO: Termos logic
                              },
                              child: Text(
                                "Termos de Uso",
                                style: GoogleFonts.notoSans(
                                  fontSize: 12,
                                  color: brandMint.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildBenefitItem(
      IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: color.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: color.withOpacity(0.7)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPricingCard(Package? package, {required String type}) {
    final bool isSelected = _selectedPackage == package;
    final bool isAnnual = type == 'annual';
    final bool isLifetime = type == 'lifetime';

    // Fallback strings
    String priceString = "R\$ --";
    String title = "PLANO";
    String subtitle = "";

    if (package != null) {
      priceString = package.storeProduct.priceString;
    } else {
      // Demo fallbacks if loading or null
      if (isAnnual) priceString = "R\$ 199,90";
      if (type == 'monthly') priceString = "R\$ 19,90";
      if (isLifetime) priceString = "R\$ 399,90";
    }

    if (isAnnual) {
      title = "ANUAL";
      subtitle =
          "apenas ${(16.65).toStringAsFixed(2).replaceAll('.', ',')}/mês";
    } else if (isLifetime) {
      title = "VITALÍCIO";
      subtitle = "Pagamento único";
    } else {
      title = "MENSAL";
      subtitle = "Cobrado mensalmente";
    }

    return GestureDetector(
      onTap: () {
        if (package != null) setState(() => _selectedPackage = package);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                gradient: isSelected && isAnnual
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0B5A8A), Color(0xFF084D75)])
                    : null,
                color: isSelected && !isAnnual
                    ? Colors.white.withOpacity(0.1)
                    : (isSelected ? null : Colors.white.withOpacity(0.05)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.white.withOpacity(0.1),
                    width: isSelected ? 2 : 1),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                            color: AppColors.primary.withOpacity(0.5),
                            blurRadius: 8,
                            offset: Offset(0, 2))
                      ]
                    : null),
            child: Row(
                // Changed Column to Row for Lifetime consistency? No, design is vertical text
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.splineSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD1E9DE).withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          priceString,
                          style: GoogleFonts.splineSans(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.notoSans(
                            fontSize: 10,
                            color: const Color(0xFFD1E9DE).withOpacity(0.6),
                          ),
                        )
                      ],
                    ),
                  )
                ]),
          ),
          if (isAnnual)
            Positioned(
              top: -10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1), blurRadius: 4)
                      ]),
                  child: Text(
                    "ECONOMIZE 20%",
                    style: GoogleFonts.splineSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandBlue,
                    ),
                  ),
                ),
              ),
            ),
          if (isSelected)
            Positioned(
              bottom: 12,
              right: 12,
              child: const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 24),
            )
          else
            Positioned(
              bottom: 12,
              right: 12,
              child: Icon(Icons.radio_button_unchecked,
                  color: Colors.white.withOpacity(0.2), size: 24),
            )
        ],
      ),
    );
  }
}
