import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  static const String _accessTokenKey = 'access_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> getPseudoFromToken() async {
    final token = await getAccessToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final parts = token.split('.');

      if (parts.length != 3) {
        return null;
      }

      final payload = parts[1];
      final normalizedPayload = base64Url.normalize(payload);
      final decodedPayload = utf8.decode(base64Url.decode(normalizedPayload));
      final payloadMap = jsonDecode(decodedPayload);

      if (payloadMap is Map && payloadMap['pseudo'] != null) {
        return payloadMap['pseudo'].toString();
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
  }
}
