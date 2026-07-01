import 'dart:convert';
import 'dart:io';

import 'package:booklub/domain/club_membership/entities/club_pending_entry.dart';
import 'package:booklub/domain/entities/clubs/club.dart';
import 'package:booklub/domain/entities/clubs/club_creation_dto.dart';
import 'package:booklub/domain/entities/users/auth_data.dart';
import 'package:booklub/domain/entities/users/auth_token.dart';
import 'package:booklub/domain/entities/users/user.dart';
import 'package:booklub/infra/auth/auth_repository.dart';
import 'package:booklub/utils/http/http_error_dto.dart';
import 'package:booklub/utils/logger/app_logger.dart';
import 'package:booklub/utils/pagination/page.dart';
import 'package:booklub/utils/pagination/paginator.dart';
import 'package:http/http.dart' as http;

class CreateClubException implements Exception {

  final String message;

  CreateClubException(this.message);

  @override
  String toString() => 'CreateClubException: $message';

}

class ClubRepository {

  final _logger = AppLogger.create();

  final String _apiUrl;

  final AuthRepository authRepository;

  ClubRepository({required String apiUrl, required this.authRepository})
    : _apiUrl = apiUrl;

  Future<AuthData> get _authData async {
    final authData = await authRepository.getAuthData();

    if (authData == null) {
      throw Exception('O usuário não está autenticado');
    }

    return authData;
  }

  Future<AuthToken> get _authToken async => (await _authData).token;

  Future<void> createClub(ClubCreationDTO club) async {
    final authData = await authRepository.getAuthData();

    if (authData == null) {
      throw Exception('O usuário não está autenticado');
    }

    final accessToken = authData.token.accessToken;

    final url = Uri.parse('$_apiUrl/api/v1/clubs');
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $accessToken';

    club.fillMultipartRequest(request);

    final response = await request.send();

    if (response.statusCode != 200) {
      final responseBody = jsonDecode(await response.stream.bytesToString());

      final httpErrorDto = HttpErrorDTO.fromJson(responseBody);

      throw CreateClubException(
        'Erro ao registrar usuário: ${httpErrorDto.message}',
      );
    }

    _logger.i('Club registrado com sucesso!');
  }

  Future<Paginator<Club>> findClubs(int pageSize) async {
    final authToken = await _authToken;

    return Paginator.create(pageSize, (page, size) async {
      final uri = Uri.parse(
        '$_apiUrl/api/v1/clubs',
      ).replace(
          queryParameters: {
            'page': page,
            'size': size,
          }
      );

      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.toString(),
          HttpHeaders.authorizationHeader: authToken.toString(),
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao buscar clubs');
      }

      return Page<Club>.fromJson(
        jsonDecode(response.body),
        (json) => Club.fromJson(json as Map<String, dynamic>),
      );
    });
  }

  Future<Club> findClubById(String clubId) async {
    final authToken = await _authToken;

    final uri = Uri.parse('$_apiUrl/api/v1/clubs/$clubId');

    final response = await http.get(
      uri,
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: authToken.toString(),
      }
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar club com ID $clubId');
    }

    return Club.fromJson(jsonDecode(response.body));
  }

  Future<Paginator<Club>> findClubsByUserId(int pageSize, String userId) async {
    final authToken = await _authToken;

    return Paginator.create(pageSize, (page, size) async {
      final uri = Uri.parse(
          '$_apiUrl/api/v1/users/$userId/clubs/participating'
      ).replace(
        queryParameters: {
          'page': page.toString(),
          'size': size.toString(),
        }
      );

      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.toString(),
          HttpHeaders.authorizationHeader: authToken.toString(),
        }
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao buscar clubs do usuário com ID $userId');
      }

      final result = Page<Club>.fromJson(
        jsonDecode(response.body),
        (json) => Club.fromJson(json as Map<String, dynamic>),
      );

      return result;
    });
  }

  Future<Paginator<Club>> findClubsByOwnerId(int pageSize, String ownerId) async {
    final authToken = await _authToken;

    return Paginator.create(pageSize, (page, size) async {
      final uri = Uri.parse(
          '$_apiUrl/api/v1/users/$ownerId/clubs/owned'
      ).replace(
          queryParameters: {
            'page': page.toString(),
            'size': size.toString(),
          }
      );

      final response = await http.get(
          uri,
          headers: {
            HttpHeaders.contentTypeHeader: ContentType.json.toString(),
            HttpHeaders.authorizationHeader: authToken.toString(),
          }
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao buscar clubs com dono com ID $ownerId');
      }

      final result = Page<Club>.fromJson(
        jsonDecode(response.body),
            (json) => Club.fromJson(json as Map<String, dynamic>),
      );

      return result;
    });
  }

  Future<Paginator<Club>> searchClubByName(String name, int pageSize) async {
    final authToken = await _authToken;

    return Paginator.create(pageSize, (page, size) async {
      final uri = Uri.parse(
        '$_apiUrl/api/v1/clubs',
      ).replace(
          queryParameters: {
            'name': name,
            'page': page.toString(),
            'size': size.toString(),
          }
      );

      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.toString(),
          HttpHeaders.authorizationHeader: authToken.toString(),
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao buscar clubs com nome $name');
      }

      return Page<Club>.fromJson(
        jsonDecode(response.body),
            (json) => Club.fromJson(json as Map<String, dynamic>),
      );
    });
  }

  Future<Paginator<User>> findClubMembers(int pageSize, String clubId) async {
    final authToken = await _authToken;

    return Paginator.create(pageSize, (page, size) async {
      final uri = Uri.parse(
        '$_apiUrl/api/v1/clubs/$clubId/members'
      ).replace(
        queryParameters: {
          'page': page.toString(),
          'size': size.toString(),
        }
      );

      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.toString(),
          HttpHeaders.authorizationHeader: authToken.toString(),
        }
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao buscar membros do clube com ID $clubId');
      }

      return Page<User>.fromJson(
        jsonDecode(response.body),
        (json) => User.fromJson(json as Map<String, dynamic>),
      );
    });
  }

  Future<bool> isMember(String clubId, String userId) async {
    final authToken = await _authToken;

    final uri = Uri.parse(
      '$_apiUrl/api/v1/clubs/$clubId/members/is-member/$userId',
    );

    final response = await http.get(
      uri,
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: authToken.toString(),
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao verificar associação ao clube');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['result'] == true;
  }

  Future<bool> hasPendingRequest(String clubId, String userId) async {
    final authToken = await _authToken;

    final uri = Uri.parse(
      '$_apiUrl/api/v1/users/$userId/requests/clubs/$clubId/requests',
    );

    final response = await http.get(
      uri,
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: authToken.toString(),
      },
    );

    return response.statusCode == 200;
  }

  Future<void> sendJoinRequest(String clubId, String userId) async {
    final authToken = await _authToken;

    final uri = Uri.parse(
      '$_apiUrl/api/v1/users/$userId/requests/requests/$clubId',
    );

    final response = await http.post(
      uri,
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: authToken.toString(),
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erro ao solicitar entrada no clube');
    }
  }

  Future<void> cancelJoinRequest(String clubId, String userId) async {
    final authToken = await _authToken;

    final uri = Uri.parse(
      '$_apiUrl/api/v1/users/$userId/requests/requests/$clubId/cancel',
    );

    final response = await http.delete(
      uri,
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: authToken.toString(),
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erro ao cancelar solicitação');
    }
  }

  Future<void> leaveClub(String clubId, String userId) async {
    final authToken = await _authToken;

    final uri = Uri.parse('$_apiUrl/api/v1/clubs/$clubId/members/$userId');

    final response = await http.delete(
      uri,
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: authToken.toString(),
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erro ao sair do clube');
    }
  }

  Future<Paginator<ClubPendingEntry>> findClubRequests(
    String clubId,
    int pageSize,
  ) async {
    final authToken = await _authToken;

    return Paginator.create(pageSize, (page, size) async {
      final uri = Uri.parse('$_apiUrl/api/v1/clubs/$clubId/requests').replace(
        queryParameters: {'page': page.toString(), 'size': size.toString()},
      );

      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.toString(),
          HttpHeaders.authorizationHeader: authToken.toString(),
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao buscar solicitações do clube');
      }

      return Page<ClubPendingEntry>.fromJson(
        jsonDecode(response.body),
        (json) => ClubPendingEntry.fromJson(json as Map<String, dynamic>),
      );
    });
  }

  Future<void> acceptRequest(String clubId, String userId) async {
    final authToken = await _authToken;

    final uri = Uri.parse(
      '$_apiUrl/api/v1/clubs/$clubId/requests/$userId/accept',
    );

    final response = await http.post(
      uri,
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: authToken.toString(),
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao aceitar solicitação do usuário $userId para o clube $clubId');
    }
  }

  Future<void> denyRequest(String clubId, String userId) async {
    final authToken = await _authToken;

    final uri = Uri.parse('$_apiUrl/api/v1/clubs/$clubId/requests/$userId/deny');

    final response = await http.delete(
      uri,
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: authToken.toString(),
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao negar solicitação do usuário $userId para o clube $clubId');
    }
  }

}
