import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titan_tunes/core/app_theme.dart';
import 'package:titan_tunes/providers/audio_provider.dart';
import 'package:titan_tunes/providers/auth_provider.dart';

class TestAccountInfo {
  final String role;
  final String email;
  final String password;
  final String description;
  final IconData icon;
  final Color color;

  const TestAccountInfo({
    required this.role,
    required this.email,
    required this.password,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class TestAccountsBottomSheet extends StatefulWidget {
  final Function(String email, String password)? onSelectAccount;

  const TestAccountsBottomSheet({super.key, this.onSelectAccount});

  static const List<TestAccountInfo> testAccounts = [
    TestAccountInfo(
      role: 'AUDITEUR (Abonné)',
      email: 'amina.koffi@email.tg',
      password: 'Auditeur@2026!',
      description: 'Auditeur avec abonnement mensuel actif',
      icon: Icons.workspace_premium_rounded,
      color: Colors.amber,
    ),
    TestAccountInfo(
      role: 'AUDITEUR (Non abonné)',
      email: 'akua.boko@email.tg',
      password: 'Auditeur@2026!',
      description: 'Auditeur standard sans abonnement actif',
      icon: Icons.person_rounded,
      color: Colors.blueAccent,
    ),
  ];

  @override
  State<TestAccountsBottomSheet> createState() =>
      _TestAccountsBottomSheetState();
}

class _TestAccountsBottomSheetState extends State<TestAccountsBottomSheet> {
  bool _isLoggingIn = false;
  String? _loggingAccountEmail;

  Future<void> _loginDirect(TestAccountInfo account) async {
    if (widget.onSelectAccount != null) {
      widget.onSelectAccount!(account.email, account.password);
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isLoggingIn = true;
      _loggingAccountEmail = account.email;
    });

    final auth = context.read<AuthProvider>();
    final err = await auth.loginWithBackend(
      emailOuUsername: account.email,
      password: account.password,
    );

    if (!mounted) return;
    setState(() {
      _isLoggingIn = false;
      _loggingAccountEmail = null;
    });

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connexion impossible: $err'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      context.read<AudioProvider>().syncUser(auth.userId);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Poignée
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primary.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.science_rounded, color: primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comptes de Test (1-Clic)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Sélectionnez un rôle pour tester immédiatement',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: TestAccountsBottomSheet.testAccounts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final acc = TestAccountsBottomSheet.testAccounts[i];
                final isCurrentLoading =
                    _isLoggingIn && _loggingAccountEmail == acc.email;

                return InkWell(
                  onTap: _isLoggingIn ? null : () => _loginDirect(acc),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: acc.color.withAlpha(80),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: acc.color.withAlpha(30),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(acc.icon, color: acc.color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    acc.role,
                                    style: TextStyle(
                                      color: acc.color,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                acc.email,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                acc.description,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.hintColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isCurrentLoading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: theme.hintColor,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
