import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class AuthApiService {
  AuthApiService() {
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

  Future<void> register({
    required String pseudo,
    required String mail,
    required String password,
  }) async {
    final csrfToken = await _getCsrfToken();

    await _dio.post(
      '/api/auth/register',
      data: {
        'pseudo': pseudo,
        'mail': mail,
        'password': password,
        'deviceInfo': 'Android emulator',
      },
      options: Options(headers: {'X-XSRF-TOKEN': csrfToken}),
    );
  }
}
