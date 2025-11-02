import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException: $message (Status Code: $statusCode)';
    }
    return 'ApiException: $message';
  }
}

class ApiService {
  static const String _baseUrl = kDebugMode
      ? 'http://10.0.2.2:8080/api/admin' // Đây là đường dẫn API admin của bạn (ví dụ)
      : 'https://your-production-api.com/api/admin'; // URL production của bạn

  Future<Map<String, dynamic>> _sendRequest(String method,
      String path, {
        Map<String, dynamic>? data,
        Map<String, String>? queryParams,
        String? token,
      }) async {
    Uri uri;
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = Uri.parse('$_baseUrl$path').replace(queryParameters: queryParams);
    } else {
      uri = Uri.parse('$_baseUrl$path');
    }

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    http.Response response;

    try {
      if (method == 'GET') {
        response = await http.get(uri, headers: headers);
      } else if (method == 'POST') {
        response =
        await http.post(uri, headers: headers, body: jsonEncode(data));
      } else if (method == 'PUT') {
        response =
        await http.put(uri, headers: headers, body: jsonEncode(data));
      } else if (method == 'DELETE') {
        response =
        await http.delete(uri, headers: headers, body: jsonEncode(data));
      } else {
        throw ArgumentError('Phương thức HTTP không hợp lệ: $method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        }
        return {'message': 'Success, but no content'};
      } else {
        String errorMessage = 'Có lỗi xảy ra.';
        if (response.body.isNotEmpty) {
          try {
            final errorBody = jsonDecode(response.body);
            if (errorBody is Map<String, dynamic> &&
                errorBody.containsKey('message')) {
              errorMessage = errorBody['message'];
            } else {
              errorMessage = response.body;
            }
          } catch (e) {
            errorMessage = response.body;
          }
        }
        throw ApiException(errorMessage, statusCode: response.statusCode);
      }
    } on http.ClientException catch (e) {
      throw ApiException('Lỗi mạng: ${e.message}');
    } catch (e) {
      throw ApiException('Lỗi không xác định: $e');
    }
  }

  Future<Map<String, dynamic>> get(String path, {
    Map<String, String>? queryParams,
    String? token,
  }) {
    return _sendRequest('GET', path, queryParams: queryParams, token: token);
  }

  Future<Map<String, dynamic>> post(String path, {
    Map<String, dynamic>? data,
    String? token,
  }) {
    return _sendRequest('POST', path, data: data, token: token);
  }

  Future<Map<String, dynamic>> put(String path, {
    Map<String, dynamic>? data,
    String? token,
  }) {
    return _sendRequest('PUT', path, data: data, token: token);
  }

  Future<Map<String, dynamic>> delete(String path, {
    Map<String, dynamic>? data,
    String? token,
  }) {
    return _sendRequest('DELETE', path, data: data, token: token);
  }
}