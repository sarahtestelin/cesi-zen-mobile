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

  Future<Map<String, dynamic>?> getTokenPayload() async {
    final token = await getAccessToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final parts = token.split('.');

      if (parts.length != 3) {
        return null;
      }

      final normalizedPayload = base64Url.normalize(parts[1]);
      final decodedPayload = utf8.decode(base64Url.decode(normalizedPayload));
      final payload = jsonDecode(decodedPayload);

      if (payload is Map<String, dynamic>) {
        return payload;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> getPseudoFromToken() async {
    final payload = await getTokenPayload();
    return payload?['pseudo']?.toString();
  }

  Future<String?> getMailFromToken() async {
    final payload = await getTokenPayload();

    return payload?['mail']?.toString() ?? payload?['sub']?.toString();
  }

  Future<String?> getRoleFromToken() async {
    final payload = await getTokenPayload();
    return payload?['role']?.toString();
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
  }
}
