import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class DownloadMetadata {
  final String chansonId;
  final DateTime downloadedAt;
  final DateTime subscriptionExpiryAt;

  DownloadMetadata({
    required this.chansonId,
    required this.downloadedAt,
    required this.subscriptionExpiryAt,
  });

  bool get isInGracePeriod {
    final now = DateTime.now();
    return now.isAfter(subscriptionExpiryAt) &&
        now.isBefore(subscriptionExpiryAt.add(const Duration(days: 7)));
  }

  bool get isExpiredForDeletion {
    final now = DateTime.now();
    // Expire après 30 jours depuis le téléchargement
    final downloadExpiry = downloadedAt.add(const Duration(days: 30));
    if (now.isAfter(downloadExpiry)) return true;
    // Expire 7 jours après l'expiration de l'abonnement
    return now.isAfter(subscriptionExpiryAt.add(const Duration(days: 7)));
  }

  DownloadMetadata copyWith({
    String? chansonId,
    DateTime? downloadedAt,
    DateTime? subscriptionExpiryAt,
  }) {
    return DownloadMetadata(
      chansonId: chansonId ?? this.chansonId,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      subscriptionExpiryAt: subscriptionExpiryAt ?? this.subscriptionExpiryAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'chansonId': chansonId,
    'downloadedAt': downloadedAt.toIso8601String(),
    'subscriptionExpiryAt': subscriptionExpiryAt.toIso8601String(),
  };

  factory DownloadMetadata.fromJson(Map<String, dynamic> json) {
    return DownloadMetadata(
      chansonId: json['chansonId'] as String,
      downloadedAt: DateTime.parse(json['downloadedAt'] as String),
      subscriptionExpiryAt: DateTime.parse(
        json['subscriptionExpiryAt'] as String,
      ),
    );
  }
}

class DownloadManager {
  static const _downloadMetadataKey = 'download_metadata';
  static const _encryptionKeyKey = 'download_encryption_key';

  final FlutterSecureStorage _storage;
  Directory? _downloadsDirectory;

  DownloadManager({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<Directory> _getDownloadsDirectory() async {
    _downloadsDirectory ??= Directory(
      '${(await getApplicationSupportDirectory()).path}${Platform.pathSeparator}downloads',
    );
    if (!await _downloadsDirectory!.exists()) {
      await _downloadsDirectory!.create(recursive: true);
    }
    return _downloadsDirectory!;
  }

  String _fileNameFor(String chansonId) {
    return 'download_${Uri.encodeComponent(chansonId)}.dat';
  }

  Future<File> _downloadFile(String chansonId) async {
    final directory = await _getDownloadsDirectory();
    return File(
      '${directory.path}${Platform.pathSeparator}${_fileNameFor(chansonId)}',
    );
  }

  Future<Key> _encryptionKey() async {
    final cachedKey = await _storage.read(key: _encryptionKeyKey);
    if (cachedKey != null && cachedKey.isNotEmpty) {
      return Key(base64Decode(cachedKey));
    }

    final secret = List<int>.generate(32, (_) => _random.nextInt(256));
    final key = Key(Uint8List.fromList(secret));
    await _storage.write(key: _encryptionKeyKey, value: base64Encode(secret));
    return key;
  }

  static final _random = Random.secure();

  Future<Map<String, DownloadMetadata>> _readMetadata() async {
    final content = await _storage.read(key: _downloadMetadataKey);
    if (content == null || content.isEmpty) {
      return {};
    }

    final raw = jsonDecode(content) as Map<String, dynamic>;
    return raw.map((key, value) {
      return MapEntry(
        key,
        DownloadMetadata.fromJson(value as Map<String, dynamic>),
      );
    });
  }

  Future<void> _writeMetadata(Map<String, DownloadMetadata> metadata) async {
    final raw = metadata.map((key, item) => MapEntry(key, item.toJson()));
    await _storage.write(key: _downloadMetadataKey, value: jsonEncode(raw));
  }

  Future<List<int>> _encryptBytes(List<int> bytes) async {
    final key = await _encryptionKey();
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
    final encrypted = encrypter.encryptBytes(bytes, iv: iv);
    return iv.bytes + encrypted.bytes;
  }

  Future<List<int>> _decryptBytes(List<int> bytes) async {
    if (bytes.length < 16) {
      throw StateError('Fichier chiffré invalide.');
    }
    final key = await _encryptionKey();

    // Cast List<int> slices explicitly to Uint8List for the encrypt package API
    final iv = IV(Uint8List.fromList(bytes.sublist(0, 16)));
    final encryptedBytes = Uint8List.fromList(bytes.sublist(16));

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
    return encrypter.decryptBytes(Encrypted(encryptedBytes), iv: iv);
  }

  Future<void> saveDownloadedAudio(
    String chansonId,
    List<int> bytes, {
    required DateTime subscriptionExpiry,
  }) async {
    final file = await _downloadFile(chansonId);
    final encrypted = await _encryptBytes(bytes);
    await file.writeAsBytes(encrypted, flush: true);

    final metadata = DownloadMetadata(
      chansonId: chansonId,
      downloadedAt: DateTime.now(),
      subscriptionExpiryAt: subscriptionExpiry,
    );

    final records = await _readMetadata();
    records[chansonId] = metadata;
    await _writeMetadata(records);
  }

  Future<List<int>?> loadDownloadedAudio(String chansonId) async {
    final file = await _downloadFile(chansonId);
    if (!await file.exists()) {
      return null;
    }
    final encryptedBytes = await file.readAsBytes();
    return await _decryptBytes(encryptedBytes);
  }

  Future<bool> isDownloadAvailable(
    String chansonId,
    DateTime? currentSubscriptionExpiry,
  ) async {
    final metadata = (await _readMetadata())[chansonId];
    if (metadata == null) {
      return false;
    }

    final now = DateTime.now();
    final expiry = currentSubscriptionExpiry ?? metadata.subscriptionExpiryAt;

    if (expiry.isAfter(now)) {
      return true;
    }

    if (metadata.isExpiredForDeletion) {
      await deleteDownloadedAudio(chansonId);
      return false;
    }

    return false;
  }

  Future<List<String>> listDownloadedChansonIds() async {
    final metadata = await _readMetadata();
    return metadata.keys.toList();
  }

  Future<void> refreshDownloadAccess({
    DateTime? currentSubscriptionExpiry,
  }) async {
    final metadata = await _readMetadata();
    final updated = <String, DownloadMetadata>{};

    for (final entry in metadata.entries) {
      final data = entry.value;
      if (currentSubscriptionExpiry != null) {
        if (currentSubscriptionExpiry.isAfter(data.subscriptionExpiryAt)) {
          updated[entry.key] = data.copyWith(
            subscriptionExpiryAt: currentSubscriptionExpiry,
          );
        } else {
          updated[entry.key] = data;
        }
        continue;
      }

      if (data.isExpiredForDeletion) {
        await deleteDownloadedAudio(entry.key);
        continue;
      }
      updated[entry.key] = data;
    }

    await _writeMetadata(updated);
  }

  Future<void> deleteDownloadedAudio(String chansonId) async {
    final file = await _downloadFile(chansonId);
    if (await file.exists()) {
      await file.delete();
    }
    final metadata = await _readMetadata();
    metadata.remove(chansonId);
    await _writeMetadata(metadata);
  }

  // -----------------
  // Compatibility API
  // -----------------

  Future<CheckAccessResult> checkAccess(
    String chansonId, {
    DateTime? currentSubscriptionExpiry,
  }) async {
    final available = await isDownloadAvailable(
      chansonId,
      currentSubscriptionExpiry,
    );
    if (!available) return CheckAccessResult(canPlay: false);
    final bytes = await loadDownloadedAudio(chansonId);
    return CheckAccessResult(canPlay: bytes != null, decryptedBytes: bytes);
  }

  Future<String?> getDecryptedTempPath(
    String chansonId, {
    DateTime? currentSubscriptionExpiry,
  }) async {
    final bytes = await loadDownloadedAudio(chansonId);
    if (bytes == null) return null;
    final tmpDir = await getTemporaryDirectory();
    final file = File(
      '${tmpDir.path}${Platform.pathSeparator}${_fileNameFor(chansonId)}.wav',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<void> save(
    String chansonId,
    List<int> bytes, {
    required DateTime subscriptionExpiry,
  }) async {
    await saveDownloadedAudio(
      chansonId,
      bytes,
      subscriptionExpiry: subscriptionExpiry,
    );
  }

  Future<void> refreshAccess(DateTime currentSubscriptionExpiry) async {
    await refreshDownloadAccess(
      currentSubscriptionExpiry: currentSubscriptionExpiry,
    );
  }

  Future<void> purgeExpired() async {
    await refreshDownloadAccess();
  }
}

/// Compatibility result for older callers of DownloadManager.checkAccess
class CheckAccessResult {
  final bool canPlay;
  final List<int>? decryptedBytes;
  CheckAccessResult({required this.canPlay, this.decryptedBytes});
}
