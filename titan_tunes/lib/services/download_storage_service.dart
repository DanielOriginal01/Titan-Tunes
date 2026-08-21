import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DownloadRecord — métadonnées d'un téléchargement stockées localement
// ─────────────────────────────────────────────────────────────────────────────
class DownloadRecord {
  final String   chansonId;
  final String   titre;
  final String   artisteName;
  final String   coverUrl;
  final int      sizeBytes;
  final DateTime downloadedAt;
  final DateTime subscriptionExpiryAt;
  final int      qualityKbps;

  const DownloadRecord({
    required this.chansonId,
    required this.titre,
    required this.artisteName,
    required this.coverUrl,
    required this.sizeBytes,
    required this.downloadedAt,
    required this.subscriptionExpiryAt,
    required this.qualityKbps,
  });

  bool get isExpired {
    final now = DateTime.now();
    // Expire après 30 jours depuis le téléchargement
    final downloadExpiry = downloadedAt.add(const Duration(days: 30));
    if (now.isAfter(downloadExpiry)) return true;
    // Expire 7 jours après l'expiration de l'abonnement
    return now.isAfter(subscriptionExpiryAt.add(const Duration(days: 7)));
  }

  bool get isInGracePeriod {
    final now = DateTime.now();
    return now.isAfter(subscriptionExpiryAt) &&
        now.isBefore(subscriptionExpiryAt.add(const Duration(days: 7)));
  }

  bool get hasAccess => !isExpired;

  int get graceDaysRemaining {
    final end = subscriptionExpiryAt.add(const Duration(days: 7));
    final diff = end.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  int get daysRemaining {
    final downloadExpiry = downloadedAt.add(const Duration(days: 30));
    final diff = downloadExpiry.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  String get sizeFormatted {
    if (sizeBytes < 1024) return '$sizeBytes o';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} Ko';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} Mo';
  }

  Map<String, dynamic> toJson() => {
    'chansonId':            chansonId,
    'titre':                titre,
    'artisteName':          artisteName,
    'coverUrl':             coverUrl,
    'sizeBytes':            sizeBytes,
    'downloadedAt':         downloadedAt.toIso8601String(),
    'subscriptionExpiryAt': subscriptionExpiryAt.toIso8601String(),
    'qualityKbps':          qualityKbps,
  };

  factory DownloadRecord.fromJson(Map<String, dynamic> j) => DownloadRecord(
    chansonId:            j['chansonId']            as String,
    titre:                j['titre']                as String? ?? '',
    artisteName:          j['artisteName']          as String? ?? '',
    coverUrl:             j['coverUrl']             as String? ?? '',
    sizeBytes:            j['sizeBytes']            as int? ?? 0,
    downloadedAt:         DateTime.parse(j['downloadedAt'] as String),
    subscriptionExpiryAt: DateTime.parse(j['subscriptionExpiryAt'] as String),
    qualityKbps:          j['qualityKbps']          as int? ?? 128,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// DownloadStorageService
// Catalogue des téléchargements dans shared_preferences +
// accès au répertoire réel de fichiers chiffrés.
// ─────────────────────────────────────────────────────────────────────────────
class DownloadStorageService extends ChangeNotifier {
  static const _kCatalogKey = 'tt_dl_catalog_v1';
  static const _dirName     = '.tt_protected';

  final SharedPreferences _prefs;
  List<DownloadRecord> _records = [];

  DownloadStorageService._(this._prefs) {
    _loadFromPrefs();
  }

  static Future<DownloadStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return DownloadStorageService._(prefs);
  }

  // ── Lecture ────────────────────────────────────────────────────────────────
  List<DownloadRecord> get all          => List.unmodifiable(_records);
  List<DownloadRecord> get available    => _records.where((r) => r.hasAccess).toList();
  List<DownloadRecord> get expired      => _records.where((r) => r.isExpired).toList();
  List<DownloadRecord> get inGrace      => _records.where((r) => r.isInGracePeriod).toList();

  int get totalSizeBytes => _records.fold(0, (s, r) => s + r.sizeBytes);
  String get totalSizeFormatted {
    final b = totalSizeBytes;
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)} Ko';
    return '${(b / (1024 * 1024)).toStringAsFixed(1)} Mo';
  }

  bool isDownloaded(String chansonId) =>
      _records.any((r) => r.chansonId == chansonId && r.hasAccess);

  DownloadRecord? getRecord(String chansonId) =>
      _records.where((r) => r.chansonId == chansonId).firstOrNull;

  // ── Écriture ───────────────────────────────────────────────────────────────
  Future<void> addOrUpdate(DownloadRecord record) async {
    _records.removeWhere((r) => r.chansonId == record.chansonId);
    _records.insert(0, record);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> remove(String chansonId) async {
    _records.removeWhere((r) => r.chansonId == chansonId);
    await _saveToPrefs();
    await _deleteFile(chansonId);
    notifyListeners();
  }

  /// Purge les enregistrements expirés et efface les fichiers.
  Future<int> purgeExpired() async {
    final expired = _records.where((r) => r.isExpired).toList();
    for (final r in expired) {
      await _deleteFile(r.chansonId);
    }
    _records.removeWhere((r) => r.isExpired);
    await _saveToPrefs();
    notifyListeners();
    return expired.length;
  }

  /// Met à jour la date d'expiry pour tous les enregistrements (réabonnement).
  Future<void> refreshExpiry(DateTime newExpiry) async {
    _records = _records.map((r) {
      return r.subscriptionExpiryAt.isBefore(newExpiry)
          ? DownloadRecord(
              chansonId:            r.chansonId,
              titre:                r.titre,
              artisteName:          r.artisteName,
              coverUrl:             r.coverUrl,
              sizeBytes:            r.sizeBytes,
              downloadedAt:         r.downloadedAt,
              subscriptionExpiryAt: newExpiry,
              qualityKbps:          r.qualityKbps,
            )
          : r;
    }).toList();
    await _saveToPrefs();
    notifyListeners();
  }

  // ── Fichiers ───────────────────────────────────────────────────────────────
  Future<Directory> _getDir() async {
    if (kIsWeb) return Directory('');
    final base = await getApplicationSupportDirectory();
    final dir  = Directory('${base.path}${Platform.pathSeparator}$_dirName');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<void> _deleteFile(String chansonId) async {
    if (kIsWeb) return;
    try {
      // Supprime le fichier chiffré créé par DownloadManager (dossier downloads/)
      final dlDir = await _getDownloadsDir();
      final dlFile = File(
        '${dlDir.path}${Platform.pathSeparator}download_${Uri.encodeComponent(chansonId)}.dat',
      );
      if (await dlFile.exists()) await dlFile.delete();
    } catch (e) {
      debugPrint('DownloadStorageService._deleteFile error: $e');
    }
  }

  Future<Directory> _getDownloadsDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}${Platform.pathSeparator}downloads');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Calcule la taille réelle sur disque (tous les fichiers .ttenc).
  Future<int> computeDiskUsageBytes() async {
    if (kIsWeb) return 0;
    try {
      final dir   = await _getDir();
      int   total = 0;
      await for (final entity in dir.list()) {
        if (entity is File && entity.path.endsWith('.ttenc')) {
          total += await entity.length();
        }
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  // ── Persistance ────────────────────────────────────────────────────────────
  void _loadFromPrefs() {
    final raw = _prefs.getString(_kCatalogKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _records = list
          .map((e) => DownloadRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('DownloadStorageService._loadFromPrefs error: $e');
      _records = [];
    }
  }

  Future<void> _saveToPrefs() async {
    final raw = jsonEncode(_records.map((r) => r.toJson()).toList());
    await _prefs.setString(_kCatalogKey, raw);
  }
}
