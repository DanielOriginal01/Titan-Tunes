import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titan_tunes/core/app_theme.dart';
import 'package:titan_tunes/presentation/widgets/test_accounts_bottom_sheet.dart';
import 'package:titan_tunes/providers/audio_provider.dart';
import 'package:titan_tunes/providers/auth_provider.dart';

/// Login/Register — style maquette avec support complet des rôles et comptes de test
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _artistNameCtrl = TextEditingController();
  final _telephoneCtrl = TextEditingController(text: '+228');

  bool _showRegister = false;
  bool _obscure = true;
  bool _busy = false;
  bool _busyGoogle = false;
  String _selectedRole = 'ROLE_AUDITEUR'; // 'ROLE_AUDITEUR' | 'ROLE_ARTISTE'

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _fullNameCtrl.dispose();
    _artistNameCtrl.dispose();
    _telephoneCtrl.dispose();
    super.dispose();
  }

  void _toast(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: isError ? Colors.redAccent : null,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _busyGoogle = true);
    final auth = context.read<AuthProvider>();
    final err = await auth.loginWithGoogle(role: _selectedRole);
    if (!mounted) return;
    setState(() => _busyGoogle = false);
    if (err != null) {
      _toast(err, isError: true);
      return;
    }
    context.read<AudioProvider>().syncUser(auth.userId);
    Navigator.of(context).pop();
  }

  Future<void> _submit(AuthProvider auth) async {
    setState(() => _busy = true);
    if (_showRegister) {
      // Inscription via backend
      final telephone = _telephoneCtrl.text.trim();
      final err = await auth.registerWithBackend(
        username: _fullNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        telephone: telephone,
        role: _selectedRole,
        artistName: _selectedRole == 'ROLE_ARTISTE'
            ? _artistNameCtrl.text.trim()
            : null,
      );
      setState(() => _busy = false);
      if (err != null) {
        _toast(err, isError: true);
        return;
      }
      _toast('Inscription réussie ! Vous pouvez maintenant vous connecter.');
      if (mounted) setState(() => _showRegister = false);
    } else {
      // Connexion via backend
      final err = await auth.loginWithBackend(
        emailOuUsername: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      setState(() => _busy = false);
      if (err != null) {
        _toast(err, isError: true);
        return;
      }
      if (mounted) {
        context.read<AudioProvider>().syncUser(auth.userId);
        Navigator.of(context).pop();
      }
    }
  }

  void _openTestAccountsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TestAccountsBottomSheet(
        onSelectAccount: (email, password) {
          setState(() {
            _showRegister = false;
            _usernameCtrl.text = email;
            _passwordCtrl.text = password;
          });
          _submit(context.read<AuthProvider>());
        },
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController(text: _usernameCtrl.text.trim());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Mot de passe oublié'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Entrez votre adresse email pour recevoir un lien de réinitialisation :',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailCtrl.text.trim();
              if (email.isEmpty) return;
              Navigator.of(ctx).pop();
              final auth = context.read<AuthProvider>();
              final msg = await auth.forgotPasswordBackend(email: email);
              if (mounted) {
                _toast(msg ?? 'Lien de réinitialisation envoyé par email.');
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final fg = isDark ? Colors.white : Colors.black;
    final muted = isDark ? Colors.white54 : Colors.black45;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final logo = isDark
        ? 'assets/logos/titan_bleu_tunes.png'
        : 'assets/logos/titan_orange_tunes.png';

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Row(
          children: [
            // Colonne gauche décorative si écran large
            if (MediaQuery.of(context).size.width > 600)
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: Image.network(
                    'https://picsum.photos/seed/login/400/800',
                    fit: BoxFit.cover,
                    errorBuilder: (_, e, s) =>
                        Container(color: primary.withAlpha(80)),
                  ),
                ),
              ),

            // Formulaire
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Bouton retour + Bouton Comptes Test
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (Navigator.of(context).canPop())
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: primary,
                              size: 20,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            tooltip: 'Retour',
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          )
                        else
                          const SizedBox.shrink(),

                        // Bouton Comptes de test
                        OutlinedButton.icon(
                          onPressed: _openTestAccountsSheet,
                          icon: const Icon(Icons.science_rounded, size: 16),
                          label: const Text(
                            'Comptes Test',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primary,
                            side: BorderSide(color: primary, width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Logo
                    Center(
                      child: Image.asset(
                        logo,
                        height: 44,
                        errorBuilder: (_, e, s) => Text(
                          'Titan Tunes',
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Titre
                    Text(
                      _showRegister ? 'Créer un Compte' : 'Se Connecter',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: fg,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _showRegister
                          ? 'Rejoignez la plateforme musicale togolaise'
                          : 'Accédez à votre musique et vos playlists',
                      style: TextStyle(fontSize: 13, color: muted),
                    ),
                    const SizedBox(height: 24),

                    // Sélecteur de rôle pour l'inscription
                    if (_showRegister) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _RoleTab(
                              title: 'Auditeur',
                              icon: Icons.headphones_rounded,
                              selected: true,
                              primary: primary,
                              isDark: isDark,
                              onTap: () => setState(
                                () => _selectedRole = 'ROLE_AUDITEUR',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                    ],

                    // Champs
                    if (_showRegister) ...[
                      _Field(
                        controller: _fullNameCtrl,
                        hint: 'Nom complet / Nom d\'utilisateur',
                        icon: Icons.person_outline,
                        cardBg: cardBg,
                        fg: fg,
                      ),
                      const SizedBox(height: 14),
                      // Le parcours public de l'application reste ciblé sur l'auditeur.
                      _Field(
                        controller: _emailCtrl,
                        hint: 'Adresse Email',
                        icon: Icons.email_outlined,
                        cardBg: cardBg,
                        fg: fg,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      _Field(
                        controller: _telephoneCtrl,
                        hint: 'Numéro de téléphone (+228XXXXXXXX)',
                        icon: Icons.phone_outlined,
                        cardBg: cardBg,
                        fg: fg,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),
                    ] else ...[
                      _Field(
                        controller: _usernameCtrl,
                        hint: 'Email ou nom d\'utilisateur',
                        icon: Icons.person_outline,
                        cardBg: cardBg,
                        fg: fg,
                      ),
                      const SizedBox(height: 14),
                    ],

                    _Field(
                      controller: _passwordCtrl,
                      hint: 'Mot de passe',
                      icon: Icons.lock_outline,
                      obscure: _obscure,
                      cardBg: cardBg,
                      fg: fg,
                      suffix: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: muted,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),

                    if (!_showRegister) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPasswordDialog,
                          style: TextButton.styleFrom(
                            foregroundColor: primary,
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Text(
                            'Mot de passe oublié ?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Bouton principal
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _busy ? null : () => _submit(auth),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _busy
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _showRegister
                                    ? 'S\'inscrire (${_selectedRole == 'ROLE_ARTISTE' ? 'Artiste' : 'Auditeur'})'
                                    : 'Se Connecter',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Séparateur 'ou'
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: isDark
                                ? AppColors.dividerDark
                                : AppColors.divider,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'ou continuer avec',
                            style: TextStyle(color: muted, fontSize: 13),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: isDark
                                ? AppColors.dividerDark
                                : AppColors.divider,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Connexions sociales & Test
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialBtn(
                          label: 'G',
                          color: const Color(0xFFEA4335),
                          loading: _busyGoogle,
                          onTap: _busyGoogle || _busy
                              ? null
                              : _handleGoogleSignIn,
                        ),
                        const SizedBox(width: 16),
                        _SocialBtn(
                          icon: Icons.science_rounded,
                          color: Colors.amber,
                          onTap: _openTestAccountsSheet,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Bouton Continuer en tant qu'invité
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _busy || _busyGoogle
                            ? null
                            : () {
                                context.read<AuthProvider>().loginGuest();
                                Navigator.of(context).pushReplacementNamed('/home');
                              },
                        icon: Icon(
                          Icons.person_outline_rounded,
                          color: muted,
                        ),
                        label: Text(
                          'Continuer en tant qu\'invité',
                          style: TextStyle(
                            color: muted,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: muted.withAlpha(80)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bascule Login / Register
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 13, color: muted),
                          children: [
                            TextSpan(
                              text: _showRegister
                                  ? 'Vous avez déjà un compte ? '
                                  : 'Pas encore de compte ? ',
                            ),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _showRegister = !_showRegister,
                                ),
                                child: Text(
                                  _showRegister
                                      ? 'Se connecter'
                                      : 'S\'inscrire',
                                  style: TextStyle(
                                    color: primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleTab extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final Color primary;
  final bool isDark;
  final VoidCallback onTap;

  const _RoleTab({
    required this.title,
    required this.icon,
    required this.selected,
    required this.primary,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? primary.withAlpha(30)
              : (isDark ? AppColors.cardDark : AppColors.cardLight),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? primary : AppColors.divider.withAlpha(80),
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? primary
                  : (isDark ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected
                    ? primary
                    : (isDark ? Colors.white70 : Colors.black87),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final Color cardBg;
  final Color fg;
  final TextInputType? keyboardType;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.cardBg,
    required this.fg,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withAlpha(100)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: TextStyle(color: fg, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.mutedLight, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.mutedLight, size: 20),
          suffixIcon: suffix,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final Color color;
  final VoidCallback? onTap;
  final bool loading;

  const _SocialBtn({
    this.label,
    this.icon,
    required this.color,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: color,
                  ),
                )
              : icon != null
              ? Icon(icon, color: color, size: 24)
              : Text(
                  label!,
                  style: TextStyle(
                    color: onTap != null ? color : color.withAlpha(100),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }
}
