import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import '../models/app_user.dart';
import 'token_storage_service.dart';

class UserApiService {
  UserApiService() {
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();

        client.badCertificateCallback = (cert, host, port) {
          return host == '10.0.2.2';
        };

        return client;
      },
    );

    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  final CookieJar _cookieJar = CookieJar();
  final TokenStorageService _tokenStorageService = TokenStorageService();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://10.0.2.2:8080',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<String> _getCsrfToken() async {
    final response = await _dio.get('/api/csrf');
    final data = response.data;

    if (data is Map && data['token'] != null) {
      return data['token'].toString();
    }

    throw Exception('Token CSRF introuvable');
  }

  Future<String> _getAccessTokenOrThrow() async {
    final token = await _tokenStorageService.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Utilisateur non connecté');
    }

    return token;
  }

  Future<AppUser> getCurrentUser() async {
    final accessToken = await _getAccessTokenOrThrow();

    final response = await _dio.get(
      '/api/users/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return AppUser.fromJson(data);
    }

    throw Exception('Profil utilisateur introuvable');
  }

  Future<AppUser> updateCurrentUser({
    required String mail,
    required String pseudo,
  }) async {
    final accessToken = await _getAccessTokenOrThrow();
    final csrfToken = await _getCsrfToken();

    final response = await _dio.put(
      '/api/users/me',
      data: {'mail': mail, 'pseudo': pseudo},
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'X-XSRF-TOKEN': csrfToken,
        },
      ),
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return AppUser.fromJson(data);
    }

    throw Exception('Impossible de modifier le profil');
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final accessToken = await _getAccessTokenOrThrow();
    final csrfToken = await _getCsrfToken();

    await _dio.post(
      '/api/password/change',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'X-XSRF-TOKEN': csrfToken,
        },
      ),
    );
  }

  Future<Map<String, dynamic>> exportMyData() async {
    final accessToken = await _getAccessTokenOrThrow();

    final response = await _dio.get(
      '/api/users/me/export',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return data;
    }

    throw Exception('Export des données introuvable');
  }

  Future<void> deleteMyAccount() async {
    final accessToken = await _getAccessTokenOrThrow();
    final csrfToken = await _getCsrfToken();

    await _dio.delete(
      '/api/users/me',
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'X-XSRF-TOKEN': csrfToken,
        },
      ),
    );
  }
}
