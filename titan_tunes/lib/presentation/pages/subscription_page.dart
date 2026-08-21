import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titan_tunes/core/app_theme.dart';
import 'package:titan_tunes/data/models/offre_abonnement.dart';
import 'package:titan_tunes/data/models/paiement_result.dart';
import 'package:titan_tunes/presentation/widgets/glassmorphism_widgets.dart';
import 'package:titan_tunes/providers/abonnement_provider.dart';
import 'package:titan_tunes/providers/auth_provider.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AbonnementProvider>().loadOffres();
    });
  }

  void _openPaymentSheet(OffreAbonnement offre) {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez vous connecter pour souscrire.'),
          action: SnackBarAction(
            label: 'Se connecter',
            onPressed: () => Navigator.of(context).pushNamed('/login'),
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentBottomSheet(offre: offre),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final abonnementProv = context.watch<AbonnementProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      body: PageBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
            physics: const BouncingScrollPhysics(),
            children: [
              // ── En-tête ──────────────────────────────────────────────────
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Abonnements Titan',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Statut Actuel ───────────────────────────────────────────
              GlassPanel(
                accentColor: primaryColor,
                borderRadius: BorderRadius.circular(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: primaryColor.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        auth.isSubscribed
                            ? Icons.workspace_premium_rounded
                            : Icons.music_note_rounded,
                        color: primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                auth.isSubscribed
                                    ? 'Abonné Actif'
                                    : 'Formule Gratuite',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: primaryColor,
                                ),
                              ),
                              if (auth.isSubscribed) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withAlpha(30),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.green),
                                  ),
                                  child: const Text(
                                    'PREMIUM',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            auth.isSubscribed
                                ? 'Expire le ${_formatDate(auth.subscriptionExpiryAt)}'
                                : 'Écoute illimitée, sans pub et téléchargements hors-ligne.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Nos Offres Mobile Money',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Paiement instantané en 1 clic via Flooz, T-Money ou Wave.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 16),

              if (abonnementProv.isLoadingOffres)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (abonnementProv.offres.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const Text('Impossible de charger les offres.'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => abonnementProv.loadOffres(),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              else
                ...abonnementProv.offres.map((offre) {
                  final isPopular = offre.code == 'MONTHLY';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _OffreCard(
                      offre: offre,
                      primaryColor: isPopular
                          ? primaryColor
                          : (isDark
                              ? AppColors.accentSkyBlue
                              : AppColors.accentDeepOrange),
                      isPopular: isPopular,
                      onTap: () => _openPaymentSheet(offre),
                    ),
                  );
                }),

              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Paiement sécurisé par NITCH-Corp / Titan Tunes',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

class _OffreCard extends StatelessWidget {
  final OffreAbonnement offre;
  final Color primaryColor;
  final bool isPopular;
  final VoidCallback onTap;

  const _OffreCard({
    required this.offre,
    required this.primaryColor,
    required this.isPopular,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPanel(
      accentColor: primaryColor,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          offre.label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (isPopular) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'MEILLEURE VENTE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offre.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                offre.formattedPrice,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '/ ${offre.durationLabel}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const Spacer(),
              if (offre.prixParJour > 0)
                Text(
                  '${offre.prixParJour.toStringAsFixed(0)} F/jour',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          ...offre.avantages.map(
            (av) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: primaryColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      av,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.flash_on_rounded, size: 18),
              label: Text('Souscrire (${offre.formattedPrice})'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentBottomSheet extends StatefulWidget {
  final OffreAbonnement offre;

  const _PaymentBottomSheet({required this.offre});

  @override
  State<_PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<_PaymentBottomSheet> {
  String _selectedOperator = 'FLOOZ'; // 'FLOOZ' | 'TMONEY' | 'WAVE'
  late final TextEditingController _phoneCtrl;
  SouscriptionResult? _receipt;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final userPhone = auth.phoneNumber ?? '+228';
    _phoneCtrl = TextEditingController(
      text: userPhone.startsWith('+228') ? userPhone : '+228$userPhone',
    );
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    final auth = context.read<AuthProvider>();
    final abonnementProv = context.read<AbonnementProvider>();

    final phone = _phoneCtrl.text.trim();
    if (phone.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un numéro de téléphone valide.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final result = await abonnementProv.souscrireEtPayer(
      auditeurId: auth.userId ?? '1',
      offreCode: widget.offre.code,
      modePaiement: _selectedOperator,
      telephone: phone,
    );

    if (result != null && result.succes) {
      setState(() => _receipt = result);
      // Mettre à jour l'état d'abonnement dans AuthProvider
      final expiryDate = result.abonnement?.endDate ??
          DateTime.now().add(Duration(days: widget.offre.dureeDays));
      auth.activateSubscription(
        offerCode: widget.offre.code,
        expiryDate: expiryDate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final abonnementProv = context.watch<AbonnementProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        22,
        18,
        22,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: _receipt != null
          ? _buildReceiptView(theme, primary, isDark)
          : _buildPaymentForm(theme, primary, isDark, abonnementProv),
    );
  }

  Widget _buildPaymentForm(
    ThemeData theme,
    Color primary,
    bool isDark,
    AbonnementProvider prov,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 18),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paiement Mobile Money',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${widget.offre.label} · ${widget.offre.formattedPrice}',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Choix de l'opérateur
        Text(
          'Sélectionnez votre opérateur :',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _OperatorButton(
                label: 'Moov FLOOZ',
                code: 'FLOOZ',
                color: const Color(0xFF007A3D),
                selected: _selectedOperator == 'FLOOZ',
                onTap: () => setState(() => _selectedOperator = 'FLOOZ'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _OperatorButton(
                label: 'T-Money',
                code: 'TMONEY',
                color: const Color(0xFFE31B23),
                selected: _selectedOperator == 'TMONEY',
                onTap: () => setState(() => _selectedOperator = 'TMONEY'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _OperatorButton(
                label: 'Wave',
                code: 'WAVE',
                color: const Color(0xFF1EA1F2),
                selected: _selectedOperator == 'WAVE',
                onTap: () => setState(() => _selectedOperator = 'WAVE'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Numéro de téléphone
        Text(
          'Numéro de compte Mobile Money :',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider.withAlpha(100)),
          ),
          child: TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              hintText: '+228XXXXXXXX',
              prefixIcon: Icon(Icons.phone_android_rounded),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),

        if (prov.errorMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.redAccent.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent.withAlpha(80)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Colors.redAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    prov.errorMessage!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 22),

        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: prov.isPaying ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: prov.isPaying
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Validation du paiement...'),
                    ],
                  )
                : Text(
                    'Payer ${widget.offre.formattedPrice} via $_selectedOperator',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptView(ThemeData theme, Color primary, bool isDark) {
    final p = _receipt!.paiement;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'Paiement Réussi !',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _receipt!.message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider.withAlpha(80)),
          ),
          child: Column(
            children: [
              _ReceiptRow(
                  label: 'Référence Transaction',
                  value: p?.transactionRef ?? 'N/A'),
              const Divider(height: 16),
              _ReceiptRow(
                  label: 'Opérateur',
                  value: p?.operateur ?? _selectedOperator),
              const Divider(height: 16),
              _ReceiptRow(
                  label: 'Montant Payé',
                  value: '${p?.montant.toInt() ?? widget.offre.prixFcfa.toInt()} FCFA'),
              const Divider(height: 16),
              _ReceiptRow(label: 'Statut', value: p?.statut ?? 'SUCCES'),
            ],
          ),
        ),
        const SizedBox(height: 22),

        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'Profiter de Titan Premium',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ],
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReceiptRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }
}

class _OperatorButton extends StatelessWidget {
  final String label;
  final String code;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _OperatorButton({
    required this.label,
    required this.code,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? color.withAlpha(30)
              : (isDark ? AppColors.cardDark : AppColors.cardLight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : AppColors.divider.withAlpha(80),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.account_balance_wallet_rounded,
                color: selected ? color : Colors.grey, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? color : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
