import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LocalUserStorage
// Persiste toutes les données utilisateur localement via shared_preferences.
// Les données sensibles (token JWT) restent dans flutter_secure_storage
// (géré par SecureTokenStorage / TokenVault).
// ─────────────────────────────────────────────────────────────────────────────
class LocalUserStorage {
  static const _kIsLoggedIn         = 'u_is_logged_in';
  static const _kUserId             = 'u_id';
  static const _kUserName           = 'u_username';
  static const _kFirstName          = 'u_first_name';
  static const _kLastName           = 'u_last_name';
  static const _kEmail              = 'u_email';
  static const _kPhoneNumber        = 'u_phone';
  static const _kGender             = 'u_gender';
  static const _kBirthDate          = 'u_birth_date';
  static const _kAvatarUrl          = 'u_avatar_url';
  static const _kAvatarBytes        = 'u_avatar_bytes';   // base64
  static const _kRole               = 'u_role';
  static const _kAuthMethod         = 'u_auth_method';
  static const _kSubscriptionPlan   = 'u_sub_plan';
  static const _kSubscriptionExpiry = 'u_sub_expiry';
  static const _kThemeMode          = 'u_theme_mode';
  static const _kCreatedAt          = 'u_created_at';
  static const _kUpdatedAt          = 'u_updated_at';
  static const _kIsPhoneVerified    = 'u_phone_verified';

  final SharedPreferences _prefs;
  LocalUserStorage._(this._prefs);

  static Future<LocalUserStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalUserStorage._(prefs);
  }

  // ── Session ────────────────────────────────────────────────────────────────
  Future<void> setLoggedIn(bool v)         async => _prefs.setBool(_kIsLoggedIn, v);
  bool         get isLoggedIn              => _prefs.getBool(_kIsLoggedIn) ?? false;

  Future<void> setUserId(String? v)        async => v != null ? _prefs.setString(_kUserId, v) : _prefs.remove(_kUserId);
  String?      get userId                  => _prefs.getString(_kUserId);

  Future<void> setRole(String? v)          async => v != null ? _prefs.setString(_kRole, v) : _prefs.remove(_kRole);
  String?      get role                    => _prefs.getString(_kRole);

  Future<void> setAuthMethod(String? v)    async => v != null ? _prefs.setString(_kAuthMethod, v) : _prefs.remove(_kAuthMethod);
  String?      get authMethod              => _prefs.getString(_kAuthMethod);

  // ── Profil ─────────────────────────────────────────────────────────────────
  Future<void> setUserName(String? v)      async => v != null ? _prefs.setString(_kUserName, v) : _prefs.remove(_kUserName);
  String?      get userName                => _prefs.getString(_kUserName);

  Future<void> setFirstName(String? v)     async => v != null ? _prefs.setString(_kFirstName, v) : _prefs.remove(_kFirstName);
  String?      get firstName               => _prefs.getString(_kFirstName);

  Future<void> setLastName(String? v)      async => v != null ? _prefs.setString(_kLastName, v) : _prefs.remove(_kLastName);
  String?      get lastName                => _prefs.getString(_kLastName);

  Future<void> setEmail(String? v)         async => v != null ? _prefs.setString(_kEmail, v) : _prefs.remove(_kEmail);
  String?      get email                   => _prefs.getString(_kEmail);

  Future<void> setPhoneNumber(String? v)   async => v != null ? _prefs.setString(_kPhoneNumber, v) : _prefs.remove(_kPhoneNumber);
  String?      get phoneNumber             => _prefs.getString(_kPhoneNumber);

  Future<void> setGender(String? v)        async => v != null ? _prefs.setString(_kGender, v) : _prefs.remove(_kGender);
  String?      get gender                  => _prefs.getString(_kGender);

  Future<void> setBirthDate(DateTime? v)   async => v != null ? _prefs.setString(_kBirthDate, v.toIso8601String()) : _prefs.remove(_kBirthDate);
  DateTime?    get birthDate               { final s = _prefs.getString(_kBirthDate); return s != null ? DateTime.tryParse(s) : null; }

  Future<void> setAvatarUrl(String? v)     async => v != null ? _prefs.setString(_kAvatarUrl, v) : _prefs.remove(_kAvatarUrl);
  String?      get avatarUrl               => _prefs.getString(_kAvatarUrl);

  Future<void> setAvatarBytes(Uint8List? v) async {
    if (v != null) {
      await _prefs.setString(_kAvatarBytes, base64Encode(v));
    } else {
      await _prefs.remove(_kAvatarBytes);
    }
  }
  Uint8List?   get avatarBytes {
    final s = _prefs.getString(_kAvatarBytes);
    return s != null ? base64Decode(s) : null;
  }

  Future<void> setIsPhoneVerified(bool v)  async => _prefs.setBool(_kIsPhoneVerified, v);
  bool         get isPhoneVerified         => _prefs.getBool(_kIsPhoneVerified) ?? false;

  // ── Abonnement ─────────────────────────────────────────────────────────────
  Future<void> setSubscriptionPlan(String v)    async => _prefs.setString(_kSubscriptionPlan, v);
  String       get subscriptionPlan              => _prefs.getString(_kSubscriptionPlan) ?? 'free';

  Future<void> setSubscriptionExpiry(DateTime? v) async =>
      v != null ? _prefs.setString(_kSubscriptionExpiry, v.toIso8601String()) : _prefs.remove(_kSubscriptionExpiry);
  DateTime?    get subscriptionExpiry {
    final s = _prefs.getString(_kSubscriptionExpiry);
    return s != null ? DateTime.tryParse(s) : null;
  }

  // ── Préférences ────────────────────────────────────────────────────────────
  Future<void> setThemeMode(int v)         async => _prefs.setInt(_kThemeMode, v);
  int          get themeMode               => _prefs.getInt(_kThemeMode) ?? 0; // 0=system,1=light,2=dark

  // ── Timestamps ─────────────────────────────────────────────────────────────
  Future<void> setCreatedAt(DateTime? v)   async => v != null ? _prefs.setString(_kCreatedAt, v.toIso8601String()) : _prefs.remove(_kCreatedAt);
  DateTime?    get createdAt               { final s = _prefs.getString(_kCreatedAt); return s != null ? DateTime.tryParse(s) : null; }

  Future<void> setUpdatedAt(DateTime? v)   async => v != null ? _prefs.setString(_kUpdatedAt, v.toIso8601String()) : _prefs.remove(_kUpdatedAt);
  DateTime?    get updatedAt               { final s = _prefs.getString(_kUpdatedAt); return s != null ? DateTime.tryParse(s) : null; }

  // ── Sauvegarde complète de session ─────────────────────────────────────────
  Future<void> saveSession({
    required bool   isLoggedIn,
    required String userId,
    required String userName,
    String?         firstName,
    String?         lastName,
    String?         email,
    String?         phone,
    String?         role,
    String?         authMethod,
    String?         avatarUrl,
    String?         subscriptionPlan,
    DateTime?       subscriptionExpiry,
    bool            isPhoneVerified = false,
  }) async {
    await Future.wait([
      setLoggedIn(isLoggedIn),
      setUserId(userId),
      setUserName(userName),
      setFirstName(firstName),
      setLastName(lastName),
      setEmail(email),
      setPhoneNumber(phone),
      setRole(role),
      setAuthMethod(authMethod),
      setAvatarUrl(avatarUrl),
      setSubscriptionPlan(subscriptionPlan ?? 'free'),
      setSubscriptionExpiry(subscriptionExpiry),
      setIsPhoneVerified(isPhoneVerified),
      setCreatedAt(DateTime.now()),
      setUpdatedAt(DateTime.now()),
    ]);
  }

  // ── Effacement complet (logout) ────────────────────────────────────────────
  Future<void> clearSession() async {
    final themeMode = _prefs.getInt(_kThemeMode); // conserver le thème
    final keys = [
      _kIsLoggedIn, _kUserId, _kUserName, _kFirstName, _kLastName,
      _kEmail, _kPhoneNumber, _kGender, _kBirthDate, _kAvatarUrl,
      _kAvatarBytes, _kRole, _kAuthMethod, _kSubscriptionPlan,
      _kSubscriptionExpiry, _kCreatedAt, _kUpdatedAt, _kIsPhoneVerified,
    ];
    for (final k in keys) { await _prefs.remove(k); }
    if (themeMode != null) await _prefs.setInt(_kThemeMode, themeMode);
  }
}
