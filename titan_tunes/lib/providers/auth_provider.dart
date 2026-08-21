import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:titan_tunes/network/network_api_client.dart';
import 'package:titan_tunes/services/api_auth_service.dart';
import 'package:titan_tunes/services/local_user_storage.dart';

class AuthProvider extends ChangeNotifier {
  static const String countryDialCode = '+228';
  static const String defaultAvatarAsset = 'assets/logos/image.png';

  // ── Dépendances injectées (peuvent être null en mode démo) ──────────────
  ApiAuthService? _apiAuth;
  TokenVault? _tokenVault;
  LocalUserStorage? _storage;

  bool _isLoggedIn = false;
  bool _isPhoneVerified = false;
  bool _hasAccount = false;
  bool _isGuest = false;

  String? _userId;
  bool _isArtist = false;
  bool _isAdmin = false;

  String? _userName;
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _gender;
  DateTime? _birthDate;
  DateTime? _createdAt;
  DateTime? _updatedAt;
  String? _avatarUrl;
  Uint8List? _avatarBytes;
  String? _phoneNumber;
  String? _pendingOtp;
  String? _userPassword;
  String? _registeredUsername;
  String? _registeredPassword;
  SubscriptionPlan _subscriptionPlan = SubscriptionPlan.free;
  DateTime? _subscriptionExpiryAt;
  AuthMethod? _authMethod;

  ThemeMode _themeMode = ThemeMode.system;
  int _guestPlayCount = 0;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isPhoneVerified => _isPhoneVerified;
  bool get hasAccount => _hasAccount;
  bool get isGuest => _isGuest;
  String? get userId => _userId;
  bool get isArtist => _isArtist;
  bool get isAdmin => _isAdmin;
  bool get isSubscribed =>
      _subscriptionExpiryAt != null &&
      _subscriptionExpiryAt!.isAfter(DateTime.now());
  DateTime? get subscriptionExpiryAt => _subscriptionExpiryAt;
  SubscriptionPlan get subscriptionPlan => _subscriptionPlan;
  AuthMethod? get authMethod => _authMethod;
  String? get userName => _userName;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get email => _email;
  String? get gender => _gender;
  DateTime? get birthDate => _birthDate;
  DateTime? get createdAt => _createdAt;
  DateTime? get updatedAt => _updatedAt;
  String? get avatarUrl => _avatarUrl;
  Uint8List? get avatarBytes => _avatarBytes;
  String? get phoneNumber => _phoneNumber;
  String? get pendingOtp => _pendingOtp;
  String? get userPassword => _userPassword;
  String? get registeredUsername => _registeredUsername;
  ThemeMode get themeMode => _themeMode;
  int get guestPlayCount => _guestPlayCount;
  bool get canPlayAsGuest => _guestPlayCount < 10;

  String get userInitials {
    final sourceName = [
      if ((_firstName ?? '').isNotEmpty) _firstName!,
      if ((_lastName ?? '').isNotEmpty) _lastName!,
    ].join(' ').trim();
    final fallbackName = sourceName.isNotEmpty ? sourceName : (_userName ?? '');
    if (fallbackName.isEmpty) return 'TT';
    final parts = fallbackName.split(' ');
    final a = parts.first.characters.first.toUpperCase();
    final b =
        parts.length > 1 ? parts.last.characters.first.toUpperCase() : '';
    return '$a$b';
  }

  String get subscriptionLabel {
    switch (_subscriptionPlan) {
      case SubscriptionPlan.free:
        return 'Gratuit';
      case SubscriptionPlan.weekly:
        return 'Hebdomadaire';
      case SubscriptionPlan.monthly:
        return 'Mensuel';
    }
  }

  String get displayName {
    final composedName = [
      if ((_firstName ?? '').isNotEmpty) _firstName!,
      if ((_lastName ?? '').isNotEmpty) _lastName!,
    ].join(' ').trim();
    return composedName.isNotEmpty
        ? composedName
        : (_userName ??
            (_phoneNumber != null
                ? 'Utilisateur $_phoneNumber'
                : 'Titan Tunes'));
  }

  String get diagramDisplayName =>
      [
        if ((_firstName ?? '').isNotEmpty) _firstName!,
        if ((_lastName ?? '').isNotEmpty) _lastName!,
      ].join(' ').trim().isNotEmpty
          ? [
              if ((_firstName ?? '').isNotEmpty) _firstName!,
              if ((_lastName ?? '').isNotEmpty) _lastName!,
            ].join(' ').trim()
          : displayName;

  // ── Initialisation ─────────────────────────────────────────────────────

  Future<void> init({
    dynamic storage,
    dynamic tokenVault,
    dynamic apiAuth,
    dynamic googleAuth,
  }) async {
    if (storage is LocalUserStorage) _storage = storage;
    if (tokenVault is TokenVault) _tokenVault = tokenVault;
    if (apiAuth is ApiAuthService) _apiAuth = apiAuth;

    if (_storage != null) {
      await _restoreSessionFromLocalStorage();
    }

    if (_tokenVault != null && _tokenVault!.hasToken) {
      await _restoreSessionFromToken();
      if (_apiAuth != null && _userId != null) {
        try {
          final profile = await _apiAuth!.getCurrentUserProfile(userId: _userId!);
          _applyProfile(profile);
          await _persistSessionToLocalStorage();
        } catch (e) {
          debugPrint('AuthProvider.sync user profile error: $e');
        }
      }
    }

    if (_storage != null && (_userId != null || _isLoggedIn)) {
      await _persistSessionToLocalStorage();
    }
    notifyListeners();
  }

  Future<void> _restoreSessionFromLocalStorage() async {
    if (_storage == null) return;

    _isLoggedIn = _storage!.isLoggedIn;
    _userId = _storage!.userId;
    _userName = _storage!.userName;
    _firstName = _storage!.firstName;
    _lastName = _storage!.lastName;
    _email = _storage!.email;
    _phoneNumber = _storage!.phoneNumber;
    _gender = _storage!.gender;
    _birthDate = _storage!.birthDate;
    _avatarUrl = _storage!.avatarUrl;
    _avatarBytes = _storage!.avatarBytes;
    _isPhoneVerified = _storage!.isPhoneVerified;
    _subscriptionPlan = _subscriptionPlanFromString(_storage!.subscriptionPlan);
    _subscriptionExpiryAt = _storage!.subscriptionExpiry;
    final role = (_storage!.role ?? '').toUpperCase();
    _isArtist = role == 'ROLE_ARTISTE';
    _isAdmin = role == 'ROLE_ADMIN';
    _authMethod = _authMethodFromString(_storage!.authMethod);
    _hasAccount = _userId != null || _email != null || _userName != null;
    _themeMode = ThemeMode.values[_storage!.themeMode.clamp(0, ThemeMode.values.length - 1)];
  }

  Future<void> _persistSessionToLocalStorage() async {
    if (_storage == null) return;

    await _storage!.saveSession(
      isLoggedIn: _isLoggedIn,
      userId: _userId ?? '',
      userName: _userName ?? _email?.split('@').first ?? 'TitanTunes',
      firstName: _firstName,
      lastName: _lastName,
      email: _email,
      phone: _phoneNumber,
      role: _isArtist ? 'ROLE_ARTISTE' : (_isAdmin ? 'ROLE_ADMIN' : 'ROLE_AUDITEUR'),
      authMethod: _authMethod?.name,
      avatarUrl: _avatarUrl,
      subscriptionPlan: _subscriptionPlan.name,
      subscriptionExpiry: _subscriptionExpiryAt,
      isPhoneVerified: _isPhoneVerified,
    );
  }

  void _applyProfile(Map<String, dynamic> data) {
    final id = data['id'] ?? data['userId'] ?? data['sub'];
    if (id != null) _userId = id.toString();
    final username = data['username'] ?? data['name'];
    if (username != null) _userName = username.toString();
    final email = data['email'];
    if (email != null) _email = email.toString();
    final firstName = data['firstName'] ?? data['prenom'];
    if (firstName != null) _firstName = firstName.toString();
    final lastName = data['lastName'] ?? data['nom'];
    if (lastName != null) _lastName = lastName.toString();
    final role = data['role'] ?? data['roles'];
    if (role is List) {
      final normalized = role.map((e) => e.toString()).join(',');
      _isArtist = normalized.toUpperCase().contains('ARTISTE');
      _isAdmin = normalized.toUpperCase().contains('ADMIN');
    } else if (role != null) {
      final roleValue = role.toString();
      _isArtist = roleValue.toUpperCase().contains('ARTISTE');
      _isAdmin = roleValue.toUpperCase().contains('ADMIN');
    }
    final avatar = data['avatarUrl'] ?? data['photoUrl'];
    if (avatar != null) _avatarUrl = avatar.toString();
    final phone = data['telephone'] ?? data['phoneNumber'];
    if (phone != null) _phoneNumber = phone.toString();
    _hasAccount = true;
    _isLoggedIn = true;
    _updatedAt = DateTime.now();
  }

  SubscriptionPlan _subscriptionPlanFromString(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'weekly':
        return SubscriptionPlan.weekly;
      case 'monthly':
        return SubscriptionPlan.monthly;
      case 'free':
      default:
        return SubscriptionPlan.free;
    }
  }

  AuthMethod? _authMethodFromString(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'phone':
        return AuthMethod.phone;
      case 'google':
        return AuthMethod.google;
      case 'facebook':
        return AuthMethod.facebook;
      case 'backend':
        return AuthMethod.backend;
      case 'demo':
        return AuthMethod.demo;
      default:
        return null;
    }
  }

  /// Parse le payload JWT pour extraire userId, email, role, etc.
  Future<void> _restoreSessionFromToken() async {
    try {
      final token = _tokenVault!.accessToken;
      if (token == null || token.isEmpty) return;

      final parts = token.split('.');
      if (parts.length != 3) return;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final data = jsonDecode(decoded) as Map<String, dynamic>;

      _userId = (data['sub'] ?? data['id'] ?? '').toString();
      _email = data['email'] as String?;
      _userName = data['username'] as String? ?? _email?.split('@').first;

      final role = data['role'] as String? ?? '';
      _isArtist = role == 'ROLE_ARTISTE';
      _isAdmin = role == 'ROLE_ADMIN';

      _isLoggedIn = true;
      _hasAccount = true;
      _authMethod = AuthMethod.backend;
      _createdAt ??= DateTime.now();
      _updatedAt = DateTime.now();
    } catch (e) {
      debugPrint('AuthProvider._restoreSessionFromToken error: $e');
      // Token invalide → on nettoie
      await _tokenVault?.clear();
    }
  }

  // ── Login Backend (vraiment connecté à l'API) ──────────────────────────

  Future<String?> loginWithBackend({
    String? usernameOrEmail,
    String? emailOuUsername,
    required String password,
  }) async {
    usernameOrEmail ??= emailOuUsername ?? '';
    final credential = usernameOrEmail.trim();
    if (credential.isEmpty) return 'Veuillez saisir un identifiant.';
    if (password.trim().isEmpty) return 'Veuillez saisir un mot de passe.';

    // Si pas de service backend, fallback démo
    if (_apiAuth == null) {
      return _loginDemo(credential);
    }

    try {
      final result = await _apiAuth!.login(
        emailOuUsername: credential,
        password: password,
      );

      // Sauvegarder les tokens
      await _tokenVault?.setTokens(
        token: result.token,
        refreshToken: result.refreshToken,
        expiry: DateTime.now().add(const Duration(hours: 1)),
      );

      // Mettre à jour l'état
      _userId = result.userId;
      _userName = result.username;
      _email = result.email;
      _isArtist = result.role == 'ROLE_ARTISTE';
      _isAdmin = result.role == 'ROLE_ADMIN';
      _isLoggedIn = true;
      _hasAccount = true;
      _authMethod = AuthMethod.backend;
      _createdAt ??= DateTime.now();
      _updatedAt = DateTime.now();
      await _persistSessionToLocalStorage();
      notifyListeners();
      return null; // succès
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (msg.toLowerCase().contains('bloqué') || msg.toLowerCase().contains('inactif')) {
        return 'Votre compte a été bloqué. Veuillez contacter le support.';
      }
      return msg.isNotEmpty ? msg : 'Échec de la connexion.';
    }
  }

  /// Fallback démo quand le backend est indisponible
  String? _loginDemo(String credential) {
    _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    _isLoggedIn = true;
    _userName =
        credential.contains('@') ? credential.split('@').first : credential;
    _hasAccount = true;
    _authMethod = AuthMethod.demo;
    _createdAt ??= DateTime.now();
    _updatedAt = DateTime.now();
    _persistSessionToLocalStorage();
    notifyListeners();
    return null;
  }

  // ── Register Backend ───────────────────────────────────────────────────

  Future<String?> registerWithBackend({
    required String username,
    required String email,
    required String password,
    String? phoneNumber,
    String? telephone,
    String? role,
    String? artistName,
  }) async {
    if (username.trim().isEmpty) {
      return 'Veuillez saisir un nom d\'utilisateur.';
    }
    if (password.trim().length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères.';
    }

    // Si pas de service backend, fallback démo
    if (_apiAuth == null) {
      _registeredUsername = username.trim();
      _registeredPassword = password;
      _email = email.trim();
      _phoneNumber = phoneNumber ?? telephone;
      _hasAccount = true;
      _authMethod = AuthMethod.demo;
      _persistSessionToLocalStorage();
      notifyListeners();
      return null;
    }

    final err = await _apiAuth!.register(
      username: username.trim(),
      email: email.trim(),
      password: password,
      telephone: (phoneNumber ?? telephone ?? '').replaceAll(RegExp(r'\s+'), ''),
      role: role ?? 'ROLE_AUDITEUR',
      artistName: artistName,
    );

    if (err != null) return err;

    // Inscription réussie — on stocke les infos pour le login immédiat
    _registeredUsername = username.trim();
    _registeredPassword = password;
    _email = email.trim();
    _phoneNumber = phoneNumber ?? telephone;
    _hasAccount = true;
    _authMethod = AuthMethod.backend;
    _persistSessionToLocalStorage();
    notifyListeners();
    return null;
  }

  // ── Google OAuth ───────────────────────────────────────────────────────

  Future<String?> loginWithGoogle({
    required String role,
    String? accessToken,
    String? email,
    String? displayName,
    String? photoUrl,
  }) async {
    if (_apiAuth == null) {
      // Fallback démo
      _userId = 'google_user_${DateTime.now().millisecondsSinceEpoch}';
      _isLoggedIn = true;
      _authMethod = AuthMethod.google;
      _userName = displayName ?? 'Google User';
      _email = email;
      _avatarUrl = photoUrl;
      _hasAccount = true;
      _createdAt ??= DateTime.now();
      _updatedAt = DateTime.now();
      _persistSessionToLocalStorage();
      notifyListeners();
      return null;
    }

    if (accessToken == null || accessToken.isEmpty) {
      return 'Token Google manquant. Veuillez réessayer.';
    }

    try {
      final result = await _apiAuth!.oauth2Callback(
        accessToken: accessToken,
        provider: 'GOOGLE',
        role: role,
        email: email,
        displayName: displayName,
        photoUrl: photoUrl,
      );

      await _tokenVault?.setTokens(
        token: result.token,
        refreshToken: result.refreshToken,
        expiry: DateTime.now().add(const Duration(hours: 1)),
      );

      _userId = result.userId;
      _userName = result.username;
      _email = result.email;
      _avatarUrl = photoUrl;
      _isArtist = result.role == 'ROLE_ARTISTE';
      _isAdmin = result.role == 'ROLE_ADMIN';
      _isLoggedIn = true;
      _hasAccount = true;
      _authMethod = AuthMethod.google;
      _createdAt ??= DateTime.now();
      _updatedAt = DateTime.now();
      await _persistSessionToLocalStorage();
      notifyListeners();
      return null;
    } catch (e) {
      return 'Échec de la connexion Google: $e';
    }
  }

  // ── Forgot Password ────────────────────────────────────────────────────

  Future<String?> forgotPasswordBackend({required String email}) async {
    if (email.trim().isEmpty) return 'Veuillez saisir une adresse e-mail.';

    if (_apiAuth == null) {
      return 'Lien de réinitialisation envoyé (mode démo).';
    }

    try {
      final msg = await _apiAuth!.forgotPassword(email: email.trim());
      return msg ?? 'Lien de réinitialisation envoyé par email.';
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  // ── Abonnement ─────────────────────────────────────────────────────────

  void activateSubscription({
    SubscriptionPlan? plan,
    Duration? duration,
    String? offerCode,
    DateTime? expiryDate,
  }) {
    if (plan != null && duration != null) {
      _subscriptionPlan = plan;
      _subscriptionExpiryAt = DateTime.now().add(duration);
    } else if (expiryDate != null) {
      _subscriptionExpiryAt = expiryDate;
      _subscriptionPlan = SubscriptionPlan.monthly;
    }
    notifyListeners();
  }

  void activateSubscriptionFromBackend({
    required DateTime endDate,
    String? offerCode,
  }) {
    _subscriptionExpiryAt = endDate;
    _subscriptionPlan = SubscriptionPlan.monthly;
    notifyListeners();
  }

  // ── Phone & Local Verification Logic ───────────────────────────────────

  bool isValidTogoPhone(String value) {
    final normalized = value.replaceAll(RegExp(r'\s+'), '');
    return RegExp(r'^\+228\d{8}$').hasMatch(normalized);
  }

  String? requestPhoneOtp({required String phoneNumber}) {
    final normalized = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    if (!isValidTogoPhone(normalized)) {
      return 'Le numéro doit être au format +228XXXXXXXX.';
    }

    _phoneNumber = normalized;
    _pendingOtp = _generateOtp();
    _authMethod = AuthMethod.phone;
    _isPhoneVerified = false;
    notifyListeners();
    return null;
  }

  bool verifyPhoneOtp({required String otp}) {
    final normalized = otp.replaceAll(RegExp(r'\s+'), '');
    final success = _pendingOtp != null && normalized == _pendingOtp;
    if (success) {
      _isLoggedIn = true;
      _isPhoneVerified = true;
      _userName = _userName ?? 'Utilisateur mobile';
      _pendingOtp = null;
      notifyListeners();
    }
    return success;
  }

  // ── Login démo (conservé pour mode hors-ligne) ─────────────────────────

  void loginDemo() {
    login(name: 'Utilisateur Démo', subscribed: false);
  }

  void loginGuest() {
    _isLoggedIn = true;
    _isGuest = true;
    _isPhoneVerified = false;
    _userId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    _userName = 'Invité';
    _avatarUrl = defaultAvatarAsset;
    _avatarBytes = null;
    _subscriptionPlan = SubscriptionPlan.free;
    _authMethod = AuthMethod.demo;
    _phoneNumber = null;
    _pendingOtp = null;
    _userPassword = null;
    _registeredUsername = null;
    _registeredPassword = null;
    _subscriptionExpiryAt = null;
    _hasAccount = false;
    _guestPlayCount = 0;
    _createdAt ??= DateTime.now();
    _updatedAt = DateTime.now();
    notifyListeners();
  }

  void incrementGuestPlayCount() {
    if (_isGuest) {
      _guestPlayCount++;
      notifyListeners();
    }
  }

  void login({
    required String name,
    String? avatar,
    bool subscribed = false,
    SubscriptionPlan? subscriptionPlan,
  }) {
    _isLoggedIn = true;
    _isPhoneVerified = false;
    _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    _userName = name;
    _avatarUrl = avatar ?? defaultAvatarAsset;
    _avatarBytes = null;
    _subscriptionPlan =
        subscriptionPlan ??
        (subscribed ? SubscriptionPlan.monthly : SubscriptionPlan.free);
    _authMethod = AuthMethod.demo;
    _phoneNumber = null;
    _pendingOtp = null;
    _userPassword = null;
    _registeredUsername = null;
    _registeredPassword = null;
    _subscriptionExpiryAt =
        subscribed ? DateTime.now().add(const Duration(days: 30)) : null;
    _hasAccount = true;
    _createdAt ??= DateTime.now();
    _updatedAt = DateTime.now();
    notifyListeners();
  }

  void loginWithSocial({
    required AuthMethod method,
    required String name,
    String? avatar,
  }) {
    _isLoggedIn = true;
    _isPhoneVerified = false;
    _authMethod = method;
    _userName = name;
    _avatarUrl = avatar ?? defaultAvatarAsset;
    _subscriptionPlan = SubscriptionPlan.free;
    _subscriptionExpiryAt = null;
    _phoneNumber = null;
    _pendingOtp = null;
    _hasAccount = true;
    _createdAt ??= DateTime.now();
    _updatedAt = DateTime.now();
    _avatarBytes = null;
    notifyListeners();
  }

  // ── Logout ─────────────────────────────────────────────────────────────

  Future<void> logout() async {
    // Appeler le backend pour blacklister le token
    if (_apiAuth != null && _tokenVault?.hasToken == true) {
      try {
        await _apiAuth!.logout();
      } catch (e) {
        debugPrint('AuthProvider.logout API error: $e');
      }
    }

    // Nettoyer les tokens locaux
    await _tokenVault?.clear();

    // Réinitialiser l'état
    _isLoggedIn = false;
    _isPhoneVerified = false;
    _userId = null;
    _isArtist = false;
    _isAdmin = false;
    _userName = null;
    _firstName = null;
    _lastName = null;
    _email = null;
    _gender = null;
    _birthDate = null;
    _createdAt = null;
    _updatedAt = null;
    _avatarUrl = null;
    _phoneNumber = null;
    _pendingOtp = null;
    _userPassword = null;
    _registeredUsername = null;
    _registeredPassword = null;
    _hasAccount = false;
    _subscriptionPlan = SubscriptionPlan.free;
    _subscriptionExpiryAt = null;
    _authMethod = null;
    _avatarBytes = null;
    notifyListeners();
  }

  // ── Profile ────────────────────────────────────────────────────────────

  void updateProfileInfo({
    String? firstName,
    String? lastName,
    String? email,
    String? gender,
    DateTime? birthDate,
  }) {
    _firstName =
        firstName?.trim().isNotEmpty == true ? firstName!.trim() : _firstName;
    _lastName =
        lastName?.trim().isNotEmpty == true ? lastName!.trim() : _lastName;
    _email = email?.trim().isNotEmpty == true ? email!.trim() : _email;
    _gender = gender?.trim().isNotEmpty == true ? gender!.trim() : _gender;
    _birthDate = birthDate ?? _birthDate;
    _updatedAt = DateTime.now();
    notifyListeners();
  }

  void setSubscription(bool value) {
    if (value) {
      _subscriptionPlan = SubscriptionPlan.monthly;
      _subscriptionExpiryAt = DateTime.now().add(const Duration(days: 30));
    } else {
      _subscriptionPlan = SubscriptionPlan.free;
      _subscriptionExpiryAt ??= DateTime.now();
    }
    notifyListeners();
  }

  void setSubscriptionPlan(SubscriptionPlan plan) {
    _subscriptionPlan = plan;
    _subscriptionExpiryAt = DateTime.now().add(
      plan == SubscriptionPlan.weekly
          ? const Duration(days: 7)
          : const Duration(days: 30),
    );
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    if (_storage != null) {
      await _storage!.setThemeMode(mode.index);
    }
    notifyListeners();
  }

  void setAvatarBytes(Uint8List bytes) {
    _avatarBytes = bytes;
    _avatarUrl = null;
    _updatedAt = DateTime.now();
    notifyListeners();
  }

  void clearAvatar() {
    _avatarBytes = null;
    _avatarUrl = null;
    _updatedAt = DateTime.now();
    notifyListeners();
  }

  String _generateOtp() {
    final seed = DateTime.now()
        .millisecondsSinceEpoch
        .remainder(1000000)
        .toString()
        .padLeft(6, '0');
    return seed.substring(seed.length - 6);
  }
}

enum SubscriptionPlan { free, weekly, monthly }

enum AuthMethod { phone, google, facebook, demo, backend }
