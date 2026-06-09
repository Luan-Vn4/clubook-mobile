import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:booklub/domain/entities/users/auth_data.dart';
import 'package:booklub/domain/entities/users/user_creation_dto.dart';
import 'package:booklub/utils/http/http_error_dto.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class NetworkException implements Exception {

  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';

}

class AuthException implements Exception {

  final String message;

  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';

}

class AuthRepository {

  final _logger = Logger();

  final _secureStorage = const FlutterSecureStorage();

  static const _authDataKey = 'auth_data';

  final String _apiUrl;

  AuthRepository({
    required String apiUrl,
  }): _apiUrl = apiUrl;

  Future<AuthData> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/api/v1/auth/login'),
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      }
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return AuthData.fromJson(json);
    } else {
      throw Exception('Falha ao fazer login: ${response.statusCode}');
    }
  }

  Future<void> recoverPasswordViaEmail(String email) async {
    final response = await http.put(
      Uri.parse('$_apiUrl/api/v1/auth/recover-password'),
      body: jsonEncode({
        'email': email
      }),
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      }
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao recuperar e-mail: ${response.statusCode}');
    }
  }

  Future<void> register(UserCreationDTO dto) async {
    if (dto.image == null) {
      await _registerWithoutImage(dto);
      return;
    }

    await _registerWithMultipart(dto);
  }

  Future<void> _registerWithoutImage(UserCreationDTO dto) async {
    final uri = Uri.parse('$_apiUrl/api/v1/auth/register');

    try {
      final response = await http.post(
        uri,
        body: jsonEncode({
          'username': dto.username,
          'email': dto.email,
          'firstName': dto.firstName,
          'lastName': dto.lastName,
          'password': dto.password,
        }),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.toString(),
          HttpHeaders.acceptHeader: ContentType.json.mimeType,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        _logger.i('Usuário registrado com sucesso!');
        return;
      }

      throw AuthException(
        'Erro ao registrar usuário: ${_extractHttpErrorMessage(response.body)}',
      );
    } on SocketException {
      throw NetworkException('Sem conexão com a internet');
    } on HandshakeException {
      throw NetworkException('Falha de SSL/TLS. Verifique se a URL da API usa o protocolo correto (http/https)');
    } on TimeoutException {
      throw NetworkException('Tempo limite de conexão excedido');
    } on http.ClientException catch (e) {
      throw NetworkException('Erro de conexão: ${e.message}');
    }
  }

  Future<void> _registerWithMultipart(UserCreationDTO dto) async {
    final uri = Uri.parse('$_apiUrl/api/v1/auth/register');
    final request = http.MultipartRequest('POST', uri);
    request.headers[HttpHeaders.acceptHeader] = ContentType.json.mimeType;

    await dto.fillMultipartRequest(request);

    try {
      final response = await request.send().timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        _logger.i('Usuário registrado com sucesso!');
        return;
      }

      final responseBody = await response.stream.bytesToString();
      throw AuthException(
        'Erro ao registrar usuário: ${_extractHttpErrorMessage(responseBody)}',
      );
    } on SocketException {
      throw NetworkException('Sem conexão com a internet');
    } on HandshakeException {
      throw NetworkException('Falha de SSL/TLS. Verifique se a URL da API usa o protocolo correto (http/https)');
    } on TimeoutException {
      throw NetworkException('Tempo limite de conexão excedido');
    } on http.ClientException catch (e) {
      throw NetworkException('Erro de conexão: ${e.message}');
    }
  }

  String _extractHttpErrorMessage(String responseBody) {
    if (responseBody.trim().isEmpty) {
      return 'Resposta vazia do servidor';
    }

    try {
      final decodedBody = jsonDecode(responseBody);
      final httpErrorDto = HttpErrorDTO.fromJson(decodedBody);
      return httpErrorDto.message;
    } on FormatException {
      return responseBody;
    }
  }

  Future<void> saveAuthData(AuthData authData) async {
    final json = authData.toJson();
    await _secureStorage.write(
        key: _authDataKey,
        value: jsonEncode(json)
    );
  }

  Future<AuthData?> getAuthData() async {
    final jsonString = await _secureStorage.read(key: _authDataKey);
    if (jsonString == null) return null;

    final json = jsonDecode(jsonString);
    return AuthData.fromJson(json);
  }

  Future<void> clearAuthData() async {
    await _secureStorage.delete(key: _authDataKey);
  }

}
