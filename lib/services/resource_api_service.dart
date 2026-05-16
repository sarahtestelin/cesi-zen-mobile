import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../models/cesi_resource.dart';

class ResourceApiService {
  ResourceApiService() {
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();

        client.badCertificateCallback = (cert, host, port) {
          return host == '10.0.2.2';
        };

        return client;
      },
    );
  }

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://10.0.2.2:8080',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<List<CesiResource>> getResources() async {
    final response = await _dio.get('/api/v1/ressources');

    final data = response.data;

    if (data is List) {
      return data
          .map((item) => CesiResource.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }
}
