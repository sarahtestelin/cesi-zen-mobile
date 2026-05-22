import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import '../models/diagnostic_question.dart';
import '../models/diagnostic_result.dart';
import 'token_storage_service.dart';

class DiagnosticApiService {
  DiagnosticApiService() {
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

  Future<List<DiagnosticQuestion>> getQuestions() async {
    final response = await _dio.get('/api/v1/diagnostics/questions');
    final data = response.data;

    if (data is List) {
      return data
          .map(
            (item) => DiagnosticQuestion.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    return [];
  }

  Future<DiagnosticResult> submitDiagnostic({
    required List<String> questionIds,
  }) async {
    final csrfToken = await _getCsrfToken();
    final accessToken = await _tokenStorageService.getAccessToken();

    final isConnected = accessToken != null && accessToken.isNotEmpty;

    final response = await _dio.post(
      isConnected
          ? '/api/v1/diagnostics/submit'
          : '/api/v1/diagnostics/anonymous',
      data: {'questionIds': questionIds},
      options: Options(
        headers: {
          'X-XSRF-TOKEN': csrfToken,
          if (isConnected) 'Authorization': 'Bearer $accessToken',
        },
      ),
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return DiagnosticResult.fromJson(data);
    }

    throw Exception('Résultat du diagnostic introuvable');
  }

  Future<List<DiagnosticResult>> getMyResults() async {
    final accessToken = await _tokenStorageService.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return [];
    }

    final response = await _dio.get(
      '/api/v1/diagnostics/results/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    final data = response.data;

    if (data is List) {
      return data
          .map(
            (item) => DiagnosticResult.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    return [];
  }
}
